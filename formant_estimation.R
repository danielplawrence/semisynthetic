##########################
# R script for generating praat formant objects
# by estimating formant contours from natural speech samples
# Daniel Lawrence Aprilis MMXV
##########################
data<-read.csv("tagliamonte_meas.csv")
vowels<-subset(data,vowel=="EY"|vowel=="OW"|vowel=="UW")
vowels$age_group=ifelse(vowels$year>1980,"Y",ifelse(vowels$year>1939,"M","O"))
vowels<-subset(vowels,stress==1)

get_formant<-function(x){return(unlist(strsplit(as.character(x),split="\\."))[1])}
get_point<-function(x){return(unlist(strsplit(as.character(x),split="\\."))[2])}

estimate_contour<-function(vowels){
library(gss)
library(reshape2)
df<-subset(vowels,stress=="1")[,c(4,11,16,69,46:55)]
df<-melt(df,id=c("age","sex","vowel","age_group"))
df$Formant<-as.factor(unlist(lapply(df$variable,get_formant)))
df$time.norm<-as.numeric(unlist(lapply(df$variable,get_point)))
df$age_group<-factor(df$age_group)


#####OW
f1<-subset(df,Formant=="F1")
f2<-subset(df,Formant=="F2")

fitf1<-ssanova(value~time.norm,data=f1)
fitf2<-ssanova(value~time.norm,data=f2)

grid<-expand.grid(time.norm=seq(20,65,length=100))
grid$F1.Fit <- predict(fitf1,grid,se = T)$fit
grid$F1.SE <- predict(fitf1,grid,se = T)$se.fit
grid$F2.Fit <- predict(fitf2,grid,se = T)$fit
grid$F2.SE <- predict(fitf2,grid,se = T)$se.fit
return(grid[,c(1,2,4)])
}


make_formant<-function(vowels){
cont<-estimate_contour(vowels)
write.csv(cont,"contour.csv")
system("/Applications/Praat.app/Contents/MacOS//praat /Users/pplsuser/semisynthetic/vowel_from_contour.psc /Users/pplsuser/semisynthetic/Original_A_token.wav /Users/pplsuser/FAVE/FAVE-extract-york/contour.csv")
}