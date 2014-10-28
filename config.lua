local config = require("lapis.config")
local secrets = require("./secrets")

config("development", {
  postgres = {
    backend = "pgmoon",
    host = "127.0.0.1",
    user = "postgres",
    password = secrets.postgres_password,
    database = "lapis"
  },
  port = 8080
})

config("production", {
  postgres = {
    backend = "pgmoon",
    host = "127.0.0.1",
    user = "postgres",
    password = secrets.postgres_password,
    database = "lapis"
  },
  lua_code_cache = 'on',
  secret = secrets.app_secret,
  port = 80,
  logging = {
    queries = false,
    request = false
  }
})
