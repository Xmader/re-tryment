-- メッセージウィンドウ
----------------------------------------
-- mw check
function msgcheck(mode)
	local id = game.mwid		-- base id
	local mw = id..".mw"		-- mw id
	local ix = getMWID("bg01")	-- mw base idは共通にしておく
	local sw = {
		-- msgon
		on = function()
			tag{"lyprop", id=(id), visible="1"}
			tag{"lyprop", id=(ix), visible="1"}
			tag{"lyprop", id=(mw), visible="1"}
		end,

		-- msgoff
		off = function()
			tag{"lyprop", id=(id), visible="0"}
		end,

		-- msgoff / system on
		sys = function()
			tag{"lyprop", id=(id), visible="1"}
			tag{"lyprop", id=(ix), visible="0"}
			mwdock_select()
		end,

		-- msgoff / select on
		hide = function()
			scr.adv.selecthide = true
			tag{"lyprop", id=(id), visible="1"}
			tag{"lyprop", id=(ix), visible="0"}
			tag{"lyprop", id=(mw), visible="0"}
		end,
	}
	scr.adv.selecthide = nil
	if sw[mode] then
		sw[mode]()
		scr.adv.mwmode = mode
	else
		message("通知", "MWエラー")
	end

	-- menu off
	if scr.adv.menu then tag{"lyprop", id=(init.mwbtnid), visible="0"} end
end
----------------------------------------
-- msg reset
function msg_reset()
	scr.mw.msg = nil
	scr.key_mw = nil
	scr.adv.mwmode = nil
	scr.adv.selecthide = nil

	local id = game.mwid		-- mw本体
	local ix = getMWID("bg01")	-- mw base idは共通にしておく
	local mw = id..".mw"		-- mw sys id
--	e:tag{"lyprop", id=(id), visible="0"}
--	e:tag{"lyprop", id=(ix), visible="1"}
--	e:tag{"lyprop", id=(mw), visible="1"}
	if init.game_mwbutton == "on" then
		e:tag{"lyprop", id=(init.mwbtnid), visible="1"}
	end
end
----------------------------------------
-- [msgon hide=""]
function msgon(p)
	local md = p and p.mode
	local nw = scr.adv.mwmode
	if not scr.mw.msg or md and md ~= nw or not p and nw == "sys" then
		estag("init")
		estag{"msgon_main", p}
		estag{"msgon_flag", p}
		estag()
	end
end
----------------------------------------
function msgon_main(p)
	local time = tn(p and (p.time or p.hide) or init.mw_time)
	if time >= 0 then
		local mode = p and p.mode or "on"
		msgcheck(mode)
		if getSkip(true) or time == 0 then
			flip()
		else
			-- scroll
			local s = init.mw_scroll
			if s and s ~= "off" then
				local id = game.mwid
				tween{ id=(id), y=(s..",0"), time=(time) }
			end

			-- rule
			if not init.rule_msgon then
				trans{ time=(time)}
			else
				local r = init.rule_msgon and "rule_msgon"
				trans{ time=(time) }
			end

		end
	end
end
----------------------------------------
function msgon_flag(p)
	scr.mw.msg = true
end
----------------------------------------
-- [msgoff hide=""]
function msgoff(p)
	if scr.mw.msg then
		estag("init")
		estag{"msgoff_main", p}
--		estag{"msgoff_flag", p}
		estag()
	end
end
----------------------------------------
function msgoff_main(p)
	local time = tn(p and (p.time or p.hide) or init.mw_time)
	if time == -1 then time = init.mw_time end
	if time >= 0 then
		local md = p and p.mode == "sys" and "sys" or "off" 
		msgcheck(md)
		if getSkip(true) or time == 0 then
			flip()
		else
			-- scroll
			local s = init.mw_scroll
			if s and s ~= "off" then
				local id = game.mwid
				tween{ id=(id), y=("0,"..s), time=(time) }
			end

			-- rule
			if not init.rule_msgoff then
				trans{ time=(time)}
			else
				local r = init.rule_msgoff and "rule_msgoff"
				trans{ time=(time)}
			end
		end
		scr.mw.msg = nil
	end
end
----------------------------------------
-- 
----------------------------------------
-- メッセージウィンドウを隠す
function msg_hide(flag)
	if scr.key_mw then return end
	scr.key_mw = true

	local time = init.mw_hidetime

	-- 通知も消す
	notify(nil, true)

	-- ADVモードのみ実行
	e:tag{"lyprop", id=(game.mwid), visible="0"}

	-- wait動作
	if flag ~= "menu" then
		trans{ fade=(time), skip=1, input="0", sys=true }
	end
end
----------------------------------------
-- メッセージウィンドウを表示
function msg_show(name)
	if not scr.key_mw or flg.ui then return end
	scr.key_mw = nil

	-- ADVモードのみ実行
	e:tag{"lyprop", id=(game.mwid), visible="1"}

	-- trans
	estag("init")
	local time = init.mw_hidetime
	local flag = flg.closecom and "off" or not name and "on"
	if flag == "on" then
		estag{"uitrans", { fade=(time), skip="1", input="0" }}
	end

	-- ボタン許可
	estag{"init_adv_btn"}
	estag{"autoskip_init"}
	estag{"flip"}
	estag()
end
----------------------------------------
