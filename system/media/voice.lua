----------------------------------------
-- 音声
----------------------------------------
-- ボイスバッファをリセット
function reset_voice(flag)
	scr.voice = {
--		flag	= nil,		-- ボイス再生フラグ
--		log		= nil,		-- ボイス再生フラグ / ログ用
--		glyph	= nil,		-- glyph制御
		stack	= {},		-- 発生中のボイスタグ
	}
	scr.vo = nil	-- vo
	if not flag then scr.lvo = {} end	-- bgv
end
----------------------------------------
-- 音声格納
function voice_stack(p)
	if not scr.vo then scr.vo = {} end
	for i, v in pairs(p) do
		table.insert(scr.vo, v)
	end
end
----------------------------------------
-- 音声再生 / mainloop
function voice_mainloop()
	if scr.vo then
		-- クリックで音声停止されてなかったら止める
		if (conf.voiceskip == 0 or conf.autostop == 0) and not flag then
			voice_stopallex(0, nil ,"bgv")
			scr.voice.stack = {}	-- voiceバッファクリア
		end

		for i, v in pairs(scr.vo) do voice_play(v) end
	end
end
----------------------------------------
-- 
----------------------------------------
-- 音声再生
function voice_play(p, flag)
	local file	= p.file or p.voice	or p["0"]	-- file

	-- 情報取得
	local head, v = getVoiceName(p.ch)
	if not v then return end

--	message("音声再生", file)

	-- configで音量0(off)になってたら再生をスキップ
	local ck = nil
	local id = getSEID("voice", v.id)
	if conf.voice > 0 and conf.fl_voice ~= 0 then
		local path = file
		if flag ~= "conf" then path = v.path..file..game.soundext end
		ck = true

		-- check
		local c = init.game_voicecheck
		if c and not isFile(path) then
			if c == "return" then
				message("通知", file, "がありませんでした")
				return
			elseif c == "dialog" then
				tag_dialog{ title="エラー", message=(file.." がありませんでした") }
				return
			end
		end

		-- loop voice再生中
		local lvo = scr.lvo[head]
		if lvo then
			local time = init.voice_fade
			tag{"sefade", id=(lvo.id), time=(time), gain="0"}
		end

		-- vol調整
		if not p.vol and v.vol then p.vol = v.vol end

		-- 再生
		seplay(id, path, p)
	end

	-- リプレイ時は記録しない
	if not flag then

		-- 再生した音声タグをスタック
		table.insert(scr.voice.stack, p)
--[[
		-- キャラフラグがあったら格納しておく
		if init.charsave == 'on' then
			local c = head
			if not gscr.vosave then gscr.vosave = {} end
			if not gscr.vosave[c] then gscr.vosave[c] = true end
		end
]]
		-- オートモード制御
		scr.voice.id   = id
--		if flg.automode then e:tag{"automode", syncse=""} end
	end

	-- 再生終了を待つ
	if ck and (not flag or flag == "adv") then
		bgmVoiceFadeIn()
		eqtag{"setonsoundfinish", id=(id), head=(head), handler="calllua", ["function"]="voice_end"}
	end
end
----------------------------------------
-- ボイス再生終了時に常に呼ばれる
function voice_end(e, p)
	bgmVoiceFadeOut()

	-- loop voice再生中
	local head = p.head
	local lvo = scr.lvo[head]
	if lvo then
		local time = init.voice_fade
		tag{"sefade", id=(lvo.id), time=(time), gain="1000"}
	end
end
----------------------------------------
-- ボイス停止時にloop voice再開
function lvoVoiceFadeOut()
	local time = init.voice_fade
	for head, v in pairs(scr.lvo) do
		tag{"sefade", id=(v.id), time=(time), gain="1000"}
	end
end
----------------------------------------
-- ボイス停止
function vostop(p)
	local time = p.time or 0
	local ch   = p.ch

	-- 全停止
	if not ch then
		lvo{ time=(time), stop=1 }
		voice_stopall(time)

	-- 個別停止
	else
		local head, v = getVoiceName(ch)
		if v then
			tag{"sestop", id=(getSEID("voice", v.id)), time=(time)}
			lvo{ ch=(ch), time=(time), stop=1 }
		end
	end
end
----------------------------------------
-- ボイス再生 / 直接
function vo2(p)
	voice_play(p)
