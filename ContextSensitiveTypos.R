testdata<-read.csv(choose.files())

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
  dplyr::select(word)

wordlist$correct<-hunspell::hunspell_check(toupper(wordlist$word))
correctwords<-wordlist %>% filter(correct==TRUE)
misspellings<-wordlist %>% filter(correct==FALSE)

correct <-function(word) {c(correctwords[adist(word, correctwords$word) <= min(adist(word, correctwords$word), 2)], word)[1]}

misspellings$sugg<-unlist(lapply(misspellings$word, correct))    ## THIS IS INCREDIBLY SLOW!
misspellings <- misspellings %>% select(word, sugg)

return(misspellings)
  ## Currently returning just the typos and top suggestion. Can use that df as a dictionary to grepl fix. 
    # Might, however, want to change this behavior.
}




#### Splitting concat words ####
#
# 1. Read in "misspellings", specifically those whose original was returned as suggested.
# 2. Among those, split at each letter and check those 2 words. IF both are words, and that's the only row that is 2 words, keep it. 
# 3. If multiple rows tend to be marked as keepers, or non-keepers are being kept, then may need to incorporate a word "Score" based on ranking in the original database, as used in FixTypos(). Might need to anyway, because it's gonna be a little foolish to program under the assumption that it'll be fine...
#
#

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

test<-lapply(c("testthis","anotherone","a"),SplitWords)

testdf<-data.frame(word=c("testthis","anotherone","a"))	

testsplit<-FixTypos(testdata,Q1A)
testsplit<-subset(testsplit,word==sugg)

testsplit$sugg2<-(unlist(lapply(testsplit$word,SplitWords)))
testdf



testdf<-FixTypos(testdata,Q1A)
testdfsplitting<-subset(testdf,word==sugg)
testdfsplitting$sugg2<-unlist(lapply(testdfsplitting$word,SplitWords))





wordlist<-testdata %>% select(Q1A) %>%
	  dplyr::mutate(text=tm::removePunctuation(Q1A,preserve_intra_word_contractions=TRUE)) %>%
	  tidytext::unnest_tokens(word, text, token="words",to_lower=TRUE, strip_punct=FALSE, strip_numeric=TRUE) %>%
	  dplyr::count(word, sort=TRUE)



	
	
#### Working single-word with pre-loaded WORDLIST being preserved below, while working on dataframe version ####
# SplitWords <-function(inp) {   ### Currently works for singular argument, and with WORDLIST pre-loaded. 
# 	inp_nchar<-nchar(inp)
# 	inp_breaklist<-data.frame("n"=1:inp_nchar,
# 														"source.word"=rep(inp,inp_nchar))
# 	
# 	inp_breaklist$word1<-substr(inp_breaklist$source.word,start=0,stop=inp_breaklist$n)
# 	inp_breaklist$word2<-substr(inp_breaklist$source.word,start=inp_breaklist$n+1,inp_nchar)
# 	
# 	selected<-inp_breaklist[hunspell::hunspell_check(toupper(inp_breaklist$word1))==TRUE & hunspell::hunspell_check(toupper(inp_breaklist$word2))==TRUE,] %>%
# 		
# 	dplyr::left_join(rename(wordlist,count.1=n), by=c("word1"="word")) %>% 
# 	dplyr::left_join(rename(wordlist,count.2=n), by=c("word2"="word")) %>%
# 	mutate(lncount.1=log(count.1),
# 				 lncount.2=log(count.2)) %>%
# 	replace(is.na(.),0)  %>% 
# 	mutate(Score=rowMeans(select(.,lncount.1,lncount.2)), sugg=paste(word1,word2,sep=" ")) %>%
# 	filter(Score==max(Score)) %>%
# 	select(word=source.word,sugg) 
# return(selected)
# 	}
#### End preserved working single-arg version ####
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		
selected<-SplitWords("ateach")	
selected<-SplitWords("alliednationwide")	

selected<- selected %>% 
	dplyr::left_join(rename(wordlist,count.1=n), by=c("word1"="word")) %>% 
	dplyr::left_join(rename(wordlist,count.2=n), by=c("word2"="word")) %>%
	mutate(lncount.1=log(count.1),
				 lncount.2=log(count.2)) %>%
	replace(is.na(.),0)  %>% 
	mutate(Score=rowMeans(select(.,lncount.1,lncount.2)))
	# filter(Score==max(Score))
	# select(word1,word2)