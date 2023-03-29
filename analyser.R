
###############################################################################################################
#Analyser
#
#Imports a data set from OMR and does stuff.


###############################################################################################################
# Load data set and set NAs to zeroes
###############################################################################################################

library(tidyverse)
library(dplyr)
source("OMR_functions.R")


  df<-as.tibble(read_csv("OMR/outputs/draft_period/Results/Results_01PM.csv",na = "")) %>%
    replace(is.na(.), 0)

###################################################################################################################################
# Get start date with numericator function - reads pre-printed grid
####################################################################################################################################

start.date<-df %>% select(file_id) %>%
  mutate(
    y1 = numericator(select(df,c(file_id,Q121:Q123)),id.name = "file_id",lead.digit = 0),
    y2 = numericator(select(df,c(file_id,Q124:Q126)),id.name = "file_id",lead.digit = 0),
    y3 = numericator(select(df,c(file_id,Q127:Q136)),id.name = "file_id",lead.digit = 0),
    m1 = numericator(select(df,c(file_id,Q137:Q138)),id.name = "file_id",lead.digit = 0),
    m2 = numericator(select(df,c(file_id,Q139:Q148)),id.name = "file_id",lead.digit = 0),
    d1 = numericator(select(df,c(file_id,Q149:Q152)),id.name = "file_id",lead.digit = 0),
    d2 = numericator(select(df,c(file_id,Q153:Q162)),id.name = "file_id",lead.digit = 0),
    date = as.Date(str_c("2",y1,y2,y3,"-",m1,m2,"-",d1,d2)),
    day = 1
      )%>%
    select(file_id,date,day)

####################################################################################################################################
# Set number of days and complete table - uses ndays to define how many days are on a page
####################################################################################################################################
ndays = 7

start.date<-expand_grid(start.date$file_id,1:ndays) %>%
  set_names(c("file_id","day")) %>%
  full_join(.,start.date) %>%
  group_by(file_id) %>%
  mutate(date=date[1]+(day-1),
         sheet.day=str_c("d",day,sep="")) %>%
  distinct()


###################################################################################################################################
#get ID Number from pre-printed grid
####################################################################################################################################

id<-df %>% select(file_id) %>%
  mutate(
    p1 = numericator(select(df,c(file_id,Q163:Q172)),id.name = "file_id",lead.digit = 0),
    p2<-numericator(select(df,c(file_id,Q173:Q182)),id.name = "file_id",lead.digit = 0),
    p3<-numericator(select(df,c(file_id,Q183:Q192)),id.name = "file_id",lead.digit = 0),
    p4<-numericator(select(df,c(file_id,Q193:Q202)),id.name = "file_id",lead.digit = 0),
    p5<-numericator(select(df,c(file_id,Q203:Q212)),id.name = "file_id",lead.digit = 0),
    p6<-numericator(select(df,c(file_id,Q213:Q222)),id.name = "file_id",lead.digit = 0),
    p7<-numericator(select(df,c(file_id,Q223:Q232)),id.name = "file_id",lead.digit = 0),
    p8<-numericator(select(df,c(file_id,Q233:Q242)),id.name = "file_id",lead.digit = 0),
    p9<-numericator(select(df,c(file_id,Q243:Q252)),id.name = "file_id",lead.digit = 0),
    p10<-numericator(select(df,c(file_id,Q253:Q262)),id.name = "file_id",lead.digit = 0),
    id = str_c(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,sep="")
      )%>%
  select(file_id,id)


####################################################################################################################################
# Use qmaker function to get data from questions, binding each question in to the data set as you go
####################################################################################################################################
{
data.out <-                   q.maker(select(df,c(file_id,Q01:Q04)),q = "d1_class",a = c("All","Some","None","School.Closed"))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q05:Q06)),q = "d1_exam",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q07:Q10)),q = "d1_period",a = c("No","Light.Period","Moderate.Period","Heavy.Period")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q11:Q12)),q = "d1_period.pain",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q13:Q14)),q = "d1_painkillers",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q15:Q17)),q = "d1_sleep",a = c("Good","Fair","Poor")))

data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q18:Q21)),q = "d2_class",a = c("All","Some","None","School.Closed")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q22:Q23)),q = "d2_exam",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q24:Q27)),q = "d2_period",a = c("No","Light.Period","Moderate.Period","Heavy.Period")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q28:Q29)),q = "d2_period.pain",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q30:Q31)),q = "d2_painkillers",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q32:Q34)),q = "d2_sleep",a = c("Good","Fair","Poor")))

data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q35:Q38)),q = "d3_class",a = c("All","Some","None","School.Closed")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q39:Q40)),q = "d3_exam",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q41:Q44)),q = "d3_period",a = c("No","Light.Period","Moderate.Period","Heavy.Period")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q45:Q46)),q = "d3_period.pain",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q47:Q48)),q = "d3_painkillers",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q49:Q51)),q = "d3_sleep",a = c("Good","Fair","Poor")))

data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q52:Q55)),q = "d4_class",a = c("All","Some","None","School.Closed")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q56:Q57)),q = "d4_exam",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q58:Q61)),q = "d4_period",a = c("No","Light.Period","Moderate.Period","Heavy.Period")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q62:Q63)),q = "d4_period.pain",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q64:Q65)),q = "d4_painkillers",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q66:Q68)),q = "d4_sleep",a = c("Good","Fair","Poor")))

data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q69:Q72)),q = "d5_class",a = c("All","Some","None","School.Closed")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q73:Q74)),q = "d5_exam",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q75:Q78)),q = "d5_period",a = c("No","Light.Period","Moderate.Period","Heavy.Period")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q79:Q80)),q = "d5_period.pain",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q81:Q82)),q = "d5_painkillers",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q83:Q85)),q = "d5_sleep",a = c("Good","Fair","Poor")))

data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q86:Q89)),q = "d6_class",a = c("All","Some","None","School.Closed")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q90:Q91)),q = "d6_exam",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q92:Q95)),q = "d6_period",a = c("No","Light.Period","Moderate.Period","Heavy.Period")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q96:Q97)),q = "d6_period.pain",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q98:Q99)),q = "d6_painkillers",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q100:Q102)),q = "d6_sleep",a = c("Good","Fair","Poor")))

data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q103:Q106)),q = "d7_class",a = c("All","Some","None","School.Closed")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q107:Q108)),q = "d7_exam",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q109:Q112)),q = "d7_period",a = c("No","Light.Period","Moderate.Period","Heavy.Period")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q113:Q114)),q = "d7_period.pain",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q115:Q116)),q = "d7_painkillers",a = c("No","Yes")))
data.out <-bind_rows(data.out,q.maker(select(df,c(file_id,Q117:Q119)),q = "d7_sleep",a = c("Good","Fair","Poor")))

}

data.out<-arrange(data.out,file_id,question) %>%
  separate(col = question,into = c("sheet.day","question"),sep = "_") %>%
  left_join(id,.) %>%
  left_join(start.date,.) %>%
  select(id,date,file_id,-day,sheet.day,question,answer,n.answers) %>%
  arrange(id,date)

data.out
