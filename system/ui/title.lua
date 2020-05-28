----------------------------------------
-- タイトル画面
----------------------------------------
function title_init()
	gscr.logo = 1

	message("通知", "タイトル画面を開きました")



	----------------------------------------
	-- scene check
	local s = flg.title and flg.title.page
	flg.title = {}
	if s then flg.title.page = true end
	extra = nil			-- シーン用
	flg.skip = nil		-- ctrlskipフラグを倒しておく

	----------------------------------------
	-- extra mode
	if titleextra then
		flg.title.page = true
		titleextra = nil
	end

	scr.mw.mode = nil
	flg.extra_bgm = nil		-- bgm再生番号とか
--	flg.tsysse = "tactive"	-- タイトル用system se

	----------------------------------------
	-- uiの初期化
	csvbtn3("ttl1", "500", csv.ui_title)
	screen_crop("500")
	--title_load2info()
	scr.uifunc = 'ttl1'

	-- ボタンを初期化しておく
	flg.ui = {}
	setonpush_ui(true)

	title_page()

	----------------------------------------
	-- 画面を表示する
	ResetStack()
	estag("init")
	e:tag{"lyprop",id="500.n",visible="0"}
	-- アニメoff もしくはui画面から戻った
	if titlepage or not getSystemEffect() or flg.title.page then
		estag{"uitrans"}
		estag{"title_bgm"}
		estag{"titlecall"}
		
		e:tag{"video",file="movie/hd/sakura.ogv",id="500.z",loop="-1"}
	-- 画面をアニメーションする
	else
		title_skipset(true)
		local o = "system/extend/title_"..game.os..".iet"
		estag{"call", file=(o) }
	end

	estag{"title_skipset"}			-- skip解除
--	estag{"title_cursor"}			-- ボタンアクティブ
	estag{"allkeyon"}
--	estag{"stop"}
	estag{"jump", file="system/ui.asb", label="stop" }
	estag()
end
----------------------------------------
-- タイトルアニメーションをskipしたときの動作
function title_skipset(flag)
	if flag then
		tag{"skip", allow="1"}
		flg.title.skip = true
	elseif flg.title.skip then
		tag{"skip", allow="0"}
		flg.title.skip = nil

		if flg.title.skipflag then
			tag{"lytweendel", id="500.ch"}
			tag{"lytweendel", id="500.lo"}
			tag{"lytweendel", id="500.d"}
			flg.title.skipflag = nil
		end
	end
end
----------------------------------------
-- BGM制御
function title_bgm()
	local b = init.title_bgm
	if type(b) == "table" then
		local cl = tn(get_eval("g.allclear"))
		local n  = cl == 1 and 2 or 1
		bgm_play{ file=(b[n]) }
	else
		bgm_play{ file=(b) }
	end
end
----------------------------------------
-- 音声ランダム
function titlecall()
	if not titlepage and not flg.title.page then
		local nm = init.trial and "trial" or "titlecall"
		sysvo(nm)
	end
end
----------------------------------------
-- 終了処理
function title_close()
	delbtn('ttl1')		-- 削除
	flg.title = nil
end
----------------------------------------
-- 続きからの状態を表示
function title_load2info(flag)
	local id = getBtnID("info")
	if id then
		if sv.checkopen("cont") then
			tag{"lyprop", id=(id), visible="0"}
		elseif not flag then
			local s  = sys.saveslot
			local no = s.cont
			local t  = s[no]

			-- セーブスロットが空だった場合は塞いでおく
			if not t then
				tag{"lyprop", id=(id), visible="0"}
				setBtnStat('bt_load2', 'c')
				return
			end

			-- thumb
			local path = e:var("s.savepath")..'/'	-- savepath
			local ss   = csv.mw.savethumb			-- サムネイル位置
			local th   = path..t.file
			local thid = id..".1"					-- サムネイルid

			-- HEVマスク
			local evm = t.evmask
			if init.game_evmask and evm then
				local pppx = ":hev/"..evm
				lyc2{ id=(thid), file=(pppx), x=(ss.x), y=(ss.y)}
			else
				lyc2{ id=(thid), file=(th), x=(ss.x), y=(ss.y)}
			end
			local time = os.date("%Y/%m/%d %H:%M", t.date)
			local tttl = t.title or ""
			local tttx = t.text or ""
			ui_message((id..'.20'), { 'loadno', text="Continue"})		-- セーブNo
			ui_message((id..'.21'), { 'loadday',text=(time)})			-- セーブ日付／ゲーム内
			ui_message((id..'.22'), { 'load'   ,text=(tttx)})			-- セーブテキスト
			ui_message((id..'.23'), { 'loadttl',text=(tttl)})			-- セーブタイトル
			tag{"lyprop", id=(id), visible="0"}
		else
			ui_message(id..'.20')
			ui_message(id..'.21')
			ui_message(id..'.22')
			ui_message(id..'.23')
		end
	end
