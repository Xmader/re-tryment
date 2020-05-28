----------------------------------------
-- タブレットUI
----------------------------------------
-- 初期化
function tab_reset()
	gscr.tablet = {}
	local b = 36
	local x = 1280 - b
	local y = 0
	local z = init.tablet_zoom
	local a = init.tablet_alpha
	gscr.tablet.x = x
	gscr.tablet.y = y
	gscr.tablet.z = z
	gscr.tablet.a = a
	gscr.tablet.b = b
end
----------------------------------------
-- 
function tabletCheck(nm)
	return nm == "ui" and conf.tabletui == 1 or conf.tablet == 1
end
----------------------------------------
-- mw check
function mw_tablet()
	local id = getTabletID()
	if not id then

	elseif not tabletCheck("ui") then
		tag{"lyprop", id=(id), visible="0"}
		tag{"lyprop", id=(getBtnID("tb_mask")), visible="0"}
	else
		if not gscr.tablet then tab_reset() end

		-- zoom
		local g  = gscr.tablet
		local p  = getTabletPos()
		local al = repercent(g.a, 255)
		local zm = g.z * 2
		local x  = g.x
		local y  = g.y
		tag{"lyprop", id=(id), left=(x), top=(y), anchorx=(p.ax), anchory=(p.ay), xscale=(zm), yscale=(zm), alpha=(al), visible="1"}

		-- drag
		local id = getBtnID("tb_mask")
		local al = 0
		tag{"lyprop", id=(id), left=(x), top=(y), anchorx=(p.ax), anchory=(p.ay), xscale=(zm), yscale=(zm), alpha=(al), visible="1"}
		tag{"lyprop", id=(id), draggable="1", clickablethreshold="128"}
		lyevent{ id=(id), name="tablet", key=(1), drag="tab_drag", dragin="tab_dragin", dragout="tab_dragout", over="tab_over", out="tab_out" }
	end
end
----------------------------------------
-- id取得
function getTabletID(nm)
	local r = init.mwtabid
	if r and nm then r = r.."."..nm end
	return r
end
----------------------------------------
-- pos取得
function getTabletPos(cm)
	local id = getBtnID("tb_mask")
	tag{"var", name="t.ly", system="get_layer_info", id=(id), style="map"}
	local p  = {
		x  = tn(e:var("t.ly.left")),	-- 左上座標
		y  = tn(e:var("t.ly.top")),		-- 
		w  = tn(e:var("t.ly.width")),	-- 幅
		h  = tn(e:var("t.ly.height")),	-- 高さ
	}
	p.ax = math.floor(p.w / 2)			-- 中心
	p.ay = math.floor(p.h / 2)

	-- zoom計算をする
	if cm then
		local g  = gscr.tablet
		local zm = g.z * 0.02
		p.zx = math.floor(p.ax * zm) - p.ax		-- 左上のはみ出し量
		p.zy = math.floor(p.ay * zm) - p.ay
		p.zw = math.floor(p.w * zm)				-- zoom後のサイズ
		p.zh = math.floor(p.h * zm)
	end
	return p
end
----------------------------------------
-- 
----------------------------------------
function tab_left()
	local g  = gscr.tablet
	local p  = getTabletPos("zoom")
	local id = getTabletID()
	local ix = getBtnID("tb_mask")
	local tm = init.tablet_movetime
	local zm = g.z * 0.02
	local bx = p.w - g.b
	local x  = p.x

	-- 等倍
	if zm == 1 then
		local x2 = x > 0 and 0 or -bx
		systween{ id=(id), x=(x..","..x2), time=(tm) }
		systween{ id=(ix), x=(x..","..x2), time=(tm) }
		gscr.tablet.x = x2

	-- 大きい
	elseif zm > 1 then
		local n1 = p.zx
		local x2 = x > n1 and n1 or -n1
		systween{ id=(id), x=(x..","..x2), time=(tm) }
		systween{ id=(ix), x=(x..","..x2), time=(tm) }
		gscr.tablet.x = x2

	-- 小さい
	else
		local n1 = -p.zx
		local n2 = p.zx
		local n3 = math.floor((p.zw - p.zx) - g.b * zm)
		local x2 = x > n1 and n1 or x > n2 and n2 or -n3
		systween{ id=(id), x=(x..","..x2), time=(tm) }
		systween{ id=(ix), x=(x..","..x2), time=(tm) }
		gscr.tablet.x = x2
	end
