----------------------------------------
-- 立ち絵制御
----------------------------------------
function readfgImage(id, p, flag)
	readImage(id, p, flag)
end
----------------------------------------
-- fg
----------------------------------------
-- fg
function image_fg(p)
	local mode = tn(p.mode or 3)
	local sync = tn(p.sync or 0)

	----------------------------------------
	-- face
	local ch = p.ch
	if mode == 1 or mode == 3 then
		if ch then
			if not scr.face then scr.face = {} end
			scr.face[ch] = p
		end

		-- mode1は立ち絵を消す
		if mode == 1 and scr.img.fg and scr.img.fg[ch] then
			if sync == 1 then
				pushTag{ fgdel, p }
				popTag()
			else
				image_store('fgdel', p)
			end
		end
	elseif ch and scr.face then
		scr.face[ch] = nil
	end

	----------------------------------------
	-- 立ち絵表示
	if mode >= 2 then
		-- すぐに表示する
		if sync == 1 then
--			pushTag{ stackImageCache, p }		-- キャッシュデータ解析
			pushTag{ fg, p }
			popTag()

		-- cacheしておく
		else
--			stackImageCache(p)
			image_store('fg', p)
		end

	----------------------------------------
	-- 消去
	elseif mode == -1 then
		faceparamdel(p.ch)
		if sync == 1 then
			pushTag{ fgdel, p }
			popTag()
		else
			image_store('fgdel', p)
		end

	----------------------------------------
	-- 全消去
	elseif mode == -2 then
		scr.face = nil
		if sync == 1 then
			pushTag{ fgdelall, p }
			popTag()
		else
			image_store('fgdelall', p)
		end
	end
end
----------------------------------------
-- delay fg
function delay_fg(p)
	local mode = tn(p.mode or 3)
	if mode > 1 then fg(p)
	elseif mode ==  1 then
	elseif mode == -1 then fgdel(p)
	elseif mode == -2 then fgdelall(p)
	else error_message(mode..'は不明な立ち絵指定です') end
end
----------------------------------------
-- fg
function fg(p, flag)
	local id  = getImageID('fg', p)
	local idx = addImageID(id, 'base')
	----------------------------------------
	-- fgframe補正
	local ch = p.ch
	local xx = 0
	if scr.img.fgf[ch] then
		xx  = scr.img.fgf[ch].fx - game.centerx
		id  = scr.img.fgf[ch].id..'.fgf.fg'
		idx = addImageID(id, 'base')
		scr.img.fgf[ch].fgid = tn(p.id)
	end

	----------------------------------------
	-- face再保存
	local mode = tn(p.mode)
	if ch and mode == 3 then
		if not scr.face then scr.face = {} end
		scr.face[ch] = p
	end

	----------------------------------------
	-- idが変わっていたら削除
	local d = scr.img.fg[ch]
--	if d and p.resize then lydel2(d) end
	if d and (p.resize or d.id ~= id) then lydel2(d.id) end

	----------------------------------------
	-- base設置
	if p.face then
--		lydel2(idx)

		----------------------------------------
		-- body
		local head = p.head
		local size = p.size or 's'
		local file = patch_checkfg() and p.ex05 or p.file
--		local file = p.file
		local path = p.path
		local ext  = game.fgext
		lyc2{ id=(idx..'.0'), file=(path..file..ext)}

		-- 立ち位置補正
		local v  = fgpos[head] or {}
		local z  = v[file] or { x=0, y=0 }
		local ax = z.ax or game.ax
		local ay = z.ay or game.ay
		tag{"lyprop", id=(idx), left=(xx + z.x), top=(z.y)}
		tag{"lyprop", id=(addImageID(id, 'move')), anchorx=(ax), anchory=(ay)}
		tag{"lyprop", id=(addImageID(id, 'act' )), anchorx=(ax), anchory=(ay)}

		----------------------------------------
		-- ey設置
		local ey = p.ey
		local f = v[ey] or { x=0, y=0 }
		lyc2{ id=(idx..'.1'), file=(path.."eye/"..ey..ext)}
		
		----------------------------------------
		-- eb設置
		local eb = p.eb
		lyc2{ id=(idx..'.2'), file=(path.."eyebrows/"..eb..ext)}

		----------------------------------------
		-- mo設置
		local mo = p.mo
		lyc2{ id=(idx..'.3'), file=(path.."mouth/"..mo..ext)}

		----------------------------------------
		-- ex
		for i=1, 4 do
			local ex = p["ex0"..i]
			if ex then
				local f = v[ex] or { x=0, y=0 }
				lyc2{ id=(idx..'.9.'..i), file=(path..ex..ext)}
			end
		end
		if p.ex == "reset" then 
			for i=1, 4 do
				lydel2(idx..'.9.'..i)
			end
		end

		----------------------------------------
		-- 時間帯フィルタ
		if scr.tone then setColortone(idx)
		else			 setTimezone(idx) end		
	end

	----------------------------------------
	-- 表示tween
	image_postween(id, p, "fg_fade", flag)

	----------------------------------------
	-- 保存
	if not flag then
		local ch = p.ch
		if not scr.img.fg then scr.img.fg = {} end
		scr.img.fg[ch] = { id=(id), p=(p) }
	end
