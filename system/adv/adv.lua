----------------------------------------
-- ADVシステム
----------------------------------------
-- ■ セーブされない
--adv = {}
----------------------------------------
-- ADV初期化
----------------------------------------
function adv_flagreset()
	flg = {}
--	adv = {}
--	setadvbtn()			-- mwボタン再設置
	scr.menu = nil		-- メニューフラグoff
	scr.fsize = getFontSize()
	
end
----------------------------------------
-- 全部停止
function adv_reset()
	adv_cls4()
	reset_bg()
	select_reset()
	allsound_stop{ time=0 }
	reset_voice()

	-- msgoff
	msg_reset()
	autoskip_init()
	allkeyon()
end
----------------------------------------
-- 初期化
function adv_init()
	if not scr.advinit then
		message("通知", "ADVで使用するパラメータを初期化しました")
		-- uiの初期化
		e:tag{"lydel", id="500"}

--		scr.adv = {
--			title = "",		-- スクリプトのタイトル
--			stack = {},		-- スクリプトスタック
--		}

		reset_bg()		-- BG/EVリセット
--		reset_fg()		-- 立ち絵リセット
		reset_voice()	-- 音声リセット
--		reset_delay()	-- delayリセット
--		autoskip_init()	-- autoskip有効
		init_advmw()	-- MW設置
		scr.mw.mode = "adv"
		scr.advinit = true
	end
--	bgcache("save")		-- cache clear
end
----------------------------------------
-- UI呼び出し
----------------------------------------
function open_ui(name)
	if menu_check() then
		releaseStack()
		local exec = {
--			stop = true,
		}
		if not getTitle() then table.insert(exec, { "msg_hide", name}) end
		-- 開いてなかったら初期化
		if not flg.ui then
			se_ok()
			flg.ui = {}
			systemsound("uistop")	-- se停止
--			voice_stopallex()	-- ボイス停止
--			save_autoskip()		-- automodeフラグを格納
			autoskip_disable()	-- automode/skip停止
			--advmw_clear()		-- advボタンクリア
			--notification_clear()-- 通知消去
--			if name == "menu" then se_ok() end
			-- サムネイル保存 / menu|save|load
			local tbl = { menu=1, save=1, load=1, favo=1, blog=1 }
			if tbl[name] then sv.makepoint() end
		end

		-- 開いてる画面があれば閉じる
		if scr.uifunc then
			local nm = scr.uifunc
			if openui_table[nm] then
				message("通知", nm, "を閉じます")
				table.insert(exec, { openui_table[nm][2], {} })
			end
		end
		scr.uifunc = name
		-- L/R
		setonpush_ui()

		-- 関数呼び出し
		if openui_table[name] then
			message("通知", name, "を開きます")
			table.insert(exec, { openui_table[name][1] })
		else
			error_message(func, "は不明な関数です")
		end
		fn.push("ui", exec)
	end
end
----------------------------------------
-- ui画面から抜ける処理／共通
function close_ui()
	local name = scr.uifunc
	sv.delpoint()
	del_uihelp()	-- 一応消しておく
	-- message("通知", name, "を閉じます")

	-- タイトル画面へ
	if getTitle() and not getExtra(true) then
		ReturnStack()	-- 空のスタックを削除
		sysvo("back")
		fn.push("uic", {
			{ openui_table[name][3], name },
			{ title_init },
		})

	-- menu以外ならmenuに戻る
	elseif name ~= 'menu' and name ~= 'blog' and scr.menu then
--		scr.menuopen = name
		fghide()
		sysvo("back")
		open_ui('menu')
		
	-- 閉じる
	else
		
		fghide()
		voice_stopallex(nil, true)
		sysvo("back")
		fgshow() -- advmodeなので戻す
		local s = flg.closecom
		local r = {
			{ openui_table[name][3], name },
			{ systemsound, "replay" },		-- se再開
		}
		if s ~= "adv_msgoff" then table.insert(r, { msg_show, name }) end
		if s then				  table.insert(r, { closeui_go }) end
		fn.push("uic", r)
		scr.uifunc = nil
		flg.ui = nil
	end
end
----------------------------------------
-- 閉じたあとに呼び出す
function closeui_go()
	local nm = flg.closecom
	if nm and (not scr.select or nm == "adv_qsave") then
		e:tag{"calllua", ["function"]=(flg.closecom)}
	end
	flg.closecom = nil
end
----------------------------------------
function adv_backlog()	
	fghide()
	open_ui('blog')	end
function adv_config()  open_ui('conf') end
function adv_save()		
	if not getTitle() then fgshow() end -- セーブ画面に立ち絵を出すためいったん出す
	if not getExtra() then sysvo("open_save") open_ui('save') end end
