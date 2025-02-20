local utils = require('sapnvim_project.utils.path')

local M = {}

local function get_default_storage_dir()
  local default_storage_dir
  local ok = pcall(require, 'lazy')
  if ok then
    default_storage_dir = require('lazy.core.config').defaults.root .. '/sapnvim_project.nvim/sessions'
  else
    default_storage_dir = vim.fn.stdpath('config') .. '/sessions'
  end

  if utils.is_valid_path(default_storage_dir) == 0 then
    vim.fn.mkdir(default_storage_dir)
  end

  return default_storage_dir
end

M.defaults = {
  sessions_storage_dir = utils.add_slash_if_folder(get_default_storage_dir()),
  sessions_data_filename = 'sessions_data.lua',
  picker_opts = {
  }
}

M.options = nil

M.setup = function(options)
  M.options = vim.tbl_deep_extend('force', M.defaults, options or {})
end

setmetatable(M, {
  __index = function(_, k)
    if k == "options" then
      return M.defaults
    end
  end,
})

return M