end
----------------------------------------
-- 立ち絵消去
function fgdel(p)
	local sync = tn(p.sync or 0)
	local ch = p.ch
	if scr.img.fg and scr.img.fg[ch] then
		local id = scr.img.fg[ch].id

		-- tween
		if not getSkip() then
			local time = p.time or (p.mx or p.my) and init.fg_fade2 or init.fg_fade
			local mx = mulpos(p.mx)
			local my = mulpos(p.my)
			local idx= addImageID(id, 'act')
			if mx then tween{ id=(idx), x=("0,"..mx), time=(time)} end
			if my then tween{ id=(idx), y=("0,"..my), time=(time)} end
		end

		-- delete
--		flip()
		lydel2(id)
		scr.img.fg[ch] = nil
		faceparamdel(ch)

		-- trans
		if sync == 1 then trans(p) end
	end
end
----------------------------------------
-- 全消去
function fgdelall(p)
	local sync = tn(p and p.sync or 0)
	if scr.img.fg then
		for i, v in pairs(scr.img.fg) do
			local id = v.id 
			if id then lydel2(id) end
		end		
		scr.img.fg = {}
		if sync == 1 then trans(p) end
	end
	scr.face = nil
end
----------------------------------------
-- fg 非表示 
function fghide()
	if scr.img.fg and next(scr.img.fg) then -- 何かしらfgがある時だけ消す
		for name,v in pairs(scr.img.fg) do 
			e:tag{"lyprop",id=(v.id),visible="0"}
		end
	end
	if scr.img.bg and next(scr.img.bg) then
		for name,v in pairs(scr.img.bg) do 
			local path = v.path:gsub("z", ""):sub(1, 4)
			if path ~= ":bg/" and path ~= ":ev/" then
				e:tag{"lyprop",id=(v.idx),visible="0"}
			end
		end
	end
	
	scr.fg_visible = false
end
----------------------------------------
-- fg 表示 
function fgshow()
	if scr.img.fg and next(scr.img.fg) then -- 何かしらfgがある時だけ表示する
		for name,v in pairs(scr.img.fg) do 
			e:tag{"lyprop",id=(v.id),visible="1"}
		end
	end
	if scr.img.bg and next(scr.img.bg) then
		for name,v in pairs(scr.img.bg) do 
			local path = v.path:gsub("z", ""):sub(1, 4)
			if path ~= ":bg/" and path ~= ":ev/" then
				e:tag{"lyprop",id=(v.idx),visible="1"}
			end
		end
	end
	
	scr.fg_visible = true
end
----------------------------------------
-- mw faceパラメータ
function faceparamdel(ch)
	if scr.face then
		if ch then
			scr.face[ch] = nil
			if ch == "mob" then
				scr.face["MOB男"] = nil
				scr.face["MOB女"] = nil
				scr.face["MOB他"] = nil
			end	
		else
			scr.face = nil
		end
	end
end
----------------------------------------
-- fgframe / 画面分割
----------------------------------------
-- fgf
function image_fgf(p)
	local sync = tn(p.sync or 0)
	local mode = tn(p.mode or 1)

	-- 立ち絵表示
	if mode >= 1 then
		-- すぐに表示する
		if sync == 1 then
			local time = p.time or init.fg_fade
			pushTag{ fgf, p }
			pushTag{ trans, { fade=time } }
			popTag()

		else
			-- cacheしておく
--			if p.bg then
--				local v = { file=p.bg, path=':bg/' }
--				local f = v.file:find('/')
--				if f then
--					v.path = v.file:sub(1, f)
--					v.file = v.file:sub(f+1)
--				end
--				imageCache('bg', v)
--			end
			image_store('fgf', p)
		end

	----------------------------------------
	-- 消去
	elseif mode == -1 then
		if sync == 1 then
			local time = p.time or init.fg_fade
			pushTag{ fgfdel, p }
			pushTag{ trans, { fade=time } }
			popTag()
		else
			image_store('fgfdel', p)
		end
	end
