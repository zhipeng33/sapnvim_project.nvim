local telescope = require('telescope')
local utils = require('sapnvim_project.utils.path')
local session_manager = require('sapnvim_project.session_manager')

local M = {}

--- 异步获取用户输入，通过回调传递结果
--- @param prompt string 提示信息
--- @param default_var string 默认输入值
--- @param msg string 用于错误消息标识
--- @param callback function 回调函数，参数为输入的值（可能为 nil）
local function input_project_info(prompt, default_var, msg, callback)
  vim.ui.input({
    prompt = prompt,
    default = default_var,
  }, function(input)
    if input and input ~= "" then
      callback(input)
    else
      vim.notify(string.format("Project %s input was cancelled", msg), vim.log.levels.WARN)
      callback(nil)
    end
  end)
end

--- 异步创建项目，收集用户输入后才调用 session_manager.add_session
function M.create_project()
  local cwd = utils.add_slash_if_folder(utils.resolve(utils.cwd()))
  local new_session = { name = vim.fn.fnamemodify(utils.cwd(), ":t"), path = cwd }
  local prompt_name = "Naming the session: "
  local prompt_path = "Confirming the session path: "
  -- 首先询问 name，然后在回调中询问 path
  input_project_info(prompt_name, new_session.name, "name", function(name_input)
    if not name_input then
      return
    end
    new_session.name = name_input
    input_project_info(prompt_path, new_session.path, "path", function(path_input)
      if not path_input then
        return
      end
      new_session.path = path_input
      -- 当收集完所有信息后调用 session_manager.add_session
      session_manager.add_session(new_session)
      vim.notify("Project created successfully", vim.log.levels.INFO)
    end)
  end)
end

function M.project_preselector(opts)
  telescope.extensions['sapnvim_project'].select(opts)
end

return M
