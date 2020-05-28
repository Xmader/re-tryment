----------------------------------------
-- ■ バックログ
----------------------------------------
-- バックログバッファをリセット
function reset_backlog()
	log = {
		p = 1,
		count = 1,
		stack = {}
	}
	flg.blog = nil
	backlog_mode(1, "init")
end
----------------------------------------
-- 初期化
function blog_init()
	message("通知", "バックログを開きました")
--	se_ok()
--	sysvo("open_blog")
--	voice_stopallex(0)		-- 一旦全停止
	backlog_mode(1, true)	-- テキスト消去

	-- バッファの初期化
	local pgmx = init.backlog_page
	local max  = table.maxn(log.stack)
	local max2 = max < pgmx and max or pgmx
	local file = scr.ip.file
	flg.blog = { max=(max), pgmx=(max2), file=(file), cache={} }

	-- ページ算出
	local page = max - pgmx
	if page < 1 then page = 1 end
	flg.blog.page = 0

	-- ダミー作成
	sys.blog = { buff = 100 }

	-- text cache
	blog_cache()

	-- uiの初期化
	csvbtn3("blog", "500", csv.ui_backlog)
	local page = init.backlog_page
	if max <= page then
		-- slider
		e:tag{"lyprop", id="500.sl", visible="0"}

		-- 未使用ボタン
		for i=max+1, page do
			e:tag{"lyprop", id=("500.bt."..i), visible="0"}
			e:tag{"lyprop", id=("500.bx."..i), visible="0"}
		end
	else
		flg.blog.page   = max - page
		flg.blog.slider = true
	end

	-- drag
	local id = "500.0"
	local wd = game.width
	local he = game.height
	lyc2{ id=(id..".drag"), width=(wd), height=(he), color="00000000", draggable="1", dragarea="0,-720,0,720"}
	lyevent{ id=(id..".drag"), dragin="blog_draginit", drag="blog_drag", dragout="blog_dragout"}

	view_backlog()			-- 最新データを読み込み

	-- メニューから来たら一旦閉じる
--	if scr.menu then
--		e:tag{"jump", file="system/ui.asb", label="log_openmenu"}
--	else
--		e:tag{"jump", file="system/ui.asb", label="log_open"}
--	end
	uiopenanime()
	uitrans()
end
----------------------------------------
-- 状態クリア
function blog_reset()
	voice_stopallex() 		-- 音声全停止
	backlog_mode(1, true)	-- テキスト消去
	delbtn('blog')			-- 削除
	sys.blog = nil			-- ダミークリア
	flg.blog = nil			-- バッファクリア
end
----------------------------------------
-- バックログを抜ける
function blog_close()
	message("通知", "バックログを閉じました")
	se_cancel()

--	if flg.blog.file ~= scr.ip.file then readScriptFile(scr.ip.file) end
	local s = flg.blog.file
	if s then readScriptFile(s, true) end

--	local time = blog_closeanime()
	uicloseanime()
	blog_reset()

--	eqwait(time)
--	flip2()
	uitrans()
end
----------------------------------------
-- スクロール演出
--[[
function blog_closeanime()
	local time = 200
--	tween{ id="500.1", x="0,1260", time=(time), ease="out"}
--	tween{ id="500.2", x="0,200" , time=(time), ease="out"}
	tween{ id="500", alpha="255,0", time=(time)}
	return time
end
]]
----------------------------------------
-- active
function log_active()
	if game.os ~= "android" then
		btn_active("btn0"..flg.blog.pgmx)
	end
end
----------------------------------------
-- 
----------------------------------------
-- cache
function blog_cache()
	local file = nil
	local p = log.stack
	local m = #p
	for i=1, m do
		local v = log.stack[i]
		local t = { text={}, voice={}, face={} }

		-- text
		if v then
			----------------------------------------
			-- script read
			if file ~= v.file then
				file = v.file
				readScriptFile(file, true)
			end

			----------------------------------------
			-- cacheに格納
			if v.select then
				t.name = { text="選択肢" }
				t.text = {{ v.select }}
			else
				-- face
				if v.face then t.face = tcopy(v.face) end
				-- テキスト取得
				local bl = v.block
				for nm, q in pairs(getText(bl)) do
					if type(q) == 'table' then
						-- 選択肢
						if q.select then
							t.name = {"name", name="選択肢"}

						-- voice
						elseif nm == "vo" then
							for i, z in pairs(q) do
								table.insert(t.voice, z)
							end
						
						-- 名前
						elseif nm == "name" then
							t.name = tcopy(q)
						-- 本文
						else
							table.insert(t.text, q)
						end
					end
				end
			end
			flg.blog.cache[i] = t
		end
	end
