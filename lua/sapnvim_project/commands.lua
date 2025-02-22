local project = require('sapnvim_project.project')
local config = require('sapnvim_project.config')

local M = {}

function M.create_mommands()
  vim.api.nvim_create_user_command("ProjectLoad", function(args)
    project.project_preselector(config.options.picker_opts)
  end, {})
  vim.api.nvim_create_user_command('ProjectSave', function ()
    project.save_project()
  end, {})
  vim.api.nvim_create_user_command('ProjectAdd', function()
    project.create_project()
  end, {})
end

return M
