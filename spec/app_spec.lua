local app = require('app')
local mock_request = require('lapis.spec.request').mock_request
local Model = require('lapis.db.model').Model
local schema = require('lapis.db.schema')
local cjson = require('cjson')
local us = require('underscore')
local security_rules = require('../security_rules')

local model_name = 'test_model';

local types = schema.types

describe('Lua REST Server', function()

  -- Create a fresh table
  schema.drop_table(model_name)
  schema.create_table(model_name, {
    { 'id', types.serial },
    { 'value', types.varchar },
    'PRIMARY KEY (id)'
  });

  local model = Model:extend(model_name)

  it('Create', function()
    local originalRecord = { value = 'some value' }
    local status = mock_request(app, '/' .. model_name, { post = { [model_name] = originalRecord } })
    local record = model:find({ value = originalRecord.value })
    assert.are.same(200, status)
    assert.truthy(record)
  end)

  it('Update', function()
    local record = model:create({ value = 'some value (update)' })
    local status, body = mock_request(app, '/' .. model_name .. '/' .. record.id, { post = { [model_name] = { value = 'altered value' } } })
    local updatedRecord = model:find({ id = record.id })
    assert.are.same(200, status)
    assert.are.same(updatedRecord.value, 'altered value')
  end)

  it('Delete', function()
    local record = model:create({ value = 'some value (del)' })
    local status, body = mock_request(app, '/' .. model_name .. '/' .. record.id, { post = { [model_name] = {} } })
    assert.are.same(200, status)
    assert.falsy(deletedRecord)
  end)

  it('Find', function()
    local originalRecord = { value = 'some value (find)' }
    local record = model:create(originalRecord)
    local status, body = mock_request(app, '/' .. model_name .. '/' .. record.id)
    assert.are.same(200, status)
    assert.are.same(us.first(us.values(cjson.decode(body))), {originalRecord})
  end)

  it('Find Many', function()
    local records = {
      {value = 'ok'},
      {value = 'not ok'},
      {value = 'ok'},
      {value = 'ok'},
      {value = 'not ok'},
      {value = 'ok'},
      {value = 'ok'}
    }

    us.each(records, function(record)
      model:create(record)
    end)

    local status, body = mock_request(app, '/' .. model_name .. '?value=ok')
    assert.are.same(200, status)
    assert.are.same(us.first(us.values(cjson.decode(body))), us.select(records, function(record)
      return record.value == 'ok';
    end))
  end)
end)
