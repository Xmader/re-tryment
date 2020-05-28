----------------------------------------
-- キャッシュ
----------------------------------------
-- キャッシュ設定を取得
function checkCacheSize()
-- large  : 全ファイル
-- middle : 定期的に開放する
-- small  : 最小限
-- none   : キャッシュしない
	local r = init.system.autocache
	if r == "none" then r = nil end
	if flg.exskip  then r = nil end		-- debugskip
	return r
end
----------------------------------------
-- cache stackにセット
function setImageStack(px)
	if checkCacheSize() then
		if not cachebuff then cachebuff = {} end
		if cachebuff[px] then return end			-- 既に載ってる

		-- 自動整理
		local f = flg.cachefiles or 0
		local m = init.system.cachemax
		if m and m < f then
			local tbl = { [":ev/"]=1, [":sd/"]=1, [":cg/"]=1 }
			local del = 0
			for k, v in pairs(cachebuff) do
				local s = k:sub(1, 4)
				if tbl[s] then
					e:unbindSurface(k)
					cachebuff[k] = nil
					del = del + 1
				end
			end
			if del > 0 then
				message("通知", "cacheを整理しました")
				f = f - del
			end
		end

		-- cache
--		message("cache", px)
		local c = flg.cachecount or 0
		flg.cachecount = c + 1
		flg.cachefiles = f + 1
		cachebuff[px] = true
		e:bindSurfaceAsync(px)
	end
end
----------------------------------------
-- cache stackを削除
function delImageStack(flag)
	local sz = checkCacheSize()
	if sz and (not flag or sz ~= "large") then
		e:clearSurfaceLoadQueue()		-- 読み込み停止
		local c = cachebuff or {}
		local f = nil
		for i, v in pairs(c) do
--			message("del", i)
			e:unbindSurface(i)
			f = true
		end
		if f then message("通知", "cacheを削除しました", nm) end
		cachebuff = nil
		flg.cachecount = nil
		flg.cachefiles = nil

		-- autocache
		if flag and sz ~= "large" then
			autocache()
		end
	end
end
----------------------------------------
-- game data cache / キャッシュ待ち
--[[
function waitImageCache()
	local sz = checkCacheSize()
	if sz and sl ~= "large" then
		local c = flg.cachecount or 0
		if c > 0 then
			flg.imageCacheStart = true	-- ローディング待機フラグを立てる
			e:setScriptStatus(4)		-- STOP_NO_INPUTステータスに遷移
		end
	end
	flg.cachecount = nil
end
]]
----------------------------------------
-- game data cache / stack
function stackImageCache(p)
	local sz = checkCacheSize()
	if sz then
		local path = p.path
		local file = anyCheck(p)
		if not path or not file then return end

		----------------------------------------
		-- ipt
		local sw = {

		--------------------------------
		-- 2048px分割
		cut = function()
			for i, v in ipairs(ipt) do
				setImageStack(path..v.file)
			end
		end,

		--------------------------------
		-- 差分
		diff = function()
			setImageStack(path..ipt.base[1])
			for i, v in ipairs(ipt) do
				setImageStack(path..v.file)
			end
		end,

		--------------------------------
		-- 全画面アニメーション
		anime_full = function(p)
			for i, v in ipairs(ipt) do
				if v[1] then setImageStack(path..v[1]) end
			end
		end,

		}

		----------------------------------------
		-- read
		if not cachebuff then cachebuff = {} end
		local c  = cachebuff
		local px = path..file
		local nm = p[1]
		if nm == "bg" then
			if file == "black" then

			elseif e:isFileExists(px..'.ipt') then
				ipt = nil
				e:include(px..'.ipt')
				local md = ipt and ipt.mode
				if md and sw[md] then sw[md](p) end
			else
				setImageStack(px)
			end

		elseif nm == "fg" then
			local tbl = { "face", "ex01", "ex02", "ex03", "ex04" }
			local ext = game.fgext
			local m = tn(p.mode)

			-- body
			if m >= 2 then
				local fl = p.fl
				if fl then setImageStack(path..fl..ext) end

				-- face
				if sz ~= "small" then
					for i, v in ipairs(tbl) do
						if p[v] then
							setImageStack(path..p[v]..ext)
						end
					end
				end
			end

			-- mw face
			if sz ~= "small" and (m == 1 or m == 3) then
				local file = p.file:gsub("_[bnz][c12]", "_no")
				local head = file:gsub("_no", "_fa"):sub(1, 7)
				local path = p.path:gsub(":fg", ":fa"):gsub("/[bnz][co12]/", "/")
				setImageStack(path..file..ext)

				for i, v in ipairs(tbl) do
					if p[v] then
						setImageStack(path..p[v]..ext)
					end
				end
			end

		elseif nm == "fgf" then
			setImageStack(file)
		else
			dump(p)
		end
	end
end
----------------------------------------
-- 自動キャッシュ
----------------------------------------
function autocache(flag)
	local sz = checkCacheSize()
	if sz then
		if debug_flag then debugcachetime = e:now() end

		-- キャッシュを空にしておく
		if flag then
