local M = {}

function M.resolve(filename)
  filename = vim.fn.expand(filename)
  return vim.fn.resolve(filename)
end

function M.format_path(path)
  return vim.fn.fnamemodify(path, ':~')
end

function M.cwd()
  return M.format_path(vim.uv.cwd())
end

function M.add_slash_if_folder(path)
  local path_info = vim.uv.fs_stat(path)
  if path_info and path_info.type == 'directory' and not path:match('/$') then
    return path .. '/'
  else
    return path
  end
end

return M
