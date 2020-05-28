----------------------------------------
-- tips
----------------------------------------
function tips_init()
	message("通知", "Library画面を開きました")
	if not flg.tips then flg.tips = {page=1,viewer=false,btn={}} end
	csvbtn3("tips", "500", csv.ui_tips)

	for name, v in pairs(csv.extra_tips) do
		if gscr.tips[name] then
			flg.tips.btn[tn(v[1])] = v[2]
		end
	end
	tips_init_button()
	uiopenanime()
	uitrans()
end

function tips_reset(p)
	flg.tips = nil			-- ボタン用ワークを削除
end
----------------------------------------
-- save画面から抜ける
function tips_close()
	message("通知", "Libraryを閉じました")
	se_cancel()
	
	delbtn("tips")
	uitrans()
end
----------------------------------------
-- 画面を作る
----------------------------------------
-- ボタン再描画
function tips_init_button()
	local nb = flg.tips.page				-- ページ番号
	local pg = (nb-1) * init.tips_column	-- ページ先頭を計算
	local id = "500.bt."
	local path = game.path.ui.."tips/thum/"
	-- 本文生成
	for i=1, init.tips_column do
		local no = pg + i
		local t = flg.tips.btn[no]

		-- tips開放済み
		if t then
			lyc2{id=(id..i..".char"),file=(path..t)}
		else
			setBtnStat(("ch"..string.format("%02d", i)),"c")
		end

	end

	-- ページボタン
	init_tips_pager()
end
----------------------------------------
-- pager設定
function init_tips_pager()
	flg.tips.page = flg.tips.page or 1 
	local max = init.tips_page_max
	for i=1, max do
		if flg.tips.page == i then
			setBtnStat(("bt_page"..string.format("%02d", i)),"c")
		else
			setBtnStat(("bt_page"..string.format("%02d", i)))
		end
	end
end

----------------------------------------
-- 動作
----------------------------------------
-- tipsクリック
function tips_click(e, p)
	local bt = p.bt or btn.cursor
	if p.ui == 'EXIT' or bt == 'bt_back' then
		tips_clickret()
	elseif bt then
		local pg = flg.tips.page

		local v = getBtnInfo(bt)
		local p1 = v.p1
		local p2 = v.p2
	    local sw = {
			-- ページ変更
			page    = function() tips_pagechange(tn(p2)) end,
			close   = function() tips_viewer_close() end,
			prev    = function() tips_viewer_prev() end,
			next	= function() tips_viewer_next() end,
			-- 
		}
        if sw[p1] then sw[p1]() 
        else 
			-- 個別画像を開く
			tips_viewer_open(tn(p2))
        end
	end
end
----------------------------------------
-- ボタン番号を保存しておく
function tips_btnover(e, p)
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
function tips_btnout(e, p)
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

function tips_clickret()
	if flg.tips and flg.tips.viewer then tips_viewer_close()
	else close_ui() end
end
------------------------------------------------
-- viewer周辺動作
------------------------------------------------
------------------------------------------------
-- 開く
function tips_viewer_open(id)
	flg.tips.viewer = true
	message("通知","tips viewerを開きました")
	csvbtn3("tips_viewer", "501", csv.ui_tips_viewer)
	-- クリックしたTipsを展開しておく
	local nb = flg.tips.page				-- ページ番号
	local pg = (nb-1) * init.tips_column	-- ページ先頭を計算
	local no = pg+id
	local path =  game.path.ui.."tips/data/"
	local img = csv.mw.tips
	flg.tips.current_pos = no -- 現在見ているtipsの位置
	message(path..flg.tips.btn[no])
	lyc2{id=("501.img"),file=(path..flg.tips.btn[no])}
	uitrans()
end
------------------------------------------------
-- 閉じる
function tips_viewer_close()
	flg.tips.viewer = false
	message("通知","tips viewerを閉じます")
	tag{"lydel",id="501"}
	tips_init()
end
-----------------------------------------------
--  次へ
function tips_viewer_next()
	local no = flg.tips.current_pos
	local idx = next(flg.tips.btn,no)
	local path =  game.path.ui.."tips/data/"
	local img = csv.mw.tips
	if idx then
		flg.tips.current_pos = idx
		lyc2{id=("501.img"),file=(path..flg.tips.btn[idx])}
		trans({time=500})
	end
end
-----------------------------------------------
--  前へ
function tips_viewer_prev()
	local no = flg.tips.current_pos
	local max = table.maxn(flg.tips.btn)
	local idx = nil 
	for i=no-1,1,-1 do
		if flg.tips.btn[i] then idx = i break end
	end
	local path =  game.path.ui.."tips/data/"
	local img = csv.mw.tips
	if idx then
		flg.tips.current_pos = idx
		lyc2{id=("501.img"),file=(path..flg.tips.btn[idx])}
		trans({time=500})
	end
end
-----------------------------------------------
----------------------------------------
-- ページ切り替え
function tips_pagechange(p)
--	local nm = "bt_page"..string.format("%02d", flg.save.page)
--	setBtnStat(nm)
	flg.tips.page = p
	message("ページ変更")
    tips_init()
	flip()
end
----------------------------------------
-- L1キー処理
function tips_l1(e, p)
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
function tips_r1(e, p)
--	se_page()
	local no = flg.save.page
	local mx = init.save_page
	if scr.savecom == "load" then mx = mx + 1 end
	no = no + 1
	if no > mx then no = 1 end
	save_pagechange(no)
end