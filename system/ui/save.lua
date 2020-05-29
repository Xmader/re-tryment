----------------------------------------
-- セーブ／ロード
----------------------------------------
-- セーブ
function save_init()
	message("通知", "セーブ画面を開きました")
	sysvo("save_open") 

	-- ボタンワーク初期化
	flg.save = {
		page	= (sys.saveslot.page or 1),	-- load時セーブしないようにコピーしておく
	}
	scr.savecom = "save"
	flg.saveqload = nil

	-- 画面を作る
	save_readcsv()
	saveload_init()
	uiopenanime()
	uitrans()
end
----------------------------------------
-- ロード
function load_init()
	message("通知", "ロード画面を開きました")
	sysvo("load_open")

	-- ボタンワーク初期化
	flg.save = {
		page	= (sys.saveslot.page or 1),	-- load時セーブしないようにコピーしておく
	}
	scr.savecom = "load"

	-- セーブデータがない場合はautosaveかqsaveのページを開く
--	if sys.saveslot.last == 0 and sys.saveslot.cont then
--		flg.save.page = math.ceil(sys.saveslot.cont / init.save_column)
--	end

	-- 画面を作る
	if flg.saveqload then qload_readcsv()
	else				  load_readcsv() end

	-- ゲーム画面から来たらloadmaskを外す
	if getTitle() then
		tag{"lyprop", id=(getBtnID("bt_save")), visible="0"}
	end
	saveload_init()
	uiopenanime()
	uitrans()
end
----------------------------------------
function save_readcsv()
	csvbtn3("save", "500", csv.ui_save)
	--setBtnStat('bt_save', 'c')
end
----------------------------------------
function load_readcsv()
	csvbtn3("load", "500", csv.ui_load)
--	setBtnStat('bt_load', 'c')
end
----------------------------------------
function qload_readcsv()
	csvbtn3("load", "500", csv.ui_load)
--	lyc2{ id="500.99", file=(game.path.ui.."loadq")}
	setBtnStat('bt_qload', 'c')
end
----------------------------------------
-- 
----------------------------------------
-- 状態クリア
function save_reset(p)
--	if not p.flag then se_cancel() end

	-- メッセージ消去
	ui_message("500.pageno")
	for i=1, init.save_column do
		local no = string.format("%02d", i)
		ui_message(getBtnID("bt_save"..no)..'.20')
		ui_message(getBtnID("bt_save"..no)..'.21')
		ui_message(getBtnID("bt_save"..no)..'.22')
		ui_message(getBtnID("bt_save"..no)..'.23')
	end

	--del_uihelp()			-- ui help
	delbtn(scr.savecom)		-- 削除
	flg.save = nil			-- ボタン用ワークを削除
	flg.favo = nil			-- お気に入りボイス用記録データ
	flg.saveqload = nil
	sys.save = nil
	sys.load = nil
end
----------------------------------------
-- save画面から抜ける
function save_close()
	message("通知", "セーブ画面を閉じました")

	se_cancel()
	uicloseanime()
	save_reset(e, {})

	-- タイトル画面以外
	if not getTitle() then
		uitrans()
	end
end
function load_title(e, param)
	e:enqueueTag{"calllua", ["function"]="title_init2"}
	e:enqueueTag{"calllua", ["function"]="title1_cursor"}
	e:enqueueTag{"calllua", ["function"]="tips_title"}
end
----------------------------------------
-- 画面を作る
----------------------------------------
-- ボタン再描画
function saveload_init()
	local nb = flg.save.page				-- ページ番号
	local pg = (nb-1) * init.save_column	-- ページ先頭を計算
	local fp = e:var("s.savepath").."/"		-- セーブフォルダ
	local hd = scr.savecom					-- フォントの先頭