end
----------------------------------------
function title_over2() tag{"lyprop", id=(getBtnID("info")), visible="1"} end
function title_out2()  tag{"lyprop", id=(getBtnID("info")), visible="0"} end
----------------------------------------
-- 体験版
function title_trial()
	if getTrial() and game.pa then
		flg.title.page = true
		title_page()
		uitrans()
	end
end
----------------------------------------
-- 体験版
function title_trialexit()
	if getTrial() and game.pa and flg.title.page then
		se_cancel()
		flg.title.page = nil
		title_page()
		uitrans()
	else
		adv_exit()
	end
end
----------------------------------------
-- omake
function title_page()
	local p = flg.title.page
	if game.pa then
		if not p then
		--	e:tag{"lyprop", id="500.tr", visible="0"}
		--	e:tag{"lyprop", id="500.d" , visible="1"}
		else
			local path = game.path.ui.."title/trbg"
		--	lyc2{ id="500.tr.0", file=(path) }
		--	e:tag{"lyprop", id="500.tr", visible="1"}
		--	e:tag{"lyprop", id="500.d" , visible="0"}
		end
	end
end
----------------------------------------
-- アクティブ制御
----------------------------------------
-- アクティブボタン制御
function title_cursor()
	if game.os ~= "android" then
		local s = titlepage or game.cs and 'bt_start'
		if s then btn_active(s) end
	end
end
----------------------------------------
function title_helpover(e, p)
	local nm = p.name or btn.cursor
	if nm then
		local v1 = getBtnInfo(nm)
		local v2 = getBtnInfo("message")
		local p2 = tn(v1.p2)
		local clip = v2.cx..","..(v2.cy + v2.ch * p2)..","..v2.cw..","..v2.ch
		tag{"lyprop", id="500.help", visible="1", clip=(clip)}
		flg.title.help = nm
	end
end
----------------------------------------
function title_helpout(e, p)
	local nm = p.name or btn.cursor
	local sp = flg.title.help
	if nm and nm == sp and game.os ~= "android" then
		tag{"lyprop", id="500.help", visible="0"}
		flg.title.help = nil
	end
end
----------------------------------------
-- ボタン類
----------------------------------------
-- クリック動作
function title_click(e, param)
	local bt = btn.cursor
	if bt then
--		message("通知", bt, "が選択されました")
		flg.tsysse = nil
		flg.titlemovie = nil
		titlepage = bt

		local v = getBtnInfo(bt)
		local p1 = v.p1
		local p2 = v.p2
		local sw = {
			start = function() se_start() sysvo(v.p3)		title_start(p2) end,	-- スクリプト開始
			load  = function() se_ok() 						adv_load() end,			-- load画面
			qload = function() se_ok()						adv_qload() end,		-- qload
			conf  = function() se_ok() 						adv_config() end,		-- config画面
			exit  = function() se_ok()						adv_exit()  end,		-- 終了
			info  = function() se_ok()						adv_info() end,			-- info
			cont  = function() se_ok() sysvo("load2")		title_load() end,		-- 最新の続きから
			menu = function() se_ok() title_menu_on() end,
			ret = function() se_cancel() title_menu_off() end,
			trial = function() se_ok() sysvo("extra")		title_trial() end,		-- 体験版おまけ
			extra = function() se_ok() sysvo("extra")		title_extra() end,		-- おまけ
			cg    = function() se_ok()						title_extra("cgmd") end,
			scene = function() se_ok()						title_extra("scmd") end,
			bgm   = function() se_ok()						title_extra("bgmd") end,
		}
		if sw[p1] then sw[p1]() end
	end
end
----------------------------------------
-- extra呼び出し
function title_extra(nm)
	-- 体験版
	if getTrial() then


	-- 本編
	else
		local name = gscr.extraname or nm or "cgmd"
		extra_init(name)
	end
end
----------------------------------------
-- menu on
function title_menu_on()
	
	e:tag{"lyprop",id="500.lo",visible="0"}
	e:tag{"lyprop",id="500.brlo",visible="0"}
	e:tag{"lyprop",id="500.d",visible="0"}
	e:tag{"lyprop",id="500.n",visible="1"}
	uitrans(300)
