----------------------------------------
-- メニュー
----------------------------------------
-- メニューを開く
function menu_init()
	message("通知", "右クリックメニューに入りました")

	-- メニューフラグon
	if not scr.menu then scr.menu = {} end
	
	-- ボタン描画
	menu_button()
	menu_open()
end
----------------------------------------
-- event mode時にボタンを使用不能にする
function menu_button()

	csvbtn3("menu", "500", csv.ui_menu)
	if scr.select then
		e:tag{"lyprop", id=(getBtnID("bt_auto")), visible="0"}
		e:tag{"lyprop", id=(getBtnID("bt_skip")), visible="0"}
	end

	if game.os == "windows" then 
		e:tag{"lyprop", id=(getBtnID("bt_save"))  ,top="144",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_load"))   ,top="186",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_auto"))   ,top="227",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_skip"))   ,top="270",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_blog"))   ,top="312",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_mwoff"))  ,top="354",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_config")) ,top="396",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_library")),top="437",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_title"))  ,top="480",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_exit"))   ,top="522",alpha="0"}
	else
		e:tag{"lyprop", id=(getBtnID("bt_save"))  ,top="146",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_load"))   ,top="193",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_auto"))   ,top="240",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_skip"))   ,top="287",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_blog"))   ,top="334",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_mwoff"))  ,top="381",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_config")) ,top="428",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_library")),top="475",alpha="0"}
		e:tag{"lyprop",id=(getBtnID("bt_title"))  ,top="522",alpha="0"}
	end
	-- save/load/qsave/qloadを使用不能にする
	if getExtra() then
		e:tag{"lyprop", id=(getBtnID("bt_save")), visible="0"}
		e:tag{"lyprop", id=(getBtnID("bt_load")), visible="0"}
	end
end
----------------------------------------
-- 画像描画
function menu_open()
	e:tag{"mouse", hide="0", autohide="0"}
	local time = 500
	menu_active()

	-- 閉じる
	if scr.menuopen then
		local name = scr.menuopen
		scr.menuopen = nil
		if name == "blog" then eqwait(300) time=200 end
	end

	-- 開く
	uitrans(time)
	time = 667
	if game.os == "windows" then
		tween{id=(getBtnID("bt_save"))   ,y="144,149"  ,delay=(167),time=(time)}
		tween{id=(getBtnID("bt_load"))   ,y="186,191"  ,delay=(167+1*time/10),time=(time)}
		tween{id=(getBtnID("bt_auto"))   ,y="227,233"  ,delay=(167+2*time/10),time=(time)}
		tween{id=(getBtnID("bt_skip"))   ,y="270,275"  ,delay=(167+3*time/10),time=(time)}
		tween{id=(getBtnID("bt_blog"))   ,y="312,317"  ,delay=(167+4*time/10),time=(time)}
		tween{id=(getBtnID("bt_mwoff"))  ,y="354,359"  ,delay=(167+5*time/10),time=(time)}
		tween{id=(getBtnID("bt_config")) ,y="396,401"  ,delay=(167+6*time/10),time=(time)}
		tween{id=(getBtnID("bt_library")),y="437,443"  ,delay=(167+7*time/10),time=(time)}
		tween{id=(getBtnID("bt_title"))  ,y="480,485"  ,delay=(167+8*time/10),time=(time)}
		tween{id=(getBtnID("bt_exit"))   ,y="522,527"  ,delay=(167+9*time/10),time=(time)}


		tween{id=(getBtnID("bt_save"))   ,alpha="0,255",delay=(167),time=(time)}
		tween{id=(getBtnID("bt_load"))   ,alpha="0,255",delay=(167+1*time/10),time=(time)}
		tween{id=(getBtnID("bt_auto"))   ,alpha="0,255",delay=(167+2*time/10),time=(time)}
		tween{id=(getBtnID("bt_skip"))   ,alpha="0,255",delay=(167+3*time/10),time=(time)}
		tween{id=(getBtnID("bt_blog"))   ,alpha="0,255",delay=(167+4*time/10),time=(time)}
		tween{id=(getBtnID("bt_mwoff"))  ,alpha="0,255",delay=(167+5*time/10),time=(time)}
		tween{id=(getBtnID("bt_config")) ,alpha="0,255",delay=(167+6*time/10),time=(time)}
		tween{id=(getBtnID("bt_library")),alpha="0,255",delay=(167+7*time/10),time=(time)}
		tween{id=(getBtnID("bt_title"))  ,alpha="0,255",delay=(167+8*time/10),time=(time)}
		tween{id=(getBtnID("bt_exit"))   ,alpha="0,255",delay=(167+9*time/10),time=(time)}
	else
		tween{id=(getBtnID("bt_save"))   ,y="146,151"  ,delay=(167),time=(time)}
		tween{id=(getBtnID("bt_load"))   ,y="193,198"  ,delay=(167+1*time/10),time=(time)}
		tween{id=(getBtnID("bt_auto"))   ,y="240,245"  ,delay=(167+2*time/10),time=(time)}
		tween{id=(getBtnID("bt_skip"))   ,y="287,292"  ,delay=(167+3*time/10),time=(time)}
		tween{id=(getBtnID("bt_blog"))   ,y="334,339"  ,delay=(167+4*time/10),time=(time)}
		tween{id=(getBtnID("bt_mwoff"))  ,y="381,386"  ,delay=(167+5*time/10),time=(time)}
		tween{id=(getBtnID("bt_config")) ,y="428,433"  ,delay=(167+6*time/10),time=(time)}
		tween{id=(getBtnID("bt_library")),y="475,480"  ,delay=(167+7*time/10),time=(time)}
		tween{id=(getBtnID("bt_title"))  ,y="522,527"  ,delay=(167+8*time/10),time=(time)}


		tween{id=(getBtnID("bt_save"))   ,alpha="0,255",delay=(167),time=(time)}
		tween{id=(getBtnID("bt_load"))   ,alpha="0,255",delay=(167+1*time/10),time=(time)}
		tween{id=(getBtnID("bt_auto"))   ,alpha="0,255",delay=(167+2*time/10),time=(time)}
		tween{id=(getBtnID("bt_skip"))   ,alpha="0,255",delay=(167+3*time/10),time=(time)}
		tween{id=(getBtnID("bt_blog"))   ,alpha="0,255",delay=(167+4*time/10),time=(time)}
		tween{id=(getBtnID("bt_mwoff"))  ,alpha="0,255",delay=(167+5*time/10),time=(time)}
		tween{id=(getBtnID("bt_config")) ,alpha="0,255",delay=(167+6*time/10),time=(time)}
		tween{id=(getBtnID("bt_library")),alpha="0,255",delay=(167+7*time/10),time=(time)}
		tween{id=(getBtnID("bt_title"))  ,alpha="0,255",delay=(167+8*time/10),time=(time)}
	end
	uiopenanime()
	uitrans()
