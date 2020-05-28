----------------------------------------
-- adv / MW操作
----------------------------------------
-- MW設置
function init_advmw(f)
--	scr.firsthalf = true

	setCmodeMW("bg01")

	-- name / adv
	setMWFont()
--	set_textfont("name", game.mwid..".mw.name")
--	set_textfont("adv" , game.mwid..".mw.adv")
--	setADVFont()
	set_message_speed()

--	local p = name_cliptable
--	lyc2{ id="1.80.mw.name", file=(game.path.ui.."name"),	 x=(p.x),  y=(p.y),  visible="0"}

--	glyph_set()		-- glyph設置
	chgmsg_adv()	-- advに変更
	init_adv_btn()	-- ボタン設置
--	setonpush{ key="126", mode="ex", lua="adv_tabletbtn" }

	-- 場所名／bgm名
--	local path = game.path.ui
--	lyc2{ id="1.99.bgx", file=(path.."nt_bg")	, y=100, alpha="0" }
--	lyc2{ id="1.99.bgm", file=(path.."nt_music"), y=100, alpha="0" }

	if not f then
		e:tag{"lyprop", id=(game.mwid), visible="0"}
	end
	flip()
end
----------------------------------------
-- set font
function setADVFont()
--[[
	local no = (conf.font or 0) + 1
	set_textfont(("name0"..no), "1.80.mw.name")
	set_textfont(("adv0" ..no), "1.80.mw.adv")
	local fo = fontdeco("adv")
	e:tag{"chgmsg", id="1.80.mw.adv"}
	e:tag(fo)
	e:tag{"/chgmsg"}
]]
end
----------------------------------------
-- フォント装飾
function fontdeco(name)
	local s  = conf.shadow
	local o  = conf.outline
	local so = o..s
	local f  = conf.font + 1
	local nm = name.."0"..f
	local v  = csv.font[nm]
	local t  = textDecoTable[so]
	local r  = tcopy(v)
	if v and t then
		r[1] = "font"
		r.face		  = init[v.face]
		r.rubyface	  = init[r.ruby]
		r.style		  = t.s
		r.kerning	  = t.k + v.kerning
		r.left		  = t.x + v.left
		r.spacetop	  = t.y + v.spacetop
		r.spacebottom = t.b + v.spacebottom
	end
	return r
end
----------------------------------------
-- set mw image
function setMWImage(name, alpha, visible)
	local t = csv.mw[name]
	if t then
		lyc2{ id=(game.mwid.."."..t.id), file=(game.path.ui..t.file), x=(t.x), y=(t.y), clip=(t.clip), alpha=(alpha), visible=(visible) }
	end
end
----------------------------------------
-- cinema mode mw
function setCmodeMW(name,vislble)
	local t = csv.mw[name]
	if t then
		lyc2{ id=(game.mwid.."."..t.id),width=(t.w) ,height=(t.h),color=("00000000"), x=(t.x), y=(t.y), visible=(visible) }
	end

end
----------------------------------------
-- mwの透明度
function mw_alpha()
	-- alpha
	local p = repercent(conf.mw_alpha, 255)
	e:tag{"lyprop", id=(getMWID("bg01")), alpha=(p)}

	local id = getMWID("name")
	if id then e:tag{"lyprop", id=(id), alpha=(p)} end
end
----------------------------------------
-- get mw id
function getMWID(name)
	local t = csv.mw[name]
	return t and game.mwid.."."..t.id
end
----------------------------------------
-- mw切り替え
----------------------------------------
-- 切り替え
function mw(p)
	local no = p.no or 1
	scr.msgno = no
	message("通知", no, "番のmwに切り替えます")
	setMWFont()
	flip()
end
----------------------------------------
-- fontとglyph
function setMWFont(flag)
	local no = scr.msgno or 1
	if not flag then
		local nm = 'bg0'..no
	--	setMWImage(nm)		-- MW書き換え
		setCmodeMW(nm)
		--mw_alpha()			-- alpha再設定
	end

	-- font
	local no = 1
	local ext = ""
	if conf.language ~= "ja" then ext = "_"..conf.language end
	set_textfont(("name0"..no), game.mwid..".mw.name")
	set_textfont(("adv0"..no..ext) , game.mwid..".mw.adv",true)
-- 	glyph_set(no)		-- glyph設置
end
----------------------------------------
-- ボタン制御
----------------------------------------
-- ボタンを配置
function init_adv_btn()
	local v = csv.ui_adv
	if v and v[1] then
		local id = game.mwid
		csvbtn3("adv", id, v)
	end
end
----------------------------------------
-- ボタンが押されたときに消してしまう
function advmw_clear(flag)
	local fl = flag and flag ~= game.os
	local bt = btn.cursor
	if bt and not fl then
		btn_nonactive(bt, true)
		btn.cursor = nil
	end
