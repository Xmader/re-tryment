----------------------------------------
-- アクション制御
----------------------------------------
-- 実行
function image_act(id, p)
	if id and conf.effect == 1 and not getSkip() then
		local idx = addImageID(id, "act")
		local act = p.act
		local switch = {

			-- びっくり
			["びっくり"] = function(p)
				local y = mulpos(p.size or 25)
				local l = p.loop and (p.loop*2 - 1) or 1
				local t = p.time or 120
				local n = p.ease or "out"
				tween{ id=(idx), y=("0,"..-y), yoyo=(l), time=(t), ease=(n)}
			end,

			-- ジャンプ
			["ジャンプ"] = function(p)
				local y = mulpos(p.size or 40)
				local l = p.loop and (p.loop*2 - 1) or 1
				local t = p.time or 300
				local n = p.ease or "out"
				tween{ id=(idx), y=("0,"..-y), yoyo=(l), time=(t), ease=(n)}
			end,

			-- あくび
			["あくび"] = function(p)
				local y = mulpos(p.size or 6)	-- 12
				local y2= math.floor(y / 0.66)
				local t = p.time or 400			-- 800
				local n = p.ease or "inout"
				tween{ id=(idx), y=("0,"..-y..','..-y2..',0'), time=(t..','..(t*2)..','..t), ease=(n)}
			end,

			-- おじぎ
			["おじぎ"] = function(p)
				local y = mulpos(p.size or 20)
				local y2= math.floor(y * 0.95)
				local t = p.time or 600
				local t2= math.floor(t * 0.75)
				local n = p.ease or "inout"
				tween{ id=(idx), y=("0,"..y..','..y2..',0'), time=(t..','..t2..','..t2), ease=(n)}
			end,

			-- うなづく
			["うなづく"] = function(p)
				local y = mulpos(p.size or 15)
				local t = p.time or 120
				local t2= math.floor(t/2)
				local n = p.ease or "out"
				tween{ id=(idx), y=("0,"..y..',5,0'), time=(t..','..t2..','..t2), ease=(n)}
			end,

			-- うんうん
			["うんうん"] = function(p)
				local y = mulpos(p.size or 20)
				local t = p.time or 100
				local n = p.ease or "out"
				tween{ id=(idx), y=("0,"..y..',0,'..y..',0'), time=(t..','..t..','..t..','..t), ease=(n)}
			end,

			-- 縦揺れ(旧クエイク)
			["縦揺れ"] = function(p)
				local y = mulpos(p.size or 8)
				local y2= math.ceil(y * 0.75)
				local t = p.time or 50
				local n = p.ease or "none"
				tween{ id=(idx), y=('0,'..y..','..-y..','..y..','..-y..','..y2..','..-y2..','..y2..','..-y2..',0'), time=(t), ease=(n)}
			end,

			-- いいえ
			["いいえ"] = function(p)
				local x = mulpos(p.size or 12)
				local l = p.loop and (p.loop*2 - 1) or 1
				local t = p.time or 120
				local n = p.ease or "out"
				tag{"tweenset"}
				tween{ id=(idx), x=("0,"..-x)  , time=(t), ease=(n)}
				tween{ id=(idx), x=(-x..","..x), time=(t), ease=(n), yoyo=(l)}
				tween{ id=(idx), x=(-x..",0")  , time=(t), ease=(n)}
				tag{"/tweenset"}
			end,

			-- ドッキリ
			["ドッキリ"] = function(p)
				local z = p.size or 110
				local l = p.loop and (p.loop*2 - 1) or 1
				local t = p.time or 80
				local n = p.ease or "none"
				tween{ id=(idx), zoom=("100,"..z), yoyo=(l), time=(t), ease=(n)}
			end,

			-- ゆらゆら
			["ゆらゆら"] = function(p)
				local s = p.size or 2
				local l = p.loop and (p.loop*2 - 1) or 1
				local t = p.time or 1500
				local n = p.ease or "inout"
				tag{"tweenset"}
				tween{ id=(idx), rotate=("0,"..s)   , time=(t), ease=(n)}
				tween{ id=(idx), rotate=(s..","..-s), time=(t), ease=(n), yoyo=(l)}
				tween{ id=(idx), rotate=(s..",0")   , time=(t), ease=(n)}
				tag{"/tweenset"}
			end,

			["停止"] = function(p)
				tag{"lytweendel", id=(idx)}
			end,

			quake = function(p)
				local t = tcopy(p)
				t.id = idx
				quake(t)
			end,

			----------------------------------------
			-- ノラととアクション
			du = function(p)
				local sz = mulpos(p.size or 20)
				local lp = p.loop or 1
				local tm = math.floor((p.time or 500) / 2)
				tag{"tweenset"}
				for i=1, lp do
					tween{ id=(idx), y=("0,"..sz), time=(tm), ease="out"}
					tween{ id=(idx), y=(sz..",0"), time=(tm), ease="in"}
				end
				tag{"/tweenset"}
			end,

			ud = function(p)
				local sz = -mulpos(p.size or 20)
				local lp = p.loop or 1
				local tm = math.floor((p.time or 500) / 2)
				tag{"tweenset"}
				for i=1, lp do
					tween{ id=(idx), y=("0,"..sz), time=(tm), ease="out"}
					tween{ id=(idx), y=(sz..",0"), time=(tm), ease="in"}
				end
				tag{"/tweenset"}
			end,

			rl = function(p)
				local sz = mulpos(p.size or 20)
				local lp = p.loop or 1
				local tm = math.floor((p.time or 500) / 2)
				tag{"tweenset"}
				for i=1, lp do
					tween{ id=(idx), x=("0,"..sz), time=(tm), ease="out"}
					tween{ id=(idx), x=(sz..",0"), time=(tm), ease="in"}
				end
				tag{"/tweenset"}
			end,

			lr = function(p)
				local sz = -mulpos(p.size or 20)
				local lp = p.loop or 1
				local tm = math.floor((p.time or 500) / 2)
				tag{"tweenset"}
				for i=1, lp do
					tween{ id=(idx), x=("0,"..sz), time=(tm), ease="out"}
					tween{ id=(idx), x=(sz..",0"), time=(tm), ease="in"}
				end
				tag{"/tweenset"}
			end,

			dud = function(p)
				local sz = mulpos(p.size or 20)
				local lp = p.loop or 1
				local t1 = math.floor((p.time or 500) / 4)
				local t2 = t1 * 2
				tag{"tweenset"}
				tween{ id=(idx), y=("0,"..sz) , time=(t1), ease="out"}
				tween{ id=(idx), y=(sz..","..-sz) , time=(t2), ease="out"}
				if lp>1 then
					for i=1, lp-1 do
						tween{ id=(idx), y=(-sz..","..sz), time=(t2), ease="out", yoyo="1"}
					end
				end
				tween{ id=(idx), y=(-sz..",0"), time=(t1), ease="out"}
				tag{"/tweenset"}
			end,

			rlr = function(p)
				local sz = mulpos(p.size or 20)
				local lp = p.loop or 1
				local t1 = math.floor((p.time or 500) / 4)
				local t2 = t1 * 2
				tag{"tweenset"}
				tween{ id=(idx), x=("0,"..sz) , time=(t1), ease="out"}
				tween{ id=(idx), x=(sz..","..-sz) , time=(t2), ease="out"}
				if lp>1 then
					for i=1, lp-1 do
						tween{ id=(idx), x=(-sz..","..sz), time=(t2), ease="out", yoyo="1"}
					end
				end
				tween{ id=(idx), x=(-sz..",0"), time=(t1), ease="out"}
				tag{"/tweenset"}
			end,
		}
		if switch[act] then
			tag{"lytweendel", id=(idx)}
			switch[act](p)
		end
	end
