--- @sync entry
local function entry()
	if #cx.tabs < 2 then
		return ya.emit("quit", {})
	end

	-- Run on the main thread so quitting does not wait on this plugin as a task.
	ya.async(function()
		local yes = ya.confirm({
			pos = { "center", w = 62, h = 10 },
			title = "Quit?",
			body = ui.Text("There are multiple tabs open. Are you sure you want to quit?"):wrap(ui.Wrap.YES),
		})
		if yes then
			ya.emit("quit", {})
		end
	end)
end

return { entry = entry }
