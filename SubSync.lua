
-- "SubSync.lua"

-- MIT License
-- 
-- Copyright (c) 2018 Eyal Katz Talmon
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

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
	vlc.msg.dbg("starting SubSync")
	create_dialog()
end
function deactivate() -- what should be done on deactivation of extension
	vlc.msg.dbg("exiting SubSync")
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
	local about_msg = 
			descriptor()["title"] .. "<br><br>" .. 
			"Easily synchronize subtitles to media, using \"catch\" and \"release\"." .. "<br>" ..
			"First, load media (movie, song ...) and subtitles (you can use VLsub addon for that), then," .. "<br>" ..
			styleMsgBold("Catch") .. " a subtitle line, by clicking the 'Catch' button when the line appears, and" .. "<br>" ..
			styleMsgBold("Release") .. " the line at the correct time." .. "<br>" ..
			"You can fix the released time by clicking \"Release\" again." .. "<br><br>" ..
			"Author: Eyal Katz Talmon" .. "<br>" ..
			"Websites: " .. createWebLink(descriptor()["url"], "GitHub page") .. "  " ..
											createWebLink("https://addons.videolan.org/p/1251951/", "Addon page") .. "<br>"
	if d ~= nil then
		d:hide()
	end
	d = nil
	collectgarbage()
	d = vlc.dialog("SubSync - about")
	details_w = d:add_html(about_msg, 1, 1, 4, 1)
	width_w = d:add_label(string.rep ("&nbsp;", 100)) -- to widen the about window
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

function createWebLink (url, name)
	return "<a href='".. url .."'>" .. name .. "</a>"
end

-- ////////////////////////TODO///////////////////////////////////
-- ordered - easy first

-- about app and manual - videolan wesite ?
-- add checkbox - pause on catch (helps remembering the selected subtitle's line)
-- remember delay (in file meta?)
-- percised catch - first click - slow motion , second - catch (instead of fine-tune delay after drop)
-- translate extension
-- display selected line
