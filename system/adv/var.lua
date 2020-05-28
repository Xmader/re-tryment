----------------------------------------
-- システム変数
----------------------------------------
os_no = { windows=1, android=2, ios=3, vita=4, ps4=5, switch=6 }
----------------------------------------
openui_table = {
		menu = { "menu_init",	"menu_reset",	"menu_close", },	-- menu
		mnal = { "mnal_init",	"mnal_reset",	"mnal_close", },	-- manual
		tips = { "tips_init",	"tips_reset",	"tips_close", },	-- tips
		blog = { "blog_init",	"blog_reset",	"blog_close", },	-- backlog
		sbck = { "sbck_init",	"sbck_reset",	"sbck_close", },	-- scene back
		save = { "save_init",	"save_reset",	"save_close", },	-- save
		load = { "load_init",	"save_reset",	"save_close", },	-- load
		favo = { "favo_init",	"save_reset",	"save_close", },	-- お気に入りボイス
		conf = { "conf_init",	"conf_reset",	"conf_close", },	-- config
--		ttl1 = { "title_init",	"title_reset",	"title_close", },	-- title
		flow = { "flow_init",	"flow_reset",	"flow_close", },	-- flowchart
		tbui = { "tbui_init",	"tbui_reset",	"tbui_close", },	-- tablet ui

		cgmd = { "extra_cg_init",	"extra_cg_reset",	"extra_cg_close", },	-- cg mode
		scen = { "extra_scene_init","extra_scene_reset","extra_scene_close", },	-- scene mode
		bgmd = { "extra_bgm_init",	"extra_bgm_reset",	"extra_bgm_close", },	-- bgm mode
		ctmd = { "extra_cat_init",	"extra_cat_reset",	"extra_cat_close", },	-- cat mode
}
----------------------------------------
-- ■ セーブされる変数の登録
scr = {}	-- スクリプトで使用する変数 / local
log = {}	-- スクリプトで使用する変数 / local backlog専用
gscr = {}	-- スクリプトで使用する変数 / global
sys = {}	-- システムで使用する変数	/ global
--conf = {}	-- config data				/ global
----------------------------------------
-- ■ セーブされない変数
init = {}	-- システム設定
tags = {}	-- タグフィルタ
e:setTagFilter(tags)
----------------------------------------
-- ■テーブルの初期化
----------------------------------------
function vartable_init()
	----------------------------------------
	-- ■セーブされる - global
	----------------------------------------
	-- システムデータ
	if not scr	then scr = {} end	-- スクリプトで使用／セーブされる
	if not log	then log = {} end	-- バックログデータ／セーブされる
	if not gscr	then gscr = {} end	-- グローバルテーブル
	if not sys	then sys = {} end	-- システムテーブル
	----------------------------------------
	-- 変数
	if not scr.vari		then scr.vari	 = {} end	-- f.変数
	if not gscr.vari	then gscr.vari	 = {} end	-- sf.変数
	----------------------------------------
	-- 見たフラグ
	if not gscr.bg		then gscr.bg	 = {} end	-- BGを見たフラグ
	if not gscr.ev		then gscr.ev	 = {} end	-- EVを見たフラグ
	if not gscr.evset	then gscr.evset	 = {} end	-- EVセットを見たフラグ
	if not gscr.bgm		then gscr.bgm	 = {} end	-- BGMを再生したフラグ
	if not gscr.tips 	then gscr.tips 	 = {} end   -- tips
	if not gscr.movie	then gscr.movie	 = {} end	-- 動画を見たフラグ
	if not gscr.scr		then gscr.scr	 = {} end	-- スクリプトを見たフラグ
	if not gscr.scene	then gscr.scene	 = {} end	-- シーンを見たフラグ
	if not gscr.select	then gscr.select = {} end	-- 選択肢の既読テーブル
	if not gscr.aread	then gscr.aread  = {} end	-- 既読フラグ
	-- Vita
--	if not gscr.trophy	then gscr.trophy = {} end	-- トロフィー管理
	----------------------------------------
	-- ADV
	if not gscr.adv		then gscr.adv	 = {} end	-- ADV汎用
