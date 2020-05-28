----------------------------------------
-- スクリプト管理
----------------------------------------
-- スクリプトを読み込む / reset
function readScriptStart(file, label, p)
	flg = nil
	scr = nil
	vartable_init()
	allkeyon()

	-- 初期値を埋め込む
	if p then
		for k, v in pairs(p) do scr[k] = v end
	end

	readScript(file, label)
	adv_reset()
	reset_backlog()
	checkAread()		-- ファイル先頭の既読処理
	autocache(true)		-- 自動キャッシュ
	e:tag{"jump", file="system/script.asb", label="main"}
end
----------------------------------------
-- スクリプトを読み込む
function readScript(file, label)
	local r = readScriptFile(file)
	if not ast then
		return
	elseif ast and not r and scr.ip and scr.ip.file then
		file = scr.ip.file
	end

	-- 保存しておく
	scr.ip = {
		file  = file,	-- 実行中のファイル
		block = 1,		-- 実行中のブロック
		count = 1,		-- 実行中の行
	}

	-- labelがあればラベル行をセット
	local l = label and ast.label and ast.label[label]
	if l then
		scr.ip.block = l.block
		scr.ip.count = l.label
	end
	scr.areadflag = "reset"		-- 既読リセット

	message("通知", scr.ip.file, "(", label, ")", "を呼び出します")

	-- 初期化
	adv_init()
--	pushGSS()
end
----------------------------------------
-- スクリプトファイルの読み込みだけを行う／ast[]に格納される
function readScriptFile(file, flag)
	ast = nil
	local ret = nil
	local fo  = init.script_format
	local fl  = file
	if tn(fl) and fo then fl = string.format(fo, fl) end
	local path = init.script_path..fl..init.script_ext
	if e:isFileExists(path) then
		if not flag then delImageStack() end	-- cache delete
		e:include(path)							-- script include
		ret = true
	else
		message("エラー", file, "が見つかりませんでした")
	end
	return ret
end
----------------------------------------
-- goto処理
function gotoScript(p)
	local file	= p.file or scr.ip.file
	local label	= p.label
	readScript(file, label)
	if ast then
		checkAread()		-- ファイル先頭の既読処理
		autocache(true)		-- 自動キャッシュ
		e:tag{"jump", file="system/script.asb", label="main"}
	else
		tag{"var", name="t.error", data=(file.."は無効なファイルです")}
		tag{"call", file="system/script.asb", label="error"}
	end
end
----------------------------------------
-- jumpex
function tags.jumpex(e, p)
	local o = game.os
	local r = nil
	if (p.mode == "not" and o ~= p.os) or (p.mode == "not" and o ~= p.os) then r = true end

	message("分岐", o, p.mode, p.os, r)

	if r then
		gotoScript{ file=(scr.ip.file), label=(p.label) }
	end
end
----------------------------------------
-- XMJP
function tags.XMJP(e, p)
	if type(extra) == "string" then
		gotoScript{ file=(scr.ip.file), label=(p.label) }
	end
end
----------------------------------------
-- uiからスクリプトを呼ぶ
function callscript(mode, file, label)
	readScript(file, label)
	if ast then
		if mode == "adv" then
			adv_reset()
			reset_backlog()
			init_adv_btn()
		end
		tag{"jump", file="system/script.asb", label="main"}
	end
end
----------------------------------------
-- 
----------------------------------------
-- load解析
function scriptLoad(ip, f)
	readScriptFile(ip.file)
