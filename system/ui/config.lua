----------------------------------------
-- config制御
----------------------------------------
-- ■ セーブされない
----------------------------------------
-- config
----------------------------------------
function conf_init()
	message("通知", "設定画面を開きました")
	--sysvo("config_open")

	flg.config = {}
	if not gscr.conf then gscr.conf = { page=1 } end
	if not gscr.vosave then gscr.vosave = {} end
	conf.dummy = 100

	-- ボタン描画
	config_page(gscr.conf.page)
	--set_uihelp("500.help", "uihelp")

	-- メニューから来たら一旦閉じる
	-- if scr.menu then
	-- 	e:tag{"jump", file="system/ui.asb", label="config_openmenu"}
	-- else
	-- 	e:tag{"jump", file="system/ui.asb", label="config_open"}
	-- end

	uiopenanime()
	uitrans()
	init_over_help()
end
----------------------------------------
-- ボタン再描画
function conf_init2()
	config_page(gscr.conf.page)
end
----------------------------------------
-- 状態クリア
function conf_reset()
	if p and p.close then
		se_cancel()
	end

	-- 消す前にフラグを取得
	local flag = checkBtnData()

	-- 削除
	--del_uihelp()			-- ui help
	config_textdelete()
	config_delsample()
	delbtn('conf')
	flg.config = nil
	conf.keyconf = nil

	-- 更新があったらセーブする
	if flag and not getTitle() then
		----------------------------------------
		-- font
--		setADVFont()			-- font type
		local p = getText()

		-- 選択肢
		if p.select then
			local s = p.select.mw
			if s then
				tag{"chgmsg", id=(game.mwid..".mw.adv")}
				tag{"rp"}
				tag{"print", data=(s)}
				tag{"/chgmsg"}
			end

		-- [line]
		elseif scr.line then

		else
			-- 再描画
			mw_redraw("sys")
		end

		----------------------------------------
		-- MWfaceのon/off
--		local n = conf.mwface == 1 and scr.mwf
--		image_mwf(n, true)

		----------------------------------------
		-- その他設定
		conf_reload()
	end
end
----------------------------------------
-- 設定画面 / 再設定
function conf_reload()
	set_message_speed()		-- 文字速度書き換え
	set_volume()			-- 音量再設定
	mouse_autohide()		-- mouse

	----------------------------------------
	-- 裸立ち絵
	if game.pa and init.game_hadaka == "on" then
		local v = scr.img.fg
		if v then
			for i, z in pairs(v) do
				fg_hadaka_img(i, z)
			end
		end
		fg_hadaka_mwface()
	end

	----------------------------------------
	-- MWの透明度を変更する
	if scr.mw.mode then mw_alpha() end

	-- ctrlskip無効化
	if conf.ctrl == 0 then
		autoskip_disable()
--		autoskip_init()
	end
end
----------------------------------------
-- 設定画面から抜ける
function conf_close()
--	ReturnStack()	-- 空のスタックを削除
	message("通知", "設定画面を閉じました")
	systemsound("uistop")
	se_cancel()
	uicloseanime()
	conf_reset()

	estag("init")
	estag{"asyssave"}

	-- タイトル画面以外
	if not getTitle() then
		estag{"uitrans", init.ui_fade}
	end
	estag()
	-- タイトル画面以外
	--if not getTitle() then e:tag{"call", file="system/ui.asb", label="config_close"} end
end
----------------------------------------
-- 
----------------------------------------
-- config／再描画
function config_resetview()
	config_default()
	config_page(gscr.conf.page)
	flip()
	btn.renew = true
end
----------------------------------------
function config_p1() se_ok() config_page(1) flip() end
function config_p2() se_ok() config_page(2) flip() end
function config_p3() se_ok() config_page(3) flip() end
function config_p4() se_ok() config_page(4) flip() end
function config_p5() se_ok() config_page(5) flip() end
----------------------------------------
-- config／ページ切り替え
function config_page(page)
	local p  = page or 1
	local vo = gscr.conf.char or 1
	config_delsample()
	config_textdelete()
	
	-- フローチャート範囲外
--	if not flow_check(true) and conf.keys[2] == "FLOW" then
--		conf.keys[2] = "MWOFF"
--	end

	-- ボタン描画
	local help = "config"
	if game.os == "windows" then
		local c = conf.keys[2] conf.keyconf = config_keytonum(c)		-- key
		local name = "ui_config"..p
		csvbtn3("conf", "500", csv[name])
	else
		-- android
		local c = conf.keys[153] conf.keyconf = config_keytonum(c)		-- key
		local name = "ui_config"..p
		csvbtn3("conf", "500", csv[name])
	end

	-- sample text
	config_delsample()
	if p == 2 then
		lyc2{ id="500.zz", width="1", height="1", color="0x00ffffff", left="-20"}
		if conf.language == "ja" then
			btn[btn.name].p["bt2012"].clip = "0,0,86,16"
			btn[btn.name].p["bt2012"].clip_a = "86,0,86,16"
			btn[btn.name].p["bt2012"].clip_c = "172,0,86,16"
		else -- ボタンの横幅が違うので無理くりどうにかする
			btn[btn.name].p["bt2012"].clip = "0,0,86,16"
			btn[btn.name].p["bt2012"].clip_a = "86,0,86,16"
			btn[btn.name].p["bt2012"].clip_c = "172,0,86,16"
		end
		btn_nonactive("bt2012")
		conf_mwsample()
		config_textex()
		ui_message("500.p01", {"confnum", x="255", y="235", text=(conf.mspeed)})
		ui_message("500.p02", {"confnum", x="255", y="315", text=(conf.aspeed)})
		-- ui_message("500.p03", {"confnum", x="94", y="440", text=(conf.mw_alpha)})
	end

	if p == 3 then
		ui_message("500.p01", {"confnum", x="255", y="235", text=(conf.master)})
		ui_message("500.p02", {"confnum", x="750", y="235", text=(conf.bgm)})
		ui_message("500.p07", {"confnum", x="255", y="315", text=(conf.ese)})
		ui_message("500.p03", {"confnum", x="750", y="315", text=(conf.se)})
		ui_message("500.p05", {"confnum", x="255", y="395", text=(conf.sysse)})
		ui_message("500.p06", {"confnum", x="750", y="395", text=(conf.movie)})
		ui_message("500.p04", {"confnum", x="255", y="475", text=(conf.voice)})
		volume_slider01()
		volume_slider02()
		volume_slider03()
		volume_slider04()
		volume_slider05()
		volume_slider06()
		volume_slider07()
	end

	-- タイトル画面
	if getTitle() then
		--setBtnStat('bt_title', 'c')
		--tag{"lyprop", id=(getBtnID("bt_title")), visible="0"}
	end
	gscr.conf.page = p
	
	init_over_help()
