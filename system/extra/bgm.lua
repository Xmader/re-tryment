----------------------------------------
-- おまけ／BGM
----------------------------------------
-- 初期化
function exf.bginit()

	if not appex.bgmd then appex.bgmd = {} end

	-- bgm title clip
	local p = appex.bgmd
	local x = p.lx
	local y = p.ly
	local h = p.ty
	local z = ","..p.tx..","..h

	-- 曲名取得 / 番号順に並べる
--	local path = game.path.ui.."extra/bgmnm01"
	local tbl = {}
	local flag = init.extrabgm_flag == "all" and 1
	for i, v in pairs(csv.extra_bgm) do
		local no = tn(v[1])
		if no and no > 0 then
			appex.bgmd[no] = { file=i, no=(no), text=(v[3]), flag=(flag or gscr.bgm[i]) }
				
			-- title
			if flag or gscr.bgm[i] then
				tttl = v[3]
			end
		end
	end

	-- 曲名座標を読み込む
--	e:include(game.path.ui.."exname.ipt")	appex.bgmd.ipt  = tcopy(ipt)
--	e:include(game.path.ui.."exname2.ipt")	appex.bgmd.ipt2 = tcopy(ipt)

	-- 現在のページ位置
	local p = appex.bgmd
	local max = #p
	appex.bgmd.pg  = 1
	appex.bgmd.max = max	-- 曲数

	exf.musicpage()

	-- noを再生中の曲に合わせる
	local t = init.title_bgm
	if type(t) == "table" then
		t = gscr.clear_fhalfflag and t[2] or t[1]
	end
	local file = getplaybgmfile() or t
	local no = max
	for i, v in ipairs(p) do
		if file == v.file then
			no = i
			appex.bgmd.play = true
			break
		end
	end
	appex.bgmd.no = no
	exf.musictitle(true)

	-- 再生中ならフラグを立てておく
--	local fl = getplaybgmfile()
--	if fl then exf.bgmplay(fl) end
end

---------

function extra_volchange()
	conf.bgm = sys.extr.bgm
	volume_bgm() 
end

