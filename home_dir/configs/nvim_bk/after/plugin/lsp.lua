require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { 
		"clangd", "lua_ls", "jdtls", "bashls", "rust_analyzer", "marksman", "dockerls" 
	}
})

-- 2. Ensure Mason's binaries are in Neovim's PATH
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. ":" .. vim.env.PATH

-- 3. Enable the servers (Native v0.11 API)
local servers = { 
	"clangd", "lua_ls", "jdtls", "bashls", "rust_analyzer", "marksman", "dockerls" 
}

for _, lsp in ipairs(servers) do
	vim.lsp.enable(lsp)
end

vim.lsp.config('lua_ls', {
	settings = {
		Lua = {
			diagnostics = { globals = { 'vim' } }
		}
	}
})

