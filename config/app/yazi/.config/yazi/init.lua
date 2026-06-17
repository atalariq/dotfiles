-- ./plugins/folder-rules.yazi/main.lua
require("folder-rules"):setup()

-- https://github.com/uhs-robert/recycle-bin.yazi
require("recycle-bin"):setup()

-- https://github.com/boydaihungst/restore.yazi
require("restore"):setup({
	-- Set the position for confirm and overwrite prompts.
	-- Don't forget to set height: `h = xx`
	-- https://yazi-rs.github.io/docs/plugins/utils/#ya.input
	position = { "center", w = 70, h = 40 }, -- Optional

	-- Show confirm prompt before restore.
	-- NOTE: even if set this to false, overwrite prompt still pop up
	show_confirm = true, -- Optional

	-- Suppress success notification when all files or folder are restored.
	suppress_success_notification = true, -- Optional

	-- colors for confirm and overwrite prompts
	theme = { -- Optional
		-- Default using style from your flavor or theme.lua -> [confirm] -> title.
		-- If you edit flavor or theme.lua you can add more style than just color.
		-- Example in theme.lua -> [confirm]: title = { fg = "blue", bg = "green"  }
		title = "blue", -- Optional. This value has higher priority than flavor/theme.lua

		-- Default using style from your flavor or theme.lua -> [confirm] -> content
		-- Sample logic as title above
		header = "green", -- Optional. This value has higher priority than flavor/theme.lua

		-- header color for overwrite prompt
		-- Default using color "yellow"
		header_warning = "yellow", -- Optional
		-- Default using style from your flavor or theme.lua -> [confirm] -> list
		-- Sample logic as title and header above
		list_item = { odd = "blue", even = "blue" }, -- Optional. This value has higher priority than flavor/theme.lua
	},
})

-- https://github.com/Rolv-Apneseth/starship.yazi
require("starship"):setup({
	-- Hide flags (such as filter, find and search). This can be beneficial for starship themes
	-- which are intended to go across the entire width of the terminal.
	hide_flags = false,
	-- Whether to place flags after the starship prompt. False means the flags will be placed before the prompt.
	flags_after_prompt = true,
	-- Custom starship configuration file to use
	config_file = "~/.config/starship_full.toml", -- Default: nil
	-- Whether to enable support for starship's right prompt (i.e. `starship prompt --right`).
	show_right_prompt = false,
	-- Whether to hide the count widget, in case you want only your right prompt to show up. Only has
	-- an effect when `show_right_prompt = true`
	hide_count = false,
	-- Separator to place between the right prompt and the count widget. Use `count_separator = ""`
	-- to have no space between the widgets.
	count_separator = " ",
})

local old_build = Tab.build

Tab.build = function(self, ...)
	local bar = function(c, x, y)
		if x <= 0 or x == self._area.w - 1 then
			return ui.Bar(ui.Edge.TOP)
		end

		return ui.Bar(ui.Edge.TOP)
			:area(ui.Rect({
				x = x,
				y = math.max(0, y),
				w = ya.clamp(0, self._area.w - x, 1),
				h = math.min(1, self._area.h),
			}))
			:symbol(c)
	end

	local c = self._chunks
	self._chunks = {
		c[1]:pad(ui.Pad.y(1)),
		c[2]:pad(ui.Pad.y(1)),
		c[3]:pad(ui.Pad.y(1)),
	}

	self._base = ya.list_merge(self._base or {}, {
		bar("┬", c[2].x, c[1].y),
		bar("┴", c[2].x, c[1].bottom - 1),
		bar("┬", c[2].right - 1, c[2].y),
		bar("┴", c[2].right - 1, c[2].bottom - 1),
	})

	old_build(self, ...)
end

-- ------------------------------------------------------------------------------

-- https://yazi-rs.github.io/docs/tips/#username-hostname-in-header
Header:children_add(function()
	if ya.target_family() ~= "unix" then
		return ""
	end
	return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
end, 500, Header.LEFT)

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
