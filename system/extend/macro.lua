----------------------------------------
-- 
----------------------------------------
----------------------------------------
-- autosave
function exautosave()
	if conf.asave == 1 and not flg.autosave then
--		message("通知", "autosave")
		scr.autosave = true
		sv.quicksave()
	end
	flg.autosave = nil
end

----------------------------------------
-- 
----------------------------------------
function uiopenanime()
--	e:tag{"lyprop", id="500", anchorx=(game.centerx), anchory=(game.centery)}
--	systween{ id="500", zoom="200,100", time=(init.ui_fade)}
end
----------------------------------------
function uicloseanime(tm, name)
--	e:tag{"lyprop", id="500", anchorx=(game.centerx), anchory=(game.centery)}
--	flip()

--	local time = tm or init.ui_fade
--	if name == "small" then
--		systween{ id="500", zoom="100,50", time=(time)}
--	else
--		systween{ id="500", zoom="100,200", time=(time)}
--	end
end
-- 
----------------------------------------
-- 画面上に透明なボタンを追加する
function tags.addbtn(e, p)
	local id = "2"
	local cl = p.clip
	local ur = p.url
	if cl and ur then
		flg.addbtn = { url=(ur) }
		local ax = explode(",", cl)
		lyc2{ id=(id), x=(ax[1]), y=(ax[2]), width=(ax[3]), height=(ax[4]), color="00ff0000"}
		lyevent{ id=(id), key=(1), name="addbtn", over="addbtn_over", out="addbtn_out"}
	else
		lydel2(id)
		flg.addbtn = nil
	end
	flip()
	return 1
end
----------------------------------------
function addbtn_over()
	if flg.addbtn then flg.addbtn.over = true end
end
----------------------------------------
function addbtn_out()
	if flg.addbtn then flg.addbtn.over = nil end
end
----------------------------------------