end
----------------------------------------
-- delay fgf
function delay_fgf(p)
	local mode = tn(p.mode or 1)
	if mode >= 1 then fgf(p)
	elseif mode == -1 then fgfdel(p) end
end
----------------------------------------
-- fgf
function fgf(p)
	local name = p.frame or "frame_rt"
	local ft = csv.fgframe
	local t  = ft[name]
	if t then
		local id  = getImageID('fgf', t)
		local idx = id..'.fgf'
		local idz = idx..'.0'
		local file = p.bg or 'frame_bg'
		local path = p.bg and ":bg/" or ":cg/"

		-- 背景
		local zm = p.bz
		readImage(idz, { path=(path), file=(file:gsub(":bg/", "")), style=(p.style), dir=(p.dir) })
		tag{"lyprop", id=(idz), left=(mulpos(p.bx)), top=(mulpos(p.by))}
		tag{"lyprop", id=(idz), anchorx=(game.centerx), anchory=(game.centery), xscale=(zm), yscale=(zm)}

		-- 枠
		lyc2{ id=(id ..".n"), file=(':cg/'..name) }
		if not p.notone then setColortone(idx) end
		tag{"lyprop", id=(idx), intermediate_render="1", intermediate_render_mask=(':mask/'..p.frame)}
		tag{"lyprop", id=(id), anchorx=(mulpos(t.fx)), anchory=(mulpos(t.fy))}

		-- tween
		local v = ft[p.disp or 'none']
		if v then
			local time = p.time or init.fg_fade
			if v.x  then tween{id=(id), x=(mulpos(v.x)..',0'), time=(time) } end
			if v.y  then tween{id=(id), y=(mulpos(v.y)..',0'), time=(time) } end
			if v.r  then tween{id=(id), rotate=((v.r)..',0'), time=(time) } end
			if v.z1 then tween{id=(id), xscale='0,100' , time=(time) } end
			if v.z2 then
				time = math.floor(time / 2)
				tag{"tweenset"}
				tween{id=(id), yscale='0,5'	 , time=(time) }
				tween{id=(id), yscale='5,100', time=(time) }
				tag{"/tweenset"}
				tween{id=(id), xscale='0,100', time=(time) }
			end
		end

		-- 保存
		if not scr.img.fgf then scr.img.fgf = {} end
		local ch = p.ch
		scr.img.fgf[name] = { id=(id), ch=(ch) }
		if ch then scr.img.fgf[ch] = { id=(id), fx=(mulpos(t.fx)) } end

		-- trans
		if sync == 1 then trans(p) end
	end
end
----------------------------------------
-- fgfdel
function fgfdel(p)
	if not scr.img.fgf then scr.img.fgf = {} end
	local name = p.frame or "frame_rt"
	local ft = csv.fgframe
	local t  = ft[name]
	if t and scr.img.fgf[name] then
		local id = getImageID('fgf', t)
		local idx = id..'.fgf'
		local time = p.time or init.fg_fade

		-- tween
		local v = ft[p.disp or 'none']
		if v then
			tag{"lyprop", id=(id), anchorx=(mulpos(t.fx)), anchory=(mulpos(t.fy))}
			if v.x  then tween{id=(id), x=('0,'..mulpos(v.x)), time=(time) } end
			if v.y  then tween{id=(id), y=('0,'..mulpos(v.y)), time=(time) } end
			if v.r  then tween{id=(id), rotate=('0,'..(v.r)), time=(time) } end
			if v.z1 then tween{id=(id), xscale='100,0' , time=(time) } end
			if v.z2 then
				local t2 = math.floor(time / 2)
				tag{"tweenset"}
				tween{id=(id), yscale='100,5',	time=(t2) }
				tween{id=(id), yscale='5,0',	time=(t2) }
				tag{"/tweenset"}
				tween{id=(id), xscale='100,0',  time=(t2), delay=(t2) }
			end
		end

		-- 保存
		local ch = scr.img.fgf[name].ch
		if ch then
			scr.img.fgf[ch] = nil
			scr.img.fg[ch] = nil
		end
		scr.img.fgf[name] = nil

		lydel2(id)
	end
end
----------------------------------------
-- 立ち絵アクション
----------------------------------------
-- 
function tag_fgact(p)
	local sync = tn(p.sync or 0)
	if sync == 1 then fgact(p)			-- すぐに実行する
	else image_store('fgact', p) end	-- スタック
end
----------------------------------------
function fgact(p)
	if not scr.img.fg then scr.img.fg = {} end
	local ch = p.ch or ""
	local v  = scr.img.fg[ch]
	image_act(v.id, p)
