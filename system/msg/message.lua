----------------------------------------
-- ADVメッセージ
----------------------------------------
-- メッセージレイヤー／テキスト描画
function mw_text(v)

	if debug_flag then debug_caption() end
	autoskip_keystop()

	local p = getText()
	if p.lane then
		mw_line(v)

	else
		local i = scr.ip.textcount or 0
		i = i + 1
		scr.ip.textcount = i

		-- message time
		local tm = p.time
		if tm then mw_time(tm) end

		-- text
		pushTag{ msgon }
		pushTag{ mw_voice }
		pushTag{ mw_name, p }
		pushTag{ adv_message, p[i] }
		popTag()
	end
end
----------------------------------------
-- 音声
function mw_voice()
	local t = getText()
	faceview(t)
	if t.vo then
		voice_stack(t.vo)
		voice_mainloop()
	end
end
----------------------------------------
-- 文字速度
function mw_time(time)
	local tm = time
	e:tag{"chgmsg", id=(game.mwid..".mw.adv")}
	if tm then
		if tm < 0 then tm = 0 elseif tm > 100 then tm = 100 end
	else
		tm = getMSpeed()
	end
	set_message_speed_tween(tm)
	e:tag{"/chgmsg"}
	scr.mstime = time
end
----------------------------------------
-- name
----------------------------------------
function mw_name(p)
	local no = scr.ip.textcount or 0
	local nm = p.name
	if no and nm then
		-- name
		local tx = nm.text or nm.name
		message_name(tx)
	end
end
----------------------------------------
-- メッセージレイヤー／名前
function message_name(text, cl)
	local id = getMWID("name")
	local idx= game.mwid..".mw.name"
	tag{"chgmsg", id=(idx)}
	tag{"rp"}
	if text then
		-- 名前枠
		local cx = init.mwnameframe
		if cx and type(cx) == 'table' then text = cx[1]..text..cx[2] end

		-- 名前の長さ確認
		local c = #text
		local s = nil
		if c >= 19 then
			local f = csv.font.name01
			s = f.size - c + 18
		end

		-- 表示
		if id then tag{"lyprop", id=(id), visible="1"} end
--		local color = cl or scr.color or "xffffff"
--		tag{"font", color=("0"..color)}	-- outlinecolor
		if s then tag{"font", size=(s), kerning="0"}	end
		--tag{"print", data=(text)}
		if s then tag{"/font"}	end
	else
		if id then tag{"lyprop", id=(id), visible="0"} end
	end
	tag{"/chgmsg"}
end
----------------------------------------
-- メッセージレイヤー／呼び出し
function adv_message(tbl)
	message_control(game.mwid..".mw.adv", tbl)
end
----------------------------------------
-- メッセージ制御
----------------------------------------
-- メッセージレイヤー制御
function message_control(id, tbl, sm)
	tag{"chgmsg", id=(id)}

	message_adv(tbl)
	flip()
	eqwait()

	-- 縦サイズを返す
--	local r = nil
--	if sm then
--		e:tag{"var", system="get_message_layer_height", name="t.tmp.h"}
--		r = e:var("t.tmp.h")
--	end
	tag{"/chgmsg", eq=true}
	return r
end
----------------------------------------
-- メッセージレイヤー／adv
function chgmsg_adv(flag, cl)
	if flag == "close" then
--		e:tag{"/font"}
		e:tag{"/chgmsg"}
	else
		e:tag{"chgmsg", id=(game.mwid..".mw.adv")}
--		local color = cl or scr.color or "xffffff"
--		e:tag{"font", color=("0"..color)}	-- outlinecolor
		if not flag then e:tag{"rp"} end
	end
end
----------------------------------------
-- 本文解析
function message_adv(tbl, mode)
	if tbl then
		-- 既読判定
		local ma = conf.mw_aread or 0
		local ar = getAread()
		local cx = not flg.ui and ar and ma == 1 and init.textaread_color
		if cx then tag{"font", color=("0"..cx)} end

		-- テキスト描画
		for i, t in pairs(tbl) do
			if type(t) == "table" then
				local s = t[1]
				if mode == "sys" and s == "txkey" then
				elseif tags[s] then tags[s](e, t) else e:tag(t) end
			else
				-- 本文描画部分

				e:tag{"print", data=(t)}
				if not flg.blog then
					e:tag{"var",system="get_message_layer_width",name="t.tmp.mww"}
					e:tag{"var",system="get_message_layer_height",name="t.tmp.mwh"}
					local w = e:var("t.tmp.mww")
					local h = e:var("t.tmp.mwh")
					set_cinema_mode(w,h)
				end
			end
		end
		if cx then tag{"/font"} end
	else
		error_message("テキストが見つかりませんでした")
	end
end

