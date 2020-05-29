----------------------------------------
-- 初期化
----------------------------------------
-- ■ lua読み込み
function system_loadinglua()

	-- luaの登録
	local luafile = {
		-- system
		"adv/var",			-- 内部変数
		"adv/fileio",		-- ファイル入出力 / system
		"adv/fsave",		-- ファイル入出力 / saveload
		"adv/parse",		-- parse csv
		"adv/func",			-- 汎用関数群

		-- base system
		"adv/system",		-- システム制御
		"adv/mainloop",		-- スクリプト制御
		"adv/vsync",		-- vsync制御
		"adv/autoskip",		-- auto/skip制御
		"adv/button",		-- ボタン制御
		"adv/select",		-- 選択肢制御
		"adv/keyconfig",	-- keyconfig制御
		"adv/quickjump",	-- quickjump制御
--		"adv/vita",			-- Vita専用

		-- game system
		"adv/adv",			-- ADV制御
		"adv/delay",		-- delay制御

		-- message
		"msg/message",		-- メッセージ制御
		"msg/line",			-- メッセージ制御 / LINE
		"msg/mw",			-- メッセージウィンドウ
		"msg/ui",			-- UIメッセージ
		"msg/tablet",		-- タブレットUI

		-- image
		"image/image",		-- 画像汎用
		"image/image_sys",	-- system
		"image/image_bg",	-- BG/EV
		"image/image_fg",	-- 立ち絵
		"image/image_act",	-- アクション制御
		"image/cache",		-- キャッシュ制御

		-- media
		"media/sound",		-- 音楽
		"media/bgm",		-- BGM
		"media/mbgm",		-- 複数BGM再生
		"media/se",			-- SE
		"media/ese",		-- 環境音
		"media/sysse",		-- SystemSE
		"media/voice",		-- voice
		"media/movie",		-- 動画

		-- script
		"extend/adv_mw",	-- ADV MW制御
		"extend/macro",		-- マクロ再現用
		"extend/script",	-- 移植元スクリプト
		"extend/staff",		-- スタッフロール

		-- ui
		"ui/menu",			-- 右クリックメニュー制御
		"ui/backlog",		-- バックログ制御
		"ui/sceneback",		-- シーンバック制御
		"ui/config",		-- config制御
		"ui/save",			-- save/load制御
		"ui/dialog",		-- dialog制御
		"ui/title",			-- タイトル画面
		"ui/tips",			-- Tips
		-- extra
		"extra/extra",		-- 鑑賞共通
		"extra/cg",			-- おまけCG
		"extra/scene",		-- おまけシーン
		"extra/bgm",		-- おまけBGM
	}

	-- luaバイナリがあれば優先して登録する
	for i, val in ipairs(luafile) do
		local file = 'system/'..val..'.lua'
--		e:tag{"var", name="t.file", system="file_exist", file=(file), save="0"}
--		if e:var("t.file") == "0" then file = 'system/'..val..'.lua' end
		e:include(file)
	end
	allkeyoff()

	----------------------------------------
	-- OSとバージョン
	game = { path={} }
	e:tag{"var", name="game.os", ["system"]="os"}
	game.os = e:var("game.os")
	game.trueos = game.os

	-- 画面サイズ
	e:tag{"var", name="game.width",  ["system"]="screen_width"}
	e:tag{"var", name="game.height", ["system"]="screen_height"}
	local w = tn(e:var("game.width"))
	local h = tn(e:var("game.height"))
	game.width	= w
	game.height	= h
	game.centerx = math.floor(w / 2)
	game.centery = math.floor(h / 2)

	----------------------------------------
	-- debug
	local d = "debug/lua/index.lua"
	if e:isFileExists(d) then
		e:include(d)

		-- fake OS
		local d = deb and deb.fake
		if d and game.os ~= "vita" and game.os ~= "ps4" then
			if d == 'auto' then
					if w ==  960 then d = 'vita'
				elseif w == 1920 then d = 'ps4'
				else d = 'windows' end
			end
			game.os = d
		end
	end

	----------------------------------------
	-- PS判定
	local gos = game.os
	local tos = game.trueos
	local tbl = {
		windows = { pa=1, sh=1 },
		android = { pa=1 },
		ios		= { pa=1 },
		iphone		= { pa=1 },
		vita	= { cs=1, sh=1, ps=1 },
		ps4		= { cs=1, sh=1, ps=1 },
		switch	= { cs=1 },
	}
	local v1 = tbl[gos]		-- os判定
	local v2 = tbl[tos]		-- 実機判定
	if v1.pa then game.pa = true end		-- Windows / android / iOS
	if v1.ps then game.ps = true end		-- PS4 /Vita
	if v1.cs then game.cs = true end		-- PS4 /Vita / Switch
	if v1.sh then game.sh = true end		-- Shader OK
	if v2.ps then game.trueps = true end	-- PS実機
	if v2.cs then game.truecs = true end	-- CS実機

	----------------------------------------
	-- 変換したcsv.lua
	local name = "list_"..gos
	e:include("system/table/"..name..".tbl")

	-- フローチャートのテーブルを呼んでおく