end
----------------------------------------
-- ■ バックログ / 表示
----------------------------------------
function view_backlog()
	local bx   = flg.blog
	local max  = bx.max
	local page = bx.page
	local pg   = init.backlog_page
	local nx   = init.mwnameframe
	local nf   = csv.font.logname

	backlog_mode(1, true)	-- 消去

	----------------------------------------
	-- 各ページをループで回す
	local file = scr.ip.file
	for i=1, pg do
		local no = page + i
		local t  = bx.cache[no]		-- cacheから読み出す
		local id = "500.bt.tx."..i

		----------------------------------------
		-- 表示
		if t then

			----------------------------------------
			-- 名前
			local nm = t.name
			if nm then
				local nz = nm.text or nm.name
				if nx and type(nx) == 'table' then nz = nx[1]..nz..nx[2] end
				-- 名前の多言語変換
				local lng = conf.language
				if lng ~= "ja" and csv.name[nz][lng] then nz = csv.name[nz][lng] end
				-- 名前の長さ確認
				local c = #nz
				local s = nil
				if c >= 19 then
					s = nf.size - c + 17
				end
				e:tag{"chgmsg", id=(id..".0"), layered=(1)}
				e:tag{"print", data=(nz)}
				if s then tag{"/font"}	end
				e:tag{"/chgmsg"}
--				if nm.voice then vo = true end
				e:tag{"lyprop", id=(getBtnID("name0"..i)), visible="1"}

			else
				e:tag{"lyprop", id=(getBtnID("name0"..i)), visible="0"}
			end

			-- voice
			if next(t.voice) then 
				setBtnStat("btn0"..i)
			else
				setBtnStat("btn0"..i,"c")
			end
			-- 本文
			flg.tximgid = id..".1"
			e:tag{"chgmsg", id=(id..".1"), layered=(1)}
			for i, tx in ipairs(t.text) do 
				message_adv(tx, "sys")
				-- 個別デザイン対応
				if tx[1] and tx[1][1] == "exfont" then 
					e:tag{"lyprop",id=(id..".1"),top=(8)}
				else
					e:tag{"lyprop",id=(id..".1"),top=(0)}
				end
			end
			e:tag{"/chgmsg"}
			flg.tximgid = nil

			-- 本文／active
--			e:tag{"chgmsg", id=(id..".2"), layered=(1)}
--			for i, tx in ipairs(t.text) do message_adv(tx) end
--			e:tag{"/chgmsg"}

			-- 座標
			local b = getBtnInfo("btn0"..i)
			e:tag{"lyprop", id=(id), top=(b.y)}

			-- face
			local v = t.face
			if v and v.file then
				setMWFaceFile(v, "blogface", id..".7")
			end
		end
		-- jump
		local vs = no < #bx.cache and 1 or 0
		e:tag{"lyprop", id=(getBtnID("jump0"..i)), visible=(vs)}
	end

	-- ボタンをアクティブにする
--	local c = flg.blog.act or flg.blog.pgmx
--	btn_over(e, { key=("btn0"..c), se=true, flip=true})
end
----------------------------------------
-- 消去とレイヤーモード変更
function backlog_mode(mode, del)
	-- 各ページをループで回す
	local ext = "_"..conf.language
	if conf.language == "ja" then ext = "" end
	for i=1, init.backlog_page do
		-- 名前
		local id = "500.bt.tx."..i..".0"
		set_textfont("logname"..ext, (id),true)
		e:tag{"chgmsg", id=(id), layered=(mode)}
		if del then e:tag{"rp"} end
		e:tag{"/chgmsg"}

		-- 本文
		local id = "500.bt.tx."..i..".1"
		 set_textfont("backlog"..ext, (id),true)
		e:tag{"chgmsg", id=(id), layered=(mode)}
		if del then e:tag{"rp"} end
		e:tag{"/chgmsg"}
		e:tag{"lyprop", id=(id), alpha="255"}

		-- 本文／アクティブ色
--		local id = "500.bt.tx."..i..".2"
--		if del == 'init' then set_textfont("backlog_a", (id)) end
--		e:tag{"chgmsg", id=(id), layered=(mode)}
--		if del then e:tag{"rp"} end
--		e:tag{"/chgmsg"}
--		e:tag{"lyprop", id=(id), alpha="0"}
	end

	-- delete
	if del then
		e:tag{"lydel", id="500.bt.tx"}
	end
end
----------------------------------------
-- drag
----------------------------------------
-- 
function blog_draginit(e, p)
	local bx = flg.blog
	local mx = bx.max - bx.pgmx
	if mx > 0 then
		local bt = btn.cursor
		if not bt and not flg.dlg then flg.blog.drag = 0 end
	end
