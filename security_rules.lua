return {
  users = {
    write = function()
      return true
    end,
    read = function(record)
      return record.id == 1
    end
  }
}
