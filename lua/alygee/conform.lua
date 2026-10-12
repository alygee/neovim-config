local util = require("conform.util")

-- Проект «выбирает» oxfmt наличием его конфига (.oxfmtrc.json/.oxfmtrc.jsonc)
-- вверх по дереву от файла — та же конвенция, что и у самого oxc. Если конфига
-- нет, форматируем js/ts как раньше, через prettierd → prettier.
local oxfmt_markers = { ".oxfmtrc.json", ".oxfmtrc.jsonc" }

local function js_ts_formatters(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local dir = bufname ~= "" and vim.fs.dirname(bufname) or vim.loop.cwd()
  if vim.fs.root(dir, oxfmt_markers) ~= nil then
    return { "oxfmt" }
  end
  return { "prettierd", "prettier" }
end

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
    -- 500 мс слишком мало: Prettier (особенно без кэша prettierd) часто не успевает
    return {
      timeout_ms = 8000,
      lsp_format = lsp_format_opt,
    }
  end,
  formatters_by_ft = {
    php = { "pint" },
    blade = { "blade-formatter" },
    cs = { "csharpier" },
    lua = { "stylua" },
    -- ruff заменяет isort + black; бинарник ставит Mason вместе с LSP `ruff`
    python = { "ruff_organize_imports", "ruff_format" },
    ["javascript"] = js_ts_formatters,
    ["javascriptreact"] = js_ts_formatters,
    ["typescript"] = js_ts_formatters,
    ["typescriptreact"] = js_ts_formatters,
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
