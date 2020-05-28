----------------------------------------
-- クイックジャンプ制御
----------------------------------------
function quickjump(no, flag)
	local p = log.stack[no]
	local file = p.file		-- script file
	local blj  = p.blj		-- backlog jump
	local chk  = flag == true and nil or true
	scr.blj = blj

	----------------------------------------
	-- 画面初期化
	if chk then
		adv_cls4()			-- テキスト消去
		allsound_stop{ time=0 }
--		reset_voice()

		----------------------------------------
		-- 変数を巻き戻す
		local vl = p.eval
		if vl then
			get_stack_eval(vl)
		else
			-- データが無いので念のためリセット
			log.vari = {}
			scr.vari = {}
		end

		----------------------------------------
		-- bselを巻き戻す
		local vl = p.bsel
		if vl then
			delBackSelect(vl)
		end
	end
	reset_bg()
	sv.delpoint()			-- saveflag delete
	delImageStack()			-- cache delete
	menuon()				-- menu on
	mw_time()				-- mw timeを戻す
	mwline_reset()			-- lane
	scr.tone = nil			-- tone color
	scr.zone = nil			-- 時間帯
	scr.flowposition = nil	-- フローチャート位置情報削除
	scr.ese = nil			-- 再生済みese
	-- 選択肢
	if scr.select then
		select_reset()		-- reset
		set_message_speed()	-- mspeed復帰
	end

	----------------------------------------
	-- 現在読み込まれてるscript fileと違うのであれば読み直す
	local sf = scr.ip.file
	local checkscript = function(nm, p, flag)
		local r = nil
		local file = p and p[1]
		if file and sf ~= file then
			local r = readScriptFile(file)
			if not r then
				error_message(file.."の読み込みに失敗しました")
				readScriptFile(s)
				file = sf
			end
			sf = file
		end

		-- astを返す
		if p and nm ~= 'load'then
			-- ast一致
			if ast[p[2]] then
				local sn = p[4]
				if sn then
					r = tcopy(ast[p[2]].delay[sn][p[3]])
				else
					r = tcopy(ast[p[2]][p[3]])
				end

				-- ファイル内だけでも検索する / パッチでも使うはず
				if r[1] ~= nm then
					if nm ~= "ese" then	error_message(nm.."がみつかりませんでした") end
					r = nil
				end

			else
				error_message(nm.."がみつかりませんでした")
			end
		end
		return r
	end

	----------------------------------------
	-- 実行順番
	local tbl = { "tone", "timezone", "bg", "fgf", "fg", "bgm","mbgm","chmbgm","mbgmstop", "se","ese", "vol","lvo", "ex", "menuoff", "autoplay", "mw", "savetitle" }
	local mwnm = "bg01"

	-- noの情報を取得して描き直す
	flg.blj = true
	for i, nm in ipairs(tbl) do
		local p  = blj[nm]
		local sw = {}

		----------------------------------------
		-- 色調
		sw.tone = function(p)
			local a = checkscript('colortone', p)
			colortone(a)
		end

		----------------------------------------
		-- 時間帯
		sw.timezone = function(p)
			local a = checkscript('timezone', p)
			timezone(a)
		end

		----------------------------------------
		-- bg
		sw.bg = function(p)
			for id, t in pairs(p) do
				local a = checkscript('bg', t)
				if a then
					a.x2=nil a.y2=nil a.z2=nil a.notrans=nil
					image_view(a, true)
				end
			end
		end

		----------------------------------------
		-- fg
		sw.fg = function(p)
			for id, t in pairs(p) do
				local a = checkscript('fg', t)
				if a then
					local m = a.mode
					if m >= 2 then
						a.disp=nil a.mx=nil a.my=nil a.x2=nil a.y2=nil a.z2=nil
						fg(a)
					end

					-- face
					if m == 1 or m == 3 then
						local ch = a.ch
						if ch then
							if not scr.face then scr.face = {} end
							scr.face[ch] = a
						end
					end
				end
			end
		end

		----------------------------------------
		-- fgf
		sw.fgf = function(p)
			for id, t in pairs(p) do
				local a = checkscript('fgf', t)
				if a then
					a.disp = nil
					fgf(a)
				end
			end
		end

		----------------------------------------
		-- bgm
		sw.bgm = function(p)
			
			local a = checkscript('bgm', p)
			if a then bgm(a) end
		end

		----------------------------------------
		-- mbgm
		sw.mbgm = function(p)
			local a = checkscript('mbgm', p)
			if a then mbgm(a) end
		end

		sw.chmbgm = function(p)
			local a = checkscript('chmbgm', p)
			if a then mbgm_change(a) end
		end

		sw.mbgmstop = function(p)
			local a = checkscript('mbgmstop', p)
			if a then mbgm_stop(a) end
		end


		----------------------------------------
		-- se
		sw.se = function(p)
			for id, t in pairs(p) do
				local a = checkscript('se', t)
				if a then se(a) end
			end
		end
		----------------------------------------
		-- ese
		sw.ese = function(p)
			local a = checkscript('ese', p)
			if a then ese(a) end
		end

		----------------------------------------
		-- vol
		sw.vol = function(p)
			for id, t in pairs(p) do
				local a = checkscript('vol', t)
				if a then media_volume(a) end
			end
		end

		----------------------------------------
		-- lvo
		sw.lvo = function(p)
			for id, t in pairs(p) do
				local a = checkscript('lvo', t)
				if a then lvo(a) end
			end
		end

		----------------------------------------
		-- mw
		sw.mw = function(p)
			local a = checkscript('mw', p)
			mwnm = 'bg0'..(a.no or 1)
		end

		----------------------------------------
		-- menuoff
		sw.menuoff = function(p)
			menuoff()
		end

		----------------------------------------
		-- autoplay
		sw.autoplay = function(p)
			local a = checkscript('autoplay', p)
			tags.autoplay(e, a)
		end

		----------------------------------------
		-- title
		sw.savetitle = function(p)
			local a = checkscript('savetitle', p)
			if a then tags.savetitle(e, a) end
		end

		----------------------------------------
		-- 呼び出し
		if p and sw[nm] then sw[nm](p) else

			if p then message(nm) end

		end
	end
	flg.blj = nil

	----------------------------------------
	-- mwを戻す