--	local ss = init.save_ss

	-- qload page
	local qs = nil
	if flg.saveqload then
		pg = game.qsavehead
		qs = true
		tag{"lyprop", id="500.up", visible="0"}		-- qsaveはページなし
	end

	-- ページ番号書き換え
	-- local mx = save_getmaxpage()
	-- local px = qs and "QuickLoad" or string.format("%03d / %03d", nb, mx)
	-- ui_message('500.pageno', { hd..'pg', text=(px) })
	-- set_uihelp("500.help", "uihelp")

	-- lock
	if not sys.saveslot.lock then sys.saveslot.lock = {} end
	local lk = sys.saveslot.lock

	-- newマーク
	local news = init.save_new
--	local newt = getBtnInfo('new')
	local last = sys.saveslot.last
	local ss   = csv.mw.savethumb			-- サムネイル位置
	local btid = "."..ss.id
	local path = e:var("s.savepath")..'/'	-- savepath
	local base = game.path.ui.."save/btn_text"
	local win  = game.os == "windows"
	local hev  = init.game_evmask

	-- 本文生成
	for i=1, init.save_column do
		local no = pg + i
		local nx = string.format("%02d", i)
		local v  = getBtnInfo('bt_save'..string.format("%02d", i))
--		local t  = get_savedatatime(no)
		local t  = isSaveFile(no)			-- セーブデータ確認
		local id = v.idx
		local thid = id..".-1"				-- サムネイルid
		local ed = 1
		lydel2(thid)
		lydel2(id..".24")
		-- no
--		set_saveno(no, id)
		local sn = qs and "Quick."..nx or string.format("No.%03d-", nb)..nx
--		if no > game.asavehead then sn = "auto "..string.format("%03d", no - game.asavehead) end
		--ui_message((id..'.20'), { hd..'no', text=(sn)})		-- セーブNo
		local ext = ""
		if conf.language ~= "ja" then ext = "_"..conf.language end
		ui_message((id..'.21'), { hd..'day'})				-- セーブ日付／ゲーム内
		ui_message((id..'.22'), { hd..''..ext   })				-- セーブテキスト
		ui_message((id..'.23'), { hd..'ttl'..ext})				-- セーブタイトル
		
		-- 追加画像
--		lyc2{ id=(id..'.10'), file=(base)}
--		local delid  = getBtnID("del0"..i)
--		local lockid = getBtnID("lock0"..i)

		-- ボタン範囲処理
		tag{"lyprop", id=(id..".0"), clickablethreshold="0"}

		-- セーブデータがある
		if t then
			local time = os.date("%Y/%m/%d %H:%M", t.date)
			local tttl = t.title[conf.language] or ""
			local tttx = t.text[conf.language]or ""
			tttx = string.sub(tttx,0,init.save_message_max*3)
			tttl = tttl:gsub("{_}"," ") 
			lydel2(id..'.-1')
			local sc_file = split(t.scfile,"_")
			sc_file =sc_file[1].."_"..sc_file[2]
			local ttlfile = game.path.ui.."save/title/"..sc_file..".png" -- ファイル名を5文字に変更
			local tickerfile = game.path.ui.."save/title/"..t.scfile.."@t.png"
			-- タイトルファイルがあったら配置しておく
			if e:isFileExists(ttlfile) then
				lyc2{id=(id..".24.0.0"),file=(ttlfile)}
				e:tag{"lyprop",id=(id..".24.0"),left="1",top="134"}
			elseif e:isFileExists(tickerfile) then

				lyc2{id=(id..".24.0.0"),file=(tickerfile)}
				e:tag{"var", name="t.ly", system="get_layer_info", id=(id..".24.0.0")}
				local width = e:var("t.ly.width")
				e:tag{"lyprop",id=(id..".24.0"),left="1",top="134"}
				lyc2{id=(id..".24.0.1"),file=(tickerfile)}
				e:tag{"lyprop",id=(id..".24.0"),intermediate_render="2",intermediate_render_mask=(game.path.ui.."save/ttlmask")}
				tween{id=(id..".24.0.0"),x=(width..",0"),time="10000",loop="-1",ease=""}
				tween{id=(id..".24.0.1"),x=("0,-"..width),time="10000",loop="-1",ease=""}
			else
				ui_message((id..'.23'), tttl)
			end
