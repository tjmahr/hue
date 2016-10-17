library(httr)
library(magrittr)

# hide username and address elsewhere
source("./secrets.R")

api_url <- file.path(bridge_address, "api", username, "lights")

# returns JSON, that gets parsed into an R list
res <- httr::GET(api_url)
res %>% content %>% str

light1 <- file.path(api_url, 1)
original_state <- GET(light1) %>% content %>% getElement("state")

res2 <- httr::GET(light1)
res2 %>% content %>% str

to_json <- function(...) {
  jsonlite::toJSON(list(...), auto_unbox = TRUE)
}

# on and off
light1_state <- file.path(light1, "state")
PUT(light1_state, body = to_json(on = FALSE))
PUT(light1_state, body = to_json(on = TRUE))

# changing brightness
httr::PUT(light1_state, body = to_json(bri = 127, transitiontime = 10))
httr::PUT(light1_state, body = to_json(bri = 60, transitiontime = 50))
httr::PUT(light1_state, body = to_json(bri = 120, transitiontime = 20))
httr::PUT(light1_state, body = to_json(bri = 127))

PUT(light1_state, body = to_json(alert = "select"))

# turn a random light off
res <- httr::GET(api_url)
num_lights <- res %>% content %>% length
random_light_num <- sample(seq_len(num_lights), size = 1)

# retain last state
light_url <- file.path(api_url, random_light_num)
prev_state <- GET(light_url) %>% content
prev_state$name

light_state <- file.path(light_url, "state")
PUT(light_state, body = to_json(on = FALSE))
Sys.sleep(1)
PUT(light_state, body = to_json(on = prev_state$state$on))


