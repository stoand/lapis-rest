local config = require('lapis.config').get()
local cjson = require('cjson')

function ember_data_error(errors)
  if config.logging.requests == true then
    print('\nEmber Data Error: ' .. cjson.encode(errors) .. '\n')
  end
  return { json = { errors = errors }, status = 422 }
end

return {
  -- Authorization
  unauthorized = function()
    return ember_data_error({ unauthorized = { 'Access Denied' } })
  end,
  -- Input
  json = function(json_err)
    return ember_data_error({ json = { json_err } })
  end,
  post_params_empty = function()
    return ember_data_error({ post = { 'POST params empty' } })
  end,
  -- Database
  unknown_model = function(model)
    return ember_data_error({ database = { 'Unknown Model Type: ' .. model } })
  end,
  invalid_id = function(id)
    return ember_data_error({ database = { 'Invalid Id: ' .. id } })
  end,
  -- The actual error message of the database should not be fed into this function
  -- as this could lead to information being leaked from the database
  database_operation = function(operation)
    return ember_data_error({ database = { operation } })
  end
}