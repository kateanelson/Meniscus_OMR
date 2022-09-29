library(tidyverse)




########################################################################################################################################
# Function to define a grid based representation of a numeric for OMR forms
# id provides the number of the text
# id.length provides padding to ensure that leading zeroes are not lost - default 5 digits
########################################################################################################################################

omr.encoder<-function(id,id.length=10,show.title=F,xaxis=10,yaxis=10){
                         # if(nchar(id)>id.length){id.length = nchar(id)}
                          id=str_pad(id, id.length, pad = "0")

                          id.grid.data<-tibble(
                                              x = as.numeric(1:nchar(id)),
                                              y = as.numeric(unlist(str_split(id,pattern = "")))
                                              )

                          id.grid.chart<- ggplot(id.grid.data,aes(x,y))+
                                            geom_tile()+
                                            ylim(-1,yaxis+1)+
                                            xlim(-1,id.length+1)+
                                           theme_void() +
                            coord_fixed()

                          if(show.title==T){id.grid.chart = id.grid.chart+ggtitle(id)}
                          return(id.grid.chart)
}
#examples
#omr.encoder(0134,id.length = 10)
#omr.encoder(0134,id.length = 10,show.title = T)
#omr.encoder("20220913",id.length = 10,show.title = F)

########################################################################################################################################
# Function to define a grid based representation of a question
# Provides an n x n grid based on the number of answer options (columns) and number of question rows (rows)
# box.size sets the checkboxes
########################################################################################################################################


omr.question<-function(
    #define number of boxes in columns
    n.x,
    #define number of boxes in rows
    n.y,

    #set size of rectangle
    rec.size=3,

    #set size of padding
    padding.x = 1,
    padding.y = 1,

     #define columns to remove
    rm.x=NULL,
    rm.y=NULL,

    #define some names
    xlabs,
    ylabs,

    #define label angles and sizes
    x.angle = 60,
    y.angle = 0,

    x.lims= c(-30, 100),
    y.lims= c(120, -20)


){

  #calculate positions of boxes (x)
  xpos<- seq(1,((rec.size+padding.x)*n.x),rec.size+padding.x)
  #remove any you don't want
  if(!is.null(rm.x)){xpos<- xpos[-rm.x]}

  #calculate positions of boxes (y)
  ypos<- seq(1,((rec.size+padding.y)*n.y),rec.size+padding.y)
  #remove any you don't want
  if(!is.null(rm.y)){ypos<- ypos[-rm.y]}

  # Expand the grid, filtering out the columns we don't want
  q.grid<-as_tibble(expand.grid(xpos,ypos))


  output<- ggplot(q.grid) + xlim(x.lims) + ylim(y.lims)+
    geom_rect(aes(xmin = Var1, xmax = Var1+rec.size, ymin = Var2, ymax = Var2+rec.size),fill = "white", alpha = 1, color = "black")+
    annotate(geom = "text",x = xpos+0.5*rec.size,y = -35,label=xlabs,angle = x.angle,hjust = 0)+
    annotate(geom = "text",y = ypos+0.5*rec.size,x = -35,label=ylabs,angle = y.angle,hjust = 1)+
    theme(plot.margin = margin(2,2,2.5,2.2, "cm"))+
    coord_fixed()+
    theme_void()


  return(output)
}

#Examples
#omr.question.2(n.x = 15,n.y = 8,rec.size = 2,padding.x = 1,padding.y = 1,xlabs=c(1:15),ylabs = c(1:8))
#omr.question.2(n.x = 3,n.y = 3,rec.size = 2,padding.x = 1,padding.y = 1,xlabs=c("Anyway you like it","B","C"),ylabs = c("Cat","Dog","Fish"))
#omr.question.2(n.x = 3,n.y = 3,rec.size = 4,padding.x = 5,padding.y = 2,xlabs=c("Anyway you like it","B","C"),ylabs = c("Cat","Dog","Fish"))

#omr.question.2(n.x = 15,n.y = 8,rec.size = 2,padding.x = 1,padding.y = 1,rm.x = c(4,6,12),rm.y = c(2,6))
#omr.question.2(n.x = 15,n.y = 8,rec.size = 3,padding.x = 1,padding.y = 1,rm.x = c(4,6,12),rm.y = c(2,6))






###############################################################################################################
# Create a function to get the answers out of the OMR data.
# You have to provide
# df: needs to include the file_id, plus the Question variables (i.e. c(file_id,Q02:Q06))
# q : the column name for the eventual variable
# a : a list of answers
#
# This outputs a tidy list in long format, which allows for multiple boxes to be ticked for each question.
# Beware that this could cause problems if you were only expecting a single box
# It captures NA for empty answers
###############################################################################################################
q.maker = function(df,q,a) {
  output<- df %>%
    setNames(.,c("file_id",a)) %>%
    mutate(question = q) %>%
    select(file_id,question,everything()) %>%
    pivot_longer(cols = 3:ncol(.),names_to = "answer",values_to = "score") %>%
    mutate(
      answer  = case_when(score==1 ~ answer)) %>%
    distinct() %>%
    group_by(file_id,question) %>%
    mutate(n.answers=sum(score)) %>%
    filter(!(n.answers>0 & is.na(answer))) %>%
    select(-score)
  return (output)
}

################################################################################################################
# Example
###############################################################################################################
#q.maker(select(df,c(file_id,Q01:Q04)),q = "Happy",a = c("Y","N","DL","ITD"))
###############################################################################################################



###############################################################################################################
# Create a function to get the ID numbers from an n*n matrix
# You have to provide
# df: needs to include the file_id, plus the Question variables (i.e. c(file_id,Q02:Q06))
# q : the column name for the eventual variable
# a : a list of answers
#
# This outputs a tidy list in long format, which allows for multiple boxes to be ticked for each question.
# Beware that this could cause problems if you were only expecting a single box
# It captures NA for empty answers
###############################################################################################################



numericator = function(df,id.name="file_id",lead.digit=0) {

  file_id <- df %>% select(id.name)

  output<-df %>%
    select(-id.name) %>%
    mutate_if(is.logical,as.numeric) %>%
    mutate_if(is.numeric,as.character) %>%
    unite("z",sep = "") %>%
    mutate(pos=str_locate(z, "1")[,1],)

  if(lead.digit==0){output <- output %>% mutate(pos=pos-1)}

  output<-bind_cols(file_id,output)
  return (as.numeric(output$pos))
}


################################################################################################################
# Example
###############################################################################################################
#numericator(select(df,c(file_id,Q183:Q192)),id.name = "file_id",lead.digit = 0)
###############################################################################################################

