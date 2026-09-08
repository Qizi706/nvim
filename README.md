# Neovim 配置（开发机）

基于 LazyVim + lazy.nvim 的个人配置，面向 Linux 开发机，使用本仓库的 `devbox` 分支。
已有插件的配置与 `macos` 分支同步，保留开发机 OSC52 剪贴板设置，不引入 Astro 和图片／公式渲染扩展。
主要用于 C/C++、Go、Python、前端和 Markdown 编辑，集成 Git、调试、测试及 Sidekick AI CLI。
插件版本由 [lazy-lock.json](lazy-lock.json) 记录，启用的 LazyVim Extras 见 [lazyvim.json](lazyvim.json)。

第一次使用请按顺序完成「安装依赖」和「安装配置与首次启动」，之后可查阅功能与快捷键。
代码块中的 `sh` 命令在开发机终端执行；以 `:` 开头的命令在 Neovim 中按 `Esc` 后输入并回车。

## 目录

- [安装依赖](#安装依赖)
- [安装配置与首次启动](#安装配置与首次启动)
- [功能](#功能)
- [快捷键](#快捷键)
- [常见问题](#常见问题)
- [更新方式](#更新方式)
- [配置目录](#配置目录)

## 安装依赖

优先复用开发机已有工具；缺失时按机器的包管理方式或团队环境说明补齐，不必重复安装。

### 1. 检查基础依赖

基础编辑和搜索需要 Neovim、Git、ripgrep、fd；Treesitter 需要 C 编译器和 Tree-sitter CLI。
使用 Sidekick 时需要 tmux 及所选 AI CLI。语言运行时按实际项目需要准备。

| 依赖 | 用途 |
| --- | --- |
| Neovim 0.11.2+（LuaJIT）、Git 2.19+ | 运行配置、下载插件；版本要求见 [LazyVim 官方说明](https://www.lazyvim.org/) |
| `rg`（ripgrep）、`fd` | 全文搜索、文件查找 |
| C 编译器、`tree-sitter` CLI | 编译和安装语法解析器；使用开发机已有的 GCC 或 Clang |
| Node.js / npm | 运行及安装前端、Pyright、Markdown 等语言工具 |
| Python 3 | Python 开发，以及部分 Mason 工具的安装和运行 |
| Go | Go 开发和相关工具安装；本分支已启用 Go 扩展 |
| `tmux` | Sidekick 使用的 terminal multiplexer |

本分支保留已启用的语言扩展；Node.js、Python 和 Go 按实际使用的语言工具准备。
系统依赖由开发机环境提供；lazy.nvim 安装 Neovim 插件；Mason 管理语言服务器、格式化器和调试器。
这些依赖不会随配置仓库一起下载。

安装后检查命令是否可用：

```sh
nvim --version
git --version
rg --version
fd --version
tree-sitter --version
node --version
npm --version
python3 --version
go version
tmux -V
cc --version
```

### 2. 设置终端和字体

在连接开发机的本地终端中启用真彩色，并选择 Nerd Font 3+，以正确显示图标。
字体安装在运行终端的本地机器上，SSH 开发机无需安装字体。
若本地使用 macOS，使用 `Alt+j/k` 时将终端的 Option 键设置为 Alt/Meta；功能键可能需要配合 Fn。

### 3. 按需安装附加工具

使用 Git 交互界面时准备 `lazygit`，使用 CMake 项目时准备 `cmake`。
当前分支未启用 Snacks 图片／公式渲染配置，无需为此安装 ImageMagick、Tectonic 或 Typst。

Sidekick 使用的 `coco`、`traex` 或其他 AI CLI，需要按所选工具的官方或内部文档单独安装并登录。
先在同一个终端中确认对应命令可以正常启动，再进入 Neovim 使用 `<leader>as` 选择工具。
本仓库只提供集成配置，不提供这些 CLI 的安装包或账号。

## 安装配置与首次启动

### 1. 备份并克隆配置

完成上述依赖安装后，先关闭所有 Neovim 实例，并在配置目录之外（例如 `cd "$HOME"`）执行以下步骤。
以下使用 Linux 上 Neovim 的默认路径；若设置了 `XDG_*` 或 `NVIM_APPNAME`，请调整路径。
已有配置会被重命名备份，不会删除。

```sh
cd "$HOME"
nvim_backup_stamp=$(date +%Y%m%d-%H%M%S)
if [ -e "$HOME/.config/nvim" ] || [ -L "$HOME/.config/nvim" ]; then
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$nvim_backup_stamp"
fi
mkdir -p "$HOME/.config"
git clone --branch devbox --single-branch https://github.com/Qizi706/nvim.git "$HOME/.config/nvim"
```

克隆后检查分支，输出应为 `devbox`：

```sh
git -C "$HOME/.config/nvim" branch --show-current
```

有推送权限且已配置 GitHub SSH 的机器可改用 `git@github.com:Qizi706/nvim.git`。
需要将 HTTPS remote 改为 SSH 时：

```sh
git -C "$HOME/.config/nvim" remote set-url origin git@github.com:Qizi706/nvim.git
```

若原机器使用其他 Neovim 配置，可以在启动前备份旧插件数据与状态，避免混用：

```sh
for nvim_old_dir in \
  "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
  if [ -e "$nvim_old_dir" ] || [ -L "$nvim_old_dir" ]; then
    mv "$nvim_old_dir" "$nvim_old_dir.backup.$nvim_backup_stamp"
  fi
done
```

这些目录可能包含 Mason 工具、会话、撤销历史等。新机器通常重新安装插件和工具即可；需要保留会话/历史时另行迁移相应状态数据。

### 2. 安装插件并恢复锁定版本

```sh
nvim
```

首次启动会自动下载 lazy.nvim 并安装插件，需要能访问 GitHub 及相关工具的下载源。
等待下载和构建完成；若有失败项，先查看 `:Lazy` 中的错误信息。安装完成后执行：

```vim
:Lazy restore
```

等待完成并重启 Neovim，使插件与仓库 `lazy-lock.json` 对齐。
迁移复现使用 `restore`；`update` 会主动升级插件，不是复现旧环境的步骤。

### 3. 安装语言服务器、格式化器和调试器

打开常用语言的项目文件，等待对应插件加载，再执行：

```vim
:Mason
```

已配置的工具会按插件规则安装。在 Mason 界面按 `?` 查看帮助，选中缺失工具按 `i` 安装，按 `Enter` 展开安装日志。
需要手动补装时，可按语言选择执行以下命令，不必全部执行：

| 用途 | 在 Neovim 中执行 |
| --- | --- |
| C/C++ 语言服务和调试 | `:MasonInstall clangd codelldb` |
| Python 语言服务、检查和调试 | `:MasonInstall pyright ruff debugpy` |
| Go 语言服务、格式化和调试 | `:MasonInstall gopls goimports gofumpt delve` |
| TypeScript / JavaScript | `:MasonInstall vtsls` |
| Markdown 语言服务与检查 | `:MasonInstall marksman markdownlint-cli2` |
| Markdown 目录与格式化 | `:MasonInstall markdown-toc prettier` |

Mason 工具名可能与可执行文件名不同，例如 `delve` 安装后提供 `dlv`。
遇到下载失败时查看 Mason 安装日志，检查网络及 Node.js、Python、Go 是否可用，然后重试。
Treesitter parser 由 Treesitter 插件管理，不在 Mason 中安装；解析器安装报错时检查 `cc` 和 `tree-sitter`。

### 4. 准备项目环境并验证

项目依赖仍需在各自的项目目录中安装。例如 Python 项目可创建独立虚拟环境：

```sh
python3 -m venv .venv
source .venv/bin/activate
# 项目使用 requirements.txt 时执行
python -m pip install -r requirements.txt
# 项目使用 pytest 且尚未安装时执行
python -m pip install pytest
```

打开 Python 文件后用 `<leader>cv` 选择该环境。前端项目按项目说明使用 npm/pnpm/yarn 安装依赖；
Go 项目可运行 `go mod download`；C/C++ 项目按下文准备编译数据库。
数据库连接、调试启动参数、AI CLI 登录和其他机器/项目级配置需要单独准备，不会随仓库克隆。

在 Neovim 中执行健康检查：

```vim
:checkhealth
:checkhealth snacks
:Mason
:LspInfo
```

打开实际项目文件后再检查 LSP，确认 LSP server 已连接到当前 buffer；用 `<leader>ff` 查找文件、`<leader>/` 搜索文本，
并在支持 LSP 的文件中尝试 `K` 查看文档。
剪贴板在 `options.lua` 中使用 OSC52，并设置 `unnamedplus`，用于通过 SSH 将复制内容传到本地终端。
复制和读取剪贴板需要终端支持并允许相应 OSC52 操作；粘贴可使用本地终端的粘贴快捷键。

## 功能

| 类别 | 当前配置 |
| --- | --- |
| 主题与浮窗 | Catppuccin Mocha，非透明背景；圆角边框；统一补全、文档、Picker、WhichKey 的背景与边框颜色 |
| 启动页 | Snacks Dashboard 自定义 ASCII 动画；离开启动页或窗口失焦后暂停动画 |
| 文件与搜索 | Snacks Picker：文件、全文、buffer、符号、Git、历史记录搜索；关闭 Picker 背景淡化 |
| 编辑辅助 | Flash 跳转、Treesitter、自动括号、text object、Yanky 复制历史、Dial 数值增减、增量重命名、颜色高亮 |
| 补全 | nvim-cmp，整合 LSP、路径、buffer 等来源，定制补全及文档窗口高亮 |
| 代码诊断 | LSP、Trouble、Inlay Hints、CodeLens；具体能力取决于语言服务器 |
| Git | Gitsigns 差异标记、hunk 操作、当前行 blame 开关；安装 lazygit 后可打开 Git 界面 |
| 调试与测试 | nvim-dap、DAP UI、虚拟文本、Neotest；已启用 Go/Python 相关扩展 |
| Markdown | render-markdown 标题图标、浏览器预览、markdownlint-cli2 检查与修复 |
| AI CLI | Sidekick + tmux，面板宽度 40%，支持工具选择、发送文件/选区、自定义提示词和 scrollback 刷新 |
| 其他 UI | Bufferline 按目录排序；Trouble 符号面板位于右侧、宽度 40%；Noice 文档窗口带边框 |
| 终端与会话 | Snacks Terminal、通知、缩进线、作用域、词引用高亮，以及 LazyVim 的会话恢复 |

Snacks 通用动画和平滑滚动默认关闭；启动页使用独立的动画逻辑。
Flash 字符跳转模式关闭背景淡化（`highlight.backdrop = false`）。

### 语言支持

| 语言/文件 | 配置说明 |
| --- | --- |
| C / C++ | clangd：后台索引、clang-tidy、IWYU 头文件插入、详细补全、函数参数占位 |
| Python | Pyright + Ruff；虚拟环境选择、Python 调试与测试扩展 |
| Go | Go 语言扩展、DAP 和 Neotest Go 适配器 |
| TypeScript / JavaScript | TypeScript、VTSLS 扩展 |
| JSON / TOML / SQL / Git | 对应语言扩展；SQL 集成 Dadbod、数据库 UI 和补全 |
| Markdown | 文档渲染、预览、格式化与 lint；允许裸 URL，标题结尾允许中英文冒号 |
| CSS / SCSS / Svelte / Vue / LaTeX / Typst | 显式追加 Treesitter parser |

安装 parser 不等于配置对应语言的完整 LSP；clangd 使用 UTF-16 offset encoding。

**C/C++ 默认关闭自动格式化**，仍可用 `<leader>cf` 手动格式化。
clangd 根据 `compile_commands.json`、`compile_flags.txt`、Makefile、Meson、
`.git`、`.clangd` 等标记识别项目。
大型 C/C++ 项目应提供正确的编译数据库，例如 CMake 项目：

```sh
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

若 clangd 未找到 `build/compile_commands.json`，可在项目 `.clangd` 中配置：

```yaml
CompileFlags:
  CompilationDatabase: build
```

本配置未强制设置 C++ 标准，标准版本由项目编译参数决定。

### Sidekick 使用说明

- 使用 tmux 后端，`mux.enabled = true`、`create = "terminal"`。
- 在插件内置工具之外，增加 `coco`、`traex` 命令；工具必须在本机安装并完成各自的登录/配置。
- 关闭 NES（Next Edit Suggestions）及 Copilot 状态跟踪。
- Sidekick 窗口内默认的提示词快捷键被禁用；仍可通过 `<leader>ap` 选择提示词。
- Normal 模式下按 `R` 刷新已打开的 tmux scrollback 快照，并恢复查看位置。
- 仅手动刷新 scrollback，不启用自动轮询。

| 提示词名称 | 用途 |
| --- | --- |
| `chinese` | 中文回复 |
| `concise` | 简洁作答、结论优先 |
| `detailed` | 详细说明推理、权衡和实现细节 |
| `no_modify` | 未明确要求时不要修改文件 |
| `ask_first` | 需求或边界不清时先确认 |
| `web_search` | 对后续内容先联网搜索 |
| `translate` | 将后续内容翻译为中文 |
| `redo` | 根据已明确的讨论重新执行上一版修改 |
| `codegraph_review` | 使用 CodeGraph 审查未提交修改，按严重程度报告正确性问题；需在目标项目中准备 CodeGraph |

## 快捷键

`<leader>` 是空格，`<localleader>` 是反斜杠；`<M-…>` / `<A-…>` 表示 Alt
（macOS 上通常是 Option），`<C-…>` 表示 Ctrl。
例如 `<leader>ff` 表示依次按空格、`f`、`f`。
未注明模式的表项默认为 Normal 模式。以下覆盖本仓库自定义映射及当前锁定版本的常用继承映射。

按空格后等待可查看 WhichKey 分组；`<leader>sk` 搜索快捷键。
检查某个键的实际来源可用 `:verbose nmap <M-j>`，Insert 模式使用 `:verbose imap <M-j>`。

### 本仓库自定义快捷键

| 按键 | 模式/范围 | 功能 |
| --- | --- | --- |
| `Alt+j` / `Alt+k` | Normal、Visual | 向下/向上移动 8 行，覆盖 LazyVim 默认的移动文本行行为 |
| `F5` | Normal | 启动/继续调试 |
| `F10` | Normal | Step Over |
| `F11` | Normal | Step Into |
| `Shift+F11` | Normal | Step Out |
| `<leader>gt` | Normal | 切换当前行 Git blame，显示延迟为 0 |
| `R` | Sidekick Normal 模式 | 刷新已打开的 tmux scrollback 快照 |

`Alt+j/k` 的 Insert 模式映射未被本仓库覆盖，仍继承 LazyVim 的移动文本行行为。
若 macOS 收不到 Alt 组合键，需要在终端设置中将 Option 配置为 Alt/Meta；功能键也可能需要配合 Fn。

### 文件、窗口与搜索

| 按键 | 功能 |
| --- | --- |
| `Ctrl+s` | 保存文件（也支持 Insert、Visual 和 Select 模式） |
| `<leader><space>` / `<leader>ff` | 在项目根目录查找文件 |
| `<leader>fF` | 在当前工作目录查找文件 |
| `<leader>fc` / `<leader>fr` / `<leader>fp` | 查找配置文件 / 最近文件 / 项目 |
| `<leader>,` / `<leader>fb` | 选择 buffer |
| `<leader>/` / `<leader>sg` | 搜索项目文本，需要 `rg` |
| `<leader>sG` / `<leader>sb` | 搜索当前工作目录 / 当前 buffer 行 |
| `<leader>sw` | 搜索光标下单词或 Visual 选区 |
| `<leader>ss` / `<leader>sS` | 搜索当前文件 / 工作区 LSP 符号 |
| `<leader>sk` / `<leader>sh` | 查找快捷键 / 帮助 |
| `s` / `S` | Flash 跳转 / Treesitter 跳转（也支持 Visual、Operator-pending 模式） |
| `Shift+h` / `Shift+l` | 上一个 / 下一个 buffer |
| `<leader>bd` / `<leader>bo` | 关闭当前 / 其他 buffer |
| `Ctrl+h/j/k/l` | 切换到左/下/上/右窗口 |
| `<leader>-` / `<leader>\|` | 向下 / 向右分屏 |
| `<leader>wd` / `<leader>wm` | 关闭窗口 / 切换窗口最大化 |
| `<leader>ft` / `<leader>fT` | 打开项目根目录 / 当前目录终端 |
| `Ctrl+/` | 聚焦项目终端（Normal、Terminal 模式；部分终端发送 `Ctrl+_`） |
| `<leader>qs` / `<leader>qS` / `<leader>ql` | 恢复当前目录会话 / 选择会话 / 恢复最近会话 |
| `<leader>qq` | 退出全部窗口 |

在 Snacks Picker 输入窗口中，`Alt+c` 切换根目录/当前目录，`Alt+t` 将结果交给 Trouble，`Alt+a` 发送至 Sidekick。

### 补全、LSP 与诊断

| 按键 | 功能 |
| --- | --- |
| `Ctrl+Space` | 触发补全（Insert 模式） |
| `Ctrl+n` / `Ctrl+p` | 下一个 / 上一个补全项（Insert 模式） |
| `Enter` / `Ctrl+y` | 确认补全 / 确认选中项或首项（补全菜单中） |
| `Ctrl+b` / `Ctrl+f` | 向上 / 向下滚动补全文档（Insert 模式） |
| `Tab` | 在可用代码片段中向前跳转，否则使用回退行为（Insert 模式） |
| `gd` / `gr` / `gI` / `gy` | 定义 / 引用 / 实现 / 类型定义 |
| `K` | 查看 Hover 文档 |
| `<leader>cr` / `<leader>ca` | 重命名 / Code Action |
| `<leader>cf` | 手动格式化，支持 Visual 选区 |
| `<leader>uf` / `<leader>uF` | 切换全局 / 当前 buffer 自动格式化 |
| `<leader>cd` | 当前行诊断浮窗 |
| `[d` / `]d` | 上一个 / 下一个诊断 |
| `[e` / `]e` | 上一个 / 下一个错误 |
| `<leader>xx` / `<leader>xX` | Trouble 全部诊断 / 当前 buffer 诊断 |
| `<leader>cs` / `<leader>cS` | Trouble 符号面板 / LSP 列表 |
| `<leader>uh` | 切换 Inlay Hints |
| `<leader>cv` | 选择 Python 虚拟环境（Python 文件） |

LSP 映射需要 LSP server 连接到当前 buffer，部分映射仅在服务器支持对应能力时出现。

### Git、调试、测试与文档

| 按键 | 功能 |
| --- | --- |
| `<leader>gg` | 打开项目 lazygit，需要安装 `lazygit` |
| `<leader>gs` / `<leader>gd` | Git 状态 / hunks |
| `<leader>gl` / `<leader>gf` | 仓库历史 / 当前文件历史 |
| `]h` / `[h` | 下一个 / 上一个 Git hunk |
| `<leader>ghs` / `<leader>ghr` | 暂存 / 重置 hunk；重置会丢弃该块的修改 |
| `<leader>ghp` / `<leader>ghb` | 行内预览 hunk / 查看当前行详细 blame |
| `<leader>db` / `<leader>dB` | 切换断点 / 设置条件断点 |
| `<leader>dc` / `<leader>dt` | 启动或继续 / 终止调试 |
| `<leader>du` / `<leader>de` | 切换 DAP UI / 求值（求值也支持 Visual 模式） |
| `<leader>tr` / `<leader>tt` / `<leader>tT` | 运行最近测试 / 当前文件测试 / 当前工作目录测试 |
| `<leader>tl` / `<leader>td` | 重跑上次测试 / 调试最近测试 |
| `<leader>ts` / `<leader>to` / `<leader>tO` | 测试摘要 / 测试输出 / 输出面板 |
| `<leader>cp` | 切换 Markdown 浏览器预览（Markdown 文件） |
| `<leader>um` | 切换 Markdown 编辑器内渲染 |
| `<leader>D` | 切换数据库 UI；连接与数据库客户端需另行配置 |

调试器、测试框架和项目运行配置需要按语言准备；启用 DAP/Neotest 不代表任意项目都能直接运行。

### AI CLI

| 按键 | 模式/范围 | 功能 |
| --- | --- | --- |
| `Ctrl+.` | Normal、Insert、Visual、Terminal | 聚焦 Sidekick；Sidekick 内隐藏面板 |
| `<leader>aa` / `<leader>as` | Normal | 切换 CLI 面板 / 选择工具 |
| `<leader>ad` | Normal | 分离 CLI 会话 |
| `<leader>at` | Normal、Visual | 发送当前位置/选区上下文 |
| `<leader>af` | Normal | 发送当前文件上下文 |
| `<leader>av` | Visual | 发送选区 |
| `<leader>ap` | Normal、Visual | 选择提示词 |
| `Ctrl+q` | Sidekick Terminal 模式 | 进入 Normal 模式，查看 scrollback |
| `Ctrl+q` | Sidekick Normal 模式 | 隐藏终端窗口 |
| `Ctrl+z` | Sidekick Normal、Terminal 模式 | 返回之前的窗口，保留面板 |

## 常见问题

| 现象 | 排查方式 |
| --- | --- |
| 提示 `nvim` 找不到 | 确认已执行基础依赖安装，并检查开发机的 PATH 设置 |
| 图标显示为方框或乱码 | 安装 Nerd Font 后，还需在终端设置中选中该字体 |
| 首次启动插件下载或构建失败 | 在 `:Lazy` 查看失败项；检查网络和基础依赖，修复后执行 `:Lazy restore` 重试 |
| 没有补全、跳转或诊断 | 在实际项目文件中检查 `:Mason` 和 `:LspInfo`，确认工具已安装、文件类型正确、LSP server 已连接到当前 buffer |
| Treesitter parser 安装失败 | 检查 C 编译器、Tree-sitter CLI 及下载日志 |
| Markdown 预览失败 | 在 `:Lazy` 选中 `markdown-preview.nvim` 按 `gb` 构建后重试 |
| Sidekick 无法打开工具 | 确认 `tmux -V` 正常，所选 AI CLI 在同一终端能启动且已完成登录 |
| Option 或功能键没有响应 | 检查终端 Alt/Meta 设置、系统快捷键占用，以及是否需要配合 Fn |

## 更新方式

### 同步此配置仓库

```sh
cd "$HOME/.config/nvim"
git status --short --branch
git switch devbox
git pull --ff-only origin devbox
```

更新前先提交本地修改，或用 `git stash push -u` 暂存后再拉取；使用 stash 时更新后执行 `git stash pop` 并处理可能的冲突。
若分支已分叉，`--ff-only` 会停止：先检查 `git log --oneline --left-right HEAD...origin/devbox`，再决定如何合并。
同步完成后在 Neovim 中执行 `:Lazy restore` 并重启，使用仓库记录的插件版本。

### 升级插件

```vim
:Lazy check
:Lazy update
```

`check` 检查可用更新，`update` 下载升级并更新锁文件；也可在 `:Lazy` 界面操作。
当前配置开启周期更新检查，但关闭更新通知，不会因此自动升级插件。
`:Lazy sync` 会执行安装、清理和更新，适合主动同步插件状态，不用于严格复现锁文件。

升级后检查常用语言 LSP、补全、Markdown、Sidekick 和调试功能，再提交锁文件：

```sh
cd "$HOME/.config/nvim"
git diff -- lazy-lock.json
git add lazy-lock.json
git commit -m "chore: update plugin lockfile"
git push origin devbox
```

Mason 安装的外部工具不受 `lazy-lock.json` 锁定，需要在 `:Mason` 中单独管理。
新增或删除语言/功能扩展可用 `:LazyExtras`，重启后检查并一并提交 `lazyvim.json`、相关 Lua 配置及锁文件变化。

### 回退插件升级

从已知可用的配置提交恢复锁文件，再执行 `:Lazy restore` 并重启：

```sh
# 将 GOOD_COMMIT 替换为实际可用的提交号；先保存当前锁文件修改
git restore --source=GOOD_COMMIT -- lazy-lock.json
```

若升级同时修改了 Lua 配置或 Extras，也需要恢复与该锁文件匹配的配置。

## 配置目录

```text
init.lua                      入口
lazyvim.json                  启用的 LazyVim Extras
lazy-lock.json                插件版本锁文件
lua/config/lazy.lua           插件管理器引导与加载
lua/config/options.lua        全局选项、OSC52 剪贴板、Picker 和 Python LSP 选择
lua/config/keymaps.lua        自定义 Alt+j/k
lua/config/autocmds.lua       C/C++ 关闭自动格式化
lua/config/ui/                启动页 ASCII 图案和动画
lua/plugins/                  各插件的配置覆盖与快捷键
lua/plugins/lsp/clangd.lua     clangd 配置，由 lspconfig.lua 引入
markdownlint.jsonc            Markdown 检查规则
stylua.toml                   Lua 格式化规则
.gitignore                    忽略 nvim.log
```

`nvim.log` 已停止 Git 跟踪，本地生成日志不会出现在待提交修改中。
插件默认快捷键可能随版本升级变化，实际行为以 `:verbose map`、WhichKey 和当前安装版本为准。
