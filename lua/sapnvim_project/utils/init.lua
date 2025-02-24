---@tag sapnvim_project.utils
--- This module provides utility functions for handling file paths.
--- It includes functions to resolve filenames, format paths, obtain the current working directory,
--- check if a path is valid (i.e., is a directory), and append a trailing slash to directory paths.
---
--- The underlying implementations are defined in sapnvim_project.utils.__path.
---
--- Example usage:
--- local utils = require("sapnvim_project.utils")
--- local abs_path = utils.resolve("~/.config/nvim/init.lua")
--- print("Absolute Path: " .. abs_path)

local utils = {}

--- Resolves a given filename to its absolute path.
--- It expands any shell variables or '~' in the filename using vim.fn.expand,
--- and then resolves it to its absolute path using vim.fn.resolve.
---
---@param filename string The filename or path to resolve.
---@return string filename The resolved absolute path.
---@type fun(filename: string): string
utils.resolve = require('sapnvim_project.utils.__path').resolve

--- Formats a given path by applying vim's filename modifier.
--- It replaces the home directory segment with '~' if applicable.
---
---@param path string The file path to format.
---@return string The formatted path.
---@type fun(path: string): string
utils.format_path = require('sapnvim_project.utils.__path').format_path

--- Check if a string is a valid filename
---@param filename string The filename string to check
---@param extension string Expected file extension (without dot, e.g. "lua")
---@return boolean? ok, string|nil msg # Returns whether valid and error message
---@type fun(filename: string, extension: string): boolean, string|nil
utils.is_valid_filename = require('sapnvim_project.utils.__path').is_valid_filename

--- Returns the current working directory in a formatted style.
--- The directory is obtained using vim.uv.cwd() and then formatted using the format_path function.
---
---@return string The formatted current working directory.
---@type fun(): string
utils.cwd = require('sapnvim_project.utils.__path').cwd

--- Checks if a given path is a valid directory.
--- It first resolves the path using the resolve function and then checks whether it is a directory using vim.fn.isdirectory.
---
---@param path string The path to validate.
---@return number 0|1 Returns 1 if the path is a valid directory; otherwise, returns 0.
---@type fun(path: string): 0|1
utils.is_valid_path = require('sapnvim_project.utils.__path').is_valid_path

--- Appends a trailing slash to the given path if it corresponds to a directory and doesn't already end with one.
--- It uses vim.uv.fs_stat to determine whether the path is a directory.
---
---@param path string The file or directory path.
---@return string path The updated path with a trailing slash if it represents a directory; otherwise, the original path.
---@type fun(path: string): string
utils.add_slash_if_folder = require('sapnvim_project.utils.__path').add_slash_if_folder

return utils
