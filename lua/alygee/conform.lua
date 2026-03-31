local util = require("conform.util")

require("conform").setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- Disable "format_on_save lsp_fallback" for languages that don't
    -- have a well standardized coding style. You can add additional
    -- languages here or re-enable it for the disabled ones.
    local disable_filetypes = { c = true, cpp = true }
    local lsp_format_opt
    if disable_filetypes[vim.bo[bufnr].filetype] then
      lsp_format_opt = "never"
    else
      lsp_format_opt = "fallback"
    end
    return {
      timeout_ms = 500,
      lsp_format = lsp_format_opt,
    }
  end,
  formatters_by_ft = {
    php = { "pint" },
    blade = { "blade-formatter" },
    lua = { "stylua" },
    python = { "isort", "black" },
    ["javascript"] = { "prettierd", "prettier" },
    ["javascriptreact"] = { "prettierd", "prettier" },
    ["typescript"] = { "prettierd", "prettier" },
    ["typescriptreact"] = { "prettierd", "prettier" },
    ["vue"] = { "prettierd", "prettier" },
    ["css"] = { "prettierd", "prettier" },
    ["scss"] = { "prettierd", "prettier" },
    ["less"] = { "prettierd", "prettier" },
    ["html"] = { "prettierd", "prettier" },
    ["json"] = { "prettierd", "prettier" },
    ["jsonc"] = { "prettierd", "prettier" },
    ["yaml"] = { "prettierd", "prettier" },
    ["markdown"] = { "prettierd", "prettier" },
    ["markdown.mdx"] = { "prettierd", "prettier" },
    ["graphql"] = { "prettierd", "prettier" },
    ["handlebars"] = { "prettierd", "prettier" },
  },
  formatters = {
    injected = { options = { ignore_errors = true } },

    ["blade-formatter"] = {
      command = "blade-formatter",
      args = {
        "--write",
        "$FILENAME",
        "--wrap-line-length",
        9999,
        "--wrap-attributes",
        "preserve-aligned",
      },
      cwd = util.root_file({
        ".editorconfig",
        "composer.json",
        "package.json",
      }),
      stdin = false,
    },

    pint = {
      meta = {
        url = "https://github.com/laravel/pint",
        description = "Laravel Pint is an opinionated PHP code style fixer for minimalists. Pint is built on top of PHP-CS-Fixer and makes it simple to ensure that your code style stays clean and consistent.",
      },
      command = util.find_executable({
        vim.fn.stdpath("data") .. "/mason/bin/pint",
        "vendor/bin/pint",
      }, "pint"),
      args = { "$FILENAME" },
      stdin = false,
    },
  },
})
