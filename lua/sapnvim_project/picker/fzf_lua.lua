local has_fzf_lua, fzf_lua = pcall(require, "fzf-lua")
if not has_fzf_lua then
  return
end

local ansi_codes = require("fzf-lua").utils.ansi_codes

local session_manager = require('sapnvim_project.session_manager')
local utils = require('sapnvim_project.utils')

local M = {}

-- Function to select and load a session from the fzf selection results
function M.select_and_load_session(selected)
  -- Get the current delimiter and session map stored in the module
  local delimiter = M._current_session_delimiter
  local session_map = M._current_session_map

  if not delimiter or not session_map then
    vim.notify("Session selection state is invalid", vim.log.levels.ERROR)
    return
  end

  if selected and #selected > 0 then
    local selected_line = selected[1]

    -- Extract ID from the selected line using the delimiter
    local id = selected_line:match("^([^" .. delimiter .. "]+)")

    if id and session_map[id] then
      local session = session_map[id]
      if not (utils.is_valid_path(session.path) == 1) then
        return
      end
      -- Close all buffers before loading the session
      vim.cmd('silent! %bd')
      -- Load the selected session and handle errors
      session_manager.load_session(session)
    end
  end
end

-- Main function to display and select sessions using fzf
function M.select_session(user_opts)
  -- Get all available sessions or default to empty table
  local sessions = session_manager.get_all_sessions() or {}
  local results = {}
  local session_map = {}

  -- Use a non-visible delimiter for structured data
  local delimiter = "\x01"

  -- Store current delimiter and session map in module scope for the action function
  M._current_session_delimiter = delimiter
  M._current_session_map = session_map

  -- Process session data for display
  for i, session in ipairs(sessions) do
    -- Assign unique ID for each session
    local id = tostring(i)
    session_map[id] = session

    -- Format session name with fixed width
    local name_width = 30
    local name_padded = session.name .. string.rep(" ", math.max(0, name_width - #session.name))

    -- Apply colors to enhance readability
    local colored_name = ansi_codes.bold(ansi_codes.white(name_padded))
    local colored_path = ansi_codes.blue(utils.format_path(session.path))

    -- Combine data with hidden delimiter and visible formatting
    table.insert(results, id .. delimiter .. colored_name .. "  " .. colored_path)
  end

  -- Configure options for fzf display
  local opts = {
    winopts = { height = 0.33, width = 0.7 },
    prompt = "Select a project> ",
    fzf_opts = {
      ["--ansi"] = "",                                      -- Enable ANSI color codes
      ["--delimiter"] = delimiter,                          -- Set delimiter for data parsing
      ["--with-nth"] = "2..",                               -- Hide the ID column
      ["--header"] = "name                            path" -- Display header
    },
    -- Set the default action to our module-level function
    actions = {
      ['default'] = M.select_and_load_session
    }
  }

  -- Merge user options with defaults
  opts = vim.tbl_deep_extend('force', {}, opts, user_opts or {})

  -- Execute fzf with prepared data and options
  fzf_lua.fzf_exec(results, opts)
end

return M