--			local lc = true

			-- HEVマスク
			local evm = t.evmask
			if hev and evm then
				local pppx = ":hev/"..evm
				lyc2{ id=(thid), file=(pppx), x=(ss.x), y=(ss.y)}

			-- thumb
			else
				local th = path..t.file
				lyc2{ id=(thid..".0"), file=(th), x=(ss.x), y=(ss.y)}
			end
			
			ui_message((id..'.21'), time)		-- セーブ日付／ゲーム内
			ui_message((id..'.22'), tttx)		-- セーブテキスト
					-- セーブタイトル

			-- lock
--[[
			if lc then
				e:tag{"lyprop", id=(delid ), visible="1"}
				e:tag{"lyprop", id=(lockid), visible="1"}
				local lv = getBtnInfo('lock0'..i)
				local cl = lk[no] and lv.clip_c or lv.clip
				e:tag{"lyprop", id=(lid..".0"), clip=(cl)}
				if win then e:tag{"lyprop", id=(id..'.0'), clickablethreshold="1"} end
			else
				e:tag{"lyprop", id=(delid ), visible="0"}
				e:tag{"lyprop", id=(lockid), visible="0"}
				if win then e:tag{"lyprop", id=(id..'.0'), clickablethreshold="0"} end
			end
]]
			-- newマークを付ける
			if news and no == last then
				e:tag{"lyprop", id=(newt.idx), visible="1", left=(v.x + newt.x), top=(v.y + newt.y)}
				news = nil
			end

		-- ない
		else
			ui_message(id..'.21')		-- セーブ日付／ゲーム内
			ui_message(id..'.22')		-- セーブテキスト
			ui_message(id..'.23')		-- セーブタイトル
--			e:tag{"lyprop", id=(delid ), visible="0"}
--			e:tag{"lyprop", id=(lockid), visible="0"}
			lyc2{ id=(thid..".0"), file=(game.path.ui.."save/null_data")}
			if win then e:tag{"lyprop", id=(id..'.0'), clickablethreshold="0"} end
			ed = 0
		end

		-- edit
		local vs = (qs or flg.save.move) and 0 or ed
		-- tag{"lyprop", id=(getBtnID("bt_edit"..nx)), visible=(vs)}
		-- tag{"lyprop", id=(getBtnID("bt_move"..nx)), visible=(vs)}
		-- tag{"lyprop", id=(getBtnID("bt_del" ..nx)), visible=(vs)}
	end

	-- newマークがなかった
	if news then
		e:tag{"lyprop", id=(newt.idx), visible="0"}
	end

	-- ページボタン
	init_pager()


	-- ページ番号
--[[
	ipt = nil
	local path = game.path.ui.."saveload.ipt"
	e:include(path)
	if ipt then
		local cl = ipt[flg.save.page]
		for i=1, init.save_column do
			local id = getBtnID("no0"..i)
			tag{"lyprop", id=(id), clip=(cl)}
		end
	end
]]
	-- numは塞いでおく
--	e:tag{"lyprop", id=(getBtnID("num")), visible="0"}

	-- saveはqsave等塞いでおく
--[[
	if scr.savecom == "save" then
		setBtnStat("bt_page11", 'c')
		setBtnStat("bt_page12", 'c')
		setBtnStat("bt_page13", 'c')
	end

	-- help
	e:tag{"lyprop", id=(getBtnID("help")), visible="0"}
	e:tag{"lyprop", id=(getBtnID("message")), visible="0"}
]]

	-- タイトル画面
	if getTitle() then
--		setBtnStat('bt_title', 'c')
		setBtnStat('bt_save', 'd')
	end
