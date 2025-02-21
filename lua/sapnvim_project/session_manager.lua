--- session_manager.lua
--- 
--- This file manages session data for the sapnvim_project.
--- It provides functions to load, save, and execute session files.
--- 
--- The file uses a Lua file as a storage backend for session data.
--- Sessions are stored as tables with "name" and "path" fields.
--- The primary functions in this file are:
---   - load_sessions_from_file: Loads sessions data from the file.
---   - serialize_sessions_to_string: Serializes the sessions table into a Lua-formatted string.
---   - write_sessions_to_file: Writes the serialized sessions back to the file.
---   - session_exists_in_cache: Checks if a given session (based on its path) already exists in the cache.
---   - get_all_sessions: Returns the current sessions list.
---   - add_session: Adds a new session (if not already present) and triggers saving of the session file.
---   - execute_session: Loads (sources) a session file after closing all buffers, given a selected session.
---
--- Dependencies:
---   - config: Provides configuration options including paths for session storage and session data filename.
---   - utils: Allows path validity checking.
---
local config = require('sapnvim_project.config')
local utils = require('sapnvim_project.utils')

local M = {}

-- Determine the full path to the sessions data file based on configuration options.
local sessions_data_file = config.options.sessions_storage_dir .. '../' .. config.options.sessions_data_filename

-- Table holding session records loaded from file.
local sessions_table = {}

--- load_sessions_from_file
--- Loads session data from the file specified by sessions_data_file.
--- 
--- Uses pcall with dofile to safely execute and load the content of the file.
--- If successful and the loaded result is a table containing a "sessions" field,
--- then sessions_table is updated accordingly. Otherwise, sessions_table is reset to an empty table.
---
---@return table A table containing session records.
local function load_sessions_from_file()
  local ok, result = pcall(dofile, sessions_data_file)
  if ok and type(result) == "table" and result.sessions then
    sessions_table = result.sessions
  else
    sessions_table = {}
  end
  return sessions_table
end

--- serialize_sessions_to_string
--- Serializes a given sessions table to a Lua-formatted string.
---
--- This converts the sessions array into a string that can be written to a file and later loaded with dofile.
---
---@param sessions table A table containing session records.
---@return string A serialized string representing the sessions data.
local function serialize_sessions_to_string(sessions)
  local s = "return {\n  sessions = {\n"
  for _, session in ipairs(sessions) do
    s = s .. string.format("    { name = %q, path = %q },\n", session.name, session.path)
  end
  s = s .. "  }\n}"
  return s
end

--- write_sessions_to_file
--- Writes the current sessions_table to the sessions data file.
--- 
--- Serializes the sessions_table and writes it to the file defined by sessions_data_file.
--- If the file cannot be opened for writing, a notification is shown.
local function write_sessions_to_file()
  local file_content = serialize_sessions_to_string(sessions_table)
  local file = io.open(sessions_data_file, "w")
  if file then
    file:write(file_content)
    file:close()
  else
    vim.notify("Cannot open " .. sessions_data_file .. " file for writing.", vim.log.levels.ERROR)
  end
end

--- session_exists_in_cache
--- Checks if a session already exists in the sessions_table based on the provided path.
---
--- Iterates through sessions_table to find a session whose "path" field matches the provided path.
---
---@param path string The path used to check against existing sessions.
---@return table|nil Returns the matching session table if found, otherwise nil.
local function session_exists_in_cache(path)
  for _, session in ipairs(sessions_table) do
    if session.path == path then
      return session
    end
  end
  return nil
end

--- get_all_sessions
--- Retrieves all stored session records.
---
--- Loads the sessions from the sessions data file and returns the sessions table.
---
---@return table A table containing all session records.
function M.get_all_sessions()
  return load_sessions_from_file()
end

--- add_session
--- Adds a new session to the sessions_table and saves it.
---
--- First, loads existing sessions from file.
--- Then, checks if a session with the same path already exists.
--- If it exists, the existing session's name is used.
--- If it does not exist, the new session is added to sessions_table and saved to the file.
--- Finally, a Vim command is executed to create a session file using mksession.
---
---@param new_session table A table containing new session information (expects at least "name" and "path" fields).
function M.add_session(new_session)
  load_sessions_from_file() -- Load current sessions

  local old_sessions = session_exists_in_cache(new_session.path)
  if old_sessions then
    new_session.name = old_sessions.name
  else
    table.insert(sessions_table, new_session)
    write_sessions_to_file()
  end
  local sessions_name = config.options.sessions_storage_dir .. new_session.name
  vim.cmd(string.format("silent! mks! %s", sessions_name))
end

--- execute_session
--- Executes (loads) a selected session from the session file.
---
--- The function first closes all open buffers. Then it caches session parameters from the
--- provided selected_session table. It checks if the session path is valid using utils.is_valid_path.
--- If the path is valid, it constructs the full path to the session file using the configured sessions_storage_dir
--- and sources the session file using a Vim command, returning true upon success.
--- If the path is invalid, the function returns false.
---
---@param selected_session table A table containing information about the selected session,
---       typically including fields "value" (the session path) and "name" (the session file name).
---@return boolean Returns true if session is successfully executed; otherwise, false.
function M.execute_session(selected_session)
  -- Close all buffers.
  vim.cmd('silent!' .. '%bd')

  -- Cache session values for clarity.
  local session_path = selected_session.value
  local session_name = selected_session.name

  -- Check if the provided session path is valid.
  if utils.is_valid_path(session_path) == 1 then
    -- Build the full path to the session file and source it.
    local session_file = config.defaults.sessions_storage_dir .. session_name
    vim.cmd(string.format("silent! source %s", session_file))
    return true
  else
    return false
    -- local msg = string.format('"%s" is not a valid path; project information has been deleted!', session_path)
    -- vim.notify(msg, vim.log.levels.WARN)
  end
end

return M
