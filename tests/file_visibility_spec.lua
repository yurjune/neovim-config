local assert = require("luassert")

local file_visibility = require("etc.file-visibility")
local adapter_name = "etc.file-visibility.oil-adapter"

describe("File visibility Oil adapter", function()
  local rules_file = file_visibility.ignore_file
  local current_dir, root

  before_each(function()
    local tmp = vim.fn.tempname()
    vim.fn.mkdir(tmp, "p")
    root = assert(vim.uv.fs_realpath(tmp))
    current_dir = nil
  end)

  after_each(function()
    file_visibility.ignore_file = rules_file
    package.loaded[adapter_name] = nil
    package.loaded["oil"] = nil
    vim.fn.delete(root, "rf")
  end)

  -- Reloads the adapter so it parses the given rules instead of the shared file. The adapter asks Oil only for the open
  -- directory, so a fake module that returns current_dir is enough.
  local function load(rules)
    if rules then
      local path = root .. "/rules.ignore"
      vim.fn.writefile(rules, path)
      file_visibility.ignore_file = path
    end
    package.loaded[adapter_name] = nil
    package.loaded["oil"] = {
      get_current_dir = function()
        return current_dir
      end,
    }
    return require(adapter_name)
  end

  local function entries(directories, files)
    current_dir = root .. "/listing"
    for _, name in ipairs(directories) do
      vim.fn.mkdir(current_dir .. "/" .. name, "p")
    end
    vim.fn.mkdir(current_dir, "p")
    for _, name in ipairs(files) do
      vim.fn.writefile({}, current_dir .. "/" .. name)
    end
  end

  describe("rule matching", function()
    it("matches any run of characters with *", function()
      local adapter = load({ "*.log" })
      assert.is_true(adapter.is_hidden_file("app.log"))
      assert.is_false(adapter.is_hidden_file("app.logs"))
    end)

    it("matches exactly one character with ?", function()
      local adapter = load({ "?.tmp" })
      assert.is_true(adapter.is_hidden_file("a.tmp"))
      assert.is_false(adapter.is_hidden_file("ab.tmp"))
    end)

    it("treats other characters literally", function()
      local adapter = load({ "a.b-c" })
      assert.is_true(adapter.is_hidden_file("a.b-c"))
      assert.is_false(adapter.is_hidden_file("axb-c"))
    end)

    it("leaves a name that no rule matches visible", function()
      local adapter = load({ "*.log" })
      assert.is_false(adapter.is_hidden_file("README.md"))
    end)

    it("ignores blank lines and comments", function()
      local adapter = load({ "", "# *.md", "  " })
      assert.is_false(adapter.is_hidden_file("README.md"))
    end)

    it("lets the last matching rule win", function()
      local adapter = load({ ".*", "!.env*" })
      assert.is_false(adapter.is_hidden_file(".env.local"))
      assert.is_true(adapter.is_hidden_file(".git"))

      adapter = load({ "!.env*", ".*" })
      assert.is_true(adapter.is_hidden_file(".env.local"))
    end)

    it("rejects path patterns and character classes", function()
      assert.has_error(function()
        load({ "src/main" })
      end)
      assert.has_error(function()
        load({ "[ab].log" })
      end)
    end)
  end)

  describe("directory-only rules", function()
    it("apply to a directory but not to a file of the same name", function()
      entries({ "build" }, { "out" })
      local adapter = load({ "build/", "out/" })
      assert.is_true(adapter.is_hidden_file("build"))
      assert.is_false(adapter.is_hidden_file("out"))
    end)

    it("can make a directory visible while a broader rule hides files", function()
      entries({ ".agents" }, { ".agentsrc" })
      local adapter = load({ ".*", "!.agents/", "!.agentsrc/" })
      assert.is_false(adapter.is_hidden_file(".agents"))
      assert.is_true(adapter.is_hidden_file(".agentsrc"))
    end)

    it("do not apply when Oil has no local directory", function()
      current_dir = nil
      local adapter = load({ "build/" })
      assert.is_false(adapter.is_hidden_file("build"))
    end)
  end)

  describe("shared rules", function()
    it("hide dotfiles except the listed exceptions", function()
      entries({ ".agents", ".git" }, { ".luarc.json", ".DS_Store" })
      local adapter = load()
      assert.is_false(adapter.is_hidden_file(".agents"))
      assert.is_false(adapter.is_hidden_file(".luarc.json"))
      assert.is_true(adapter.is_hidden_file(".git"))
      assert.is_true(adapter.is_hidden_file(".DS_Store"))
    end)

    it("hide dependency and build directories", function()
      entries({ "node_modules", "dist" }, { "README.md" })
      local adapter = load()
      assert.is_true(adapter.is_hidden_file("node_modules"))
      assert.is_true(adapter.is_hidden_file("dist"))
      assert.is_false(adapter.is_hidden_file("README.md"))
    end)
  end)
end)
