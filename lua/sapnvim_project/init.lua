local commands = require('sapnvim_project.commands')
local config = require('sapnvim_project.config')
local M = {}

M.setup = function(opts)
  config.setup(opts)
  commands.create_mommands()
end

return M
