return {
  {
    "nvim-mini/mini.icons",
    version = "*",
    lazy = false,
    priority = 1000,
    config = function()
      require("mini.icons").setup()

      -- Compatibility with plugins expecting nvim-web-devicons
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },
}
