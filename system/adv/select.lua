----------------------------------------
-- 選択肢
----------------------------------------
-- 選択肢割り振り
function exselect(p)
	-- 初期化
	if not scr.select then
		message("通知", "選択肢を初期化します")
		scr.select = { idx={} }
	end

	if p.text then	select_text(p)				-- textがあれば追加
	else			select_start(p) end			-- 実行
end
----------------------------------------
-- 選択肢のボタンテキストを設定する
function select_text(p)
	local tbl = {
		file  = p.file,
		label = p.label,
		text  = p.text,
		exp   = p.exp,
--		cond  = p.cond,
	}

	-- cond
	if p.cond then tbl.cond = p.cond end

	-- 代入
	table.insert(scr.select, tbl)
end
----------------------------------------
-- 選択肢を初期化する
function select_start(p)
	local name = p.name or scr.ip.file
	local mwnm = p.nw
	local mwtx = p.mw
	local mode = p.mode
	local asel = tn(p.auto or 0)
	scr.select.name = name
	scr.select.mwnm = mwnm
	scr.select.mwtx = mwtx

	delImageStack()		-- cache delete

	----------------------------------------
	-- 拡張選択肢
	if p.mode == "ex" then
		local r = select_extendCheck(p.func)	-- 拡張選択肢使用可確認
		if r then
			estag("init")
			estag{"msgoff"}						-- 念のため[msgoff]しておく
			estag{"exskip_stop"}				-- debugskip停止
			estag{"select_init"}				-- 選択肢設定
			estag{"select_extendinit", p}		-- 拡張選択肢設定
			estag()
		else
			error_message("拡張選択肢の呼び出しに失敗しました")
		end

	----------------------------------------
	-- 自動選択１
	elseif asel == 1 and conf.finish01 ~= 2 then
		scr.select.id = conf.finish01 + 1
		scr.select.autoselect = true
		estag("init")
		estag{"exskip_stop"}			-- debugskip停止
		estag{"select_clicknext"}
		estag()

	----------------------------------------
	-- 自動選択２
	elseif asel == 2 and conf.finish02 ~= 2 then
		scr.select.id = conf.finish01 + 1
		scr.select.autoselect = true
		estag("init")
		estag{"exskip_stop"}			-- debugskip停止
		estag{"select_clicknext"}
		estag()

	----------------------------------------
	-- 実行
	else
		local md = p.mode
		estag("init")
		estag{"exskip_stop"}					-- debugskip停止
		estag{"select_init"}
		if md == 'hide' then 
			estag{"msgon", { mode="hide" }}		-- mw非表示 / 選択肢のみ入力許可
			scr.select.hide = true
		else
			if md == "sys" and game.pa then
				estag{"msgon", { mode="sys" }}	-- ボタンのみ表示モード
				scr.select.mwsys = true
			else
				estag{"msgon"}					-- 念のため[msgon]しておく
			end
			local bl = #log.stack
			if bl > 0 and md ~= 'nosave' then
				estag{"select_autosave"}		-- autosave
			end
		end
		estag{"select_view"}					-- 表示
		estag{"select_event"}					-- lyevent割り当て
		estag()
	end
end
----------------------------------------
-- 拡張選択肢 / 確認
function select_extendCheck(nm)	return exSelectTable and exSelectTable[nm] end
function select_extendinit(p)	select_extend("init", p) end
----------------------------------------
-- 拡張選択肢
function select_extend(ex, p)
	local r = true
	local s = scr.select
	local t = exSelectTable
	local nm = p and p.func or s and s.func
	if s and t and nm and t[nm] and t[nm][ex] then
		if ex == "init" then
			message("通知", "拡張選択肢モードに入ります。")
			scr.select.func = nm
--		else
--			message("通知", "拡張選択肢モード", ex)
		end
		_G[t[nm][ex]](p)
		r = nil
	end
	return r
end
----------------------------------------
-- 選択肢の初期化
function select_init()
	autoskip_stop(true)		-- auto/skip保存して停止
	glyph_del()				-- glyphを消す
