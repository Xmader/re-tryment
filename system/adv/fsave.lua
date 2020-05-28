----------------------------------------
-- save / load共通
----------------------------------------
sv = {}
----------------------------------------
-- 現在のポインタを保存しておく
function sv.makepoint()
	if not sv.no then
		message("通知", "セーブ情報を保存しました")
		sv.no = 1		-- noを1で初期化しておく
		sv.fl = nil		-- quick flag
		tag{"takess"}	-- SSをメモリに保存
	end
end
----------------------------------------
function sv.delpoint()
	if sv.no then
		message("通知", "セーブ情報を削除しました")
	end
	sv.no = nil
end
----------------------------------------
-- noからファイル名を求める
function sv.makefile(no)
	local r
	local s = sys.saveslot[no]
	local m = game.savemax

	-- 番号をそのまま返す
	if init.save_moveno ~= "on" or no > m then
		r = init.save_prefix..string.format("%04d", no)

	-- slotから読み出す
	elseif s then
		r = s.file

	-- 新規作成
	elseif scr.savecom == "save" then
		if not sys.saveslot.check then sys.saveslot.check = {} end
		local c = sys.saveslot.count or 0
		c = c + 1
		if c <= m then
			sys.saveslot.count = c
		else
			-- slotを調べて空いてたらそこを使う
			for i=1, m do
				local s = init.save_prefix..string.format("%04d", i)
				if not sys.saveslot.check[s] then
					c = i
					break
				end
			end
		end
		r = init.save_prefix..string.format("%04d", c)
		sys.saveslot.check[r] = true
	end
	return r
end
----------------------------------------
-- セーブ存在チェック
function sv.checkopen(mode)
	local r = nil
	local s = sys.saveslot or {}
	if mode == "all" then
		r = s.last or s.quick or s.auto or s.cont
	elseif mode == "title" then
		r = s.last or s.auto
	else
		r = s[mode]
	end
	return not r
end
----------------------------------------
-- save
----------------------------------------
-- quicksave
function sv.quicksave()
	allkeyoff()
	sv.makepoint()
	if not flg.ui then systemsound("uistop") end	-- SE停止

	-- セーブ番号
	local no = sys.saveslot.quick or 0
	no = no + 1
	if no > init.qsave_max then no = 1 end
	sys.saveslot.quick = no
	sv.no = game.qsavehead + no
	sv.fl = true

	-- save
	scr.quicksave = true
	sv.exec = "qsaveend"
	e:tag{"jump", file="system/save.asb", label="save"}
end
----------------------------------------
-- qsave終了
function qsaveend(flag)
	if not scr.menu then
		sv.delpoint()
		if not flg.ui then systemsound("replay") end			-- SE再開
--		if not flag then info_qsaveload("qsave", true) end		-- 通知
	end
	scr.quicksave = nil
end
----------------------------------------
-- autosave
function sv.autosave()
	if not flg.autosave and not getExtra() and conf.asave == 1 then
		allkeyoff()
		sv.makepoint()

		-- セーブ番号
		local no = sys.saveslot.auto or 0
		no = no + 1
		if no > init.asave_max then no = 1 end
		sys.saveslot.auto = no
		sv.no = game.asavehead + no
		sv.fl = true

		-- save
		scr.autosave = true
		sv.exec = "asaveend"
		e:tag{"call", file="system/save.asb", label="save"}
	end
	flg.autosave = nil
end
----------------------------------------
-- autosave終了
function asaveend()
	sv.delpoint()
	scr.autosave = nil
	notify('オートセーブしました。')
end
----------------------------------------
-- save画面 / クリックされた
function sv.saveclick()
	allkeyoff()
	sv.no = flg.save.no
	sv.exec = "saveload_reload"
	e:tag{"jump", file="system/save.asb", label="save"}
end
----------------------------------------
-- suspend
function sv.suspend()
	allkeyoff()
	sv.makepoint()

	sv.no = init.save_suspend
	sv.exec = "suspend_exit"
	e:tag{"jump", file="system/save.asb", label="save"}
end
----------------------------------------
-- suspend
function suspend_exit()
	sv.go_exit()
