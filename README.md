# sapnvim_project.nvim
This plugin adds a project management function to nvim, which allows you to jump between saved projects.

## Features

### Project Management
The plugin provides comprehensive project management capabilities for Neovim:

- **Project Creation and Storage**: Save your current workspace as a named project
- **Project Loading**: Quickly switch to any previously saved project
- **Project State Preservation**: Save the current state of your project, including open buffers, cursor positions, and more
- **Quick Project Switch**: Toggle between two most recently used projects for efficient multitasking

### Session Handling
- Automatically preserves your project's state using Neovim's session management
- Customizable session options to control exactly what gets saved in your project state
- Project history tracking for easy navigation between recent projects

## Install
- lazy.nvim  
The following is the installation using `lazy.nvim`, including the default configuration
```lua
return {
  'sapnvim/sapnvim_project.nvim',
  dependencies = {
    { 'nvim-telescope/telescope.nvim' },
    { 'nvim-telescope/telescope-fzf-native.nvim',   build = 'make', },
    { 'nvim-telescope/telescope-file-browser.nvim', }
  },
  opts = {
    --- The address where the project is stored
    --- Useing Lazy.nvim, default: '~/.local/share/nvim/lazy/sapnvim_project.nvim/sessions'
    --- no Using Lazy.nvim, details: 'vim.fn.stdpath("config") .. "/sessions"'
    sessions_storage_dir = '~/.local/share/nvim/lazy/sapnvim_project.nvim/sessions',

    --- This is a data file
    --- Records the projects that have been saved in the project storage directory
    sessions_data_filename = 'sessions_data.lua',

    --- This is a setting related to session saving in Vim/Neovim
    --- View details :h sessionoptions
    sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },

    --- telescope config
    picker_opts = {
    }
  }
}
```

## Commands
- *`ProjectAdd`*  
Save the current workspace as a project. The project name and path are entered by the user.

- *`ProjectSave`*  
When the current workspace is a project, save the latest state.  

- *`ProjectLoad`*  
Load a project from the list of saved projects into the current workspace  

- *`ProjectClose`*  
Used to close the current project and save the latest status before closing.

- *`ProjectToggle`*  
Quickly toggle between the two most recently used projects, enabling efficient switching between related tasks.


Using commands may not be very convenient, 
here are some recommended shortcut key bindings to make execution easier.
```
vim.keymap.set('n', '<leader>sa', '<cmd>ProjectAdd<cr>', { desc = 'Create a project'})
vim.keymap.set('n', '<leader>sc', '<cmd>ProjectClose<cr>', { desc = 'Close current project'})
vim.keymap.set('n', '<leader>sw', '<cmd>ProjectSave<cr>', { desc = 'Save exists project'})
vim.keymap.set('n', '<leader>sf', '<cmd>ProjectLoad<cr>', { desc = 'Load project in list'})
vim.keymap.set('n', '<leader>st', '<cmd>ProjectToggle<cr>', { desc = 'Toggle between recent projects'})
```