--	eqwait{ scenario="1" }	-- テキストの表示終了を待つ
end
----------------------------------------
-- autosave
function select_autosave()
	if init.game_selectsave == "on" and conf.selsave == 0 then
		sv.autosave()
	end
end
----------------------------------------
-- 選択肢を表示する
function select_view()
	local s = scr.select
	local max  = #s
	local name = s.name

	-- mw
	local mwnm = s.mwnm
	local mwtx = s.mwtx
	if mwnm then message_name(mwnm) end
	if mwtx then
		chgmsg_adv()
		set_message_speed_tween(0)
		e:tag{"print", data=(mwtx)}
		chgmsg_adv("close")
	end

	-- 選択肢ボタン
	local c  = 0
	local t  = csv.mw.select		-- 画像情報
	local id = getMWID("select")	-- id base
	local ar = init.select_aread	-- 既読色
	local cd = init.select_condtext	-- cond text
	local ca = init.select_active	-- アクティブ文字色
	local wh = split(t.clip, ',')
	local ax = math.floor(wh[3] / 2)
	local ay = math.floor(wh[4] / 2)
	local file = game.path.ui..t.file
	for i=1, max do
		local v = scr.select[i]
		local f = v.cond and cond(v.cond) == 1 or not v.cond

--		message("通知", i, f, text, v.cond)

		if f or cd then
			local ids  = id.."."..(c+1)..".0"
			local idx  = ids..".0"
			local text = v.text
			local clip = f and t.clip or t.clip_c
			scr.select.idx[i] = idx

			-- 画像設置
			lyc2{ id=(idx..'.0'), file=(file), clip=(clip)}
			e:tag{"lyprop", id=(ids), left=(t.x)}
			e:tag{"lyprop", id=(idx), anchorx=(ax), anchory=(ay)}

			-- 選択肢に表示するメッセージの生成
			set_textfont("select", idx..".2")
			e:tag{"chgmsg", id=(idx..".2"), layered="1"}
			e:tag{"rp"}

			-- 既読色
			local gs = gscr.select
			local rd = conf.selcolor == 1 and gs and gs[name] and gs[name][i] == 1

			-- cond == 0
			if not f and cd then
				e:tag{"print", data=(cd)}
				scr.select[i].disable = true

			-- シーン中は未選択のものを書き換え
--			if eval == 0 and getExtra() then
--				e:tag{"print", data="選択されていません"}
			else
				scr.select[i].disable = nil

				-- 選択されている
				if rd and ar then
					tag{"font", color=(ar[1]), shadowcolor=(ar[2]), outlinecolor=(ar[3])}
				end
				e:tag{"print", data=(text)}
