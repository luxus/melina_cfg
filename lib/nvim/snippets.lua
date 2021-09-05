local luasnip = require("luasnip")
local c = luasnip.choice_node
local i = luasnip.insert_node
local s = luasnip.snippet
local t = luasnip.text_node

luasnip.snippets = {
  nix = {
    s("mkDerivation", {
      t({
        "{ fetchFromGitHub, lib, stdenv }:",
        "",
        "stdenv.mkDerivation rec {",
        '  pname = "',
      }),
      i(1),
      t({ '";', '  version = "' }),
      i(2),
      t({ '";', "", "  src = fetchFromGitHub {", '    owner = "' }),
      i(3),
      t({
        '";',
        "    repo = pname;",
        "    rev = ",
      }),
      c(4, { t('"v${version}"'), t("version") }),
      t({
        ";",
        '    sha256 = "";',
        "  };",
        "",
        "  meta = with lib; {",
        '    description = "";',
        '    homepage = "";',
        "    license = ",
      }),
      i(5),
      t({
        ";",
        "    platforms = platforms.all;",
        "    maintainers = with maintainers; [ figsoda ];",
        "  };",
        "}",
      }),
    }, {
      condition = function()
        return vim.fn.line(".") == 1
      end,
    }),

    s("buildRustPackage", {
      t({
        "{ fetchFromGitHub, lib, rustPlatform }:",
        "",
        "rustPlatform.buildRustPackage rec {",
        '  pname = "',
      }),
      i(1),
      t({ '";', '  version = "' }),
      i(2),
      t({ '";', "", "  src = fetchFromGitHub {", '    owner = "' }),
      i(3),
      t({
        '";',
        "    repo = pname;",
        "    rev = ",
      }),
      c(4, { t('"v${version}"'), t("version") }),
      t({
        ";",
        '    sha256 = "";',
        "  };",
        "",
        '  cargoSha256 = "";',
        "",
        "  meta = with lib; {",
        '    description = "";',
        '    homepage = "";',
        "    license = ",
      }),
      i(5),
      t({ ";", "    maintainers = with maintainers; [ figsoda ];", "  };", "}" }),
    }, {
      condition = function()
        return vim.fn.line(".") == 1
      end,
    }),
  },
}