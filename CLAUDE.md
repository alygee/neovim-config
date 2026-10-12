# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim configuration, originally derived from kickstart.nvim but split into
modules. Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim), with LSP
servers, formatters, and tools installed automatically via Mason. There is no build or test
system — changes are validated by opening Neovim.

## Layout & load order

`init.lua` requires `alygee`, which runs `lua/alygee/init.lua`. That file requires the other
modules **in a fixed order** — plugins must be set up (`lazy`) before any module that calls
`require()` on a plugin:

```
lua/alygee/init.lua   → orchestrator; also defines yank-highlight + diagnostic keymaps
  ├─ lazy.lua         → lazy.nvim bootstrap + the ENTIRE plugin list, incl. LSP/Mason/cmp config
  ├─ set.lua          → vim options + BufWritePre CR-trimming autocmd
  ├─ remap.lua        → keymaps (movement, harpoon, dotnet <leader>n* runners)
  ├─ telescope.lua    → telescope setup + <leader>s* search keymaps
  ├─ treesitter.lua   → treesitter (deferred via vim.defer_fn) + textobject/move/swap keymaps
  └─ conform.lua      → formatters + format_on_save
```

`typescript-tools.lua` exists but is **not** required by `init.lua`; it is loaded by lazy.nvim
as the plugin's own config (see the `pmizio/typescript-tools.nvim` spec in `lazy.lua`).

`after/plugin/*.lua` runs automatically after all plugins load: `colors.lua` sets the gruvbox
colorscheme (transparent), `snippets.lua` registers LuaSnip snippets. `neoformat.lua` is an
intentionally empty stub (formatting moved to conform).

## Key architectural points

- **LSP is configured entirely inside `lazy.lua`** in the `nvim-lspconfig` spec's `config`
  function, not in a separate module. Servers are declared in the local `servers` table and
  registered with `vim.lsp.config()` + `vim.lsp.enable()` via mason-lspconfig v2 (the old
  `handlers` API is gone). LSP keymaps (`gd`, `gr`, `<leader>rn`, `<leader>ca`, …) are set in
  the `LspAttach` autocmd and route "go to" actions through Telescope.
- **TypeScript uses `typescript-tools.nvim`, not `ts_ls`.** Don't add `ts_ls` to the `servers`
  table — it would double up. C# uses `csharp_ls`; `omnisharp`/`omnisharp_mono` are explicitly
  excluded from mason-lspconfig auto-enable to avoid two LSPs on `.cs`.
- **Formatting is conform.nvim only.** `format_on_save` runs on write with an 8000ms timeout
  (Prettier needed more than the default), falling back to LSP formatting except for c/cpp.
  Formatters are per-filetype in `formatters_by_ft`. JS/TS filetypes use the
  `js_ts_formatters(bufnr)` chooser: if `.oxfmtrc.json`/`.oxfmtrc.jsonc` is found upward from
  the file it formats with `oxfmt`, otherwise `prettierd` → `prettier`. Other web filetypes
  (vue/css/html/json/…) always use prettier. `<leader>f` formats manually.
- **Mason auto-installs** everything in the `servers` table plus the extra tools list in
  `lazy.lua` (`stylua`, `prettierd`, `csharpier`, tailwind/html/php LSPs, `eslint`). If a tool
  is missing, add it there rather than installing manually.
- Leader is `<Space>`. `<leader>n*` runs dotnet commands (`build`/`run`/`test`/`clean`/`watch`)
  in a terminal split, resolving the workdir by walking up to the nearest `.sln`/`.csproj`.
  Note the `<leader>n` prefix was deliberately chosen over `<leader>d` to avoid a which-key
  clash that caused commands to fire twice.
- Harpoon (branch `harpoon2`) is set up in both `lazy.lua` and `remap.lua`; `<C-e>` toggles the
  menu, `<A-1>`..`<A-9>` jump to marks.

## Making changes

- **Adding a plugin:** add a spec to the `require("lazy").setup({ … })` table in `lazy.lua`.
- **Adding an LSP:** add it to the `servers` table in `lazy.lua`'s lspconfig `config` function.
- **Adding a formatter:** add the filetype→formatter mapping in `conform.lua` and add the tool
  binary to the Mason `ensure_installed` list in `lazy.lua`.
- After editing, verify with `nvim --headless "+qa"` (surfaces Lua load errors) or by opening
  Neovim; run `:Lazy sync`, `:Mason`, and `:checkhealth` as needed. Lua is formatted with
  `stylua` (2-space indent, per `.editorconfig`).
- Pinned plugin versions live in `lazy-lock.json` — commit it after `:Lazy sync`.
- Many inline comments are in Russian and capture hard-won gotchas (LSP conflicts, formatter
  timeouts, keymap clashes); read them before changing nearby code.
