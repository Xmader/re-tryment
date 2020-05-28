----------------------------------------
-- ■ シーンバック(簡易版)
----------------------------------------
-- 初期化
function sbck_init()
	-- 最初の１行目は何もしない
	local max  = table.maxn(log.stack)
	if max <= 1 then
		message("通知", "シーンデータがありませんでした")
	else
		message("通知", "シーンバックを開きました")
--		se_ok()
		voice_stopallex(0)		-- 一旦全停止

		-- 初期化
		local file = scr.ip.file
		flg.sback = { max=(max), line=(max-1), file=(file), back=(file), cache={} }

		-- 画面
		flg.ui = {}
		csvbtn3("sbck", "500", csv.ui_sback)
		sback_view()

		-- glyph
		glyph_del()
		flip()
	end
end
----------------------------------------
-- 
function sbck_reset()
	delbtn('sbck')
	init_adv_btn()
	autoskip_init()

	-- glyph
--	e:tag{"lyprop", id=(getMWID("glyph")), visible="1"}
--	if scr.mwface then e:tag{"lyprop", id=(getMWID("face")) , visible="1"} end
	flip()

	flg.sback = nil
	flg.ui = nil
end
----------------------------------------
-- シーンバックを抜ける
function sbck_close()
	message("通知", "シーンバックを閉じました")
	voice_stopall()	 		-- 音声全停止
	se_cancel()

	-- 戻す
	flg.sback.line = flg.sback.max
	sback_view(true)
	if flg.sback.back ~= scr.ip.file then readScriptFile(scr.ip.back) end
	if flg.sback.preview then
--		local v = log.stack[flg.sback.max]
--		if v then quickjump(v, "sback") end
		quickjump(flg.sback.max, "sback")
	end

	sbck_reset()
end
----------------------------------------
-- 
function sback_up(e, p)
	local line = flg.sback.line - 1
	if line > 0 then
		se_active()
		flg.sback.line = line
		sback_view()
	end
end
----------------------------------------
-- 
function sback_dw(e, p)
	local line = flg.sback.line + 1
	local max  = flg.sback.max
	if line == max then
		sbck_close()
	elseif line < max then
		se_active()
		flg.sback.line = line
		sback_view()
	end
end
----------------------------------------
-- 現在の位置にジャンプ
function sback_click(e, p)
	local no = flg.sback.line
	ReturnStack()			-- 空のスタックを削除
	voice_stopall()	 		-- 音声全停止
	sback_view("jump")		-- 再描画
	sbck_reset()			-- リセット

	-- 移動
--	local v  = tcopy2(log.stack[no])
--	quickjump(v)
	quickjump(no)
end
----------------------------------------
-- voice
function sback_voice(e, p)
	local v = flg.sback.voice
	if v and v.voice then
		voice_replay(v)
	end
end
----------------------------------------
-- 
----------------------------------------
-- 現在行のテキストを表示する
function sback_view(flag)
	local no = flg.sback.line
	local v  = log.stack[no]
	local fl = v.file
	local bl = v.block

	----------------------------------------
	-- データ生成
	local t = { name={}, text={} }
	if not flg.sback.cache[no] then
		if flg.sback.file ~= fl then
			flg.sback.file = fl
			readScriptFile(fl)
		end

		-- cacheに格納
		local a = ast.text[bl]
		t.name = tcopy2(a.name)
		t.text = tcopy2(a)
		flg.sback.cache[no] = t
	else
		-- cacheから読み出す
		t = flg.sback.cache[no]
	end

	----------------------------------------
	-- 表示
	local co = not flag and '0'..init.sceneback_color
	local nm = ""
	flg.sback.voice = nil
	if t.name then
		nm = t.name.text or t.name.name
		flg.sback.voice = t.name
	end
	message_name(nm)

	tag{"chgmsg", id=(game.mwid..".mw.adv")}
	tag{"rp"}
	if co then tag{"font", color=(co)} end
	message_adv(t.text[1])
	if co then tag{"/font"} end
	tag{"/chgmsg"}

	----------------------------------------
	-- delay
	if flag == 'jump' then
--		local v = log.stack[no]
--		quickjump(v, "sback")
		quickjump(no, "sback")
	elseif not flag then
		tween{ id=(getBtnID('delay')), alpha="0,1", time=(init.sceneback_time), handler="calllua", ["function"]="sback_delay", no=(no)}
	end
	flip()
end
----------------------------------------
-- 画面を書き換える
function sback_delay(e, p)
	local no = tn(p.no)
	local line = flg.sback.line
	if no == line then
		e:tag{"lytweendel", id=(getBtnID('delay'))}

		-- blj
--		local v = log.stack[no]
--		if v then quickjump(v, "sback") flip() end
		quickjump(no, "sback")
		flip()
		flg.sback.preview = true
	end
end
----------------------------------------
