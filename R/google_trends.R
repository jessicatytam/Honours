library(tidyverse)
devtools::install_github("PMassicotte/gtrendsR")
library(gtrendsR)
library(curl)
library(data.table)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(wesanderson)


#reading and writing

write.csv(includeh, file = "outputs/data/includeh.csv")
includeh <- read_csv("outputs/data/includeh.csv")[-c(1)]

saveRDS(gtrends_list, "data/intermediate_data/gtrends_list.RDS")
gtrends_list <- readRDS("data/intermediate_data/gtrends_list.RDS")

#get the data

output5 <- list()
for (i in 6451:7522) {
  print(paste(i, "getting data for", includeh$genus_species[i]))
  search_term <- includeh$genus_species[i]
  output5[[i]] <- gtrends(keyword = search_term,
                         time = "all")
  Sys.sleep(1)
}

saveRDS(output, "data/intermediate_data/gtrends_results1.RDS") #spp 1-1602
saveRDS(output2, "data/intermediate_data/gtrends_results2.RDS") #spp 1603-3203
saveRDS(output3, "data/intermediate_data/gtrends_results3.RDS") #spp 3204-4847
saveRDS(output4, "data/intermediate_data/gtrends_results4.RDS") #spp 4848-6450
saveRDS(output5, "data/intermediate_data/gtrends_results5.RDS") #spp 6451-7522

#combine them into 1 list + checking

gtrends_results1 <- readRDS(file = "data/intermediate_data/gtrends_results1.RDS")
gtrends_results2 <- readRDS(file = "data/intermediate_data/gtrends_results2.RDS")
gtrends_results3 <- readRDS(file = "data/intermediate_data/gtrends_results3.RDS")
gtrends_results4 <- readRDS(file = "data/intermediate_data/gtrends_results4.RDS")
gtrends_results5 <- readRDS(file = "data/intermediate_data/gtrends_results5.RDS")

gtrends_results2 <- gtrends_results2[1603:3203]
gtrends_results3 <- gtrends_results3[3204:4847]
gtrends_results4 <- gtrends_results4[4848:6450]
gtrends_results5 <- gtrends_results5[6451:7522]

gtrends_list <- do.call(c, list(gtrends_results1, gtrends_results2, gtrends_results3, gtrends_results4, gtrends_results5))

spp <- data.frame()
for (i in 1:length(gtrends_list)) {
  print(gtrends_list[[i]]$interest_by_country[1, "keyword"])
  spp[i, 1] <- gtrends_list[[i]]$interest_by_country[1, "keyword"]
}

unique(spp$V1) #checking

#check for null

for (i in 1:length(gtrends_list)) {
  if (is.null(gtrends_list[[i]])) {
    print(i)
  }
}

#replace <1 with 0.5

replace(gtrends_list[[1]]$interest_over_time[, "hits"], #test
        gtrends_list[[1]]$interest_over_time[, "hits"] == "<1", "0.5")

for (i in 1:length(gtrends_list)) {
  gtrends_list[[i]]$interest_over_time[, "hits"] <- replace(gtrends_list[[i]]$interest_over_time[, "hits"],
                                                            gtrends_list[[i]]$interest_over_time[, "hits"] == "<1", "0.5")
}

#only the sum

hits <- data.frame(genus_species = as.character(),
                   sum_gtrends = as.numeric())

data.frame(genus_species = gtrends_list[[1]]$interest_by_country[1, "keyword"],
           sum_gtrends = 0) #test

for (i in 1:length(gtrends_list)) {
  if (is.null(gtrends_list[[i]]$interest_by_country)) {
    gtrends_hits <- data.frame(genus_species = gtrends_list[[i]]$interest_by_country[1, "keyword"],
                               sum_gtrends = 0)
  } else {
    gtrends_hits <- data.frame(genus_species = gtrends_list[[i]]$interest_by_country[1, "keyword"],
                               sum_gtrends = sum(as.numeric(gtrends_list[[i]]$interest_over_time[, "hits"])))
  }
  hits <- rbind(hits, gtrends_hits)
}

#checking

sum(hits$sum_gtrends==0) #6199 species with 0

#combine with includeh

includeh <- left_join(includeh, hits, by = "genus_species")
table(is.na(includeh$sum_gtrends)) #no NA since it is 0

#slope, intercept

glm <- glm(hits ~ date, output[6787]$interest_over_time, family = poisson)
summary(glm)
plot(glm)


glm_list <- list() #828, 2551
for (i in 1:length(gtrends_list)) {
  if (!is.null(gtrends_list[[i]]$interest_over_time)) {
    print(paste(i, gtrends_list[[i]]$interest_over_time[1, "keyword"]))
    glm_list[[i]] <- summary(glm(hits ~ date, gtrends_list[[i]]$interest_over_time, family = poisson))
    glm_list[[i]][["genus_species"]] <- gtrends_list[[i]]$interest_over_time[1, "keyword"]
  }
}

#sorting clade

includeh$clade <- factor(includeh$clade, levels = c("Afrotheria", "Xenarthra", "Euarchontoglires", "Laurasiatheria", "Marsupials & monotremes"))

#map

by_country <- output$interest_by_country

by_country <- by_country %>%
  rename(name = location)
by_country$hits[is.na(by_country$hits)] <- 0

world <- ne_countries(scale = "large", returnclass = "sf")

world <- left_join(world, by_country)

ggplot(world) +
  geom_sf(aes(fill = hits)) +
  coord_sf(expand = FALSE) +
  labs(x = "Longitude",
       y = "Latitude",
       fill = "Number of hits") +
  theme(panel.background = element_rect(fill = "aliceblue")) +
  scale_fill_viridis_c(option = "plasma") 

