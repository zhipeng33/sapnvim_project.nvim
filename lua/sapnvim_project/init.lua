local config = require('sapnvim_project.config')
local M = {}

M.setup = function(opts)
  config.setup(opts)
  require('sapnvim_project.commands').create_mommands()
end

return M
