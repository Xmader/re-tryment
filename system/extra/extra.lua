----------------------------------------
-- おまけ／共通化
----------------------------------------
exf = {}
----------------------------------------
exf.table = {
	cgmd = { ui="ui_cgmode" , init="cginit", view="cgpage", vo="open_cgmode", flag="ev"    },	-- CG鑑賞
	scen = { ui="ui_scene"  , init="scinit", view="scpage", vo="open_scene" , flag="scene" },	-- シーン鑑賞
	bgmd = { ui="ui_bgmmode", init="bginit", view="bgpage", vo="open_music" , flag="bgm"   },	-- 音楽鑑賞
	movi = { ui="ui_movie"  , init="mvinit", view="mvpage", vo="open_movie" , flag="movie" },	-- 動画鑑賞
	exfg = { ui="ui_fgmode" , init="fginit", view="fgpage", vo="open_fgmode", flag="exfg", reset="fgexit", exit="fgexit" },	-- 立ち絵鑑賞
}
----------------------------------------
function extra_cgmode()	extra_init("cgmd") end
function extra_scene()	extra_init("scen") end
function extra_bgmmd()	extra_init("bgmd") end
function extra_movie()	extra_init("movi") end
----------------------------------------
-- 呼び出し初期化
function extra_init(name, flag)
	local p = exf.table[name]
	message("通知", name, "を開きました")

	flg.titleextra = true

	-- sysvo
--	if not flag and p.vo then sysvo(p.vo) end

--	bgm_play{ file=(init.title_bgm) }

	-- 念のため入れておく
	flg.ui = {}
	setonpush_ui()

	-- テーブルがなければ作成
	if not appex then appex = {} end
	if not appex[name] then appex[name] = {} end
	if not gscr.extra then gscr.extra = {} end
	if not gscr[name] then gscr[name] = {} end
	if not sys.extr then sys.extr = { music=100, play=1} end
	sys.extr.bgm = conf.bgm 
	sys.extr.bgmDefault = conf.bgm 
	-- 開かれていたら閉じる
	local nm = appex.name
	local px = nm and exf.table[nm]
	if px and exf[px.reset] then exf[px.reset]() end
	appex.name = name
	gscr.extraname = name

	-- ボタン描画
	csvbtn3("extr", "500", csv[p.ui])

	-- ページ数
	local cxt = csv[p.ui]
	if cxt[2] then
		appex[name].pagemax = cxt[2]	-- ページ内のボタン数
		appex[name].lx = cxt[3]			-- サムネイルx数
		appex[name].ly = cxt[4]			-- サムネイルy数
		appex[name].tx = cxt[5]			-- サムネイルx補正
		appex[name].ty = cxt[6]			-- サムネイルy補正
	end

	-- データを作っておく
	if p.init and exf[p.init] then exf[p.init]() end

	-- 表示
	extra_page()
--	uiopenanime()
	uitrans()
end
----------------------------------------
-- ページ処理
function extra_page()
	local p, page, char = exf.getTable()

	-- キャラボタン
--	setBtnStat("page0"..char, 'c')		-- 

	-- 各ページへ
	local s = p.t.view	-- exf.table[name].page
	if s and exf[s] then exf[s]() end
--	exf.mvpage()

	-- フラグで開放
--	local p3 = tn(get_eval("g.allclear"))
--	if p3 == 0 then setBtnStat("bt_bgm", 'd') end

	-- 保存
	local nm = p.name
	if nm == "bgmd" then exf.musicpage() end
	gscr[nm][char].page = page
end
----------------------------------------
-- 閉じる
function extra_exit()
	ReturnStack()	-- 空のスタックを削除
	se_cancel()

	-- 個別exitがあれば呼ぶ
	local p = exf.getTable()
	local ex = p.t and p.t.exit
	if ex and exf[ex] then exf[ex]() end
	if flg.excgbuff and p.name == "cgmd" then return exf.closecg() end
	-- 削除
	conf.bgm = sys.extr.bgmDefault
	volume_bgm() 
	delbtn('extr')		-- 削除
	appex = nil
	sys.extr = nil

	-- titleへ
	title_init()
end
----------------------------------------
-- 
----------------------------------------
-- 変数まとめて取得
function exf.getTable()
	local name = appex.name
	local px   = appex[name]
	local char = gscr.extra.char or px.char or 1
	local tbl  = exf.table[name]

	if not gscr[name][char] then gscr[name][char] = {} end
	local page = gscr[name][char].page or 1
	local head = (page - 1) * px.pagemax

	local r = {
		name = name,
		char = char,
		page = page,
		head = head,
		p    = px,
		t    = tbl,
	}
	return r, page, char
end
----------------------------------------
-- ページ番号処理
function exf.pageno(name, no)
	local v = getBtnInfo(name)
	if v.dir == "width" then
		local z = no * v.cw + v.cx
		local c = z..","..v.cy..","..v.cw..","..v.ch
		tag{"lyprop", id=(v.idx), clip=(c)}
	end
end
----------------------------------------
-- パーセント処理
function exf.percent(id, num, name, flag)
	local a = NumToGrph3(num)
	local v = getBtnInfo(name)
	local w = v.w
	local h = v.h
	local z = ",0,"..w..","..h

	-- 100
	if a[1] == 1 then tag{"lyprop", id=(id..".1"), clip=(w..z)}
	elseif flag then  tag{"lyprop", id=(id..".1"), clip=((11 * w)..z)}
	else			  tag{"lyprop", id=(id..".1"), clip=("0,"..z)} end

	-- 10 / 1
	tag{"lyprop", id=(id..".2"), clip=((a[2] * w)..z)}
	tag{"lyprop", id=(id..".3"), clip=((a[3] * w)..z)}
