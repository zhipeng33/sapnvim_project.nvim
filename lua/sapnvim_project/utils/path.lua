local M = {}

M.resolve = function(filename)
  filename = vim.fn.expand(filename)
  return vim.fn.resolve(filename)
end

M.resolve_dir = function(filename)
  return vim.fn.fnamemodify(filename, ":t")
end

M.format_path = function(path)
  return vim.fn.fnamemodify(path, ':~')
end

M.cwd = function()
  return M.format_path(vim.uv.cwd())
end

M.add_slash_if_folder = function(path)
  local path_info = vim.uv.fs_stat(path)
  if path_info and path_info.type == 'directory' and not path:match('/$') then
    return path .. '/'
  else
    return path
  end
end

M.project_path = function(entry)
  local lsp_path = vim.lsp.buf.list_workspace_folders()
  print(lsp_path)
end

M.get_all_project = function(path)
  if path == nil or path == '' then
    vim.notify("Unable to obtain the successful path or is nil.")
    return
  end

  local files = {}
  print("Processing directory:", path)
  local p = io.popen(string.format('fd ".vim" %s', path))
  if p == nil then
    vim.notify("Unable to obtain the successful path or is nil.")
    return
  end

  for file in p:lines() do
    file = M.format_path(file)
    table.insert(files, file)
  end

  p:close()

  return files
end

return M
