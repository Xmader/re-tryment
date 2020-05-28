----------------------------------------
-- オートモードとスキップモード
----------------------------------------
-- auto / skip初期化
function autoskip_init()
--	autoskip_disable()		-- 停止
--	set_message_speed()		-- メッセージ速度
--	flg.automode = nil		-- autoフラグoff
--	flg.skipmode = nil		-- skipフラグoff
	autoskip_ctrl(true)		-- ctrl
	e:tag{"automode", allow="1"}
	e:tag{"skip", allow="1"}
	e:tag{"automode", syncse=""}
--	flg.loadrestore = nil
	flg.skip = nil
	flg.skipstop = nil
	flg.skipmode = nil
	flg.automode = nil
	flg.ctrlstop = nil

	-- ctrlスキップ制御
	e:tag{"setoncontrolskipin" , handler="calllua", ["function"]="skipctrl_start"}
	e:tag{"setoncontrolskipout", handler="calllua", ["function"]="skipctrl_stop"}
end
----------------------------------------
-- auto / skip初期化 / UI用
function autoskip_uiinit(flag)
	e:tag{"exec", command="automode", mode="0"}
	e:tag{"exec", command="skip",	  mode="0"}
	e:tag{"automode", allow="0"}
	e:tag{"skip", allow="0"}

	-- keyconfig / autoskip関連全部停止
	for i=9, 13 do tag{"keyconfig", role=(i), keys=""} end
	e:tag{"delonautomodeout"}
	e:tag{"deloncommandskipout"}

	-- flagが立っている時のみctrlskip有効
	if flag then
		autoskip_ctrl(true)			-- ctrl
		e:tag{"skip", allow="1"}
	end
end
----------------------------------------
-- オートモードとスキップを停止する
function autoskip_stop(f)
	if f then
		save_autoskip(g)
		e:tag{"delonautomodeout"}
	end
	if flg.automode then e:tag{"exec", command="automode", mode="0"} automode_stopcheck() end
	if flg.skipmode then e:tag{"exec", command="skip",     mode="0"} skipmode_stopcheck() end
end
----------------------------------------
-- オートモードとスキップを強制停止する
function tags.autoskip_disable(e, p) autoskip_disable() return 1 end
function autoskip_disable(f, g)
	e:tag{"delonautomodeout"}
	e:tag{"deloncommandskipout"}
	e:tag{"automode", syncse=""}

	if f then save_autoskip(g) end
	automode_stopcheck()		-- auto停止チェック
	skipmode_stopcheck()		-- skip停止チェック
	flg.skipstop = nil

	e:tag{"exec", command="automode", mode="0"}
	e:tag{"exec", command="skip",	  mode="0"}
	e:tag{"automode", allow="0"}
	e:tag{"skip",	  allow="0"}
	e:tag{"keyconfig", role="10", keys=""}
	e:tag{"keyconfig", role="13", keys=""}
	autoskip_ctrl()		-- ctrlskip off

	e:tag{"delonautomodein"}		-- auto
	e:tag{"delonautomodeout"}		-- 
	e:tag{"deloncommandskipin"}		-- skip
	e:tag{"deloncommandskipout"}	-- 
	e:tag{"deloncontrolskipin"}		-- ctrlskip
	e:tag{"deloncontrolskipout"}	-- 
end
----------------------------------------
-- ctrlskip
function autoskip_ctrl(flag)
	local f = flag and conf.ctrl ~= 0
	if f then
		tag{"keyconfig", role="14", keys=(csv.advkey.ctrl)}	-- 有効
	else
		tag{"keyconfig", role="14", keys=""}				-- 無効
	end
end
----------------------------------------
-- オート／スキップの状態保存
function save_autoskip(f)
	if scr.adv.memory and scr.adv.memory.lock then

	else
		message("通知", "auto/skipの状態を保存しました")
		scr.adv.memory = {
			auto = flg.automode,
			skip = flg.skipmode,
			menu = flg.skipswitch,
			lock = f,
		}
	end
end
----------------------------------------
-- オート／スキップ再開
function restart_autoskip()
	autoskip_init()
	if scr.adv.memory then
		-- skipmodeの再設定
		if conf.skip == 1 and scr.adv.memory.skip then
			-- menuから実行された場合はflagを再保存しておく
			local m = scr.adv.memory.menu
			if m then flg.skipswitch = m end

			-- 一旦強制的に再開
			flg.skipstart = m or conf.messkip
			skipmode_start()
--			menu_hide()

		-- automodeの再設定
		elseif conf.auto == 1 and scr.adv.memory.auto then
			automode_start()
--			menu_hide()

		-- 再開なし
		else
--			e:tag{"lyprop", id="1.80.300", visible="1"}			-- mw save/load
		end
	end
	scr.adv.memory = nil
	flg.selectskip = nil
end
----------------------------------------
-- オート／スキップ再開チェック
-- オート／スキップ動作チェック
function autoskipcheck()
	return flg.automode or flg.skipmode
end
----------------------------------------
-- クリック時の処理
----------------------------------------
-- スキップ中にキー待ち可能なタイミングを作る
function autoskip_wait()
	if flg.skipmode or flg.automode then
		e:tag{"wait", input="1", time="0"}
	end