end
----------------------------------------
-- 
----------------------------------------
-- クリック共通
function extra_click()
	local bt = btn.cursor
	if bt then
		local v = getBtnInfo(bt)
		local c = v.p1
		local n = tn(v.p2)

--		message("通知", bt.."が選択されました", c, n)

		local sw = {
			bt_exit = function() se_ok() adv_exit() end,

			extra	= function() exf.clickextra(v.p2) end,
			click	= function() exf.clickcheck(n) end,
			box		= function() exf.clickbox(n) end,
			char	= function() exf.charchange(n) end,
			page	= function() exf.pagechange(n) end,
			pageadd = function() exf.addpage(n) end,
			pagemax = function() exf.addpage("min") end,
			pagemin = function() exf.addpage("max") end,
			prev    = function() exf.prevcg() end,
			next	= function() exf.nextcg() end,
			close	= function() exf.closecg() end ,
			bgm		= function() exf.clickbgm(n) end,		-- bgm直接再生
			play	= function() exf.clickbgmbtn(v.p2) end,	-- bgmプレイヤーボタン
		}
		local nm = c or bt
		if sw[nm] then sw[nm](n) end

--[[
		-- cg view
		if n then extra_cg_view(n)

		-- page
		elseif c then extra_cg_pagech(c)
		elseif bt == "bt_bgm"	then extra_cg_exit(e, "extra_bgm_init")
		elseif bt == "bt_scene" then extra_cg_exit(e, "extra_scene_init")
		elseif bt == "bt_cat"   then extra_cg_exit(e, "extra_cat_init")

		elseif bt == "bt_exit" then adv_exit()
		end
]]
	end
end
----------------------------------------
-- おまけ移動
function exf.clickextra(nm)
	if exf.table[nm] then
		se_ok()
		extra_init(nm)
	end
end
----------------------------------------
-- 本体クリック
function exf.clickcheck(no)
	local p, pg, ch = exf.getTable()
	local s = (pg-1) * (p.p.pagemax or 0) + no
	if p.p[ch][s].flag then
		se_ok()
		local sw = {
			cgmd = function() exf.cgview(no) end,
			scen = function() exf.sceneview(no) end,
			movi = function() exf.playmovie(no) end,
		}
		if sw[p.name] then sw[p.name]() end
	end
end
----------------------------------------
-- キャラ変更
function exf.charchange(no)
	local p = exf.getTable()
	local nm = p.name

	-- cg/scene
	if nm == "cgmd"  then
		se_ok()
		setBtnStat("page0"..p.char, nil)	-- キャラボタン有効化
		appex[nm].char = no					-- char保存
		gscr.extra.char = no				-- char保存 / 共通
		extra_page()
		flip()

	-- movie/box
	else
		se_ok()
		if appex.bgmd then appex.bgmd.pg = no	end		-- char保存
		exf.musicpage()
	end
end
----------------------------------------
-- ページ変更
function exf.pagechange(no)
	local p, pg, ch = exf.getTable()
	local nm = p.name
--	if nm == "cgmd" or nm == "scen" then
		se_ok()
		local px = p.p[ch]
		local mx = px.pmax
--		pg = pg + no
--		if pg < 1 then pg = mx elseif pg > mx then pg = 1 end
		message(nm,ch)
		gscr[nm][ch].page = no
		extra_page()
		flip()
--	end
end
----------------------------------------
-- ページ変更／加算
function exf.addpage(no)
	local p, pg, ch = exf.getTable()
	local nm = p.name
	if nm == "cgmd" or nm == "scen" then
		se_ok()
		local px = p.p[ch]
		local mx = px.pmax 
		if no == "min" then
			pg = 1
		elseif no == "max" then
			pg = mx
		else
			pg = pg + no
			if pg < 1 then pg = mx elseif pg > mx then pg = 1 end
		end
		gscr[nm][ch].page = pg
		extra_page()
		flip()
	end
end
----------------------------------------
-- movie
----------------------------------------
-- 
function exf.movieplay(file)
	local time = 1500
--	allkeyoff()

	-- 再生中のbgmを保存しておく
	local b = getplaybgmfile()
	flg.extra_playbgm = b

	bgm_stop{ time=(time) }

	-- 停止キー
	local ky = getKeyString("CANCEL")
	tag{"keyconfig", role="1", keys=(ky)}

	-- path
	local n = "movierename_"..file
	if init[n] then file = init[n] end
	local path = game.path.movie..file..game.movieext

	lyc2{ id="900", file=(init.black) }
	estag("init")
	estag{"uitrans", (time)}
	estag{"video", file=(path), skip="2"}
	estag{"keyconfig", role="1", keys=""}
	estag{"lydel", id="900"}
	estag{"uitrans", (time)}
	estag{"extra_movieend"}
	estag()
end
----------------------------------------
function extra_movieend()
	-- bgm再開
	local fl = getplaybgmfile(flg.extra_playbgm)
	if fl then
		bgm_play{ file=(fl), sys=true }
		flg.extra_playbgm = nil
	else
		title_bgm()
	end
end
----------------------------------------
