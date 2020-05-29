----------------------------------------
-- おまけ／CG
----------------------------------------
-- CG初期化
function exf.cginit()

	if not appex.cgmd then appex.cgmd = {} end
	local stm = 0
	local stc = 0
	for set, v in pairs(csv.extra_cgmode) do
		local p = v[1]
		local n = v[2]
		local m = table.maxn(v) - 2

		-- 差分の開き具合を確認しておく
		local o = 0
		for i=1, m do
			local nm = v[i + 2]
			if gscr.ev[nm] then o = o + 1 end
		end

		-- 保存
		local fl = gscr.evset[set]
		if not appex.cgmd[p]	then appex.cgmd[p] = {} end
		if not appex.cgmd[p][n] then appex.cgmd[p][n] = { set=(set), file=(set), open=(o), max=(m), tbl=(v), flag=(fl) } end
		if fl then stc = stc + 1 end
		stm = stm + 1
	end
	local mx = appex.cgmd.pagemax
	for i, v in ipairs(appex.cgmd) do
		appex.cgmd[i].bmax = #v
		appex.cgmd[i].pmax = math.ceil(#v / mx)
	end
end
----------------------------------------
-- ページ生成
function exf.cgpage()
	local p, page, char = exf.getTable()
	local px = p.p

	-- ページ本体
	local max = px.pagemax
	if max then
		local mask = getBtnInfo("cg01")
		local path = game.path.ui.."extra/"
		for i=1, max do
			local hd = (page - 1) * max
			local mv = px[char][p.head + i]
			local nm = "cg"..string.format("%02d", i)
			local id = getBtnID(nm)

			-- ボタン
			if not mv then
				tag{"lyprop", id=(id), visible="0"}
			else
				tag{"lyprop", id=(id), visible="1"}
				local idt = id..".2"
				if mv.flag then
					lyc2{ id=(idt), file=(":thumb/"..mv.file)}
					lyevent{id=(idt),out="thumb_out",over="thumb_over",penetration="1"}
					setBtnStat(nm, nil)
				else
					lydel2(idt)
					setBtnStat(nm, 'c')
				end
			end
		end

		local m = #px
		for i=1, 3 do
			local name = "page"..string.format("%02d", i)
			if i == char then
				setBtnStat(name, 'c')
			else
				setBtnStat(name, nil)
			end
		end
	end
end
----------------------------------------
-- 半透明にするやつ
----------------------------------------
function thumb_over(e,p) tween{id=(p.id),alpha="255,165",time=(250)} end
function thumb_out(e,p) tween{id=(p.id),alpha="165,255",time=(250)} end
----------------------------------------
-- 
----------------------------------------
-- CG表示
function exf.cgview(no)
	local p, pg, ch = exf.getTable()
	local z = p.p[ch][p.head + no]
	-- 下処理
	local c = 0
	flg.excgbuff = {}
	for i=1, z.max do
		local n = z.tbl[i+2]
		if gscr.ev[n] then
			table.insert(flg.excgbuff, n)
			c = c + 1
		end
	end
	flg.excgbuff.count = 1
	flg.excgbuff.max   = c
	flg.excgbuff.set   = z.set
	flg.cg_viewer = {}
	flg.cg_viewer.start = e:now()
	flg.point = e:getMousePoint()
	message("通知","cg viewerを開きました")
	csvbtn3("cg_viewer", "600", csv.ui_cg_viewer)
	local path =  ":ev/"..z.set.."/"..flg.excgbuff[1]
	lyc2{id=("600.a"),file=(path)}
	uitrans()
end
function exf.hideViewerBtn() 
	e:tag{"lyprop",id=("600.btn"),visible="0"}
	flip()
end
function exf.showViewerBtn() 
	e:tag{"lyprop",id=("600.btn"),visible="1"}
	flip()
end
function exf.nextcg()
	local no = flg.excgbuff.count + 1
	if flg.excgbuff[no] then
		flg.excgbuff.count = no
		
		local path =  ":ev/"..flg.excgbuff.set.."/"..flg.excgbuff[no]
		lyc2{id=("600.a"),file=(path)}
		trans({time=500})
	end
end
-----------------------------------------------
--  前へ
function exf.prevcg()
	local no = flg.excgbuff.count - 1
	if flg.excgbuff[no] then
		flg.excgbuff.count = no
		local path =  ":ev/"..flg.excgbuff.set.."/"..flg.excgbuff[no]
		lyc2{id=("600.a"),file=(path)}
		trans({time=500})
	end
end
function exf.closecg()
	flg.excgbuff = nil
	flg.btnstop = nil
	flg.cg_viewer = nil
	flg.point = nil
	message("通知","cg viewerを閉じます")
	delbtn("cg_viewer")
	extra_init("cgmd")
end

-- cg表示終了
function extra_cg_viewerexit()
--	exf.bgmrestart()
	flg.btnstop = nil
end
----------------------------------------
-- cg表示
function extra_cg_viewer()
	local v = flg.excgbuff
	local c = v.count
	local n = v[c]

	message("通知", c.."/"..v.max, n)

	-- 表示
	local time = 300
	local rule = init.rule_cgmode

	-- 振り分け
	-- local switch = {
	-- 	-- movie
	-- 	mvop = function()	extra_cg_movie("mvop") end,
	-- 	mvpv = function()	extra_cg_movie("mvpv") end,

	-- 	-- scroll
	-- 	scroll = function()
	-- 		local time = 30000
	-- 		tween{ id="600", x=("0,-"..game.width), time=(time)}
	-- 		eqwait(time)
	-- 		eqtag{"lytweendel", id="600"}
	-- 	end
	-- }
	-- if switch[n] then
	-- 	switch[n]()
	-- else
		e:tag{"lydel", id="600"}
		local m = ':ev/'..v.set.."/"
		lyc2{ id=("600.1"), file=(m..n)}

		-- 上下黒線
		if game.crop then
--			lyc2{id="1.-1", width="8", height="1", color="0xfff00000", y="-1", visible="0"}
			tag{"lyprop", id="600", top=(game.crop)}
		end
	--end

	-- 次
	local r = 0
	c = c + 1
	if c > v.max then r = 1 end
 	flg.excgbuff.count = c
	e:tag{"var", name="t.check", data=(r)}
	e:tag{"var", name="t.trns" , data=(time)}
	e:tag{"var", name="t.rule" , data=(rule)}
end

