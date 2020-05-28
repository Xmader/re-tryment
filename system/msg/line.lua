----------------------------------------
-- LINE
----------------------------------------
-- メッセージレイヤー／テキスト描画
function mw_line(p)
	local mode = p and p.mode

	-- 削除
	if mode == "del" then
		local sync = p and tn(p.sync) ~= 0
		estag("init")
		estag{"msgoff", { hide="0" }}
		if sync then estag{"mwline_close", p}
		else		 estag{"mwline_store", p} end
		estag()

	-- 表示
	else
		estag("init")
		if not scr.line then
			estag{"msgoff"}
			estag{"mwline_open", p}
			estag{"msgon", { mode="sys", hide="0" }}
		else
			estag{"msgon", { mode="sys" }}
		end
		estag{"mwline_main", p}
		estag()
	end
end
----------------------------------------
-- 表示
function mwline_store(p)
	image_store('mwline_close', p)
end
----------------------------------------
-- 表示
function mwline_open(p)
	if not scr.line then
		scr.line = { count=1, buff={} }
		local ch = p.ch
		local no = ch and init["line_char_"..ch] or 1

		local id = init.mwlineid
		local b1 = init.line_back
		local b2 = init.line_window
		lyc2{ id=(id..".0"), file=(b1[1]..no), x=(b1[2]), y=(b1[3])}
		lyc2{ id=(id..".9"), file=(b2[1]..no), x=(b2[2]), y=(b2[3])}

		mwline_del()

		local sc = init.line_scroll
		local time = get_tweentime(sc[2])
		tween{ id=(id), y=(sc[1]..",0"), time=(time) }
		trans{ fade=(time) }
	end
end
----------------------------------------
function mwline_close(p)
	local sync = p and tn(p.sync) ~= 0
	local id = init.mwlineid
	local sc = init.line_scroll
	local time = get_tweentime(sc[2])
	tag{"lyprop", id=(id), intermediate_render="1", intermediate_render_mask=(init.black)}
	if sync then tween{ id=(id), y=("0,"..sc[1]), time=(time) } end
	lydel2(id)
	if sync then
		mwline_del()
		trans{ fade=(time) }
	else
		flg.transcom = "mwline_del"
	end
	scr.line = nil
end
----------------------------------------
-- 
----------------------------------------
--　本体
function mwline_main(p)
	local t  = getText()
	local s  = scr.line
	local ct = t.lane
	local ch = p.ch
	if ch then scr.line.ch = ch:gsub("ex", "") end

	-- buff保存するもの
	local bf = {
--		ch	  = p.ch,		-- tag char
		aread = p.aread,	-- tag 既読
		stamp = p.stamp,	-- tag スタンプ
		w	  = p.w,		-- tag width
		h	  = p.h,		-- tag height
		y	  = s.y,		-- y位置
--		my	  = 0,			-- yサイズ
		file  = scr.ip.file,
		block = scr.ip.block,
	}
	scr.line.buff[ct] = bf
	local w, h = mwline_text(t)

	-- 座標計算
	local sz  = init.line_size
	local sc  = init.line_scroll
	local id  = init.mwlineid..".1.0"
	local idz = init.mwlineid..".1"
	tag{"lyprop", id=(idz), top=(sz[2])}

	-- scroll
	local tm = get_tweentime(sc[4])
	local by = s.y or 0
	local y  = by + h + sz[5]
	scr.line.y = y
	if y <= sz[4] then
		scr.line.buff[ct].my = 0
		local y2 = by + sz[5]
		tween{ id=(id.."."..ct), y=(y2..","..by), time=(tm)}
	else
		local y1 = s.my or 0
		local my = sz[4] - y
		scr.line.buff[ct].my = my
		scr.line.my = my
		tween{ id=(id), y=(y1..","..my), time=(tm)}
	end
	if getSkip() then flip() else uitrans(tm) end