end
----------------------------------------
-- 
----------------------------------------
-- save本体
function sv.save()
	local no   = sv.no or 1		-- save no
	local flag = sv.fl			-- quick flag
	local file = sv.makefile(no)

	----------------------------------------
	-- サムネイル作成
	local th = true
	if flag then
		if scr.autosave then th = init.asave_thumb == "on"		-- autosave のサムネイルを作る
		else				 th = init.qsave_thumb == "on" end	-- quicksaveのサムネイルを作る
	end

	-- evmask check
	if scr.evmask then th = nil end

	-- サムネイル作成
	if th then
		local t = csv.mw.savethumb			-- サムネイルサイズ
		
		e:tag{"savess", file=(file), width=(t.w), height=(t.h)}
		local t = csv.mw.savethumb_l			-- サムネイル大サイズ
		if t then e:tag{"savess", file=(file..'_l'), width=(t.w), height=(t.h)} end
	end

	----------------------------------------
	-- セーブ直前に表示されていたメッセージを保存
	local tx = "autosave"		-- 本文
	if not scr.autosave then
		local r = getSaveTextBlock(getTextBlock())	-- テキスト取得

		if r then
			tx = r
		else
			tx = ""
		end
	end
	----------------------------------------
	-- ロード判定用
	local bl = scr.ip.block		-- script block
	local ax = ast[bl]
	scr.ip.save = { text=(tx), txno=(ax.lang), crc=(ax.crc) }
	----------------------------------------
	-- suspend以外
	if no < init.save_suspend then

		-- 情報をスロットに保存する
		sys.saveslot[no] = {
			text  = tx,					-- セーブ時のテキスト
			title = sv.getsavetitle(),	-- セーブタイトル
			date  = get_unixtime(),		-- 現在時刻(unixtime)
			file  = file,				-- セーブしたファイル
			scfile = scr.ip.file, 		-- スクリプトファイル名
			evmask= scr.evmask,			-- HEVマスク
		}
		sys.saveslot.cont = no			-- 『続きから』で読み込む番号

		-- qsave / autosaveは実行しない
		if not flag then
			sys.saveslot.actv = flg.save.p1		-- 押されたボタン
			sys.saveslot.last = no				-- セーブされた番号
			sys.saveslot.page = flg.save.page	-- ページ保存
		end
	end

	----------------------------------------
	-- セーブ実行
	tag{"save", file=(file..".dat"), eq=1}
end---------------------------------
-- save完了後に呼ばれる
function sv.savenext()
	if sv.exec then
		_G[sv.exec]()
		sv.exec = nil
	end
	allkeyon()
end

----------------------------------------
-- セーブタイトル取得
function sv.getsavetitle()
	return scr and scr.adv and scr.adv.title or {}
end
----------------------------------------
-- 
----------------------------------------
-- qload開始
function sv.quickload()
	local no = game.qsavehead + sys.saveslot.quick
	if no then
--		message("通知", no, "をロードします")
		sv.load(no, {})
	end
end
----------------------------------------
-- load開始
function sv.loadclick()
	local no = flg.save.no
	if no then
		message("通知", no, "をロードします")
		sv.load(no, {})
	end
end
----------------------------------------
-- load本体
function sv.load(no, p)
	delImageStack()		-- cache delete
	sv.loadparam = { no, p }
	if p.mode ~= "cont" then
		e:tag{"call", file="system/ui.asb", label="load"}
	else
		e:tag{"call", file="system/ui.asb", label="load_cont"}
	end
end
----------------------------------------
function sv.loadstart()
	local no   = sv.loadparam[1]
	local file = sv.makefile(no)
	tag{"load", file=(file..".dat")}
end
----------------------------------------
-- 
----------------------------------------
-- 削除
function sv.delete()
	local no = sv.delparam
	local t  = isSaveFile(no)			-- セーブデータ確認
	if t then
		sv.deleteno(no)
		sv.delparam = nil
	end
end
----------------------------------------
-- noから削除
function sv.deleteno(no)
	message("通知", no, "番のセーブデータを削除しました")

	-- 実ファイルの削除
	if not game.truecs then
		local file = sv.makefile(no)
		local path = e:var("s.savepath")..'/'..file
		deleteFile(path..'.dat')
		deleteFile(path..'.png')
		local t = csv.mw.savethumb_l	-- サムネイル大サイズ
		if t then deleteFile(path..'_l.png') end
		if sys.saveslot.check then sys.saveslot.check[file] = nil end
	end
	sys.saveslot[no] = nil

	-- 最新ファイルの確認
	if no == sys.saveslot.last then sv.checknewfile() end

	-- 再描画
	saveload_reload()
	pssyssave()
end
----------------------------------------
-- 最新ファイルを更新する
function sv.checknewfile()
	local t = sys.saveslot
	if t then
		local max  = init.save_column * init.save_page
		local last = 0	-- last:最後にセーブしたもの
		local cont = 0	-- cont:continueで呼び出す
		local tmls = 0	-- time:最後にセーブしたもの
		local tmct = 0	-- time:continue
		for i, v in pairs(t) do
			if type(i) == "number" then
				local time = v.date

				-- last save
				if i < max and tmls < time then
					tmls = time
					last = i
				end

				-- continue
				if tmct < time then
					tmct = time
					cont = i
				end
			end
		end

		-- 書き込み
		sys.saveslot.last = last
		sys.saveslot.cont = cont
	end
end
----------------------------------------
-- 
----------------------------------------
-- セーブタイトル
function sv.savetitle(p)
	local tx = p.text
	scr.adv.title = p
	return 1
end
----------------------------------------
-- 抜ける
----------------------------------------
-- タイトルへ
function sv.go_title()
	if getExtra(true) then
		local nm = init.game_sceneexit or "scene"
		if nm == "scene" then
			tag{"jump", file="system/ui.asb", label="exscene_jumpend"}
		else
			appex = nil
			sys.extr = nil
			systemreset = true
			tag{"jump", file="system/ui.asb", label="go_title"}
		end
	else
		systemreset = true
		tag{"jump", file="system/ui.asb", label="go_title"}
	end
end
----------------------------------------
-- ゲーム終了
function sv.go_exit()
	if not gameexitflag then
		gameexitflag = true
		staffroll_reset()		-- staffroll中断
		tag{"jump", file="system/ui.asb", label="go_exit"}
	end
end
----------------------------------------