end
----------------------------------------
function tab_right()
	local g  = gscr.tablet
	local p  = getTabletPos("zoom")
	local id = getTabletID()
	local ix = getBtnID("tb_mask")
	local tm = init.tablet_movetime
	local zm = g.z * 0.02
	local bx = p.w - g.b
	local x  = p.x

	-- 等倍
	if zm == 1 then
		local x2 = x < 0 and 0 or bx
		systween{ id=(id), x=(x..","..x2), time=(tm) }
		systween{ id=(ix), x=(x..","..x2), time=(tm) }
		gscr.tablet.x = x2

	-- 大きい
	elseif zm > 1 then
		local n1 = p.zx
		local x2 = x < -n1 and -n1 or n1
		systween{ id=(id), x=(x..","..x2), time=(tm) }
		systween{ id=(ix), x=(x..","..x2), time=(tm) }
		gscr.tablet.x = x2

	-- 小さい
	else
		local n1 = p.zx
		local n2 = -p.zx
		local n3 = math.floor((p.zw - p.zx) - g.b * zm)
		local x2 = x < n1 and n1 or x < n2 and n2 or n3
		systween{ id=(id), x=(x..","..x2), time=(tm) }
		systween{ id=(ix), x=(x..","..x2), time=(tm) }
		gscr.tablet.x = x2
	end
end
----------------------------------------
-- 
----------------------------------------
function tab_over()
	if flg.advdragin then flg.advdrag = true end
end
----------------------------------------
function tab_out()  flg.advdrag = nil end
----------------------------------------
function tab_drag()
	if get_gamemode('ui2', "tb_mask") then
		local p  = getTabletPos()
		local id = getTabletID()
		tag{"lyprop", id=(id), left=(p.x), top=(p.y)}
		flip()
	end
end
----------------------------------------
function tab_dragin()
	if get_gamemode('ui2', "tb_mask") then
		flg.nonactive = true
		flg.advdragin = true
	end
end
----------------------------------------
function tab_dragout(e, p)
	flg.advdrag = nil
	flg.advdragin = nil
	flg.nonactive = nil
	if get_gamemode('ui2', "tb_mask") then
		tab_drag()
		local g  = gscr.tablet
		local p  = getTabletPos("zoom")
		local id = getTabletID()
		local ix = getBtnID("tb_mask")
		local tm = init.tablet_movetime
		local zm = g.z * 0.02
		local x  = p.x
		local y  = p.y

		-- 上下にはみ出た
		local ad = init.tablet_adarea	-- 吸着範囲
		local n1 = p.zy
		local n2 = game.height - p.zy - p.h
		if y < n1 + ad or y > n2 - ad then
			local y2 = y < n1 + ad and n1 or n2
			systween{ id=(id), y=(y..","..y2), time=(tm) }
			systween{ id=(ix), y=(y..","..y2), time=(tm) }
			y = y2
		end
--		flip()
		gscr.tablet.x = x
		gscr.tablet.y = y
	else
		tag{"lyprop", id=(p.id), left=(gscr.tablet.x), top=(gscr.tablet.y)}
		flip()
	end
end
----------------------------------------
-- tablet ui
----------------------------------------
function tab_menu() open_ui('tbui') end
----------------------------------------
function tbui_init()
	message("通知", "タブレット設定を開きました", a, z)

	ui_message("500.tx.1", {"tbnum", x=760, y=405 })
	ui_message("500.tx.2", {"tbnum", x=760, y=462 })

	tbui_init2()
	uiopenanime()
	uitrans()
end
----------------------------------------
function tbui_init2()
	local g = gscr.tablet
	local a = percent(g.a - 25, 75)
	local z = percent(g.z - 25, 75)
	sys.tbui = { alpha=(a), zoom=(z) }

	csvbtn3("tbui", "500", csv.ui_tablet)

	local id = getBtnID("sample")
	tag{"lyprop", id=(id), anchorx="640", anchory="45"}
	tbui_sample()

	set_uihelp("500.tx.help", "tbhelp")
end
----------------------------------------
function tbui_reset()
	del_uihelp()			-- ui help
	ui_message("500.tx.1")
	ui_message("500.tx.2")
	delbtn('tbui')			-- 削除
	sys.tbui = nil			-- ダミークリア
end
----------------------------------------
function tbui_close()
	message("通知", "タブレット設定を閉じました")
	se_cancel()

	uicloseanime()
	tbui_reset()
	uitrans()
end
----------------------------------------
-- 
----------------------------------------
-- 初期値に戻す
function tbui_def()
	se_ok()
	tab_reset()
	tbui_init2()
	flip()
end
----------------------------------------
--
function tbui_alpha(e, p)
	local n = repercent(p.p, 75) + 25
	gscr.tablet.a = n
	tbui_sample()
	flip()
end
----------------------------------------
--
function tbui_zoom(e, p)
	local n = repercent(p.p, 75) + 25
	gscr.tablet.z = n
	tbui_sample()
	flip()
end
----------------------------------------
--
function tbui_sample()
	local g  = gscr.tablet
	local al = repercent(g.a, 255)
	local zm = g.z * 2
	local id = getBtnID("sample")
	tag{"lyprop", id=(id), alpha=(al), xscale=(zm), yscale=(zm)}

	ui_message("500.tx.1", g.z)
	ui_message("500.tx.2", g.a)
end
----------------------------------------
function tab_dummy(e, p)
--	message("通知", "何も機能が割り当てられていません")
end
----------------------------------------
