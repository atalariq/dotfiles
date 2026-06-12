require("save-clipboard-to-file"):setup({
	input_position = { "center", w = 70 },
	overwrite_confirm_position = { "center", w = 70, h = 10 },
	hide_notify = false,
})

require("spot"):setup({
	metadata_section = {
		enable = true,
		hash_cmd = "xxhsum", -- other hashing commands may be slower
		hash_filesize_limit = 150, -- in MB, set 0 to disable
		relative_time = true, -- 2026-01-01 or n days ago
		time_format = "%Y-%m-%d %H:%M", -- https://www.man7.org/linux/man-pages/man3/strftime.3.html
		show_compression = "size", ---@type false|"size"|"percentage"
	},
	plugins_section = {
		enable = true,
	},
	style = {
		section = "green",
		key = "reset",
		value = "blue",
		selected = "blue",
		colorize_metadata = true,
		height = 20,
		width = 60,
		key_length = 15,
	},
})

require("starship"):setup({
	hide_flags = false,
	flags_after_prompt = true,
	config_file = "~/.config/starship.toml",
	show_right_prompt = false,
	hide_count = false,
	count_separator = " ",
})

-- https://yazi-rs.github.io/docs/tips/#symlink-in-status
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)

-- https://yazi-rs.github.io/docs/tips/#user-group-in-status
Status:children_add(function()
	local h = cx.active.current.hovered
	if not h or ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Line({
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	})
end, 500, Status.RIGHT)
