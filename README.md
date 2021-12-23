# FixTypos:  A Function for Context-Sensitive Typo Correction
## Very much a work-in-progress!

### Usage
```
output <- FixTypos(df, colname)
```

input the dataframe containing your open-ended text column, and the name of the text column. 

"output" will contain a table of the "words" identified as non-words, and the top suggestion for each. 

### Details
Function designed to fix typos in open-ended survey data. Uses dataset's own words to replace non-words based on most-frequently used near-match.

Inspired by [Rasmus Bååth's 2-line R adaptation](http://www.sumsar.net/blog/2014/12/peter-norvigs-spell-checker-in-two-lines-of-r/) of [Peter Norvig's spell-checker](http://www.norvig.com/spell-correct.html). 

The Norvig solution looks for the most commonly-occuring near-match for within a "clean" set of external words (a bunch of public-domain book excerpts, wiktionary words, etc).  That solution is great, but I wanted to adapt it for use in finding typos in open-ended survey data. Because surveys are generally about a *specific* concept, the distributions of words in any pre-constructed set of texts will probably not be appropriate. 

Instead of referencing an external word base & distribution, this function uses hunspell to FIRST identify non-words in the provided dataset, then search for good replacements among hunspell-approved words in that dataset. If no good replacement is found among the hunspell-approved words, then the original (misspelled) word is returned. 

### Helper Function: SplitWords
In addition, a function "SplitWords" has been built into this function that breaks each un-fixed word up into possible words.  It first pulls any words that did not receive a suggestion from the probabilistic word replacement in FixTypos. Then, it breaks that word up at every character, looking for (1) any instances of both halves being found in the hunspell dictionary. (2) If multiple instances, it assigns a score to rows, based on the mean of their log-occurrence in your specific dataset. So for "ateach", it will return both "at/each" and "a/teach".  If "at" occurs 3,000 times in your dataset (ln=8.01), and "each" occurs 1,200 times (ln=7.09), that split's mean log score would be 7.55. That would be compared to the mean log score of "a/teach", and the higher would be retained.  

This approach was chosen to get around Zipf's law--because word frequencies drop exponentially, we dontt want to score words by their base frequency. For example, in a training dataset, the frequencies for a/teach and at/each were: 8199/0 and 1038/169, or 2.40%/0.00% and 0.30%/0.05%. By any straightforward approach to those numbers, a/teach would be identified as most-likely, despite having a word that doesn't appear at all in the underlying dataset. Any penalization term for that non-appearing word seems arbitrary, so instead the natural log was taken of frequencies to level that exponential advantage to high-frequency words. Using this log-frequency, we get scores of 9.01/0.00 and 6.95/5.13.  Now, two moderately-common words compete fairly (and, indeed, beat) one SUPER common word and a "foreign" word. 

This function is not yet optimized for external/independent use, but can easily be extracted and used by creating a "wordlist" file, with individual words from your data sorted by frequency of occurence.  Its input is a single character value (e.g., "ateach"), and is currently designed to output the single best-scoring word pair. Thus, to use it on a full vector/dataframe, one must lapply and unlist results. 

### Relies on:
* dplyr
* tidytext
* tm
* hunspell

## Future plans:
* Custom dictionary (see shortcomings below)
* Provide an argument for fix=T/F. Current behavior (outputting table of suggestions) would be fix=FALSE. Default behavior, though, would be fix=TRUE, which would then do the replacement on the original text column and output the new/replaced COLUMN. 

## Current shortcomings or known bugs:
* Probably better to test reversing ie to ei / ei to ie before subbing words. e.g., recieve is getting subbed with believe instead of receive. 
* "Words" containing numbers are not working super well. Probably worth just ignoring anything with a number; they will inherently be too unique to use a probabilistic replacement anyway. Right now, they're being split so number/text come out separately. The text suffix isn't helpful, though, so again--prob best to just drop.
* solo punctuation is (1) showing up, which should not be happening, and (2) being replaced with "I". Currently, just ignoring any "i" suggestions. 
* Custom dictionary is DEFINITELY required. Examples follow
	+ maybe "autopay"
	+ hvac
	+ mixup
	+ vin
	+ dmv
	+ idk
	+ aarp
	+ i'm
	+ Generally, proper names--particularly orgs or specific product names
	+ ...

  
