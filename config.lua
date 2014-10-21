local config = require("lapis.config")

config("development", {
  postgres = {
    backend = "pgmoon",
    host = "127.0.0.1",
    user = "postgres",
    password = " ",
    database = "lapis"
  },
  port = 8080
})

config("production", {
  postgres = {
    backend = "pgmoon",
    host = "127.0.0.1",
    user = "postgres",
    password = " ",
    database = "lapis"
  },
  code_cache = 'on',
  port = 80
})
