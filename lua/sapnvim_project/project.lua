--[[
  This module provides functionality for creating projects asynchronously.
  It collects user input for the project name and path, then creates a new session.
  It uses telescope for potential further enhancements, sapnvim_project.utils for
  path utilities, and sapnvim_project.session_manager for session handling.
--]]

local telescope = require('telescope')
local utils = require('sapnvim_project.utils')
local session_manager = require('sapnvim_project.session_manager')

local M = {}

--- Asynchronously obtains user input and passes the result to a callback function.
--- If the user cancels input, the callback is called with nil.
---
---@param prompt string The prompt to display to the user.
---@param default_var string The default input value.
---@param msg string A message identifier for error notifications.
---@param callback function A function to call with the user's input as its argument.
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

--- Asynchronously creates a new project session.
--- It collects the project name and path from the user and then calls
--- session_manager.add_session with the collected session data.
function M.create_project()
  local name = vim.fn.fnamemodify(utils.resolve(utils.cwd()), ":t")
  local cwd = utils.add_slash_if_folder(utils.resolve(utils.cwd()))
  local new_session = { name = name, path = cwd }
  local prompt_name = "Naming the session: "
  local prompt_path = "Confirming the session path: "

  -- Prompt for the project name first, then for the path in a nested callback.
  input_project_info(prompt_name, new_session.name, "name", function(name_input)
    if not name_input then
      return
    end
    new_session.name = name_input
    input_project_info(prompt_path, new_session.path, "path", function(path_input)
      if not path_input then
        return
      end
      cwd = path_input
      -- Call session_manager.add_session once all information has been collected.
      session_manager.get_all_sessions()
      session_manager.add_session(new_session)
      vim.notify("Project created successfully", vim.log.levels.INFO)
    end)
  end)
end

function M.save_project()
  local name = vim.fn.fnamemodify(utils.resolve(utils.cwd()), ":t")
  local cwd = utils.add_slash_if_folder(utils.resolve(utils.cwd()))
  local old_session = { name = name, path = cwd }
  session_manager.get_all_sessions()
  if not session_manager.save_existing_session(old_session) then
    vim.notify("The workspace is not an existing project", vim.log.levels.WARN)
  end
end

function M.project_preselector(opts)
  telescope.extensions['sapnvim_project'].select(opts)
end

return M