end
----------------------------------------
-- 演出
----------------------------------------
-- quake
function tag_quake(p)
	local sync = tn(p.sync or 0)
	if sync == 1 then	quake(p)		-- すぐに実行する
	else image_store('quake', p) end	-- スタック

end
----------------------------------------
-- quake
function quake(p)
	if not scr.quake then scr.quake = {} end
	local mode = p.mode or 'gr'
	local id   = p.id   or quake_idtable[mode] or scr.quake[mode]
	if mode == 'bg' or mode == 'cg' then
		local v = scr.img.bg
		local n = tn(p.id or 0) + 1
		if v[n] then
			id = addImageID(v[n].idx, "act")
		else
			message("通知", mode, "id:", n, "は設置されていない画像です")
			return
		end
	elseif mode == 'st' then
		local ch = p.id
		local v  = scr.img.fg
		if ch and v[ch] then
			id = addImageID(v[ch], "act")
		else
			message("通知", mode, "id:", n, "は設置されていない画像です")
			return
		end
	end
	if not id then return end

	tag{"lytweendel", id=(id)}

	----------------------------------------
	-- 停止
	if tn(p.stop) == 1 then
		if scr.quake[mode] then
			tween{ id=(id), x="1,0", time="0"}
			tween{ id=(id), y="1,0", time="0"}
			scr.quake[mode] = nil
		end

	----------------------------------------
	-- 
	else
		local q = init.quake
		local size = mulpos(p.size or q and q[1] or 8)	-- 揺れサイズ
		local w    = mulpos(p.w) or size				-- 揺れサイズ w
		local h    = mulpos(p.h) or size				-- 揺れサイズ h
		local time = tn(p.time or q and q[2] or 60)		-- 揺れる時間
		local cnt  = tn(p.loop or q and q[3] or 10)		-- 揺れる回数
		local ease = p.ease or 'inout'
		local dir  = p.dir  or 'r'
		local fr   = math.ceil(time / 4)
		local mn   = math.ceil(time / 2)

		if cnt ~= -1 and getSkip() then return end

		local sw = {

		----------------------------------------
		-- ランダム∞
		r0 = function()
			if w then
				e:tag{"tweenset"}
				tween{ id=(id), x=("0,"..w)   , time=(fr*2), ease=(ease)}
				tween{ id=(id), x=(w..","..-w), time=(mn*2), ease=(ease), yoyo=(cnt)}
				tween{ id=(id), x=(-w..",0")  , time=(fr*2), ease=(ease)}
				e:tag{"/tweenset"}
			end
			if h then
				e:tag{"tweenset"}
				tween{ id=(id), y=("0,"..h)   , time=(fr), ease=(ease)}
				tween{ id=(id), y=(h..","..-h), time=(mn), ease=(ease), yoyo=(cnt*2)}
				tween{ id=(id), y=(-h..",0")  , time=(fr), ease=(ease)}
				e:tag{"/tweenset"}
			end
		end,

		----------------------------------------
		-- ランダム８
		r1 = function()
			if w then
				e:tag{"tweenset"}
				tween{ id=(id), x=("0,"..w)   , time=(fr), ease=(ease)}
				tween{ id=(id), x=(w..","..-w), time=(mn), ease=(ease), yoyo=(cnt*2)}
				tween{ id=(id), x=(-w..",0")  , time=(fr), ease=(ease)}
				e:tag{"/tweenset"}
			end
			if h then
				e:tag{"tweenset"}
				tween{ id=(id), y=("0,"..h)   , time=(fr*2), ease=(ease)}
				tween{ id=(id), y=(h..","..-h), time=(mn*2), ease=(ease), yoyo=(cnt)}
				tween{ id=(id), y=(-h..",0")  , time=(fr*2), ease=(ease)}
				e:tag{"/tweenset"}
			end
		end,

		----------------------------------------
		-- 2 : 往復＋逆往復
		r2 = function()
			if w then
				e:tag{"tweenset"}
				tween{ id=(id), x=("0,"..w)   , time=(fr), ease=(ease)}
				tween{ id=(id), x=(w..","..-w), time=(mn), ease=(ease), yoyo=(cnt)}
				tween{ id=(id), x=(-w..",0")  , time=(fr), ease=(ease)}
				e:tag{"/tweenset"}
			end
			if h then
				e:tag{"tweenset"}
				tween{ id=(id), y=("0,"..h)   , time=(fr), ease=(ease)}
				tween{ id=(id), y=(h..","..-h), time=(mn), ease=(ease), yoyo=(cnt)}
				tween{ id=(id), y=(-h..",0")  , time=(fr), ease=(ease)}
				e:tag{"/tweenset"}
			end
		end,

		----------------------------------------
		-- 3 : 往復
		r3 = function()
			if w then
				tween{ id=(id), x=("0,"..w), time=(mn), ease=(ease), yoyo=(cnt)}
			end
			if h then
				tween{ id=(id), y=("0,"..h), time=(mn), ease=(ease), yoyo=(cnt)}
			end
		end,

		----------------------------------------
		-- 4 : 右下→戻る→左下→戻る
		r4 = function()
			if w then
				e:tag{"tweenset"}
				tween{ id=(id), x=("0,"..w)   , time=(fr), ease=(ease)}
				tween{ id=(id), x=(w..","..-w), time=(mn), ease=(ease), yoyo=(cnt)}
				tween{ id=(id), x=(-w..",0")  , time=(fr), ease=(ease)}
				e:tag{"/tweenset"}
			end
			if h then
				tween{ id=(id), y=("0,"..h), time=(fr), ease=(ease), yoyo=(cnt)}
			end
		end,
		}

		if sw[dir] then sw[dir]()

		-- 無限ループ
		elseif time == -1 then
			if dir == 'r' or dir == 'v' then tween{ id=(id), x=(size..','..-size), time=(80), yoyo="-1", ease=(p.ease)} end
			if dir == 'r' or dir == 'h' then tween{ id=(id), y=(size..','..-size), time=(70), yoyo="-1", ease=(p.ease)} end
			scr.quake[mode] = id

		-- 時間指定ゆれ / 現在スキップ中かeffect offならば実行しない
		elseif not getSkip(true) then
			local s = size
			local r = -s
			local r2= -s
			local c = 1
			for i=1, cnt do
				local n = math.ceil(s * c)
				if n == 0 then n = 1 end
				r = r..','..n
				r2= r2..','..n..','..-n
				c = c * -1
				s = s * 0.85
			end

			local rx = r..',0'
			local r2 = r2..',0'
				if dir == 'v' then tween{ id=(id), x=(rx), time=(math.ceil(time/2)..','..time), ease=(ease)}
			elseif dir == 'h' then tween{ id=(id), y=(rx), time=(math.ceil(time/2)..','..time), ease=(ease)}
			elseif dir == 'r' then
				tween{ id=(id), x=(r2), time=(math.ceil(time/4)..','..math.ceil(time/2)), ease=(ease)}
				tween{ id=(id), y=(rx), time=(math.ceil(time/2)..','..time), ease=(ease)}
			elseif dir == 'r2' then
				tween{ id=(id), x=(rx), time=(math.ceil(time/4)..','..math.ceil(time/2)), ease=(ease)}
				tween{ id=(id), y=(r2), time=(math.ceil(time/2)..','..time), ease=(ease)}
			end
		end
	end
end
----------------------------------------
-- flash
function tag_flash(p)
	-- 現在スキップ中かeffect offならば実行しない
	if getSkip(true) then return end

	local sync = tn(p.sync or 0)
	if sync == 1 then flash(p)			-- すぐに実行する
	else image_store('flash', p) end	-- スタック
end
----------------------------------------
-- flash
function flash(p)
	local id = "1.0.fl"
	local md = p.mode or "haru"
	local cl = p.color or "0xffffff"
	local st = p.style
	local sw = {
		-- 停止
		stop = function(p)
			tag{"lytweendel", id=(id)}
			lydel2(id)
		end,

		-- harukaze flash
		haru = function(p)
			local tm = math.ceil((p.time or 100) / 2)
			local al = p.alpha or 255;
			local lp = p.loop or p.count or 1 if lp > 1 then lp = lp * 2 - 1 end
			lyc2{ id=(id), width=(game.width), height=(game.height), color=(cl), layermode=(st)}
			tween{ id=(id), alpha="0,"..al, yoyo=(lp), time=(tm), delete="1" }
		end,
	}
	if sw[md] then sw[md](p) end
end
----------------------------------------
