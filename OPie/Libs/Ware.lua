-- Writable Restricted Environment; see https://www.townlong-yak.com/addons/ware
local Ware, REV, ADDON, T = {}, 1, ...

local rpairs, rnext, type, setmetatable = rtable.pairs, rtable.next, type, setmetatable
local IsFrameWidget = C_Widget.IsFrameWidget
local simpleTypes = {number=1, string=1, boolean=1, frameref=1}
local prototype, emptyTable = newproxy(true), {}

local weakKeys_mt = {__mode="k"}
local handleRT_mt = {__mode="k"} -- + __index later
local ownerHandle = {}
local handleInfo  = setmetatable({}, weakKeys_mt)
local handleRT    = setmetatable({}, handleRT_mt)
local handleWAN   = setmetatable({}, weakKeys_mt)
local refHandle   = setmetatable({}, weakKeys_mt)
local refKey      = setmetatable({}, weakKeys_mt)
local rtHandle    = setmetatable({}, {__mode="kv"})
local newEnvHandle, SetAttribute, SetAttributeNoHandler do
	local INIT_SNIPPET = [=[--Ware_Init 
		__WARE = newtable()
		__WARE.r0, __WARE._nextWAN, __WARE._nextID = _G, "r1", 2
	]=]
	local OAC_SNIPPET = [=[--Ware_Delegate_OAC 
		local W = __WARE
		local t = W[name]
		if t then
			t[value] = self:GetAttribute("val")
		elseif name == "set" or name == "new" or name == "ref" then
			W[value][self:GetAttribute("key")] = name == "new" and newtable() or name == "ref" and W._ref or self:GetAttribute("val")
		elseif name == "idx" then
			W._ref = value == nil and W or W._ref[value]
		elseif name == W._nextWAN then
			W[name], W._nextWAN, W._nextID = value == "nat" and newtable() or W._ref, "r" .. W._nextID, W._nextID + 1
		elseif name == "clr" and value:byte(1) ~= 95 and value ~= "r0" then
			W[value], W._ref = nil, nil
		elseif name == "exe" and value == nil then
			wipe(W._x)
		elseif name == "exe" then
			local x, PACK_SNIPPET = W._x and wipe(W._x) or newtable()
			for i=1, self:GetAttribute("n") do
				local ai = self:GetAttribute("a" .. i)
				x[i] = ai == nil and x or ai
			end
			W._x, PACK_SNIPPET = x, [==[--Ware_Pack 
				local x, n = __WARE._x, select("#", ...)
				if n < #x then wipe(x) end
				x[0], x[1], x[2], x[3], x[4] = n, ...
				for i=5, n, 4 do
					x[i], x[i+1], x[i+2], x[i+3] = select(i, ...)
				end
			]==]
			owner:Run(PACK_SNIPPET, owner:RunFor(self:GetFrameRef("other") or owner, value, unpack(x)))
		end
	]=]
	function handleRT_mt:__index(h)
		local hi = handleInfo[h]
		local env = hi and hi[4] and GetManagedEnvironment(hi[4])
		if env then
			handleRT[h] = env
		end
		return env
	end
	local function initDelegate(hi, idx)
		if idx ~= 1 or InCombatLockdown() then
			return nil
		end
		local h, owner, env, delegate = hi[3], hi[4]
		SecureHandlerExecute(owner, INIT_SNIPPET)
		env = GetManagedEnvironment(owner)
		delegate = CreateFrame("Frame", nil, nil, "SecureFrameTemplate")
		SecureHandlerWrapScript(delegate, "OnAttributeChanged", owner, OAC_SNIPPET)
		rtHandle[env], handleRT[h] = h, env
		if not SetAttribute then
			SetAttribute, SetAttributeNoHandler = delegate.SetAttribute, delegate.SetAttributeNoHandler
		end
		hi[1], hi[2], hi[4] = delegate, env.__WARE, nil
		setmetatable(hi, nil)
		return delegate
	end
	local handleInfoMeta = {__index=initDelegate}
	function newEnvHandle(owner)
		local h = newproxy(prototype)
		ownerHandle[owner], handleWAN[h], handleInfo[h] = h, "r0", setmetatable({nil, nil, h, owner}, handleInfoMeta)
		return h
	end
end

local scratch = {}
local function checkRef(h)
	local ph, pk = refHandle[h], refKey[h]
	local rt = handleRT[ph]
	if rt and rt[pk] == handleRT[h] then
		return ph, pk
	end
