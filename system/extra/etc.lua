----------------------------------------
-- おまけ／動画とおもちゃ箱
----------------------------------------
-- 動画初期化
function exf.mvinit()

	if not appex.movi then appex.movi = {} end
	if not appex.movi[1] then appex.movi[1] = {} end

	-- 動画取得
	local tbl = {}
	for i, v in pairs(csv.extra_movie) do
		local no = tn(v[2])
		if no and no > 0 then tbl[no] = { file=i, no=(no), name=(v[3]) } end
	end

	-- 開放確認
	for i, v in pairs(tbl) do
		local fl = v.file
		table.insert(appex.movi[1], { file=(fl), name=(v.name), flag=(gscr.movie[fl]) })
	end
end
----------------------------------------
-- ページ生成
function exf.mvpage()
	local p, page, char = exf.getTable()
	local px = p.p

	-- ページ本体
	if px.pagemax then
		local mask = getBtnInfo("cg01")
		local path = game.path.ui
		for i=1, px.pagemax do
			local mv = px[char][i]
			local nm = "cg"..string.format("%02d", i)
			local id = getBtnID(nm)
			if mv.flag then
				lyc2{ file=(":thumb/"..mv.file), id=(id..".-1"), x=(px.tx), y=(px.ty)}
			else
				lyc2{ file=(path..mask.file), id=(id..".-1"), clip=(mask.clip_c)}
			end
		end
	end

	-- char
	setBtnStat("page01", 'c')
	setBtnStat("page02", 'c')
	setBtnStat("page03", 'c')
	setBtnStat("page04", 'c')
	setBtnStat("page05", 'c')
	tag{"lyedit", id=(getBtnID("page01")..".0"), mode="gray"}
	tag{"lyedit", id=(getBtnID("page02")..".0"), mode="gray"}
	tag{"lyedit", id=(getBtnID("page03")..".0"), mode="gray"}
	tag{"lyedit", id=(getBtnID("page04")..".0"), mode="gray"}
end
----------------------------------------
-- 
----------------------------------------
-- 動画再生
function exf.playmovie(no)
	flg.btnstop = true
	local p, pg, ch = exf.getTable()
	local z = p.p[ch][no]

	-- ムービー再生
	if z.name == "mv" then
		local path = game.path.movie
		local file = z.file
		local exp  = game.movieext

		local key = "1"
		for k, v in pairs(csv.advkey.list.MWCLICK) do
			key = key..','..k
		end
		e:tag{"keyconfig", role="0", keys=(key)}

		local time = init.ui_fade
		allsound_stop{ tile=(time) }
		lyc2{ id="600", file=(init.black)}
		uitrans(time)

		eqtag{"video", file=(path..file..exp), skip=(1)}
		eqtag{"keyconfig", role="0", keys="124"}
		eqtag{"jump", file="system/ui.asb", label="cgviewer_exit"}
	else
		eqtag{"call", file="system/ui.asb", label="movie_staffroll"}
	end
end
----------------------------------------
-- staffroll
function movie_staffroll()
	staffroll{}
end
----------------------------------------
-- staffroll exit
function movie_staffroll_exit()
	flg.btnstop = nil
	exf.bgmrestart()	-- bgm再開
	setonpush_ui()		-- 念のためキー設定
end
----------------------------------------
-- ひみつのおもちゃ箱
----------------------------------------
-- 
function exf.bxpage()
	if tn(get_eval("g.seri")) == 0 then setBtnStat('box01', 'd') end
	if tn(get_eval("g.aken")) == 0 then setBtnStat('box02', 'd') end
	if tn(get_eval("g.mimi")) == 0 then setBtnStat('box03', 'd') end
	if tn(get_eval("g.yuka")) == 0 then setBtnStat('box04', 'd') end

	-- char
	setBtnStat("page01", 'c')
	setBtnStat("page02", 'c')
	setBtnStat("page03", 'c')
	setBtnStat("page04", 'c')
	setBtnStat("page05", 'c')
	tag{"lyedit", id=(getBtnID("page01")..".0"), mode="gray"}
	tag{"lyedit", id=(getBtnID("page02")..".0"), mode="gray"}
	tag{"lyedit", id=(getBtnID("page03")..".0"), mode="gray"}
	tag{"lyedit", id=(getBtnID("page04")..".0"), mode="gray"}
end
----------------------------------------
-- 再生
function exf.clickbox(no)
	local tbl = {
		{ file=":sysse/ser/ser_special", btn="box01" },
		{ file=":sysse/ake/ake_special", btn="box02" },
		{ file=":sysse/mim/mim_special", btn="box03" },
		{ file=":sysse/yuk/yuk_special", btn="box04" },
	}

	-- 再生
	local v = tbl[no]
	if v then
		se_ok()
		flg.btnstop = true
		local t = getBtnInfo(v.btn)
		lyc2{ id="500.zz", file=(game.path.ui..t.file), x=(t.x), y=(t.y), clip=(t.clip_c)}
		flip()

		-- bgm音量を下げる
		local vol = conf.bgmvoice
		if conf.bgmvfade == 1 and vol > 0 and vol < 100 then
			e:tag{"sfade", time=(init.bgm_voicein), gain=(vol.."0")}
		end

		local id = 910
		seplay(id, v.file..game.soundext, {})
		tag{"setonsoundfinish", id=(id), handler="calllua", ["function"]="exf.clickbox_end", btn=(v.btn)}
		eqwait{ se=(id) }
		eqtag{"calllua", ["function"]="exf.clickbox_end", id=(id), btn=(v.btn)}
	end
end
----------------------------------------
-- 再生終了
function exf.clickbox_end(e, p)
	flg.btnstop = nil
	tag{"sestop", id=(p.id)}

	-- bgm音量を戻す
	if conf.bgmvfade == 1 then
		e:tag{"sfade", time=(init.bgm_voiceout), gain="1000"}
	end

	se_cancel()
	tag{"lydel", id="500.zz"}
	flip()
end
----------------------------------------
