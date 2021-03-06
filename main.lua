love = lutro

require("intro")
require("menu")
require("space")
require("splash")
require("mission01")
require("driving")
require("spaceroad")

WIDTH = 320
HEIGHT = 240
SCALE = 1

pause = false
mute = false
gamestate = 0
selection = 0
submenu = 0

use_music = true

splash_duration = 300

save_names = nil

au_level = 0.01

dialog_line_no = 1
dialog_char_no = 1

dbg_dt = 0

function love.conf(t)
	t.width = WIDTH
	t.height = HEIGHT
end

function love.load()
  print("LOAD")
	math.randomseed(os.time())

  save_names = {"xxx", "xxx", "xxx"}

	--NOTE add gothic font
	-- - https://www.dafont.com/de/owrekynge.font?text=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789%24%A2%80%A3%A5-%2A%2F%3D%25%27%23%40%26_%28%29%2C.%3B%3A%3F%21%7C%7B%7D%3C%3E%5B%5D%A7%5E%7E&fpp=200&sort=date&l[]=10&l[]=1&back=bitmap
	imgfont = love.graphics.newImageFont("gfx/imgfont.png"," abcdefghijklmnopqrstuvwxyz0123456789$-*/=%'#@&_(),.;:?!|{}<>[]^~")
	love.graphics.setFont(imgfont)

	iconfont = love.graphics.newImageFont("gfx/iconfont.png"," abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

  loadAudio()

	loadIntro()
  loadSpace()
  loadSplash()
	loadMission01()

	loadDriving()

	debugMaf()

	if not mute then
  	--love.audio.play(au_intro)
	end

	updateScale()
	restart()
end

function debugMaf()
	local a = maf.vector(1, 2, 3)
	local b = maf.vector(-4, 2, 6)

	local c = a + b
	local d = maf.rotation.between(a, b)

	print(c:unpack())
	print(d:getAngleAxis())
end


function restart()
	print("RESTART")
	gamestate = 0
end


function love.draw()
	--NOTE MAYBE BITONALIZE EVERYTHING (only 2 colors: b/w no grey) with a pallette: https://lospec.com/palette-list/1bit-monitor-glow
	--REVIEW its pretty hard to create a bitonal game...
	love.graphics.clear()
	love.graphics.scale(SCALE,SCALE)
  if gamestate == 0 then
    drawIntro()
  elseif gamestate == 1 then
    drawSpace()
    drawMenu()
  elseif gamestate == 2 then
		drawMission01()
	elseif gamestate == 3 then
		drawDriving()
	elseif gamestate == 4 then
		drawDemoGameOver()
	end

  love.graphics.printf("s_x:"..steer_x.." fps:" .. math.floor(1 / dbg_dt) .. " dl:" .. dialog_line_no .. " gs:" .. gamestate .. " sm:".. submenu,0,0,WIDTH,"right")
end

function drawDemoGameOver()
		love.graphics.printf("game over", 0, 100, WIDTH, "center")
	  love.graphics.printf("end of this demo", 0, 120, WIDTH, "center")
		love.graphics.printf("contact me if u wanna work on this", 0, 140, WIDTH, "center")

		love.graphics.setFont(iconfont)
		love.graphics.printf("M", 0, 160, WIDTH, "center")
		love.graphics.setFont(imgfont)
end

function love.update(dt)
	dbg_dt = dt
  if gamestate == 0 then
    updateIntro()
    updateSpace(dt)
    if dev_splash_counter > splash_duration then
			gamestate = 1
		end

	elseif gamestate == 1 then
    if au_level < 0.6 then
      au_level = au_level + 0.001 --slowly fade in if cut
    end
    auBGM:setVolume(au_level)
    if not auBGM:isPlaying() and not mute then
      --love.audio.play(auBGM)
    end
    updateSpace(dt)

	elseif gamestate == 2 then
    if auBGM:isPlaying() then
      auBGM:stop()
			au_level = 0
    end
		updateMission01(dt)

	elseif gamestate == 3 then
		if not auBGM:isPlaying() and not mute then
			--love.audio.play(auBGM)
		end
		if au_level < 0.6 then
      au_level = au_level + 0.001 --slowly fade in if cut
    end
		auBGM:setVolume(au_level)
		updateDriving(dt)
		if drv_exp_finished then
			if auBGM:isPlaying() then
	      auBGM:stop()
				au_level = 0
	    end
			gamestate = 4
		end
	else
    --body
	end
end

function updateScale()
	SCRNWIDTH = WIDTH*SCALE
	SCRNHEIGHT = HEIGHT*SCALE
	love.window.setMode(SCRNWIDTH,SCRNHEIGHT,{fullscreen=false})
end

function love.gamepadpressed(i, key)
  if gamestate == 0 then
    return
  elseif gamestate == 1 then
    if key == 'up' then
      selection = selection - 1
    elseif key == 'down' then
      selection = selection + 1
    elseif key == 'start' then
			if not mute then
				--love.audio.play(auSelect)
			end
			if submenu == 0 then
      	submenu = 1
			elseif submenu == 1 then
				submenu = 0
				gamestate = 2
			end
    end
    return
  elseif gamestate == 2 then
		if key == "a" or key == "start" then
			if dialog_line_no ~= table.getn(dialog_lines) then
				dialog_line_no = dialog_line_no + 1
				dialog_char_no = 1
			else
				gamestate = 3
			end
		end
  elseif gamestate == 3 then
		if key == "left" then
			steer_x = steer_x - 0.01
		elseif key == "right" then
			steer_x = steer_x + 0.01
		end
	end
end

function love.gamepadreleased(i, k)
	-- body
end


function loadAudio()
  au_intro = love.audio.newSource("sfx/intro.ogg","stream")
  au_intro:setVolume(0.6)

	au_engine = love.audio.newSource("sfx/engine.ogg","stream")
  au_engine:setVolume(0.001)
	au_engine:setLooping(true)

	au_explosion = love.audio.newSource("sfx/explosion.ogg","stream")
  au_engine:setVolume(0.3)

  auSelect = love.audio.newSource("sfx/select.ogg","stream")
  auSelect:setVolume(0.3)

  if use_music == true then
    auBGM = love.audio.newSource("sfx/bgm.ogg","stream")
    auBGM:setLooping(true)
    auBGM:setVolume(au_level)
  end
end
