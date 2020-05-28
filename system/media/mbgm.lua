-----------------------------
-- mbgmタグ対応
----------------------------------------
-- mbgm
function mbgm(p)
    if scr.bgm then bgm_stop(p) end -- bgmがあったら止めておく
    mbgm_play(p)
end
function mbgm_play(p)
    local id	= "mbgm"				    -- id
    local files	= split(p.file,",")			-- file
    local time = p.time or 0
    local target = p.default or files[1]
    local gain = sound_gain(p.vol or 100)
    
	-- ファイル名変換
    -- [mbgm file="bgm001,bgm002,bgm003" default="bgm001"]
    for i,v in ipairs(files) do
        local file = v
        --if csv.bgm and csv.bgm[v] then file = csv.bgm[v] end
        local path = ":bgm/"..file.."_a"..game.soundext
        local vol = gain
        if v ~= target then vol = 0 end
        message("通知",path,"を再生します vol:",vol)

        e:tag{"seplay", file=(path),id=(id..i), gain=(vol), loop="1",time=(time)}
    end

	-- 保存
    if not scr.mbgm then scr.mbgm = {} end
	scr.mbgm = { file=(files), id=("mbgm"), vol=(gain), pan=(p.pan), loop=(0),current=(target)}
	sound_check("se", id)
end

function mbgm_change(p)
    if not scr.mbgm then error_message("mgbmの設定をしてください") end
    local id	= scr.mbgm.id
    local files = scr.mbgm.file
	local time	= p.time or 0				-- time
    local target = p.file
    local gain = sound_gain(p.vol or scr.mbgm.vol or 100) 
    for i,v in ipairs(files) do
        local file = v
        if csv.bgm and csv.bgm[v] then file = csv.bgm[v] end
        local path = ":bgm/"..file.."_a"..game.soundext
        local vol = gain
        if v ~= target then vol = 0 
        else scr.mbgm.current = target end
        message("通知",path,"の音量を",vol,"にします")
        e:tag{"sefade",id=(id..i), gain=(vol), loop="1",time=(time)}
    end
end

function mbgm_stop(p)
    local time	= p.time or init.bgm_fade	-- time
    local wait	= p.wait or 0				-- wait
    if scr.mbgm and scr.mbgm.file then
        for i,v in ipairs(scr.mbgm.file) do
            e:tag{"sestop", id=("mbgm"..i),  time=(time)}
        end
    end
    scr.mbgm = {}
end