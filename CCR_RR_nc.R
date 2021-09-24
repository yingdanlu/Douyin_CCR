####################################################################################
## SETUP
####################################################################################

#### wd and packages ####
setwd("//Volumes/GoogleDrive/My Drive/Yingdan/Research/JEN/Douyin/")

library(dplyr)
library(readr)
library(extrafont)
library(psych)
library(xtable)
library(ggplot2)
library(grid)
library(gridExtra)
library(ggpubr)
library(scales)
library(lubridate)
library(reshape2)
library(boot)
loadfonts()

#### functions ####
# mean function for bootstrap
my.mean = function(x, indices) {
  return( mean( x[indices] ) )
}

# bootstrap
boot.results <- function(variable){
  set.seed(120)
  a <- boot.ci(boot(variable, my.mean, 1000, parallel = "multicore"), index = 1, type=c('norm'))$norm
  return(c(my.mean(variable), a[2], a[3]))
}

vis <- function(dt, accounts, variable){
  mat <- data.frame(NA, 4, 4)
  for (i in 1:4){
    m <- boot.results(dt[dt$account_type2 == accounts[i], variable])
    mat[i,1] <- accounts[i]
    mat[i,2] <- round(m[1],4)
    mat[i,3] <- round(m[2],4)
    mat[i,4] <- round(m[3],4)
  }
  return(mat)
}

#### read data ####
all_sample_nc <- read.csv("CCR_final_nc_new.csv",
                       colClasses=c(rep("character",3),
                                    "numeric",
                                    "character",
                                    rep("numeric",11),
                                    rep("character",6)), 
                       stringsAsFactors = F)

####################################################################################
## Figure 3 and Table 1
####################################################################################

#### Figure 3 ####
## tabulate videos by account type
tab <- data.frame(table(all_sample_nc$account_type2))
## get the unique accounts and tabulate by account type
account_unique_nc <- all_sample_nc[!duplicated(all_sample_nc$uid),]
account_unique_nc <- data.frame(table(account_unique_nc$account_type2))
## merge with the video by account table and calculate the ratio
all_sample_type <- left_join(tab, account_unique_nc, by = "Var1")
colnames(all_sample_type) <- c("account_type", "videos", "accounts")
all_sample_type$videos_ratio <- all_sample_type$videos / nrow(all_sample_nc)*100
## round the ratio and rename the accounts for plotting
all_sample_type$videos_ratio <- round(all_sample_type$videos_ratio, 1)
all_sample_type$account_type <- factor(c("Celebrities", "Non-Official\nMedia", "Ordinary\nUsers", "Regime\nAffiliated"), 
                                       levels = c("Regime\nAffiliated", "Ordinary\nUsers",
                                                  "Celebrities", "Non-Official\nMedia"))
## plot
ggplot(all_sample_type, aes(x=account_type, y=videos_ratio, fill = account_type)) + 
  geom_bar(stat="identity", position=position_dodge(), colour = "black", width = 0.8) +
  ylab("")+
  scale_fill_manual(values = c("Regime\nAffiliated"="black","Ordinary\nUsers"="gray40",
                               "Celebrities"="gray40", "Non-Official\nMedia"="gray40"))+
  ylim(0,50)+
  geom_text(aes(label=videos_ratio), position=position_dodge(width=0.9), vjust = -0.25, size = 6)+
  ylab("Percent of featured trending videos")+  xlab("")+theme_classic()+
  theme(text = element_text(size=20, colour = "black"),
        axis.title.x = element_text(size=22, colour = "black"), 
        axis.title.y = element_text(size=22, colour = "black"), 
        axis.text.x  = element_text(size=20, colour = "black"), 
        axis.text.y = element_text(size=20, colour = "black"),
        legend.position = "None")

#### Table 1 ####
## find all regime-related videos
all_sample_regime_nc <- all_sample_nc[all_sample_nc$account_type2=="regime accounts",]
## differentiating different types of regime-related media
all_sample_regime_nc$account_type3 <- ifelse(
  all_sample_regime_nc$account_type == "official media" & 
    all_sample_regime_nc$daily == 1, "Mouthpiece\nNewspaper", 
  ifelse(all_sample_regime_nc$account_type == "official media" & 
           !is.na(all_sample_regime_nc$newspaper_ch), "Non-\nMouthpiece\nNewspaper", 
         ifelse(all_sample_regime_nc$account_type == "official media", "Other\nOfficial\nMedia", "Government\nCCP")))
## find all unique regime-related accounts and tabulate
account_unique_regime_nc <- subset(all_sample_regime_nc, !duplicated(uid))
account_unique_regime_nc <- data.frame(table(account_unique_regime_nc$account_type3))
tab <- data.frame(table(all_sample_regime_nc$account_type3))
account_unique_regime_nc <- left_join(tab, account_unique_regime_nc, by = "Var1")
colnames(account_unique_regime_nc) <- c("account_type", "videos", "accounts")
account_unique_regime_nc$rate <- account_unique_regime_nc$videos / account_unique_regime_nc$accounts
account_unique_regime_nc

