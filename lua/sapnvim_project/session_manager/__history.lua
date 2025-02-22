--- history.lua

local storage = require('sapnvim_project.session_manager.__storage')

local history = {}

local history_table = {}

--- load_history_from_file
--- Load historical data from the data file and update the local history_table.
--- @return { name: string, path: string }[] history_table Returns the history table.
local function load_history_form_file()
  local data = storage.load_data_form_file()
  if data.history then
    history_table = data.history
  else
    history_table = {}
  end
  return history_table
end

--- get_history_sessions
--- Get all stored history records.
--- Load the latest data from the data file before each call.
--- @return { name: string, path: string }[] history_table Return the history table.
function history.get_history_sessions()
  return load_history_form_file()
end

return history
