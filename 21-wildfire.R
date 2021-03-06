library(tidyverse)
library(lubridate)

# load USA wide data ------------------------------------------------------

paths <- list.files("data/us_fires",
                    full.names = T)

us_fires <- paths %>%
  map(~read_csv(file = .,
                col_types = cols(
                  .default = col_character(),
                  stat_cause_code = col_double(),
                  cont_date = col_datetime(format = ""),
                  discovery_date = col_datetime(format = ""),
                  cont_doy = col_integer(),
                  cont_time = col_integer(),
                  fire_size = col_double(),
                  latitude = col_double(),
                  longitude = col_double()
                ))) %>%
  reduce(bind_rows)



# Bin data ----------------------------------------------------------------

jpeg(filename = "plots/21-wildfire-map.jpg",
     width = 10, 
     height = 7,
     units = "in",
     res = 200)
us_fires %>%
  mutate(latitude = round(latitude, digits = 0),
         longitude = round(longitude, digits = 0)) %>%
  group_by(fire_year, latitude, longitude) %>%
  summarise(fire_size = sum(fire_size)) %>%
  # filter(fire_year == 2007) %>%
  ggplot(aes(x = longitude,
             y = latitude,
             fill = sqrt(fire_size))) +
  geom_raster() +
  facet_wrap(facets = "fire_year") +
  # coord_map(projection = "azequalarea") +
  ylim(20, 50) +
  xlim(-130, -70) +
  scale_fill_viridis_c(option = "C") +
  theme_bw() 
dev.off()


# is total intensity increasing ---------------------------------------------

jpeg(filename = "plots/21-wildfire-high-class.jpg",
     width = 10, 
     height = 8,
     units = "in",
     res = 300)
us_fires %>%
  filter(fire_size_class %in% c("F", "G")) %>%
  ggplot(aes(x = discovery_date,
              y = fire_size)) +
  # geom_point(alpha = .1) +
  geom_hex(bins = 70) +
  scale_y_log10() +
  scale_fill_viridis_c(option = "C") +
  theme_minimal(base_size = 20) +
  ggtitle("Big Fires in the USA from 1992 to 2015",
          sub = "Data from US fire service, only biggest fires (categories F and G)") +
  xlab("Date of Alert") +
  ylab("Fire Size [Hectares???] (log scale)")
dev.off()

jpeg(filename = "plots/21-wildfire-high-class-facet.jpg",
     width = 12, 
     height = 10,
     units = "in",
     res = 300)
us_fires %>%
  filter(fire_size_class %in% c("F", "G")) %>%
  ggplot(aes(x = discovery_date,
             y = fire_size)) +
  # geom_point(alpha = .1) +
  geom_hex(bins = 12) +
  scale_y_log10() +
  scale_fill_viridis_c(option = "C") +
  scale_x_datetime(date_breaks = "3 months",
                   date_labels = "%b") +
  facet_wrap(facets = "fire_year",
             scales = "free_x",
             ncol = 6) +
  theme_bw(base_size = 14) +
  ggtitle("Big Fires in the USA from 1992 to 2015",
        sub = "Data from US fire service, only biggest fires (categories F and G)") +
  xlab("Date of Alert") +
  ylab("Fire Size [Hectares???] (log scale)")
dev.off()


  