####################################################################################
## Figure 4
####################################################################################
## get a list of account types
accounts <- unique(all_sample_nc$account_type2)

## calculate the mean value of visual features and ci through bootstrapping
luminance <- vis(all_sample_nc, accounts, "luminance_avg")
entropy <- vis(all_sample_nc, accounts, "entropy_avg")
warmth <- vis(all_sample_nc, accounts, "warmth")
cold <- vis(all_sample_nc, accounts, "cold")
duration <- vis(all_sample_nc, accounts, "duration")
face <- vis(all_sample_nc, accounts, "face_rate")

## combine as a dataframe and rename for plotting
visuals <- rbind.data.frame(luminance, entropy, warmth, cold, duration,face)
visuals$metric <- factor(rep(c("Brightness", "Entropy", 
                               "Warm color\ndominance", "Cold color\ndominance",
                               "Video length", "Face presence"), 
                             each = 4), levels = c("Brightness", "Entropy", 
                                                   "Cold color\ndominance", 
                                                   "Warm color\ndominance",
                                                   "Video length", "Face presence"))
colnames(visuals) <- c("account_type","mean", "down", "upper", "metric")
visuals$account_type <- factor(rep(c("Ordinary users", "Celebrities", "Regime\nAffiliated", "Non-official\nmedia"),6), 
                               levels = rev(c("Regime\nAffiliated", "Ordinary users",
                                              "Celebrities", "Non-official\nmedia")))

## Plot
g1 <- ggplot(subset(visuals, metric %in% c("Brightness", "Entropy", "Video length")), aes(x=account_type, y=mean, ymin=down, ymax=upper, color = account_type))+
  geom_pointrange(size = 0.6, fatten = 2.5)+ xlab("") + 
  scale_colour_manual(values = c("Regime\nAffiliated"="red","Ordinary users"="black",
                                 "Celebrities"="black", "Non-official\nmedia"="black"))+
  facet_grid(. ~ metric, scales = "free_x", switch = "y") +
  coord_flip()+
  ylab("") +
  theme_bw(base_size=20, base_family='Times New Roman') +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  theme(text = element_text(size=20), axis.title.y = element_text(size=20),
        axis.title.x = element_text(size=20),
        axis.text.y = element_text(size=18),
        axis.text.x = element_text(size=18),
        strip.text.x = element_text(size = 20),
        legend.position = "None",panel.spacing.x=unit(1.5, "lines"))

g2 <- ggplot(subset(visuals, metric %in% c("Cold color\ndominance","Warm color\ndominance","Face presence")), aes(x=account_type, y=mean, ymin=down, ymax=upper, color = account_type))+
  geom_pointrange(size = 0.6, fatten = 2.5)+ xlab("") + 
  scale_colour_manual(values = c("Regime\nAffiliated"="red","Ordinary users"="black",
                                 "Celebrities"="black", "Non-official\nmedia"="black"))+
  facet_grid(. ~ metric, scales = "free_x", switch = "y") +
  coord_flip()+
  ylab("Mean") +
  theme_bw(base_size=16, base_family='Times New Roman') +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  theme(text = element_text(size=20), axis.title.y = element_text(size=20),
        axis.title.x = element_text(size=20),
        axis.text.y = element_text(size=18),
        axis.text.x = element_text(size=18),
        strip.text.x = element_text(size = 20),
        legend.position = "None",panel.spacing.x=unit(1.5, "lines"))
ggarrange(g1, g2, nrow = 2, align = "h")

####################################################################################
## Figure 5
####################################################################################
## tabulate the proportion of topics by accounts
tb <- as.data.frame(
  prop.table(table(all_sample_nc$account_type2,all_sample_nc$topic_category),1))

## rename for plotting
tb$Var1 <- recode(tb$Var1, 
                  celebrities = "Celebrities",
                  "non-official media" = "Non-Official\nMedia",
                  "ordinary users" = "Ordinary\nUsers",
                  "regime accounts" = "Regime\nAffiliated")

tb$Var2 <- factor(tb$Var2, levels = c("Propaganda", "Positive energy",
                                      "Human interest", "Breaking news", 
                                      "Business news", "Entertainment"))
## plot the left panel
p <- ggplot(tb, aes(x=Freq, y=Var1, fill=Var2)) +
  geom_bar(stat="identity", position = "stack", colour = "black", width = 0.8)+
  scale_fill_manual(values = c("#DC0000B2","gray20",
                               "gray40","gray60", "gray80","white"))+
  #  scale_fill_manual(values = c("#DC0000B2", "#F39B7FB2", "#4DBBD5B2"))+
  xlab("Share of videos")+
  ylab("")+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = 'white', colour = 'black'))+
  theme(text = element_text(size=20, colour = "black"),
        axis.title.y = element_text(size=20, colour = "black"),
        axis.title.x = element_text(size=20, colour = "black"),
        axis.text.x  = element_text(size=20, colour = "black"),
        axis.text.y = element_text(size=20, colour = "black"),
        legend.title=element_blank(),
        legend.position="top",
        legend.text = element_text(size=16,colour ="black",margin = margin(t = 2))
  )