end
----------------------------------------
-- 
function blog_drag(e, p)
	local bx = flg.blog
	local r  = true
	local tm = bx.dragtime
	if not tm or e:now() > tm + 120 then
		flg.blog.dragtime = e:now()
	else
		r = nil
	end

	local dr = bx.drag
	if r and dr then
		e:tag{"var", name="t.ly", system="get_layer_info", id="500.0.drag"}
		local dy = tn(e:var("t.ly.top"))
		local y  = math.floor((dr - dy) / 70) + 1
		if dr ~= dy then
			log_addpage(y)
		end
	end
end
----------------------------------------
-- 
function blog_dragout(e, p)
	local id = "500.0"
	tag{"lyprop", id=(id..".drag"), top="0"}
	flip()
	flg.blog.drag = nil
	flg.blog.dragtime = nil
end
----------------------------------------
-- バックログボタンまわり
----------------------------------------
-- クリックされた
function log_click(e, p)
	local nm = p.bt or p.btn or p.key
	local v  = getBtnInfo(nm) or {}
	local p1 = v.p1
	local p2 = v.p2

	local sw = {

		----------------------------------------
		-- scroll
		scroll = function()
			if nm ~= "HUP" and nm ~= "HDW" then se_ok() end
			local c = init["blog_scroll0"..p2]
			if c then
				local add = c * v.p3
				log_addpage(add, nm)
			end
		end,

		----------------------------------------
		-- cursor
		cursor = function()
			se_active()
			log_addcursor(p2)
		end,

		----------------------------------------
		-- voice
		voice = function()
			local no = flg.blog.page + p2

			-- 音声再生
			local tbl = flg.blog.cache[no].voice
			if tbl then
				voice_stopallex(0)		 -- 一旦全停止
				voice_replay(tbl, true)
			end
		end,

		----------------------------------------
		-- お気に入り
		favo = function()
			local no = flg.blog.page + p2
			local tbl = flg.blog.cache[no]
			if tbl then
				se_ok()
				flg.favo = tbl
				open_ui('favo')
			end
		end,

		----------------------------------------
		-- sback
		jump = function()
			local no = flg.blog.page + p2
			local mx = #log.stack
			if no < mx then goBacklogJump(no) end
		end,

		----------------------------------------
		-- system
		title = function() adv_title() end,
		exit  = function() adv_exit()  end,
	}
	if sw[p1] then sw[p1]() end
end
----------------------------------------
-- カーソル移動
function log_addcursor(add)
	local bx = flg.blog
	local mx = bx.pgmx

	-- 移動
	local ct = bx.cursor
	if not ct then
		ct = add == -1 and 1 or mx
	else
		ct = ct + add
		if ct > mx then
			log_addpage(1, "DW")
			ct = mx
		elseif ct < 1 then
			log_addpage(-1, "UP")
			ct = 1
		end
	end
	flg.blog.cursor = ct
	local nm = "btn0"..ct
	btn_active2(nm)
	flip()
end
----------------------------------------
-- ページ移動
function log_addpage(add, nm)
	local bx = flg.blog
	local mx = bx.max - bx.pgmx
	local pg = bx.page
	if mx > 0 then
		local p = pg + add
		if mx == p-1 then
			if nm == "DW" then close_ui() end	-- 抜ける
		else
			if p > mx then p = mx
			elseif p < 0 then p = 0 end
			flg.blog.page = p
			view_backlog()
			log_sliderpos()
			flip()
		end
	elseif nm == "DW" then
		close_ui()			-- 抜ける
	end
end
----------------------------------------
-- ボタンup
function log_btnup(e, p)
	local ct = flg.blog.act or flg.blog.pgmx
	if ct <= 1 then
		se_active()
		log_addpage(-1)
	else
		ct = ct - 1
		btn_out( e, { key=(btn.cursor) })
		btn_over(e, { key=("btn0"..ct) })
	end
end
----------------------------------------
-- ボタンdown
function log_btndw(e, p)
	local mx = flg.blog.max		-- 全体数
	local pm = flg.blog.pgmx	-- ボタン数
	local pg = flg.blog.page	-- ページ管理
	local ct = flg.blog.act		-- ページ内のカーソル位置
	if ct == pm then
		if ct + pg >= mx then
			close_ui()			-- 抜ける
		else
			se_active()
			log_addpage(1)		-- 加算
		end
	else
		ct = ct + 1
		btn_out( e, { key=btn.cursor })
		btn_over(e, { key=("btn0"..ct) })
	end
end
----------------------------------------
-- ボタンover
function log_btnover(e, p)
	local nm = p.name
	if nm then
		local v  = getBtnInfo(nm)
		local no = tn(v.p2)
		local id =  "500.bt.tx."..no..".1"
		tween{id=(id), time="250",alpha="255,165"}
		-- カーソル位置
		if game.os ~= "android" then
			flg.blog.act = no
		end
		flg.blog.btnno = v.p2
	end