--			e:clearSurfaceLoadQueue()
			delImageStack()
		end

		-- 現在位置から読み込んでいく
		local b = scr.ip.block
		local c = scr.ip.count or 1
		if c > 1 then
			c = c + 1
			if not ast[b][c] then
				b = b + 1
				c = 1
			end
		end
		for i=b, #ast do
			local fl = nil
			if not ast[i] then
				break
			else
				local sw = {
					select  = function() fl = true end,
					gotitle = function() fl = true end,
					excall  = function() fl = true end,
					exreturn= function() fl = true end,

					cacheclear = function()
						if sz ~= "large" then fl = true end
					end,

					bg = function(v) stackImageCache(v) end,
					fg = function(v) stackImageCache(v) end,
					fgf= function(v)
						local b = v.bg
						if b then
							stackImageCache{"fgf", path="", file=(b)}
						end
					end,
				}

				-- block内を検索
				for k, v in ipairs(ast[i]) do
					local nm = v[1]
					if c > 1 and c > k then

					elseif sw[nm] then
						sw[nm](v)
						if fl then break end
					end
				end
				c = 1

				-- delay
				local d = ast[i].delay
				if not fl and d then
					for k, v in pairs(d) do
						for j, z in ipairs(v) do
							local nm = z[1]
							if sw[nm] then
								sw[nm](z)
								if fl then break end
							end
						end
						if fl then break end
					end
				end
			end
			if fl then break end
		end
	end
end
----------------------------------------
-- UIキャッシュ
----------------------------------------
-- ■ 起動時に１回だけ読み込まれる / ui先読み
function system_cache()
	local c = csv.cache and csv.cache.system
	if c then
		for i, path in ipairs(c) do
			local s = getChacePath(path)
--			message("cache", s)
			e:bindSurfaceAsync(s)
		end
		csv.cache.system = nil
	end
end
----------------------------------------
-- ■ タイトル画面用ui先読み
function title_cache()
	local c = csv.cache and csv.cache.title
	if c and not titlecache then
		message("通知", "title ui cache")
		for i, path in ipairs(c) do
			local s = getChacePath(path)
--			message("cache", s)
			e:bindSurfaceAsync(s)
			titlecache = true
		end
	end
end
----------------------------------------
-- title cacheを削除
function title_cachedelete()
	local c = csv.cache and csv.cache.title
	if c and titlecache then
		message("通知", "title ui cacheを削除しました")
		for i, path in ipairs(c) do
			local s = getChacePath(path)
			e:unbindSurface(s)
		end
		titlecache = nil
	end
end
----------------------------------------
-- title cache完了を待つ
function title_cachewait()
	flg.imageCacheStart = true	-- ローディング待機フラグを立てる
	e:setScriptStatus(4)		-- STOP_NO_INPUTステータスに遷移
end
----------------------------------------
-- パス変換
function getChacePath(path)
	return path:gsub("<ui>", game.path.ui)
end
----------------------------------------
--
----------------------------------------
-- vita専用
----------------------------------------
--
function vitaCache()
	local no = os_no[game.os]
	local file = scr.ip.file
	local path = init.os_path[no]..init.vcache_path..file..'.tbl'

	-- tblがあれば読み込み
	if game.ps and e:isFileExists(path) then
		message("通知", file, 'をキャッシュしています')

		e:include(path)
		e:tag{"call", file="system/script.asb", label="vitacache"}
	else
		fct = nil
	end
end
----------------------------------------
function vitaCacheMain()
	if fct then
		tag{"lydel", id="cache"}
		local tbl = {
			"0,160,40,100",
			"0,160,80,100",
			"0,160,120,100",
			"0,160,160,100",
			"0,160,200,100",
			"0,160,240,100",
			"0,160,280,100",
			"0,160,320,100",
		}
		local max = table.maxn(fct)
		local ctm = max / 8
		local ct = 0
		local cx = 1
		local fl = game.os == 'vita'
		for i, v in ipairs(fct) do
--			message("cache", v)
			lyc2{ id=("cache."..i), file=(v), eq=true}
--[[
			if fl and i > ct then
				tag{"lyprop", id="cache", visible="0", eq=true}
				tag{"lyprop", id="zzlogo.zcat", visible="1", clip=(tbl[cx]), eq=true}
				flip2()
				wt(0, true)
				cx = cx + 1
				ct = ct + ctm
			end
]]
		end
		tag{"lyprop", id="cache", visible="0", eq=true}
--		tag{"lyprop", id="zzlogo.zcat", visible="0", eq=true}
	end
end
----------------------------------------
-- font cache
----------------------------------------
function font_cache()
	local path = init.system.ui_path..init.fcache_path
	if e:isFileExists(path..'index.dat') and not fontcacheflag then
		message("通知", 'フォントをキャッシュします')
		e:restoreFontCache(path)
		fontcacheflag = true
	end

	base_fontcache()
end
----------------------------------------
-- font本体を読み込んでおく
function base_fontcache()
	message("通知", 'フォント本体をキャッシュします')
	for i=1, 10 do
		local name = "font"..string.format("%02d", i)
		if init[name] then
			local id = "basefont."..name
			message("cache", name, init[name])
			e:tag{"chgmsg", id=(id), layered="1"}
			e:tag{"font", face=(init[name]), size="12", left="0", top="0", width="400", height="80"}
			e:tag{"print", data="　"}
			e:tag{"/chgmsg"}
			e:tag{"lyprop", id=(id), top="-200"}
		end
	end
end
----------------------------------------
