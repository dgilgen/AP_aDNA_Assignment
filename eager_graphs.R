library(plotly)

## Load Tidyverse Packages
library(tidyverse)
## Load csv into a Raw Data Object
raw_data <- read_csv("ppr_data.csv")

## Create Working Dataframe and Assign Shotgun/Capture classing to samples
working_data <- raw_data %>%
  mutate(Preparation = case_when(
    row_number() <= 22 ~ "Shotgun",
    row_number() <= 44 ~ "Capture",
    TRUE ~ NA_character_
  ))

## Remove TW and SG tags from the sample IDs to pair for downstream graphing
working_data <- working_data %>%
  mutate(`Sample Name` = str_remove(`Sample Name`, "_(TW|SG)$"))

## Calculate Damage Average for each Sample (and remove % from the column values)
working_data <- working_data %>%
  mutate(
    across(7:8, ~ as.numeric(gsub("%", "", as.character(.x)))),
    damage_average = rowMeans(pick(7:8), na.rm = TRUE)
  )

## Subset data to 44 samples
working_data <- working_data[1:44,]

## Damage Plot
ggplot(working_data, aes(
  x = `Sample Name`,
  y = damage_average,
  id = `Sample Name`,
  colour = Preparation,
  group = `Sample Name`
)) +
  geom_point(
    size = 3,
    position = position_dodge(width = 0.2)
  ) +
  labs(
    title = "DNA Damage by Preparation Method",
    x = "Library",
    y = "Average Damage (%)",
    colour = "Preparation Method"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1)
  )

## Sex Determination Plot
sexdet <- ggplot(working_data, aes(
  id = `Sample Name`,
  x = `SexDet Rate X Chr`,
  y = `SexDet Rate Y Chr`,
  colour = Preparation
)) +
  geom_point(
    size = 2,
  ) +
  labs(
    title = "Sex Determination",
    x = "X Chromosome Rate",
    y = "Y Chromosome Rate",  
  )

ggplotly(sexdet)

## Endogenous DNA Plot
### Sample on X-axis, endogenous DNA y-axis
ggplot(working_data, aes(x = `Sample Name`, y = `Endogenous DNA Post (%)`, colour = Preparation, group)) +
  geom_point(size = 3) +
  labs(
    x = "Library",
    y = "Endogenous DNA Post-trimming (%)",
    title = "Endogenous DNA concentration by Preparation"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1)
  )

## No. SNPs plot
## Make the SNPs per 1000 column
working_data <- working_data %>%
  mutate(SNPs_per_1000 = (`#SNPs Covered` / `#SNPs Total`) * 1000)
## Plot in log-scale
ggplot(working_data, aes(x = `Sample Name`, y = SNPs_per_1000, colour = Preparation)) +
  geom_point(size = 3) +
  scale_y_log10(
    breaks = c(0.01, 0.1, 1, 10, 100),
    labels = c("0.01", "0.1", "1", "10", "100")
  ) +
  geom_hline(yintercept = 0) +
  labs(
    x = "Libraries",
    y = "SNPs per 1000 sites (log10 scale)",
    title = "Scatter Plot"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1)
  )

## Contamination Estimate


## Fragment Length
# Remove 'bp' from column on read length
working_data[, 9:10] <- lapply(working_data[, 9:10], function(x) as.numeric(sub("bp$", "", x)))

# Plotting the data
ggplot(working_data, aes(x = `Sample Name`, y = `Mean Length Mapped Reads`, colour = Preparation )) +
  geom_point(size = 3) +
  labs(
    x = "Libraries",
    y = "Average Fragment Length (bp)",
    title = "Fragment Length by Preparation Method"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1)
  )