--[[
	estag("init")
	estag{"voice_play", p}
	if conf.voiceskip == 1 then
		estag{"voice_stopall"}
	end
	estag{"reset_voice"}
	estag()
]]
end
----------------------------------------
-- BGV / LoopVoice
----------------------------------------
-- loop voice
function lvo(p)
	local time = p.time or 0
	local ch   = p.ch
	local head, v = getVoiceName(ch)
	local id   = v and getSEID("bgv", v.id)

	-- stop
	if p.stop then
		if v then
			tag{"sestop", id=(id), time=(time)}
			scr.lvo[head] = nil
			sound_check("lvo", head)
		else
			for i, t in pairs(scr.lvo) do
				tag{"sestop", id=(t.id), time=(time)}
			end
			scr.lvo = {}
			sound_check("lvo", -1)
		end

	-- キャラ指定なし
	elseif not v then
		error_message(ch.."は不明なキャラです")

	-- play
	else
		-- bgv設定
		local file = p.file

		-- 再生
		local path = ":bgv/"..p.file..game.soundext
		if not p.loop then p.loop = 1 end
		seplay(id, path, p)
		scr.lvo[head] = { id=(id), file=(path), p=(p) }
		sound_check("lvo", head)
	end
end
----------------------------------------
-- bgv再開
function lvoRestart()
	if checkbgv() and scr.lvo then
		local vo = tcopy(scr.lvo)
		scr.lvo = {}
		for nm, v in pairs(vo) do
			lvo(v.p)
		end
	end
end
----------------------------------------
--
function getVoiceName(ch)
	local head = -1
	local v = csv.voice[ch]
	if v then
		head = ch
	elseif csv.voice.name[ch] then
		head = csv.voice.name[ch][1]
		v = csv.voice[head]
	end
	return head, v
end
----------------------------------------
-- 音声リプレイ
function voice_replay(p, flag)
	message("通知", "音声をリプレイします")
	if p then
		-- テーブルを展開してあるだけ再生する
		local f = flg.ui and true or flag
		for i, v in ipairs(p) do
			local head, t = getVoiceName(v.ch)
			if t then
				local id = getSEID("voice", t.id)
				tag{"sestop", id=(id)}
			end
			voice_play(v, f)
		end
	end
end
----------------------------------------
-- 直前のバックログテーブルに音声番号を加える
--[[
function add_voice(e, param)
	if not log.stack[log.count].voice then log.stack[log.count].voice = {} end
	table.insert(log.stack[log.count].voice, param)
end
]]
----------------------------------------
-- 音声全停止
function voice_stopall(p, flag)
	if scr.voice and scr.voice.stack then
--		message("通知", "全音声を停止しました")
		local time = p or init.voice_fade		-- time
		local s	= scr.voice.stack
		if s then
			for i, v in pairs(s) do
				local t = csv.voice[v.ch]
				if t then
					tag{"sestop", id=(getSEID("voice", t.id)), time=(time)}	-- vo
--					tag{"sestop", id=(getSEID("bgv"  , t.id)), time=(time)}	-- bgv
				end
			end
		end

		-- ボイスバッファをクリア
		reset_voice(flag)
		bgmVoiceFadeOut()
		lvoVoiceFadeOut()
	end
end
----------------------------------------
-- 音声全停止／強制
function voice_stopallex(tm, flag, bgv)
	local time = tm or 0
	local bgvf = checkbgv() and not bgv

	-- voice_tableの中身を取り出す
	for nm, v in pairs(csv.voice) do
		if v.id and v.ex ~= "off" then
			tag{"sestop", id=(getSEID("voice", v.id)), time=(time)}		-- vo
			if bgvf then
				tag{"sestop", id=(getSEID("bgv", v.id)), time=(time)}	-- bgv
			end
		end
	end

	-- sysvoも止める
	if flag then tag{"sestop", id="910", time=(time)} end

	-- 音量戻し
	bgmVoiceFadeOut()
	if bgv then lvoVoiceFadeOut() end
end
----------------------------------------
-- syncseを作成
function make_syncse()
	-- csv.voiceの中身を取り出す
	local ret = ""
	local tbl = {}
	for key, val in pairs(csv.voice) do
		local id = csv.voice[key].id
		if ret == "" then		ret = getSEID("voice", id)
		elseif not tbl[id] then ret = ret..getSEID("voice", id) end
		tbl[id] = true
	end
	return ret
end
----------------------------------------
