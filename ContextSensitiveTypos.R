# testdata<-read.csv(choose.files())

FixTypos<-function(df, text) {
  # Required packages #
  require(dplyr)
  require(tm)
  require(tidytext)
  require(hunspell)
	
 
	wordlist<-df %>% select({{text}}) %>%
  dplyr::mutate(text=tm::removePunctuation({{text}},preserve_intra_word_contractions=TRUE)) %>%
  tidytext::unnest_tokens(word, text, token="words",to_lower=TRUE, strip_punct=FALSE, strip_numeric=TRUE) %>%
  dplyr::count(word, sort=TRUE) %>%
  dplyr::select(word,n)

wordlist$correct<-hunspell::hunspell_check(toupper(wordlist$word))
correctwords<-wordlist %>% filter(correct==TRUE)
misspellings<-wordlist %>% filter(correct==FALSE)

correct <-function(word) {c(correctwords$word[adist(word, correctwords$word) <= min(adist(word, correctwords$word), 2)], word)[1]}

misspellings$sugg<-unlist(lapply(misspellings$word, correct))    ## THIS IS INCREDIBLY SLOW!
misspellings <- misspellings %>% select(word, sugg)

SplitWords <-function(inp) {   ### will assume it gets just a list of words
	inp_nchar<-nchar(inp)
	inp_breaklist<-data.frame("n"=1:inp_nchar,
														"source.word"=rep(inp,inp_nchar))
	
	inp_breaklist$word1<-substr(inp_breaklist$source.word,start=0,stop=inp_breaklist$n)
	inp_breaklist$word2<-substr(inp_breaklist$source.word,start=inp_breaklist$n+1,inp_nchar)
	
	selected<-inp_breaklist[hunspell::hunspell_check(toupper(inp_breaklist$word1))==TRUE & hunspell::hunspell_check(toupper(inp_breaklist$word2))==TRUE,] 
	if (nrow(selected) >0) {
		selected<- selected %>%
			dplyr::left_join(rename(wordlist,count.1=n), by=c("word1"="word")) %>% 
			dplyr::left_join(rename(wordlist,count.2=n), by=c("word2"="word")) %>%
			mutate(lncount.1=log(count.1),
						 lncount.2=log(count.2)) %>%
			replace(is.na(.),0)  %>% 
			mutate(Score=rowMeans(select(.,lncount.1,lncount.2)), sugg=paste(word1,word2,sep=" ")) %>%
			filter(Score==max(Score) | is.na(Score)) %>%
			select(sugg) 
	}  else {
		selected<-data.frame(sugg=inp)
	}
return(selected$sugg[1])
}

possconcat<-subset(misspellings, word==sugg) %>% select(word)
possconcat$split<-(unlist(lapply(possconcat$word,SplitWords)))
RecTable<-misspellings %>% left_join(possconcat)
RecTable$sugg[RecTable$word==RecTable$sugg]<-RecTable$split[RecTable$word==RecTable$sugg]
RecTable$sugg[RecTable$sugg=="i"]<-RecTable$word[RecTable$sugg=="i"]
RecTable<-RecTable %>% select(-split)

# if (fix=TRUE) {
#		return(GREPL ORIGINAL COLUMN)
#  } else {
#		return(TABLE OF SUGGESTED REPLACEMENTS)
#  }
return(RecTable)
  ## Currently returning just the typos and top suggestion. Can use that df as a dictionary to grepl fix. 
    # Might, however, want to change this behavior.
}





# df$fixed<-gsub(paste0("\\b",word,"\\b"),sugg,df$raw)

