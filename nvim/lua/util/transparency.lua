local M = {}

local is_transparent = false
local baseline_captured = false

-- Store original highlight values
local original_colors = {}

-- All groups you want transparent
local transparent_groups = {
  -- Core editor
  "Normal",
  "NormalNC",
  "EndOfBuffer",
  "SignColumn",
  "VertSplit",
  -- "WinSeparator",
  "StatusLine",
  "StatusLineNC",
  "LineNr",
  "CursorLineNr",
  "TabLine",
  "TabLineFill",
  "TabLineSel",

  -- Floating windows
  "NormalFloat",
  "FloatTitle",

  -- blink.cmp
  -- "BlinkCmpMenu",
  -- "BlinkCmpMenuBorder",
  -- "BlinkCmpLabel",
  -- "BlinkCmpLabelDeprecated",
  -- "BlinkCmpLabelMatch",
  -- "BlinkCmpLabelDetail",
  -- "BlinkCmpLabelDescription",
  -- "BlinkCmpKind",
  -- "BlinkCmpKindText",
  -- "BlinkCmpKindMethod",
  -- "BlinkCmpKindFunction",
  -- "BlinkCmpKindConstructor",
  -- "BlinkCmpKindField",
  -- "BlinkCmpKindVariable",
  -- "BlinkCmpKindClass",
  -- "BlinkCmpKindInterface",
  -- "BlinkCmpKindModule",
  -- "BlinkCmpKindProperty",
  -- "BlinkCmpKindUnit",
  -- "BlinkCmpKindValue",
  -- "BlinkCmpKindEnum",
  -- "BlinkCmpKindKeyword",
  -- "BlinkCmpKindSnippet",
  -- "BlinkCmpKindColor",
  -- "BlinkCmpKindFile",
  -- "BlinkCmpKindReference",
  -- "BlinkCmpKindFolder",
  -- "BlinkCmpKindEnumMember",
  -- "BlinkCmpKindConstant",
  -- "BlinkCmpKindStruct",
  -- "BlinkCmpKindEvent",
  -- "BlinkCmpKindOperator",
  -- "BlinkCmpKindTypeParameter",
  -- "BlinkCmpDoc",
  -- "BlinkCmpDocBorder",
  -- "BlinkCmpDocCursorLine",
  -- "BlinkCmpDocSeparator",
  -- "BlinkCmpSignatureHelp",
  -- "BlinkCmpSignatureHelpBorder",
  -- "BlinkCmpSignatureHelpActiveParameter",
  -- "BlinkCmpGhostText",

  -- Which-key
  "WhichKey",
  "WhichKeyFloat",
  "WhichKeyBorder",
  "WhichKeyGroup",
  "WhichKeyDesc",
  "WhichKeySeparator",
  "WhichKeyValue",
  "WhichKeyNormal",

  -- Noice
  "NoicePopup",
  "NoicePopupBorder",
  "NoiceMini",
  "NoiceCmdlinePopup",
  "NoiceCmdlinePopupBorder",
  "NoiceCmdlinePopupTitle",
  "NoiceConfirm",
  "NoiceConfirmBorder",

  -- Notify
  "NotifyBackground",
  "NotifyERRORBody",
  "NotifyWARNBody",
  "NotifyINFOBody",
  "NotifyDEBUGBody",
  "NotifyTRACEBody",
  "NotifyERRORBorder",
  "NotifyWARNBorder",
  "NotifyINFOBorder",
  "NotifyDEBUGBorder",
  "NotifyTRACEBorder",
  "NotifyERRORTitle",
  "NotifyWARNTitle",
  "NotifyINFOTitle",
  "NotifyDEBUGTitle",
  "NotifyTRACETitle",
  "NotifyERRORIcon",
  "NotifyWARNIcon",
  "NotifyINFOIcon",
  "NotifyDEBUGIcon",
  "NotifyTRACEIcon",

  -- Telescope
  -- "TelescopeNormal",
  -- "TelescopeBorder",
  -- "TelescopeTitle",
  -- "TelescopePromptNormal",
  -- "TelescopePromptBorder",
  -- "TelescopePromptTitle",
  -- "TelescopePromptPrefix",
  -- "TelescopePromptCounter",
  -- "TelescopeResultsNormal",
  -- "TelescopeResultsBorder",
  -- "TelescopeResultsTitle",
  -- "TelescopePreviewNormal",
  -- "TelescopePreviewBorder",
  -- "TelescopePreviewTitle",
  -- "TelescopeSelection",
  -- "TelescopeSelectionCaret",
  -- "TelescopeMultiSelection",
  -- "TelescopeMatching",

  -- LSP
  "LspInlayHint",

  -- Pmenu fallback
  "Pmenu",
  "PmenuExtra",
  "PmenuExtraSel",

  -- Snippets
  "SnippetTabstop",
  "SnippetPassiveTabstop",
  "LuaSnipInsertNodeActive",
  "LuaSnipInsertNodePassive",
  "LuaSnipChoiceNodeActive",
  "LuaSnipChoiceNodePassive",
  "LuaSnipExitNodeActive",
  "LuaSnipExitNodePassive",
  "LuaSnipVisitedNodeActive",
  "LuaSnipVisitedNodePassive",

  -- Lazy UI (important)
  "LazyNormal",
  "LazyBorder",
}

