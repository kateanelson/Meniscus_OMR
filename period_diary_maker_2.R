#########################################################################################
# ODK hardcopy in PDF v 1.0
#########################################################################################
#
# Step one of this script is a call to ODK briefcase via the command line, which pulls all
# records and media.
#
# Step two is to output individual records to a temp file, then bind their data with
# any images to make a pdf document.
#
# This work is licensed under Creative Commons Attribution-ShareAlike 3.0 Unported License
# http://creativecommons.org/licenses/by-sa/3.0/"
#########################################################################################
# Requirements
#
#needs latex and pandoc (external installations, use homebrew)
library(knitr)
library(readr)
library(dplyr)
library(anytime)
library(qrencoder)
library(png)
library(grid)
library(here)

#Run script to generate functions
source("OMR_functions.R")

#remotes::install_github('coolbutuseless/ggqr')
#
#########################################################################################
# call to ODK briefcase
# use full path including first subdirectory
# ie. https://projectx.odk.lshtm.ac.uk/projectx/
# any passwords with special characters will need escape characters
# i.e. password doggy!prunes12 needs to be specified as doggy\\!prunes12
# obviously shouldn't hardcode passwords. Better to call from the console using a readline() command but I am lazy
# Also need to specify the targets for input and output. Here TMIH_example
# I also renamed the jar file for ODK briefcase because I hate whitespace

df<-tibble(id=c(
  "8234567890",
  "4123456789"))


#set colours for qrcodes
group.colors <- c("0"="white","1"="black")




# enter loop for each row of the csv file
for(i in 1:dim(df)[1])
{
  #send a file for the current record to tmp
  write_csv(df[i,],"tmp.csv")

  id.barcode<-qrencode_df(df$id[i])
  id.num <- df$id[i]
  
  start.date = "2022-10-08"

  #BUILD THE QR CODE
  qr<-ggplot(id.barcode,aes(x,y,fill=as.factor(z)))+geom_tile()+
    scale_fill_manual(values = group.colors,name = "group")+
    theme_void()+ theme(legend.position="none")


  #create a grid for weeks
  wk.grid<-omr.encoder(str_remove_all(start.date,pattern = "-"),id.length = 10,show.title = F,yaxis=10,xaxis=10)+theme_void()

  #create a grid for ID

  id.grid<-omr.encoder(id.num,show.title=F,id.length = 10,xaxis=10,yaxis=10)


  # Create the main figure

  h.adjust.q=-350

  question.grid<- omr.question(
    n.x = 27,
    n.y = 7,
    rm.x = c(5,6,9,10,15:16,19:20,23:24),
    rec.size = 24,
    padding.x = 12,
    padding.y = 12,
    xlabs= c("All","Some","None","School Closed","No","Yes","No","Light Period","Moderate Period","Heavy Period","No","Yes","No","Yes","Good","Fair","Poor"),
    ylabs = format(seq(as.Date(start.date), by = "day", length.out = 7), format="%a, %d %b"),
    x.lims = c(-130,1000),
    y.lims = c(260,h.adjust.q),
    x.angle = 80, 
    size = 3
  )+
    annotate(geom = "text",x = 75,y = h.adjust.q,label="How much\nclass did you\nattend today?",angle = 0,hjust = 0.5,vjust=1,size=3,lineheight=1)+
    annotate(geom = "text",x = 250,y = h.adjust.q,label="Did you\nhave an\nexam\ntoday?",angle = 0,hjust = 0.5,vjust=1,size=3,lineheight=1)+
    annotate(geom = "text",x = 430,y = h.adjust.q,label="Are you in\nyour period\ntoday?",angle = 0,hjust = 0.5,vjust=1,size=3,lineheight=1)+
    annotate(geom = "text",x = 610,y = h.adjust.q,label="Did you\nhave\nperiod pain\ntoday?",angle = 0,hjust = 0.5,vjust=1,size=3,lineheight=1)+
    annotate(geom = "text",x = 755,y = h.adjust.q,label="Did you\nhave to\ntake\npainkillers\ntoday?",angle = 0,hjust = 0.5,vjust=1,size=3,lineheight=1)+
    annotate(geom = "text",x = 915,y = h.adjust.q,label="How was\nyour sleep\nlast night?",angle = 0,hjust = 0.5,vjust=1,size=3,lineheight=1)+
    annotate(geom = "text",x = -100,y = -130,label=id.num,angle = 0,hjust = 0.5,vjust=1,size=2,lineheight=1)+ 

    #add lines
    geom_vline(xintercept = c(-25,180,320,535,680,830,1000), size =0.25)+
    geom_hline(yintercept = c(-20,260), size = 0.25)

  annotation_custom(ggplotGrob(qr), xmin = -130, xmax = -30, ymin = 20, ymax = 120)

  # get the meniscus logo
  img<-readPNG("meniscus_logo.png")
  g <- rasterGrob(img, interpolate=TRUE)

  # get the omr marker
  img2<-readPNG(here("OMR", "inputs", "draft_period", "omr_marker.png"))
  g2 <- rasterGrob(img2, interpolate=TRUE)

  #Build the form


  final<-ggplot(tibble(x=0:1000,y=0:1000),aes(x,y)) +
    #add the meniscus logo and QR
    annotation_custom(g, xmin=0.4, xmax=0.6, ymin=0.9, ymax=1)+
    annotation_custom(ggplotGrob(qr), xmin = 0.0, xmax = 0.05, ymin = 0.95, ymax = 1.0)+
    #add the question grid
    annotation_custom(ggplotGrob(question.grid), xmin = 0.04, xmax = 0.94, ymin = 0.25, ymax = 0.75)+
    # add the omr marks
    annotation_custom(g2, xmin=0.0, xmax=0.03, ymin=0.6, ymax=1)+
    annotation_custom(g2, xmin=0.0, xmax=0.03, ymin=-1.05, ymax=1)+
    annotation_custom(g2, xmin=0.97, xmax=1, ymin=0.6, ymax=1)+
    annotation_custom(g2, xmin=0.97, xmax=1, ymin=-1.05, ymax=1)+
    annotation_custom(ggplotGrob(wk.grid), xmin = 0.45, xmax = 0.2, ymin = -0.5, ymax = 0.75)+
    annotation_custom(ggplotGrob(id.grid), xmin = 0.7, xmax = 0.45, ymin = -0.5, ymax = 0.75)+
    theme_void()

  final
  ggsave("tmp.png")

  #convert datetimes so that reports sort appropriately by date of submission

  #run RMD script to create report in pdf, pulling in any jpgs
  rmarkdown::render(input = "pdfmaker2.Rmd",
                    output_file = str_c(df[i,],".pdf"),
                    output_dir = "output/")

}

#This work is licensed under Creative Commons Attribution-ShareAlike 3.0 Unported License
#http://creativecommons.org/licenses/by-sa/3.0/"

#Nuff respect to VP Nagraj [twitter @vpnagraj] from whose scripts I reused some of the control structure for calling RMD from another R script
#See http://nagraj.net/notes/multiple-rmarkdown-reports/



