return {
  test_model = {
    write = true,
    read = true
  },
  users = {
    write = true,
    read = true
  },
  --  users = {
  --    write = function(record, newRecord)
  --      return true
  --      --      return record.id == 200;
  --    end,
  --    read = function(record)
  --      return true
  --    end
  --  }
}