-------------------------------
-- 現在のページ
function exf.musicpage()
	local pg = appex.bgmd.pg
	local max = init.ex_bgm_num_max or 30
	local max_page = math.ceil(#appex.bgmd/max) 
	local flag = true
	if appex.bgmd.no then
	-- 現在再生中のボタンを通常状態へ変更
		local nm = "bgm"..string.format("%02d", appex.bgmd.no)
		local v  = getBtnInfo(nm)
		tag{"lyprop", id=(v.idx..".0"), clip=(v["clip"])}
		exf.musictitle()
	end
	local path = game.path.ui.."extra/music/list/"
	for i=1,max_page do
		if pg == i then
			setBtnStat(("page"..string.format("%02d", i)),"c")
		else
			setBtnStat(("page"..string.format("%02d", i)))
		end
	end
	for i=max_page+1,10 do
		local btn = getBtnInfo(("page"..string.format("%02d", i)))
		e:tag{"lydel",id=(btn.idx)}
	end
	for i=1, max do
		local no = i + (pg-1)*max
		local id = getBtnID("bgm"..string.format("%02d", i))
		tag{"lydel",id=(id..'.23')}
		if flag or gscr.bgm[no] then
			local tttl  = "track"..string.format("%02d", no)
			if e:isFileExists(path..tttl..".png") then lyc2{id=(id..'.23'),file=(path..tttl),x=(22),y=(15)} end
		end
	end
	
	uitrans(500)
end
----------------------------------------
-- 再生停止
function exf.musicreset()
	local p  = appex.bgmd
	local no = p.no
	if no then
		local nm = "bgm"..string.format("%02d", no)
		--setBtnStat(nm, nil)
	end
end
----------------------------------------
-- 曲名
function exf.musictitle(flag)
	local p  = appex.bgmd
	local no = p.no 
	local pg = p.pg
	local max = init.ex_bgm_num_max or 30
	local bid= p.no 
	if p.no > max then bid = p.no - max * (pg - 1) end
	local fl = getplaybgmfile()
	-- 再生中ボタン
	local nm = "bgm"..string.format("%02d", no)
	local v  = getBtnInfo(nm)
	local bx = not appex.bgmd.play and "clip_a" or flag and "clip_d" or "clip_c"
	if pg * max >= no and no > (pg-1)*max then tag{"lyprop", id=(v.idx..".0"), clip=(v[bx])} end
--[[
	if fl then
		local nm = "bgm"..string.format("%02d", no)
		setBtnStat(nm, 'c')

		-- 曲名
		local h = (no-1) * v.h
		local clip = "0,"..h..","..v.w..","..v.h
		setBtnStat("bt_play", 'c')
		setBtnStat("bt_stop", nil)
		tag{"lyprop", id=(id), visible="1", clip=(clip)}
	else
		setBtnStat("bt_play", nil)
		setBtnStat("bt_stop", 'c')
		tag{"lyprop", id=(id), visible="0"}
	end
]]
end
----------------------------------------
-- 
----------------------------------------
-- bgmボタンの属性を変える
--[[
function exf.musicbtn(name, act)
	local fl = game.path.ui.."exname"
	local v  = getBtnInfo(name)
	local p  = appex.bgmd
	local pg = p.pg
	local no = tn(v.p2)

--	local c = pg + no
--	local t = p[c]
--	local ix = p.ipt[t.file]
--	lyc2{ file=(fl), id=(v.idx..".-1"), clip=(ix[act])}
end
----------------------------------------
]]
function extra_btmbtn_over(e, p)
	local bt = p.name
	local v  = getBtnInfo(bt)
	local p  = appex.bgmd
	local no = p.no
	if appex.bgmd.play and no == tn(v.p2) then
		e:tag{"lyprop", id=(v.idx..".0"), clip=(v.clip_d)}
	else
	--	tween{id=(v.idx), time="250",alpha="255,165"}
	end
--	exf.musicbtn(bt, 2)
end
----------------------------------------
function extra_btmbtn_out(e, p)
	local bt = p.name
	local v  = getBtnInfo(bt)
	local p  = appex.bgmd
	local no = p.no
	if appex.bgmd.play and no == tn(v.p2) then
		e:tag{"lyprop", id=(v.idx..".0"), clip=(v.clip_c)}
	else
	--	tween{id=(v.idx), time="250",alpha="165,255"}
	end
--	exf.musicbtn(bt, 1)
end
----------------------------------------
-- 
----------------------------------------
-- bgmクリック
function exf.clickbgm(num)
	local p = appex.bgmd
	local max = p.max
	local pg  = p.pg
	local no  = (pg - 1)* 30 + num
	if no > max then no = max end

	-- 現在再生中のボタンを通常状態へ変更
	local nm = "bgm"..string.format("%02d", appex.bgmd.no)
	local v  = getBtnInfo(nm)
	tag{"lyprop", id=(v.idx..".0"), clip=(v["clip"])}

	se_ok()
	exf.musicreset()
	exf.bgmplay(p[no].file)
	appex.bgmd.no = no
	exf.musictitle()
	flip()
end
----------------------------------------
-- bgmボタン制御
function exf.clickbgmbtn(nm)
--	message("通知", nm)

	local sw = {
		play = function() exf.bgmplaystop() end,	-- playボタン
		stop = function() exf.bgmstop() end,		-- stopボタン
		back = function() exf.bgmadd(-1) end,		-- backボタン
		next = function() exf.bgmadd( 1) end,		-- nextボタン
	}
	if sw[nm] then sw[nm]() end
end
----------------------------------------
-- 次の曲へ
function exf.bgmadd(add)
	local p = appex.bgmd
	local max = p.max
	local no  = p.no + add
	exf.musicreset()

	-- pg / no計算
	if no > max then
		no = 1
	elseif no < 1 then
		no = max
	end 
	appex.bgmd.no = no

	----------------------------------------
	-- ページ変更確認
	local px, page, char = exf.getTable()
	local no = p.no
	local ax = math.floor( no / 15 ) + 1
	if page ~= ax then
		gscr.bgmd[char].page = ax
		exf.musicpage()
	end

	----------------------------------------
	se_ok()
	exf.bgmplay(p[no].file)
	exf.musictitle()
	flip()
end
----------------------------------------
-- 再生
function exf.bgmplay(name)
	if appex.bgmd.play then
		local s = scr.bgm.name
		if s == name then
			bgm_stop{}
			appex.bgmd.play = nil
			exf.musictitle()
			flip()
		else
			appex.bgmd.play = true
			bgm_play{ file=(name), sys=true }
		end
	else
		appex.bgmd.play = true
		bgm_play{ file=(name), sys=true }
	end
end
----------------------------------------
-- 再生ボタン
function exf.bgmplaystop()
	se_ok()
	local fl = getplaybgmfile()
	if fl then
		bgm_stop{}
		exf.musicreset()
		flip()
		appex.bgmd.play = nil
	else
		local p = appex.bgmd
		local no  = p.no
		exf.bgmplay(p[no].file)
		exf.musictitle()
		flip()
	end
end
----------------------------------------
-- 停止ボタン
function exf.bgmstop()
	se_ok()
	local fl = getplaybgmfile()
	if fl then
		bgm_stop{}
		appex.bgmd.play = nil
		exf.musicreset()
		exf.musictitle()
		flip()
	end
end
----------------------------------------
-- bgm再開
function exf.bgmrestart()
	local p = appex.bgmd
	if p.play then
		exf.bgmplay(p[p.no].file)
	end
end
----------------------------------------
-- BGMボタン生成
----------------------------------------
--[[
function extra_bgm_init()
	message("通知", "BGMモードを開きました")

	bgm_stop{}

	flg.tsysse = 'none'

	-- 曲名取得 / 番号順に並べる
	local vx = csv.ui_bgmmode
	local tbl = {}
	flg.exbgm = { pagesize=vx[2], lx=vx[3], ly=vx[4], lw=vx[5], lh=vx[6], ady=vx[7] }
	for i, v in pairs(csv.extra_bgm) do
		local no = tn(v[1])
--		if no and no > 0 then flg.exbgm[no] = { file=i, text=v[3] } end
		if no and no > 0 then tbl[no] = { file=i, time=v[4] } end
	end

	-- 開放確認
	for i, v in pairs(tbl) do
		local fl = v.file
		if gscr.bgm[fl] then
			table.insert(flg.exbgm, { file=(fl), time=(v.time) })
		end
	end

	if not flg.extra_bgm then flg.extra_bgm = { play = 0 } end
	flg.exbgm.pagemax = table.maxn(flg.exbgm)
	flg.exbgm.btnmax  = init.exevent_bgm	-- メインのボタン数
	flg.exbgm.now = 1						-- 現在の曲ポインタ(ボタン位置)
	flg.exbgm.rep = 0						-- replay

--	sysse("bgmmode")

	-- テーブルがなければ作成
	if not gscr.exbgm then gscr.exbgm = { page = 0 } end
	gscr.exbgm.page = 0

	-- ボタン描画
	extra_bgm_page()
	btn_active2("bt_bgm01")
	extra_bgm_playbtn()
	uitrans()
end
----------------------------------------
-- bgm close
function extra_bgm_reset()
--	exbgm_text()
	flg.exbgm = nil
	flg.exlua = nil
	flg.repflag = nil
	flg.bgmrep  = nil
	flg.tsysse  = nil
	delbtn('bgmd')
	e:tag{"lydel", id="600"}
end
----------------------------------------
-- bgm close
function extra_bgm_close()
--	ReturnStack()	-- 空のスタックを削除
	se_cancel()
	extra_bgm_reset()
--	uitrans()
end
----------------------------------------
-- bgm close
function extra_bgm_exit(e, name)
	if type(name) == "string" then se_ok() else se_cancel() end
	flg.exlua = name
	bgm_stop{}
	e:tag{"var", name="t.lua", data="extra_bgm_exit2"}
	e:tag{"jump", file="system/ui.asb", label="exbgm_close"}
end
----------------------------------------
function extra_bgm_exit2()
--	ReturnStack()	-- 空のスタックを削除
	local name = flg.exlua
	extra_bgm_reset()
	e:tag{"return"}
	e:tag{"return"}

	if type(name) == "string" then
		e:tag{"calllua", ["function"]=(name)}
	else
		title_init()
	end
end
----------------------------------------
-- bgm page
function extra_bgm_page()
	local pg = gscr.exbgm.page or 0

	csvbtn3("bgmd", "500", csv.ui_bgmmode)

	-- 曲名配置
	local v    = flg.exbgm
	local tbl  = v
	local y = 0 - pg * v.ady
	local path = game.path.ui
	local nbtn = 'music01'
	local abtn = 'music02'
	local cbtn = 'music02'
	e:include(path..nbtn..'.ipt')
	for i, n in ipairs(tbl) do
		local id = "500.4.b.0."..i
		lyc2{ id=(id..".1"), file=(path..nbtn)}
		lyc2{ id=(id..".2"), file=(path..cbtn)}
		lyc2{ id=(id..".3"), file=(path..abtn)}
		local clip = ipt[n.file]
		tag{"lyprop", id=(id..".1"), clip=(clip)}
		tag{"lyprop", id=(id..".2"), clip=(clip), visible="0", colormultiply="FFD080", alpha="96"}	--layermode="multiply"}
		tag{"lyprop", id=(id..".3"), clip=(clip), visible="0"}
		tag{"lyprop", id=(id), top=(y)}
		y = y + v.ady
	end
	tag{"lyprop", id="500.4.b", left=(v.lx), top=(v.ly)}
	tag{"lyprop", id="500.4", intermediate_render=",", intermediate_render_mask=(game.path.ui..'musicmask')}

	-- リピートボタン
	extra_bgm_repeat()

	-- page
--	setBtnStat("page0"..pg, "c")
end
----------------------------------------
-- scroll
function extra_bgm_scroll(pg)
	local v  = flg.exbgm
	local p1 = gscr.exbgm.page
	local y1 = -p1 * v.ady
	local y2 = -pg * v.ady

	-- 一旦カーソルを消す
	local bt = btn.cursor
	if bt then
		flg.exbgm.bt = bt
		btn_out(e, { key=(bt), flip=true })
	end

	local time = init.excgtime
	tween{ id="500.4.b.0", y=(y1..","..y2), time=(time)}
	eqwait(time)
	eqtag{"calllua", ["function"]="extra_bgm_scroll2"}

	gscr.exbgm.page = pg
end
----------------------------------------
-- 
function extra_bgm_scroll2()
	local bt = flg.exbgm.bt or btn.cursor
	if bt then btn_active2(bt) flip() end
end
]]
----------------------------------------
-- テキスト設定と削除
--[[
function exbgm_text()
	for n, v in pairs(btn[btn.name].p) do
		if type(v) == "table" and v.p1 then
			local idx = getBtnID(n)..".2"
			set_textfont("exbgm", idx)
			e:tag{"chgmsg", id=(idx), layered="1"}
			e:tag{"rp"}
			e:tag{"/chgmsg"}
		end
	end
end
]]
----------------------------------------
--
----------------------------------------
-- cursor
--[[
function extra_bgm_cursor(bt, flag)
	if bt then
		local pg = gscr.exbgm.page or 0
		local t  = getBtnInfo(bt)
		local c  = pg + t.p1
		local id = "500.4.b.0."..c
		if flag then
			tag{"lyprop", id=(id..".1"), visible="0"}
			tag{"lyprop", id=(id..".3"), visible="1"}
		else
			tag{"lyprop", id=(id..".1"), visible="1"}
			tag{"lyprop", id=(id..".3"), visible="0"}
		end
	end
end
----------------------------------------
-- over
function extra_bgm_over(e, p)
	local nm = p.name
	if nm then extra_bgm_cursor(nm, true) end
end
----------------------------------------
-- out
function extra_bgm_out(e, p)
	local nm = p.name
	if nm then extra_bgm_cursor(nm) end
end
----------------------------------------
-- btn over
function extra_bgm_btover(e, p)
end
----------------------------------------
-- btn out
function extra_bgm_btout(e, p)
	local nm = p.name
	local v  = flg.exbgm
	local t  = getBtnInfo(nm)
	if nm == 'bt_rand' and v.rand then
		tag{"lyprop", id=(t.idx..".0"), clip=(t.clip_c)}
	elseif nm == 'bt_rep2' and v.rep == 1 then
		tag{"lyprop", id=(t.idx..".0"), clip=(t.clip_c)}
	elseif nm == 'bt_rep1' and v.rep == 2 then
		tag{"lyprop", id=(t.idx..".0"), clip=(t.clip_c)}
	end
end
----------------------------------------
--
function extra_bgm_playdel()
	local no = flg.exbgm.now
	if no then tag{"lyprop", id="500.4.b.0."..no..".2", visible="0"} end
end
----------------------------------------
-- play/stopボタン
function extra_bgm_playbtn(flag)
	if flag then
		setBtnStat('bt_play', 'c')
		setBtnStat('bt_stop', nil)
		local no = flg.exbgm.now
		tag{"lyprop", id="500.4.b.0."..no..".2", visible="1"}
	else
		setBtnStat('bt_play', nil)
		setBtnStat('bt_stop', 'c')
	end
end
----------------------------------------
-- リピートボタン
function extra_bgm_repeat()
	local r  = flg.exbgm.rep or 0
	local t1 = getBtnInfo("bt_rep1")
	local t2 = getBtnInfo("bt_rep2")
	local nx = flg.bgmrep
	if r == 0 then
		tag{"lyprop", id=(t1.idx..".0"), clip=(t1.clip)}
		tag{"lyprop", id=(t1.idx), visible="1"}
		tag{"lyprop", id=(t2.idx), visible="0"}
		setBtnStat('bt_rep1', nil)
		setBtnStat('bt_rep2', 'c')
		btn_active2("bt_rep1")
		if nx then flg.repflag = true end
	elseif r == 1 then
		tag{"lyprop", id=(t1.idx), visible="0"}
		tag{"lyprop", id=(t2.idx), visible="1"}
		setBtnStat('bt_rep1', 'c')
		setBtnStat('bt_rep2', nil)
		btn_active2("bt_rep2")
		if nx then flg.repflag = nil end
	else
		tag{"lyprop", id=(t1.idx..".0"), clip=(t1.clip_c)}
		tag{"lyprop", id=(t1.idx), visible="1"}
		tag{"lyprop", id=(t2.idx), visible="0"}
		setBtnStat('bt_rep1', nil)
		setBtnStat('bt_rep2', 'c')
		btn_active2("bt_rep1")
		if nx then flg.repflag = true end
	end
end
----------------------------------------
-- 
----------------------------------------
-- クリック
function extra_bgm_click(e, p)
	local bt = btn.cursor
	if bt then
--		ReturnStack()	-- 空のスタックを削除
--		message("通知", bt.."が選択されました")

		local v = getBtnInfo(bt)
		local n = tn(v.p1)
		local g = tn(v.p2)
		local switch = {
			bt_play = function() extra_bgm_play() end,
			bt_stop = function() extra_bgm_stop() end,
			bt_back = function() extra_bgm_back() end,
			bt_next = function() extra_bgm_next() end,
			bt_rand = function() extra_bgm_rand() end,
			bt_rep1 = function() extra_bgm_repeatbtn(1) end,
			bt_rep2 = function() extra_bgm_repeatbtn(2) end,
		}
		if n then extra_bgm_start(n)
		elseif g then
--			se_ok()
			gscr.exbgm.page = g
			extra_bgm_page()
			flip()

		elseif bt and switch[bt] then switch[bt]()

--		elseif bt == "bt_play" then extra_bgm_replay()
--		elseif bt == "bt_stop" then extra_bgm_stop()

		elseif bt == "bt_cg"	then extra_bgm_exit(e, "extra_cg_init")
		elseif bt == "bt_scene" then extra_bgm_exit(e, "extra_scene_init")
		elseif bt == "bt_cat"   then extra_bgm_exit(e, "extra_cat_init")

		elseif bt == "bt_exit" then adv_exit()
		end
	end
end
----------------------------------------
-- L1
function extra_bgm_l1()
--	se_ok()
	local pg = gscr.exbgm.page
	local v  = flg.exbgm
	local ct = v.pagesize
	pg = pg - ct
	if pg <= -ct then pg = #v - ct elseif pg < 0 then pg = 0 end
	extra_bgm_scroll(pg)
end
----------------------------------------
-- R1
function extra_bgm_r1()
--	se_ok()
	local pg = gscr.exbgm.page
	local v  = flg.exbgm
	local ct = v.pagesize
	local mx = #v
	pg = pg + ct
	if pg >= mx then pg = 0 elseif pg > mx - ct then pg = mx - ct end
	extra_bgm_scroll(pg)
end
----------------------------------------
-- UP
function extra_bgm_up()
	local bt = btn.cursor or "bt_bgm09"
	if bt then
		local v  = flg.exbgm
		local t  = getBtnInfo(bt)
		local p1 = tn(t.p1)
		if p1 and p1 == 1 then
			local pg = gscr.exbgm.page
			local ct = flg.exbgm.pagesize
			local mx = #v - ct
			pg = pg - 1
			if pg < 0 then pg = mx end
			extra_bgm_cursor('bt_bgm01')
			flip()
			extra_bgm_scroll(pg)
		else
			btn_up(e, { name=(bt) })
		end
	else
		btn_active("bt_bgm09")
	end
end
----------------------------------------
-- DW
function extra_bgm_dw()
	local bt = btn.cursor
	if bt then
		local v  = flg.exbgm
		local t  = getBtnInfo(bt)
		local p1 = tn(t.p1)
		if p1 and p1 >= v.pagesize then
			local pg = gscr.exbgm.page
			local ct = flg.exbgm.pagesize
			local mx = #v - ct
			pg = pg + 1
			if pg > mx then pg = 0 end
			extra_bgm_cursor('bt_bgm09')
			flip()
			extra_bgm_scroll(pg)
	--		extra_bgm_cursor('bt_bgm09', true)
		else
			btn_down(e, { name=(bt) })
		end
	else
		btn_active("bt_bgm01")
	end
end
----------------------------------------
-- 
----------------------------------------
-- BGM再生 / playボタン
function extra_bgm_play()
	local v  = flg.exbgm
	local mx = #v
	local no = flg.exbgm.now or 1
	local rd = no
	flg.repflag = nil

	-- ランダム再生
	if v.rand then
		repeat
			rd = (e:random() % (mx-1)) + 1
		until (rd ~= no)
		extra_bgm_start(rd, true)
	else
		extra_bgm_start(rd)
	end
end
----------------------------------------
-- nextボタン
function extra_bgm_next()
	local v = flg.exbgm
	if v.rand then
		extra_bgm_play()
	else
		local no = (v.now or 1) + 1
		local mx = #v
		if no > mx then no = 1 end
		extra_bgm_start(no, true)
	end
end
----------------------------------------
-- backボタン
function extra_bgm_back()
	local v  = flg.exbgm
	if v.rand then
		extra_bgm_play()
	else
		local no = (flg.exbgm.now or 1) - 1
		local mx = #v
		if no < 1 then no = mx end
		extra_bgm_start(no, true)
	end
end
----------------------------------------
-- randボタン
function extra_bgm_rand()
	local t  = getBtnInfo("bt_rand")
	local v  = flg.exbgm
	local r  = not v.rand
	flg.exbgm.rand = r
	if r then
		tag{"lyprop", id=(t.idx..".0"), clip=(t.clip_c)}
	else
		tag{"lyprop", id=(t.idx..".0"), clip=(t.clip)}
	end
	flip()
end
----------------------------------------
-- repeatボタン
function extra_bgm_repeatbtn(no)
	local t  = getBtnInfo("bt_rep"..no)
	local v  = flg.exbgm
	local r  = (v.rep or 0) + 1
	if r > 2 then r = 0 end
	flg.exbgm.rep = r

	extra_bgm_repeat()
	flip()
end
----------------------------------------
-- 
----------------------------------------
-- BGM再生
function extra_bgm_start(num, flag)
	local pg = gscr.exbgm.page or 0
	local v  = flg.exbgm
	local ct = pg + num
	if flag then ct = num end
	if v[ct] then
		local file = v[ct].file
		if file == scr.bgm.file then
			-- 再生中なのでなにもしない
		else
			-- リピート設定があったらtimeを保存しておく
			local time = v[ct].time - 4		-- 4:無音補正
			local rep  = v.rep
			flg.bgmrep = e:now() + time * 1000
			if rep ~= 1 then
				flg.repflag = rep
			end

			bgm_play{ file=(file) }

			extra_bgm_playdel()		-- 前回の曲を非表示
			flg.exbgm.now = ct
			extra_bgm_playbtn(true)	-- 現在の曲をアクティブ
			flip()

			-- 範囲外にボタンがあったら画面内に戻す
			local mx = v.pagesize
			local xx = v.pagemax

			-- １つ上
			if ct == pg and pg > 0 then
				extra_bgm_scroll(pg - 1)

			-- １つ下
			elseif ct == pg + mx + 1 then
				extra_bgm_scroll(pg + 1)

			-- 画面内
			elseif ct >= pg and ct < pg + mx + 1 then

			-- スクロール
			else
				ct = ct - 5
				if ct < 0 then ct = 0 elseif ct > xx - mx then ct = xx - mx end
				extra_bgm_scroll(ct)
			end
		end
	end
end
----------------------------------------
-- bgm停止
function extra_bgm_stop()
	flg.repflag = nil
	flg.bgmrep  = nil
	bgm_stop{}
	extra_bgm_playdel()
	extra_bgm_playbtn()
	flip()
end
----------------------------------------
-- bgm自動停止
function extra_bgm_autostop()
	local v = flg.exbgm
	if v.rep == 0 then
		extra_bgm_stop()	-- 停止
	else
		flg.repflag = nil
		flg.bgmrep  = nil
		bgm_stop{}			-- 次の曲
		tag{"call", file="system/ui.asb", label="exbgm_autoplay"}
	end
end
]]
----------------------------------------