--[[
	-- autosave / log check
	local bl = #log.stack
	if bl == 0 or scr.autosave then return end

	-- 最新のデータと比較する
	local s = scr.ip.save		-- セーブ時のデータ
	local v = get_backlog()		-- ipが指すblock
	local text  = get_backlogtext(v.text)
	local name  = v.name and (v.name.text or v.name.name)
	local voice = v.name and  v.name.voice
	local save_name  = s.name and (s.name.text or s.name.name)
	local save_voice = s.name and  s.name.voice
	local save_text  = s.text

	-- ボイス一致
	if voice == save_voice then
--		message("voice ok")

	-- テキスト一致
	elseif text == save_text then
--		message("text ok")

	-- 一致しないので前後を検索
	else
		local bl  = ip.block
		local max = table.maxn(ast)

		-- block位置取得
		local check = function(c, vo, tx)
			local ret = nil
			local v = ast[c]
			local n = get_backlogname(v)
			local s = get_backlogtextblock(v)

			-- 音声ファイルチェック
			if n and n.voice and save_voice == n.voice then
				message("通知", "音声が一致したのでブロックを移動します", c)
				scr.ip.block = c
				ret = true

			-- テキスト一致チェック
			elseif s and s == save_text then
				message("通知", "テキストが一致したのでブロックを移動します", c)
				scr.ip.block = c
				ret = true
			end
			return ret
		end

		-- loopして取り出していく
		for i=1, max do
			-- 前を確認していく
			local c = bl - i
			if c >= 1 then
				if check(c, save_voice, save_text) then break end
			end

			-- 後ろを確認していく
			local c = bl + i
			if c <= max then
				if check(c, save_voice, save_text) then break end
			end
		end
	end
]]
end
----------------------------------------
-- 
----------------------------------------
-- メインループ
function scriptMainloop()
	local b = scr.ip.block			-- block
	local c = scr.ip.count or 1		-- block count
	local v = ast[b] and ast[b][c]

	-- 終端到達
	if not v then
		exreturn()

	-- テキストブロック
	elseif not v[1] and v.text then
--		msgon()
--		scr.text = v.text
--		e:enqueueTag{"calllua", ["function"]="scriptMainloopText"}
		
	-- tag実行
	elseif tags[v[1]] then
		if not v.cond or cond(v.cond) == 1 then
			storeQJumpStack(v[1], v)
			tags[v[1]](e, v)
		end
	else
		e:tag(v)
	end
end
----------------------------------------
-- メインループ／text表示
function scriptMainloopText()
--	chgmsg_adv()
--	message_adv(scr.text)
--	scr.text = nil
end
----------------------------------------
-- メインループ／加算
function scriptMainAdd()
	local b = scr.ip.block			-- block
	local c = scr.ip.count or 1		-- block count
	local m = table.maxn(ast[b])
	c = c + 1
	if c <= m then
		scr.ip.count = c
	else
		stack_eval()		-- 更新があったのでスタックしておく
		set_backlog_next()	-- バックログ格納
		checkAread()		-- 既読
		scr.ip.count = nil	-- カウンタリセット

		-- クリック待ち
		e:tag{"jump", file="system/script.asb", label="click"}
	end
end
----------------------------------------
-- クリック処理
----------------------------------------
-- クリック待ち開始前の処理
function clickPrepare(e, p)
	--setCaption()			-- debug情報
--	autoskip_keystop()
--	flip()
--	eqwait()

	-- 画像処理
	if scr.img.buff then image_loop() end

	-- exskip
	if flg.exskip then
		-- 未読停止
		if not scr.areadflag and conf.messkip == 0 then
			exskip_stop("cache")
		end
		e:tag{"wait", time="0", input="0"}
	end
end
----------------------------------------
-- クリック待ち開始
function clickStart(e, p)
	delay_check()		-- delay
	flg.click = true	-- click flag
end
----------------------------------------
-- delay skip
function delayStop()
	local key = flg.delaykey
	if key then
		delay_skipstop()		-- delayskip終了
		flip()

		-- クリック以外のキー
		if key[2] ~= "CLICK" then
			flg.exclick = key[1]

		-- ボタンがクリックされた
		elseif key[1] == 1 and key[3] then
			flg.btnclick = 1
			flg.exclick = 1
		end
		flg.delaykey = nil
	end
end
----------------------------------------
-- クリック直前
function clickAutomode()
	-- automode
--	if flg.automode and conf.autostop == 1 then e:enqueueTag{"automode", syncse=(scr.voice.id)} end
	if flg.automode then
		if conf.autostop == 1 then
--			eqwait{ se=(scr.voice.id) }
			eqtag{"automode", syncse=(scr.voice.id)}
		end