--	e:include("system/flow.tbl")

	----------------------------------------
	-- 設定
	set_caption()	-- ウインドウタイトル設定
	screen_init()	-- 画面初期化
end
----------------------------------------
-- ■ データ読み込み
function system_dataloading()
	load_system()	-- $g→sys
	load_global()	-- $g→gscr
	conf = fload_pluto(init.save_config)

	-- 初回起動
	if not conf then

		-- config初期化
		config_default()

	-- 初回以外
	else
		-- configのデータが壊れていたら初期化する
		if conf and ( not conf.bgm or not conf.se or not conf.voice or not conf.aspeed or not conf.mspeed ) then
			e:tag{"dialog", title="通知", message="システムデータを再初期化しました"}
			config_default()
		end
	end
end
----------------------------------------
-- ■ 初期化
function system_initialize()
	----------------------------------------
	-- 各種操作を禁止する
	e:tag{"alreadyread",  mode="0"}	-- 既読データを保存しない
	e:tag{"writebacklog", mode="0"}	-- 使用しないので常に"0"にしておく
	e:tag{"backlog",	allow="0"}	-- 使用しないので常に"0"にしておく
	e:tag{"hide",		allow="0"}	-- 使用しないので常に"0"にしておく
	e:tag{"rclick",		allow="0"}	-- 使用しないので常に"0"にしておく
	e:tag{"skip",		allow="0"}	-- 停止しておく
	e:tag{"automode",	allow="0"}	-- 停止しておく
	e:tag{"autosave",	allow="0"}	-- 停止しておく
	-- setonpushを停止しておく
	for i=1, init.max_keyno do e:tag{"delonpush", key=(i)} end

	-- keyconfigを停止しておく
	for i=0, 16 do e:tag{"keyconfig", role=(i), keys=""} end
--	e:tag{"keyconfig", role="0", keys="1,13"}
--	e:tag{"keyconfig", role="1", keys="2,27"}
	e:tag{"keyconfig", role="0", keys="124"}	-- dummy click

	e:setUseMultiTouch(3)			-- マルチタッチ数を制限
--	e:setFlickSensitivity(-1)		-- エンジンのフリックを無効化

	----------------------------------------
	-- 初期化
	vartable_init()		-- 変数初期化
	storage_path()		-- storage path
	system_cache()		-- ui cache
	font_init()			-- font設定
	setonpush_init()	-- key設定
	key_reset()			-- key flag
	reset_backlog()		-- 念のためバックログをリセット
	volume_master()		-- ボリューム復帰

	----------------------------------------
	-- システムスクリプトをキャッシュしておく
	e:enqueueTag{"call", file="system/ui.asb",		 label="last"}
	e:enqueueTag{"call", file="system/save.asb",	 label="last"}
	e:enqueueTag{"call", file="system/script.asb",	 label="last"}

	----------------------------------------
	-- ■ 登録
	e:setEventHandler{
		onSave		   = "store",			-- セーブ直前に呼ばれる
		onLoad		   = "restore",			-- ロード直後に呼ばれる
		onClickWaitIn  = "keyClickStart",	-- キークリック待ち開始時に呼ばれる
		onClickWaitOut = "keyClickEnd",		-- キークリック待ち終了時に呼ばれる
		onDebugSkipOut = "exskip_end",		-- debugSkip停止時
		onEnterFrame   = "vsync"
	}

	-- ui用ctrlskip
	autoskip_uiinit(true)