--	if not gscr.adv.name	then gscr.adv.name = {} end	-- 名前テーブル
	if not scr.adv		then scr.adv	 = {} end	-- ADV汎用
	if not scr.mw		then scr.mw	 	= {} end	-- MW
	if not scr.se		then scr.se	 	= {} end	-- SE
	if not scr.bgm		then scr.bgm 	= {} end	-- BGM
	if not scr.mbgm		then scr.mbgm 	= {} end	-- BGM
	if not scr.lvo		then scr.lvo	= {} end	-- loop voice
	if not scr.blj		then scr.blj 	= {} end	-- BLJ
	----------------------------------------
	-- SAVE/LOAD
	if not sys.saveslot then sys.saveslot = {} end
	----------------------------------------
	-- ■セーブされる - local
	scr.file = ""

	-- stack初期化
	initVariStack("varistack")
	initVariStack("bselstack")

	-- reset対策
	scr.clickjump= nil

	----------------------------------------
	-- ■セーブされない
	adv_flagreset()		-- ADVフラグリセット
end
----------------------------------------
-- ■ セーブされない
----------------------------------------
-- システム変数
----------------------------------------
quake_idtable = {
	al = '1',
	gr = '1.0',
	mw = init.mwid or '1.80',
}
----------------------------------------
-- 文字装飾
textDecoTable = {
	["11"] = { y=0, x=0, b=0, k=0, s="outline,shadow" },	-- 影＋縁
	["10"] = { y=1, x=0, b=1, k=1, s="outline" },			-- 縁
	["01"] = { y=3, x=1, b=1, k=2, s="shadow" },			-- 影
	["00"] = { y=4, x=1, b=2, k=3, s="single" },			-- なし
}
----------------------------------------



----------------------------------------
--[[
ease_table = {
	[0]  = nil,					-- easeLinear
	[1]  = "easeout_quad",		-- easeOutSine
	[2]  = "easeout_quad",
	[3]  = "easeout_cubic",
	[4]  = "easeout_quart",
	[5]  = "easeout_quint",
	[6]  = "easeout_expo",
	[7]  = "easeout_circ",
	[8]  = "easeout_elastic",
	[9]  = "easeout_back",
	[10] = "easeout_bounce",
	[-1] = "easein_quad",		-- easeInSine
	[-2] = "easein_quad",
	[-3] = "easein_cubic",
	[-4] = "easein_quart",
	[-5] = "easein_quint",
	[-6] = "easein_expo",
	[-7] = "easein_circ",
	[-8] = "easein_elastic",
	[-9] = "easein_back",
	[-10]= "easein_bounce",
}
----------------------------------------
voice_man = {

	S998 = true,
--	S999 = true,
}
----------------------------------------
-- stg mode
STGmodeTable = {
	{ waku="CutFrame1", mask="mask01", [960]={ x="0"  , y="0" , w="320" , h="544"}, [1280]={ x="0"  , y="0"  , w="427" , h="720"}, [1920]={ x="0"   , y="0"  , w="640" , h="1080"}, },	-- x960="0"  , y960="0" , x1280="0"  , y1280="0"  , x1920="0"   , y1920="0" },
	{ waku="CutFrame1", mask="mask01", [960]={ x="320", y="0" , w="320" , h="544"}, [1280]={ x="426", y="0"  , w="427" , h="720"}, [1920]={ x="640" , y="0"  , w="640" , h="1080"}, },	--x960="320", y960="0" , x1280="426", y1280="0"  , x1920="640" , y1920="0" },
	{ waku="CutFrame1", mask="mask01", [960]={ x="640", y="0" , w="320" , h="544"}, [1280]={ x="852", y="0"  , w="427" , h="720"}, [1920]={ x="1280", y="0"  , w="640" , h="1080"}, },	--x960="640", y960="0" , x1280="853", y1280="0"  , x1920="1280", y1920="0" },
	{ waku="CutFrame3", mask="mask03", [960]={ x="0"  , y="95", w="1280", h="200"}, [1280]={ x="0"  , y="127", w="1280", h="200"}, [1920]={ x="0"   , y="190", w="1920", h="200"}, },	--x960="0"  , y960="95", x1280="0"  , y1280="127", x1920="0"   , y1920="190" },
	[960]=6, [1280]=10, [1920]=14,		-- 謎の固定値
}
----------------------------------------
-- glay除外リスト
notGlayTable = {
	BLACK  = true,
	WHITE  = true,
}
]]
----------------------------------------
csvidtbl = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 24, 25, 26, 27, 28, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39 }
----------------------------------------
