# sapnvim_project.nvim
This plugin adds a project management function to nvim, which allows you to jump between saved projects.

## Install
- lazy.nvim  
The following is the installation using `lazy.nvim`, including the default configuration
~~~lua
return {
  'sapnvim/sapnvim_project.nvim',
  dependencies = {
    { 'nvim-telescope/telescope.nvim' },
    { 'nvim-telescope/telescope-fzf-native.nvim',   build = 'make', },
    { 'nvim-telescope/telescope-file-browser.nvim', }
  },
  opts = {
    sessions_storage_dir = '~/.local/share/nvim/lazy/sapnvim_project.nvim/sessions',
    sessions_data_filename = 'sessions_data.lua',
    -- telescope config
    picker_opts = {
    }
  }
}
~~~

## Commands
- *`ProjectAdd`*  
Save the current workspace as a project. The project name and path are entered by the user.

- *`ProjectSave`*  
When the current workspace is a project, save the latest state.  

- *`ProjectLoad`*  
Load a project from the list of saved projects into the current workspace  

- *`ProjectClose`*  
Used to close the current project and save the latest status before closing.


Using commands may not be very convenient, 
here are some recommended shortcut key bindings to make execution easier.
~~~
vim.keymap.set('n', '<leader>sa', '<cmd>ProjectAdd<cr>', { desc = 'Create a project'})
vim.keymap.set('n', '<leader>sc', '<cmd>ProjectClose<cr>', { desc = 'Close current project'})
vim.keymap.set('n', '<leader>sw', '<cmd>ProjectSave<cr>', { desc = 'Save exists project'})
vim.keymap.set('n', '<leader>sf', '<cmd>ProjectLoad<cr>', { desc = 'Load project in list'})
~~~
