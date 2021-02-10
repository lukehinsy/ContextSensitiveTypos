

function(df, text) {
wordlist<-df %>% select(text) %>%
  dplyr::mutate(text=tm::removePunctuation(text,preserve_intra_word_contractions=TRUE)) %>%
  tidytext::unnest_tokens(word, text, token="words",to_lower=TRUE, strip_punct=FALSE, strip_numeric=TRUE) %>%
  dplyr::count(word, sort=TRUE) %>%
  dplyr::select(word)

wordlist$correct<-hunspell::hunspell_check(toupper(wordlist$word))
correctwords<-wordlist %>% filter(correct=TRUE)
misspellings<-wordlist %>% filter(correct=FALSE)

correct <-function(word) {c(correctwords[adist(word, correctwords$word) <= min(adist(word, correctwords$word), 2)], word)[1]}

misspellings$sugg<-unlist(lapply(misspellings$word, correct))    ## THIS IS INCREDIBLY SLOW!
misspellings <- misspelings %>% select(word, sugg)
return(misspellings)
  ## Currently returning just the typos and top suggestion. Can use that df as a dictionary to grepl fix. 
    # Might, however, want to change this behavior.remote
}

