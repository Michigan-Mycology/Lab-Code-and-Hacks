#Load your libraries

library(vegan)
library(BiodiversityR)
library(MASS)
library(ggplot2)

comm<-read.csv("crypto_otus.csv", row.names = 1,check.names = FALSE)
tcomm<-t(comm)

grouping_info<-read.csv("Crypto_final_map_file.csv",row.names=1,check.names=FALSE)
head(grouping_info)

#                     State Country Year  Month      Substrate     Locale
#0175G_NorthLake         MI     USA 2014   July 0.8_um_filters Freshwater
#0196G_WoodlandLake      MI     USA 2014   July 0.8_um_filters Freshwater
#0224G_Crooked           MI     USA 2014   July 0.8_um_filters Freshwater
#0238G_SmithFenInlet     MI     USA 2014 August 0.8_um_filters Freshwater
#0239G_SmithsFenInlet    MI     USA 2014 August 0.8_um_filters Freshwater
#0242G_BurtLakefar       MI     USA 2014 August 0.8_um_filters Freshwater
#                       Specific
#0175G_NorthLake      Freshwater
#0196G_WoodlandLake   Freshwater
#0224G_Crooked        Freshwater
#0238G_SmithFenInlet  Freshwater
#0239G_SmithsFenInlet Freshwater
#0242G_BurtLakefar    Freshwater

sol<-metaMDS(tcomm,distance="bray", k=2, trymax = 5000)
#No convergence, then...

sol<-metaMDS(tcomm,distance="bray", k=2, noshare=0.2, trymax = 5000)

#Run 223 stress 0.2525146
#... New best solution
#... Procrustes: rmse 8.713072e-05  max resid 0.0003523964
#... Similar to previous best
#*** Solution reached

NMDS=data.frame(x=sol$point[,1],y=sol$point[,2],Sub=(grouping_info$Substrate),Loc=(grouping_info$Locale),Spec=(grouping_info$Specific))


#Make ellipses, if wanted
plot.new()
ord<-ordiellipse(sol, as.factor(grouping_info$Locale) ,display = "sites", kind ="sd", conf = 0.95, label = T)
dev.off()

#Create a data frame to put elipses around your categories
veganCovEllipse<-function (cov, center = c(0, 0), scale = 1, npoints = 100)
{
  theta <- (0:npoints) * 2 * pi/npoints
  Circle <- cbind(cos(theta), sin(theta))
  t(center + scale * t(Circle %*% chol(cov)))
}

#Generate ellipse points
df_ell <- data.frame()
for(g in levels(NMDS$Loc)){
  if(g!="" && (g %in% names(ord))){
    
    df_ell <- rbind(df_ell, cbind(as.data.frame(with(NMDS[NMDS$Loc==g,],
                                                     veganCovEllipse(ord[[g]]$cov,ord[[g]]$center,ord[[g]]$scale)))
                                  ,Loc=g))
  }
}

head(df_ell)
#      NMDS1     NMDS2        Loc
#1 0.6743124 0.2340824 Freshwater
#2 0.6725194 0.2796438 Freshwater
#3 0.6671474 0.3240105 Freshwater
#4 0.6582177 0.3670074 Freshwater
#5 0.6457654 0.4084649 Freshwater
#6 0.6298397 0.4482193 Freshwater


NMDS.mean=aggregate(NMDS[,1:2],list(group=NMDS$Loc),mean)
head(NMDS.mean)
#         group           x           y
#1 Freshwater -0.23434226 -0.02306909
#2     Marine  0.04942911  0.23609317
#3      Plant -0.06662380 -0.12219290
#4   Sediment  0.04800815  0.09380377
#5       Soil  0.48078342 -0.14131016


#Visualize various ways
ggplot(NMDS,aes(x,y,color=Loc))+
  geom_path(data=df_ell,aes(x=NMDS1, y=NMDS2), size=2, linetype=2)+
  geom_point(size=4,aes(shape=Loc))+
  annotate("text",x=NMDS.mean$x,y=NMDS.mean$y,label=NMDS.mean$group,size=6)+
  theme_bw()

ggplot(NMDS,aes(x,y,color=Loc))+
  geom_path(data=df_ell,aes(x=NMDS1, y=NMDS2), size=2, linetype=2)+
  geom_point(size=4,aes(shape=Loc))+
  theme_bw()


ggplot(NMDS,aes(x,y,color=Loc))+
  geom_point(size=6,aes(shape=Loc))+
  theme_bw()

