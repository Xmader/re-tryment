----------------------------------------
-- BGM
----------------------------------------
-- bgm filename
function getplaybgmfile(name)
	local s = scr.bgm
	local r = nil
	if name or s and s.file then
		-- タグ名から判定
		local n = name or s.name
		local v = csv.extra_bgm[n]
		if v then
--			if v[1] ~= -1 then r = v[2] end
			r = n

		-- ファイル名から判定
		elseif s.file then
			r = s.file
			if r:sub(-2) == "_a" then r = r:sub(1, -3) end
		end
	end
	return r
end
----------------------------------------
-- bgm
function bgm(p)
	if tn(p.stop) == 1 then bgm_stop(p) else bgm_play(p) end
end

----------------------------------------
-- BGM再生
function bgm_play(p)
	local name	= p.file or p["0"]			-- name
	local file	= name						-- file
	local time	= p.time or 0				-- time
	local loop	= p.loop or 1				-- loop
	local gain	= sound_gain(p.vol or 100)	-- gain
	local pan	= sound_pan( p.pan or 0  )	-- pan	左-100 中0 右100
	local ptime	= p.ptime or 0				-- pan time

	-- time変換
	if getSkip() then time = 1 end

	-- ファイル名変換
	if not csv.extra_bgm[name] then
		message(name, "は登録されていないファイルです")
		return
	else
		file = csv.extra_bgm[name][2]
	end

	if file == scr.bgm.file then
		message("BGM再生", name, "は既に再生されています")
		return
	end

	if scr.mbgm then 
		tags.mbgmstop(e, {time=(time)})
	end
	message("BGM再生", name)

	local cf = scr.bgm and scr.bgm.file
	if cf then	e:tag{"sxfade", file=(':bgm/'..file..game.soundext), time=(time), loop=(loop), gain=(gain)}
	else		e:tag{"splay",  file=(':bgm/'..file..game.soundext), time=(time), loop=(loop), gain=(gain)} end
	e:tag{"span",  pan=(pan), time=(ptime)}

	-- 保存
	scr.bgm = { name=(name), file=(file), vol=(gain), pan=(pan), loop=(loop) }
	sound_check("bgm")

	-- 再生したBGMはtrueをセット
	gscr.bgm[name] = true

	-- 曲名
--	if not p.sys then
--		flg.notification_bgm = p.file
--		notification()
--	end
end
----------------------------------------
-- BGM停止
function bgm_stop(p, flag)
	local time	= p.time or init.bgm_fade	-- time
	local wait	= p.wait or 0				-- wait
	if getSkip() then time = 0 end

	message("BGM停止", "time:", time)
	e:tag{"sstop", time=(time)}

	if not flag then
		-- waitがあったら指定時間待つ
		if wait > 0 then
			eqwait(time)
			e:enqueueTag{"sstop", time="0"}
		end

		-- 保存データの削除
		scr.bgm = {}
		sound_check("bgm")
	end
end
----------------------------------------
-- BGM fade
function bgm_fade(param)
	local time	= param.time or init.bgm_fade	-- time
	local gain	= sound_gain(param.vol or 100)	-- gain
	if getSkip() then time = 0 end

	message("通知", "BGMの音量を", gain, "に変更します")
	e:tag{"sfade", time=(time), gain=(gain)}

	-- 保存
	scr.bgm.vol = gain
end
----------------------------------------
-- BGM pan
function bgm_pan(param)
	local time	= param.time or init.bgm_fade	-- time
	local pan	= sound_pan( param.pan or 0  )	-- pan	左-1000 中0 右1000
	if getSkip() then time = 0 end

	message("通知", "BGMのpanを", pan, "に変更します")
	e:tag{"span", time=(time), pan=(pan)}

	-- 保存
	scr.bgm.pan = pan
end
----------------------------------------
-- 
----------------------------------------
-- BGM / ボイス再生中に音量を下げる
function bgmVoiceFadeIn()
	local f = conf.fl_bgmvo
	local v = f == 0 and 0 or percent(conf.bgmvoice,100) * (scr.bgm.vol or 100)
	if v and conf.bgmvfade == 1 and v < 100 and not getSkip() then
		local c = 1	-- (scr.bgmfade or 0) + 1
		scr.bgmfade = c
		if c == 1 and next(scr.mbgm) then
			local time = init.bgm_voicein
			for i=1,tn(scr.mbgm.rane) do
				if tn(scr.mbgm.current) == i then e:tag{"sefade",id=("mbgm"..i), time=(time), gain=(v.."0")} end
			end
		elseif c == 1 then
			local time = init.bgm_voicein
			e:tag{"sfade", time=(time), gain=(v.."0")}
		end
	end
end
----------------------------------------
-- BGM / ボイス再生終了で音量を戻す
function bgmVoiceFadeOut()
	local c = scr.bgmfade
	if c then
		c = 0	--c - 1
		scr.bgmfade = c
		if c == 0 and next(scr.mbgm) then
			local time = init.bgm_voicein
			for i=1,tn(scr.mbgm.rane) do
				if tn(scr.mbgm.current) == i then e:tag{"sefade",id=("mbgm"..i), time=(time), gain=(scr.bgm.vol or "1000")} end
			end
			scr.bgmfade = nil
		elseif c == 0 then
			local time = getSkip() and 0 or init.bgm_voiceout
			e:tag{"sfade", time=(time), gain=(scr.bgm.vol or "1000")}
			scr.bgmfade = nil
		end
	end
end
----------------------------------------

