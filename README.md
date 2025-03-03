# sapnvim_project.nvim
This plugin adds a project management function to nvim, which allows you to jump between saved projects.


## Features

### Core Project Management Features

- **Project Creation** - Save the current workspace as a named project through the `ProjectAdd` command

- **State Saving** - Use the `ProjectSave` command to update the latest state of an existing project

- **Project Loading** - Select and load a saved project from the list through the `ProjectLoad` command

- **Project Closing** - Use the `ProjectClose` command to close the current project and save the latest state

- **Quick Switching** - Seamlessly switch between the two most recently used projects through the `ProjectToggle` command

### Plugin Advantages

- 🚀 **Workflow Continuity** - Maintain the context of multiple projects and reduce switching costs

- 🔍 **Focus on Development** - Maintain an independent working environment and state for each project

- ⏱️ **Improve Efficiency** - Immediately restore to the exact state you left last time without resetting the environment

- 📁 **Space Organization** - Systematically manage multiple projects to avoid workspace clutter

### Session Features

- Automatically save open buffers, window layouts, cursor positions and other working states
- Support custom session save options to control the specific content that needs to be saved
- Record project access history to facilitate quick navigation between frequently used projects


## Install
### `lazy.nvim`
<details>
    <summary>Telescope.nvim 🌞</summary>

```lua
return {
  'sapnvim/sapnvim_project.nvim',
  dependencies = {
    { 'nvim-telescope/telescope.nvim' },
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope-fzf-native.nvim',   build = 'make', },
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

    picker = 'telescope'

    --- telescope config
    picker_opts = {
    }
  }
}
```
</details>


<details>
    <summary>fzf-lua 🌞</summary>

```lua
return {
  'sapnvim/sapnvim_project.nvim',
  dependencies = {
    { 'fzf-lua' },
    { 'nvim-tree/nvim-web-devicons' },
    { 'echasnovski/mini.icons' },
  },
  opts = function(_, _)
    local fzf_lua = require('sapnvim_project.picker.fzf_lua')
    return {
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

      -- Useing fzf-lua
      picker = 'fzf-lua',

      --- fzf-lua config
      picker_opts = {
        winopts = { height = 0.33, width = 0.7 },
        prompt = "Select a project> ",
        fzf_opts = {
          ["--ansi"] = "",                                      -- Enable ANSI color codes
          ["--delimiter"] = fzf_lua.delimiter,                  -- Set delimiter for data parsing
          ["--with-nth"] = "2..",                               -- Hide the ID column
          ["--header"] = "name                            path" -- Display header
        },
        -- Set the default action to our module-level function
        actions = {
          ['default'] = fzf_lua.select_and_load_session
        }
      }
    }
  end
}
```
</details>

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