end
----------------------------------------
-- face
----------------------------------------
function mwf(p)
	-- 消去
	if p.del then
--		mw_facedel()
		scr.faceflag = "del"

	-- 表示
	else
		local ch = p.ch
		if ch then
			if not scr.face then scr.face = {} end
			scr.face[ch] = p
			scr.faceflag = ch
		end
	end
end
----------------------------------------
-- 音声のあるキャラのみmwに出す
function faceview(p)
	local nm = scr.faceflag or p.vo and p.vo[1] and p.vo[1].ch
	if nm == "del" then
		mw_facedel()

	elseif nm then
		local z = csv.voice[nm]
		local ch = z and z[1]
		local v  = scr.face and scr.face[ch]
		if v then
			mw_face(v)
			scr.mwface = nm
		end
	end
	scr.faceflag = nil
end
----------------------------------------
-- MW face
function mw_face(p)
	local id = getMWID("face")
	lydel2(id)

	-- 表示
	local v = getMWFaceFile(p)
	setMWFaceFile(v, "face", id)
end
----------------------------------------
-- MW face 消去
function mw_facedel()
	if scr.mwface then
		local id = getMWID("face")
		if id then lydel2(id) end
		scr.mwface = nil
	end
end
----------------------------------------
-- ファイル名を変換して返す
function getMWFaceFile(p, flag)
	local tbl  = { file=0, face=1, ex01=11, ex02=12, ex03=13, ex04=14 }
	local file = patch_checkfg() and p.ex05 or p.file
	local file = file:gsub("_[bnz][c12]", "_no")
	local head = file:gsub("_no", "_fa"):sub(1, 7) if p.head == "mob" then head = "mob" end
	local path = p.path:gsub(":fg", ":fa"):gsub("/[bnz][co12]/", "/")
	local ch   = p.ch
	local z    = fgpos[head] or {}
	local r    = { path=(path) }
	for nm, id in pairs(tbl) do
		local fl = nm == "file" and file or p[nm]
		if fl then
			if nm == "face" and patch_checkfg() then
				if ch == "みなと" then
						if fl:find("a06") then fl = fl:gsub("a06", "a00")
					elseif fl:find("b06") then fl = fl:gsub("b06", "b00") end
				elseif ch == "悠" then
						if face == "a1938" then face = "a0038"
					elseif face == "b1938" then face = "b0038" end
				end
			end
			r[nm] = { file=(fl), id=(id) }
			if not flag then
				local v = z[fl]
				if v then
					r[nm].x = v.x
					r[nm].y = v.y
				end
			end
		end
	end
	return r
end
----------------------------------------
-- 変換したファイルから描画
function setMWFaceFile(p, nm, id)
	if not p or not p.file then return end
	local idb  = id..".0"
	local path = p.path
	local ext  = game.fgext
	local mw   = csv.mw[nm]
	for fl, v in pairs(p) do
		if fl ~= "path" then
			local idx = idb.."."..v.id
			lyc2{ id=(idx), file=(path..v.file..ext), x=(v.x), y=(v.y)}
		end
	end

	----------------------------------------
	-- 常に合成
	local c = mw.clip
	local z = mw.zoom
	tag{"lyprop", id=(id), left=(mw.x), top=(mw.y), clip=(c), intermediate_render="1", intermediate_render_mask=":mask/facemask"}
	if z then tag{"lyprop", id=(idb), anchorx="0", anchory="0", xscale=(z), yscale=(z)} end

	-- 色調フィルタ
	if not flg.ui and init.game_mwtone == "on" then setColortone(id) end
end
----------------------------------------
-- ボイスを取得して立ち絵の表情を返す
function getBlogFace()
	local r = nil
	local v = scr.face
	if not v or init.game_backlogface ~= "on" then return r end

	-- text blockから名前を取り出す
	local la = game.language
	local b  = scr.ip.block
	local t  = ast.text[b][la]
	local nm = t and t.name and t.name.name
	if nm and v[nm] then
		r = getMWFaceFile(v[nm])
	end
	return r
end
----------------------------------------
-- 裸立ち絵ルーチン
function fg_hadaka_img(ch, pr)
	local p = pr and pr.p
	fg(p, true)
end
----------------------------------------
-- 裸立ち絵ルーチン / mwface
function fg_hadaka_mwface()
	-- 条件を満たしていない場合MWは書き換えない
	local f = scr.mw.msg	-- MW
	local s = scr.select	-- 選択肢
	if s and (s.hide or s.mwsys) then f = nil end
	if f then
		local t  = getText()
		faceview(t)
	end
end
----------------------------------------
