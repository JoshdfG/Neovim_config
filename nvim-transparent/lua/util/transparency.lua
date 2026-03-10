-- lua/utils/transparency.lua

local M = {}
local is_transparent = false -- Global state to track transparency status

-- Define the highlight groups that should have a transparent background.
local transparent_groups = {
  "Normal",
  "NormalNC",
  "EndOfBuffer",
  "SignColumn",
  "VertSplit",
  "StatusLine",
  "LineNr",
  -- "CursorLine",
  -- "Visual",
  -- "VisualNOS",
  "CmpItemAbbrMatch",
  "CmpItemAbbrMatchFuzzy",
  "LuaSnipInsertNodePassive",
  "LuaSnipChoiceNodePassive",
}

-- Table to store original background colors for restoration.
local original_colors = {}

--- @brief Returns true if custom transparency is currently enabled.
function M.is_enabled()
  return is_transparent
end

--- @brief Applies transparency to specified highlight groups.
-- It stores original colors before making groups transparent.
function M.enable()
  if is_transparent then
    return
  end

  -- Store original colors before setting to NONE
  for _, group in ipairs(transparent_groups) do
    local current_hl = vim.api.nvim_get_hl(0, { name = group })
    original_colors[group] = {
      fg = current_hl.foreground,
      bg = current_hl.background,
      sp = current_hl.special,
      reverse = current_hl.reverse,
      italic = current_hl.italic,
      bold = current_hl.bold,
      underline = current_hl.underline,
      undercurl = current_hl.undercurl,
      underdot = current_hl.underdot,
      underdash = current_hl.underdash,
      strikethrough = current_hl.strikethrough,
    }
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
  is_transparent = true
  vim.notify("Transparency enabled", vim.log.levels.INFO)
end

--- @brief Disables transparency and restores original background colors.
-- If original colors aren't stored, it resets the highlight group.
function M.disable()
  if not is_transparent then
    return
  end

  -- Restore original colors
  for _, group in ipairs(transparent_groups) do
    local orig = original_colors[group]
    if orig then
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
    else
      -- Fallback: Reset to default if original color wasn't captured
      vim.api.nvim_set_hl(0, group, {})
    end
  end
  is_transparent = false
  vim.notify("Transparency disabled", vim.log.levels.INFO)
end

--- @brief Toggles transparency on or off based on the current state.
function M.toggle()
  if is_transparent then
    M.disable()
  else
    M.enable()
  end
end

return M