end
----------------------------------------
-- ボタンをアクティブにする
function menu_active()
	if scr.menu.bt and game.os ~= "android" then
	--	btn_active2(scr.menu.bt)
	end
end
----------------------------------------
-- 
function menu_playtime(text)
	e:tag{"chgmsg", id="time", layered="1"}
	e:tag{"rp"}
	if text then e:tag{"print", data=(text)} end
	e:tag{"/chgmsg"}
end
----------------------------------------
-- メニューから抜ける
function menu_close()
	message("通知", "右クリックメニューから抜けました")
	mouse_autohide()
	local func = flg.closecom
	if func then
		se_ok()
		menu_reset(e, { close=true })
	else
		se_cancel()
		menu_reset(e, { close=true })
	end
	scr.menu = nil	-- メニューフラグoff
end
----------------------------------------
-- 状態クリア
function menu_reset(e, p)
	if p then
		local time = init.ui_fade
		if p.close then
			eqwait(time)
		end
	end
	delbtn('menu')
	--menu_playtime()
	sv.delpoint()
	uicloseanime()
	uitrans()
end
----------------------------------------
-- menuを抜けて機能呼び出し
function menu_callfunc(name)
	flg.closecom = "adv_"..name
	close_ui()
end
----------------------------------------
-- メニューボタンがクリックされた
function menu_click(e, param)
	local bt = btn.cursor
	if bt then
--		message("通知", bt, "が選択されました")

		-- 振り分け
		local switch = {
--			bt_qsave = function()	se_ok() adv_qsave() end,	-- クイックセーブ
			bt_qload = function()	se_ok() adv_qload() end,	-- クイックロード
			bt_title = function()	se_ok() adv_title() end,	-- タイトルに戻る
			bt_manual = function()	se_ok() adv_manual() end,	-- マニュアル
			bt_save = function()	se_ok() adv_save() end,		-- セーブ
			bt_load = function()	se_ok() adv_load() 	end,	-- ロード
			bt_config = function()	se_ok() adv_config() end,	-- コンフィグ
			bt_blog  = function()	adv_backlog() end,	        -- バックログ
			bt_library= function() adv_tips() end,              -- Tips
			bt_qsave = function()	menu_callfunc("qsave") end,	-- クイックセーブ
			bt_auto = function()	menu_callfunc("auto") end,	-- auto
			bt_skip = function()	menu_callfunc("skip") end,	-- skip
			bt_mwoff = function()	menu_callfunc("msgoff") end,-- msgoff

			bt_exit = function()	adv_exit() end,		-- exit
		}

		-- switch文
		if switch[bt] then
			switch[bt]()
			scr.menu.bt = bt
		else
			error_message(bt, "は登録されていないメニューボタンです")
		end
	end
end
----------------------------------------
function menu_over(e, p)
	local bt = p.name
	local v  = getBtnInfo(bt)
	local z  = getBtnInfo("help")
	if v.p1 then
		local y = z.ch * v.p1
		tag{"lyprop", id=(z.idx), visible="1"}
		tag{"lyprop", id=(z.idx), clip=(z.cx..","..y..","..z.cw..","..z.ch)}
	else
		tag{"lyprop", id=(z.idx), visible="0"}
	end
end
----------------------------------------
-- □マニュアル
----------------------------------------
function mnal_init()
--	se_ok()
	csvbtn3("mnal", "500", csv.ui_manual)
	uitrans()
end
----------------------------------------
function mnal_reset()
	se_cancel()
	delbtn('mnal')
end
----------------------------------------
function mnal_close()
	mnal_reset()
--	uitrans{ rule="rule8r" }
end
----------------------------------------
function manual_click()
	e:tag{"var", name="t.path", data=(game.path.ui.."manual")}
	e:tag{"jump", file="system/ui.asb", label="manual_copyright"}
end
----------------------------------------
