----------------------------------------
-- BG/EV制御
----------------------------------------
-- 
----------------------------------------
-- BGバッファをリセット
function reset_bg()
	e:tag{"lydel", id="1.0"}
	e:tag{"lydel", id="1.60"}
	mw_facedel()
	scr.img = { bg={}, fg={}, fgf={} }
	scr.gray = nil		-- グレースケールoff
	scr.nega = nil		-- ネガポジ反転off
	scr.bgfilter = nil
	scr.evmask = nil	-- HEVマスク

	-- ゲーム画面に対して中間合成をかける
	if checkSynthesis() then
		lyc2{ id="1.0.-1", file=(init.black)}
		screen_crop("1.0")
	end

	-- 中心座標を設定
	tag{"lyprop", id="1.0", anchorx=(game.centerx), anchory=(game.centery), left="0", top="0", xscale="100", yscale="100"}
end
----------------------------------------
-- evset
function evset(p)
	-- 変換
	local set  = p.set
	local file = anyCheck(p)
	if file:sub(1, 1) == 'z' then file = file:sub(2) end
	if not p.notopen and not gscr.evset[set]  then gscr.evset[set] = true	message("通知", set , "を開放しました") end
	if not p.notopen and not gscr.ev[file]	then gscr.ev[file]   = true	message("通知", file, "を登録しました") end

	-- HEVマスク
	if init.game_evmask and set:find("_h") then
		scr.evmask = set
	end
end

function ev_flg(p)
	local set  = p.set
	local file = anyCheck(p)
	
	if not gscr.evset[set]  then gscr.evset[set] = true	message("通知", set , "を開放しました") end
	if not gscr.ev[file]	then gscr.ev[file]   = true	message("通知", file, "を登録しました") end
end
----------------------------------------
-- 
----------------------------------------
function image_bg(p)
	local sync = tn(p.sync or p.id and 0 or 1)		-- cg:0 bg/ev:1
	if not scr.img.bg then scr.img.bg = {} end

	-- すぐに表示する
	if sync == 1 then
		-- 表示チェック
		local time = p.time or init.bg_fade
		local view = tn(p.hide) ~= -1 and true
		local nt   = tn(p.notrans) or 0
		if nt == 1 or time < 2 then view = nil end

		-- 実行
		estag("init")
		if view			then estag{ "msgoff" } end				-- msgoff
		if scr.img.buff then estag{ "image_loop", true } end	-- nosync実行
--		estag{ "stackImageCache", p }	-- キャッシュデータ解析
--		estag{ "waitImageCache" }		-- キャッシュ待ち
		estag{ "image_view", p }		-- 表示
		estag()

	-- cacheしておく
	else
--		stackImageCache(p)				-- キャッシュデータ解析
		image_store('bg', p)
	end
end
----------------------------------------
-- bg画像設置
function image_view(p, flag)
	local no = (p.id or 0) + 1
	local id = getImageID('bg', p)
	local idx= addImageID(id, "base")
	local file = p.file
	local f1 = string.sub(file,1,1)
	local bg = csv.bg[file]
	local type = p.path
	local next_ese = ""
	if f1 == "l" or f1 == "z" then
		bg = csv.bg[string.sub(file,2)]
	end
