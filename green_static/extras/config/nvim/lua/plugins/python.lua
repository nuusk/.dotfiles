return {
  -- LSP: Ruff (replaces Pyright)
  -- Ruff provides linting, formatting, and basic type checking in one tool
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff = {
          -- Ruff LSP handles linting and formatting
          init_options = {
            settings = {
              -- Use ruff for everything
              lint = { enable = true },
              format = { enable = true },
            },
          },
        },
        pyright = false,
      },
    },
  },

  -- Install tools via Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "ruff", -- All-in-one: linting + formatting
      })
    end,
  },

  -- Format with Ruff
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
      },
    },
  },

  -- Lint with Ruff (integrated with LSP above, but explicit config for nvim-lint)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "ruff" },
      },
    },
  },
}