end
local function canRefWithout(h, hx)
	local h1, h2, h3 = h, nil, h ~= hx and checkRef(h)
	if handleWAN[h] or handleWAN[h3] then
		return true
	end
	while h3 and h1 ~= h2 and h1 ~= h3 do
		h1 = refHandle[h1]
		h2 = h3 ~= hx and checkRef(h3)
		h3 = h2 ~= hx and checkRef(h2)
		if handleWAN[h2] or handleWAN[h3] then
			return true
		end
	end
end
local function wrapValue(h, v, k)
	local vh = rtHandle[v]
	if vh then
		if not handleWAN[vh] and (refHandle[vh] ~= h or refKey[vh] ~= k) and canRefWithout(h, vh) then
			refHandle[vh], refKey[vh] = h, k
		end
	elseif type(v) ~= "userdata" then
		return v
	elseif IsFrameHandle(v) then
		return GetFrameHandleFrame(v)
	else
		vh = newproxy(prototype)
		rtHandle[v], handleRT[vh], handleInfo[vh] = vh, v, handleInfo[h]
		refHandle[vh], refKey[vh] = h, k
	end
	return vh
end
local function hnext(h, k)
	local rt = handleRT[h]
	if rt then
		local nk, nv = rnext(rt, k)
		return nk, wrapValue(h, nv, nk)
	end
end
local function emplaceReference(h)
	local delegate, pwan = handleInfo[h][1], handleWAN[h]
	if pwan then
		SetAttribute(delegate, "idx", nil)
		SetAttribute(delegate, "idx", pwan)
		return delegate
	end
	local sn, snOdd, pwan = 1, true, nil
	local ps, ph, pk = h, checkRef(h)
	while pk and ph ~= ps do
		ps, snOdd = snOdd and ps or refHandle[ps], not snOdd
		scratch[sn], sn = pk, sn + 1
		pwan, ph, pk = handleWAN[ph], checkRef(ph)
		if pwan then
			scratch[sn], scratch[sn+1], sn = pwan, nil, sn + 2
			break
		end
	end
	for i=sn - 1, 1, -1 do
		if pwan then
			SetAttribute(delegate, "idx", scratch[i])
		end
		scratch[i] = nil
	end
	return pwan and delegate
end
local function allocWAN(h)
	local delegate, wan = emplaceReference(h), nil
	if delegate then
		wan = handleInfo[h][2]._nextWAN
		SetAttribute(delegate, wan, nil)
		handleWAN[h], refHandle[h], refKey[h] = wan, nil, nil
	end
	return wan
