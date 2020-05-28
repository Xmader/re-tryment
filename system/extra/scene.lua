----------------------------------------
-- おまけ／シーン
----------------------------------------
-- シーン初期化
function exf.scinit()

	if not appex.scen then appex.scen = {} end

	-- シーン取得
	local stm = 0
	local stc = 0
	for set, v in pairs(csv.extra_scene) do
		local p = v[1]
		local n = v[2]
		local m = table.maxn(v) - 2

		-- 保存
		local fl = v[3]
		local fx = gscr.scene[set]
		if not appex.scen[p]	then appex.scen[p] = {} end
		if not appex.scen[p][n] then appex.scen[p][n] = { file=(fl), label=(v[4]), thumb=(v[5]), flag=(fx), exec=(v[6]) } end
		if fx then stc = stc + 1 end
		stm = stm + 1
	end

	-- パーセント
--	local px = stc == stm and 100 or percent(stc, stm)
--	exf.percent("500.nm", px, "num01")

	-- 各ページのボタン数
	local mx = appex.scen.pagemax
	for i, v in ipairs(appex.scen) do
		appex.scen[i].bmax = #v
		appex.scen[i].pmax = math.ceil(#v / mx)
	end
end
----------------------------------------
-- ページ生成
function exf.scpage()
	local p, page, char = exf.getTable()
	local px = p.p

	-- ページ本体
	local max = px.pagemax
	if max then
		local mask = getBtnInfo("cg01")
		local path = game.path.ui.."extra/"
		for i=1, max do
			local hd = (page - 1) * max
			local mv = px[char][p.head + i]
			local nm = "cg"..string.format("%02d", i)
			local id = getBtnID(nm)

			-- ボタン
			if not mv then
				tag{"lyprop", id=(id), visible="0"}
			else
				tag{"lyprop", id=(id), visible="1"}
				local idt = id..".-1"
				if mv.flag then 
					lyc2{ id=(idt), file=(":thumb/"..mv.thumb), x=(px.tx), y=(px.ty)}
					setBtnStat(nm, nil)
				else
					lydel2(idt)
					setBtnStat(nm, 'c')
				end
			end
		end
--[[
		-- ページ番号表示
--		exf.pageno("no01", page)
--		exf.pageno("no02", px[char].pmax)
		for i=1, px[char].pmax do
			local name = "page"..string.format("%02d", i)
			if i == page then
				setBtnStat(name, 'c')
			else
				setBtnStat(name, nil)
			end
		end
]]
		-- キャラ表示
		local m = #px
		for i=1, m do
			local name = "page"..string.format("%02d", i)
			if i == char then
				setBtnStat(name, 'c')
			else
				setBtnStat(name, nil)
			end
		end
	end
end
----------------------------------------
--
----------------------------------------
-- 呼び出し
function exf.sceneview(no)
	local p, page, char = exf.getTable()
	local z = appex.scen.pagemax
	local n = (page-1) * z + no
	local v = p.p[char][n]
	if v.flag then
		local file = v.file

		message("通知", file, ":", v.label, "を呼び出します")

		-- 実行後コマンド
		appex.exec = nil
		if v.exec then appex.exec = v.exec end

		-- 動画再生
		if file == "movie" then
			exf.movieplay(v.label)

		-- シーン再生
		else
			-- 再生中のbgmを保存しておく
			local b = getplaybgmfile()
			appex.playbgm = b

			-- シーンを閉じる
			e:tag{"lydel", id="400"}
			e:tag{"lydel", id="500"}
			e:tag{"lydel", id="600"}
--			extra_scene_reset()

			flg.scene = v
			e:tag{"jump", file="system/ui.asb", label="exscene_jump"}
		end
	end
end
----------------------------------------
-- 実行
function extra_scene_jump2()
	ResetStack()		-- スタックリセット
	local v = flg.scene

	-- 念のためリセット
	reset_backlog()
	key_reset()
	adv_flagreset()

	-- 呼び出し
	ast = nil
	scr.ip = nil
	readScriptStart(v.file, v.label)
end
----------------------------------------
-- シーン選択再表示
function extra_goscene()

	-- 実行後コマンド
	local nm = appex.exec
	local sw = {
		-- cgリセット
		evcheck = function()
			appex.cgmd = nil
		end,
	}
	if nm and sw[nm] then sw[nm]() end

	-- bgm再生
	local fl = getplaybgmfile(appex.playbgm)
	if fl then
		bgm_play{ file=(fl), sys=true }
		appex.playbgm = nil
	else
		title_bgm()
	end
	scr.ip = nil

	-- scene
	extra_init("scen", true)
	uitrans()
end
----------------------------------------

----------------------------------------
-- シーンボタン生成
----------------------------------------
--[[
function extra_scene_init()
	message("通知", "イベントモードを開きました")

	bgm_play{ file=(""..init.title_bgm) }

	-- 先にデータを作っておく
	local smax = 0
	local scnt = 0
	if not sys.extra then sys.extra = { page=1 } end
	flg.scene = { pagesize=csv.ui_scene[2], lx=csv.ui_scene[3], ly=csv.ui_scene[4], page=1 }
	for set, v in pairs(csv.extra_event) do
		local no = tn(set)
		local p = v[1]
		local n = v[2]
		if not flg.scene[p] then flg.scene[p] = {} end
		if not flg.scene[p][n] then flg.scene[p][n] = { name=(no), file=(v[3]), label=(v[4]), thumb=(v[5]) } end
		smax = smax + 1

		-- 開放具合を確認しておく
		if gscr.scene[no] then scnt = scnt + 1 end
	end
	flg.scene.pagemax = table.maxn(flg.scene)	-- 最大ページ数
--	flg.scene.smax = smax		-- 差分総数
--	flg.scene.scnt = scnt		-- 差分オープン数

	-- ボタン描画
	csvbtn3("scen", "500", csv.ui_scene)
	e:tag{"lyprop", id=(getBtnID("mask")), visible="0"}

--	if get_eval("sf.s3002") == 0 then setBtnStat('bt_cg'   , 'c') end	-- cg
--	if get_eval("sf.s3003") == 0 then setBtnStat('bt_scene', 'c') end	-- scene
--	if get_eval("sf.s3004") == 0 then setBtnStat('bt_bgm'  , 'c') end	-- bgm

	-- 達成率を書き換え
	local r = percent(scnt, smax)
	message("通知", "差分：", scnt, "/", smax, r, "%")
	if r < 100 then
		e:tag{"lyprop", id=(getBtnID("per01")), visible="0"}
		local p = NumToGrph(r)

		-- 10
		if p[1] == 0 then
			e:tag{"lyprop", id=(getBtnID("per02")), visible="0"}
		else
			local v = getBtnInfo("per02")
			e:tag{"lyprop", id=(v.idx), clip=((p[1] * v.w + v.cx)..","..v.cy..","..v.cw..","..v.ch)}
		end

		-- 1
		local v = getBtnInfo("per03")
		e:tag{"lyprop", id=(v.idx), clip=((p[2] * v.w + v.cx)..","..v.cy..","..v.cw..","..v.ch)}
	end

	extra_scene_page(sys.extra.page)
	e:tag{"jump", file="system/ui.asb", label="exbgm_open"}
end
----------------------------------------
-- scene page
function extra_scene_page(page)

	-- 最終ページ処理
	if page < flg.scene.pagemax then
		e:tag{"lyprop", id=(getBtnID("frame01")), visible="1"}
		e:tag{"lyprop", id=(getBtnID("frame02")), visible="0"}
	else
		e:tag{"lyprop", id=(getBtnID("frame01")), visible="0"}
		e:tag{"lyprop", id=(getBtnID("frame02")), visible="1"}
	end

	-- ページ番号
--	local v = getBtnInfo('no01')
--	local x = (page-1) * v.w + v.cx
--	e:tag{"lyprop", id=(v.idx), clip=(x..","..v.cy..","..v.cw..","..v.ch)}

	-- サムネイル表示
	local addy = (page - 1) * flg.scene.pagesize
	local z = init.exscene
	local t = init.exscenename
	local m = getBtnInfo("mask")
	for i=1, flg.scene.pagesize do
		local p = flg.scene[page][i]
		local n = "cg"..string.format("%02d", i)
		local v = getBtnInfo(n)
		e:tag{"lyprop", id=(v.idx), visible="1"}

		-- 有効
		if p and gscr.scene[p.name] then
			lyc2{ id=(v.idx..".-1"), file=(m.path.."thumb/"..p.thumb), x=(m.x), y=(m.y) }
--			lyc2{ id=(v.idx..".-1.0"), file=(v.path..v.file), clip=(v.clip_c)}
--			lyc2{ id=(v.idx..".-1.1"), file=(z[1]..p.thumb), x=(z[2]), y=(z[3])}
--			setBtnStat(n)

			-- シーンタイトル
--			local x = ((i-1) % 5) * t[4]
--			local y = math.floor((addy + i - 1) / 5) * t[5] + t[6]
--			lyc2{ id=(v.idx..".-1.10"), file=(t[1]), x=(t[2]), y=(t[3]), clip=(x..","..y..","..t[4]..","..t[5])}

		-- 無効
		else
			lyc2{ id=(v.idx..".-1"), file=(m.path..m.file), clip=(m.clip), x=(m.x), y=(m.y) }
--			e:tag{"lydel", id=(v.idx..".-1")}
--			setBtnStat(n, "c")
		end
	end

	-- 保存
	sys.extra.page = page
end
----------------------------------------
-- scene close
function extra_scene_reset()
	flg.scene = nil
	flg.exlua = nil
	delbtn('scen')
	e:tag{"lydel", id="600"}
end
----------------------------------------
-- scene close
function extra_scene_close()
--	ReturnStack()	-- 空のスタックを削除
	se_cancel()
	extra_scene_reset()
--	uitrans()
end
----------------------------------------
-- scene close
function extra_scene_exit(e, name)
	if type(name) == "string" then se_ok() else se_cancel() end
	flg.exlua = name
	e:tag{"var", name="t.lua", data="extra_scene_exit2"}
	e:tag{"jump", file="system/ui.asb", label="exbgm_close"}
end
----------------------------------------
function extra_scene_exit2(e, p)
--	ReturnStack()	-- 空のスタックを削除
	local name = flg.exlua
	extra_scene_reset()
	e:tag{"return"}
	e:tag{"return"}

	if type(name) == "string" then
		e:tag{"calllua", ["function"]=(name)}
	else
		title_init()
	end
end
----------------------------------------
-- クリック
function extra_scene_click(e, param)
	local bt = btn.cursor
	if bt then
		ReturnStack()	-- 空のスタックを削除
--		message("通知", bt, "が選択されました")

		local v = getBtnInfo(bt)
		local n = tn(v.p1)
		if n then extra_scene_jump(n)

		elseif bt == "bt_bgm"	then extra_scene_exit(e, "extra_bgm_init")
		elseif bt == "bt_cg" 	then extra_scene_exit(e, "extra_cg_init")
		elseif bt == "bt_cat"   then extra_scene_exit(e, "extra_cat_init")

		elseif bt == "bt_exit" then adv_exit()
		end
	end
end
----------------------------------------
-- L1
function extra_scene_l1()
	se_ok()
	local no = sys.extra.page
	no = no - 1
	if no < 1 then no = flg.scene.pagemax end
	extra_scene_page(no)
	flip()
end
----------------------------------------
-- R1
function extra_scene_r1()
	se_ok()
	local no = sys.extra.page
	no = no + 1
	if no > flg.scene.pagemax then no = 1 end
	extra_scene_page(no)
	flip()
end
]]
----------------------------------------
-- シーンを呼び出す
--[[
function extra_scene_jump(n)
	local v = flg.scene[sys.extra.page][n]
	if gscr.scene[v.name] then
		se_ok()
		message("通知", v.file, ":", v.label, "を呼び出します")

		-- シーンを閉じる
		e:tag{"lydel", id="400"}
		e:tag{"lydel", id="500"}
		e:tag{"lydel", id="600"}
		extra_scene_reset()

		flg.scene = v
		e:tag{"jump", file="system/ui.asb", label="exscene_jump"}
--	else
--		se_none()
	end
end
]]
----------------------------------------
-- シーンから戻る
function extra_scene_return()
	e:tag{"jump", file="system/ui.asb", label="exscene_jump_return"}
end
----------------------------------------
function extra_goscene_exit()
	-- シーンに戻る
	flg.title = { page=true }
	flg.ui = {}
--	e:tag{"return"}
	if scr.eventflag or sys.extra and sys.extra.event then
		exev.delete()
		exev_init()
	else
		extra_scene_init()
	end
	stop2()
end
----------------------------------------
