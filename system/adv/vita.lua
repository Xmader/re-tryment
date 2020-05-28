----------------------------------------
-- Vita専用システム
----------------------------------------
tipsRatioMax = 121	-- Tips最大数
----------------------------------------
--	gscr.trophy{}
--	comp	=  1,	-- 全トロフィー獲得（手動登録しない）
trophy_table = {
	cg10	=  1, cg20= 2, cg30= 3, cg40= 4, cg50= 5, cg60= 6, cg70= 7, cg80=8, cg90=9, cg100=10,
	ACT01	= 11,	-- Act.01終了
	ACT02	= 12,	-- Act.02終了
	ACT03	= 13,	-- Act.03終了
	TSUKUYO	= 14,	-- 月夜ルートに入った
	AZUSA	= 15,	-- 梓ルートに入った
	MADOKA	= 16,	-- まどかルートに入った
	ARISA	= 17,	-- 有紗ルートに入った
	HIJIRI	= 18,	-- 有紗ルートに入った
	ED_TSUKUYO	= 19,	-- 月夜ルートクリア
	ED_AZUSA	= 20,	-- 梓ルートクリア
	ED_MADOKA	= 21,	-- まどかルートクリア
	ED_ARISA	= 22,	-- 有紗ルートクリア
	ED_HIJIRI	= 23,	-- ひじりルートクリア
}
----------------------------------------
-- CG総枚数と各パーセントを取得しておく
----------------------------------------
function initCGTrophy()
	local max = 0
	for key, val in pairs(csv.extra_cgmode) do
		for k, v in pairs(val) do
			if type(v) == "string" and v ~= "" then max = max + 1 end
		end
	end

	-- CG達成率を開放する枚数を保存
	cgTrophy = {
		math.ceil(max/10),		-- 10%
		math.ceil(max/10 * 2),	-- 20%
		math.ceil(max/10 * 3),	-- 30%
		math.ceil(max/10 * 4),	-- 40%
		math.ceil(max/10 * 5),	-- 50%
		math.ceil(max/10 * 6),	-- 60%
		math.ceil(max/10 * 7),	-- 70%
		math.ceil(max/10 * 8),	-- 80%
		math.ceil(max/10 * 9),	-- 90%
		max						-- 100%
	}
end
----------------------------------------
-- 現在のCG枚数をカウント
function getCGCount()
	local cnt = 0
	for key, val in pairs(csv.extra_cgmode) do
		for k, v in pairs(val) do
			if type(v) == "string" and v ~= "" then
				if gscr.ev[v] then cnt = cnt + 1 end
			end
		end
	end
	message("通知", "取得したCG枚数 : "..cnt.." / "..cgTrophy[10].."枚")
	return cnt
end
----------------------------------------
-- CG達成率をチェック
function checkCGTrophyRate(no)
	local c = nil
	for i, v in ipairs(cgTrophy) do 
		if v == no then
			message("通知", "CG達成率 "..i.."0%")
			setTrophy("cg"..i.."0")
		end
	end
end
----------------------------------------
-- 
----------------------------------------
-- トロフィー開放
function setTrophy(name)
	local no = trophy_table[name]
	if not no then
		error_message(name.."は不明なトロフィーです")
	elseif gscr.trophy[no] then
		message("通知", name.."は登録済みのトロフィーです")
		e:enqueueTag{"trophy", id=(no)}
	else
		message("TROPHY", name.."を開放しました")
		e:enqueueTag{"trophy", id=(no)}
		gscr.trophy[no] = true
	end
end
----------------------------------------
-- トロフィー開放タグ
function tags.setTrophy(e, param) setTrophy(param["0"]) return 1 end
function tags.checkTrophy(e, param) checkTrophy() return 1 end
----------------------------------------
-- トロフィー
function tags.getTrophy(e, param)
	e:tag{"trophy", id="-1"}
	e:tag{"var", name="t.result", ["system"]="get_trophy_status", id=(param["0"])}
	local p = e:var("t.result")

	if p == "-2" then
		error_message("トロフィーの取得に失敗しました:"..param["0"])
	elseif p == "-1" then
		message("通知", param["0"].."は登録中です")
	else
		checkTrophy()
	end
	return 1