--				lyevent{ id=(idx..'.0'), no=(i), name="select", key="CLICK", click="select_click", over="select_over", out="select_out"}
				if rd then tag{"/font"} end
			end
			e:tag{"/chgmsg"}

			-- アクティブ文字色
			if ca then
				local idca = idx..".3"
				set_textfont("select", idca)
				tag{"chgmsg", id=(idca), layered="1"}
				tag{"font", color=("0"..ca)}
				tag{"rp"}
				tag{"print", data=(text)}
				tag{"/font"}
				tag{"/chgmsg"}
				tag{"lyprop", id=(idca), visible="0"}
			end
			c = c + 1
		end
	end
	scr.select.max = c

	-- bg check
	local n = "selectbg"..c
	local b = csv.mw[n]
	if b then lyc2{ id=(id..'.0'), file=(game.path.ui..b.file), clip=(b.clip), x=(b.x), y=(b.y)} end

	-- 座標
	local y = math.ceil(t.h / 2)
	local z = {
		{ 0, },						-- １個
		{ -1, 1 },					-- ２個
		{ -2, 0, 2 },				-- ３個
		{ -3, -1, 1, 3 } ,			-- ４個
		{ -4, -2, 0, 2, 4 },		-- ５個
		{ -5, -3, -1, 1, 3, 5 },	-- ６個
	}
	if z[c] then
		for i=1, c do
			e:tag{"lyprop", id=(id.."."..i), top=(t.y + y * z[c][i])}
		end
	end
	scr.select.count = c

	-- カーソル動作書き換え
	setonpush_select()

	-- アニメーション
	local a = init.select_anime
	if a then
		local seltween = {
			lt = function(idx, t, d) tween{ id=(idx), x="-50,0", time=(t), delay=(d)} end,
			rt = function(idx, t, d) tween{ id=(idx), x="50,0" , time=(t), delay=(d)} end,
			up = function(idx, t, d) tween{ id=(idx), y="50,0" , time=(t), delay=(d)} end,
			dw = function(idx, t, d) tween{ id=(idx), y="-50,0", time=(t), delay=(d)} end,
			xs = function(idx, t, d) tween{ id=(idx), xscale="0,100", time=(t), delay=(d)} end,
			ys = function(idx, t, d) tween{ id=(idx), yscale="0,100", time=(t), delay=(d)} end,

			ro = function(idx, t, d) tween{ id=(idx), rotate="360,0", time=(t), delay=(d)} end,

			zs = function(idx, t, d)
				tween{ id=(idx), xscale="200,100", time=(t), delay=(d)}
				tween{ id=(idx), yscale="0,100"  , time=(t), delay=(d)}
			end,
			ro2 = function(idx, t, d)
				tween{ id=(idx), zoom="200,100", time=(t), delay=(d)}
				tween{ id=(idx), rotate="360,0", time=(t), delay=(d)}
			end,
		}
		local time	= init.select_time  or 200
		local delay = init.select_delay or 100
		local wait	= time
		for i=1, c do
			local idx = id.."."..i..".0.0"
			local dl  = (i-1)*delay
			tween{ id=(idx), alpha="0,255" , time=(time), delay=(dl)}
			if seltween[a] then seltween[a](idx, time, dl) end
			wait = wait + delay
		end
		flip()
		eqwait(wait)
		for i=1, c do
			local idx = id.."."..i..".0.0"
			eqtag{"lytweendel", id=(idx)}
		end
	else
		uitrans()
	end
end
----------------------------------------
-- lyevent割り当て
function select_event()
	local s = scr.select
	if s then
		local c = #s
		for i=1, c do
			local idx = not s[i].disable and s.idx[i]
			if idx then lyevent{ id=(idx..'.0'), no=(i), name="select", key="CLICK", click="select_click", over="select_over", out="select_out"} end
		end
	end

	-- 入力待ち
	eqtag{"jump", file="system/script.asb", label="select"}
end
----------------------------------------
-- 
----------------------------------------
-- 選択肢終了
function select_reset()
	if scr.select then

		-- 画像消去
		local r = select_extend("reset")
		if r then select_resetimage() end
		scr.select = nil
		scr.btnfunc["select|CLICK"] = nil
		scr.p = nil
		delonpush_ui()		-- key戻し
		setMWFont(true)		-- glyph戻し
	end
end
----------------------------------------
-- 選択肢の画像を消去
function select_resetimage()
	if scr.select then
		local id  = getMWID("select")
		lydel2(id)

		-- 選択肢に表示したメッセージの消去
		local ca = init.select_active	-- アクティブ文字色
		for i=1, #scr.select do
			local idx = id.."."..i..".0.0.2"
			e:tag{"chgmsg", id=(idx)}
			e:tag{"rp"}
			e:tag{"/chgmsg"}
			if ca then
				local idx = id.."."..i..".0.0.3"
				e:tag{"chgmsg", id=(idx)}
				e:tag{"rp"}
				e:tag{"/chgmsg"}
			end
			lydel2(idx)
		end
	end
end
----------------------------------------
-- 
----------------------------------------
-- 選択肢決定
function select_click()
	local v  = scr.select
	local no = v.id
	if no and get_gamemode('adv') then
		se_select()
--		flg.btnstop = true	-- ボタン禁止
		allkeyoff()			-- 入力禁止
		autoskip_disable()	-- autoskip一旦停止

		-- 決定色がある
		local id = getMWID("select")	-- id base
		local t  = csv.mw.select		-- 画像情報
