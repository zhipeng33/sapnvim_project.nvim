local telescope = require('telescope')
local utils = require('sapnvim_project.utils.path')
local session_manager = require('sapnvim_project.session_manager')

local M = {}

function M.create_project()
  -- 假定 config.options.sessions_dir 和 utils 模块已定义
  local cwd = utils.add_slash_if_folder(utils.resolve(utils.cwd()))
  vim.ui.input({
    prompt = "Naming the session:",
    default = vim.fn.fnamemodify(utils.cwd(), ":t"),
  }, function(input)
    if input and input ~= "" then
      local new_session = { name = input, path = cwd }
      session_manager.add_session(new_session)
    else
      vim.notify("Session name input was cancelled", vim.log.levels.WARN)
    end
  end)
end

function M.project_preselector(opts)
  telescope.extensions['sapnvim_project'].select(opts)
end

return M
