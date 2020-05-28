----------------------------------------
-- UIメッセージ処理
----------------------------------------
-- ui message表示
function ui_message(id, p)
	local s = type(p) == 'table'
	if s and p[1] then set_textfont(p[1], id, true) end

	-- text
	local tx = s and p.text or not s and p
	e:tag{"chgmsg", id=(id), layered="1"}
	e:tag{"rp"}
	if tx then e:tag{"print", data=(tx)} end
	e:tag{"/chgmsg"}

	-- pos
	if s and (p.x or p.y) then tag{"lyprop", id=(id), left=(p.x), top=(p.y)} end
end
----------------------------------------
-- ui help
----------------------------------------
-- help設定の確認
function uihelp_check(nm)
	local a = init.game_mwhelp
	local r = init.game_uihelp == 'on' or nm == 'adv' and ((not a or a == 'off') and nil or true)
	return r
end
----------------------------------------
-- ui help font設定
function set_uihelp(id, nm)
	if uihelp_check(nm) then
		del_uihelp()
		if id and nm then
			flg.uihelp = id
			ui_message(id, { nm })
		end
	end
end
----------------------------------------
-- ui help消去
function del_uihelp()
	local id = flg.uihelp
	if id then
		ui_message(id)
		flg.uihelp = nil
	end
end
----------------------------------------
-- ボタンover時にcsvを参照する
function uihelp_over(p)
	local nm = p.name
	if uihelp_check(nm) then
		local id = flg.uihelp
		local gr = btn.name
		local tb = csv.uihelp

		-- adv
		if nm == 'adv' then
			local c = conf.mwhelp
			if flg.txclick or c ~= 1 then id = nil end
		end

		-- 表示
		if id and gr and nm and tb[gr] then
			local tx = tb[gr][nm]
			if not tx then
				local v  = getBtnInfo(nm)
				if v and v.p1 == "help" and v.p2 then tx = tb[gr][v.p2] end
			end
			if tx then
				ui_message(id, tx)

				-- textセンタリング
				local y  = 0
				local bm = btn and btn.name
				if bm then
					local hp = init["uihelp_"..bm]
					if hp then
						tag{"chgmsg", id=(id)}
						tag{"var", name="t.ht", system="get_message_layer_height"}
						local ht = tn(e:var("t.ht"))
						tag{"/chgmsg"}
						y = hp - ht
						if y > 0 then y = math.floor(y / 2) end
					end
				end
				tag{"lyprop", id=(id), top=(y)}
			end
		end
	end
end
----------------------------------------
function uihelp_out(p)
	local id = flg.uihelp
	if id then ui_message(id) end
end
----------------------------------------
