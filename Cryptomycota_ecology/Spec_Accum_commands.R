####Spec Accum Work####
#Break the OTU table up into csv files based on which sample type they are e.g. soil_otus.csv

library(vegan)
library(ggplot2)


tsed<-read.csv("sediment_otus.csv", row.names = 1,check.names = FALSE)
sed<-t(tsed)

spSed <-specaccum(sed, "random")
plot(spSed)


tsoil<-read.csv("soil_otus.csv", row.names = 1,check.names = FALSE)
soil<-t(tsoil)

spSoil <-specaccum(soil, "random")
plot(spSoil)

tfresh<-read.csv("freshwater_otus.csv", row.names = 1,check.names = FALSE)
fresh<-t(tfresh)

spFresh <-specaccum(fresh, "random")
plot(spFresh)


tmar<-read.csv("marine_otus.csv", row.names = 1,check.names = FALSE)
marine<-t(tmar)

spMarine <-specaccum(marine, "random")
plot(spMarine)


tinter<-read.csv("intertidal_otus.csv", row.names = 1,check.names = FALSE)
inter<-t(tinter)

spInter <-specaccum(inter, "random")
plot(spInter)


tplant<-read.csv("plant_otus.csv", row.names = 1,check.names = FALSE)
plant<-t(tplant)

spPlant <-specaccum(plant, "random")
plot(spPlant)

########Putting it together##########

#plot curve_all first
plot(spFresh, ci.type="bar", ci.col="gray", ylab="Cryptomycota OTUs", lwd=4)
#then plot the rest
plot(spSoil, add = TRUE, col = 5, ci.type="bar", ci.col="paleturquoise1", lwd=4) 
plot(spSed, add = TRUE, col = 2, ci.type="bar", ci.col="lightpink", lwd=4)
plot(spMarine, add = TRUE, col = 4, ci.type="bar", ci.col="lightblue", lwd=4)
plot(spPlant, add = TRUE, col = 3, ci.type="bar", ci.col="lightgreen", lwd=4)
legend('bottomright', c('Fresh', 'Sediment', 'Soil', 'Plant', 'Marine'), col=c("black","red","cyan","green", "blue"), lty=1, 
       bty='n', inset=0.08, lwd=4, text.font=4)