--	setMWImage(mwnm)
	setMWFont()

	----------------------------------------
	if chk then
		-- ファイルを読み直す
		checkscript('load', file)
		scr.ip.file = file
		local block = p.block
		local count = 1

		----------------------------------------
		-- call stackを巻き戻す
		local gss = p.gss			-- gamescript stack
		if gss and init.game_stack == 'on' then
			local max = #gss
			if max > 0 then
				local g = gss[max]
				scr.gss = tcopy(gss)
			end
		else
			-- データが無いので念のためリセット
			scr.gss = {}
		end

		----------------------------------------
		-- log dataを現在位置へ
		local n = no + 0
		local m = #log.stack
		for i=n, m do
			table.remove(log.stack, n)
		end

		----------------------------------------
		-- 移動準備
		local r = readScriptFile(file)	-- 読み直しておく
		local block = block				-- script block
		local count = count				-- script count
		local t = ast[block]

		-- bsel / 前の選択肢に戻る
		if flag == "bsel" then
			for i, v in ipairs(t) do
				if v[1] == "select" then
					count = i
					break
				end
			end

		-- nsel / 次の選択肢へ進む
		elseif flag == "nsel" then
			flag = "ui"
			count = scr.ip.count or 1

		-- その他
		else
			local com = { sm=1, text=1, fgact=1 }
			for i, v in ipairs(t) do
				local a = v[1]
				if com[a] then
					count = i
					break
				end
			end
		end

		-- mw reset
		msg_reset()

		-- 移動する
		scr.tagstack = nil
		scr.ip.block = block
		scr.ip.count = count or 1
		scr.ip.textcount = nil
		autocache(true)				-- 自動キャッシュ
		if flag == "ui" or flag == "bsel" then
			scr.uifunc = nil
			flg.ui = nil
			e:tag{"jump", file="system/script.asb", label="main_blj"}

		-- zapping
		elseif flag == "zap" then
			e:tag{"jump", file="system/script.asb", label="main_zap"}
		else
			e:tag{"jump", file="system/script.asb", label="main"}
		end
	end
end
----------------------------------------
-- 暗転を挟む
function quickjumpui(no, name)
	flg.qjno = no
	local time = init.ui_fade

	-- 全音停止
	estag("init")
	estag{"allsound_stop", { time=(time) } }