end
----------------------------------------
function config_textdelete()
	ui_message("500.p01")
	ui_message("500.p02")
	ui_message("500.p03")
	ui_message("500.p04")
	ui_message("500.p05")
	ui_message("500.p06")
	ui_message("500.p07")
end

-----------------------------------------
-- over helpの設定
-----------------------------------------
function config_set_overhelp(page)
	local layout = {}
	if game.os == "windows" then
	layout = {
		{
			name="window",
			left=2,
			right=2
		},{
			name="text",
			left=3,
		},{
			name="sound",
			left=5,
			right=4
		},
		{
			name="shortcut",
			left=0,
			right=0
		}
	}
	local pos = {left={x=264,y=189},right={x=760,y=189}}
	local h = 79
	local pg = tn(page)
	if pg == 2 then 
		for i=1,layout[pg].left do
			config_set_overhelp_cell(layout[pg].name, pos.left.x, pos.left.y + h * (i-1) + 1, i)
		end
		config_set_overhelp_cell(layout[pg].name, pos.right.x, pos.right.y + h * 2, 4)
	else 
		for i=1,layout[pg].left do
			config_set_overhelp_cell(layout[pg].name, pos.left.x, pos.left.y + h * (i-1) + 1, i)
		end
		for i=1,layout[pg].right do
			config_set_overhelp_cell(layout[pg].name, pos.right.x, pos.right.y + h * (i - 1) + 1, i+layout[pg].left)
		end
	end
	else
		-- return 0
		-- layout = {
		-- 	{
		-- 		name="window",
		-- 		left=1,
		-- 		right=1
		-- 	},{
		-- 		name="text",
		-- 		left=3,
		-- 	},{
		-- 		name="sound",
		-- 		left=5,
		-- 		right=4
		-- 	},
		-- 	{
		-- 		name="shortcut",
		-- 		left=0,
		-- 		right=0
		-- 	}
		-- }
	end


end
-----------------------------------------
-- over helpの設定
-----------------------------------------
function config_set_overhelp_cell(name,left,top,num) 
	local id = "500.hover."..num
	lyc2{id=(id), color=("00000000"),width="464",height="79"}
	e:tag{"lyprop",id=(id), left=(left),top=(top)}
	lyevent{id=(id),page=(name),key=(num),over=("conf_help_over")}
	lyevent{id=(id),page=(name),key=(num),out=("conf_help_out")}
end
----------------------------------------
-- over helpのlayer init
----------------------------------------
function init_over_help()
	--reset_hover_help()
	flg.conf_help_on = nil
	lyc2{id="500.help",file=(game.path.ui.."conf/default"),left="56",top="456"}
	config_set_overhelp(gscr.conf.page)
end
----------------------------------------
-- over helpのlayer reset
----------------------------------------
function conf_help_over(e, p)
	flg.conf_help_on = p.page..p.key -- ガチャガチャしたときの回避策
	lyc2{id="500.help",file=(game.path.ui.."conf/"..p.page.."/help."..p.page.."."..p.key),left="56",top="456"}
	flip()
end
function conf_help_out(e, p)
	if p.page..p.key == flg.conf_help_on then-- ガチャガチャしたときの回避策
		lyc2{id="500.help",file=(game.path.ui.."conf/default"),left="56",top="456"}
		flg.conf_help_on = nil
	end
	flip()