end
----------------------------------------
-- 
----------------------------------------
-- sback / 設定行戻す
function mw_autoback()
	local ct = conf.scback
	local mx = #log.stack
	if mx > 1 then
		local bc = mx - ct
		if bc < 1 then bc = 1 end

		message("通知", ct, "行戻します", bc)

		se_ok()
--		ReturnStack()	-- 空のスタックを削除
		quickjumpui(bc)
	end
end
----------------------------------------
-- glyph
----------------------------------------
-- glyph設置	name,x,y,w,h,loop,time,homing
function glyph_set(no)
	chgmsg_adv()
	local nm   = "glyph0"..no
	local g    = csv.mw[nm]
	local id   = game.mwid.."."..g.id
	local path = game.path.ui
	local max  = g.loop
	local time = g.time
	e:tag{"glyph"}
	e:tag{"anime",		id=(id), mode="init", file=(path..g.file), clip=("0,0,"..g.w..","..g.h)}
	for i=1, max do
		e:tag{"anime",	id=(id), mode="add",  file=(path..g.file), clip=((i*g.w)..",0,"..g.w..","..g.h), time=(i*time)}
	end
	e:tag{"anime",		id=(id), mode="end",  time=(max * time)}
	e:tag{"lyprop",		id=(id), left=(g.x), top=(g.y)}
	e:tag{"glyph",	 layer=(id), homing=(g.homing)}
	chgmsg_adv("close")
end
----------------------------------------
-- glyph消去
function glyph_del()
	e:tag{"glyph"}
end
----------------------------------------
--[[
-- glyph check
function glyph_check()
	-- voice
	if scr.voice.glyph then
		glyph_set("glyph_voice")

	-- normal
	else
		glyph_set("glyph_adv")
	end
end
----------------------------------------
-- glyph delete
function glyph_del()
--	message("通知", "glyph delete")
	e:tag{"lydel", id="1.90"}
	e:tag{"glyph"}
	flg.glyph = nil
	scr.adv.glyph = nil
end
----------------------------------------
-- glyph
function glyph_set(name, f)
	local id	= "1.90"
	local time	= init.glyph_time
	local p		= init[name]
	if not f then glyph_del() end
	flg.glyph = {}

--	message("通知", "glyph を設定しました")

	if p and not p[3] then
		-- alpha点滅
		lyc2{  id=(id), file=(p[1]), clip=(p[2])}
		tween{ id=(id), alpha="255,0", time=(time), yoyo="-1"}
	elseif p then
		-- 1    2   3     4     5     6     7
		-- file,max,sizeX,sizeY,clipX,clipY,max2
		local max = p[2] + p[7]
		local cx  = p[5]
		local cy  = p[6]
		for i = 0, max do
			lyc2{ id=(id..'.'..i), file=(p[1]), clip=((cx + i*p[3])..","..cy..","..p[3]..","..p[4]), alpha=0}
		end
		scr.adv.glyph = 0
		tween{ id=(id..".0"), c=0, name=(name), max=(p[2]), max2=(max), time2=(time), alpha="254,255", time=1, delay=(time), handler="calllua", ["function"]="glyph_anime", eq=true }

		flg.glyph.max = max
--[ [
		-- アニメ
		local max = p[2] - 1
		local cx  = p[5]
		local cy  = p[6]

		-- ループ
		e:tag{"anime", id=(id), mode="init", file=(p[1]), clip=(cx..","..cy..","..p[3]..","..p[4])}
		for i = 1, max do
			e:tag{"anime", id=(id), mode="add", file=(p[1]), clip=((cx + i*p[3])..","..cy..","..p[3]..","..p[4]), time=(i*time)}
		end
		e:tag{"anime", id=(id), mode="end", time=(max*time)}
		tween{ id=(id), alpha="254,255", time=(max*time), handler="calllua", ["function"]="glyph_anime", name=(name), eq=true }
] ]
	end

	-- 表示位置
	local p = init.glyph_pos
	e:tag{"lyprop", id=(id), left=(p[1]), top=(p[2])}
	if not f then e:tag{"glyph", layer=(id), homing=(init.glyph_homing)} end
--	e:tag{"glyph", layer=(id), left=(p[1]), top=(p[2]), homing=(init.glyph_homing)}
end
----------------------------------------
function glyph_anime(e, p)
	local c	= tonumber(p.c)
	if scr.mw.msg and flg.glyph and scr.adv.glyph == c then
		local id	= "1.90."
		local time	= tonumber(p.time2)
		local delay	= time

		-- 消す
		tween{ id=(id..c), alpha="1,0", time=1 }

		-- 計算
		c = c + 1
		if c >= 0 + p.max2 then c = 0 + p.max end
		if c >= 0 + p.max  then delay = time * 4 end
		scr.adv.glyph = c
		tween{ id=(id..c), c=(c), name=(p.name), max=(p.max), max2=(p.max2), alpha="254,255", time=1, time2=(time), delay=(delay), handler="calllua", ["function"]="glyph_anime" }

	-- 消しておく
	elseif flg.glyph then
		tween{ id=("1.90."..c), alpha="1,0", time=1 }
	end
end
]]
----------------------------------------
-- mw dock
----------------------------------------
-- mw dock on/offボタンが押された
function mwdock()
	local c  = conf.dock or 1
	if c == 0 then conf.dock = 1
	else		   conf.dock = 0 end
	btn_over(e, { key="bt_lock" })
	flip()
