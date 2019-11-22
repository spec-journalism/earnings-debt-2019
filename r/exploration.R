library(tidyverse)

peers <- c(
  "Columbia University in the City of New York",
  "Brown University",
  "Cornell University",
  "Dartmouth College",
  "Duke University",
  "Harvard University",
  "Massachusetts Institute of Technology",
  "Princeton University",
  "Stanford University",
  "Yale University",
  "University of Chicago",
  "University of Pennsylvania"
)
raw_data <- readxl::read_excel("../Most-Recent-Field-Data-Elements.xlsx")
data <- raw_data %>% 
  filter(
    MD_EARN_WNE != "PrivacySuppressed" &
      DEBTMEDIAN != "PrivacySuppressed"
  ) %>% 
  mutate(
    COUNT = as.numeric(COUNT),
    MD_EARN_WNE = as.numeric(MD_EARN_WNE),
    DEBTMEDIAN = as.numeric(DEBTMEDIAN)
  )

get_cred_data <- function(cred) {  
  fields <- data %>% 
    filter(INSTNM == "Columbia University in the City of New York") %>% 
    filter(CREDDESC == cred) %>% 
    pull(CIPCODE) %>% 
    unique()
  data %>% 
    filter(CREDDESC == cred) %>%
    filter(CIPCODE %in% fields) %>% 
    mutate(color = ifelse(INSTNM %in% peers, INSTNM, "other"))
}

plot_cred_data <- function(cred) {
  cred_data <- get_cred_data(cred) %>% 
    mutate(DEBTMEDIAN = DEBTMEDIAN / 1000, MD_EARN_WNE = MD_EARN_WNE / 1000)
  limits <- cred_data %>% 
    group_by(CIPDESC) %>% 
    summarize(min = 0, max = max(DEBTMEDIAN, MD_EARN_WNE)) %>% 
    gather(lim_label, y, min, max) %>% 
    mutate(x = 0) %>% 
    arrange(y)
  
  cred_data %>% 
    ggplot(aes(DEBTMEDIAN, MD_EARN_WNE)) +
    geom_abline(slope = 1) +
    geom_point(data = cred_data %>% filter(color == "other"), color = "grey", alpha = 0.3) +
    geom_point(data = cred_data %>% filter(color != "other"), aes(color = color)) +
    geom_blank(data = limits, aes(x, y)) +
    facet_wrap(~ CIPDESC, scales = "free") +
    expand_limits(x = 0, y = 0) +
    scale_x_continuous(expand = c(0, 0), labels = scales::dollar) +
    scale_y_continuous(expand = c(0, 0), labels = scales::dollar)
}

plot_cred_data("First Professional Degree")

plot_cred_data("Bachelor\u0092s Degree")

plot_cred_data("Master's Degree")