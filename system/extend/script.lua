----------------------------------------
-- 中間スクリプト
----------------------------------------
-- system
----------------------------------------
-- MW
function tags.sysshow(e, p)		msg_show(p.skip) return 1 end		-- [sysshow] / system
function tags.syshide(e, p)		msg_hide(p.skip) return 1 end		-- [syshide] / system
function tags.msg(e, p)			mw(p) return 1 end					-- [msg]
function tags.msgon(e, p)		msgon(p) return 1 end				-- [msgon]
function tags.msgoff(e, p)		msgoff(p) return 1 end				-- [msgoff]
------------------------
-- image
function tags.bg_reset(e, p)	reset_bg() return 1 end				-- [bg_reset]
function tags.extrans(e, p)		extrans(p) return 1 end				-- [extrans]
------------------------
-- jump
function tags.excall(e, p)		excall(p) return 1 end				-- [script]
function tags.exreturn(e, p)	exreturn(p) return 1 end			-- [exreturn]
function tags.select(e, p)		exselect(p) return 1 end			-- [select]
function tags.selback(e, p)		exselback(p) return 1 end			-- [selback]
function tags.selnext(e, p)		exselnext(p) return 1 end			-- [selnext]
function tags.brandlogo(e, p)	brandlogo(p) return 1 end			-- [brandlogo]
------------------------
-- extra
function tags.scenestart(e, p)	sceneStart() return 1 end			-- [scenestart]
function tags.sceneend(e, p)	sceneEnd(p) return 1 end			-- [sceneend]
function tags.staffroll(e, p)	staffroll(p) return 1 end			-- [staffroll]
function tags.tipsopen(e,p)  gscr.tips[p.name] = true return 1 end    -- [tipsopen]
------------------------
-- key
function tags.keyskip(e, p)		keyskip(p) return 1 end				-- [keyskip]
function tags.skipstart(e, p)	autoskip_init() return 1 end							-- [skipstart]
function tags.skipstop(e, p)	autoskip_stop() e:tag{"skip", allow="0"} return 1 end	-- [skipstop]
------------------------
-- save
function tags.savetitle(e, p)	sv.savetitle(p) return 1 end		-- [savetitle]
function tags.exautosave(e, p)	exautosave() return 1 end			-- [exautosave]
function tags.loading(e, p)		loading_func(p) return 1 end
function tags.saving(e, p)		saving_func(p) return 1 end
function tags.uimask(e, p)		uimask_func(p) return 1 end
function tags.loadmask(e, p)	loadmask_func(p) return 1 end
----------------------------------------
-- テキスト
----------------------------------------
--function tags.name(e, p)	mw_name(p)		return 1 end	-- 
function tags.text(e, p)	mw_text(p)		return 1 end	-- 
function tags.line(e, p)	mw_line(p)		return 1 end	-- 
function tags.rt2(e, p)		rt2()			return 1 end	-- 
function tags.gaiji(e, p)	gaiji(p)		return 1 end	-- 
function tags.exfont(e, p)	exfont(p)		return 1 end	-- 
function tags.txkey(e, p)	txkey(p)		return 1 end	-- 
function tags.tximg(e, p)	tximg(p)		return 1 end	-- 
function tags.kerning(e,p) kerning(p)       return 1 end