end
----------------------------------------
function mwdock_mover()
	local c  = conf.dock or 1
	if c == 0 then btn_clip("bt_lock", 'clip_d') end
end
----------------------------------------
function mwdock_mout()
	local c  = conf.dock or 1
	if c == 0 then btn_clip("bt_lock", 'clip_c') end
end
----------------------------------------
function mwdock_vover()
	if conf.fl_master == 0 or conf.master == 0 then btn_clip("bt_mute", 'clip_d') end
end
----------------------------------------
function mwdock_vout()
	if conf.fl_master == 0 or conf.master == 0 then btn_clip("bt_mute", 'clip_c') end
end
----------------------------------------
--
----------------------------------------
-- lock状態
function mwdock_lock()
	if game.pa then

		-- dock area
		local ix = getBtnID("dockarea")
		if ix then
			tag{"lyprop", id=(ix), alpha="0"}
			lyevent{ id=(ix), over="mwarea_over", out="mwarea_out"}
			scr.mwlock = true
		end

		-- lock button
		local id = init.mwbtnid
		local c  = conf.dock or 1
		if c == 1 or scr.select then
--			tag{"lyprop", id=(id), visible="1"}
			tag{"lyprop", id=(id..".dc"), visible="1", top="0"}
		else
			tag{"lyprop", id=(id..".dc"), visible="0"}
			del_uihelp()
			scr.mwlock = nil
		end

		-- help
		--set_uihelp(id..".dc.help", "mwhelp")

		-- volume
		if conf.fl_master == 0 or conf.master == 0 then
			btn_clip("bt_mute", 'clip_c')
		end
		mwdock_mout()
		mwdock_vout()
	end
end
----------------------------------------
-- 
function mwarea_over()
	if conf.dock == 0 and not scr.mwlock then
		scr.mwlock = true

		if not scr.select and not flg.mwmute and not autoskipcheck() then
			local tm = init.mwbtn_fade
			local id = init.mwbtnid..".dc"
			tag{"lyprop", id=(id), visible="1"}
			systween{ id=(id), y="40,0", time=(tm) }
			uitrans(tm)
		end
	end
end
----------------------------------------
function mwarea_out()
	if conf.dock == 0 and scr.mwlock then
		scr.mwlock = nil

		-- mute
		if not scr.select and not flg.mwmute then
			local tm = init.mwbtn_fade
			local id = init.mwbtnid..".dc"
			systween{ id=(id), y="0,40", time=(tm) }
			tag{"lyprop", id=(id), visible="0"}
			uitrans(tm)
		end
	end
end
----------------------------------------
-- 選択肢 mode="sys"
function mwdock_select(flag)
	if conf.dock == 0 and scr.select and game.pa then
		if not flag then
			tag{"lyprop", id=(init.mwbtnid..".dc"), visible="1", top="0"}
		elseif flag or not scr.mwlock then
			tag{"lyprop", id=(init.mwbtnid..".dc"), visible="0"}
			scr.mwlock = nil
		end
	end
end
----------------------------------------
function mwdock_mute()
	if not flg.mwmute then
		flg.mwmute = true

		local tm = init.mwbtn_fade
		if not scr.mwlock then
			local id = init.mwbtnid..".dc"
			tag{"lyprop", id=(id), visible="1"}
			systween{ id=(id), y="40,0", time=(tm) }
		end

		-- slider位置
		sys.adv.dummy = 100 - conf.master
		local y = percent(sys.adv.dummy, 100)
		local v = getBtnInfo("sl_vol")
		local s = repercent(y, v.h - v.p2)
		e:tag{"lyprop", id=(v.idx..".10"), top=(s)}
		tag{"lyprop", id=(getBtnID("sl_vol")), visible="1"}
		uitrans(tm)
	end
end
----------------------------------------
function mwdock_volume(e, p)
	local c = sys.adv.dummy
	conf.master = 100 - c
	set_volume()
	if c == 100 then	btn_clip("bt_mute", 'clip_c')
	else				btn_clip("bt_mute", 'clip')   conf.fl_master = 1 end