end
----------------------------------------
-- pager設定
function init_pager()
	flg.save.page = flg.save.page or 1 
	for i=1, save_getmaxpage() do
		if flg.save.page == i then
			setBtnStat(("bt_page"..string.format("%02d", i)),"c")
		else
			setBtnStat(("bt_page"..string.format("%02d", i)))
		end
	end
end
----------------------------------------
-- max page
function save_getmaxpage()
	return game.pa and init.save_page or init.save_pagecs
end
----------------------------------------
-- lock check
function save_lockcheck(no)
	local pg = (flg.save.page-1) * init.save_column
	local lk = sys.saveslot.lock
	return lk[pg+no]
end
----------------------------------------
-- lock
function save_lockout(e, p)
	local bt = p.name
	if bt then
		local lv = getBtnInfo(bt)
		local no = tn(lv.p2)
		if save_lockcheck(no) then
			e:tag{"lyprop", id=(lv.idx..".0"), clip=(lv.clip_c)}
		end
	end
end
----------------------------------------
-- 再描画
function saveload_reload()
	local bt = getbtn_actcursor()		-- 直前のアクティブ情報取得
	local hd = scr.savecom
	local sw = {
		save  = function()  save_readcsv() end,
		load  = function()  load_readcsv() end,
		qload = function() qload_readcsv() end,
		favo  = function()  favo_readcsv() end,
	}
	if sw[hd] then sw[hd]() end
	save_delthumb() flip()
	if hd == "favo" then	favopage_init()
	else					saveload_init() end
	if bt then btn_active2(bt) end		-- アクティブ再設定
	flip()
end
----------------------------------------
function saveload_change(name)
	flg.save.move = nil
	if name == "qload" then flg.saveqload = true else flg.saveqload = nil end
	local sw = {
		save  = function() sysvo("open_save") save_init() end,
		load  = function() sysvo("open_load") load_init() end,
		qload = function() sysvo("open_load") load_init() end,
		favo  = function() sysvo("open_favo") favo_init() end,
	}
	if sw[name] then sw[name]() end
end
----------------------------------------
-- セーブデータチェック
--[[
function get_savedatatime(num)
	local ret  = nil
	local path = e:var("s.savepath").."/"..init.save_prefix..string.format("%02d", num)
	e:tag{"var", name="t.tmp", file=(path..".dat"), system="file_update_time", format="yyyy/MM/dd\nhh:mm"}
	local time = e:var("t.tmp")
	if time ~= "" then
		ret = { time=(time), file=(path) }
	end
	return ret
end
]]
----------------------------------------
-- セーブ番号描画
function set_saveno(num, id)
	local p = NumToGrph(num)
	local v = getBtnInfo('num')
	local t = 0
		if p[1] >= 20 then t = 1 p[1] = p[1] - 20
	elseif p[1] >= 10 then t = 1 p[1] = p[1] - 10 end
	table.insert(p, 1, t)

	local x = v.x
	local y = v.y
	local w = v.cw
	local a = ","..v.cy..","..v.cw..","..v.ch
	for i=1, #p do
		local idx  = id..".3"..i
		local clip = (p[i] * w + v.cx)..a
		lyc2{ id=(idx), file=(v.path..v.file), x=(x), y=(y), clip=(clip)}
		x = x + w - 1
	end