----------------------------------------
-- 画像
----------------------------------------
function tags.bg(e, p)		image_bg(p)		return 1 end	-- 
function tags.ev(e, p)		image_bg(p)		return 1 end	-- 
function tags.evflg(e,p)	ev_flg(p)		return 1 end    --
function tags.cg(e, p)		image_bg(p)		return 1 end	-- 
function tags.cgdel(e, p)	cgdel(p)		return 1 end	-- 
function tags.cgact(e, p)	tag_cgact(p)	return 1 end	-- 
function tags.fg(e, p)		image_fg(p)		return 1 end	-- 
function tags.fgf(e, p)		image_fgf(p)	return 1 end	-- 
function tags.fgact(e, p)	tag_fgact(p)	return 1 end	-- 
----------------------------------------
function tags.colortone(e, p)	colortone(p)	return 1 end	-- 
function tags.cacheclear(e, p)	delImageStack("change")	return 1 end	-- 
----------------------------------------
-- media
----------------------------------------
function tags.bgm(e, p)		bgm(p)		return 1 end
function tags.vol(e, p)		media_volume(p)		return 1 end	-- 
function tags.mbgm(e,p)		mbgm(p)		return 1 end	--
function tags.chmbgm(e,p)	mbgm_change(p)		return 1 end
function tags.mbgmstop(e,p)	mbgm_stop(p)		return 1 end	--
function tags.se(e, p)		se(p)		return 1 end	-- 
--function tags.vo(e, p)		vo(p)		return 1 end	-- 
function tags.vo(e, p)		vo2(p)		return 1 end	-- 
function tags.vostop(e, p)	vostop(p)	return 1 end	-- voice stop
function tags.lvo(e, p)		lvo(p)		return 1 end	-- loop voice
function tags.movie(e, p)	movie_init(p)	return 1 end	-- 
----------------------------------------
function tags.allsoundstop(e, p) allsound_stop(p) return 1 end
----------------------------------------
function tags.sysvo(e, p)		sysvo(p.file or p["0"]) return 1 end	-- [sysvo]
function tags.sysse(e, p)		system_se_play(p) 		return 1 end	-- [sysse]
function tags.ese(e, p)			ese_play(p) 			return 1 end	-- [ese]
function tags.se_ok(e, p)		se_ok()		 return 1 end		-- [se_ok]
function tags.se_cancel(e, p)	se_cancel()  return 1 end		-- [se_cancel]
function tags.se_active(e, p)	se_active()  return 1 end		-- [se_active]
function tags.se_none(e, p)		se_none()	 return 1 end		-- [se_none]
function tags.se_saveok(e, p)	sysvowait(p, "saveok") return 1 end		-- [se_saveok]
function tags.se_loadok(e, p)	sysvowait(p, "loadok") return 1 end		-- [se_loadok]
function tags.se_exitok(e, p)	sysvowait(p, "exitok") return 1 end		-- [se_loadok]
function tags.stopese(e,p) ese_stop({time=100}) return 1 end
----------------------------------------
-- 演出
----------------------------------------
function tags.quake(e, p)	tag_quake(p) return 1 end			-- [quake]
function tags.flash(e, p)	flash(p) return 1 end				-- [flash]
----------------------------------------
function tags.ex(e, p)
	local switch = {

		-- wait
		wait = function(p)
			if scr.img.buff then
				estag("init")
				estag{"image_loop"}
				estag{"eqwait", p.time}
				estag()
			else
				eqwait(p.time)
			end
		end,

		-- count
		count = function(p) ex_countdown(p) end,

		-- tweet
		tweet = function(p) ex_tweetset(p) end,
	}

	local nm = p.func
	if nm and switch[nm] then
		switch[nm](p)
	else
dump(p)
	end
	return 1
end
----------------------------------------
-- 拡張
----------------------------------------
function tags.exdlg(e, p)
	local nm = p.name
	if nm then
		autoskip_disable()
		estag("init")
		estag{"exskip_stop"}
		estag{"dialog", nm}
		estag()
	end
	return 1
end
----------------------------------------
--
function tags.exclick(e, p)
--	local time = flg.automode and 5000 or 33554431
	estag("init")
	estag{"image_loop"}
--	estag{"eqwait", time}
	estag{"exclick_wait"}
	estag()
	return 1
end
----------------------------------------
function exclick_wait()
	flg.clickwait = true
	tag{"@"}
end
----------------------------------------
function tags.autoplay(e, p)
	if p.mode == "stop" then
		allkeyon()
		e:tag{"exec", command="automode", mode="0"}
		msg_reset()
		set_message_speed()
		autoskip_init()
	else
		-- autoflagが1なら飛ばせる
		local s = p.autoflag
		local m = s and tn(get_eval(s))
		if m == 1 then
			message("通知", "autoplay開始 flag:", s, m)
		else
			if s then allkeyoff() end
			tags.skipstop(e, p)
			message("通知", "autoplay開始")
		end

		-- 文字速度と待機時間
		local sp = p.speed or init.autoplay_speed
		local dl = p.wait  or 500
		local at = p.auto  or init.autoplay_delay
		chgmsg_adv()
		set_message_speed_tween(sp, dl)
		chgmsg_adv("close")
		e:tag{"var", name="s.automodewait", data=(at)}

		local s = nil
		for i, v in pairs(csv.voice.name) do
			if s then	s = s..","..getSEID("voice", v.id)
			else		s = getSEID("voice", v.id) end
		end
		e:tag{"automode", allow="1", stopbyclick="0", stopbystop="0", syncse=(s)}
		e:tag{"exec", command="automode", mode="1"}
	end
	return 1
end
----------------------------------------
--[[
function tags.TL(e, p)			tags["タイトル"](e, p)	return 1 end	-- 
function tags.AS(e, p)			return 1 end	-- 
function tags.goto(e, p)		gotoScript(p)	return 1 end	-- goto
function tags.gosub(e, p)		staffroll(p)	return 1 end	-- staffroll
tags["end"] = function(e, p)	e:tag{"reset"}	return 1 end	-- スクリプト終端
tags["RM_S"] = function(e, p)	sceneStart()	return 1 end	-- 回想開始
tags["RM_E"] = function(e, p)	sceneEnd(p)		return 1 end	-- 回想終了
tags["XM_E"] = function(e, p)	sceneEnd(p, 1)	return 1 end	-- 回想終了
]]
----------------------------------------
-- 
----------------------------------------
-- フローチャート登録
function tags.flow(e, p)
	-- 開放
	local name = p["0"] or p.name
	if name then
		local c = gscr.vari[name]
		if c ~= 1 then
			message("通知", name, "を開放します")
			gscr.vari[name] = 1
			if not p.sys then asyssave() end
		end
	end

	-- 現在位置
	local pos = p.pos
	if pos then
		message("通知", "現在位置を", pos, "に設定しました")
		scr.flowposition = pos
	end
	return 1
