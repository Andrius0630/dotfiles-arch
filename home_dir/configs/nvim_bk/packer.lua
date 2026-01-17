-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
	  'nvim-telescope/telescope.nvim', tag = '*',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use({
	  'rose-pine/neovim',
	  as = 'rose-pine',
	  config = function()
		  vim.cmd('colorscheme rose-pine')
	  end
  })

  use{'nvim-treesitter/nvim-treesitter', branch = 'master', run = ':TSUpdate'}

  use{'nvim-treesitter/playground'}

  use "nvim-lua/plenary.nvim" -- don't forget to add this one if you don't have it yet!

  use {
	  "ThePrimeagen/harpoon",
	  -- branch = "harpoon2",
	  requires = { {"nvim-lua/plenary.nvim"} }
  }
  use "mbbill/undotree"
  use "tpope/vim-fugitive"

  use {
	  'neovim/nvim-lspconfig',
	  requires = {
		  'williamboman/mason.nvim',
		  'williamboman/mason-lspconfig.nvim',
	  }
  }
end)