end
----------------------------------------
function mwline_text(t)
	local ct = t.lane
	local s  = scr.line
	local p  = s.buff[ct]

	-- id
	local id   = init.mwlineid
	local ib   = id..".1.0."..ct
	local idtx = ib..".tx"
	local idnm = ib..".nm"

	-- 初期化
	local nm = t.name and t.name.name
	local no = s.ch == nm and 2 or 1
	local fl = p.w and p.h

	-- text
	set_textfont("line0"..no, idtx, true)
	tag{"chgmsg", id=(idtx)}
	tag{"rp"}
	message_adv(t[1])
	if not fl then
		tag{"var", name="t.w", system="get_message_layer_width"}
		tag{"var", name="t.h", system="get_message_layer_height"}
	end
	tag{"/chgmsg"}
	local w = p.w or tn(e:var("t.w"))
	local h = p.h or tn(e:var("t.h"))
	if p.stamp then
		lyc2{ id=(ib..".st"), file=(p.stamp), x="16", y="8" }
	end

	-- mw
	local wd = init["line_name0"..no]
	local sz = init.line_size
	local mx = sz[1]
	local mw = sz[3]
	local fl = wd[1]
	local fk = wd[2]
	local ad = wd[3]
	local bw = wd[4]
	local bh = wd[5]
	local w1 = w + ad
	lyc2{ id=(ib..".bg.1"), file=(fl), clip=("0,0,"..w1..","..h) }
	lyc2{ id=(ib..".bg.2"), file=(fl), clip=(bw..",0,"..ad..","..h), x=(w1) }
	lyc2{ id=(ib..".bg.3"), file=(fl), clip=("0,"..bh..","..w1..","..ad), y=(h) }
	lyc2{ id=(ib..".bg.4"), file=(fl), clip=(bw..","..bh..","..ad..","..ad), x=(w1), y=(h) }

	-- 吹き出し
	local x  = 0
	local zy = math.floor((h + ad - wd[6]) / 2)
	if no == 1 then
		-- 左寄せ
		lyc2{ id=(ib..".bg.5"), file=(fk), x=(-ad), y=(zy) }
		x = mx

		-- 名前
		if nm then
			set_textfont("linenm", idnm, true)
			tag{"chgmsg", id=(idnm)}
			tag{"print", data=(nm)}
			tag{"/chgmsg"}
			tag{"lyprop", id=(idnm), left="0", top="0"}
		end
	else
		-- 右寄せ
		x = mx + mw - w
		lyc2{ id=(ib..".bg.5"), file=(fk), x=(w1+ad), y=(zy) }

		-- 既読
		local ar = p.aread
		if ar ~= "none" then
			local idt = id..".nm"
			local tx = "既読"
			if ar and tn(ar) > 1 then tx = tx.." "..ar end
			set_textfont("linear", idnm, true)
			tag{"chgmsg", id=(idnm)}
			tag{"rp"}
			tag{"print", data=(tx)}
			tag{"/chgmsg"}
			tag{"lyprop", id=(idnm), left=(w1), top=(h)}
--[[
			local idt = id..".tm"
			set_textfont("linetm", idt, true)
			tag{"chgmsg", id=(idt)}
			tag{"rp"}
			if tm then tag{"print", data=(tm)} end
			tag{"/chgmsg"}
			tag{"lyprop", id=(idt), left=(w1)}
]]
		end
	end
	tag{"lyprop", id=(ib), left=(x), top=(p.y)}
	return w, h
end
----------------------------------------
function mwline_del()
	local id = init.mwlineid..".1.0."
	for i=1, 40 do
		tag{"chgmsg", id=(id..i..".tx")}
		tag{"rp"}
		tag{"/chgmsg"}

		tag{"chgmsg", id=(id..i..".nm")}
		tag{"rp"}
		tag{"/chgmsg"}
	end
end
----------------------------------------
function mwline_reset()
	local s = scr.line
	if s then
		mwline_del()
		lydel2(init.mwlineid)
	end
	scr.line = nil
end
----------------------------------------