end
----------------------------------------
-- sample text
function config_textex()
	local t0 = init.textsample
	local t1 = init["sample_text01_"..conf.language]
	local t2 = init["sample_text02_"..conf.language]

	if t0 == "on" and t1 and t2 then
		ui_message("500.p01", conf.mspeed)
		ui_message("500.p02", conf.aspeed)

		-- 初期化
		if not flg.config.tx then
			local s1 = math.ceil(#t1:gsub("\n", "") / 3)
			local s2 = math.ceil(#t2:gsub("\n", "") / 3)
			flg.config.tx = {
				{ s1, t1 },
				{ s2, t2 },
			}
		end

		local ext = "_"..conf.language
		if conf.language == "ja" then ext = "" end
		set_textfont("config01"..ext, "500.sample",true)
		-- font
		local ms = getMSpeed()
--		local fo = fontdeco("conf")
		e:tag{"chgmsg", id="500.sample", layered="1"}
		e:tag{"rp"}
		
--		e:tag(fo)
		set_message_speed_tween(ms)
		e:tag{"/chgmsg"}

		-- 開始
		flg.config.addcount = 0
		config_samplestart(300)
	end
end
----------------------------------------
-- text start
function config_samplestart(time)
	tag{"lytweendel", id="500.zz"}
	if not flg.config.sample then
		flg.config.sample = true
		tag{"lytween", id="500.zz", param="alpha", from="254", to="255", time=(time), handler="calllua", ["function"]="config_sampletext"}
	end
end
----------------------------------------
-- text clear
function config_delsample()
	flg.config.sample = nil
	e:tag{"chgmsg", id="500.sample"}
	e:tag{"rp"}
	e:tag{"/chgmsg"}
end
----------------------------------------
-- text
function config_sampletext()
	local v = flg.config
	if v then
		local t = v.tx
		local c = flg.config.addcount
		c = c + 1
		if c > #t then c = 1 end

		-- 表示
		e:tag{"chgmsg", id="500.sample"}
		e:tag{"rp"}
		e:tag{"print", data=(t[c][2])}
		flip()
		eqwait()
		eqtag{"/chgmsg"}

		-- timer
		local ms = getMSpeed()
		local as = getASpeed()
		local tx = ms * t[c][1] + as
		flg.config.addcount= c

		-- restart
		flg.config.sample = nil
		config_samplestart(tx)
	end
end
----------------------------------------
-- text 再開チェック
function config_sampletextcheck()
	local c = flg.config
	if c then
		local pg = gscr.conf.page or 1
		local os = game.os
		if os == "windows" and pg == 2 then
			config_sampletext()
		end
	end
end
----------------------------------------
-- ボイスキャラ
--[[
function config_vochar(name)
	if name then
		-- 背景
		readImage("500.3.0", { path=(game.path.ui), file="config03" })
		local v = getBtnInfo(name)
		if v and v.p2 then
			local p = v.p2
			local n = ipt[p]
			tag{"lyprop", id="500.3.0", clip=(n), left=(ipt.base.x), top=(ipt.base.y)}

			-- 音量コピー
			local no = conf[p]
			conf.dummy  = no
			conf.voname = name
			volume_charset()	-- スライダーpin初期化
		end
	else
		setBtnStat("sl_char", 'c')
	end
end
]]
----------------------------------------
-- サンプルウィンドウ
function config_sample()
	local p = repercent(conf.mw_alpha, 255)
	e:tag{"lyprop", id=(getBtnID("alpha")), alpha=(p)}
end
----------------------------------------
-- 
function config_samplewindow(e, p)
	if p.old and p.old ~= p.p then
		config_sample()
	end
end
----------------------------------------
-- start リセットチェック
function config_resetcheck()
	se_ok()
	dialog('reset')
end
----------------------------------------
-- ボタン制御
----------------------------------------
-- クリックされた
function config_click(e, param)
	local bt = btn.cursor
	if bt then
--		ReturnStack()	-- 空のスタックを削除
--		se_ok()
--		message("通知", bt, "が選択されました")

		local v = getBtnInfo(bt)
		local n = bt:sub(1, 3)
		local p1 = v.p1
		local p2 = tn(v.p2)
		local switch = {
			bt_default	= function() config_resetcheck() end,
			bt_title	= function() adv_title() end,
			bt_exit		= function() adv_exit() end,
			bt_end		= function() adv_exit() end,

			-- p1 command
			page = function()	se_ok() config_page(p2) flip() end,
			voice = function()	se_ok() config_voicechar(p2) end,
			sch = function()	se_ok() config_samplevoice((gscr.conf.char or 1), p2) end,

--			bt_exit = function() config_exit() end,
		}
			if n == 'btn' then config_nameclick(bt, 10)
--		elseif n == 'cha' then config_charclick(bt)
--		elseif p1 == 'page' then se_ok() config_page(p2) flip()
		elseif switch[bt] then switch[bt]()
		elseif switch[p1] then switch[p1]()
		else error_message(bt, "は登録されていないボタンです") end
	end
end
----------------------------------------
-- config_toggle
function config_toggle(e, p)
	local bt = btn.cursor
	if bt then
		local v = getBtnInfo(bt)
		local a = explode("|", v.p2)
		for i, nm in pairs(a) do
			setBtnStat(nm, nil)
		end

		se_ok()
		btn_clip(bt, 'clip_c')
		setBtnStat(bt, v.def)	-- 自分 disable
		btn.cursor = a[1]
		
		if v.def == 'language' and v.p1 then 
			saveBtnData(v.def,v.p1)
			game.path.ui = init.system.ui_path..init.lang[v.p3]
			conf["language"] = v.p3
			setMWFont()
			conf_init()
		elseif v.def and v.p1 then saveBtnData(v.def, tn(v.p1)) end
		if v.p4 then e:tag{"calllua", ["function"]=(v.p4), name=(v.name)} end
		flip()
	end
end
----------------------------------------
-- キーコンフィグ
----------------------------------------
function config_numtokey(no)
	local tbl = { "MWOFF", "AUTO", "CONFIG", "SKIP", "LOAD", "SAVE", "FLOW" }
	return tbl[no]
end
----------------------------------------
function config_keytonum(key)
	local tbl = { MWOFF=1, AUTO=2, CONFIG=3, SKIP=4, LOAD=5, SAVE=6, FLOW=7 }
	return tbl[key]
end
----------------------------------------
function config_keyconfig02(e, p)
	local bt = p.name
	if bt then
		local v = getBtnInfo(bt)
		local n = tn(v.p1)
		if n then
			local k = game.os == "windows" and 2 or 153
			conf.keyconf = n
			conf.keys[k] = config_numtokey(n)
		end
	end
end
----------------------------------------
-- ボタン名クリック
function config_nameclick(name, add)
	se_ok()
	local v = getBtnInfo(name)
	local n = v.p1
	if n then
		local t = getBtnInfo(n)
		local c = t.com
		if c == 'toggle' then		toggle_change(n)			-- toggle
		elseif c == 'xslider' then	xslider_add(n, add) end		-- slider
		flip()
	end
end
----------------------------------------
-- 
function config_charclick(bt)
	-- サンプルボイス
	if flg.config.lock then
		if bt then
			local t  = getBtnInfo(bt)
			local nm = t.p2
			local vx = csv.voice[nm]
			voice_stopallex(0)
			voice_play({ ch=(nm), file=(vx.name), path=":vo/" }, true)
		end

	-- キャラボイスモード
	else
		se_ok()
		flg.config.lock = true
		if bt then
			config_vochar(bt)
			flip()
		end
	end
end
----------------------------------------
-- 戻る処理
function config_back()
	-- キャラボイスモードを抜ける
	if flg.config.lock then
		se_ok()
		flg.config.lock = nil

	-- 終了
	else
		close_ui()
	end
end
----------------------------------------
-- 
----------------------------------------
-- UP
function config_up(e, p)
	local bt = btn.cursor or 'UP'
	btn_up(e, { name=(bt) })
	config_markcheck()
	flg.config.lock = nil
end
----------------------------------------
-- DW
function config_dw(e, p)
	local bt = btn.cursor or 'DW'
	btn_down(e, { name=(bt) })
	config_markcheck()
	flg.config.lock = nil
end
----------------------------------------
-- 左キー
function config_lt(e, p)
	local bt = btn.cursor
	if flg.config.lock then
		xslider_add("sl_char", -10)
	elseif bt then
		local t  = getBtnInfo(bt)
		local cm = t.com
		if t.lt then			 btn_left(e, { name=(bt) })	-- 移動
		elseif cm == "mark" then config_markmove(-1) end
--[[
		local nm = bt:sub(1, 3)
		elseif nm == 'cha'   then btn_left(e, { name=(bt) })	-- キャラ動作
		elseif nm == 'btn'   then config_nameclick(bt, -10)		-- ボタン
		elseif bt == 'bt_vskip' then
		else
			se_ok()
			if t.com == 'toggle' then		toggle_change(bt)			-- toggle
			elseif t.com == 'xslider' then	xslider_add(bt, -10) end	-- slider
		end
]]
	end
end
----------------------------------------
-- 右キー
function config_rt(e, p)
	local bt = btn.cursor
	if flg.config.lock then
		xslider_add("sl_char", 10)
	elseif bt then
		local t  = getBtnInfo(bt)
		local cm = t.com
		if t.rt then			 btn_right(e, { name=(bt) })	-- 移動
		elseif cm == "mark" then config_markmove(1) end

--[[
		local nm = bt:sub(1, 3)
		if t.lt then			  btn_right(e, { name=(bt) })	-- 移動
--		elseif nm == 'cha'   then btn_right(e, { name=(bt) })	-- キャラ動作
		elseif nm == 'btn'   then config_nameclick(bt, 10)		-- ボタン
		elseif bt == 'bt_vskip' then
		else
			se_ok()
			if t.com == 'toggle' then		toggle_change(bt)			-- toggle
			elseif t.com == 'xslider' then	xslider_add(bt, 10) end		-- slider
		end
]]
	end
end
----------------------------------------
-- mark
function config_markcheck()
	local bt = btn.cursor
	local t  = bt and getBtnInfo(bt)
	if t and t.com == 'mark' then
		local p1 = t.p1
		local v  = p1 and getBtnInfo(p1)
		if v.com == "toggle" then
			p1 = v.p2
			if p1:find("|") then
				local ax = explode("|", p1)
				p1 = ax[1]
			end
		end
		--uihelp_over{ name=(p1) }
		flip()
	end
end
----------------------------------------
-- click / 左右カーソル共通(addの有無で判定)
config_markchange = {
	----------------------------------------
	xslider = function(bt, add) if add then se_ok() end xslider_add(bt, (add or 1)*10) end,		-- X slider
	yslider = function(bt, add) if add then se_ok() end yslider_add(bt, (add or 1)*10) end,		-- Y slider

	----------------------------------------
	-- トグルボタン
	toggle = function(bt, add, p)
		local fl = nil
		local nm = p.def
		local dx = conf[nm]		-- 現在の値 
		local p1 = tn(p.p1)		-- 指定ボタンの値
		local p2 = p.p2			-- 指定ボタンのペア
		if p2:find("|") then
			local t1 = explode("|", p2)		-- ３個以上のトグルボタン処理
			local t2 = {}
			table.insert(t1, 1, bt)			-- 先頭のボタンを足す

			-- 各ボタンからp1の値を取り出す
			local ct = 1
			local mx = #t1
			for i, v in ipairs(t1) do
				local t = getBtnInfo(v)
				local n = tn(t.p1)
				t2[i] = n
				if n == conf[nm] then ct = i end
			end

			-- 範囲内であれば隣のボタンへ移動
			local cx = ct + (add or 1)
			if not add and cx > mx then cx = 1 end
			if cx >= 1 and cx <= mx then
				if add then se_ok() end
				local n1 = t1[ct]
				local n2 = t1[cx]
				setBtnStat(n1, nil)		-- 自分 enable
				setBtnStat(n2, nm)		-- 相棒 disable
				btn_clip(n1, 'clip')
				btn_clip(n2, 'clip_c')
				flip()

				-- save
				local t = getBtnInfo(n2)
				saveBtnData(nm, tn(t.p1))
				fl = t.p4
			end
		else
			-- ボタンが左側にある
			if dx == p1 and (not add or add == 1) then
				if add then se_ok() end
				setBtnStat(bt, nil)		-- 自分 enable
				setBtnStat(p2, nm)		-- 相棒 disable
				btn_clip(bt, 'clip')
				btn_clip(p2, 'clip_c')
				flip()

				-- save
				local t = getBtnInfo(p2)
				saveBtnData(nm, tn(t.p1))
				fl = t.p4

			-- ボタンが右側にある
			elseif dx ~= p1 and (not add or add == -1) then
				if add then se_ok() end
				setBtnStat(p2, nil)		-- 自分 enable
				setBtnStat(bt, nm)		-- 相棒 disable
				btn_clip(p2, 'clip')
				btn_clip(bt, 'clip_c')
				flip()

				-- save
				saveBtnData(nm, p1)
				fl = p.p4
			end
		end

		-- p4があれば実行
		if fl then e:tag{"calllua", ["function"]=(fl)} flip() end
	end,
}
----------------------------------------
-- mark click
function config_markclick(bt)
	if bt and get_gamemode('ui2', bt) then
		local t  = getBtnInfo(bt)		-- mark
		local bx = t.p1
		if bx then
			local v  = getBtnInfo(bx)	-- button
			local cm = v.com
			if config_markchange[cm] then config_markchange[cm](bx, nil, v) end
		end
	end
end
----------------------------------------
-- ボタン移動
function config_markmove(add)
	local bt = btn.cursor
	if bt and get_gamemode('ui2', bt) then
		local t  = getBtnInfo(bt)		-- mark
		local bx = t.p1
		if bx then
			local v  = getBtnInfo(bx)	-- button
			local cm = v.com
			if config_markchange[cm] then config_markchange[cm](bx, add, v) end
		end
	end
end
----------------------------------------
-- test voice再生(F1)
function config_f1_test(e, p)
	local bt = btn.cursor
	if bt and get_gamemode('ui2', bt) then
		local t  = getBtnInfo(bt)
		local nm = t.p3
		if nm then
			local v  = getBtnInfo(nm)
			if v then
				local ex = v.exec
				if ex then _G[ex](e, nm) end
			end
		end
	end
end
----------------------------------------
-- mute(F2)
function config_f2_mute(e, p)
	local bt = btn.cursor
	if bt and get_gamemode('ui2', bt) then
		local t  = getBtnInfo(bt)
		local nm = t.p2
		if nm then
			local v = getBtnInfo(nm)
			if v then
				local cm = v.com
				if	   cm == "single" then se_ok() single_change(nm)
				elseif cm == "check"  then se_ok() check_change(nm) end
			end
		end
	end
end
----------------------------------------
-- アクティブ
--[[
function config_over(e, p)
	local bt = p.name
	if bt then
		local nm = bt:sub(1, 4)
		if nm == 'char' then
			config_vochar(bt)
			flip()
		end
	end
end
]]
----------------------------------------
-- bgm/se/se2ボタン
function config_volumeadd(e, p)
	local bt = p.btn
	if bt then
		se_ok()
		local v  = getBtnInfo(bt)
		local p1 = v.p1
		local p2 = tn(v.p2)
		xslider_add(p1, p2)
	end
end
----------------------------------------
-- 
function config_sample01(e, p)
	local bt = p.btn
	if bt then
		local v  = getBtnInfo(bt)
		local p1 = v.p1
		local p2 = v.p2
		local s  = csv.sysse[p1]

		systemsound("uistop")

		-- se/se2
		if s then
			local m = #s
			local r = (e:random() % m) + 1
			local id = getSEID(p2, 0)
			seplay(id, ":sysse/sample/"..s[r]..game.soundext, {})

		-- voice
		else
			local r1 = (e:random() % 13) + 1
			local r2 = (e:random() % 3) + 1
			config_samplevoice(r1, r2)
		end
	end
end
----------------------------------------
-- キャラ個別音量／スライダー共用
function volume_char(e, p)
	local vo = gscr.conf.char or 1
	local nm = "name"..string.format("%02d", vo)
	local tx = csv.voice.name[nm]
	if tx then
		local n = tx[1]
		local s = conf.dummy
		conf[n] = s
		volume_eachvoice(n)
	end
end
----------------------------------------
-- キャラ個別音量／スライダーpin初期化
function volume_charset()
	local no = conf.dummy
	if no then
		xslider_pin("sl_char", no)
	end
end
----------------------------------------
-- sample voice
function config_samplevoice(vo, no)
	local nm = "name"..string.format("%02d", vo)
	local v  = csv.voice
	local t  = v.name[nm]
	if t then
		systemsound("uistop")
		local n = t[1]
		local x = csv.samplevoice[n]
		local file = x[no]
		local path = ":sysse/vo/"..file..game.soundext
		local id   = getSEID("voice", t.id)
		seplay(id, path, {})
	end
end
----------------------------------------
-- mw sample
function conf_mwsample()
	local a = conf.mw_alpha
	local p = repercent(a, 255)
--	tag{"lyprop", id=(getBtnID("mw")), alpha=(p)}
	ui_message("500.p03", conf.mw_alpha)

--[[
	local numper = function(nm, no)
		local v = getBtnInfo(nm)
		if v.dir == "width" then
			local clip = (v.cx + v.cw*no)..","..v.cy..","..v.cw..","..v.ch
			tag{"lyprop", id=(v.idx), clip=(clip)}
		else
			local clip = v.cx..","..(v.cy + v.ch*no)..","..v.cw..","..v.ch
			tag{"lyprop", id=(v.idx), clip=(clip)}
		end
	end

	-- 0-100%
	local p = NumToGrph3(a)
	local z = p[1] == 0 and p[2] == 0 and 0 or 1
	tag{"lyprop", id=(getBtnID("no01")), visible=(p[1])}
	tag{"lyprop", id=(getBtnID("no02")), visible=(z)}
	numper("no02", p[2])
	numper("no03", p[3])
]]
end
----------------------------------------
-- qsave/qloadまとめ
function config_dlgqsave(e, p)
	local bt = p.name
	if bt then
		local v  = getBtnInfo(bt)
		local p1 = conf.qsave
		conf.dlg_qsave = p1
		conf.dlg_qload = p1
	end
end
----------------------------------------
-- sub menu
----------------------------------------
function config_submenu(e, p)
	local bt = p.btn
	local vx = getBtnInfo(bt)

	-- shortcut
	if bt == "short" then
		se_ok()
		csvbtn3("csub", "510", csv.ui_config13)
		flg.config.sub = { page=13 }
		uitrans()

	-- custom
	elseif bt == "custom02" then
		se_ok()
		csvbtn3("csub", "510", csv.ui_config12)
		tag{"lyprop", id="510.help", visible="0"}
		local nm = "short0"..conf.custom
		setBtnStat(nm, 'c')
		flg.config.sub = { page=12 }
		uitrans()

	-- ショートカット
	elseif bt then
		se_ok()
		csvbtn3("csub", "510", csv.ui_config11)
		tag{"lyprop", id="510.help", visible="0"}
		local p1 = tn(vx.p1)
		local p2 = tn(vx.p2)
		local mx = conf.keys[p2]
		flg.config.sub = { page=11, key=(p2) }
		for i=1, 8 do
			local nm = "short0"..i
			local v  = getBtnInfo(nm)
			if mx == v.p1 then
				setBtnStat(nm, 'c')
				break
			end
		end
		uitrans()
	end
end
----------------------------------------
-- 
function config_subclick(e, p)
	local bt = p.btn
	if bt and bt ~= "EXIT" then
		local s  = flg.config.sub
		local v  = getBtnInfo(bt)
		local p1 = v.p1

		-- shortcut
		if p1 and s.page == 11 then
			se_ok()
			conf.keys[s.key] = p1
			btn.renew = true

		-- custom
		elseif p1 and s.page == 12 then
			se_ok()
			local p1 = tn(p1)
			conf.custom = p1
			gscr.vari.custom = p1	-- 初回特典
			btn.renew = true
		end
	else
		se_cancel()
	end

	-- 画面を戻す
	delbtn('csub')
	config_page(gscr.conf.page)
	uitrans()
	flg.config.sub = nil
end
----------------------------------------
-- 
----------------------------------------
-- リセット
function config_reset(e, param)
	config_default()	-- 初期化
	set_message_speed()	-- 文字速度書き換え

	-- uiの初期化
	e:tag{"lydel", id="500"}

	-- ボタン描画
	config_page(gscr.conf.page)
end
----------------------------------------
-- dialog初期化
function config_dialog(e, p)
	local v = getBtnInfo(p.name)
	local p = loadBtnData(v.def)
	if p == 1 then
		message("通知", [[dialogを再表示します]])
		config_dialogreset()
	end
end
----------------------------------------
-- message
----------------------------------------
function getMSpeed()
	local ms = 100 - conf.mspeed
	if conf.fl_mspeed == 0 then ms = 0 end
	return ms
end
----------------------------------------
function getASpeed()
	local am = init.automode_speed
	local as = (100 - conf.aspeed) * am[2] + am[1]
	if conf.fl_aspeed == 0 then as = init.autooff_speed end
	return as
end
----------------------------------------
-- メッセージ速度を設定する
function set_message_speed()
	local ms = getMSpeed()

	if game and game.mwid then
		e:tag{"chgmsg", id=(game.mwid..".mw.adv"), layered="1"}
		set_message_speed_tween(ms)	-- ADV画面
		e:tag{"/chgmsg"}

--		e:tag{"chgmsg", id=(game.mwid.."mw.novel"), layered="1"}
--		set_message_speed_tween(ms)	-- 全画面
--		e:tag{"/chgmsg"}
	end

	-- オート速度を設定する
	e:tag{"var", name="s.automodewait", data=(getASpeed())}
end
----------------------------------------
function set_message_speed_tween(delay, time, diff)
	local tm = time or init.config_mestime
	local df = diff or init.config_mestop
	e:tag{"scetween", mode="init", type="in"}
	e:tag{"scetween", mode="add" , type="in", param="alpha", ease="none", time=(tm), delay=(delay), diff="-255"}
	if conf.mspeed < 100 and conf.fl_mspeed == 1 then
	e:tag{"scetween", mode="add" , type="in", param="top",   ease="none", time=(tm), delay=(delay), diff=(df), ease="easeout_quad"}
	end
end
----------------------------------------
-- 音量計算
----------------------------------------
-- ボリュームを設定する
function set_volume()
	volume_master()
	volume_bgm()
	volume_movie()
	volume_se()
	volume_voice()
	volume_sysse()
	volume_sysvo()
	volume_ese()
end
----------------------------------------
function volume_slider00()
	volume_sysvo()
	local s = conf.fl_sysvo == 0 and "off" or conf.sysvo
	ui_message("500.p01", s)
end
--------
function volume_slider01()
	set_volume()
	local s = conf.fl_master == 0 and "off" or conf.master
	ui_message("500.p01", s)
end
--------
function volume_slider02()
	volume_bgm()
	volume_movie()
	local s = conf.fl_bgm == 0 and "off" or conf.bgm
	ui_message("500.p02", s)
end
--------
function volume_slider03()
	volume_se()
	local s = conf.fl_se == 0 and "off" or conf.se
	ui_message("500.p03", s)
end
--------
function volume_slider04()
	volume_voice()
	local s = conf.fl_voice == 0 and "off" or conf.voice
	ui_message("500.p04", s)
end
--------
function volume_slider05()
	volume_sysse()
	local s = conf.fl_sysse == 0 and "off" or conf.sysse
	ui_message("500.p05", s)
end
--------
function volume_slider06()
	volume_voice()
	local s = conf.fl_bgv == 0 and "off" or conf.movie
	ui_message("500.p06", s)
end
--------
function volume_slider07()
--	volume_voice()
	local s = conf.fl_bgmvo == 0 and "off" or conf.ese
	ui_message("500.p07", s)
end
----------------------------------------
function volume_sliderch(e, p)
	local bt = p.name or btn.cursor
	if bt and p.old then
		local v = getBtnInfo(bt)
		local nm = v.def
		volume_eachvoice(nm)
	end
end
----------------------------------------
-- volume制限
function volume_check(v)
	local m = init.vita_volume
	if m and game.os == "vita" and v >= m * 10 then v = m * 10 end
	return v
end
----------------------------------------
-- volume計算
function volume_count(name, ...)
	local r = 1000
	local c = conf.fl_master == 0 and 0 or conf["fl_"..name]
	if c and c == 0 then
		r = 0
	else
		local t = { ... }
		local m = #t
		local c = 100
		for i, v in ipairs(t) do
			if i == 1 then	r = t[i]
			else			r = r * t[i] / 100 end
		end
		r = volume_check(math.ceil(r * 10))
	end
	return r
end
----------------------------------------
-- マスター音量を計算する
function volume_master()
--	volume_bgm()	-- BGM音量
--	volume_movie()	-- movie音量

	-- SE/Voice
	local ans = volume_count("master", conf.master, init.config_volumemax)
	e:tag{"var", name="s.sevol", data=(ans)}
end
----------------------------------------
-- BGMの音量を計算する
function volume_bgm()
	local ans = volume_count("bgm", conf.master, conf.bgm, init.config_bgmmax)
	e:tag{"var", name="s.bgmvol", data=(ans)}
	-- mbgm用の音量も同期して下げる
	e:tag{"var", name="s.segain.mbgm1", data=(ans)}
	e:tag{"var", name="s.segain.mbgm2", data=(ans)}
	e:tag{"var", name="s.segain.mbgm3", data=(ans)}
	e:tag{"var", name="s.segain.mbgm4", data=(ans)}
	e:tag{"var", name="s.segain.mbgm5", data=(ans)}
	e:tag{"var", name="s.segain.mbgm6", data=(ans)}
	e:tag{"var", name="s.segain.mbgm7", data=(ans)}
	e:tag{"var", name="s.segain.mbgm8", data=(ans)}
end
----------------------------------------
-- movieの音量を設定する
function volume_movie()
	if not game.ps then
		local ans = volume_count("movie", conf.master, (conf.movie or conf.bgm), (init.config_moviemax or init.config_bgmmax))
		e:tag{"var", name="s.videovol", data=(ans)}
	end
end
----------------------------------------
-- ボイスの音量を設定する
function volume_voice()
	local tbl = {}
	for nm, v in pairs(csv.voice) do	-- voice_tableの中身を取り出す
		local id = v.id
		if id and not tbl[id] then
			volume_eachvoice(nm)		-- 個別
			tbl[id] = true				-- 同一idを弾く
		end
	end
end
----------------------------------------
-- voice個別
function volume_eachvoice(name)
	local v  = csv.voice[name]
	local id = v.id

	local ans = 0
	ans = volume_count(name, conf.voice, conf[name])

	e:tag{"var", name=("s.segain."..getSEID("voice", id)), data=(ans)}		-- voice
end
----------------------------------------
-- 音量設定
function setsevol(name)
	local head = getSEID(name, 0)
	if head > -1 then
		local vol = volume_count(name, conf[name])
		local max = init[name.."_limit"]			-- id数
		for i=0, max-1 do
			local no = head + i
			e:tag{"var", name=("s.segain."..no), data=(vol)}
		end
	end
end
----------------------------------------
function volume_se()	setsevol("se") end		-- SEの個別音量を設定する
function volume_sysse()	setsevol("sysse") end	-- SysSEの個別音量を設定する
function volume_sysvo()	setsevol("sysvo") end	-- SysVoiceの個別音量を設定する
function volume_ese()	setsevol("ese") end		-- SysVoiceの個別音量を設定する
----------------------------------------
-- 初期化
----------------------------------------
-- ダイアログを出すかどうか確認するテーブル
function config_dialogreset(no)
	conf.dlg_all	= no or 1		-- 
	conf.dlg_load	= no or 0
	conf.dlg_save	= no or 1
	conf.dlg_save2	= no or 0
	conf.dlg_del	= no or 0
--	conf.dlg_news	= no or 0
	conf.dlg_scene	= no or 0
	conf.dlg_title	= no or 0
	conf.dlg_exit	= no or 0
	conf.dlg_qload	= no or 0
	conf.dlg_qsave	= no or 1
	conf.dlg_reset	= no or 0
	conf.dlg_jump	= no or 0
	conf.dlg_tweet	= no or 0
	conf.dlg_suspend= no or 0
	conf.dlg_flow	= no or 0
	conf.dlg_web	= no or 0
	conf.dlg_favo	= no or 1
	conf.dlg_favo2	= no or 0
end
----------------------------------------
function tabletmode_check()
	if game.os == "android" then
--		conf.tablet = 1
	end
end
----------------------------------------
function config_default()

	message("通知", "設定を初期化しました")

	-- バッファクリア
	local def = conf and conf.dlg_reset
	local lng = nil
	if conf then lng = conf.language end 
	if not lng then lng = init.config_language end
	conf = {}
	config_dialogreset()
	conf.keys = {}		-- keyconfig [key] = name
	if def then conf.dlg_reset = def end

	-- text
	conf.mspeed		= init.config_mspeed			-- メッセージ速度	- slider
	conf.aspeed		= init.config_aspeed			-- オートモード速度 - slider
	conf.fl_mspeed	= init.config_on_mes	or 1	-- メッセージ速度	- on/off 
	conf.fl_aspeed	= init.config_on_aspeed	or 1	-- オートモード速度	- on/off 
	conf.autostop	= init.config_autostop or 1		-- オートモード時音声待機
	conf.autoclick	= init.config_autoclick or 0	-- オートモード時クリック動作
	conf.font		= init.config_fonttype			-- フォント変更
	conf.shadow		= init.config_textshadow		-- 文字の影
	conf.outline	= init.config_textoutline		-- 文字の縁
	
	-- message window
	conf.mw_alpha	= init.config_mw_alpha			-- ウインドウ濃度
	conf.mw_aread	= init.config_mw_aread			-- テキスト既読色
	conf.mw_simple	= init.config_mw_simple			-- シンプルMWを使用
	conf.mwface		= init.config_mw_face			-- メッセージウィンドウのface絵
	conf.mwhelp		= init.config_mw_help			-- mwbtn help
	conf.dock		= init.config_mw_dock			-- dock

	conf.bgname		= init.config_bgname			-- 場所名				0:なし	1:あり
	conf.bgmname	= init.config_bgmname			-- 曲名					0:なし	1:あり
	conf.notify		= init.config_notify or 1		-- 通知					0:なし	1:あり
	conf.rclick_type= init.config_rclicktype
	conf.dlg		= init.config_dlg
	-- select / skip
	conf.ctrl		= init.config_ctrl				-- ctrlキー
	conf.exskip		= init.config_sceneskip			-- シーンスキップ
	conf.messkip	= init.config_areadskip			-- メッセージスキップ既読設定
	conf.skip		= init.config_sel_skip			-- 選択肢後のスキップ継続
	conf.auto		= init.config_sel_auto			-- 選択肢後のオート継続
	conf.selcolor	= init.config_sel_color			-- 選択肢の文字色
	conf.finish01	= init.config_finish01			-- 挿入時				0:膣内	1:外	2:選択
--	conf.finish02	= init.config_finish02			-- フェラ				0:口内	1:顔面	2:選択

	-- graphic
	conf.window		= init.config_window			-- 画面モード
	conf.effect		= init.config_effect			-- 画面効果
	conf.sysani		= init.config_sysani or 1		-- 画面効果 / システム

	-- save system
	conf.qsave		= init.config_qsave or 0		-- qsave / qload
	conf.asave		= init.config_asave				-- オートセーブ / [autosave]タグ
	conf.selsave	= init.config_asave_select		-- オートセーブ / 選択肢

	-- system
--	conf.rclick		= init.config_rclick			-- 右クリック動作
	conf.mouse		= init.config_autocursor		-- 自動カーソル
	conf.cursor		= init.config_autohide			-- 自動消去
	conf.scback		= init.config_textback			-- テキストバック

	-- sound
	conf.master		= init.config_volume			-- マスター音量
	conf.bgm		= init.config_bgm				-- BGM
	conf.se			= init.config_se				-- SE
	conf.voice		= init.config_voice				-- Voice
	conf.bgv		= init.config_bgv				-- BGV音量
	conf.sysse		= init.config_sysse				-- SysSe
	conf.sysvo		= init.config_sysvo				-- SysVoice
	conf.movie		= init.config_movie				-- movie
	conf.ese		= init.config_ese				-- ese
	conf.fl_master	= init.config_on_volume			-- on/off マスター音量
	conf.fl_bgm		= init.config_on_bgm			-- on/off BGM
	conf.fl_se		= init.config_on_se				-- on/off SE
	conf.fl_voice	= init.config_on_voice			-- on/off Voice
	conf.fl_sysse	= init.config_on_sysse			-- on/off SysSE
	conf.fl_sysvo	= init.config_on_sysvo			-- on/off SysVoice
	conf.fl_bgv		= init.config_on_bgv			-- on/off 
	conf.fl_bgmvo	= init.config_on_bgmvo			-- on/off 
	conf.fl_movie	= init.config_on_movie			-- on/off Movie
	conf.language   = lng							-- ja / en / cn language
	conf.voiceskip	= init.config_voiceskip			-- クリックで音声を停止する
	conf.bgmvfade	= init.config_bgm_vfade			-- on/off ボイス再生時BGM音量制御
	conf.bgmvoice	= init.config_bgm_voice			-- ボイス再生時のBGM音量
	conf.ex_vol     = init.config_ex_vol
--	conf.sysvochar	= init.config_systemchar		-- システムボイスのキャラ

	-- 各キャラボイスのon/offはvoice_tableから取得する	0:off 1:on
	for nm, v in pairs(csv.voice) do
		if v.id then
			conf[nm] = 100
			conf["fl_"..nm] = 1
		end
	end

	-- system voice
	conf.sysvo01 = 1
	conf.sysvo02 = 1
	conf.sysvo03 = 1
	conf.sysvo04 = 1

	-- etc system
--	conf.mw_count	= init.config_mwcount			-- カウントダウン		0:なし	1:あり
--	conf.hev_cutin	= init.config_hevcutin			-- 断面図				0:なし	1:あり

	-- tablet
	local gs = game.os
	local t1 = init.config_tablet					-- タブレットモード
	local t2 = init.config_tabletui					-- タブレットUI
	if gs == "windows" then
		local tb = tn(e:var("s.windowstouch"))		-- 対応有無を取得
		if not t1 then t1 = tb end
		if not t2 then t2 = tb end
--	elseif gs == "android" then t1 = 1
--	elseif gs == "switch"  then t1 = 1
	end
	conf.tablet		= t1							-- タブレットモード
	conf.tabletui	= t2							-- タブレットUI

	----------------------------------------
	-- 言語

	----------------------------------------
	-- debug設定があれば上書きする
	if debug_flag then debug_configinit() end

	-- windowsかつフルサイズのときは上書き
	e:tag{"var", name="t.screen", system="fullscreen"}
	local s = tn(e:var("t.screen"))
	if game.os == "windows" and s == 1 then
		conf.window = 1
	end

	----------------------------------------
	-- キーショートカット(キー番号管理)
	for i=1, init.max_keyno do
		local k = init["config_key"..i]
		if k then conf.keys[i] = k end
	end

	----------------------------------------
	patch_check()		-- パッチチェック
	set_volume()		-- ボリュームを設定する
	set_message_speed()	-- メッセージ速度を設定する
	--tabletmode_check()	-- androidはタブレットモードに

	-- lua側システム変数のセーブ
	asyssave()
end
----------------------------------------
-- 裸パッチチェック
function patch_checkfg()
	return game.os == "windows" and conf.patch == 1
end
----------------------------------------
-- 裸パッチチェック
function patch_check()
	local c = conf.patch
	if game.os == "windows" then
		local path = "裸パッチ.ini"
		if isFile(path) then
			c = c or 0
		else
			c = nil
		end
	else
		c = nil
	end
	conf.patch = c
end
----------------------------------------
