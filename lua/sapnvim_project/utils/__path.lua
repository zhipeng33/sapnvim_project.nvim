local M = {}

--- Resolves a given filename to its absolute path.
--- It expands any shell variables or '~' in the filename using vim.fn.expand,
--- and then resolves it to its absolute path using vim.fn.resolve.
---
---@param filename string The filename or path to resolve.
---@return string filename # The resolved absolute path.
function M.resolve(filename)
  filename = vim.fn.expand(filename)
  return vim.fn.resolve(filename)
end

--- Formats a given path by applying vim's filename modifier.
--- It replaces the home directory segment with '~' if applicable.
---
---@param path string|nil The file path to format.
---@return string path # The formatted path.
function M.format_path(path)
  path = path or {}
  return vim.fn.fnamemodify(path, ':~')
end

--- Returns the current working directory in a formatted style.
--- The directory is obtained using vim.uv.cwd() and then formatted using the format_path function.
---
---@return string The formatted current working directory.
function M.cwd()
  return M.format_path(vim.uv.cwd())
end

--- Checks if a given path is a valid directory.
--- It first resolves the path using the resolve function and then checks whether it is a directory using vim.fn.isdirectory.
---
---@param path string The path to validate.
---@return number 0|1 Returns 1 if the path is a valid directory; otherwise, returns 0.
function M.is_valid_path(path)
  path = M.resolve(path)
  return vim.fn.isdirectory(path)
end

--- Check if a string is a valid filename
---@param filename string The filename string to check
---@param extension string Expected file extension (without dot, e.g. "lua")
---@return boolean? ok, string|nil msg # Returns whether valid and error message
function M.is_valid_filename(filename, extension)
  -- Check parameters
  if type(filename) ~= "string" or filename == "" then
    return false, "Filename cannot be empty"
  end

  if type(extension) ~= "string" or extension == "" then
    return false, "File extension must be specified"
  end

  -- Check file extension
  if not filename:lower():match("%." .. extension:lower() .. "$") then
    return false, string.format("Filename must end with .%s", extension)
  end

  -- Check main part of filename
  local name_without_ext = filename:match("(.+)%." .. extension .. "$")
  if not name_without_ext or name_without_ext == "" then
    return false, "Filename cannot be extension only"
  end

  -- Check illegal characters
  if filename:match("[<>:\"/\\|?*]") then
    return false, "Filename contains illegal characters"
  end

  return true, nil
end

--- Appends a trailing slash to the given path if it corresponds to a directory and doesn't already end with one.
--- It uses vim.uv.fs_stat to determine whether the path is a directory.
---
---@param path string The file or directory path.
---@return string path The updated path with a trailing slash if it represents a directory; otherwise, the original path.
function M.add_slash_if_folder(path)
  local path_info = vim.uv.fs_stat(path)
  if path_info and path_info.type == 'directory' and not path:match('/$') then
    return path .. '/'
  else
    return path
  end
end

return M
