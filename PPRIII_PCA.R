library(RColorBrewer)
library(ggplot2)
library(ggrepel)
library(plotly)
library(readxl)

setwd("C:/Users/dylan/Documents/pca_ppr3")

# population data
# this is a file that contains your population name with population group for plotting the PCA. 
# You need to include the ancient individual as well, including your own sample
# avoid using space, as this will be treated as another column 
# see example below

# Abkhasian.DG		Caucasus  Modern
# Adygei.DG		Caucasus  Modern
# Albanian.DG		SoutheasternEurope  Modern
# Aleut.DG		Siberia_NorthAmerica  Modern
# .
# A30717_LP_1819_7_TW Spain_AbricPizarro  StudySample  (Category can be anything, @Cleo: yours gonna be Indonesia_Sulawesi)
# .
# GUP001.AG Indonesia_Sulawesi_HG.AG Ancient
# tai002.SG Taiwan_Liangdao_8000BP.SG Ancient

popdata <- read_excel(
  "C:/Users/dylan/Documents/pca_ppr3/POPDATA.xlsx",
  col_names = FALSE
)

names(popdata)[1:3] <- c("V1", "V2", "V3")

# smartpca data 
# this is your pca data
smartpca_val <- read.table("C:/Users/dylan/Documents/pca_ppr3/SGDP_HGDP_AADR_Lapita_Lachitu2_AbricPizarro.smartpca.eval.txt")
smartpca_vec <- read.table("C:/Users/dylan/Documents/pca_ppr3/SGDP_HGDP_AADR_Lapita_Lachitu2_AbricPizarro.smartpca.evec.txt")

smartpca_data <- data.frame(
  PC1 = smartpca_vec$V2, 
  PC2 = smartpca_vec$V3, 
  Sample_ID = smartpca_vec$V12,
  Ancestry = popdata$V2[match(smartpca_vec$V12, popdata$V1)],
  Source = popdata$V3[match(smartpca_vec$V12, popdata$V1)]
)

# this is to calculate the % variance captured by PC1 and PC2
smartpca_val[1,]/sum(smartpca_val)*100 #PC1 
smartpca_val[2,]/sum(smartpca_val)*100 #PC2


#filtered PCA for specific population
# Define the populations you want to exclude
population_exclude <- c("AltaiNeanderthal", "Chagyrskaya_Neanderthal","Vindija_Neanderthal","AltaiNeanderthalsnpAD",
                        "Chimp.REF", "Denisova_snpAD"
)

# Filter the data
filtered_smartpca_data <- smartpca_data %>% 
  filter(
    !(Ancestry %in% population_exclude),
    !is.na(Source)
  )
#plot PCA
#feel free to make the plot prettier, I haven't specified the color here
pca_plot <- ggplot(filtered_smartpca_data, 
                   aes(x = PC1, 
                       y = PC2, 
                       color = Ancestry, 
                       label = Sample_ID,
                       shape = Source,
                       alpha = Source)) +
  geom_point(size = 5) +
  labs(title = "Abric Pizzaro and HGDP/SGDP PCA Plot", 
       x = "PC1 (6.96%)", y = "PC2 (4.16%)",  # adjust PC1 and PC2 label manually 
       color = "Population", 
       shape = "Source", 
       alpha = NA) +
  # scale_color_manual(values = pop_colors) + # you can create a vector for color if you want
  scale_alpha_manual(values =c("Ancient" = 0.25, 
                               "Modern" = 0.25, 
                               "Published Ancient" = 0.25,
                               "Sample" = 1)) +
  scale_shape_manual(values = c("Paleolithic" = 3, 
                                "Modern" = 1, 
                                "Sample" = 19,
                                "Neolithic" = 4,
                                "Neanderthal" = 2,
                                "Denisovan" = 2,
                                "Holocene" = 5)) +
  guides(alpha = "none") +
  theme_minimal() +
  theme(legend.position = "right") +  # Adjust legend position
  theme(axis.text = element_text(size = 10),  # Adjust axis text size
        axis.title = element_text(size = 10),  # Adjust axis title size
        plot.title = element_text(size = 12))  # Adjust plot title size

print(pca_plot)

ggplotly(pca_plot)

ggsave("PCA.png", plot = pca_plot, width = 16, height = 12, units = "in", dpi = 1200)
ggsave("PCA.pdf", plot = pca_plot, width = 16, height = 12, units = "in", dpi = 600)