--[[
	local x = v.x + v.w - 1
	local y1 = v.h * p[1] + v.cy
	local y2 = v.h * p[2] + v.cy
	local c1 = v.cx..","
	local c2 = ","..v.cw..","..v.ch
	lyc2{ id=(id..".30"), file=(v.path..v.file), x=(v.x), y=(v.y), clip=(c1..y1..c2)}
	lyc2{ id=(id..".31"), file=(v.path..v.file), x=(x  ), y=(v.y), clip=(c1..y2..c2)}
]]
end
----------------------------------------
-- 
----------------------------------------
-- 大サムネイル
function save_thover(e, p)
	local name = p.name
	local v = getBtnInfo(name)
	if v then
		local pg = (flg.save.page-1) * init.save_column + v.p1

		if flg.saveqload then pg = game.qsavehead + v.p1 end

		local fp = e:var("s.savepath").."/"
		local th = csv.mw.savethumb_l
		local tb = sys.saveslot[pg]
		if tb and isSaveFile(pg) then
			local id = "500.big."
			local file = tb.file.."_l"
			lyc2{ id=(id.."base"), file=(fp..file), x=(th.x), y=(th.y)}

			local time = os.date("%Y/%m/%d  %H:%M", tb.date)
			ui_message(id..'.date', {"savedate", text=(time)})
			ui_message(id..'.titl', {"savetitl", text=(tb.title)})	-- "文字が入ります文字が入ります文字が入ります")
			ui_message(id..'.text', {"save",	 text=(tb.text)})	--"文字が入ります文字が入ります文字が入ります文字が入ります文字が入ります文字が入ります")

			-- new
			local last = sys.saveslot.last
			if pg == last then tag{"lyprop", id=(id.."top"), visible="1"}
			else			   tag{"lyprop", id=(id.."top"), visible="0"} end
		else
			save_delthumb_l()
		end
	end
end
----------------------------------------
-- 大サムネイル戻し
function save_thout(e, p)

end
----------------------------------------
-- 大サムネイルを消去
function save_delthumb_l()
	local id = "500.big."
	lydel2(id.."base")
	tag{"lyprop", id=(id.."top"), visible="0"}

	ui_message(id..'.date')
	ui_message(id..'.titl')
	ui_message(id..'.text')
end
----------------------------------------
-- サムネイルを消去
function save_delthumb()
--[[
	for i=1, init.save_column do
		local no = string.format("%02d", i)
		local id = getBtnID('bt_save'..no)
		lydel2(id..'.10')
	end
]]
end
----------------------------------------
-- 動作
----------------------------------------
-- セーブクリック
function save_click(e, p)
	local bt = p.bt or btn.cursor
	if p.ui == 'EXIT' or bt == 'bt_ret' then
		save_clickret()
	elseif bt == 'bt_load' then 
		adv_load()
	elseif bt == 'bt_save' then
		adv_save()
	elseif bt then
--		message("通知", bt, "が選択されました")

		local pg = flg.save.page

		local v = getBtnInfo(bt)
		local p1 = v.p1
		local p2 = v.p2
--[[
		if p1 == "del" then
			p1 = p2
			local no = (pg-1) * init.save_column + p2
			local lk = sys.saveslot.lock[no]
			if not lk then flg.save.delete = true end
		end
]]
		local sw = {
			title = function() adv_title() end,
			exit  = function() adv_exit()  end,

			-- ページ変更
			page    = function() se_ok() save_pagechange(tn(p2)) end,
			pageadd = function() se_ok() save_pageadd(p2) end,
			change  = function() se_ok() saveload_change(p2) end,

			-- lock
			lock = function()
				local no = (pg-1) * init.save_column + p2
				local lk = sys.saveslot.lock[no]
				if lk then se_cancel()	sys.saveslot.lock[no] = nil
				else	   se_ok()		sys.saveslot.lock[no] = true end
				saveload_reload()
			end,

			-- 移動モード
			move = function()
				se_ok()
				local pg = flg.save.page
				local no = (pg-1) * init.save_column + p2
				flg.save.move = no
				saveload_reload()
			end,
		}
		if sw[p1] then sw[p1]()

		-- save / load
		elseif p1 == "save" or p1 == "del" or p1 == "edit" then
			-- 移動
			local m = flg.save.move
			if m then
				local pg = flg.save.page
				local no = (pg-1) * init.save_column + p2
				if m == no then
					se_cancel()
					flg.save.move = nil
					saveload_reload()
				else
					se_ok()
					flg.save.no = no
					saveload_move(m)
				end

			else

			-- 番号情報を作る
			local pg = flg.save.page
			local no = (pg-1) * init.save_column + p2
			local lk = save_lockcheck(p2)	-- lock情報

			-- qload page
			if flg.saveqload then no = game.qsavehead + p2 end

