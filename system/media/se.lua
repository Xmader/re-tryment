----------------------------------------
-- SE
----------------------------------------
-- SE再生
function se(p)
	if tn(p.stop) == 1 then se_stop(p) else se_play(p) end
end
----------------------------------------
function se_play(p)
	local id	= tn(p.id or 1)				-- id
	local file	= p.file					-- file

	-- ファイル名変換
	if csv.se and csv.se[file] then file = csv.se[file] end

	-- 再生
	local path = ":se/"..file..game.soundext
	seplay(id, path, p)

	-- 保存
	if not scr.se then scr.se = {} end
	scr.se[id] = { file=(file), id=(p.id), vol=(p.vol), pan=(p.pan), loop=(p.loop) }
	sound_check("se", id)
end
----------------------------------------
-- SE停止
function se_stop(p)
	local id	= tn(p.id) or -1			-- id
	local time	= p.time or init.normal		-- time
	local wait	= p.wait or 0				-- wait

	-- スキップ中ならtime=0
	if getSkip() then time=0 end

	-- idが-1なら全停止
	if id == -1 then
		message("SE全停止", "time:", time)
		for key, val in pairs(scr.se) do
			e:tag{"sestop", id=(key), time=(time)}
			e:tag{"sestop", id=(key + 10), time=(time)}	-- hse
		end
		scr.se = {}
		sound_check("se", -1)
	else
		message("SE停止", "id:", id, "time:", time)
		e:tag{"sestop", id=(id), time=(time)}
		e:tag{"sestop", id=(id + 10), time=(time)}		-- hse
		scr.se[id] = nil
		sound_check("se", id)
	end

	-- waitがあったら指定時間待つ
	if wait > 0 then
		eqwait(time)
		e:enqueueTag{"sestop", id=(id), time="0"}
	end
end
----------------------------------------
-- se fade
function se_fade(e, param)
	local id	= tonumber(param.id or param.buf) or 0		-- id
	local time	= param.time or 0				-- time
	local gain	= sound_gain(param.vol or 100)	-- gain

	-- スキップ中ならtime=0
	if getSkip() then time=0 end

	e:tag{"sefade", id=(id), gain=(gain), time=(time)}
	scr.se[id].vol = gain
end
----------------------------------------
-- se pan
function se_pan(e, param)
	local id	= tonumber(param.id or param.buf) or 0		-- id
	local time	= param.time or 0				-- time
	local pan	= sound_pan(param.pan or 0)		-- pan	左-1000 中0 右1000

	e:tag{"sepan", id=(id), pan=(pan), time=(time)}
	scr.se[id].pan = pan
end
----------------------------------------
-- 
----------------------------------------
-- SE全音ストップ／強制
function allse_stop(tm, flag)
	local time = tm or 0

	-- se
	local hd = init.mediaid_se
	for i=hd, hd + init.se_limit-1 do
		e:tag{"sestop", id=(i), time=(time)}
	end

	-- exse
	local hd = init.mediaid_se2
	if hd then
		for i=hd, hd + init.se_limit-1 do
			e:tag{"sestop", id=(i), time=(time)}
		end
	end

	if not flag then scr.se = {} end
end
----------------------------------------
-- SE再開 / loopのみ
function replay_se()
	local s = scr.se or {}
	for id, v in pairs(scr.se) do
		if tn(v.loop) == 1 then
			se_play{ id=(id), file=(v.file), pan=(v.pan), vol=(v.vol), loop="1"}
		end
	end
end
----------------------------------------
