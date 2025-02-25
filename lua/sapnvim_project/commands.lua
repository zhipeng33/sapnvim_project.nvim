local project = require('sapnvim_project.project')

local M = {}

function M.create_mommands(opts)
  opts = opts or {}
  vim.api.nvim_create_user_command("ProjectLoad", function()
    project.project_preselector(opts)
  end, {})
  vim.api.nvim_create_user_command('ProjectSave', function()
    project.save_project()
  end, {})
  vim.api.nvim_create_user_command('ProjectAdd', function()
    project.create_project()
  end, {})
  vim.api.nvim_create_user_command('ProjectClose', function()
    project.close_project()
  end, {})
end

return M