end
----------------------------------------
-- ■ 起動チェック
function system_starting()

	e:tag{"autosave",	allow="1"}	-- autosave有効化
	allkeyon()

	-- フルスクリーン
	fullscreen_on()
	mouse_autohide()
	window_button()
	loading_off()

	--------------------------------
	-- suspend
	local sus = init.save_suspend
	if sus then
		local file = sv.makefile(sus)..".dat"
		if e:isFileExists(e:var("s.savepath").."/"..file) then
			suspend_load = true
			eqtag{"load", file=(file)}
			return
		end
	end

	--------------------------------
	local dflag = true
	if debug_flag and not androidreset then dflag = debugInit() end

	-- movie復帰
	if androidreset then
		local p = androidreset
		local b = p.ip.block
		local c = p.ip.count or 0
		scr = p
		readScript(p.ip.file)
		scr.ip.block = b		-- p.ip.block
		scr.ip.count = c + 1	-- p.ip.count
		androidreset = nil
--		scriptMainAdd()
		movie_play_exit(e)
		scr.advinit = nil
		adv_init()
		flip()
		e:tag{"jump", file="system/script.asb", label="main"}

	-- logo skip
	elseif systemreset then
		systemreset = nil
		base_fontcache()
		eqtag{"jump", file="system/first.iet", label="title"}

	-- game start
	elseif dflag then
		eqtag{"jump", file="system/first.iet", label="game_start"}
	end
end
----------------------------------------
-- ■ ブランドロゴ
----------------------------------------
function brand_logo() 
	callscript("system", init.brand_script)
end
----------------------------------------
function brandlogo(p)
	local file = p.file
	local mode = p.mode
	local path = game.path.ui
	local v  = flg.logo or {}
	local id = 10
	local tr = { sys=2, time=(v.time) }

	-- 初期化
	if mode then
		message("通知", "ブランドロゴを表示します")
		if not flg then flg = {} end
		flg.logo = {}
		flg.logo.file  = init[mode] or path..mode
		flg.logo.time  = tn(p.time or 1000)
		flg.logo.wait  = tn(p.wait or 2500)
		flg.logo.count = 1

		-- 表示
		local v = flg.logo
		lyc2{ id=(id), file=(v.file) }
		uitrans{ sys=2, time=(v.time) }

	-- リセット
	elseif not file then
		estag("init")
		estag{"lyc2", { id=(id), file=(v.file) }}
		estag{"uitrans", tr}
		estag{"brandlogo_windowsexit"}
		flg.logo = nil

		-- title cache
		estag{"title_cache"}
		estag{"title_cachewait"}

		-- titleへ
		estag{"lydel", id=(id)}
		estag{"jump", file="system/first.iet", label="title"}
		estag()

	-- 画像表示
	else
		estag("init")
		local c = v.count
		if c > 1 then
			estag{"lyc2", { id=(id), file=(v.file) }}
			estag{"uitrans", tr}
		end
		flg.logo.count = c + 1

		-- 表示
		local m = tn(p.movie) or 0
		if m == 0 then
			estag{"lyc2", { id=(id), file=(path..file) }}
			estag{"uitrans", tr}
		end

		-- brand call
		if p.sysvo then estag{"sysvo", p.sysvo} end

		-- movie
		if m == 2 then
			local px = game.path.movie..file..".ogv"
			message("通知", px)
			estag{"video", id=(id), file=(px)}
			estag{"flip"}
			estag{"eqwait", { video=(id), input="2"} }
		elseif m ~= 0 then
			tag{"keyconfig", role="1", keys=(getKeyString("ALL"))}
			local px = game.path.movie..file..game.movieext
			message("通知", px)
			estag{"video", file=(px), skip="2"}
		else
			-- wait
			estag{"eqwait", v.wait }
		end
		estag{"keyconfig", role="1", keys=""}
		estag()
	end
