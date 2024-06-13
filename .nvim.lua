if not vim.g.vscode then
	local function get_current_target()
		local head = "//" .. vim.fn.expand("%:h")
		local file_label = head .. ":" .. vim.fn.expand("%:t")
		local query_cmd = function(attr)
			return { "bazel", "query", string.format("'attr('%s', %s, %s)'", attr, file_label, head .. "/...") }
		end
		local target = vim.system(query_cmd("srcs"), { stderr = false }):wait().stdout
		if target == nil or target == "" then
			target = vim.system(query_cmd("hdrs"), { stderr = false }):wait().stdout
		end
		return target
	end

	local function make_bazel(mode)
		return function(args)
			local command = table.concat({
				"Dispatch",
				"bazel",
				mode,
				"--noshow_progress",
				"--",
				(args.bang and "//%:h/..." or get_current_target()),
			}, " ") .. (table.concat(args.fargs, " ") or "")
			vim.cmd(command)
		end
	end

	vim.api.nvim_create_user_command("Target", function()
		vim.print(get_current_target())
	end, {})
	vim.api.nvim_create_user_command(
		"Build",
		make_bazel("build"),
		{ bang = true, desc = "Build the current target (or dir with !)" }
	)
	vim.api.nvim_create_user_command(
		"Run",
		make_bazel("run"),
		{ bang = true, desc = "Run the current target (or dir with !)" }
	)
	vim.api.nvim_create_user_command(
		"Test",
		make_bazel("test"),
		{ bang = true, desc = "Test the current target (or dir with !)" }
	)
	vim.api.nvim_create_user_command("Tidy", function(args)
		vim.cmd("Dispatch tidybatch -C .clang-tidy-earlyadopters check " .. (args.bang and "%:h" or "%"))
	end, { bang = true, desc = "Run tidybatch on the current file (or dir with !)" })
	vim.api.nvim_create_user_command("Cprt", function()
		vim.api.nvim_set_current_line(
			string.format("Aurora Innovation, Inc. Proprietary and Confidential. Copyright %s.", os.date("*t").year)
		)
		require("Comment.api").toggle.linewise.current()
	end, {})
	vim.api.nvim_create_user_command("Incl", function()
		local fname = vim.fn.expand("%:t:r")
		local ext = vim.fn.expand("%:e")
		if fname:match("_test$") then
			fname = string.sub(fname, 1, -6)
		end
		vim.api.nvim_set_current_line(string.format('#include "%s/%s.hh"', vim.fn.expand("%:h"), fname))
	end, {})
	vim.api.nvim_create_user_command("UpdateTarget", function(args)
		vim.cmd(
			"Start! /home/xihu/av/experimental/xihu/tools/bazel/update_build.py %"
				.. (args.bang and " --force_bquery" or "")
		)
	end, { bang = true, desc = "Update the BUILD file for the current target (force bazel query with !)" })

	vim.keymap.set("n", "mt", "<cmd>Test<CR>")
	vim.keymap.set("n", "mb", "<cmd>Build<CR>")
	vim.keymap.set("n", "mu", "<cmd>UpdateTarget<CR>")
	vim.keymap.set("n", "md", "<cmd>Tidy<CR>")
	vim.keymap.set("n", "mT", "<cmd>Test!<CR>")
	vim.keymap.set("n", "mB", "<cmd>Build!<CR>")
	vim.keymap.set("n", "mU", "<cmd>UpdateTarget!<CR>")
	vim.keymap.set("n", "mD", "<cmd>Tidy!<CR>")
end

vim.keymap.set("n", "gb", function()
	local filename = vim.fn.expand("%:t")
	vim.cmd("e %:h/BUILD")
	vim.cmd("/" .. filename)
	vim.cmd("nohls")
end, { desc = "[G]o to [B]UILD file" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "cpp",
	desc = "Cpp surroundings",
	group = vim.api.nvim_create_augroup("cpp-surroundings", { clear = true }),
	callback = function()
		local function f_surround(fname)
			return {
				input = { fname .. "%b()", "^" .. fname .. "%(().*()%)$" },
				output = { left = fname .. "(", right = ")" },
			}
		end

		vim.b.minisurround_config = {
			custom_surroundings = {
				["r"] = f_surround("RETURN_OR_ASSIGN"),
				["R"] = f_surround("RETURN_IF_NOT_OK"),
				["c"] = f_surround("CHECKED_RESULT"),
				["C"] = f_surround("CHECK_STATUS_OK"),
				["a"] = f_surround("ASSERT_RESULT"),
				["A"] = f_surround("ASSERT_STATUS_OK"),
				["i"] = f_surround("make_in_out"),
				["o"] = f_surround("make_out"),
			},
		}
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "cpp",
	desc = "Cpp settings",
	group = vim.api.nvim_create_augroup("cpp-settings", { clear = true }),
	callback = function()
		vim.keymap.set({ "n", "i" }, "<M-o>", function()
			local ext = vim.fn.expand("%:e")
			local dest_ext = ""
			if ext == "hh" then
				dest_ext = "cc"
			elseif ext == "cc" then
				dest_ext = "hh"
			else
				print("Cannot jump to src/hdr file with ext: " .. ext)
				return
			end
			vim.cmd("e %:r." .. dest_ext)
		end)
	end,
})

-- vim: ts=2 sts=2 sw=2 et