--	allsound_stop{ time=(time) }

	-- uiから来た
	if name == "blog" then
		uicloseanime(time, "small")
--		blog_reset()
		estag{"blog_reset"}
	else
--		notification_clear()	-- 通知消去
--		adv_cls4()				-- テキスト消去
--		msg_hide()
		estag{"notification_clear"}
		estag{"adv_cls4"}
		estag{"msg_hide"}
	end

	-- mask
--	uimask_on()
	estag{"uimask_on"}

	-- 共通消去
	local nm = name == "bsel" and name or "ui"
	estag{"reset_bg"}
	estag{"uitrans", time}
	estag{"quickjumpui2", { no, nm }}
	estag()
end
----------------------------------------
function quickjumpui2(p)
	ResetStack()	-- スタックリセット
	quickjump(p[1], p[2])
end
----------------------------------------
-- msgshow
function quickjumpmsg()
	local block = scr.ip.block

	-- mw処理 / lane
	msg_reset()
	local z = ast.text[block] or {}

	-- hide
	if z.hide then
		msgcheck("off")

	-- [line]
	elseif z.lane then
		scr.mw.msg = true
		msgcheck("sys")

	-- 
	elseif scr.adv.menu then
		scr.mw.msg = true
		msgcheck("on")
	end

	-- 有効化
	init_adv_btn()
	autoskip_init()
end
----------------------------------------
-- 実行情報
----------------------------------------
-- タグ実行時に情報を格納する
function storeQJumpStack(nm, p, dl)
	-- フラグがonであれば保存しておく
	if init.game_quickjump ~= 'on' then return end

	local sw = {}
	----------------------------------------
	-- 呼ばれたら現在位置を返す
	local getBlock = function(v)
		local d = v	-- and 'delay'
		local f = scr.ip.file
		local b = scr.ip.block
		local c = scr.ip.count or 1
		return { f, b, c, d }
	end
	----------------------------------------

	----------------------------------------
	-- 背景
	sw.bg = function(p)
		local id = (p.id or 0) + 1
		stackBLJ('bg', getBlock(dl), id)
		if id == 1 then
			stackBLJ('fg', nil)

			-- 背景以外全削除する
			if scr.blj.bg then
				for i, v in pairs(scr.blj.bg) do
					if i ~= 1 then stackBLJ('bg', nil, i) end
				end
			end
		end
	end

	----------------------------------------
	-- cgdel
	sw.cgdel = function(p)
		local id = (p.id or 0) + 1
		if id == 0 and scr.blj.bg then
			-- 背景以外全削除する
			for i, v in pairs(scr.blj.bg) do
				if i ~= 1 then stackBLJ('bg', nil, i) end
			end
		else
			stackBLJ('bg', nil, id)
		end
	end

	----------------------------------------
	-- 立ち絵
	sw.fg = function(p)
		local id = tn(p.id or 1)
		local md = tn(p.mode)
			if md == -2 then stackBLJ('fg', nil)
		elseif md == -1 then stackBLJ('fg', nil, id)
		else				 stackBLJ('fg', getBlock(dl), id) end
	end

	----------------------------------------
	-- fgframe
	sw.fgf = function(p)
		local fr = p.frame
		local md = tn(p.mode)
		if md == -1 then
			stackBLJ('fgf', nil, fr)

			-- 同時に立ち絵も消す
			local ch = scr.img.fgf and scr.img.fgf[fr] and scr.img.fgf[fr].ch
			if ch then
				local id = scr.img.fgf[ch].fgid
				if id then
					stackBLJ('fg', nil, id)
				end
			end
		else
			stackBLJ('fgf', getBlock(dl), fr)
		end
	end

	----------------------------------------
	-- 色調
	sw.colortone = function(p)
		local r = p.mode == 'reset'
		if r then stackBLJ('tone', nil)
		else	  stackBLJ('tone', getBlock(dl)) end
	end

	----------------------------------------
	-- 時間帯
	sw.timezone = function(p)
		local r = p.mode == 'reset'
		if r then stackBLJ('timezone', nil)
		else	  stackBLJ('timezone', getBlock(dl)) end
	end

	----------------------------------------
	-- mw
	sw.mw = function(p)
		local no = p.no
		if no == 1 then stackBLJ('mw', nil)
		else			stackBLJ('mw', getBlock(dl)) end
	end

	----------------------------------------
	-- media
	----------------------------------------
	sw.bgm = function(p)
		local st = tn(p.stop)
		stackBLJ('mbgm',nil)
		stackBLJ('chmbgm',nil)
		if st == 1 then stackBLJ('bgm', nil)
		else			stackBLJ('bgm', getBlock(dl)) end
		stackBLJ('vol', nil, "bgm")

	end
	----------------------------------------
	sw.mbgm = function(p)
		stackBLJ('bgm', nil)
		stackBLJ('mbgm', getBlock(dl))
		stackBLJ('vol', nil, "mbgm")
	end

	sw.chmbgm = function(p)
		local trg = p.rane or 1
		stackBLJ('chmbgm', getBlock(dl))
	end

	sw.mbgmstop = function(p)
		stackBLJ('mbgm',nil)
		stackBLJ('chmbgm',nil)
		stackBLJ('mbgmstop', getBlock(dl))
	end
	----------------------------------------
	sw.se = function(p)
		local id = tn(p.id or 1)
		local st = tn(p.stop)
		local lp = tn(p.loop)
		if st == 1 then
			-- 全停止
			if id == -1 then
				stackBLJ('se', nil)
				for i=0, init.se_limit do stackBLJ('vol', nil, i) end
			else
				stackBLJ('se', nil, id)
				stackBLJ('vol', nil, id)
			end

		-- loopseは保存する
		elseif lp == 1 then
			stackBLJ('se', getBlock(dl), id)

		-- 単発seは保存しない / loopseを同IDで上書きしている可能性があるので消す
		else
			stackBLJ('se', nil, id)
			stackBLJ('vol', nil, id)
		end
	end
	----------------------------------------
	sw.ese = function(p)
		local id = tn(p.id or 1)
		local st = tn(p.stop)
		local lp = tn(p.loop)
		stackBLJ('ese', getBlock(dl))
	end
	----------------------------------------
	sw.vol = function(p)
		local id = p.id or 1
		stackBLJ('vol', getBlock(dl), id)
	end

	----------------------------------------
	sw.vo = function(p)
