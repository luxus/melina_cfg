local dap = require("dap")
local dapui = require("dapui")
local gitsigns = require("gitsigns")
local luasnip = require("luasnip")

local api = vim.api
local b = vim.b
local g = vim.g
local map = vim.keymap.set
local o = vim.o

local function mapt(buf, lhs, cmd, no_auto_quit)
  map("n", lhs, function()
    api.nvim_command("T " .. cmd)
    b.no_auto_quit = no_auto_quit
    api.nvim_command("startinsert")
  end, { buffer = buf })
end

local function map_cargo(ctx)
  mapt(ctx.buf, " B", "@rust@/bin/cargo run", true)
  map("n", " D", ":!@rust@/bin/cargo doc --open<cr>", { buffer = ctx.buf })
  mapt(ctx.buf, " U", "@cargo_edit@/bin/cargo-upgrade upgrade")
  map("n", " a", function()
    vim.ui.input({ prompt = "Add dependencies: " }, function(flags)
      if flags then
        api.nvim_command("T @rust@/bin/cargo add " .. flags)
        api.nvim_command("startinsert")
      end
    end)
  end, { buffer = ctx.buf })
  mapt(ctx.buf, " b", "@rust@/bin/cargo build")
  mapt(ctx.buf, " c", "@rust@/bin/cargo test")
  mapt(ctx.buf, " u", "@rust@/bin/cargo update")
end

local function map_nix(ctx)
  mapt(ctx.buf, " B", "@nix@/bin/nix run", true)
  mapt(ctx.buf, " U", "@nix@/bin/nix flake update --commit-lock-file")
  mapt(ctx.buf, " b", "@nix@/bin/nix build")
  mapt(ctx.buf, " c", "@nix@/bin/nix flake check")
  mapt(ctx.buf, " i", "@nix@/bin/nix repl -f @nixpkgs@")
  mapt(ctx.buf, " u", "@nix@/bin/nix flake update")
end

g.loaded_netrw = true
g.loaded_netrwFileHandlers = true
g.loaded_netrwPlugin = true
g.loaded_netrwSettings = true
g.mapleader = " "
g.zig_fmt_autosave = false
g.zig_fmt_parse_errors = false

o.clipboard = "unnamedplus"
o.completeopt = "menuone,noinsert,noselect"
o.cursorline = true
o.expandtab = true
o.ignorecase = true
o.list = true
o.listchars = "tab:-->,trail:+,extends:>,precedes:<,nbsp:·"
o.mouse = "a"
o.foldenable = false
o.showmode = false
o.swapfile = false
o.number = true
o.relativenumber = true
o.scrolloff = 2
o.shiftwidth = 4
o.shortmess = "aoOtTIcF"
o.showtabline = 2
o.signcolumn = "yes"
o.smartcase = true
o.smartindent = true
o.splitbelow = true
o.splitright = true
o.termguicolors = true
o.timeoutlen = 400
o.title = true
o.updatetime = 300

api.nvim_create_autocmd("BufRead", {
  pattern = "all-packages.nix",
  callback = function()
    require("cmp").setup.buffer({
      sources = {
        { name = "nvim_lsp" },
        { name = "path" },
      },
    })
  end,
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "Cargo.toml", "Cargo.lock" },
  callback = map_cargo,
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "flake.lock",
  callback = map_nix,
})

api.nvim_create_autocmd("FileType", {
  pattern = "nix",
  callback = map_nix,
})

api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(ctx)
    if string.sub(ctx.file, 1, 5) == "/tmp/" then
      mapt(ctx.buf, " B", "@rust@/bin/cargo -Zscript " .. ctx.file, true)
    else
      map_cargo(ctx)
    end
  end,
})

api.nvim_create_autocmd("TermClose", {
  callback = function()
    if not b.no_auto_quit then
      vim.defer_fn(function()
        if api.nvim_get_current_line() == "[Process exited 0]" then
          api.nvim_buf_delete(0, { force = true })
        end
      end, 50)
    end
  end,
})

api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

api.nvim_create_user_command("P", function(input)
  local ext = input.fargs[1]
  local file = vim.fn.tempname()
  if ext and ext ~= "" then
    file = file .. "." .. ext
  end
  api.nvim_command("edit " .. file)

  if ext == "rs" then
    api.nvim_put({
      "//!```cargo",
      "//! [package]",
      [[//! edition = "2021"]],
      "//!",
      "//! [dependencies]",
      "//! ```",
      "",
      "fn main() {}",
    }, "c", false, false)
  end
end, { nargs = "?" })

map("n", " dB", dap.clear_breakpoints)
map("n", " dC", dap.reverse_continue)
map("n", " db", dap.toggle_breakpoint)
map("n", " dc", dap.continue)
map("n", " dd", function()
  dapui.toggle({ reset = true })
end)
map("n", " dh", dap.step_out)
map("n", " dj", dap.step_over)
map("n", " dk", dap.step_back)
map("n", " dl", dap.step_into)
map("n", " dt", dap.terminate)
map("n", " gR", gitsigns.reset_buffer)
map("n", " gb", gitsigns.blame_line)
map("n", " gh", gitsigns.preview_hunk)
map("n", " gr", gitsigns.reset_hunk)
map("n", " gs", gitsigns.stage_hunk)
map("n", " gu", gitsigns.undo_stage_hunk)
map("n", " nd", function()
  require("nix-develop").nix_develop({})
end)
map("n", " q", require("trouble").toggle)
map("n", "[h", gitsigns.prev_hunk)
map("n", "]h", gitsigns.next_hunk)

map("s", "<s-tab>", function()
  luasnip.jump(-1)
end)
map("s", "<tab>", function()
  luasnip.jump(1)
end)

map({ "i", "s" }, "<c-x>", function()
  luasnip.change_choice(1)
end)

map({ "n", "v", "s" }, " de", dapui.eval)
map({ "n", "v", "s" }, "<c-w>", function()
  if vim.bo.buftype == "terminal" then
    api.nvim_buf_delete(0, { force = true })
  else
    api.nvim_command("confirm bdelete")
  end
end)

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = {
    format = function(diagnostic)
      return table.concat(
        vim.tbl_filter(function(line)
          return line ~= ""
        end, vim.tbl_map(vim.trim, vim.split(diagnostic.message, "\n"))),
        ", "
      )
    end,
  },
})
