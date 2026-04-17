local palette = {
  bg = "#0a0e17",
  bg_card = "#111827",
  bg_muted = "#1a2332",
  fg = "#80ffcc",
  fg_dim = "#3d6b5a",
  primary = "#00ff80",
  accent = "#00e5ff",
  secondary = "#bf5af2",
  red = "#ff453a",
  yellow = "#ffd60a",
  border = "#0d3326",
}

return {
  {
    "folke/tokyonight.nvim",
    opts = function(_, opts)
      opts.style = "night"
      opts.transparent = false
      opts.terminal_colors = true
      opts.on_colors = function(colors)
        colors.bg = palette.bg
        colors.bg_dark = palette.bg
        colors.bg_float = palette.bg_card
        colors.bg_popup = palette.bg_card
        colors.bg_sidebar = palette.bg
        colors.bg_statusline = palette.bg
        colors.bg_highlight = palette.bg_muted
        colors.bg_visual = palette.bg_muted
        colors.border = palette.border
        colors.border_highlight = palette.primary
        colors.fg = palette.fg
        colors.fg_dark = palette.fg_dim
        colors.fg_float = palette.fg
        colors.fg_sidebar = palette.fg
        colors.comment = palette.fg_dim
        colors.green = palette.primary
        colors.blue = palette.accent
        colors.cyan = palette.accent
        colors.magenta = palette.secondary
        colors.purple = palette.secondary
        colors.red = palette.red
        colors.yellow = palette.yellow
        colors.orange = palette.yellow
        colors.git = {
          add = palette.primary,
          change = palette.accent,
          delete = palette.red,
        }
      end
      opts.on_highlights = function(hl, colors)
        hl.Normal = { bg = palette.bg, fg = palette.fg }
        hl.NormalNC = { bg = palette.bg, fg = palette.fg }
        hl.NormalSB = { bg = palette.bg, fg = palette.fg }
        hl.SignColumn = { bg = palette.bg, fg = palette.fg_dim }
        hl.SignColumnSB = { bg = palette.bg, fg = palette.fg_dim }
        hl.FoldColumn = { bg = palette.bg, fg = palette.fg_dim }
        hl.EndOfBuffer = { bg = palette.bg, fg = palette.bg }
        hl.NormalFloat = { bg = palette.bg_card, fg = palette.fg }
        hl.FloatBorder = { bg = palette.bg_card, fg = palette.accent }
        hl.FloatTitle = { bg = palette.bg_card, fg = palette.primary, bold = true }
        hl.WinSeparator = { fg = palette.border }
        hl.LineNr = { fg = palette.fg_dim }
        hl.CursorLineNr = { fg = palette.primary, bold = true }
        hl.CursorLine = { bg = palette.bg_muted }
        hl.Visual = { bg = palette.bg_muted }
        hl.Search = { bg = palette.accent, fg = palette.bg }
        hl.IncSearch = { bg = palette.primary, fg = palette.bg }
        hl.StatusLine = { bg = palette.bg_card, fg = palette.fg }
        hl.StatusLineNC = { bg = palette.bg, fg = palette.fg_dim }
        hl.Pmenu = { bg = palette.bg_card, fg = palette.fg }
        hl.PmenuSel = { bg = palette.bg_muted, fg = palette.primary, bold = true }
        hl.PmenuSbar = { bg = palette.bg_muted }
        hl.PmenuThumb = { bg = palette.border }
        hl.VertSplit = { fg = palette.border }
        hl.Directory = { fg = palette.accent }
        hl.Comment = { fg = palette.fg_dim, italic = true }
        hl.Keyword = { fg = palette.secondary }
        hl.Function = { fg = palette.primary }
        hl.String = { fg = palette.accent }
        hl.Constant = { fg = palette.yellow }
        hl.Type = { fg = palette.secondary }
        hl.DiagnosticError = { fg = palette.red }
        hl.DiagnosticWarn = { fg = palette.yellow }
        hl.DiagnosticInfo = { fg = palette.accent }
        hl.DiagnosticHint = { fg = palette.primary }
        hl.NeoTreeNormal = { bg = palette.bg, fg = palette.fg }
        hl.NeoTreeNormalNC = { bg = palette.bg, fg = palette.fg }
        hl.NeoTreeSignColumn = { bg = palette.bg, fg = palette.fg_dim }
        hl.NeoTreeSignColumnNC = { bg = palette.bg, fg = palette.fg_dim }
        hl.NeoTreeStatusLine = { bg = palette.bg, fg = palette.fg }
        hl.NeoTreeStatusLineNC = { bg = palette.bg, fg = palette.fg_dim }
        hl.NeoTreeEndOfBuffer = { bg = palette.bg, fg = palette.bg }
        hl.NeoTreeWinSeparator = { bg = palette.bg, fg = palette.border }
        hl.NeoTreeCursorLine = { bg = palette.bg }
        hl.NeoTreeCursorLineNr = { bg = palette.bg, fg = palette.primary, bold = true }
        hl.NvimTreeNormal = { bg = palette.bg, fg = palette.fg }
        hl.NvimTreeNormalNC = { bg = palette.bg, fg = palette.fg }
        hl.NvimTreeEndOfBuffer = { bg = palette.bg, fg = palette.bg }
        hl.SnacksNormal = { bg = palette.bg, fg = palette.fg }
        hl.SnacksNormalNC = { bg = palette.bg, fg = palette.fg }
        hl.TelescopeNormal = { bg = palette.bg_card, fg = palette.fg }
        hl.TelescopeBorder = { bg = palette.bg_card, fg = palette.border }
        hl.TelescopePromptNormal = { bg = palette.bg_muted, fg = palette.fg }
        hl.TelescopePromptBorder = { bg = palette.bg_muted, fg = palette.primary }
        hl.TelescopePromptTitle = { bg = palette.primary, fg = palette.bg, bold = true }
        hl.TelescopePreviewTitle = { bg = palette.accent, fg = palette.bg, bold = true }
        hl.TelescopeResultsTitle = { bg = palette.secondary, fg = palette.bg, bold = true }
      end
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = {
        normal = {
          a = { bg = palette.primary, fg = palette.bg, bold = true },
          b = { bg = palette.bg_card, fg = palette.fg },
          c = { bg = palette.bg, fg = palette.fg_dim },
        },
        insert = {
          a = { bg = palette.accent, fg = palette.bg, bold = true },
          b = { bg = palette.bg_card, fg = palette.fg },
          c = { bg = palette.bg, fg = palette.fg_dim },
        },
        visual = {
          a = { bg = palette.secondary, fg = palette.bg, bold = true },
          b = { bg = palette.bg_card, fg = palette.fg },
          c = { bg = palette.bg, fg = palette.fg_dim },
        },
        replace = {
          a = { bg = palette.red, fg = palette.bg, bold = true },
          b = { bg = palette.bg_card, fg = palette.fg },
          c = { bg = palette.bg, fg = palette.fg_dim },
        },
        command = {
          a = { bg = palette.yellow, fg = palette.bg, bold = true },
          b = { bg = palette.bg_card, fg = palette.fg },
          c = { bg = palette.bg, fg = palette.fg_dim },
        },
        inactive = {
          a = { bg = palette.bg_muted, fg = palette.fg_dim },
          b = { bg = palette.bg, fg = palette.fg_dim },
          c = { bg = palette.bg, fg = palette.fg_dim },
        },
      }
    end,
  },

  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.highlights = {
        fill = { bg = palette.bg },
        background = { bg = palette.bg, fg = palette.fg_dim },
        buffer_selected = { bg = palette.bg_card, fg = palette.fg, bold = true },
        tab_selected = { bg = palette.bg_card, fg = palette.fg, bold = true },
        separator = { bg = palette.bg, fg = palette.border },
        separator_selected = { bg = palette.bg_card, fg = palette.border },
        indicator_selected = { fg = palette.primary, bg = palette.bg_card },
        modified = { bg = palette.bg, fg = palette.accent },
        modified_selected = { bg = palette.bg_card, fg = palette.accent },
        close_button = { bg = palette.bg, fg = palette.fg_dim },
        close_button_selected = { bg = palette.bg_card, fg = palette.red },
      }
    end,
  },
}
