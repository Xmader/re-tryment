----------------------------------------
-- onEnterFrame制御
----------------------------------------
function tags.repeatedly(e, p) repeatedly() return 1 end
function repeatedly() flg.repeatedly = e:now() end
----------------------------------------
function vsync()
	-- debugger
	if debug_vscode then debuggee.poll() end

	----------------------------------------
	-- longtap
	local s = flg and (flg.skip or flg.skipstop)
	local b = btn and btn.cursor
	if s or b then
		e:setUseTouchHold(false)
		flg.longtap = true
	elseif flg.longtap and not f and not b then
		e:setUseTouchHold(true)
		flg.longtap = nil
	end
	if flg.skipmode and e:isDownEdge(1) then
		e:overrideKey{ key=1, status=32 }
	end

	----------------------------------------
	-- cache test
	if flg.imageCacheStart and not e:isLoadingSurface(nil) then
		flg.imageCacheStart = nil	-- ローディング待機フラグ削除
		e:setScriptStatus(0)		-- RUNステータスに遷移
	end

	----------------------------------------
	-- ゲーム終了
	if gameexitflag then
		if not gameexitflagex and e:isDown(1) then
			gameexitflagex = true
			tag{"skip", allow="1"}
			tag{"exec", command="skip", mode="1"}
		end
	end

	----------------------------------------
	-- config / fullscreen処理
	if flg.config and gscr.conf.page == 1 and game.os == "windows" then
		e:tag{"var", name="t.screen", system="fullscreen"}
		local s = tn(e:var("t.screen"))
		local c = conf.window
		if s ~= c then
			conf.window = s
			local nm = s == 1 and init.windows_screenon or init.windows_screenoff
			toggle_change(nm)
		end
	end

	----------------------------------------
	-- すべての入力を停止
	if allkeystopex then
		e:overrideKey{ status=0 }
	end

	----------------------------------------
	-- ゲーム画面のdrag処理
	if flg.advdrag then
		e:overrideKey{ key=1, status=0 }
	end

	----------------------------------------
	-- ctrlskip無効化
	if flg.ctrlstop then
		local s = explode(",", csv.advkey.ctrl)
		for i, v in pairs(s) do
			local n = tn(v)
			if n <= 226 then
				e:overrideKey{ key=(n), status=0 }
			end
		end
	end

	----------------------------------------
	-- windows
	if game.os == "windows" then
		if e:isDown(18) then altkey = true else altkey = nil end

		-- tablet mode
		if conf.tabletui == 1 then
			if e:isDown(1) then flg.tabletui = true else flg.tabletui = nil end
		end
		if flg.cg_viewer and flg.cg_viewer.start < e:now() - 2000 then
			local point = e:getMousePoint()
			if point.x == flg.point.x and point.y == flg.point.y then
				exf.hideViewerBtn()
			else
				exf.showViewerBtn()
				flg.point = point
			end
			flg.cg_viewer.start = e:now()
		end
	end

	----------------------------------------
	-- skip時は抜ける
	if flg.skipmode then return end

	----------------------------------------
	-- 連打防止
	if flg.repeatedly then
		if e:isDown(1) or e:isDown(13) then
			flg.repeatedly = e:now()
		elseif flg.repeatedly < e:now() - 200 then
			flg.repeatedly = nil
		end
		e:overrideKey{ status=0 }
	end

	----------------------------------------
	-- ctrlskip無効
	local c = conf and conf.ctrlskip == 0
	if c then
		if e:isDown(17 ) then e:overrideKey{ key=17 , status=0 } end
		if e:isDown(140) then e:overrideKey{ key=140, status=0 } end
	end

	----------------------------------------
	-- debug
	if debug_flag then
		----------------------------------------
		-- loading time
		if debugcachetime and not e:isLoadingSurface(nil) then
			local s = e:now() - debugcachetime
			message("通知", "Loading", s, "ms")
			debugcachetime = nil
		end

		----------------------------------------
		-- 画面左での右フリックはtabに
		if e:isUpEdge(152) then
			local m = e:getMousePoint()
			if m.x < 100 then
				e:overrideKey{ status=0 }
				e:overrideKey{ key=9, status=32 }
			end
		----------------------------------------
		-- tab keyがない機種用
		elseif (e:isDown(116) or e:isDown(260)) and (e:isDownEdge(117) or e:isDownEdge(261)) then
			e:overrideKey{ status=0 }
			e:overrideKey{ key=9, status=32 }
		-- L1ボタンはupEdgeで反応／無効化
		elseif e:isDown(116) or e:isDown(260) then
			e:overrideKey{ status=0 }
		-- L1ボタンはupEdgeで反応／push
		elseif e:isUpEdge(116) or e:isUpEdge(260) then
			e:overrideKey{ key=116, status=32 }
		end
	end

	----------------------------------------
	-- keyskip / trans中処理
	local v = scr.keyskip
	if flg.trans and v and not v.skip then
		for i, n in pairs(v.list) do
			if e:isDownEdge(i) then
				e:tag{"exec", command="skip", mode="1"}
				scr.keyskip.skip = true
				break
			end
		end
	end

	----------------------------------------
	-- title anime skip
	local v = flg.title
	if v and v.skip and not v.skipflag then
		for i, n in pairs(csv.advkey.list.OK) do
			if e:isDownEdge(i) then
				e:tag{"exec", command="skip", mode="1"}
				flg.title.skipflag = true
				break
			end
		end
	end

	----------------------------------------
	-- ムービー再生が３本指タッチですぐ飛ばないようにする
	if not flg.exclick and scr.movie then
		local t = e:getTouchCount()
		if scr.movie.ctrlskip then
			if t == 0 then
				scr.movie.ctrlskip = nil
			else
				e:overrideKey{ status=0 }
			end
		elseif e:isDown(140) then
			scr.movie.ctrlskip = true
			e:overrideKey{ status=0 }

		-- 停止をUpEdgeにする
		elseif e:isDown(1) then		e:overrideKey{ status=0 }
		elseif e:isUpEdge(1) then	e:overrideKey{ key=1, status=32 }
		end

	----------------------------------------
	-- automode / skipmode