--	loading_off()
	e:tag{"lydel", id="startmask"}
	if bg and bg.ese then next_ese = string.lower(bg.ese) end
	if bg and bg.ese and p.noese ~= 1 and scr.ese ~= next_ese then  
		storeQJumpStack("ese", {"ese",file=(bg.ese),loop="0"} )
		ese{file=(bg.ese),loop="0"} 
		scr.ese = next_ese
	elseif bg and scr.ese == next_ese then
		message("ese","同じファイルが既に再生されているため、再生をしません")
	else
		if flg.eseid and not bg and type == ":bg/" then ese_stop{time=(p.time or 100)}  scr.ese = nil end
	end
	if p.noese == 1 and not scr.ese then ese_stop{time=(p.time or 100)}  scr.ese = nil end
	-- 立ち絵削除
	if no == 1 then
		-- bg/ev表示時はbg通知を消す
		e:tag{"lytweendel", id="1.99.bgx"}
		fgdelall()
		timezone(p)		-- 立ち絵フィルタ
		reset_bg()
	end

	-- 表示チェック
	local view = true
	local nt   = tn(p.notrans)
	if nt == 1 then view = nil end

	----------------------------------------
	-- 設置
	if view then
		message("通知", file, "を設置しました")
		lydel2(id)
		readImage(id, p)

		-- 特殊effect
		local s = scr.tone
		if s and s.mode == "ex" and conf.effect == 1 then
			local no = tn(s.p.no)
			local sw = {

				-- ブラー的な
				function(v)
					local time = v.speed or 2500
					local x = tn(v.x or 10)
					local y = tn(v.y or 10)
					local c = v.color
					local a = v.alpha or 64
					for i=1, 4 do
						local idc = idx.."."..i
						readImage(idc, p)
--						tag{"lyprop", id=(idc), layermode="add", intermediate_render="1", colormultiply=(c)}
						tag{"lyprop", id=(idc), layermode="add"}
						tween{ sys=1, id=(idc), alpha=("0,"..a), yoyo="-1", time=(time), ease="inout"}
					end
					if y > 0 then
						tween{ sys=1, id=(idx..".1"), y=("0,-"..y), yoyo="-1", time=(time), ease="inout"}
						tween{ sys=1, id=(idx..".2"), y=("0,"..y) , yoyo="-1", time=(time), ease="inout"}
					end
					if x > 0 then
						tween{ sys=1, id=(idx..".3"), x=("0,-"..x), yoyo="-1", time=(time), ease="inout"}
						tween{ sys=1, id=(idx..".4"), x=("0,"..x) , yoyo="-1", time=(time), ease="inout"}
					end
--					tween{ id=(idx..".3"), rotate=("0,-2"), yoyo="-1", time=(time), ease="inout"}
--					tween{ id=(idx..".4"), rotate=("0,2" ), yoyo="-1", time=(time), ease="inout"}
				end,

				-- ぐるぐる
				function(v)
					local t1 = v.time or 2500
					local t2 = v.speed or 50000
					local x = tn(v.x or 480)
					local y = tn(v.y or 240)
					local c = v.color or "ff0000"
					local a = v.alpha or 80
					local t = { { -1,0 }, { 1,0 }, { 0,-1 }, { 0,1 } }
					for i=1, 4 do
						local idc = idx.."."..i
						readImage(idc, p)
						local z = t[i]
						tag{"lyprop", id=(idc), layermode="add", xscale="200", yscale="200", left=(x*z[1]), top=(y*z[2]), intermediate_render="1", colormultiply=(c)}
						tween{ sys=1, id=(idc), alpha=("30,"..a), yoyo="-1", time=(t1), ease="inout"}
					end
					tween{ sys=1, id=(idx..".1"), rotate="0,360" , loop="-1", time=(t2), ease="none"}
					tween{ sys=1, id=(idx..".2"), rotate="0,-360", loop="-1", time=(t2), ease="none"}
					tween{ sys=1, id=(idx..".3"), rotate="0,360" , loop="-1", time=(t2), ease="none"}
					tween{ sys=1, id=(idx..".4"), rotate="0,-360", loop="-1", time=(t2), ease="none"}
				end,
			}
			if sw[no] then sw[no](s.p) end
		end

		-- filter
--		if name == "bg" then bg_f(p) end
	end

	-- tween
	image_postween(id, p)

	if view then
		-- trans
		if not flag then trans{ fade=(p.time), rule=(p.rule), vague=(p.vague), wait=(p.wait) } end

		-- set
		if p.set then evset(p) end
	end

	-- 保存
	local px = p.path
	scr.img.bg[no] = { path=(px), file=(p.file), id=(p.id), lv=(p.lv), idx=(id) }
	if px == ":ani/" then scr.img.bg[no].p = tcopy(p) end
	-- mobだったらフィルターをかける
	local f = p.file:gsub("z", ""):sub(1, 6)
	local fold = p.file:gsub("z", ""):sub(1, 3)
	if fold == "mob" then
		if scr.tone then setColortone(id)
		else			 setTimezone(id) end		
	end