function set_cinema_mode(width,height)
	local x = (game.width - width)/2
	local posY = {["41"]=86,["82"]=50,["123"]=18}
	local num = math.ceil(tn(height)/41)
	if num == 1 then 		y = 86
	elseif num == 2 then 	y = 50
	elseif num == 3 then 	y = 18
	else					y = (num-3) * -18 end
	local t = csv.mw["bg01"]
	e:enqueueTag{"lyprop",id=(game.mwid..".mw.adv"),left=(x),top=(y)}
end
----------------------------------------
-- astからtextのみを抽出する
function get_scriptText(block, file)
	local r = ""
	local v = ast.text[block]
	local l = conf.language
	if l and v then v = v[l] end
	if v then
		for i, t in ipairs(v) do
			for j, tx in ipairs(t) do
				if type(tx) == "string" then r = r..tx end
			end
		end
	end	
	return r
end

----------------------------------------
-- noもしくは現在のtext blockを取得
function getTextBlock(no)
	local n = no or scr.ip.block or 1
	local r = ast.text[n]
	if not r then r = ast.text[#ast.text] end
	return r
end
----------------------------------------
-- セーブに利用するtextblock取得
function getSaveTextBlock(block)
	local new_block = {}
	for nm,v in pairs(block)do
		for ln,w in pairs(init.lang)do
			if nm == ln then 
				new_block[ln] = ""
				for tx,u in pairs(v[1]) do
					if type(u) == "string" then new_block[ln] = new_block[ln]..u end
				end
			end
		end
	end
	return new_block
end 


----------------------------------------
-- text再描画
function mw_redraw(mode)
	local ar = getAread()
--	local cl = init.aread_color
--	if not cl or not ar then cl = nil end
--	chgmsg_adv(nil, cl)
--	glyph_setex(ar)

	-- 読み込み
	local bl = scr.ip.block
	local t  = getText(no)
--	local t = ast and ast.text and ast.text[bl]
	if not t.lane then

		-- 名前
		local nm = t.name
		if nm then
			local tx = nm.text or nm.name
			message_name(tx)
		end

		-- 本文
		chgmsg_adv()
		for i, v in ipairs(t) do message_adv(v, mode) end
		chgmsg_adv("close")
	end
end
----------------------------------------
-- その他制御
----------------------------------------
-- 名前／本文消去
function adv_cls4()
	message_name()
	e:tag{"rp"}
	scr.color = nil
end
----------------------------------------
function getText(no)
	local n = no or scr.ip.block or 1
	local r = ast.text[n]
	local l = conf.language
	if l and r then
		local vo = r.vo
		local name = r.name
		r = r[l]
		if vo then r.vo = vo end
		if name then r.name = name end
	end
	return r
end
----------------------------------------
-- 改行
function rt2()
	tag{"rt", omitblankline="1"}
end
----------------------------------------
-- キー待ち
function txkey()
	if not flg.ui then
		flg.txclick = true
		estag("init")
		estag{"eqwait", { scenario="1" }}
		estag{"txkey_click"}
		estag{"txkey_exit"}
		estag()
	end
end
----------------------------------------
function txkey_click()
	tag{"@"}
end
----------------------------------------
function txkey_exit()
	ResetStack()
	flg.txclick = nil
	mw_text()
end
----------------------------------------
-- 外字
function gaiji(p)
	tag{"font", face=(init.gaiji)}
	tag{"print", data=(p.text)}
	tag{"/font"}
end
----------------------------------------
-- カーニング
function kerning(p)
	-- local len = #p.text/2
	-- tag{"font",face=(init.dash), kerning="-5",style="shadow,underline,strikeout",underlinecolor="000000"}
	-- tag{"print",data=(string.rep("ー",len))}
	-- tag{"/font"}

end
----------------------------------------
-- text image
function tximg(p)
	local id = flg.tximgid
	if id then
		local x  = p.x
		local y  = p.y
		local nm = btn.name
		if nm == "blog" then
			local b = csv.font.backlog
			x = b.left
			y = b.top
		end
		lyc2{ id=(id), file=(p.file), x=(x), y=(y)}
	end
end
----------------------------------------
-- font
function exfont(p)
	local sz = p.size
	local co = p.color
	local oco = p.outlinecolor
	local h = nil
	-- 閉じる
	if not sz and not co then
		tag{"/font"}
		scr.fsize = getFontSize()

	-- 
	else
		local s = sz and sz:sub(1, 1) == 'f' and tn(sz:sub(2))
		if s then sz = math.floor(getFontSize() * init.fontsize[s] / 100) end
		if sz and conf.language == "ja" then h = 7 else h = 21 end
		tag{"font", size=(sz), color=(co),outlinecolor=(oco) ,rubysize=(h)}
		if sz then scr.fsize = sz end
	end
end
----------------------------------------
-- 
function getFontSize(name)
	local nm = name or 'adv'
	return csv.font[nm] and csv.font[nm].size or 20
end
----------------------------------------
