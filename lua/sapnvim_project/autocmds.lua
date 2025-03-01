local session_manager = require('sapnvim_project.session_manager')
local utils = require('sapnvim_project.utils')

local autocmd = vim.api.nvim_create_autocmd

local function create_aotucmd()
  autocmd({ 'VimLeavePre' }, {
    callback = function()
      if not (vim.v.dying == 0) then
        return
      end

      local name = vim.fn.fnamemodify(utils.resolve(utils.cwd()), ':t')
      local cwd = utils.add_slash_if_folder(utils.resolve(utils.cwd()))
      local session = { name = name, path = cwd }
      if session_manager.save_existing_session(session) then
        session_manager.create_history_session(session)
      else
        session.name = 'tmp'
        session_manager.create_history_session(session, true)
      end
    end
  })
end

return { create_aotucmd = create_aotucmd() }
