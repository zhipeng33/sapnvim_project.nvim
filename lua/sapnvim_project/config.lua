local utils = require('sapnvim_project.utils.path')

local M = {}

local default_dir = vim.fn.stdpath('config') .. '/sessions'
M.defaults = {
  sessions_storage_dir = utils.add_slash_if_folder(default_dir),
  sessions_data_filename = 'sessions_data.lua',
  picker_opts = {
  }
}

M.options = {}

M.setup = function(options)
  M.options = vim.tbl_deep_extend('force', M.defaults, options or {})
end

return M