end
----------------------------------------
-- キー待ちタイミングで停止された場合の処理
function autoskip_keystop()
	-- skip未読停止
	if flg.skipstop or (flg.skipmode and not scr.areadflag and conf.messkip == 0) then
--		se_cancel()
		autoskip_disable()
		autoskip_init()
	end
end
----------------------------------------
-- ボタンが押されたら停止
function autoskip_stopkey(flag)
	if flag then
--		se_cancel()
		if flg.click then
--		autoskip_disable()
--		autoskip_init()
			e:tag{"exec", command="automode", mode="0"}
		else
--			e:tag{"skip", allow="1"}
--			e:tag{"exec", command="skip", mode="1"}
		end
	else
		flg.skipstop = true
	end
end
----------------------------------------
-- skip mode
----------------------------------------
-- スキップ開始
function skipmode_start()
	if flg.skipmode then return end

	-- 既読ブロックのみ実行
	local sk = flg.skipswitch or flg.skipstart or conf.messkip
	if flg.skipstart or scr.areadflag or sk == 1 then
		flg.skipstart = nil

		message("通知", "スキップを開始します mode:", sk)

		-- skip/auto停止
		autoskip_disable()
		autoskip_ctrl()		-- ctrlskip off

		-- 動作設定(固定
--		e:tag{"skip", allow="1", unread=(sk)}
		e:tag{"skip", allow="1", unread=(1)}

		-- icon
		autoskip_startimg("skip")

		e:tag{"setoncommandskipout", handler="calllua", ["function"]="skipmode_stopexec"}

		-- スキップ開始
		e:tag{"keyconfig", role="13", keys=(csv.advkey.skip)}	-- 停止キー登録
		e:tag{"exec", command="skip", mode="1"}
		flg.skipmode = true	-- スキップフラグon
		flg.skip = true
	else
--		se_none()
		message("通知", "未読です")
	end
end
----------------------------------------
-- 停止確認
function skipmode_stopexec()
	e:tag{"deloncommandskipout"}
	e:tag{"keyconfig", role="13", keys=""}	-- 停止キー削除

	if flg.skipmode then se_cancel() end

	local p = flg.waitparam
	local r = getWaitStatusCheck(p)
	if r and r[1] == "time" then
		e:tag{"exec", command="skip", mode="1"}
		flg.skipstop = true
	elseif r then
		e:tag{"exec", command="automode", mode="1"}
		flg.skipstop = true
	else
		skipmode_stopcheck()
	end
end
----------------------------------------
-- 停止確認
function skipmode_stopcheck(mode)
	flg.skip = nil
	if flg.skipmode then
		message("通知", "スキップを停止します")
		if not mode then se_cancel() end
		local id = getMWID("skip")
		if id then e:tag{"lyprop", id=(id), visible="0"} end
		autoskip_stopimg()		-- imageを戻す
		autoskip_init()			-- autoskip再有効化
		autoskip_ctrl(true)		-- ctrl
		setonpush_init()		-- キー再設定
	end
	flg.skipmode = nil	-- スキップフラグoff
end
----------------------------------------
function skipctrl_start()
--	autoskip_startimg("ctrl")
	if not flg.ui and not flg.dlg and not scr.select then
		flg.skip = true
	end
end
----------------------------------------
function skipctrl_stop()
--	autoskip_stopimg()
	flg.skip = nil
end
----------------------------------------
-- auto mode
----------------------------------------
-- オートモード開始
function automode_start()
	if flg.automode then return end

	message("通知", "オートモードを開始します")

	-- skip/auto停止
	autoskip_disable()

	-- 動作設定(固定
	e:tag{"automode", allow="1", stopbyclick="1", stopbystop="1"}

	-- オートが止まった時に呼ばれる
	e:tag{"delonautomodeout"}
	e:tag{"setonautomodeout", handler="calllua", ["function"]="automode_stop"}

	-- automode用image
	autoskip_startimg("auto")

	-- オート開始
--	e:tag{"keyconfig", role="10", keys=(csv.advkey.auto)}	-- 停止キー登録
	e:tag{"exec", command="automode", mode="1"}
	flg.automode = true	-- autoフラグon

	-- auto時ボイス再生終了を待つ
	if conf.autostop == 1 and not flg.delay then
--		eqwait{ se=(scr.voice.id) }
		eqtag{"automode", syncse=(scr.voice.id)}
	end
end
----------------------------------------
-- automode停止
function automode_stop()
	message("通知", "オートモードを停止しました")
	se_cancel()
	flg.automode = nil		-- オートフラグoff
	autoskip_stopimg()		-- imageを戻す
	flip()
	autoskip_init()

	-- @停止中
	if flg.automodeclick then
		ReturnStack()
		eqtag{"@"}
	end
	flg.automodeclick = nil
end
----------------------------------------
-- automode停止チェック
function automode_stopcheck()
	if flg.automode then
		message("通知", "オートモードを停止しました")
		flg.automode =	nil						-- オートフラグoff
		e:tag{"keyconfig", role="10", keys=""}	-- キー設定を戻す
		setonpush_init()						-- キー再設定
		autoskip_stopimg()						-- imageを戻す
		flip()
	end
end
----------------------------------------
