----------------------------------------
-- sound
----------------------------------------
-- system sound
function systemsound(mode, tm)
	local time = not getSkip() and tm or 0
	local sw = {

		----------------------------------------
		-- 全停止
		stop = function(time)
			bgm_stop({ time=(time) }, true)
			mbgm_stop({time=(time)})
			allse_stop(time, true)
			voice_stopallex(time, nil, not checkbgv())
		end,

		----------------------------------------
		-- ui停止
		uistop = function(time)
			allse_stop(time, true)
			voice_stopallex(time, nil)
		end,

		----------------------------------------
		-- 再開
		replay = function(time)
			if scr.bgm and scr.bgm.file then
				local s = tcopy(scr.bgm)
				s.file = getplaybgmfile(s.name)
				bgm_play(s)
			end
			replay_se()
			lvoRestart()
		end,

		----------------------------------------
		-- 現在の値を保存
		selsave = function()
			scr.selsave = {
				bgm = scr.bgm,
				se  = scr.se,
				lvo = scr.lvo,
			}
		end,

		----------------------------------------
		-- 現在の値を再開
		selload = function(time)
			local s = scr.selsave
			if s then
				-- bgm
				if s.bgm then
					local v = tcopy(s.bgm)
					v.file = getplaybgmfile(v.name)
					bgm_play(v)
				end

				-- se
				if s.se then
					for i, v in pairs(s.se) do
						if tn(v.loop) == 1 then
							se_play(v)
						end
					end
				end

				-- loopvoice
				if s.lvo then
					for nm, v in pairs(s.lvo) do
						lvo(v.p)
					end
				end
			end
			scr.selsave = nil
		end,
	}
	if mode and sw[mode] then sw[mode](time) end
end
----------------------------------------
-- 高速スキップ処理
function sound_check(nm, no)
	local s = scr.selsave
	if flg.exskip and s and s[nm] then
		if no == -1 then
			scr.selsave[nm] = {}
		elseif no then
			scr.selsave[nm][no] = nil
		else
			scr.selsave[nm] = nil
		end
	end
end
----------------------------------------
-- 全音ストップ
function allsound_stop(p)
	local time = p and (p["0"] or p.time) or init.bgm_fade
	systemsound("stop", time)
--	voice_stopallex(time, true)
--	bgm_stop{ time=(time) }
--	se_stop{  time=(time), id=-1 }
	scr.bgm = {}
	scr.se = {}
	reset_voice()
end
----------------------------------------
function checkbgv() return init.game_enablebgv == "on" end
----------------------------------------
-- seid取得
function getSEID(name, id)
	local r = -1
	local s = "mediaid_"..name
	local v = init[s]
	if v then
		r = v + id
	else
		error_message(name.."("..id..") は使用できないsound idです。")
	end
	return r
end
----------------------------------------
--
----------------------------------------
-- play共通
function seplay(id, file, p)
	local time	= p.time					-- time
	local loop	= tn(p.loop or 0)			-- loop
	local skip	= p.skippable or 1			-- skip
	local gain	= sound_gain(p.vol or 100)	-- gain
	local pan	= sound_pan(p.pan or 0)		-- pan	左-1000 中0 右1000
	local ptime	= p.ptime or 0				-- pan time
	local sync	= tn(p.sync)				-- sync

	-- debug check
	if debug_flag then
		local f = e:isFileExists(file)
		if not f then
			if debug_setting.voice_error or debc and debc.debg and debc.debg.soundcheck == 1 then
				message("通知", file, "は存在しません") 
				return
			end
		end
	end

	-- スキップ中かつloopなしなら停止タグを発行して抜ける
	if loop == 0 and getSkip() then tag{"sestop", id=(id)} return else skip = 0 end

	-- 再生
	local gx = p.vol and gain
--	tag{"sestop", eq=(p.eq), id=(id)}
	tag{"seplay", eq=(p.eq), id=(id), file=(file), time=(time), loop=(loop), gain=(gx), skippable=(skip)}
	if p.pan then tag{"sepan", eq=(p.eq), id=(id), pan=(pan), time=(ptime)} end

	-- syncセット
	if sync == 1 then eqwait{ se=(id) } end
end
----------------------------------------
-- panチェック
function sound_pan(pan)
	local p = tonumber(pan)
	local a = string.sub(string.lower(pan), 1, 1)
	if p ~= 0 then
		-- pan l c r
		if		pan == 'c' then p = 0
		elseif	pan == 'l' then p = -1000
		elseif	pan == 'r' then p = 1000

		elseif	a == 'l' then
			a = string.sub(pan, 2)
			p = a * 10 * -1
		elseif	a == 'r' then
			a = string.sub(pan, 2)
			p = a * 10

		-- pan 10段階
		elseif	p < -100 then p = -1000
		elseif	p > 100	then p = 1000
		else	p = p * 10
		end
	end
	return p
end
----------------------------------------
-- gainチェック
function sound_gain(gain)
	local g = tonumber(gain)
	-- gain 100段階
	if		g < 0	then g = 0
	elseif	g > 100	then g = 1000
	else	g = g * 10
	end
	return g
end
-- 
----------------------------------------
-- ボリューム変更
function media_volume(p)
	local id  = p.id or 1
	local vol = (p.fade or 100) * 10
	local tm  = not getSkip() and p.time
	if vol < 0 then vol = 0 elseif vol > 1000 then vol = 1000 end

	message("通知", "音量変更:", vol, "id:", id, "time:", tm)
	if id == "ese" then id = init["mediaid_ese"] end
	-- bgm
	if id == "bgm" then
		tag{"sfade", gain=(vol), time=(tm)}
		scr.bgm.vol = vol
	-- se
	else
		tag{"sefade", id=(id), gain=(vol), time=(tm)}
	end
end
----------------------------------------