p

## tabulate the proportion of topics by regime-affiliated accounts
tb <- as.data.frame(prop.table(table(
  all_sample_regime_nc$account_type3,
  all_sample_regime_nc$topic_category),1))

## rename for plotting
tb$Var2 <- factor(tb$Var2, levels = c("Propaganda", "Positive energy",
                                      "Human interest", "Breaking news", 
                                      "Business news", "Entertainment"))
tb$Var1 <- factor(tb$Var1, levels=c("Other\nOfficial\nMedia", "Non-\nMouthpiece\nNewspaper", "Mouthpiece\nNewspaper", "Government\nCCP"))

## plot the right panel
q <- ggplot(tb, aes(x=Freq, y=Var1, fill=Var2)) +
  geom_bar(stat="identity", position = "stack", colour = "black", width = 0.8)+
  scale_fill_manual(values = c("#DC0000B2", "gray20",
                               "gray40","gray60", "gray80", "white"))+
  #  scale_fill_manual(values = c("#DC0000B2", "#F39B7FB2", "#4DBBD5B2"))+
  xlab("Share of videos")+
  ylab("")+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = 'white', colour = 'black'))+
  theme(text = element_text(size=20, colour = "black"),
        axis.title.y = element_text(size=20, colour = "black"),
        axis.title.x = element_text(size=20, colour = "black"),
        axis.text.x  = element_text(size=20, colour = "black"),
        axis.text.y = element_text(size=20, colour = "black"),
        legend.title=element_blank(),
        legend.position="top",
        legend.text = element_text(size=16,colour ="black",margin = margin(t = 2))
  )
q
## arrange and output
ggarrange(p,q, common.legend = T)


####################################################################################
## Figure 6 and Figure S6
####################################################################################
# Figure S6: Bimodal distribution of regime-affiliated content by topic
all_sample_nc$propaganda <- ifelse(all_sample_nc$account_type2 == "regime accounts", 1, 0)
topic_sample <- all_sample_nc %>%
  group_by(topic_name) %>%
  summarise(
    sum = sum(propaganda),
    count = n(),
    prop = sum/count
  )

# Many topics only talked about by regime affiliated accounts
p <- ggplot(data= topic_sample, aes(x= prop)) +
  geom_density(adjust=1.5, alpha=.4)+
  xlab('Proportion of videos from regime-affiliated accounts')+
  ylab('Density')+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = 'white', colour = 'black'))+
  theme(text = element_text(size=20, colour = "black"),
        axis.title.y = element_text(size=20, colour = "black"),
        axis.title.x = element_text(size=20, colour = "black"),
        axis.text.x  = element_text(size=20, colour = "black"),
        axis.text.y = element_text(size=20, colour = "black"),
        legend.title=element_blank(),
        legend.position="top",
        legend.text = element_text(size=16,colour ="black",margin = margin(t = 2))
  )
p 

## set a threshold to differentiate content only discussed by regime-affiliated accounts
## not discussing by regime-affiliated accounts or mixed
topic_sample$type <- ifelse(topic_sample$prop==1, "gov",
                            ifelse(topic_sample$prop==0, "nogov", "mixed"))

## select topics that only talked about by regime-affiliated accounts
all_sample_nc_regime2 <- merge(all_sample_regime_nc, topic_sample[,c(1,4:5)], by="topic_name")
all_sample_nc_regime2 <- all_sample_nc_regime2[all_sample_nc_regime2$type == "gov",]

## tabulate
tb <- as.data.frame(prop.table(table(
  all_sample_nc_regime2$account_type3,
  all_sample_nc_regime2$topic_category),1))

## rename for plotting
tb$Var2 <- factor(tb$Var2, levels = c("Propaganda", "Positive energy",
                                      "Human interest", "Breaking news", 
                                      "Business news", "Entertainment"))
tb$Var1 <- factor(tb$Var1, levels=c("Other\nOfficial\nMedia", 
                                    "Non-\nMouthpiece\nNewspaper", 
                                    "Mouthpiece\nNewspaper", "Government\nCCP"))

## plot
p <- ggplot(tb, aes(x=Freq, y=Var1, fill=Var2)) +
  geom_bar(stat="identity", position = "stack", colour = "black", width = 0.8)+
  scale_fill_manual(values = c("#DC0000B2", "gray20",
                               "gray40","gray60", "gray80","white"))+
  #  scale_fill_manual(values = c("#DC0000B2", "#F39B7FB2", "#4DBBD5B2"))+
  xlab("Share of videos")+
  ylab("")+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = 'white', colour = 'black'))+
  theme(text = element_text(size=20, colour = "black"),
        axis.title.y = element_text(size=20, colour = "black"),
        axis.title.x = element_text(size=20, colour = "black"),
        axis.text.x  = element_text(size=20, colour = "black"),
        axis.text.y = element_text(size=20, colour = "black"),
        legend.title=element_blank(),
        legend.position="top",
        legend.text = element_text(size=16,colour ="black",margin = margin(t = 2))
  )
p



