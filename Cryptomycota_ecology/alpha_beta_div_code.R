# This is the code to calculate alpha and beta diversity for Crypto samples
# It also was used to calculate indicator species, or OTUs with preferences to particular habitats
# Code was used from https://pedrohbraga.github.io/CommunityPhylogenetics-Workshop/CommunityPhylogenetics-Workshop.html

library("picante")
library("ggplot2")
library("magrittr")
library("vegan")

# Read in data
phy<-read.tree("RAxML_bipartitions.final_tree_constrained_bootstraps.12.09.19_renamed.tre")
comm_data <- read.table (file = "Biom_Cryptomycota_habitats_reconciled_v2.txt", header=TRUE,row.names=1)
prunedphy <- prune.sample(comm_data, phy)

# function to calculate the standardized effect size of a phylogenetic beta-diversity metric. 
# This code comes from https://pedrohbraga.github.io/CommunityPhylogenetics-Workshop/CommunityPhylogenetics-Workshop.html
ses.PBD <- function(obs, rand){
# first, we make sure our observed PhyloSor values are numeric
pbd.obs <- as.numeric(obs)
# then, we take the mean of the 100 null expectations we generated
rand <- t(as.data.frame(lapply(rand, as.vector)))
pbd.mean <- apply(rand, MARGIN = 2,
FUN = mean,
na.rm = TRUE)
# as well as their standard deviation
pbd.sd <- apply(rand,
MARGIN = 2,
FUN = sd,
na.rm = TRUE)
# now, we can calculate the standardized effect size (SES)!
pbd.ses <- (pbd.obs - pbd.mean)/pbd.sd
# rank observed PhyloSor (we use this to calculate p-values for SES)
pbd.obs.rank <- apply(X = rbind(pbd.obs, rand),
MARGIN = 2,
FUN = rank)[1, ]
pbd.obs.rank <- ifelse(is.na(pbd.mean), NA, pbd.obs.rank)
# return results in a neat dataframe
data.frame(pbd.obs,
pbd.mean,
pbd.sd,
pbd.obs.rank,
pbd.ses,
pbd.obs.p = pbd.obs.rank/(dim(rand)[1] + 1))
}

# End code from https://pedrohbraga.github.io/CommunityPhylogenetics-Workshop/CommunityPhylogenetics-Workshop.html

# Calculate PD and Sobs
pd.result <- pd(comm_data, prunedphy, include.root = TRUE)

pd.result
#                 PD  SR
#Freshwater 6.880039 175
#Marine     1.242097  25
#Plant      1.405166  20
#Sediment   4.379492  96
#Soil       4.150250  72

# Calculate Unifrac distances for full matrix
crypto.uni <- unifrac(comm = comm_data, tree = prunedphy)
crypto.uni
# Output
#         Freshwater    Marine     Plant  Sediment
#Marine    0.8684065                              
#Plant     0.8131621 0.7374088                    
#Sediment  0.5851862 0.8245589 0.7909360          
#Soil      0.7658206 0.8292784 0.8367548 0.5744675

# Randomize the data to calculate SES
crypto.rnd <- list()
for(i in 1:100){ # randomize the community 100 times
crypto.rnd[[i]] <- randomizeMatrix(comm_data, null.model = "richness")
}

# Calculate unifrac on randomized matrix
crypto.uni.rnd <- lapply(crypto.rnd, unifrac, tree = prunedphy)

# Calculate SES using function ses.PBD
crypto.ses.uni <- ses.PBD(obs = crypto.uni, rand = crypto.uni.rnd)

crypto.ses.uni
# Output
#     pbd.obs  pbd.mean     pbd.sd pbd.obs.rank     pbd.ses pbd.obs.p
#1  0.8684065 0.7774877 0.03717989          100  2.44537573 0.9900990
#2  0.8131621 0.7973250 0.03792858           64  0.41755083 0.6336634
#3  0.5851862 0.4747414 0.04123086          101  2.67869209 1.0000000
#4  0.7658206 0.5491353 0.04902047          101  4.42030328 1.0000000
#5  0.7374088 0.7405171 0.06135262           47 -0.05066187 0.4653465
#6  0.8245589 0.7451615 0.04865949           97  1.63169504 0.9603960
#7  0.8292784 0.7308470 0.05078597          100  1.93816125 0.9900990
#8  0.7909360 0.7702556 0.04316763           67  0.47907063 0.6633663
#9  0.8367548 0.7604615 0.05315164           95  1.43538991 0.9405941
#10 0.5744675 0.5726674 0.04948512           52  0.03637713 0.5148515

