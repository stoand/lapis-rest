local app = require("app")
local mock_request = require("lapis.spec.request").mock_request

describe("Lua REST Server", function()
  it("Create", function()
    local status, body = mock_request(app, "/users", { post = { name = "Andy" } })
    assert.same(200, status)
  end)
end)
