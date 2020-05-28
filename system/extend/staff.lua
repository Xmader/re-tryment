-- staff roll
----------------------------------------
function staffroll(p)
	estag("init")
	estag{"autoskip_stop", true}	-- auto/skip保存して停止
	estag{"msgoff"}
	estag{"autoskip_ctrl"}			-- ctrlskip off
	estag{"delImageStack"}			-- cache delete
	estag{"exskip_stop"}			-- debugskip停止
	estag{"autoskip_disable"}		-- autoskip disable
	estag{"staffroll2", p}
	estag()
end
----------------------------------------
function staffroll2(p)
	local tx = { ["瑠莉"]=1, ["美琴"]=2, ["悠"]=3, ["みなと"]=4 }
	local ch = p["0"] or p.ch
	local no = tx[ch]
	local f1 = "z0"..no.."_bg"
	local f2 = "z0"..no.."_tx"
	local b  = init.staff_bgm[no]
	stf = { time={}, no=(no), bgm=(b), file=(f1), text=(f2), ch=(ch) }
	if not gscr.staff then gscr.staff = {} end
	local ed = gscr.staff[ch]

	message("通知", ch, "エンディング", b, ed)

	-- 初期化
	local path = "system/extend/staff0"..no..".iet"
	reset_bg()

	-- 右クリックを制限
	e:tag{"keyconfig", role="1", keys=(csv.advkey.list.CANCEL)}
	if ed == 1 then
		e:tag{"setonpush", key="2", file=(path), label="staffroll_exit"}
	else
		e:tag{"setonpush", key="2", file="system/first.iet", label="last", call="1"}
	end

	-- bg
	lyc2{ id="staff.r.aa", file=(init.white)}
	tag{"lyprop", id="staff", intermediate_render="2", clip=("0,0,"..game.width..","..game.height)}

	tag{"call", file=(path), label="staffroll"}
end
----------------------------------------
-- staffroll実行
function staffroll_start(e, p)
	local s = stf

	-- back読み込み
	readImage("staff.r.bg", { path=":staff/", file=(s.file) })
	local v = ipt.base
	local y = -v.h + game.height
	e:tag{"lyprop", id="staff.r.bg", top=(y), visible="0"}
	stf.y = y
	stf.h = 0

	-- text読み込み
	readImage("staff.r.pg", { path=":staff/", file=(s.text) })
	local v = ipt.base
	local y = game.height
	e:tag{"lyprop", id="staff.r.pg", left=(p.left), top=(y), visible="0"}
	stf.py = y
	stf.ph = -v.h + game.height

	----------------------------------------
	-- sli
	local path = ":bgm/"
	local file = s.bgm
	local sli  = path..file..".ogg.sli"
	local z = csv.extra_bgm[file]
	if z then sli  = path..z[2]..".ogg.sli" end

	message("通知", sli)

	-- sliからtimeを読み込む
	local tbl = opensli(sli)		-- 44.1KHz
--	local tbl = opensli(sli, 48)	-- 48KHz

	for i, v in ipairs(tbl) do stf.time[i] = v end
	local t = stf.time
	local m = #t
	stf.stop = t[m]
	stf.stbg = t[m-2] - t[1]
	stf.stpg = t[m-1] - t[1]
	stf.bgm  = file
	stf.count = 1
	stf.input = gscr.staff[s.ch] or 0
end
----------------------------------------
-- bgm再生
function staffroll_bgm()
	local s = stf
	stf.head = e:now()					-- 時間
	bgm_play{ file=(s.bgm), loop="0" }	-- play
end
----------------------------------------
-- スクロール開始
function staffroll_scroll(e, p)
	local no = tn(p.page)
	local s = stf
	local t1 = p.time or s.stbg or s.stop
	local t2 = p.time or s.stpg or s.stop
	if no == 1 then
		tween{ id="staff.r.bg", sys=true, y=(s.y..","..s.h), time=(t1), ease="none"}
	else
		tween{ id="staff.r.pg", sys=true, y=(s.py..","..s.ph), time=(t2), ease="none"}
	end
end
----------------------------------------
function staffroll_exit()
	local ch = stf.ch
	e:tag{"lydel", id="1.0"}
	e:tag{"lydel", id="2.0"}
	e:tag{"lydel", id="cache"}
	e:tag{"delonpush", key="2"}		-- 右クリック
	e:tag{"keyconfig", role="1", keys=""}
	stf = nil

	-- シーンは何もしない
	if not getExtra() then
--		gscr.movie.ed = true		-- 既読フラグ
		gscr.staff[ch] = 1
		estag("init")
		estag{"asyssave"}
		estag{"msg_reset"}
		estag{"setonpush_init"}
		estag{"init_adv_btn"}
		estag{"autoskip_init"}
		estag{"restart_autoskip"}	-- autoskip再開
		estag()
	end
end
----------------------------------------
-- 無理やり中断させる
function staffroll_reset()
	if stf then
		e:tag{"lydel", id="staff"}
		e:tag{"delonpush", key="2"}		-- 右クリック
		e:tag{"keyconfig", role="1", keys=""}
		stf = nil
	end
end
----------------------------------------
function tags.edwait()
	local s = stf
	if s then
		local n = e:now() - s.head

		local time = s.time[s.count] - n
		stf.count = s.count + 1
--		message("time", time, n)
		eqwait{ time=(time), input=(s.input) }
--		eqwait{ se="0", time=(time), input=(s.input) }
	end
	return 1
end
----------------------------------------
