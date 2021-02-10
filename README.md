# FixTypos:  A Function for Context Sensitive Typo Correction
## VERY much a work-in-progress!

Function designed to fix typos in open-ended survey data. Uses dataset's own words to replace non-words based on most-frequently used near-match.

Inspired heavily by [Rasmus Bååth's 2-line R adaptation](http://www.sumsar.net/blog/2014/12/peter-norvigs-spell-checker-in-two-lines-of-r/) of [Peter Norvig's spell-checker](http://www.norvig.com/spell-correct.html). 

The Norvig solution looks for the most commonly-occuring near-match for within a "clean" set of external words (a bunch of public-domain book excerpts, wiktionary words, etc).  That solution is great, but I wanted to adapt it for use in finding typos in open-ended survey data. Because surveys are generally about a *specific* concept, the distributions of words in any pre-constructed set of texts will probably not be appropriate. 

Instead of referencing an external word base & distribution, this function uses hunspell to FIRST identify non-words in the provided dataset, then search for good replacements among hunspell-approved words in that dataset. If no good replacement is found among the hunspell-approved words, then the original (misspelled) word is returned. 

Relies on:
  dplyr
  tidytext
  tm
  hunspell