--		if t.clip_c then
--			e:tag{"lyprop", id=(v.idx[no]..".0"), clip=(t.clip_c)}
--			flip()
--		end

		-- アニメーション
		local a = init.select_anime
		if a then
			local seltween = {
				lt = function(idx, t, d) tween{ id=(idx), x="0,40", time=(t), delay=(d)} end,
				rt = function(idx, t, d) tween{ id=(idx), x="0,-40" , time=(t), delay=(d)} end,
				up = function(idx, t, d) tween{ id=(idx), y="0,-40" , time=(t), delay=(d)} end,
				dw = function(idx, t, d) tween{ id=(idx), y="0,40", time=(t), delay=(d)} end,
				xs = function(idx, t, d) tween{ id=(idx), xscale="100,0", time=(t), delay=(d)} end,
				ys = function(idx, t, d) tween{ id=(idx), yscale="100,0", time=(t), delay=(d)} end,
	
				ro = function(idx, t, d) tween{ id=(idx), rotate="0,-360", time=(t), delay=(d)} end,
	
				zs = function(idx, t, d)
					tween{ id=(idx), xscale="100,200", time=(t), delay=(d)}
					tween{ id=(idx), yscale="100,0"  , time=(t), delay=(d)}
				end,
				ro2 = function(idx, t, d)
					tween{ id=(idx), zoom="100,200", time=(t), delay=(d)}
					tween{ id=(idx), rotate="0,360", time=(t), delay=(d)}
				end,
			}
			local time	= init.select_time  or 200
			local delay = init.select_delay or 100
			local wait	= time
			local max	= #scr.select
			for i=1, max do
				if i ~= no then
					local idx = v.idx[i]
					if idx then
						local dl  = (i-1)*delay
						tween{ id=(idx), alpha="255,0", time=(time), delay=(dl)}
						if seltween[a] then seltween[a](idx, time, dl) end
						wait = wait + delay
					end
				end
			end
			flip()
			scr.select.wait = wait
		end

		-- script.asbを経由する
		btnstat(getMWID("select"))	-- キー連打を防ぐ
		eqtag{"jump", file="system/script.asb", label="select_exit"}
	end
end
----------------------------------------
-- 
function select_exittrans()
	local s = scr.select
	if s then
		local a = init.select_anime
		local w = s.wait
		local id = getMWID("select")

		-- mwを戻す
		if s.mwsys and game.pa then
			estag("init")
			estag{"eqwait", w}
			estag{"lydel", id=(id)}			-- 画像消去
			estag{"uitrans"}
			estag{"mwdock_select", true}	-- dock消去
			estag()

		-- アニメ停止
		elseif a then
			eqwait(w)
--			for i=1, max do
--				local idx = scr.select.idx[i]
--				eqtag{"lytweendel", id=(idx)}
--			end
			eqtag{"lydel", id=(id)}		-- 画像消去
			eqtag{"calllua", ["function"]="tags.uitrans"}

		-- 消去
		else
			lydel2(id)					-- 画像消去
			uitrans()
		end
	end