end
----------------------------------------
-- menu off
function title_menu_off()
	
	e:tag{"lyprop",id="500.d",visible="1"}
	e:tag{"lyprop",id="500.lo",visible="1"}
	e:tag{"lyprop",id="500.brlo",visible="1"}
	e:tag{"lyprop",id="500.n",visible="0"}
	uitrans(300)
end
----------------------------------------
-- 前回のつづきから
function title_auto()
	local no = sys.saveslot.cont
	if no then
		local p = get_savedatatime(no)
		if p then
			se_ok()
			e:tag{"var", name="t.file", data=(p.file..".dat")}
			e:tag{"call", file="system/ui.asb", label="title_autoload"}
		else
			e:tag{"dialog", title="通知", message="最新のセーブデータが見つかりませんでした"}
		end
	end
end
----------------------------------------
-- 最後にセーブされたデータを読み出す
function title_load()
	local v = sys.saveslot or {}
	local f = v.cont
	if f then
		sv.load(f, { mode="cont" })
	end	
end
----------------------------------------
-- ムービー再生
function title_movie()
	local time = 1500
	allkeyoff()
	bgm_stop{ time=(time) }
	lyc2{ id="900", file=(init.black) }
	tag{"var", name="t.time" , data=(time)}
	tag{"var", name="t.movie", data=(init.title_movie)}
	tag{"jump", file="system/ui.asb", label="title_automovie"}
end
----------------------------------------
function title_movieend()
	tag{"return"}
	tag{"lydel", id="900"}
	title_init()
end
----------------------------------------
-- ボタン類
----------------------------------------
-- ゲーム開始
function title_start(nm)
	local file = init[nm] or nm
	titlepage = nil
	allkeyoff()			-- キー停止
	autoskip_ctrl()		-- ctrlキー停止

	--------------------------------
	-- 起動
	--------------------------------
	estag("init")
	estag{"title_reset"}
	estag{"eqwait", 1000}
	estag{"title_start2", file}
	estag()
end
--------------------------------
function title_reset()
	-- uiの初期化
	title_load2info(true)
	delbtn('ttl1')		-- 削除

	-- fadeout
	local time = init.start_fadetime or init.bgm_fade
	allsound_stop{ time=(time) }

	-- 背景
	local s	= init.start_bg or "black"
	local dtbg = init[s] or s

	-- delete
	tag{"lydel", id="1"}
	tag{"lydel", id="500"}
	tag{"lydel", id="600"}
	tag{"lydel", id="ui"}
	lyc2{ id="startmask", file=(dtbg)}
	uitrans(time)

	-- cache削除
	title_cachedelete()
end
--------------------------------
-- スクリプトファイルを呼び出す
--------------------------------
function title_start2(nm)
	-- スタックを空にしておく／[return]でfirst.iet*topに戻る
	ResetStack()

	----------------------------------------
	-- 内部変数初期化
	appex = nil
	extra = nil
	scr = nil
	vartable_init()
	reset_backlog()
	key_reset()
	sv.delpoint()		-- セーブ情報を念のため初期化しておく
	----------------------------------------

	-- adv[]を初期化
	adv_flagreset()

	-- 念のため削除
	e:tag{"lydel", id="1"}

	-- 白bg
	local b = init.start_bg or "black"
	lyc2{ id="startmask", file=(init[b])}

--	loading_off()
--	flip()

	-- キー許可
--	allkeyon()

	-- スクリプトを呼び出す
	ast = nil
	scr.ip = nil
	local file = init.trial and init.trial_script or nm

	message("通知", file, "を呼び出します", no)
	readScriptStart(file, nil, v)
	return 1
end
----------------------------------------
-- 動画自動再生
function title_automovieset()
	flg.titlemovie = e:now() + init.automovie
end
----------------------------------------
function title_automovie()
	allkeyoff()
	bgm_stop{}			-- 次の曲
	tag{"var", name="t.bg", data=(init.black)}
	tag{"jump", file="system/ui.asb", label="title_automovie"}
end
----------------------------------------
function title_automovieend()
	title_init()
end
----------------------------------------
function getTitle()
	local ret = nil
	if flg.title then ret = true end
	return ret
end
----------------------------------------
function getExtra()
--	local ret = extra and true or sys.extra and sys.extra.event
	local ret = scr.eventflag or appex and true or extra and true or sys.extra and sys.extra.event
	return ret
end
----------------------------------------
function getTrial()
	return init.trial == "on"
end
----------------------------------------