function adv_load()		if not getExtra() then sysvo("open_load") open_ui('load') end end
function adv_manual()	open_ui('mnal')	end
function adv_tips() open_ui('tips') end
function adv_cgmode()	open_ui('cgmd')	end
function adv_scene()	open_ui('scen')	end
function adv_bgmmode()	open_ui('bgmd')	end
function adv_evmode()	open_ui('exev')	end

function adv_menu()		
	fghide()
	open_ui('menu')	end
function adv_msgoff_to_menu() call_ui('msoftomn','ast') end
----------------------------------------
function adv_flow()
	if not getExtra() and flow_check() then
		open_ui('flow')
	end
end
----------------------------------------
-- ボタン動作
function call_ui(name, flag)
	if menu_check() then
		se_ok()
		advmw_clear()			-- advボタンクリア
		notification_clear()	-- 通知消去
		if not flg.ui then advmw_clear() end
		if flag == "func" then
			if _G[name] then _G[name]()
			else error_message(name.."は実行できない関数です") end
		elseif flag == "ast" then
			tag{"jump", file="system/ui.asb", label=(name)}
		else
			dialog(name)
		end
--	else se_none()
	end
end
----------------------------------------
function adv_click()	flg.exclick = 124 end			-- CLICK
function adv_exit()		call_ui("exit")  end			-- exit
function adv_s_back()	call_ui('sceneback', 'ast') end	-- sceneback
function adv_msgoff()	call_ui("msgoff", 'ast') end	-- MW OFF
function adv_dock()		call_ui("mwdock", 'func')  end	-- MW dock
--function adv_manual()	call_ui("manual", true) end		-- manual
function adv_info()		call_ui("info", 'ast')  end		-- info
function adv_auto()		adv_autostart() end				-- automode
function adv_skip()		adv_skipstart() end				-- skipmode
function adv_screen()	windowmax() end					-- fullscreen / window
----------------------------------------
-- title
function adv_title()
	if getExtra() then
		local nm = init.game_sceneexit or "scene"
		call_ui(nm)
	else
		call_ui("title")
	end
end

----------------------------------------
-- auto/skip用
function autoskip_check()
	local ret = nil
	if menu_check() then
		if not scr.select and not flg.skipmode and not flg.automode then ret = true end
--	else
--		se_none()
	end
	return ret
end
----------------------------------------
-- auto開始
function adv_autostart()
	advmw_clear()		-- advボタンクリア
	if autoskip_check() then
		se_ok()
		automode_start()
	end
end
----------------------------------------
-- skip開始
function adv_skipstart()
	if autoskip_check() then
		if flg.ex2skip then
			se_ok()
			flg.ex2skip = nil
			advmw_clear()			-- advボタンクリア
			e:tag{"jump", file="system/ui.asb", label="exskip"}

		elseif scr.areadflag or conf.messkip == 1 then
			se_ok()
			advmw_clear()			-- advボタンクリア
			skipmode_start()
		else
			advmw_clear("android")	-- advボタンクリア
			se_none()
			notify('未読です。')
		end
	end
end
----------------------------------------
function adv_exskipstart()
	e:tag{"return"}
	e:debugSkip{ index=99999 }
end
----------------------------------------
-- qsave
function adv_qsave()
	if getExtra() then
		message("通知", "シーンモードではqsaveできません")
	elseif menu_check() then
		scr.autosave = nil
		sv.makepoint()
		call_ui("qsave")
	end
end
----------------------------------------
-- qload
function adv_qload()
	advmw_clear("android")	-- advボタンクリア
	if getExtra() then
		message("通知", "シーンモードではqloadできません")
	elseif menu_check() then
		if quickloadCheck() then
			call_ui("qload")
		else
			se_none()
			notify('クイックセーブのデータがありませんでした。')
		end
--	else
--		se_none()
	end
end
----------------------------------------
-- ボイスリプレイ
function adv_replay()
	advmw_clear("android")	-- advボタンクリア
	if menu_check() then
		-- スタックに音声があったらリプレイ
		if table.maxn(scr.voice.stack) > 0 then
			-- automode中なら停止する
			autoskip_stop()
			voice_replay(scr.voice.stack, "adv")
	
		else
			se_none()
			notify('ボイスがありませんでした。')
		end
	end
end
----------------------------------------
-- お気に入りボイス
function adv_favo()
	advmw_clear("android")	-- advボタンクリア
	if menu_check() then
		if table.maxn(scr.voice.stack) > 0 then
