----------------------------------------
-- 動画再生
----------------------------------------
-- 初期化
function movie_init(p)
	scr.movie = p

	-- androidの場合はセーブする
	if game.trueos == "android" then
		e:tag{"var", name="save.systemtable", data=(pluto.persist({}, scr))}
	end

	-- 一旦asbを経由しておく
	e:tag{"call", file="system/script.asb", label="movie_play"}
end
----------------------------------------
-- auto/skip保存して停止
function movie_autoskip()
	if not getTitle() then
		autoskip_stop(true)
		autoskip_disable()
	end
end
----------------------------------------
-- 再生本体
function movie_play()
	local p    = scr.movie
	local file = p.file

	message("通知", file, "を再生します")

	-- 登録
	-- path
	local n = "movierename_"..file
	if init[n] then file = init[n] end
	local path = game.path.movie..file..game.movieext
	message(game.path.movie..file.."_"..conf.language..game.movieext)
	if conf.language ~= "ja" and e:isFileExists(game.path.movie..file.."_"..conf.language..game.movieext) then path = game.path.movie..file.."_"..conf.language..game.movieext end
	-- 停止キー
	local ky = getKeyString("CANCEL")

	-- 再生
	
	if not gscr.movie[file] then 
		gscr.movie[file] = true 
		tag{"keyconfig", role="1", keys=(ky)}
		tag{"video", file=(path), skip="0"}
	else
		tag{"keyconfig", role="1", keys=(ky)}
		tag{"video", file=(path), skip="2"}
	end
end
----------------------------------------
-- 終了処理
function movie_play_exit()
	e:tag{"var", name="save.systemtable", system="delete"}	-- android用
	e:tag{"keyconfig", role="1", keys=""}
	e:tag{"lydel", id="2"}
	scr.movie = nil

	if not getTitle() then
		autoskip_init()
		restart_autoskip()
	end
end
----------------------------------------
-- 
----------------------------------------
-- ogv
function ogv_play(id, p)
	local file = p.file
	local path = game.path.movie..file
	local loop = p.loop

	-- se
	local sefl = ":se/"..file..game.soundext
	if isFile(sefl) then
		
	end

	-- movie
	tag{"video", id=(id), file=(path..".ogv"), loop=(loop), eq=1}
end
----------------------------------------
