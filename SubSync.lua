-- "SubSync.lua"

function descriptor()
	return {
		title = "VLC Extension - Basic structure", --Subtitles Synchronizer
		version = "1.0",
		author = "EyalKT",
		url = 'http://',
		shortdesc = "SubSync",
		description = "Simplifies Subtitles Synchronization",
		capabilities = {"menu"} --{"input-listener", "meta-listener", "playing-listener"}
	}
end

function activate()
	-- this is where extension starts
	create_dialog()
end
function deactivate()
	-- what should be done on deactivation of extension
end
function close()
	-- function triggered on dialog box close event
	-- for example to deactivate extension on dialog box close:
	vlc.deactivate()
end

function menu()
	return {"About"}
end

-- Function triggered when an element from the menu is selected
function trigger_menu(id)
	if(id == 1) then
		openAboutDialog()
	end
	-- elseif(id == 2) then
	-- 	--Menu_action2()
	-- end
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
end

-- function input_changed()
-- 	-- related to capabilities={"input-listener"} in descriptor()
-- 	-- triggered by Start/Stop media input event
-- end
-- function playing_changed()
-- 	-- related to capabilities={"playing-listener"} in descriptor()
-- 	-- triggered by Pause/Play madia input event
-- end
-- function meta_changed()
-- 	-- related to capabilities={"meta-listener"} in descriptor()
-- 	-- triggered by available media input meta data?
-- end


-- Custom part, Dialog box example: -------------------------

function create_dialog()
	current_input_object = nil --initInput() -- vlc.object.input()
	selected_subtitle_time = nil
	selected_drop_time = nil
	time_difference = nil
	curr_delay = nil
	d = vlc.dialog("SubSync")
	w1 = d:add_label("Catch a subtitle line", 1, 1, 3, 1)
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
	selected_subtitle_time = vlc.var.get(current_input_object, "time")
	vlc.msg.dbg("selected subtitle line (time): " .. selected_subtitle_time)
	-- retriveLine()
	w1:set_text("Now, Release at the desired time")
end

function click_Release()
	if selected_subtitle_time == nil or current_input_object == nil then
		w1:set_text("First , catch a subtitle line!")
		return
	end
	curr_delay = vlc.var.get(current_input_object, 'spu-delay')
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

-- ////////////////////////TODO///////////////////////////////////

-- display selected line
-- fine-tune delay after drop
-- remember delay
-- about app and manual
-- translate extension
