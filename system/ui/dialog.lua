----------------------------------------
-- 画像ダイアログ
----------------------------------------
function dialog(name)
	fn.push("dlg", {
		{ dialog_main, name },
		{ dialog_exit, name },
	})
end
----------------------------------------
-- dialogを抜けたあとに実行する
function dialog_exit(name)
	local r = fn.get()
	if r == 1 then
		local switch = {
			qsave = function() sv.quicksave() end,	-- qsave
			qload = function() sv.quickload() end,	-- qload
			save  = function() sv.saveclick() end,	-- save
			save2 = function() sv.saveclick() end,	-- save上書き
			load  = function() sv.loadclick() end,	-- load
			favo  = function() favoclick() end,		-- お気に入りボイス
			favo2 = function() favoclick() end,		-- お気に入りボイス上書き
			fdel  = function() favodelete() end,	-- お気に入りボイス削除

			reset = function() config_resetview() end,	-- config reset
			title = function() sv.go_title() end,	-- title
			exit  = function() sv.go_exit() end,	-- game exit
			scene = function() sv.go_title() end,	-- scene
			jump  = function() goBacklogJumpTo() end,	-- backlog jump

			back  = function() goBackSelect() end,	-- 前の選択肢に戻る
			next  = function() goNextSelect() end,	-- 次の選択肢に進む

			flow  = function() flow_script() end,	-- フローチャート確認
			web   = function() goWebAccess() end,	-- ブラウザを開く確認

			del   = function() sv.delete() end,		-- save data削除
			sus   = function() sv.suspend() end,	-- suspend

			tweet = function() ex_tweet() end,		-- tweet
			oksus = function() load_suspendcheck2() end,
		}
		if switch[name] then
			message("通知", name, "を呼び出します")
			switch[name]()
		end
	end
end
----------------------------------------
-- dialog / 新ルーチン
function dialog_main(name)
	local check = nil

	local bt = btn.cursor
	if bt then btn_nonactive(bt) end

	-- onになっていたらダイアログを表示せずに抜ける
	-- local dlg = conf["dlg_"..name]
	-- 今作ではdlgフラグだけでよい
	local dlg = conf["dlg"]
--	if name == 'save2' then dlg = conf.dlg_save end		-- 上書き確認はsaveで判定
--	if name == 'scene' then dlg = conf.dlg_title end	-- sceneはtitleで判定
	if dlg == 1 then
--		se_ok()
		message("通知", "dialogで確認をしない設定です", name)
		return 1	-- yesの戻り値
	end

	-- -- 機種ごとの文字座標を得る
	-- ipt = nil
	-- local path = game.path.ui.."mw/dialog.ipt"
	-- e:include(path)
	-- if not ipt then
	-- 	error_message("座標ファイルが見つかりませんでした")
	-- 	return 0	-- noの戻り値
	-- end

	message("通知", "dialogを開きました", name)

	-- ドラッグ禁止
	if flg.ui then sliderdrag_stat(0) end

	-- 初期化
	sys.dlg = { dummy=dlg }
	flg.dlg = { name=name }
	if btn and btn.name then
		flg.dlg.ui  = btn.name
		flg.dlg.glp = btn.group
		flg.dlg.btn = btn.cursor
	end

	-- 音声を停止する
	systemsound("uistop")

	-- sys voice
--	local s = csv.sysse
--	if name and s[name] then sysvo(name) end

	-- チェックボックスは必ずoff
--	conf.dummy = 0

	-- ボタン描画
	csvbtn3("dlg", "600.1", csv.ui_yesno)	-- dialog
	local t = btn.dlg.p.bg
--	lyc2{ id="600.0", file=(init.black), alpha="128"}
--	lyc2{ id="600.0", width=(game.width), height=(game.height), color="F47AAA", alpha="128"}

	-- text
	local v = getBtnInfo("message")
	local y = v.y
	local x = v.x

	-- okボタン処理
	local b = "bt_yes"
	local path = game.path.ui.."mw/"..name
	lyc2{id=(v.idx), file=(path), top=(y),left=(x)}
	flg.dlg.autocursor = b

--	yesno_active()
	setonpush_ui()
	systween2{ id="600.1", time=(init.ui_fade)}
	tag{"call", file="system/ui.asb", label="dialog"}
end
----------------------------------------
-- yesをアクティブにする
function yesno_active()
	local time = init.ui_fade
	tween{ id="600", alpha="0,255", time=(time)}
	flip()
	if game.os == "windows" and conf.mouse == 1 then
		local nm = flg.dlg.autocursor or "bt_yes"
		mouse_autocursor(nm, time)
	else
		eqwait(time)
	end
	eqtag{"lytweendel", id="600"}
end
----------------------------------------
-- dialog checkbox
function yesno_checkbox(e, p)
	check_change("bt_check")
end
----------------------------------------
-- dialog click
function yesno_click(e, p)
	local ret = 0
	local bt = btn.cursor
	if not bt then

	elseif bt == "bt_check" then
		yesno_checkbox(e, p)
	else
		if bt == "bt_yes" then
			se_yes()

			-- 状態保存
			local a = sys.dlg.dummy
			local n = flg.dlg.name
			conf["dlg_"..n] = a
--			if n == "save" then conf.dlg_save2 = a end		-- saveは２種類あるのでどちらも有効にする
--			if n == "load" then temp_dialog = "dlg_"..n end	-- loadはロード後に書き込む
--			if a == 1 then		conf.dlg_all = 0 end		-- 何か１つでも有効であればconfigをoffにする
			asyssave()

			ret = 1

		elseif bt == "bt_no" then
			se_cancel()

		elseif bt == "bt_ok" then
			se_ok()

		end
		fn.set(ret)
		yesno_exit()
	end
end
----------------------------------------
-- dialog escape
function yesno_esc(e, p)
	se_cancel()
	if flg.dlg.name == 'qsave' then qsaveend(true) end
	fn.set(0)
	yesno_exit()
end
----------------------------------------
-- dialogを抜ける
function yesno_exit()
	ReturnStack()	-- 空のスタックを削除
--	message("通知", "dialogを閉じました")

	-- 画面を閉じる
	tag{"var", name="t.lua", data="dialog_return"}
	tag{"jump", file="system/ui.asb", label="return_ui"}
end
----------------------------------------
-- dialogを抜ける
function dialog_return()
	local name = flg.dlg.name
--	systween2{ id="600.1", zoom="100,50", time=(init.ui_fade)}
	systween2{ id="600.1", time=(init.ui_fade)}
	delbtn('dlg')
	e:tag{"lydel", id="600"}
	btn.name	= flg.dlg.ui	-- 戻す
	btn.group	= flg.dlg.glp
	btn.cursor	= flg.dlg.btn
	flg.dlg = nil
	sys.dlg = nil
	delonpush_ui()

	-- checkbox check
	if name == "load" or name == "qload" then
		local n = "dlg_"..name
		if conf[n] == 1 then
			temp_dialog = n
		end
	end

--	adv_btnreset()

	-- ui
	if flg.ui then
		sliderdrag_stat(1)		-- ドラッグ許可
		setonpush_ui()

	-- 選択肢
	elseif scr.select then
		sv.delpoint()
		systemsound("replay")
		setonpush_ui()
	else
		sv.delpoint()
		systemsound("replay")
		autoskip_init()
	end
end
----------------------------------------
