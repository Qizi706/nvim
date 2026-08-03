return {
  keys = {
    { "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
  },
  root_markers = {
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac", -- AutoTools
    "Makefile",
    "configure.in",
    "config.h.in",
    "meson.build",
    "meson_options.txt",
    "build.ninja",
    ".git",
    ".clangd",
    ".clang-tidy",
    ".clang-format",
  },
  capabilities = {
    offsetEncoding = { "utf-16" },
  },
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
    fallbackFlags = { "-std=c++23" },
  },
}