end
----------------------------------------
-- 閉じる
function mwdock_muteclose()
	if flg.mwmute then
		flg.mwmute = nil

		local tm = init.mwbtn_fade
		if not scr.mwlock then
			local id = init.mwbtnid..".dc"
			systween{ id=(id), y="0,40", time=(tm) }
			tag{"lyprop", id=(id), visible="0"}
		end
		tag{"lyprop", id=(getBtnID("sl_vol")), visible="0"}
		estag("init")
		estag{"uitrans", tm}
		estag{"asyssave"}
		estag()
	end
end
----------------------------------------
-- auto / skip
----------------------------------------
-- autoskip開始時に呼ばれる
function autoskip_startimg(name)
	local r = btn and btn.name == "adv"
	if r then
--		message("通知", name, "開始")

		advmw_clear()

		-- icon
		local idx =  getMWID(name)
		if idx then tag{"lyprop", id=(idx), visible="1"} end

		-- MWボタン
		local id = init.mwbtnid
		if id and game.pa then
			-- tablet ui
			if tabletCheck("ui") then
				tag{"lyprop", id=(init.mwtabid), visible="0"}
			end

			-- mwbtn
			if name == 'auto' then
				local tm = init.mwbtn_fade
				systween{ id=(id..".dc"), y="0,40", time=(tm)}	-- dock button
				systween{ id=(id..".cl"), x="0,64", time=(tm)}	-- close button
				systween{ id=(id), alpha="255,0", time=(tm)}
				tag{"lyprop", id=(id), visible="0"}
				estag("init")
--				estag{"eqwait", tm}
				estag{"uitrans", { fade=tm }}
				estag()
			else
				tag{"lyprop", id=(id), visible="0"}
				flip()
			end
		end
		flg.autoskipflag = name
	end
end
----------------------------------------
-- autoskip停止時に呼ばれる
function autoskip_stopimg()
	local r = btn and btn.name == "adv"
	if r then
		local name = flg.autoskipflag
		local tm = init.mwbtn_fade
		local id = init.mwbtnid

		-- tablet ui
		if tabletCheck("ui") then
			tag{"lyprop", id=(init.mwtabid), visible="1"}
		end

		-- icon
		local idx =  getMWID(name)
		if idx then tag{"lyprop", id=(idx), visible="0"} end

		if id and game.pa then
			if name == 'auto' then
				local tm = init.mwbtn_fade
				tag{"lyprop", id=(id), visible="1"}
				if scr.mwlock then
					systween{ id=(id..".dc"), y="40,0", time=(tm)}
				else
				end
				systween{ id=(id..".cl"), x="64,0", time=(tm)}
				systween{ id=(id), alpha="0,255", time=(tm)}
				flip()
			elseif name == 'skip' then
				tag{"lyprop", id=(id), visible="1"}
				flip()
			end
		end
	end
	flg.autoskipflag = nil
end
----------------------------------------
-- 通知
----------------------------------------
-- bg / bgm
function notification()
--[[
	local fl = nil

	-- bg
	local nm = flg.notification_bg
	if nm and nm ~= scr.bghead and conf.bgname == 1 then
		local path = game.path.ui.."nt_bg.ipt"
		if e:isFileExists(path) then
			e:include(path)
			flg.notification_bg = nil
			if ipt[nm] then
				scr.bghead = nm
				local id = "1.99.bgx"
				e:tag{"lyprop", id=(id), alpha="255", left="-360", clip=(ipt[nm])}
				e:tag{"lytweendel", id=(id)}
				tween{id=(id), x="-360,0", time="200"}
--				tween{id=(id), x="0,-360", time="200", delay="5000"}
				tween{id=(id), alpha="255,0", time="200", delay="3000"}
				fl = true
			end
		end
	end

	-- bgm
	local nm = flg.notification_bgm
	if nm and conf.bgmname == 1 then
		local path = game.path.ui.."nt_music.ipt"
		if e:isFileExists(path) then
			e:include(path)
			flg.notification_bgm = nil
			if ipt[nm] then
				local id = "1.99.bgm"
				e:tag{"lyprop", id=(id), alpha="255", left="1280", clip=(ipt[nm])}
				e:tag{"lytweendel", id=(id)}
				tween{id=(id), x="1280,920", time="200"}
--				tween{id=(id), x="920,1280", time="200", delay="5000"}
				tween{id=(id), alpha="255,0", time="200", delay="3000"}
				fl = true
			end
		end
	end

	if fl then flip() end
]]
end
----------------------------------------
-- 通知消去
function tags.ntclear() notification_clear() return 1 end
function notification_clear()
--	e:tag{"lytweendel", id="1.99.bgx"}
--	e:tag{"lytweendel", id="1.99.bgm"}
--	e:tag{"lyprop", id="1.99.bgx", alpha="0"}
--	e:tag{"lyprop", id="1.99.bgm", alpha="0"}
	notify()
end
----------------------------------------
