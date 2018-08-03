
-- "SubSync.lua"

local curr_version = "1.0"

function descriptor()
	return {
		title = "SubSync - " .. curr_version,
		version = curr_version,
		author = "EyalKT",
		url = 'https://github.com/eyalkt/vlc-subtitles-sync',
		shortdesc = "SubSync",
		description = "Simplifies Subtitles Synchronization",
		capabilities = {"menu"} --{"input-listener", "meta-listener", "playing-listener"}
	}
end

function activate() -- this is where extension starts
	about = false
	create_dialog()
end
function deactivate()
	-- what should be done on deactivation of extension
end
function close() -- function triggered on dialog box close event
	if about then
		about = false
		d = nil
		collectgarbage()
		create_dialog()
	else vlc.deactivate() end
end

-- menu -------------------------------------

function menu()
	return {"About"}
end

function trigger_menu(id) -- Function triggered when an element from the menu is selected
	if(id == 1) then
		openAboutDialog()
	end
end

function openAboutDialog ()
	local about_msg = "hi"
	if d ~= nil then 
		d:hide() 
	end
	d = nil
	collectgarbage()
	d = vlc.dialog("SubSync - about")
	details_w = d:add_html(about_msg)
	about = true
end


-- extension logic  -------------------------

function create_dialog()
	current_input_object = nil
	selected_subtitle_time = nil
	selected_drop_time = nil
	time_difference = nil
	curr_delay = nil
	d = vlc.dialog("SubSync")
	w1 = d:add_label(styleMsgBold("Catch") .. " a subtitle line", 1, 1, 3, 1)
	-- w2 - html - selected line
	w3 = d:add_button("Catch",click_Catch, 1, 3, 1, 1)
	w4 = d:add_button("Release!",click_Release, 2, 3, 1, 1)
end

function click_Catch()
	current_input_object = vlc.object.input()
	if not vlc.input.is_playing() then 
		w1:set_text("No media found")
		return 
	end
	released = false
	selected_subtitle_time = vlc.var.get(current_input_object, "time")
	vlc.msg.dbg("selected subtitle line (time): " .. selected_subtitle_time)
	-- retriveLine()
	w1:set_text("Now, " .. styleMsgBold("Release") .. " at the desired time")
end

function click_Release()
	if selected_subtitle_time == nil or current_input_object == nil then
		w1:set_text("First , " .. styleMsgBold("catch") .. " a subtitle line!")
		return
	end
	if released then curr_delay = 0
	else curr_delay = vlc.var.get(current_input_object, 'spu-delay') end
	released = true
	-- curr_delay = vlc.var.get(current_input_object, 'spu-delay')
	selected_drop_time = vlc.var.get(current_input_object, "time")
	vlc.msg.dbg("selected drop time: " .. selected_drop_time)
	time_difference = selected_drop_time - selected_subtitle_time + curr_delay
	vlc.msg.dbg("difference between selected line and drop time: " .. time_difference)
	w1:set_text(styleMsgGood("Thats it!") .. " , Wait for playback to resume")
	vlc.msg.dbg("setting subtitles delay: " .. time_difference)
	vlc.var.set(current_input_object, 'spu-delay', time_difference)
end

function styleMsgGood (msg)
	return "<span style='color:green;font-weight:bold'>" .. msg .. "</span>"
end

function styleMsgBold (msg)
	return "<span style='font-weight:bold'>" .. msg .. "</span>"
end

-- ////////////////////////TODO///////////////////////////////////
-- ordered - easy first

-- about app and manual
-- add checkbox - pause on catch (helps remembering the selected subtitle's line)
-- remember delay
-- fine-tune delay after drop
-- translate extension
-- display selected line
