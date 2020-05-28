
function ese(p)
	if tn(p.stop) == 1 then ese_stop(p) else ese_play(p) end
end
-- ese(環境音)再生
function ese_play(p)
	local file = p.file
	local id = tn(p.id or 1)	

	-- 音量確認
	local v1 = conf.ese
	local v2 = conf.fl_ese
	local time = p.time or 0
	local vol = p.vol or 100
	if v1 ==0 or v2 and v2 == 0 then
    --	message("通知", "音量が 0 でした", file)
	if flg.eseid then ese_stop() end
	-- 再生
	elseif file then
		local no = 0
		local path = ":ese/"..file..game.soundext
		seplay(getSEID("ese", no), path, {loop="1",time=(time),vol=(vol)})
		message("通知",path,"を再生しました【ese】")
		scr.ese = string.lower(file)
		flg.eseid = no
	end
end
----------------------------------------
function ese_stop(p)
	tag{"sestop", id=(getSEID("ese", 0)), time=(p.time), eq=(p.eq)}
end