end
----------------------------------------
-- 動画再生中に×ボタンが押されると抜けられなくなる対処
function brandlogo_windowsexit()
	if gameexitflag then tag{"exit"} end
end
----------------------------------------
--
----------------------------------------
-- ■ font初期化
function font_init()
	local c = 0
	for name, v in pairs(csv.font) do
		if v.show == 'cache' then
			local id = 'fontcache.'..c
			set_textfont(name, id)
			e:tag{"chgmsg", id=(id), layered="1"}
			e:tag{"print", data="　"}
--			e:tag{"rp"}
			e:tag{"/chgmsg"}
			c = c + 1
		elseif v.show ~= 'none' then
			set_textfont(name, name)
		end
	end

	if c ~= 0 then
		e:tag{"lyprop", id="fontcache", left=(game.width), visible="0"}
	end
end
----------------------------------------
-- テキストレイヤーにfontを設定
function set_textfont(name, id, flag)
--	console('【通知】テキストレイヤー'..name..'('..id..')を設定しました')

	-- １回だけ通過する
	if not flg.textfont then flg.textfont = {} end
	if not flg.textfont[name] then flg.textfont[name] = {} end
	if not flag and flg.textfont[name][id] then return end
	flg.textfont[name][id] = true

	-- 登録
	local font = tcopy(csv.font[name])
	local ly   = font.layered or 0
	e:tag{"chgmsg", id=(id), layered=(ly)}
	e:tag{"fontinit"}
	font[1] = 'font'
	font.face     = font.face and init[font.face] or 'ＭＳ ゴシック'
	font.rubyface = font.ruby and init[font.ruby]
	e:tag(font)

	-- show/hide
	local s = font.show
	if s and s ~= 'none' and s ~= 'cache' then
		e:tag{"scetween", mode="init", type="show"}
		e:tag{"scetween", mode="add",  type="show", param="alpha", ease="none", diff="0", time=(s), delay="0"}
		e:tag{"scetween", mode="init", type="hide"}
		e:tag{"scetween", mode="add",  type="hide", param="alpha", ease="none", diff="-255", time=(s), delay="0"}
	end

	-- indent
	local id = font.indent
	if id and init[id] then
		e:tag{"indent", pair=(init[font.indent]), nest="0", range="2"}
	else
		e:tag{"indent", pair="", nest="0", range="0"}	-- indent無効化
		e:tag{"wordparts", parts="!"}					-- 英単語判定無効化
	end

	-- prohibit
	local pr = tn(font.prohibit)
	if pr == 2 then e:tag{"prohibit", head="！？、。」』）", foot="「『（"}
	elseif pr then	e:tag{"prohibit", head=(init.prohibit_head), foot=(init.prohibit_foot)}
	else			e:tag{"prohibit", head=" ", foot=" "} end
	e:tag{"/chgmsg"}
end
----------------------------------------
-- ■ 起動時に１回だけ読み込まれる
function screen_init()

	-- 画面サイズ
	e:tag{"var", name="game.width",  ["system"]="screen_width"}
	e:tag{"var", name="game.height", ["system"]="screen_height"}
	game.width	= tonumber(e:var("game.width"))
	game.height	= tonumber(e:var("game.height"))

	-- 中心座標
	game.centerx = game.width / 2
	game.centery = game.height / 2
	game.ax = game.centerx
	game.ay = game.os == 'vita' and game.centery - 2 or game.centery

	-- ゲーム倍率 	1:1280 0.75:960  1.5:1920
	--				1:1920 0.75:1280 0.5:960
	local s = init.game_scale
	game.scalewidth  = s[1]
	game.scaleheight = s[2]
	game.sax = s[1] / 2
	game.say = s[2] / 2
	game.scale = 1
	if game.width ~= s[1] then game.scale = game.width / s[1] end

	-- OSとバージョン