end
----------------------------------------
-- トロフィーチェック
function checkTrophy()
--[[
	-- CG達成率
	local r = getCGratio()
		if r == 100 then  setTrophy("cg100")
	elseif r >=  90 then  setTrophy("cg90")
	elseif r >=  80 then  setTrophy("cg80")
	elseif r >=  70 then  setTrophy("cg70")
	elseif r >=  60 then  setTrophy("cg60")
	elseif r >=  50 then  setTrophy("cg50")
	elseif r >=  40 then  setTrophy("cg40")
	elseif r >=  30 then  setTrophy("cg30")
	elseif r >=  20 then  setTrophy("cg20")
	elseif r >=  10 then  setTrophy("cg10") end

	-- Tips達成率
--	local r = getTIPSratio()

	-- トロフィーフルコンプ
--	local r = getTROPHYratio()
-- プラチナトロフィーは自動的に登録されるので手動登録しない
--	if r == 100 then setTrophy("comp") end
]]
end
----------------------------------------
-- CG全トロフィーチェック
function checkCGTrophy()
	e:tag{"var", name="t.cg10", data="0"}
	e:tag{"var", name="t.cg20", data="0"}
	e:tag{"var", name="t.cg30", data="0"}
	e:tag{"var", name="t.cg40", data="0"}
	e:tag{"var", name="t.cg50", data="0"}
	e:tag{"var", name="t.cg60", data="0"}
	e:tag{"var", name="t.cg70", data="0"}
	e:tag{"var", name="t.cg80", data="0"}
	e:tag{"var", name="t.cg90", data="0"}
	e:tag{"var", name="t.cg100", data="0"}

	-- CG達成率
	local r = getCGratio()
	if r >=  10 and not gscr.trophy[trophy_table.cg10]  then e:tag{"var", name="t.cg10", data="1"} end
	if r >=  20 and not gscr.trophy[trophy_table.cg20]  then e:tag{"var", name="t.cg20", data="1"} end
	if r >=  30 and not gscr.trophy[trophy_table.cg30]  then e:tag{"var", name="t.cg30", data="1"} end
	if r >=  40 and not gscr.trophy[trophy_table.cg40]  then e:tag{"var", name="t.cg40", data="1"} end
	if r >=  50 and not gscr.trophy[trophy_table.cg50]  then e:tag{"var", name="t.cg50", data="1"} end
	if r >=  60 and not gscr.trophy[trophy_table.cg60]  then e:tag{"var", name="t.cg60", data="1"} end
	if r >=  70 and not gscr.trophy[trophy_table.cg70]  then e:tag{"var", name="t.cg70", data="1"} end
	if r >=  80 and not gscr.trophy[trophy_table.cg80]  then e:tag{"var", name="t.cg80", data="1"} end
	if r >=  90 and not gscr.trophy[trophy_table.cg90]  then e:tag{"var", name="t.cg90", data="1"} end
	if r == 100 and not gscr.trophy[trophy_table.cg100] then e:tag{"var", name="t.cg100", data="1"} end
end
----------------------------------------
-- CG達成率を取得
function getCGratio()
	local max = 0
	local cnt = 0
	for key, val in pairs(csv.extra_cgmode) do
		for k, v in pairs(val) do
			if type(v) == "string" and v ~= "" then
				if gscr.ev[v] then cnt = cnt + 1 end
				max = max + 1
			end
		end
	end
	local r = percent(cnt, max)
	message("達成率", "CG : "..cnt.." / "..max.." : "..r.."%")
	return r
end
----------------------------------------
-- Tips達成率を取得 / 仮実装
function getTIPSratio()
	local max = tipsRatioMax
	local cnt = 0
	for k, v in pairs(gscr.tips) do cnt = cnt + 1 end
	local r = percent(cnt, max)
	message("達成率", "Tips : "..cnt.." / "..max.." : "..r.."%")
	return r
end
----------------------------------------
-- Trophy達成率を取得
function getTROPHYratio()
	local max = tmaxn(trophy_table)
	local cnt = 0
	for k, v in pairs(trophy_table) do
		if gscr.trophy[v] then cnt = cnt + 1 end
	end
	local r = percent(cnt, max)
	message("達成率", "Trophy : "..cnt.." / "..max.." : "..r.."%")
	return r
end
----------------------------------------