-- Capture clean baseline (ONLY ONCE)
local function capture_baseline()
  if baseline_captured then
    return
  end

  for _, group in ipairs(transparent_groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
    if ok and hl then
      original_colors[group] = {
        fg = hl.foreground,
        bg = hl.background,
        sp = hl.special,
        reverse = hl.reverse,
        italic = hl.italic,
        bold = hl.bold,
        underline = hl.underline,
        undercurl = hl.undercurl,
        underdot = hl.underdot,
        underdash = hl.underdash,
        strikethrough = hl.strikethrough,
      }
    end
  end

  baseline_captured = true
end

function M.is_enabled()
  return is_transparent
end

function M.enable()
  if is_transparent then
    return
  end

  capture_baseline()

  for _, group in ipairs(transparent_groups) do
    local orig = original_colors[group] or {}
    vim.api.nvim_set_hl(0, group, {
      fg = orig.fg,
      bg = "NONE",
      ctermbg = "NONE",
      sp = orig.sp,
      reverse = orig.reverse,
      italic = orig.italic,
      bold = orig.bold,
      underline = orig.underline,
      undercurl = orig.undercurl,
      underdot = orig.underdot,
      underdash = orig.underdash,
      strikethrough = orig.strikethrough,
    })
  end

  is_transparent = true
end

function M.disable()
  if not is_transparent then
    return
  end

  for group, orig in pairs(original_colors) do
    vim.api.nvim_set_hl(0, group, {
      fg = orig.fg,
      bg = orig.bg,
      sp = orig.sp,
      reverse = orig.reverse,
      italic = orig.italic,
      bold = orig.bold,
      underline = orig.underline,
      undercurl = orig.undercurl,
      underdot = orig.underdot,
      underdash = orig.underdash,
      strikethrough = orig.strikethrough,
    })
  end

  is_transparent = false
end

function M.reapply()
  if not is_transparent then
    return
  end

  for _, group in ipairs(transparent_groups) do
    local orig = original_colors[group]
    if orig then
      vim.api.nvim_set_hl(0, group, {
        fg = orig.fg,
        bg = "NONE",
        ctermbg = "NONE",
        sp = orig.sp,
        reverse = orig.reverse,
        italic = orig.italic,
        bold = orig.bold,
        underline = orig.underline,
        undercurl = orig.undercurl,
        underdot = orig.underdot,
        underdash = orig.underdash,
        strikethrough = orig.strikethrough,
      })
    end
  end
end

function M.toggle()
  if is_transparent then
    M.disable()
  else
    M.enable()
  end
end

return M
