-- Gerado pelo matugen (apply-theme.sh) — colorscheme OPCIONAL com as cores do wallpaper.
-- Não altera seu setup: para usar, rode  :colorscheme matugen  (seu padrão continua catppuccin).
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.termguicolors = true
vim.o.background = "{{ mode }}"
vim.g.colors_name = "matugen"

local c = {
  bg        = "{{ colors.surface.default.hex }}",
  bg_dim    = "{{ colors.surface_container_lowest.default.hex }}",
  bg1       = "{{ colors.surface_container_low.default.hex }}",
  bg2       = "{{ colors.surface_container.default.hex }}",
  bg3       = "{{ colors.surface_container_high.default.hex }}",
  bg4       = "{{ colors.surface_container_highest.default.hex }}",
  fg        = "{{ colors.on_surface.default.hex }}",
  fg_dim    = "{{ colors.on_surface_variant.default.hex }}",
  comment   = "{{ colors.outline.default.hex }}",
  border    = "{{ colors.outline_variant.default.hex }}",
  primary   = "{{ colors.primary.default.hex }}",
  on_primary = "{{ colors.on_primary.default.hex }}",
  primary_c = "{{ colors.primary_container.default.hex }}",
  secondary = "{{ colors.secondary.default.hex }}",
  tertiary  = "{{ colors.tertiary.default.hex }}",
  red       = "{{ colors.red_source.default.hex | harmonize: {{ colors.source_color.default.hex }} }}",
  green     = "{{ colors.green_source.default.hex | harmonize: {{ colors.source_color.default.hex }} }}",
  yellow    = "{{ colors.yellow_source.default.hex | harmonize: {{ colors.source_color.default.hex }} }}",
  blue      = "{{ colors.blue_source.default.hex | harmonize: {{ colors.source_color.default.hex }} }}",
  magenta   = "{{ colors.magenta_source.default.hex | harmonize: {{ colors.source_color.default.hex }} }}",
  cyan      = "{{ colors.cyan_source.default.hex | harmonize: {{ colors.source_color.default.hex }} }}",
  orange    = "{{ colors.orange_source.default.hex | harmonize: {{ colors.source_color.default.hex }} }}",
  error     = "{{ colors.error.default.hex }}",
}

local function hl(group, opts) vim.api.nvim_set_hl(0, group, opts) end

-- Editor
hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalNC", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = c.bg2 })
hl("FloatBorder", { fg = c.border, bg = c.bg2 })
hl("FloatTitle", { fg = c.primary, bg = c.bg2, bold = true })
hl("Cursor", { fg = c.on_primary, bg = c.primary })
hl("CursorLine", { bg = c.bg1 })
hl("CursorColumn", { bg = c.bg1 })
hl("ColorColumn", { bg = c.bg1 })
hl("CursorLineNr", { fg = c.primary, bold = true })
hl("LineNr", { fg = c.comment })
hl("SignColumn", { bg = c.bg })
hl("FoldColumn", { fg = c.comment, bg = c.bg })
hl("Folded", { fg = c.fg_dim, bg = c.bg2 })
hl("VertSplit", { fg = c.border })
hl("WinSeparator", { fg = c.border })
hl("StatusLine", { fg = c.fg, bg = c.bg2 })
hl("StatusLineNC", { fg = c.fg_dim, bg = c.bg1 })
hl("TabLine", { fg = c.fg_dim, bg = c.bg1 })
hl("TabLineSel", { fg = c.on_primary, bg = c.primary, bold = true })
hl("TabLineFill", { bg = c.bg_dim })
hl("Pmenu", { fg = c.fg, bg = c.bg2 })
hl("PmenuSel", { fg = c.on_primary, bg = c.primary })
hl("PmenuSbar", { bg = c.bg3 })
hl("PmenuThumb", { bg = c.border })
hl("Visual", { bg = c.primary_c })
hl("Search", { fg = c.bg, bg = c.yellow })
hl("IncSearch", { fg = c.bg, bg = c.orange })
hl("CurSearch", { fg = c.bg, bg = c.orange })
hl("MatchParen", { fg = c.primary, bold = true, underline = true })
hl("NonText", { fg = c.border })
hl("Whitespace", { fg = c.border })
hl("SpecialKey", { fg = c.border })
hl("EndOfBuffer", { fg = c.bg })
hl("Directory", { fg = c.primary })
hl("Title", { fg = c.primary, bold = true })
hl("ErrorMsg", { fg = c.error })
hl("WarningMsg", { fg = c.yellow })
hl("MoreMsg", { fg = c.green })
hl("Question", { fg = c.blue })
hl("WildMenu", { fg = c.on_primary, bg = c.primary })

-- Sintaxe
hl("Comment", { fg = c.comment, italic = true })
hl("Constant", { fg = c.magenta })
hl("String", { fg = c.green })
hl("Character", { fg = c.green })
hl("Number", { fg = c.orange })
hl("Boolean", { fg = c.orange })
hl("Float", { fg = c.orange })
hl("Identifier", { fg = c.fg })
hl("Function", { fg = c.blue })
hl("Statement", { fg = c.primary })
hl("Keyword", { fg = c.primary, italic = true })
hl("Conditional", { fg = c.primary })
hl("Repeat", { fg = c.primary })
hl("Operator", { fg = c.fg_dim })
hl("Exception", { fg = c.red })
hl("PreProc", { fg = c.tertiary })
hl("Include", { fg = c.tertiary })
hl("Define", { fg = c.tertiary })
hl("Macro", { fg = c.tertiary })
hl("Type", { fg = c.secondary })
hl("StorageClass", { fg = c.secondary })
hl("Structure", { fg = c.secondary })
hl("Typedef", { fg = c.secondary })
hl("Special", { fg = c.cyan })
hl("Delimiter", { fg = c.fg_dim })
hl("Tag", { fg = c.primary })
hl("Underlined", { underline = true })
hl("Error", { fg = c.error })
hl("Todo", { fg = c.bg, bg = c.yellow, bold = true })

-- Diagnósticos / diff
hl("DiagnosticError", { fg = c.error })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.blue })
hl("DiagnosticHint", { fg = c.cyan })
hl("DiagnosticUnderlineError", { undercurl = true, sp = c.error })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
hl("DiffAdd", { bg = c.bg2, fg = c.green })
hl("DiffChange", { bg = c.bg2, fg = c.yellow })
hl("DiffDelete", { bg = c.bg2, fg = c.red })
hl("DiffText", { bg = c.bg3, fg = c.fg })

-- Treesitter (links para os grupos acima)
for from, to in pairs({
  ["@comment"] = "Comment", ["@string"] = "String", ["@number"] = "Number", ["@boolean"] = "Boolean",
  ["@constant"] = "Constant", ["@function"] = "Function", ["@function.call"] = "Function",
  ["@method"] = "Function", ["@keyword"] = "Keyword", ["@keyword.function"] = "Keyword",
  ["@type"] = "Type", ["@type.builtin"] = "Type", ["@variable"] = "Identifier",
  ["@property"] = "Identifier", ["@field"] = "Identifier", ["@operator"] = "Operator",
  ["@punctuation"] = "Delimiter", ["@tag"] = "Tag", ["@constructor"] = "Type",
}) do hl(from, { link = to }) end
