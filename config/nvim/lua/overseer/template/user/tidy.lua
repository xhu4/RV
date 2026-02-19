return {
  generator = function()
    return {
      {
        name = "clang tidy diff",
        builder = function()
          return {
            name = "t.tidy.diff",
            cmd = { "bash", "-lc", "t.tidy.diff" },
            components = {
              { "on_output_quickfix", open = false, set_diagnostics = true },
              "default",
              "restart_on_save",
            },
          }
        end,
      },
      {
        name = "clang tidy diff fix",
        builder = function()
          return {
            name = "t.tidy.diff -fix",
            cmd = { "bash", "-lc", "t.tidy.diff -fix" },
            components = {
              { "on_output_quickfix", open = false, set_diagnostics = false },
              "default",
              "restart_on_save",
            },
          }
        end,
      },
    }
  end,
}
