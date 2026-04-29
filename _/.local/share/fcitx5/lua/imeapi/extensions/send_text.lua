local fcitx = require("fcitx")

local recording = false

function Handy_send_text()
	local suc, _, ec = os.execute("handy --toggle-transcription")
	recording = not recording
	if recording or not suc or ec ~= 0 then
		return
	end
	local file, err = io.open("/tmp/handy.fifo")
	if file == nil then
		return
	end
	fcitx.commitString(file:read("a"))
	file:close()
end

ime.register_command("hh", "Handy_send_text", "handy send text", "alpha", "")
