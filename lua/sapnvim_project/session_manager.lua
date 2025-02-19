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
    vim.notify("已成功写入 " .. sessions_data_file .. " 文件。")
  else
    vim.notify("无法打开 " .. sessions_data_file .. " 文件进行写入。")
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

-- 添加新的 session，并同时触发保存 session 文件的操作，
-- 同时执行保存 session 的 vim.cmd 以及通知
function M.add_session(new_session)
  load_sessions_from_file() -- 先加载现有的 sessions
  local sessions_name = config.options.sessions_storage_dir .. new_session.name
  vim.notify(string.format("mks! %s", sessions_name))
  vim.cmd(string.format("mks! %s", sessions_name))
  if session_exists_in_cache(new_session) then
    vim.notify("该 session 已存在，不重复添加。")
    return
  end
  table.insert(sessions_table, new_session)
  write_sessions_to_file()
  -- 调用 Neovim 命令保存当前 session 文件
end

-- 可选：获取当前所有会话记录
function M.get_all_sessions()
  return load_sessions_from_file()
end

function M.execute_session(selected_session)
  vim.cmd([[%bd]])
  vim.cmd(string.format("source %s%s", config.defaults.sessions_storage_dir, selected_session.name))
end

return M
