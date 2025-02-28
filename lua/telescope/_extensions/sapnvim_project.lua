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

local function create_finder()
  local sessions = session_manager.get_all_sessions() or {}
  if sessions == nil then
    vim.notify("Error: Failed to get the file name of the telescope results.", vim.log.levels.ERROR)
  end

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

local function select_session(opts)
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
        session_manager.load_session(selection)
      end)
      return true
    end
  }):find()
end
return telescope.register_extension({
  exports = {
    ['spanvim_sessions'] = select_session,
    select = select_session
  }
})