--	e:tag{"var", name="game.os", ["system"]="os"}
--	game.os  = e:var("game.os")
	game.ver = "1.0"
	if init["game_ver_"..game.os] then game.ver = init["game_ver_"..game.os] end
	e:tag{"var", name="game.ver", data=(game.ver)}
	scr.gamever = game.ver

	-- フリックエリア
	local a = 100
	if init.menu_area then a = repercent(init.menu_area, game.width) end
	game.flickarea = a

	-- システムバージョンチェック
	game.sysver = e:var("s.engineversion")

	-- セーブデータの最大値などを作っておく
	game.savemax   = init.save_page * init.save_column	-- ページ数×１ページに表示できる数
	if init.save_etcmode == "quick" then
		game.qsavehead = game.savemax						-- quicksaveの先頭番号
		game.asavehead = game.qsavehead + init.qsave_max	-- autosaveの先頭番号
	else
		game.asavehead = game.savemax						-- autosaveの先頭番号
		game.qsavehead = game.asavehead + init.asave_max	-- quicksaveの先頭番号
	end
end
----------------------------------------
-- パス初期化
function storage_path()
	local s = init.system
	local tros = game.trueos
	local gmos = game.os
	local image = s.image_path
	local sound = s.sound_path
	local movie = s.movie_path
	if gmos == "vita" and tros == "windows" then sound = s.fake.sound_path end

	----------------------------------------
	-- magicpathcheck
	local setpath = function(nm, path)
		local s = path:sub(-1)
		if s == '/' then
			e:debug(nm.." "..path.." パスの末尾に / が付いていると正しく動作しません")
		else
			e:setMagicPath{nm,	path}
		end
	end

	----------------------------------------
	-- magicPath
	for k, v in pairs(init.mpath.image) do setpath(k, image..v) end
	for k, v in pairs(init.mpath.sound) do setpath(k, sound..v) end
--	for k, v in pairs(init.mpath.movie) do setpath(k, movie..v) end

	----------------------------------------
	-- movieはmagicpathが使えないので特殊処理
	game.path.movie	= movie			-- movie path

	----------------------------------------
	-- etc path
	game.path.rule		= image..init.mpath.image.rule..'/'
--	game.path.facemask	= form..image..init.face_path..'/mask'

	----------------------------------------
	-- ui path
	local lang = conf.language or "ja"
	local path = init.lang[lang]
	game.path.ui		= s.ui_path..path

	----------------------------------------
	-- 拡張子
	game.fgext	  = s.fg_ext		-- 立ち絵
	game.ruleext  = s.rule_ext		-- rule
	game.movieext = s.movie_ext		-- movie
	game.soundext = s.sound_ext		-- sound
	if gmos == "vita" and tros == "windows" then game.soundext = s.fake.sound_ext end

	----------------------------------------
	-- etc
	game.mwid			= init.mwid						-- mwid
	game.language		= init.game_language or 'ja'	-- 言語

	----------------------------------------
	-- 何か読み込んでおかないとVRAMのゴミが残る問題の回避