# Calculate Chao1 and ACE using vegan

chao1_ACE<-estimateR(comm_data)
chao1_ACE
#         Freshwater    Marine     Plant   Sediment      Soil
#S.obs    174.000000 25.000000 20.000000  96.000000 72.000000
#S.chao1  178.871795 36.000000 29.000000 102.333333 73.312500
#se.chao1   3.234803  8.863831  7.601951   4.084194  1.602335
#S.ACE    185.083556 39.637882 32.054131 111.043912 75.494303
#se.ACE     6.248114  3.254560  2.858108   5.004718  3.985209

# Calculate Chao1 on sample data (not just the combined data) using vegan
# Data set is Biom_Cryptomycota_habitats_samples_reconciled.txt
sample_comm_data <- read.table (file = "Biom_Cryptomycota_samples_reconciled.txt", header=TRUE,row.names=1)
chao1_ACE_samples<-estimateR(sample_comm_data)
write.table(chao1_ACE_samples, file="chao1_ACE_samples.txt")

# Heatmap code from https://pedrohbraga.github.io/CommunityPhylogenetics-Workshop/CommunityPhylogenetics-Workshop.html
crypto.ses.uni.m <- crypto.uni
# assign UniFrac value to each cell
for(i in 1:length(crypto.uni)) {crypto.ses.uni.m[i] <- crypto.ses.uni$pbd.ses[i]}
# plot heatmap using ggplot
crypto.ses.uni.m %>% as.matrix() %>% melt() %>% # manipulate data into a format that works for ggplot
ggplot() +
geom_tile(aes(x = Var1, y = Var2, fill = value)) + # create the heatmap
scale_fill_gradient2(low = "blue", mid = "white", high = "red") + # create a diverging color palette
xlab("sites") + ylab("sites") + labs(fill = "SES_UniFrac") + # edit axis and legend titles
theme(axis.text.x = element_text(angle = 90)) # rotates x axis labels
# end code from https://pedrohbraga.github.io/CommunityPhylogenetics-Workshop/CommunityPhylogenetics-Workshop.html


# Now do the above using rarefaction
# List to store the rarefied reps
crypto.rarefy.reps <- list()
# List to store the unifracs of the rarefied list
crypto.rarefy.uni <- list()
# List to store the PD of the rarefied list
crypto.rarefy.PD <- list()
# List to store the Chao1/ACE of the rarefied list
crypto.rarefy.ChaoACE <- list()
# List to store the SES of the rarefied list
crypto.ses.rarefied <- list()

library(GUniFrac)
for(i in 1:100){ # rarefy the community 100 times
crypto.rarefy.reps[[i]] <- comm_data.rff<-Rarefy(comm_data, 165)$otu.tab.rff
crypto.rarefy.uni[[i]] <- unifrac(comm = crypto.rarefy.reps[[i]], tree = prunedphy)
crypto.rarefy.PD[[i]] <- pd(crypto.rarefy.reps[[i]], prunedphy, include.root = TRUE)
crypto.rarefy.ChaoACE[[i]] <- estimateR(crypto.rarefy.reps[[i]])

# List of randomizations to calculate SES
crypto.rnd_for_ses <- list()
for(j in 1:100){ # randomize the community 100 times
crypto.rnd_for_ses[[j]] <- randomizeMatrix(crypto.rarefy.reps[[i]], null.model = "richness")
} 

# Run unifrac on randomizations
crypto.uni.rnd <- lapply(crypto.rnd_for_ses, unifrac, tree = prunedphy)
# Calculate SES of randomizations
crypto.ses.rarefied[[i]] <- ses.PBD(obs = crypto.rarefy.uni[[i]], rand = crypto.uni.rnd)
}

# Now to get list of values and averages to make final table
# Average PD and SO
# Average ChaoACE
# Average UNI and Average SES/rank/P of PBD