end
----------------------------------------
-- ボタンout
function log_btnout(e, p)
	local nm = p.name
	if nm then
		local v  = getBtnInfo(nm)
		local no = tn(v.p2)
		local id =  "500.bt.tx."..no..".1"
		tween{id=(id), time="250",alpha="165,255"}
		-- カーソル位置
		if game.os ~= "android" then
			flg.blog.act = no
		end
		local no2 = flg.blog.btnno
		if v.p2 == no2 then
 			flg.blog.btnno = nil
 		end
	end
end
----------------------------------------
-- スライダーpos制御
function log_sliderpos()
	if flg.blog.slider then
		local max = flg.blog.max - init.backlog_page
		local y   = percent(flg.blog.page, max)

		-- btn
		local name = btn.name
		local tbl  = btn[name].p.slider
		local pos  = repercent(y, tbl.h - tbl.p2)

		-- 移動
		local id = btn[name].id..tbl.id..".10"
		e:tag{"lyprop", id=(id), top=(pos)}
	end
end
----------------------------------------
-- スライダー制御
function backlog_slider(e, p)
	local max = flg.blog.max - init.backlog_page
	local p   = tn(p.p)
	local no  = repercent(p, max)
	if no ~= flg.blog.page then
		flg.blog.page = no
		view_backlog()
		flip()
	end
end
----------------------------------------
-- 
----------------------------------------
-- -- ボタン番号を保存しておく
-- function log_btnover(e, p)
-- 	local bt = p.name
-- 	if bt then
-- 		local v = getBtnInfo(bt)
-- 		local p2 = v.p2
-- 		flg.blog.btnno = p2
-- 	end
-- end
-- ----------------------------------------
-- function log_btnout(e, p)
-- 	local bt = p.name
-- 	if bt then
-- 		local v  = getBtnInfo(bt)
-- 		local p2 = v.p2
-- 		local no = flg.blog.btnno
-- 		if p2 == no then
-- 			flg.blog.btnno = nil
-- 		end
-- 	end
-- end
----------------------------------------
-- quickjump
function log_f1jump(e, p)
	local no = flg.blog.btnno
	if no then
		log_click(e, { bt=("jump0"..no) })
	end
end
----------------------------------------
-- お気に入りボイス
function log_f2favo(e, p)
	local no = flg.blog.btnno
	if no then
		log_click(e, { bt=("favo"..no) })
	end
end
----------------------------------------
-- ■ バックログ記録
----------------------------------------
-- メッセージウィンドウ１画面分を書き込み終えた時の処理
function set_backlog_next()
	local qj = getQJumpStack()	-- BackLogJump管理テーブル
	local va = getEvalPoint()	-- 変数ポインタ
	local fa = getBlogFace()	-- 立ち絵表情
	local bs = getBselPoint()	-- 前の選択肢に戻るポインタ
	local ss = tcopy2(scr.gss)	-- GameScriptStack(call)管理テーブル
	local sn = scr.ip.file		-- script name
	local sb = scr.ip.block		-- script block

	-- テーブルを分解して格納する(ポインタ回避)
	table.insert(log.stack, { file=(sn), block=(sb), blj=(qj), gss=(ss), eval=(va), face=(fa), bsel=(bs) })

	-- 最大数を超えていたら先頭を削除
	if table.maxn(log.stack) >= init.backlog_max then
		table.remove(log.stack, 1)
	end
end
----------------------------------------
-- 一番新しいバックログデータを返す
function get_lastlog(flag)
	local mx = #log.stack
	if mx == 0 then return end
	local bl  = log.stack[mx].block
	if scr.select then bl = bl + 1 end
	local tbl = getText(bl)

	-- nameのみ返す
	if flag == "name" then
		local tx = ""
		if tbl and tbl.name then
			tx = tbl.text or tbl.name
		end
		tbl = tx

	-- textにして返す
	elseif flag then
		local tx = ""
		for tg, v in pairs(tbl) do
			-- 選択肢
			if tg == 'select' then
				for x, s in ipairs(v) do tx = tx.."『"..s.."』" end

			-- tag
			elseif type(tg) == 'string' then

			-- text
			else
				for x, s in pairs(v) do
					if type(x) == 'number' and type(s) == 'string' then tx = tx..s end
				end
			end
		end
		if tx ~= "" then tbl = tx end
	end
	return tbl
end
----------------------------------------
-- ■ バックログジャンプ
----------------------------------------
-- バックログジャンプ実行確認
function goBacklogJump(no)
	flg.blogno = no
	se_ok()
	dialog("jump")
end
----------------------------------------
function goBacklogJumpTo()
	local no = flg.blogno
	flg.blogno = nil
	quickjumpui(no, "blog")
end
----------------------------------------