--	elseif flg.skipmode or flg.automode then
--[[
	elseif flg.skipmode then
		if not flg.skipstop then
			for i, v in pairs(csv.advkey.list.MWCLICK) do
				-- isDown()にするとボタンのmouse upでskip停止するので注意(レスポンス悪くなるけどやむを得ず)
				if e:isDownEdge(i) then
					flg.skipstop = true
--					message("skip", i, v, e:now())
					e:overrideKey{ status=0 }
--					e:overrideKey{ key=1, status=32 }
					break
				end
			end
		end
]]
	----------------------------------------
	-- transをclickで飛ばす処理
	elseif flg.trans then
		-- ui
		if flg.ui or flg.dlg then
			for i, v in pairs(csv.advkey.list.OK) do
				if e:isDownEdge(i) then
					e:overrideKey{ status=0 }
					e:overrideKey{ key=(124), status=32 }
					break
				end
			end

		-- game中
		else
			for i, v in pairs(csv.advkey.def) do
				if v.adv == "CLICK" and e:isDownEdge(i) then
					e:overrideKey{ status=0 }
					e:overrideKey{ key=(124), status=32 }
					break
				end
			end
		end

		-- ホイール上は殺しておく
		if e:isDownEdge(136) then e:overrideKey{ status=0 } end

	----------------------------------------
	-- 指定ボタンを押す
	elseif flg.exclick then
		e:overrideKey{ status=0 }
		e:overrideKey{ key=(flg.exclick), status=32 }
		flg.exclick = nil

	----------------------------------------
	-- ゲーム画面
	elseif not flg.ui and (flg.click or scr.select) and scr.mw.msg then
--		if e:isDown(152) or e:isDown(154) then
--			flg.m = e:getMousePoint()
--		elseif e:isUpEdge(152) or e:isUpEdge(154) then
--			flg.m = nil
--		end
		if e:isDown(1) then flg.m = e:getMousePoint() end
--[[
		-- タブレットモード / あぶのま
		if conf and conf.tablet == 1 then
			-- 上フリック
			if e:isUpEdge(151) or debug_flag and e:isDownEdge(104) then
				local m = e:getMousePoint()
				if m.y > 500 then
					e:overrideKey{ status=0 }
					e:overrideKey{ key=(126), status=32 }
				end
			end
		end
]]
		-- ↓＋×＋L1
		if e:isDown(27) and e:isDown(40) and e:isDown(115) then
			e:overrideKey{ key=27 , status=0 }
			e:overrideKey{ key=40 , status=0 }
			e:overrideKey{ key=115, status=32 }
			flg.ex2skip = true
		end

		----------------------------------------
		-- F4キー(START)はボタンが離された時に実行する
--		local k = 115
--		if e:isDown(k) then e:overrideKey{ key=(k), status=0 } elseif e:isUpEdge(k) then e:overrideKey{ key=(k), status=32 } end

	----------------------------------------
	-- bgmmode
--[[
	elseif flg and flg.repflag and flg.bgmrep then
		if flg.bgmrep < e:now() then
			flg.repflag = nil
			extra_bgm_autostop()
		end

	----------------------------------------
	-- title automovie
	elseif flg.titlemovie then
		if flg.titlemovie < e:now() then
			flg.titlemovie = nil
			title_automovie()
		end
]]
	----------------------------------------
	-- extra
	elseif appex and appex.exfg then
		if e:isDown(16) then appex.shlock = true else appex.shlock = nil end
	end
end
----------------------------------------
-- 
function tap_kill()
	e:overrideKey{ key=1  , status=0 }	-- tap
--	e:overrideKey{ key=114, status=0 }	-- F4 SELECT
--	e:overrideKey{ key=115, status=0 }	-- F5 START
	e:overrideKey{ key=139, status=0 }	-- double touch
	e:overrideKey{ key=140, status=0 }	-- triple touch
	e:overrideKey{ key=143, status=0 }	-- long tap
	e:overrideKey{ key=151, status=0 }	-- flick up
	e:overrideKey{ key=152, status=0 }	-- flick left
	e:overrideKey{ key=153, status=0 }	-- flick down
	e:overrideKey{ key=154, status=0 }	-- flick right
end
----------------------------------------
-- 
----------------------------------------
-- キー入力待ち開始のとき自動的に呼ばれる
function keyClickStart(e, param)
	-- wait中にsetonpushが実行できないようにする / ただしCLICKは有効
	flg.waitflag = getWaitStatus()
end
----------------------------------------
-- キー入力待ち終了のとき自動的に呼ばれる
function keyClickEnd()
	if getWaitStatus() then flg.waitflag = nil end
	flg.waitparam = nil
end
----------------------------------------
function getWaitStatus()
	local p = e:getScriptWaitReason()
	flg.waitparam = p
	return getWaitStatusCheck(p, true)
end
----------------------------------------
function getWaitStatusCheck(p, f)
	local r = nil
	local c = f and 2 or 1
	local tbl = {
		{ "time", "textTween", "textClearTween", "sound", "video" },
		{ "time", "textClearTween", "sound", "video" },
	}
	if p then
		for k, v in ipairs(tbl[c]) do
			if p[v] then
				r = { v, p[v], e:now() }
				break
			end
		end
	end
	return r
end
----------------------------------------
