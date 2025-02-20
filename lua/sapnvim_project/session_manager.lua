local config = require('sapnvim_project.config')
local utils = require('sapnvim_project.utils.path')

local M = {}
local sessions_data_file = config.options.sessions_storage_dir .. '../' .. config.options.sessions_data_filename
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


--- 检查是否已经存在会话
---@param path string 传入的路径，用于判断。
---@return table|nil?
local function session_exists_in_cache(path)
  for _, session in ipairs(sessions_table) do
    if session.path == path then
      return session
    end
  end
  return nil
end

--- 可选：获取当前所有会话记录
function M.get_all_sessions()
  return load_sessions_from_file()
end

--- 添加新的 session，并同时触发保存 session 文件的操作，
--- 同时执行保存 session 的 vim.cmd 以及通知
---@param new_session table 新的会话信息
function M.add_session(new_session)
  load_sessions_from_file() -- load sessions

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

--- 用于加载一个已经存在的会话
---@param selected_session table 这是一个即将加载会话的信息。
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
  else
    local msg = string.format('"%s" is not a valid path; project information has been deleted!', session_path)
    vim.notify(msg, vim.log.levels.WARN)
  end
end

return M