--			local t = get_savedatatime(no)
			local t = isSaveFile(no)			-- セーブデータ確認
			flg.save.no = no
			flg.save.p1 = tn(p2)

			-- コメント編集	
			if p1 == "edit" then
				if not lk and t then
					se_ok()
					save_comment("save")
				end

			-- delete
			elseif flg.save.delete or p1 == "del" then
				if not lk and t then
					se_ok()
					sv.delparam = no
					dialog('del')
					flg.save.delete = nil
				end

			-- save
			elseif scr.savecom == "save" then
				if lk then
					se_none()
				else
					se_ok()

					-- 上書き
					if t then
						dialog('save2')
	
					-- 新規
					else
						dialog('save')
					end
				end

			-- load
			elseif t then
					se_ok()
					sv.loadfile = t.file
					dialog('load')
			end
			end
		end
	end
end
----------------------------------------
-- returnボタン
function save_clickret()
	if flg.save.move then
		se_cancel()
		flg.save.move = nil
		saveload_reload()
	elseif flg.save.delete then
		se_cancel()
		flg.save.delete = nil
		saveload_reload()
	else
		close_ui()
	end
end
----------------------------------------
-- deleteボタン
function save_clickdel()
	if not flg.save.delete then
		se_ok()
		flg.save.delete = true

		lyc2{ id="500.z", file=(game.path.ui.."delmask")}

		setBtnStat('bt_del', 'c')

		setBtnStat('bt_title', 'c')
		setBtnStat('bt_exit' , 'c')
		setBtnStat('bt_save' , 'd')
		setBtnStat('bt_load' , 'd')
		setBtnStat('bt_qload', 'd')

		-- local pg = flg.save.page
		-- for i=1, 10 do
		-- 	if i ~= pg then
		-- 		local nm = "bt_page"..string.format("%02d", i)
		-- 		setBtnStat(nm, 'd')
		-- 	end
		-- end
		flip()
	end
end
----------------------------------------
-- 移動
function saveload_move(m)
	local no = flg.save.no
	local v  = sys.saveslot
	local s  = tcopy(v[m])

	message("通知", m, "→", no)

	-- 入れ替え
	if v[no] then
		local z  = tcopy(v[no])
		sys.saveslot[m]  = z
		sys.saveslot[no] = s

	-- 移動
	else
		sys.saveslot[no] = s
		sys.saveslot[m] = nil
	end

	-- 最新ファイルの確認
	sv.checknewfile()

	flg.save.move = nil
	estag("init")
	estag{"asyssave"}
	estag{"saveload_reload"}
	estag()
end
----------------------------------------
-- コメント書き換え
function save_comment(nm)
	local no = flg.save.no
	local s  = nm == "save" and sys.saveslot or nm == "favo" and sys.favo
	if no and s[no] then
		local v  = s[no]
		local tx = v.text

		-- def
		if not v.def then s[no].def = tx end

		-- 呼び出し
		tag_dialog({ varname="t.yn", textfield="t.tx", textfieldsize="100", message=(tx) }, "save_commentsave", nm)
	end
end
----------------------------------------
function save_commentsave(nm)
	local no = flg.save.no
	local s  = nm == "save" and sys.saveslot or nm == "favo" and sys.favo
	local yn = tn(e:var("t.yn"))
	local tx = e:var("t.tx")
	if yn == 1 then
		se_ok()
		if tx == "" then tx = s[no].def end
		tx = tx:gsub("[\n\t]", "")		-- 念の為

		-- 本文の文字数を制限
		tx = tx:gsub("　", "")
		tx = mb_substr(tx, 1, init.save_message_max)

		-- 保存
		s[no].text = tx
		estag("init")
		estag{"asyssave"}
		estag{"saveload_reload"}
		estag()
	else
		se_cancel()
	end