--			sysvo("open_save")
			local v = tcopy(get_lastlog())	-- logを整理
			local z = log.stack[#log.stack]
			v.text  = { v[1] }
			v.voice = v.vo
			v.face  = tcopy(z.face)
			v[1] = nil
			v.vo = nil
			flg.favo = v
			open_ui('favo')
		else
			open_ui('favo')
--			se_none()
--			notify('ボイスがありませんでした。')
		end
	end
end
----------------------------------------
-- 前の選択肢に戻る
function adv_selback()
	if init.game_selback == "on" and menu_check() then
		if getExtra() then
			advmw_clear("android")	-- advボタンクリア
			notify('シーン鑑賞では実行できません。')
		else
			local s = getBselPoint()
			if s > 0 then
				call_ui("back")
			else
				advmw_clear("android")	-- advボタンクリア
				se_none()
				notify('これ以上戻れません。')
			end
		end
	end
end
----------------------------------------
-- 次の選択肢に移動
function adv_selnext()
	if init.game_selnext == "on" and menu_check() then
		if getExtra() then
			advmw_clear("android")	-- advボタンクリア
			notify('シーン鑑賞では実行できません。')
		else
			if autoskip_check() then
				if scr.areadflag or conf.messkip == 1 then
					call_ui("next")
				else
					advmw_clear("android")	-- advボタンクリア
					se_none()
					notify('未読です。')
				end
			end
		end
	end
end
----------------------------------------
-- 
function adv_tweet()
	if getExtra() then
		se_none()
		notify('シーンモードではツイートできません。')
	elseif scr.ero then
		se_none()
		notify('Ｈシーンではツイートできません。')
	else
		call_ui("tweet")
	end
end
----------------------------------------
-- 
function adv_suspend()
	if getExtra() then
		se_none()
		notify('シーンモードでは実行できません。')
	else
--		call_ui("sus")
		se_ok()
		if not flg.ui then advmw_clear() end
		sv.suspend()
	end
end
----------------------------------------
function adv_mute()
	if menu_check() then mwdock_mute() end
end
----------------------------------------
-- 左フリック座標チェック / 右だけメニューになる
function adv_lflick()
	if menu_check() then
		local m = flg.m or e:getMousePoint()
		local n = init.game_menu == "on"
		if not n or m.x < game.width - getFlickArea() then
			adv_msgoff()
		else
			adv_menu()
		end
	end
end
----------------------------------------
-- フリック範囲算出
function getFlickArea()
	return repercent(game.width, init.menu_area)
end
----------------------------------------
function adv_dummy()
	message("通知", "何もしない")
end
----------------------------------------
-- windows
----------------------------------------
--
function window_button()
	local lua = init.window_button
	if game.os == "windows" and lua then
		if init.window_maxwindow == "on" then e:tag{"var", name="s.enablemaximizedwindow", data="1"} end	-- 最大化フラグ
		local b1 = init.window_close
		local b2 = init.window_max
		local b3 = init.window_min
		if b1 then e:tag{"setonwindowbutton", button="0", handler="calllua", ["function"]=(b1)} end
--		if b2 then e:tag{"setonwindowbutton", button="1", handler="calllua", ["function"]=(b2)} end
--		if b3 then e:tag{"setonwindowbutton", button="2", handler="calllua", ["function"]=(b3)} end
	end
end
----------------------------------------
-- ×ボタン
function windowclose()
	if not gameexitflag then
		if conf.dlg_exit == 0 then
			se_ok()
			tag_dialog({ varname="t.yn", title="確認", message="ゲームを終了しますか？"}, "windowclose_next")
		else
			sv.go_exit()
		end
	end
end
----------------------------------------
function windowclose_next()
	local yn = tn(e:var("t.yn"))
	if yn == 1 then
		se_ok()
		sv.go_exit()
	else
		se_cancel()
	end
end
----------------------------------------
-- 最小化ボタン
--[[
function windowmin()
	message("通知", "最小化ボタンが押されました")
	tag{"exec", command="minimize"}
end
----------------------------------------
-- 最大化ボタン
function windowmax()
	e:tag{"var", name="t.screen", system="fullscreen"}
	local s = tn(e:var("t.screen"))
	local c = flg.config and gscr.conf.page
	if s == 0 then
		message("通知", "最大化ボタンが押されました")
		local nm = init.windows_screenon
		if nm and c and c == 1 then toggle_change(nm) else conf.window = 1 end
		fullscreen_on()
	else
		message("通知", "ALT+Enterが押されました")
		local nm = init.windows_screenoff
		if nm and c and c == 1 then toggle_change(nm) else conf.window = 0 end
		fullscreen_off()
	end
end
]]
----------------------------------------
-- 
----------------------------------------
-- カーソル追尾
function mouse_autocursor(name, time)
	if game.os == "windows" and conf.mouse == 1 then
--		local tbl = { 3,3,3,3,3,4,5,7,10,15 }
		local tbl = { 0.05, 0.05, 0.05, 0.05, 0.05, 0.07, 0.10, 0.13, 0.19, 0.26 }
		local m = e:getMousePoint()
		local v = getBtnInfo(name)
		local x = v.x + math.floor(v.w / 2) + 10
		local y = v.y + math.floor(v.h / 2) + 10
		local t = time or 60

		-- 計算
		local c  = 0
		local fx = math.floor((x - m.x) / 10)
		local fy = math.floor((y - m.y) / 10)
		for i=1, 10 do
			local tx = math.floor(t * tbl[i])
			eqtag{"calllua", ["function"]="mouse_autocursorlp", x=(fx), y=(fy)}
			eqwait(tx)
			c = c + tx
		end
		if c < time then eqwait(time - c) end
		eqtag{"calllua", ["function"]="mouse_autocursored", name=(name)}
	end
end
----------------------------------------
function mouse_autocursorlp(e, p)
	local m = e:getMousePoint()
	tag{"mouse", left=(m.x + p.x), top=(m.y + p.y)}
end
----------------------------------------
function mouse_autocursored(e, p)
	btn_active2(p.name)
	flip()
end
----------------------------------------
-- info
----------------------------------------
function advinfo_init()
	flg.ui = {}

	message("通知", [[infoを表示します]])

	-- info生成
	local h  = init.info_header
	local tx = init.trial and init.trial_title or init.game_title
	local info	= tx..h[1]..game.ver.."\n"
	info = info..h[2]..init.game_year.." "..init.game_author.."\n\n"
	info = info..e:var("s.copyright").."\n"

	local f = init.info_footer
	if f and e:isFileExists(f) then
		local s = e:file(f)
		for a, z in ipairs(split(s, "\r\n")) do
			info = info..code_utf8(z).."\n"
		end
	end

	local is = init.info_status
	flg.info = {
		text  = split(info, "\n"),
		max   = 0,
--		page  = 0,
--		count = 0,
		line  = is[1]
	}
	flg.info.max  = table.maxn(flg.info.text)
--	flg.info.page = math.floor(flg.info.max / flg.info.add) + 1

	set_textfont("info", "info.1")
	e:tag{"chgmsg", id="info.1", layered="0"}
--	e:tag{"rp"}

	-- show
	e:tag{"scetween", mode="init", type="in"}
	e:tag{"scetween", mode="add" , type="in",  param="alpha",  time=(is[2]), delay=(is[3]), diff="-255", ease="none"}
	e:tag{"scetween", mode="add" , type="in",  param="left",   time=(is[2]), delay=(is[3]), diff="40",   ease="easeout_quad"}
	e:tag{"scetween", mode="add" , type="in",  param="top",    time=(is[2]), delay=(is[3]), diff="20",   ease="easeout_quad"}
	e:tag{"scetween", mode="add" , type="in",  param="xscale", time=(is[2]), delay=(is[3]), diff="600",  ease="easein_quad"}
	e:tag{"scetween", mode="add" , type="in",  param="yscale", time=(is[2]), delay=(is[3]), diff="600",  ease="easein_quad"}
	e:tag{"scetween", mode="add" , type="in",  param="rotate", time=(is[2]), delay=(is[3]), diff="180",  ease="easeout_quad"}

	-- hide
	e:tag{"scetween", mode="init", type="out"}
	e:tag{"scetween", mode="add" , type="out", param="alpha",  time=(is[4]), delay=(is[5]), diff="-255", ease="none"}
	e:tag{"scetween", mode="add" , type="out", param="xscale", time=(is[4]), delay=(is[5]), diff="800",  ease="easeout_quad"}
	e:tag{"scetween", mode="add" , type="out", param="yscale", time=(is[4]), delay=(is[5]), diff="-100", ease="easeout_quad"}
	e:tag{"/chgmsg"}
	e:tag{"chgmsg", id="info.1", layered="0"}
end
----------------------------------------
-- info loop
function advinfo_loop(e, p)
	local v = flg.info
	local c = v.count or 1
	local p = v.page  or 0
	local m = v.line

	e:tag{"rp"}
	for i=1, m do
		e:tag{"print", data=(v.text[p+i])}
		e:tag{"rt"}
	end
--	eqwait{ scenario="1" }
	eqwait()

	-- 計算
	local f = 1
	flg.info.page = p + m
	if flg.info.page > v.max then f = 0 end
	e:tag{"var", name="t.exit", data=(f)}
end
----------------------------------------
-- info抜ける
function advinfo_exit(e, param)

	message("通知", "infoを終了します")

	e:tag{"rp"}
	e:tag{"/chgmsg"}
	flg.info = nil
	flg.dlg = nil
end
----------------------------------------
