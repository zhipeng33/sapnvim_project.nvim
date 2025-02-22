local config = require('sapnvim_project.config')

local storage = {}

--- Determine the full path to the sessions data file based on configuration options.
local sessions_data_file = config.options.sessions_storage_dir .. '../' .. config.options.sessions_data_filename

--- Serializes the sessions and history tables into a string.
---@param data { sessions: {}[], history: {}[] } Contains both the sessions and history tables.
---@return string str # The serialized string representation.
function storage.serialize_data_to_string(data)
  local str = "return {\n"
  if data.sessions then
    str = str .. "  sessions = {\n"
    for _, session in ipairs(data.sessions) do
      str = str .. string.format("    { name = %q, path = %q },\n", session.name, session.path)
    end
    str = str .. "  },\n"
  end
  if data.history then
    str = str .. "  history = {\n"
    for _, history_item in ipairs(data.history) do
      str = str .. string.format("    { name = %q, path = %q },\n", history_item.name, history_item.path)
    end
    str = str .. "  },\n"
  end
  str = str .. "}"
  return str
end

--- Load data from files
--- Load session and history data from data files.
--- Use pcall and dofile to safely load files.
---@return { sessions: table[], history: table[] } result # Returns the result of the load, or an empty table if the load fails.
function storage.load_data_form_file()
  local ok, result = pcall(dofile, sessions_data_file)
  if ok and type(result) then
    return result
  else
    return {}
  end
end

--- write_sessions_to_file
--- Writes the current sessions_table to the sessions data file.
---
--- Serializes the sessions_table and writes it to the file defined by sessions_data_file.
--- If the file cannot be opened for writing, a notification is shown.
---@param data { sessions: table[], history: table[] } Need to write file data
function storage.write_data_to_file(data)
  local file_content = storage.serialize_data_to_string(data)
  local file = io.open(sessions_data_file, "w")
  if file then
    file:write(file_content)
    file:close()
  else
    vim.notify("Cannot open " .. sessions_data_file .. " file for writing.", vim.log.levels.ERROR)
  end
end

--- get_sessions_data_file
--- Get the full path of the data file.
---@return string filename data file path.
function storage.get_sessions_data_file()
  return sessions_data_file
end

return storage