end
----------------------------------------
-- 事後処理
function select_clicknext()
	local v  = scr.select
	local no = v.id
	local t  = v[no]
	local tx = t.text:gsub('　', '')

	-- バックログの１画面分をクローズ
	if not v.hide then 
		set_backlog_next()
		log.stack[#log.stack].select = tx
	end

	message("通知", "『", tx, "』が選択されました", label)

	-- 選択したボタンを既読にする
	if not getExtra() and init.select_save == 'on' then
		local name = v.name
		if not gscr.select then gscr.select = {} end
		if not gscr.select[name] then gscr.select[name] = {} end
		gscr.select[name][no] = 1
		asyssave()
	end

	-- exp処理
	if t.exp then set_eval(t.exp) end

	-- 名前の消去処理
--	system_adv_textclear(e, {})

	-- 事後処理
	exselback("selsave")	-- 前の選択肢に戻る、の情報をスタック / scr.select削除前に実行
--	flg.btnstop = nil		-- ボタン許可
	select_reset()			-- バッファクリア
--	set_backlog_next()		-- バックログ格納
	scr.ip.count = nil		-- カウンタリセット
	scr.flowposition = nil	-- フローチャート位置情報削除
	clickEnd(e)				-- click終了処理を通す
	ResetStack()			-- stackを空にする

	-- mode=hideの場合はリセットしておく
	if v.hide then msg_reset() end

	-- 自動選択の場合はオートモード再開処理を実行しない
	local s = v.autoselect
	if not s then
		restart_autoskip()		-- auto/skip再開
		set_message_speed()		-- mspeed復帰
		allkeyon()				-- 入力許可
	end

	-- file/labelがある場合は飛ぶ
	if t.file or t.label then
		stack_eval()		-- 更新があったのでスタックしておく
		gotoScript{ file=(t.file), label=(t.label) }		-- スクリプトの呼び出し

	-- ない場合はフラグをセットして次の行へ
	else
		set_eval('f.s='..no)
		stack_eval()		-- 更新があったのでスタックしておく
		autocache()			-- 自動キャッシュ
		tag{"jump", file="system/script.asb", label="main"}
	end
end
----------------------------------------
-- 選択肢アクティブ
function select_over(e, p)
	if get_gamemode('adv') then
		if not p.se then se_active() end
		local no = tonumber(p.no)
		local ix = scr.select.id
		if ix and ix ~= no then select_out(e, { no=(ix) }) end

		local t	 = csv.mw.select		-- 画像情報
		local id = p.id or scr.select.idx[no]..".0"
		e:tag{"lyprop", id=(id), clip=(t.clip_a)}

		local ca = init.select_active	-- アクティブ文字色
		if ca then 		
			local idx = scr.select.idx[no]..".3"
			tag{"lyprop", id=(idx), visible="1"}
		end
		flip()
		scr.select.id = no
	end
end
----------------------------------------
-- 選択肢ノンアクティブ
function select_out(e, p)
	if get_gamemode('adv') then
		local no = tonumber(p.no)
		if scr.select.id == no then scr.select.id = nil end

		local t  = csv.mw.select		-- 画像情報
		local id = p.id or scr.select.idx[no]..".0"
		e:tag{"lyprop", id=(id), clip=(t.clip)}

		local ca = init.select_active	-- アクティブ文字色
		if ca then 		
			local idx = scr.select.idx[no]..".3"
			tag{"lyprop", id=(idx), visible="0"}
		end
		flip()
	end
end
----------------------------------------
-- 選択肢／キー操作 ↑
function select_keyup()
	local s = scr.select
	local max = #s
	local key = s.id or max

	-- 現在位置から１周する
	local c = key
	for i=1, max do
		local n = key - i
		if n < 1 then n = n + max end
		if not s[n].disable then
			c = n
			break
		end
	end

	-- カーソル移動
	if c ~= key then select_over(e, { no=(c) }) end
end
----------------------------------------
-- 選択肢／キー操作 ↓
function select_keydw()
	local s = scr.select
	local max = #s
	local key = s.id or 0

	-- 現在位置から１周する
	local c = key
	for i=1, max do
		local n = key + i
		if n > max then n = n - max end
		if not s[n].disable then
			c = n
			break
		end
	end

	-- カーソル移動
	if c ~= key then select_over(e, { no=(c) }) end
end
----------------------------------------
-- 前の選択肢に戻る
----------------------------------------
-- bselポインタを返す
function getBselPoint()
	return init.game_selback == "on" and getVariStack("bselstack")
end
----------------------------------------
-- bsel管理
function exselback(p)
	if init.game_selback == "on" then
		local bp = getBselPoint()

		-- ファイル名を直接格納
		local v  = type(p) == "table" and p or {}
		local fl = v.file
		local lb = v.label
		if fl or lb then
			message("通知", fl, lb, "を保存しました")
			addVariStack("bselstack", { file=(fl), label=(lb) })
--			flg.eval = true

		-- 選択肢決定後
		elseif p == "selsave" and bp > 0 then
			local r = pluto.persist({}, log.stack[#log.stack])
			addVariStack("bselstack", r)
--			flg.eval = true
		end
	end
end
----------------------------------------
-- 実行
function goBackSelect()
	local v = loadVariStack("bselstack")
	local m = #v
	if m > 0 then
--		local vl = tcopy(log.vari)	-- 変数stackは残す
		reset_backlog()				-- backlogを初期化しておく
		local s = v[m]
		if type(s) == "string" then
--			log.vari = vl

			-- bsel stack巻き戻し
			local ls = pluto.unpersist({}, s)
			local no = ls.bsel
			if no then delBackSelect(no) end

			-- 変数を捨てる
			local vl = ls.eval
			if vl then get_stack_eval(vl) end

			-- logに書き込んで呼び出し
			table.insert(log.stack, ls)
			quickjumpui(#log.stack, "bsel")				-- quickjump
		elseif s then
			ResetStack()			-- スタックリセット
			notification_clear()	-- 通知消去
			sv.delpoint()			-- saveflag delete
			delImageStack()			-- cache delete
			menuon()				-- menu on
			mw_time()				-- mw timeを戻す
			mwline_reset()			-- lane
			scr.tone = nil			-- tone color
			scr.zone = nil			-- 時間帯
			scr.flowposition = nil	-- フローチャート位置情報削除

			-- 選択肢
			if scr.select then
				select_reset()		-- reset
				set_message_speed()	-- mspeed復帰
			end

			local time = init.ui_fade
			estag("init")
			estag{"allsound_stop", { time=(time) } }
			estag{"adv_cls4"}			-- 文字消去
			estag{"msg_reset"}			-- mw reset
			estag{"reset_bg"}			-- 画面reset
			estag{"uitrans", time}

			estag{"adv_flagreset"}		-- advflag reset
			estag{"autoskip_init"}		-- auto/skip reset
		--	estag{"init_adv_btn"}		-- ボタン再設定
			estag{"gotoScript", v[1]}
			estag()
		else
			message("通知", "これ以上戻れません")
		end
	end
end
----------------------------------------
-- bsel stack巻き戻し
function delBackSelect(no)
	if init.game_selback == "on" and no > 0 then
		local v = loadVariStack("bselstack")
		for i=#v, no+1, -1 do table.remove(v, i) end
		saveVariStack("bselstack", v)
	end
end
----------------------------------------
-- 次の選択肢に進む
----------------------------------------
function goNextSelect()
	ResetStack()
	local time = init.ui_fade

	autoskip_ctrl()					-- ctrl無効化
	delImageStack()					-- cache開放
	systemsound("selsave", time)	-- sound保存

	-- 全音停止
	estag("init")
	estag{"allsound_stop", { time=(time) } }
	estag{"notification_clear"}		-- 通知消去
	estag{"adv_cls4"}				-- テキスト消去

	-- 共通消去
	estag{"uimask_on"}				-- 画像は消さずにmaskで隠す
	estag{"uitrans", time}
	estag{"wait", time="20", input="0"}
	estag{"system_se_stop", { time="0" }}	-- sysseを止めておく
	estag{"goNextSelectLoop"}
	estag()
end
----------------------------------------
-- debugSkip版
function goNextSelectLoop(flag)
	scr.face = nil	-- mwfaceのテーブルが残っていると停止時にエラーが出るので削除
	flg.exskip = true
	e:debugSkip{ index=99999 }
end
----------------------------------------
-- table loop版
function goNextSelectLoopOld(flag)
	local m = #ast
	local f = nil
	local p = nil
	scr.face = nil	-- mwfaceのテーブルが残っていると停止時にエラーが出るので削除

	----------------------------------------
	-- tag
	local sw = {
		-- 抜ける
		select		= function() return "stop" end,
		movie		= function() return "stop" end,
		staffroll	= function() return "stop" end,
		stop		= function() return "stop" end,
		skipstop	= function() return "stop" end,

		-- ゲーム終端
		gotitle		= function(z) p=z return "exit" end,
		["タイトル"]= function(z) p=z return "exit" end,

		-- 次のファイルを読み込む
		excall		= function(v) goNextSelectFile(v)  return "file" end,
		exreturn	= function(v) goNextSelectReturn() return "file" end,

		-- タグ実行
		eval		= function(v) tags[v[1]](e, v) end,
		title		= function(v) tags[v[1]](e, v) end,
		sceneend	= function(v) sceneEnd(v) end,			-- scene登録

		-- ev登録
		bg = function(v)
			storeQJumpStack("bg", v)
			if v.set then evset(v) end
		end,
	}

	----------------------------------------
	-- loop
	local ipct = flg.ipcount
	flg.ipcount = nil
	if not flag then
		scr.ip.block = scr.ip.block + 1		-- 次のblockから読み始める
	end

	----------------------------------------
	-- block
	repeat
		local b  = scr.ip.block			-- block
		local v  = ast[b]
		local mc = #v
		scr.ip.count = ipct or 1
		ipct = nil

		----------------------------------------
		-- 既読判定
		local ar = getAread()
		if not ar and conf.messkip == 0 and ast.text[b] then
			local tbl = { select=1, movie=1, staffroll=1, stop=1, skipstop=1, gotitle=1, ["タイトル"]=1, }
			local z = 0
			local m = #v
			local c = scr.ip.count

			-- 停止タグを最大値にする
			for i=c, m do
				local nm = v[i][1]
				if tbl[nm] then z = i break
				elseif nm == "bg" or nm == "extrans" then z = i end
			end

			-- 現在位置から停止タグまでを処理
			if z > 0 then
				for i=c, z do
					scr.ip.count = i
					local v  = ast[b][i]
					local nm = v[1]
					if tags[nm] then
						if not v.cond or cond(v.cond) == 1 then
							if sw[nm] then f = sw[nm](v)
							else storeQJumpStack(nm, v) end
							if f then break end
						end
					end
				end
			else
				scr.ip.count = c
			end

			-- fileは通過
			if not f then f = "aread" end
			break
		end

		----------------------------------------
		-- block内
		if not f then
			repeat
				local c  = scr.ip.count		-- block count
				local v  = ast[b][c]
				local nm = v[1]

				-- タグ登録
				if tags[nm] then
					if not v.cond or cond(v.cond) == 1 then
						if sw[nm] then f = sw[nm](v)
						else storeQJumpStack(nm, v) end
					end
				end
				if f then break end
				scr.ip.count = c + 1
			until not ast[b][c+1]

			----------------------------------------
			-- delay
			scr.ip.count = nil		-- カウンタリセット
			local d = not f and ast[b].delay
			if not fl and d then
				for k, v in pairs(d) do
					for j, z in ipairs(v) do
						local nm = z[1]
						if sw[nm] then sw[nm](z)
						else storeQJumpStack(nm, z, k) end
					end
					if f then break end
				end
			end

			stack_eval()			-- 変数の更新があればスタックに登録
			if f then break end
			set_backlog_next()		-- バックログ格納
			setAread()				-- 既読設定
			scr.ip.block = b + 1
		end
	until not ast[b+1]

	----------------------------------------
	-- 終端まで到達
	if not f then
		estag("init")
		estag{"tag_dialog", { message="終端に到達しました" }}
		estag{"call", file="system/ui.asb", label="go_title"}
		estag()

	-- タイトルに戻る
	elseif f == "exit" then
		tags.gotitle(e, p)

	-- 画面再開
	elseif f == "stop" or f == "aread" then
		ResetStack()			-- stackを空にする

		-- バックログの１画面分をクローズ
		set_backlog_next()
--		log.stack[#log.stack].select = tx
		local nm = f == "stop" and "bsel" or "nsel"
		quickjump(#log.stack, nm)

	-- 次のファイルへ
	elseif f == "file" then

	else
message("end", f)
	end
end
----------------------------------------
-- file読み込み
function goNextSelectFile(p)
	local fl = p.file or scr.ip.file
	local lb = p.label
	readScript(fl, lb)

	-- count保存
	flg.ipcount = scr.ip.count

	estag("init")
	estag{"eqwait"}
	estag{"goNextSelectLoop", true}
	estag()
	return 1
end
----------------------------------------
-- call→return
function goNextSelectReturn()

	message("通知", "return実行")

	return 1
end
----------------------------------------