end
----------------------------------------
-- ルート開放確認
function tags.clearcheck(e, p)
	local mode = p.mode

	----------------------------------------
	-- reset
	if mode == "reset" then
		message("通知", "ルート開放フラグをリセットしました")
		gscr.vari = {}
		gscr.clear_fhalfflag = nil
		return 1
	end

	----------------------------------------
	-- crc
	local crc = gamecheck_crc
	if crc and game.os == "windows" then
		e:tag{"var", name="t.tmp.crc", system="file_crc", file=(gamecheck_exe), zerox="0", caps="0"}
		local ecrc = e:var("t.tmp.crc")
		if crc ~= ecrc then
			message("通知", "抜けます")
			return 1
		end
	end

	----------------------------------------
	local tbl = {
		alpha = { 2, 5, 3 },		-- g.alpha	条件を満たすと自動で 1 をセット	g.e02～g.e05のうち３つ開放
		beta  = { 2 , 10, 7  },		-- g.beta	条件を満たすと自動で 1 をセット	g.e02～g.e10のうち７つ開放
		gamma = { 2 , 15, 12 },		-- g.gamma	条件を満たすと自動で 1 をセット	g.e02～g.e15のうち12個開放
		omega = { 2 , 20, 19  },	-- g.omega	条件を満たすと自動で 1 をセット	g.e02～g.e20の全て開放
--		omega = { 17, 20, 3  },		-- g.omega	条件を満たすと自動で 1 をセット	g.e02～g.e15の全て及びg.e17～g.e20うち３個開放
--		zzzzz = { 2 , 15, 14 },		-- g.omega	条件を満たすと自動で 1 をセット	g.e02～g.e15の全て及びg.e17～g.e20うち３個開放

		-- 体験版用
		trbeta  = { 2 , 10, 6  },	-- g.trbeta	条件を満たすと自動で 1 をセット	g.e02～g.e10のうち７つ開放
	}

	----------------------------------------
	-- check
	local route_check = function(nm)
		local p = tbl[nm]
		local r = nil
		local c = 0
		for i=p[1], p[2] do
			local s = "e"..string.format("%02d", i)
			local g = tn(gscr.vari[s] or 0)
			if g and g ~= 0 then c = c + 1 end
		end
		if c >= p[3] then r = true end
		return r
	end

	----------------------------------------
	-- alpha/beta/gamma route
	local r = nil
	local t = { "alpha", "beta", "gamma", "omega" }
	if getTrial() then t = { "alpha", "beta" } end
	for i, v in ipairs(t) do
		local a = tn(get_eval("g."..v))
		if a == 0 and route_check(v) then
			message("通知", v, "routeが開放されました")
			gscr.vari[v] = 1
			r = v
		end
	end
--[[
	-- omega route
	local a = tn(get_eval("g.omega"))
	if a == 0 and not getTrial() then
		local t = route_check("omega")
		local z = route_check("zzzzz")
		if t and z then
			message("通知", "omega routeが開放されました")
			gscr.vari.omega = 1
			r = "omega"
		end
	end
]]
	-- sigma route / A32 A33 C20
	local a1 = tn(get_eval("g.clear_a32"))
	local a2 = tn(get_eval("g.clear_a33"))
	local a3 = tn(get_eval("g.clear_c20"))
	local as = tn(get_eval("g.sigma"))
	if a1 == 1 and a2 == 1 and a3 == 1 and as == 0 then
		message("通知", "sigma routeが開放されました")
		gscr.vari.sigma = 1
	end

	-- delta route / A32 A33
	local a1 = tn(get_eval("g.clear_a32"))
	local a2 = tn(get_eval("g.clear_a33"))
	local ao = tn(get_eval("g.omega"))
	local ad = tn(get_eval("g.delta"))
	if a1 == 1 and a2 == 1 and ao == 1 and ad == 0 then
		message("通知", "delta routeが開放されました")
		gscr.vari.delta = 1
	end

	----------------------------------------
	-- call ex
	if r and (not mode or mode ~= "sys") then
		local t2 = { alpha="ex01", beta="ex02", gamma="ex03", omega="ex04", trbeta="ex02" }
		local fl = t2[r]
		local ex = tn(gscr.vari[fl]) or 0
		if fl and ex == 0 then
--			gscr.vari[fl] = 1
			ResetStack()
			message("通知", fl, "を呼び出します", r)
			gotoScript{ file=(fl) }
		end
	end
	return 1
end
----------------------------------------