end
local freeWAN do
	local q, f = {}, CreateFrame("Frame")
	f:RegisterEvent("PLAYER_REGEN_ENABLED")
	f:SetScript("OnEvent", function()
		for i=InCombatLockdown() and 0 or #q, 2, -2 do
			freeWAN(q[i-1], q[i])
			q[i-1], q[i] = nil, nil
		end
	end)
	function freeWAN(delegate, wan, enq)
		if enq then
			q[#q+1], q[#q+2] = delegate, wan
		else
			SetAttribute(delegate, "clr", wan)
			SetAttributeNoHandler(delegate, wan, nil)
		end
	end
end
local function adjustType(v, h, isValue)
	local tv = type(v)
	local hi = tv == "userdata" and isValue and (handleInfo[v] or handleInfo[rtHandle[v]])
	if tv == "table" and IsFrameWidget(v) then
		v = GetFrameHandle(v) or SecureHandlerSetFrameRef(handleInfo[h][1], "h", v) and nil or GetFrameHandle(v)
		tv = v and "frameref" or tv
	elseif hi then
		v = handleInfo[v] and v or rtHandle[v]
		tv = v and hi == handleInfo[h] and "ware" or "alien"
	elseif tv == "userdata" and IsFrameHandle(v) then
		tv = "frameref"
	end
	return v, tv
end
local function newtable(h, k, ...)
	local t
	if k == nil then
		local hi = handleInfo[h]
		local delegate, tWAN = hi[1], hi[2]._nextWAN
		SetAttribute(delegate, tWAN, "nat")
		t = hi[3].__WARE[tWAN]
		handleWAN[t] = handleWAN[t] or tWAN
	else
		h[k] = newtable
		t = h[k]
	end
	local n = select("#", ...)
	for i=1, n, 4 do
		local l, a,b,c,d = i+4, select(i, ...)
		for j=i, l < n and l or n do
			t[j], a,b,c = a, b,c,d
		end
	end
	return t
end
local function unpack_ij(t, i, j)
	local d = j-i
	if     d >= 3 then return t[i], t[i+1], t[i+2], t[i+3], unpack_ij(t, i+4, j)
	elseif d >= 2 then return t[i], t[i+1], t[i+2]
	elseif d >= 1 then return t[i], t[i+1]
	elseif d >= 0 then return t[i]
	end
end
local function cleanupExec(delegate, ...)
	SetAttributeNoHandler(delegate, "frameref-other", nil)
	SetAttribute(delegate, "exe", nil)
	return ...
end
local function execFor(hw, other, body, ...)
	local hi = handleInfo[hw] or handleInfo[Ware.GetRestrictedEnvironment(hw)] or error("invalid handle", 3)
	local delegate, n = hi[1], select("#", ...)
	for i=1,n,3 do
		local a,b,c = select(i, ...)
		SetAttributeNoHandler(delegate, "a" .. i, a)
		b = i < n and SetAttributeNoHandler(delegate, "a" .. i+1, b)
		c = i+1 < n and SetAttributeNoHandler(delegate, "a" .. i+2, c)
	end
	SetAttributeNoHandler(delegate, "n", n)
	SetAttributeNoHandler(delegate, "frameref-other", other and adjustType(other, hi[3]))
	SetAttribute(delegate, "exe", body)
	local r = hi[2]._x
	return cleanupExec(delegate, unpack_ij(r, 1, r[0] or 0))
end

local hmeta = getmetatable(prototype)
function hmeta:__call(s, k)
	if s ~= nil then
		return hnext, self
	end
	return hnext(self, k)
end
function hmeta:__index(k)
	k = IsFrameWidget(k) and GetFrameHandle(k) or k
	return wrapValue(self, (handleRT[self] or emptyTable)[k], k)
end
function hmeta:__newindex(k, v)
	local wan, tk, tv = handleWAN[self] or allocWAN(self)
	k, tk = adjustType(k, self)
	v, tv = adjustType(v, self, true)
	if not wan then
		return error("lost handle", 2)
	elseif not simpleTypes[tk] then
		return error("invalid key type: " .. tk, 2)
	end
	local delegate, ov = handleInfo[self][1], handleRT[self][k]
	local isRef, isNewt = tv == "ware", v == newtable
	if ov == v or tv == "ware" and handleRT[v] == ov then
		-- leave it as is.
	elseif isRef or isNewt or tk == "frameref" or tv == "frameref" then
		if isRef and not emplaceReference(v) then
			return error("lost value handle", 2)
		elseif not (isRef or isNewt) then
			SetAttributeNoHandler(delegate, "val", v)
		end
		SetAttributeNoHandler(delegate, "key", k)
		SetAttribute(delegate, isNewt and "new" or isRef and "ref" or "set", wan)
	elseif v ~= nil and not simpleTypes[tv] then
		return error("invalid value type: " .. tv, 2)
	else
		SetAttributeNoHandler(delegate, "val", v)
		SetAttribute(delegate, wan, k)
	end
end
function hmeta:__len()
	return #(handleRT[self] or emptyTable)
end
function hmeta:__gc()
	local wan = handleWAN[self]
	if wan and wan ~= "r0" then
		freeWAN(handleInfo[self][1], wan, InCombatLockdown())
	end
end

Ware.newtable = newtable
function Ware.GetRestrictedEnvironment(owner)
	return ownerHandle[owner] or IsFrameWidget(owner) and select(2, owner:IsProtected()) and newEnvHandle(owner) or nil
end
function Ware.GetBackingRestrictedTable(h)
	return handleRT[h] or handleInfo[h] and handleInfo[h][1] and handleRT[h]
end
function Ware.PrepareWritableHandle(h)
	return handleInfo[h] and (handleWAN[h] or not InCombatLockdown() and allocWAN(h)) and h or nil
end
function Ware.Run(hw, body, ...)
	return execFor(hw, nil, body, ...)
end
function Ware.RunFor(hw, otherFrame, body, ...)
	return execFor(hw, otherFrame, body, ...)
end
function Ware.IsWareHandle(h)
	return handleInfo[h] ~= nil
end
function Ware.pairs(h)
	return (handleInfo[h] and h or rpairs)(h)
end
function Ware.next(h, k)
	local hi = handleInfo[h]
	return (hi and hnext or rnext)(h, hi and IsFrameWidget(k) and GetFrameHandle(k) or k)
end

(ADDON == "Ware" and _G or T).Ware = setmetatable(Ware, { __index = {REV = REV} })