return {

  -- gopls with build tags
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              buildFlags = { "-tags=unit_test" },
            },
          },
        },
      },
    },
  },

  -- neotest + neotest-golang
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "fredrikaverpil/neotest-golang",
      {
        "nvim-treesitter/nvim-treesitter",
        build = function()
          vim.cmd("TSUpdate go")
        end,
      },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang")({
            runner = "gotestsum",
            go_test_args = { "-tags=unit_test" },
          }),
        },
      })
    end,
    keys = {
      {
        "<leader>tt",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run Test File",
      },
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest Test",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Test Summary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true })
        end,
        desc = "Test Output",
      },
    },
  },

  -- dap + dap-ui + dap-go
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      dap.listeners.after.event_initialized["dapui"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui"] = function()
        dapui.close()
      end

      -------------------------------------------------------------------
      -- ✔ The ONLY correct dap-go setup (based on the README)
      -------------------------------------------------------------------
      require("dap-go").setup({
        delve = {
          build_flags = { "-tags=unit_test" }, -- REAL documented API
          initialize_timeout_sec = 20,
        },

        dap_configurations = {
          {
            type = "go",
            name = "Debug Package",
            request = "launch",
            mode = "test",
            program = "${fileDirname}", -- EXACTLY as plugin expects
            buildFlags = "-tags=unit_test",
          },
        },

        tests = {
          verbose = false,
        },
      })
    end,

    keys = {
      -- Debug nearest test (OFFICIAL API)
      {
        "<leader>dt",
        function()
          require("dap-go").debug_test()
        end,
        desc = "Debug Nearest Test",
      },

      -- Debug last test
      {
        "<leader>dl",
        function()
          require("dap-go").debug_last_test()
        end,
        desc = "Debug Last Test",
      },

      -- Smart debug: tests or program
      {
        "<leader>dd",
        function()
          if vim.fn.expand("%"):match("_test%.go$") then
            require("dap-go").debug_test()
          else
            require("dap").continue()
          end
        end,
        desc = "Debug (Smart)",
      },

      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
    },
  },
}