#map of sum

ggplot(world) +
  geom_sf() +
  geom_point(data = includeh, aes(x = x,
                                  y = y,
                                  colour = log_sumgtrends),
             size = 2,
             alpha = 0.4) +
  coord_sf(expand = FALSE) +
  labs(x = "Longitude",
       y = "Latitude",
       colour = "Google searches") +
  theme(axis.title = element_text(size = 14),
        axis.text = element_text(size = 10),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10),
        panel.background = element_rect(fill = "white"),
        panel.grid = element_line(colour = "grey80",
                                  linetype = "dashed")) +
  scale_colour_gradientn(colours = wes_palette("Zissou1", 100, type = "continuous")) 

ggplot(includeh, aes(x = median_lat,
                     y = log_sumgtrends,
                     colour = clade)) +
  geom_point(size = 2,
             alpha = 0.4) +
  geom_smooth(colour = "black") +
  labs(x = "Latitude (median)",
       y = "Google searches",
       colour = "Clade") +
  theme(axis.title = element_text(size = 14),
        axis.text = element_text(size = 10),
        axis.line = element_line(colour = "black"),
        legend.title = element_blank(),
        legend.text = element_text(size = 14),
        legend.key = element_rect(fill = "white"),
        legend.position = "top",
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(colour = "grey80"),
        panel.grid.minor = element_line(colour = "grey80",
                                        linetype = "longdash")) +
  scale_colour_manual(values = c("#f1c40f", "#e67e22", "#e74c3c", "#8e44ad", "#3498db"),
                      guide = guide_legend(override.aes = list(size = 4,
                                                               alpha = 1)))

#h vs sum

ggplot(includeh, aes(x = log_sumgtrends,
                     y = logh1,
                     colour = clade)) +
  geom_point(size = 2,
             alpha = 0.5) +
  labs(x = "Sum of Google Trends index",
       y = "h-index") +
  scale_x_continuous(breaks = c(0, 2, 3, 4),
                     labels = c(0, 100, "1,000", "10,000")) +
  scale_y_continuous(breaks = c(0, 1, 2),
                     labels = c(0, 9, 99)) +
  scale_colour_manual(values = c("#f1c40f", "#e67e22", "#e74c3c", "#8e44ad", "#3498db"),
                      guide = guide_legend(override.aes = list(size = 4,
                                                               alpha = 1))) +
  theme(axis.title = element_text(size = 14),
        axis.text = element_text(size = 10),
        axis.line = element_line(colour = "black"),
        legend.title = element_blank(),
        legend.text = element_text(size = 14),
        legend.key = element_rect(fill = "white"),
        legend.position = "top",
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(colour = "grey80"),
        panel.grid.minor = element_line(colour = "grey80",
                                        linetype = "longdash"))

#testing

for (i in 1:length(gtrends_list)) {
  if (!is.null(gtrends_list[[i]]$interest_over_time)) {
    print(i)
  }
}

test <- gtrends_list[6071:6080]

test_glm <- summary(glm(hits ~ date, test[[8]]$interest_over_time, family = poisson))

test_stat <- data.frame(matrix(ncol = 9, nrow = 0))
names <- c("genus_species", "intercept", "slope", "se", "p", "null_dev", "null_df", "resid_dev", "resid_df")
colnames(test_stat) <- names

for (i in 1:length(test)) {
  if (!is.null(test[[i]]$interest_over_time)) {
    print(test[[i]]$interest_over_time[1, "keyword"])
    glm <- summary(glm(hits ~ date, test[[i]]$interest_over_time, family = poisson))
    print("glm done.")
    test_stat[test_stat$genus_species[i]] <- test[[i]]$interest_over_time[1, "keyword"]
    test_stat[test_stat$intercept[i]] <- glm$coefficients[1, 1]
    test_stat[test_stat$slope[i]] <- glm$coefficients[2, 1]
    test_stat[test_stat$se[i]] <- glm$coefficients[2, 2]
    test_stat[test_stat$p[i]] <- glm$coefficients[2, 4]
    test_stat[test_stat$null_dev[i]] <- glm$null.deviance
    test_stat[test_stat$null_df[i]] <- glm$df.null
    test_stat[test_stat$resid_dev[i]] <- glm$deviance
    test_stat[test_stat$null_df[i]] <- glm$df.resid
  } else {
    test_stat[test_stat$genus_species[i]] <- test[[i]]$interest_by_country[1, "keyword"]
    test_stat[test_stat[i, 2:9]] <- NA
  }
}

test_stat <- data.frame(genus_species[i] = test[[i]]$interest_over_time[1, "keyword"],
                        intercept[i] = glm$coefficients[1, 1],
                        slope[i] = glm$coefficients[2, 1],
                        se[i] = glm$coefficients[2, 2],
                        p[i] = glm$coefficients[2, 4],
                        null_dev[i] = glm$null.deviance,
                        null_df[i] = glm$df.null,
                        resid_dev[i] = glm$deviance,
                        null_df[i] = glm$df.resid)

test_map <- map(test, glm(hits ~ date, test$interest_over_time, family = poisson))

glm_list <- list()
for (i in 1:length(test)) {
  if (!is.null(test[[i]]$interest_over_time)) {
    print(test[[i]]$interest_over_time[1, "keyword"])
    glm_list[[i]] <- summary(glm(hits ~ date, test[[i]]$interest_over_time, family = poisson))
    glm_list[[i]][["genus_species"]] <- test[[i]]$interest_over_time[1, "keyword"]
  }
}