--	wt()
end
----------------------------------------
-- cgdel
function cgdel(p)
	local sync = tn(p.sync or 0)

	-- すぐに表示する
	if sync == 1 then
		if not p.hide  then pushTag{ msgoff } end
		pushTag{ cgdel_main, p }
		popTag()

	-- cacheしておく
	else
		image_store('cgdel_main', p)
	end
end
----------------------------------------
-- cgdel実行
function cgdel_main(p)
	if not scr.img.bg then scr.img.bg = {} end

	-- 全消去
	local id = tn(p.id) or -1
	if id == -1 then
		for i, v in pairs(scr.img.bg) do
			if i > 1 then
				local id = getImageID('bg', v)
				lydel2(id)
				scr.img.bg[i] = nil
			end
		end

	-- id指定消去
	else
		-- move
		local id   = getImageID('bg', p)
		local time = getTweenTime(p.speed or p.time or init.bg_fade)
		local ease = getEase(p.ease or "out")
		if p.x2 then tween{ id=(id), x=(mulpos(p.x2)..","..mulpos(p.x)), time=(time), ease=(ease) } end
		if p.y2 then tween{ id=(id), y=(mulpos(p.y2)..","..mulpos(p.y)), time=(time), ease=(ease) } end

		-- disp処理
		local idx= addImageID(id, "act")
		local mx = mulpos(p.mx)
		local my = mulpos(p.my)
		if mx then tween{ id=(idx), x=("0,"..mx), time=(time), ease=(ease) } end
		if my then tween{ id=(idx), y=("0,"..my), time=(time), ease=(ease) } end
		lydel2(id)

		local no = (p.id or 0) + 1
		scr.img.bg[no] = nil
	end

	-- trans
	local sync = tn(p.sync or 0)
	if sync == 1 then trans{ fade=(p.time), rule=(p.rule), vague=(p.vague) } end
end
----------------------------------------
-- CGアクション
----------------------------------------
-- 
function tag_cgact(p)
	local sync = tn(p.sync or 0)
	if sync == 1 then cgact(p)			-- すぐに実行する
	else image_store('cgact', p) end	-- スタック
end
----------------------------------------
function cgact(p)
	if not scr.img.bg then scr.img.bg = {} end
	local no = (p.id or 0) + 1
	local v  = scr.img.bg
	if no and v[no] then
		image_act(v[no].idx, p)
	end
end
----------------------------------------
-- cg cutin
----------------------------------------
-- cutin
function tag_cgcut(p)
	local sync = tn(p.sync or 0)
	if sync == 1 then image_cgcut(p)		-- すぐに実行する
	else image_store('image_cgcut', p) end	-- スタック
end
----------------------------------------
--
function image_cgcut(p)
	local no = (p.id or 0) + 1
	local id = getImageID('bg', p)
	local idx= addImageID(id, "base")

	local x = mulpos(p.x)
	local y = mulpos(p.y)
	local w = mulpos(p.w)
	local h = mulpos(p.h)
	local c = "0,0,"..w..","..h
	lyc2{ id=(idx..".-1"), width=(w), height=(h), color="0x00000000" }
	tag{"lyprop", id=(id), left=(x), top=(y) }
	tag{"lyprop", id=(idx), clip=(c), intermediate_render="1" }

	----------------------------------------
	-- move
	local x2 = mulpos(p.x2)
	local y2 = mulpos(p.y2)
	if x2 or y2 then
		local ida  = addImageID(id, 'act')
		local time = p.speed or p.time
		if x2 then tween{ id=(ida), x=(x2..",0"), time=(time)} end
		if y2 then tween{ id=(ida), y=(y2..",0"), time=(time)} end
	end

	----------------------------------------
	-- save
	scr.img.bg[no] = { id=(p.id), lv=(p.lv), idx=(idx) }
end
----------------------------------------