end
----------------------------------------
-- ボタン番号を保存しておく
function save_btnover(e, p)
	local bt = p.name
	if bt then
		local v = getBtnInfo(bt)
		local p2 = v.p2
		flg.save.btnno = p2
		local ss   = csv.mw.savethumb
		tween{id=("500."..v.id.."."..ss.id), time="250",alpha="255,165"}
	end
end
----------------------------------------
function save_btnout(e, p)
	local bt = p.name
	if bt then
		local v  = getBtnInfo(bt)
		local p2 = v.p2
		local no = flg.save.btnno
		local ss   = csv.mw.savethumb
		tween{id=("500."..v.id.."."..ss.id), time="250",alpha="165,255"}
		if p2 == no then
			flg.save.btnno = nil
		end
	end
end
----------------------------------------
function save_f1del()
	local no = flg.save.btnno
	if no then
		local bt = "bt_del"..string.format("%02d", no)
		save_click(e, {bt=(bt)})
	end
end
----------------------------------------
function save_f2move()
	local no = flg.save.btnno
	if no then
		local bt = "bt_move"..string.format("%02d", no)
		save_click(e, {bt=(bt)})
	end
end
----------------------------------------
-- 
----------------------------------------
-- ページ切り替え
function save_pagechange(p)
--	local nm = "bt_page"..string.format("%02d", flg.save.page)
--	setBtnStat(nm)
	flg.save.page = p
	message("ページ変更")
	saveload_init()
	flip()
end
----------------------------------------
-- ページ切り替え/加算
function save_pageadd(add)
	local p = (flg.save.page or 1) + add
	local m = save_getmaxpage()
	if p < 1 then p = m elseif p > m then p = 1 end
	save_pagechange(p)
end
----------------------------------------
-- L1キー処理
function save_l1(e, p)
--	se_page()
	local no = flg.save.page
	local mx = init.save_page
	if scr.savecom == "load" then mx = mx + 1 end
	no = no - 1
	if no < 1 then no = mx end
	save_pagechange(no)
end
----------------------------------------
-- R1キー処理
function save_r1(e, p)
--	se_page()
	local no = flg.save.page
	local mx = init.save_page
	if scr.savecom == "load" then mx = mx + 1 end
	no = no + 1
	if no > mx then no = 1 end
	save_pagechange(no)
end
----------------------------------------
function save_helpover(e, p)
	local nm = p.name
	if nm then
		local lv = getBtnInfo(nm)
		local no = tn(lv.p3)
		local v  = getBtnInfo("message")
		local cl = v.cx..","..(v.cy+v.ch*no)..","..v.cw..","..v.ch
		e:tag{"lyprop", id=(getBtnID("help")), visible="1"}
		e:tag{"lyprop", id=(getBtnID("message")), visible="1", clip=(cl)}
		flg.help = nm
	end
end
----------------------------------------
function save_helpout(e, p)
	local nm = p.name
	local sp = flg.help
	if nm and nm == sp and game.os ~= "android" then
		e:tag{"lyprop", id=(getBtnID("help")), visible="0"}
		e:tag{"lyprop", id=(getBtnID("message")), visible="0"}
		flg.help = nil
	end
end
----------------------------------------
-- 
----------------------------------------
-- 
function save_delete()
	local bt = btn.cursor
	if bt then
		local v  = getBtnInfo(bt)
		if v.p1 then
			local no = (flg.save.page-1) * init.save_column + v.p1
			local t  = isSaveFile(no)			-- セーブデータ確認
			if t then
				sv.delparam = no
				dialog("del")
			end
		end
	end
end
----------------------------------------
-- 
----------------------------------------
-- quickロードファイルチェック
function quickloadCheck()
	return isSaveFile(sys.saveslot.quick, "quick")
end
----------------------------------------