--	dump(p)
	end

	----------------------------------------
	sw.vostop = function(p)
		local ch = p.ch
		if ch then
			stackBLJ('lvo', nil, ch)	-- lvo停止
		else
			stackBLJ('lvo', nil)		-- lvo全停止
		end
	end

	----------------------------------------
	sw.lvo = function(p)
		local ch = p.ch
		if p.stop == 1 then	stackBLJ('lvo', nil, ch)
		else				stackBLJ('lvo', getBlock(dl), ch) end
	end

	----------------------------------------
	-- 演出
	----------------------------------------
	-- quake
	sw.quake = function(p)
--	dump(p)
	end

	-- savetitle
	sw.savetitle = function(p)
		stackBLJ('savetitle', getBlock(dl))
	end

	-- menuon
	sw.menuon = function(p)
		stackBLJ('menuoff', nil)
	end

	-- menuoff
	sw.menuoff = function(p)
		stackBLJ('menuoff', getBlock(dl))
	end

	-- autoplay
	sw.autoplay = function(p)
		local md = p.mode
		if md == "stop" then
			stackBLJ('autoplay', nil)
		else
			stackBLJ('autoplay', getBlock(dl))
		end
	end

	----------------------------------------
	if sw[nm] then sw[nm](p)

	elseif nm ~= 'text' then

--	message("script", nm)

	end
end
----------------------------------------
-- bljにデータを積んでいく
function stackBLJ(nm, p, id)
	if not scr.blj then scr.blj = {} end	-- この変数はリセットしない

	-- 格納する
	if id then
		if not scr.blj[nm] then scr.blj[nm] = {} end
		scr.blj[nm][id] = p
	else
		scr.blj[nm] = p
	end
end
----------------------------------------
-- bljの実行情報を取得する／バックログ
function getQJumpStack()
	local r
	if init.game_quickjump == 'on' then
		r = tcopy2(scr.blj)	-- BackLogJump管理テーブル
	end
	return r
end
----------------------------------------