--		eqwait{ scenario="1" }

	-- skip speed
	elseif flg.skipmode then
		local s = conf.skipspd
		if s then
			local tm = s * 2
			if tm > 0 then
				e:tag{"wait", time=(tm), input="0"}
			end
		end
	end
end
----------------------------------------
-- クリック直後の処理
function clickEnd(e, p)
	flg.click = nil
	flg.automodeclick = nil
	flg.cgtweendel = nil	-- CG tween停止の管理フラグ
	scr.ip.textcount = nil	-- text counter
	scr.vo = nil			-- voice del
	mw_facedel()			-- face del
	adv_cls4()				-- cls
--	chgmsg_adv("close")		-- /adv
--	delay_skipstop()		-- delayskip終了
	flg.delaykey = nil
	e:tag{"lydel", id="cache"}
	flip()

	-- クリックで音声停止
	if flg.automode then e:tag{"automode", syncse=""}
	elseif conf.voiceskip == 1 then voice_stopall(nil, true) end
	scr.voice.stack = {}	-- voiceバッファクリア

	-- 既読
	setAread()
	scr.ip.block = scr.ip.block + 1		-- ブロック加算
	checkAread()

	-- automode
--	if flg.automode then e:tag{"automode", syncse=""} end
end
----------------------------------------
-- 既読処理
----------------------------------------
-- 現在の既読情報を確認
function checkAread()
	local ar = getAread()	-- 既読
	if ar ~= scr.areadflag then
		-- 既読マーク
		local a = ar and 255 or 0
		local id = getMWID("read")
		if id then e:tag{"lyprop", id=(id), visible=(a)} end
--		flip()
	end
	scr.areadflag = ar
end
----------------------------------------
-- 現在の既読情報を取得
function getAread()
	local ret = nil
	local p = scr.ip
	if p and gscr.aread[p.file] then
		local no = p.block
		for i, v in ipairs(gscr.aread[p.file]) do
			if v[1] <= no and no <= v[2] then ret = true break end
		end
	end
	return ret
end
----------------------------------------
-- 既読セット
function setAread()
	local p = scr.ip
	if p then
		local file = p.file
		local no   = p.block
		local flag = true
		if not gscr.aread[file] then gscr.aread[file] = {{ no, no }} flag = nil end
		for i, p in ipairs(gscr.aread[file]) do
			local n = p[2]

			-- 既に範囲内なら何もしない
			if p[1] <= no and no <= n then
				flag = nil
				break

			-- 範囲の１個次なら保存する
			elseif n + 1 == no then
				gscr.aread[file][i][2] = no
				flag = nil
				break
			end
		end

		-- 番号が飛んだらテーブルを追加する
		if flag then
			table.insert(gscr.aread[file], { no, no })
		end
	end
end
----------------------------------------
-- シーン処理
----------------------------------------
-- tweet
function ex_tweetset(p)
	local mode = tn(p.mode)
	if mode == 1 then
		message("通知", "ツイート禁止")
		scr.ero = true
	else
		message("通知", "ツイート許可")
		scr.ero = nil
	end
end
----------------------------------------
-- 開始
function sceneStart()
	message("通知", "シーン開始")

	-- Hシーンフラグ
--	scr.ero = true

	-- MWをシンプルにする
--	if conf.mw_simple == 1 then
--		setMWImage("bg2")
--		mw_alpha()
--	end
end
----------------------------------------
-- 終了
function sceneEnd(p)
	-- Hシーンフラグ
--	scr.ero = nil

	-- MWを戻す
--	setMWImage("bg")
--	mw_alpha()

	-- タイトル画面に戻す
	if getExtra() then
		scr.fo = nil
		notification_clear()	-- 通知を消す
		eqtag{"jump", file="system/ui.asb", label="exscene_jumpend"}

	-- 登録
	else
		local set = p["0"] or p.file
		if set then
			message("通知", set, "をシーン登録しました")
			gscr.scene[set] = true
			asyssave()	-- save
--		else
--			message("通知", "ツイート許可")
		end
	end
	return 1
end
----------------------------------------
