local lapis = require("lapis")
local db = require("lapis.db")
local cjson = require("cjson.safe")
local Model = require("lapis.db.model").Model
local security_rules = require("./security_rules")
local errors = require("./errors")
local us = require("underscore")

local app = lapis.Application()


-- CREATE
app:post("/:model", function(self)
  local model = Model:extend(self.params.model)
  if us.is_empty(self.req.params_post) then
    return errors.post_params_empty()
  else
    local data, err = cjson.decode(us.keys(self.req.params_post)[1])
    if err then
      return errors.json(err)
    else
      local create_successful = pcall(function() model:create(data) end)
      if not create_successful then
        return errors.database_operation("Record could not be created.")
      else
        return { json = { [self.params.model] = { data } } }
      end
    end
  end
end)

-- UPDATE, DELETE
-- (Ember data has to be modified because lapis cannot handle PUT and DELETE requests)
app:match("/:model/:id", function(self)
  local model = Model:extend(self.params.model)
  local find_successful, find_result = pcall(function() return model:find(self.params.id) end)
  if not find_successful then
    return errors.unknown_model(self.params.model)
  else
    local record = find_result
    if us.is_empty(record) then
      return errors.invalid_id(self.params.id)
    elseif us.is_empty(self.req.params_post) then
      return errors.post_params_empty()
    else
      local data, err = cjson.decode(us.keys(self.req.params_post)[1])
      if err then
        return errors.json(err)
      else
        local database_operation_successful = pcall(function()
          if next(data) == nil then
            record:delete()
          else
            record:update(data)
          end
        end)
        if not database_operation_successful then
          return errors.database_operation("Unable to create or delete record")
        else
          return { json = { [self.params.model] = data } }
        end
      end
    end
  end
end)

-- Find One
app:get("/:model/:id", function(self)
  local model = Model:extend(self.params.model)
  local find_successful, find_result = pcall(function() return model:find(self.params.id) end)
  if not find_successful then
    return errors.unknown_model(self.params.model)
  else
    local record = find_result
    if not record then
      return errors.invalid_id(self.params.id)
    else
      local rules = security_rules[self.params.model]
      if not (rules and rules.read == true or (type(rules.read) == "function" and rules.read(record) == true)) then
        return errors.unauthorized()
      else
        return { json = { [self.params.model] = { record } } }
      end
    end
  end
end)

-- Find Many
app:get("/:model", function(self)
  local model = Model:extend(self.params.model)

  --  local required_values = us.map(pairs(self.params), function(pair) end)

  local query
  for key, value in pairs(self.req.params_get) do
    if string.sub(key, 1, 1) ~= "_" then
      if query == nil then
        query = "where "
      else
        query = query .. ' AND '
      end
      query = query .. db.escape_identifier(key) .. ' = ' .. db.escape_literal(value)
    end
  end

  if self.params._order_by then
    local order = 'asc'
    if self.params._order == 'desc' then order = 'desc'
    end
    query = query .. ' order by ' .. db.escape_identifier(self.params._order_by) .. ' ' .. order
  end

  local paginated = model:paginated(query, {
    per_page = self.params._per_page
  });

  local res
  if self.params._page then
    res = paginated:get_page(self.params._page)
  else
    res = paginated:get_all()
  end

  if res then
    return { json = { [self.params.model] = res } }
  else
    return ember_data_error({ query = { "Incorrect Model or Id" } })
  end
end)

return app