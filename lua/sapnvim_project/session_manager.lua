local config = require('sapnvim_project.config')
local utils = require('sapnvim_project.utils.path')

local M = {}
local sessions_data_file = config.defaults.sessions_storage_dir .. config.defaults.sessions_data_filename
local sessions_table = {}

local function load_sessions_from_file()
  local ok, result = pcall(dofile, sessions_data_file)
  if ok and type(result) == "table" and result.sessions then
    sessions_table = result.sessions
  else
    sessions_table = {}
  end
  return sessions_table
end

local function serialize_sessions_to_string(sessions)
  local s = "return {\n  sessions = {\n"
  for _, session in ipairs(sessions) do
    s = s .. string.format("    { name = %q, path = %q },\n", session.name, session.path)
  end
  s = s .. "  }\n}"
  return s
end

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

local function session_exists_in_cache(new_session)
  for _, session in ipairs(sessions_table) do
    if session.path == new_session.path then
      return true
    end
  end
  return false
end

local function is_valid_path(path)
  path = utils.resolve(path)
  return vim.fn.isdirectory(path)
end

-- 可选：获取当前所有会话记录
function M.get_all_sessions()
  return load_sessions_from_file()
end

-- 添加新的 session，并同时触发保存 session 文件的操作，
-- 同时执行保存 session 的 vim.cmd 以及通知
function M.add_session(new_session)
  load_sessions_from_file() -- load sessions

  local sessions_name = config.options.sessions_storage_dir .. new_session.name
  vim.cmd(string.format("mks! %s", sessions_name))

  if session_exists_in_cache(new_session) then
    return
  end
  table.insert(sessions_table, new_session)
  write_sessions_to_file()
end

function M.execute_session(selected_session)
  -- Close all buffers.
  vim.cmd('%bd')

  -- Cache session values for clarity.
  local session_path = selected_session.value
  local session_name = selected_session.name

  -- Check if the provided session path is valid.
  if is_valid_path(session_path) == 1 then
    -- Build the full path to the session file and source it.
    local session_file = config.defaults.sessions_storage_dir .. session_name
    vim.cmd(string.format("source %s", session_file))
  else
    local msg = string.format('"%s" is not a valid path; project information has been deleted!', session_path)
    vim.notify(msg, vim.log.levels.WARN)
  end
end

return M
