local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  return
end

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local telescope_config = require("telescope.config").values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local entry_display = require("telescope.pickers.entry_display")

local session_manager = require('sapnvim_project.session_manager')
local utils = require('sapnvim_project.utils')

local M = {}

local function create_finder()
  local sessions = session_manager.get_all_sessions() or {}

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 30, },
      { remaining = true, },
    },
  })

  local function make_display(entry)
    return displayer({ entry.name, { entry.value, "Comment" } })
  end

  return finders.new_table({
    results = sessions,
    entry_maker = function(entry)
      return {
        display = make_display,
        name = entry.name,
        value = utils.format_path(entry.path),
        ordinal = entry.name .. " " .. entry.path,
      }
    end
  })
end

function M.select_session(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Select a project",
    finder = create_finder(),
    sorter = telescope_config.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.cmd('silent! %bd!')
        local session = { name = selection.name, path = selection.value }
        session_manager.load_session(session)
      end)
      return true
    end
  }):find()
end

return M