# These give the means
library(plyr)
# c(2,3) means to apply across rows and columns
mean_rarefied_PD <- aaply(laply(crypto.rarefy.PD, as.matrix), c(2, 3), mean)
mean_rarefied_unifrac <- aaply(laply(crypto.rarefy.uni, as.matrix), c(2, 3), mean)
mean_rarefied_ses_uni <- aaply(laply(crypto.ses.rarefied, as.matrix), c(2, 3), mean)
mean_rarefied_ChaoACE <- aaply(laply(crypto.rarefy.ChaoACE, as.matrix), c(2, 3), mean)

mean_rarefied_PD
#            X2
#X1                 PD    SR
#  Freshwater 2.607228 53.65
#  Marine     1.242097 25.00
#  Sediment   1.836090 35.59
#  Soil       2.679411 38.52

mean_rarefied_unifrac
#            X2
#X1           Freshwater    Marine  Sediment      Soil
#  Freshwater  0.0000000 0.7570750 0.7387958 0.8120946
#  Marine      0.7570750 0.0000000 0.7435211 0.7951980
#  Sediment    0.7387958 0.7435211 0.0000000 0.7298971
#  Soil        0.8120946 0.7951980 0.7298971 0.0000000

mean_rarefied_ses_uni
#   X2
#X1    pbd.obs  pbd.mean     pbd.sd pbd.obs.rank   pbd.ses pbd.obs.p
#  1 0.7570750 0.7223696 0.05660818        70.83 0.6167174 0.7012871
#  2 0.7387958 0.6866580 0.05838140        76.99 0.8962826 0.7622772
#  3 0.8120946 0.6799968 0.05771931        99.39 2.2943889 0.9840594
#  4 0.7435211 0.7215389 0.06146675        62.07 0.3550026 0.6145545
#  5 0.7951980 0.7217696 0.06103687        88.97 1.2113736 0.8808911
#  6 0.7298971 0.6970860 0.06063542        65.80 0.5431745 0.6514851

mean_rarefied_ChaoACE
#          X2
#X1         Freshwater    Marine  Sediment      Soil
#  S.obs      54.11000 25.000000 35.400000 38.630000
#  S.chao1   110.61284 36.000000 67.446224 62.167991
#  se.chao1   29.32752  8.863831 19.891426 14.616020
#  S.ACE     111.35542 39.637882 73.881757 67.281477
#  se.ACE      6.24671  3.254560  5.200719  4.745931
#

# This is to get a matrix of all values that can be used to extract range, CIs, etc.
library(dplyr)
do.call(rbind, setNames(crypto.rarefy.PD, NULL))
all_rarefied_PD <- bind_rows(crypto.rarefy.PD, .id = "column_label")
write.table(all_rarefied_PD, file="all_rarefied_PD.txt")
all_rarefied_ses_uni <- bind_rows(crypto.ses.rarefied, .id = "column_label")
write.table(all_rarefied_ses_uni, file="all_rarefied_ses_uni.txt")
all_crypto.rarefy.uni_rows <- sapply(crypto.rarefy.uni, as.vector, USE.NAMES = TRUE)
write.table(all_crypto.rarefy.uni_rows, file="all_crypto.rarefy.uni_rows.txt")
all_crypto.ChaoACE <- bind_rows(as.data.frame(crypto.rarefy.ChaoACE), .id = "column_label")
write.table(all_crypto.ChaoACE, file="all_crypto.ChaoACE.txt")

# Heatmap of SES Unifrac

data<-read.table("unifrac_ses_v2.txt", header=T)
data$x <-factor(data$x, levels = c("Freshwater", "Marine", "Sediment", "Soil", "Plant"))
data$y <-factor(data$y, levels = c("Freshwater", "Marine", "Sediment", "Soil", "Plant"))
p<-ggplot(data,aes(x=x, y=y, fill = value)) + geom_tile() + # create the heatmap
scale_fill_gradient2(low = "blue", mid = "white", high = "red") + # create a diverging color palette
xlab("sites") + ylab("sites") + labs(fill = "SES_UniFrac") + # edit axis and legend titles
theme(axis.text.x = element_text(angle = 90)) # rotates x axis labels

# This code identifies species with preferences for particular habitats using Indicspecies

library(indicspecies)
data<-read.table("sites_crypto_abund.txt", row.names=1,  col.names=,1)
habitat<-c(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5)
str_assoc<-strassoc(data, cluster=habitat,func="r")
sig_assoc<-signassoc(data, cluster=habitat, mode=1, control = how(nperm=999))