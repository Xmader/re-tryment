----------------------------------------
-- システムSE
----------------------------------------
-- system se再生
function sysse(name)
	local file = nil
	local id = flg.sysseid or 0
	local v  = csv.sysse[name]
	if v then file = v[1] end		-- 再生file

	-- 音量確認
	local v1 = conf.sysse
	local v2 = conf.fl_sysse
	if v1 ==0 or v2 and v2 == 0 then
--		message("通知", "音量が 0 でした", file)

	-- 再生
	elseif file then
		local no = id + 1
		if no >= init.sysse_limit then no = 0 end
		local path = ":sysse/"..file..game.soundext
		seplay(getSEID("sysse", no), path, {})
		flg.sysseid = no
	end
end
----------------------------------------
function system_se_stop(p)
	for i=0, init.sysse_limit do
		tag{"sestop", id=(getSEID("sysse", i)), time=(p.time), eq=(p.eq)}
	end
end
----------------------------------------
-- ok
function se_ok()
	if not flg.stopsysse then
		sysse("ok")
	end
	flg.stopsysse = nil
end
----------------------------------------
function se_cancel()  sysse("cancel") end		-- キャンセル
function se_caution() sysse("caution") end		-- ダイアログ
function se_yes()	  sysse("yes") end			-- dialog yes
function se_decide()  sysse("decide") end		-- 決定
function se_select()  sysse("select") end		-- 選択肢決定
function se_none()	  sysse("none") end			-- 無効
function se_menu()	  sysse("menu") end			-- menu
function se_logo()	  sysse("logo") end			-- logo
function se_qsave()   sysse("qsave") end		-- qsave
function se_qload()   sysse("qload") end		-- qload
function se_start()	  sysse("title") end		-- title start
----------------------------------------
-- 完了待機
function sysvowait(p, nm)
	local v = csv.sysse[nm]
	if v and not scr.autosave then
		local wa = p.wait or p["0"]
		if wa then
			local id = flg.sysvoid	--getSEID("sysse", flg.sysvoid)
			e:tag{"wait", se=(id), input="1" }
		else
			sysvo(nm)
		end
	end
end
----------------------------------------
 -- アクティブ
function se_active()
	local file = flg.tsysse or "active"
	if not flg.nonactive then
		sysse(file)
	end
end
----------------------------------------
-- SystemVoice
----------------------------------------
-- system voice
function sysvo(name, flag)
	local s = init.sysvo_func

	-- 音量確認
	local v1 = conf.sysse
	local v2 = conf.fl_sysse
	if v1 ==0 or v2 and v2 == 0 then
--		message("通知", "音量が 0 でした", name)

	-- 専用ルーチンを呼び出す
	elseif s and _G[s] then
		_G[s](name, flag)

	-- 汎用ルーチン
	else
		local no  = conf.sysvochar or 99
		local v   = csv.sysse[name]
		if v and no > 0 then
			local max = #v

			-- check box
			if conf.sysvo01 then
				local t = {}
				local r = 0
				for i=1, max do
					local s = "sysvo"..string.format("%02d", i)
					if conf[s] == 1 then
						r = r + 1
						t[r] = i
					end
				end
				if r == 0 then
--					message("通知", "システムボイスが全てoffでした")
					return
				else
					no = (e:random() % r) + 1
					no = t[no]
				end

			-- ランダム
			else
				if no > max then no = (e:random() % max) + 1 end
			end

			-- 再生
			if v[no] then
--				message("通知", "sysvoice", name)
				local id = getSEID("sysvo" , (name == "exitok" and 1 or 0))
				local path = ":sysse/"..v[no]..game.soundext
				seplay(id, path, {})
				flg.sysvoid = id
				if flag then eqwait{ se=(id) } end
			else
				error_message(name.."は不明なsysvoiceです")
			end
		end
	end
end
----------------------------------------
-- systemVo
--[[
function systemVo(p)
	local file = p.file
	local name = "etc"
	local id   = tonumber(p.id)
	for n, v in pairs(csv.voice) do
		if v.id == id then
			name = n
			break
		end
	end
	message(name, file)
	voice_play{ name=(name), file=(file), path=(string.format("%03d/", id))}
end
]]
----------------------------------------
