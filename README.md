# ContextSensitiveTypos
## VERY much a work-in-progress!

Function designed to fix typos in open-ended survey data. Uses dataset's own words to replace non-words based on most-frequently used near-match.

Built using Rasmus Bååth's 2-line R adaptation of Peter Norvig's famous spell-checker. That solution relies on a clean dataset and external words, though: Any misspelling already in the dataset would not get corrected. Instead, this function uses hunspell to FIRST identify non-words in the dataset, then search for replacements. If no good replacement is found among the hunspell-approved words, then the original (misspelled) word is returned. 

Relies on:
  dplyr
  tidytext
  tm
  hunspell