--	lyc2{ id="-273", file=(init.black), x=(-game.centerx), y=(-game.centery), anchorx=(game.centerx), anchory=(game.centery)}
	lyc2{ id="-273", file=(init.black) }

	-- mask
	game.clip = "0,0,"..game.width..","..game.height
	if init.vita_crop and game.os == 'vita' then
		if tros == 'vita' then
			game.clip = "0,0,960,540"
			game.crop = 4
			lyc2{ id="zzzz.dw", width="960", height="4", color="0xff000000", y="540"} 
		else
			game.clip = "0,2,960,540"
			game.crop = 2
			lyc2{ id="zzzz.up", width="960", height="2", color="0xff000000", y="0"} 
			lyc2{ id="zzzz.dw", width="960", height="2", color="0xff000000", y="542"} 
		end
	end

	----------------------------------------
	-- loading
	loading_icon = nil
	local v = csv.mw
	if v.loading and v.saving then
		local pl = v.loading
		local ps = v.saving
		local path = game.path.ui
		lyc2{ id=(pl.id), file=(path..pl.file), clip=(pl.clip), x=(pl.x), y=(pl.y)}
		lyc2{ id=(ps.id), file=(path..ps.file), clip=(ps.clip), x=(ps.x), y=(ps.y), visible="0"}
		loading_icon = true
	end
	flip()
end
----------------------------------------
function loading_on()	if loading_icon then e:tag{"lyprop", id="zzlogo.load", visible="1"} e:tag{"lyprop", id="zzlogo.save", visible="0"} end end
function loading_off()	if loading_icon then e:tag{"lyprop", id="zzlogo.load", visible="0"} e:tag{"lyprop", id="zzlogo.save", visible="0"} end end
function saving_on()	if loading_icon then e:tag{"lyprop", id="zzlogo.load", visible="0"} e:tag{"lyprop", id="zzlogo.save", visible="1"} end end
function saving_off()	if loading_icon then e:tag{"lyprop", id="zzlogo.load", visible="0"} e:tag{"lyprop", id="zzlogo.save", visible="0"} end end
----------------------------------------
function loading_func(p)
	if loading_icon then
		local flag = p["0"] or 'off'
		local logo = p["1"] ~= "logo" and true
		if flag == 'on' then
			loading_on()
			if logo then lyc2{id="zzlogn", file=(init.black), alpha="128"} end
			flip()
		else
			loading_off()
			if logo then tag{"lydel", id="zzlogn"} end
			flip()
		end
	end
	wt()
end
----------------------------------------
function saving_func(p)
	if loading_icon then
		local flag = p["0"] or 'off'
		if flag == 'on' then saving_on()  lyc2{id="zzlogn", file=(init.black), alpha="128"}
		else				 saving_off() tag{"lydel", id="zzlogn"} end
		flip()
	end
	wt()
end
----------------------------------------
-- loadmask
function loadmask_func(p)
	local f = p["0"] or p.del
	local t = p.time
	if f then
		local v = scr.bgm
		if v then
			local tm = t or init.ui_fade
			local vl = v.vol or 1000
			tag{"sfade", gain=(vl), time=(tm)}	-- bgm復帰

			-- bgv復帰
			local b = scr.lvo
			if b and not flg.ui then
				for i, v in pairs(b) do
					local g = v.p.gain or 1000
					tag{"sefade", id=(v.id), gain=(g), time=(tm)}
				end
			end
		end
		uimask_off()
	else
		local tm = t or init.ui_fade
		tag{"sfade", gain="0", time=(tm)}	-- bgm

		-- bgv fadeout
		local b = scr.lvo
		if b and not flg.ui then
			for i, v in pairs(b) do
				tag{"sefade", id=(v.id), gain="0", time=(tm)}
			end
		end
		uimask_on()
	end
end
----------------------------------------
-- uimask
function uimask_func(p)
	local f = p["0"] or p.del
	if f then	uimask_off()
	else		uimask_on() end
end
function uimask_on()  e:tag{"lyc"  , id="zzamask", file=(init.black)} end
function uimask_off() e:tag{"lydel", id="zzamask"} end
----------------------------------------
-- 
----------------------------------------
-- 中間合成モード
function checkSynthesis()
	local s = init.game_synthesis
	return s == "on" or s == game.os
end
----------------------------------------
-- 画面サイズより大きい範囲は切る
function screen_crop(id)
	if checkSynthesis() then
		tag{"lyprop", id=(id), intermediate_render="2", clip=(game.clip)}
	end
end
----------------------------------------
