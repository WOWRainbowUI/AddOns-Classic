--[[--
	by ALA
--]]--
----------------------------------------------------------------------------------------------------
local __addon, __private = ...;
local MT = {  }; __private.MT = MT;		--	method
local CT = {  }; __private.CT = CT;		--	constant
local VT = {  }; __private.VT = VT;		--	variables
local DT = {  }; __private.DT = DT;		--	data

-->		upvalue
	local setfenv = setfenv;
	local xpcall = xpcall;
	local geterrorhandler = geterrorhandler;
	local print, date = print, date;
	local type = type;
	local setmetatable = setmetatable;
	local rawset = rawset;
	local next = next;
	local select = select;
	local tremove = table.remove;
	local strrep = string.rep;
	local IsLoggedIn =IsLoggedIn;
	local UnitInBattleground = UnitInBattleground;
	local GetBestMapForUnit = C_Map.GetBestMapForUnit;
	local CreateFrame = CreateFrame;
	local _G = _G;

-->
	local __ala_meta__ = _G.__ala_meta__;
	__ala_meta__.emu = __private;
	VT.__dep = __ala_meta__;

-->		Dev
	local _GlobalRef = {  };
	local _GlobalAssign = {  };
	function MT.BuildEnv(category)
		local _G = _G;
		local Ref = _GlobalRef[category] or {  };
		local Assign = _GlobalAssign[category] or {  };
		setfenv(2, setmetatable(
			{  },
			{
				__index = function(tbl, key, val)
					Ref[key] = (Ref[key] or 0) + 1;
					_GlobalRef[category] = Ref;
					return _G[key];
				end,
				__newindex = function(tbl, key, value)
					rawset(tbl, key, value);
					Assign[key] = (Assign[key] or 0) + 1;
					_GlobalAssign[category] = Assign;
					return value;
				end,
			}
		));
	end
	function MT.MergeGlobal(DB)
		local _Ref = DB._GlobalRef;
		if _Ref ~= nil then
			for category, db in next, _Ref do
				local to = _GlobalRef[category];
				if to == nil then
					_GlobalRef[category] = db;
				else
					for key, val in next, db do
						to[key] = (to[key] or 0) + val;
					end
				end
			end
		end
		DB._GlobalRef = _GlobalRef;
		local _Assign = DB._GlobalAssign;
		if _Assign ~= nil then
			for category, db in next, _Assign do
				local to = _GlobalAssign[category];
				if to == nil then
					_GlobalAssign[category] = db;
				else
					for key, val in next, db do
						to[key] = (to[key] or 0) + val;
					end
				end
			end
		end
		DB._GlobalAssign = _GlobalAssign;
	end

-->		constant
	CT.RAID_CLASS_COLORS = RAID_CLASS_COLORS;
	CT.UNK_CLASS_COLORS = { r = 1.0, g = 0.5, b = 0.5, a = 1.0, };
	CT.CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS;
	CT.UNK_CLASS_COORDS = { 0.75, 1.0, 0.75, 1.0, };
	CT.ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS;
	CT.LOCALE = GetLocale();
	CT.BNTAG = select(2, BNGetInfo());
	CT.SELFREALM = GetRealmName();
	CT.SELFGUID = UnitGUID('player');
	CT.SELFLCLASS, CT.SELFCLASS, CT.SELFCLASSINDEX = UnitClass('player');
	CT.SELFNAME = UnitName('player');
	CT.SELFFULLNAME = CT.SELFNAME .. "-" .. CT.SELFREALM;
	CT.SELFFACTION = UnitFactionGroup('player');
	CT.CLIENTVERSION, CT.BUILDNUMBER, CT.BUILDDATE, CT.TOCVERSION = GetBuildInfo();
	if CT.TOCVERSION < 20000 then
		CT.BUILD = "CLASSIC";
	elseif CT.TOCVERSION < 30000 then
		CT.BUILD = "BCC";
	elseif CT.TOCVERSION < 40000 then
		CT.BUILD = "WRATH";
	elseif CT.TOCVERSION < 50000 then
		CT.BUILD = "CATA"
	elseif CT.TOCVERSION < 60000 then
		CT.BUILD = "PANDARIA";
	else
	end
	CT.ADDONVERSION = GetAddOnMetadata(__addon, "version");
	CT.MEDIAPATH =  [[Interface\AddOns\]] .. __addon .. [[\Media\]];
	CT.TEXTUREPATH =  CT.MEDIAPATH .. [[Textures\]];
	CT.NUM_POINTS_NEXT_TIER = 5;
	CT.TOOLTIP_WAIT_BEFORE_QUERY_UNIT = 0.5;
	CT.THROTTLE_TALENT_QUERY = VT.__dep.__emulib.CT.TALENT_REPLY_THROTTLED_INTERVAL + 0.5;
	CT.THROTTLE_GLYPH_QUERY = VT.__dep.__emulib.CT.GLYPH_REPLY_THROTTLED_INTERVAL + 0.5;
	CT.THROTTLE_EQUIPMENT_QUERY = VT.__dep.__emulib.CT.EQUIPMENT_REPLY_THROTTLED_INTERVAL + 0.5;
	CT.DATA_VALIDITY = 30;
	CT.TOOLTIP_UPDATE_DELAY = 0.02;
	CT.INSPECT_WAIT_TIME = 10;
	CT.l10n = {  };

	CT.TEXTUREICON = CT.TEXTUREPATH .. [[ICON]];
	CT.TEXTUREUNK = [[Interface\Icons\Inv_Misc_QuestionMark]];

	CT.RepeatedZero = setmetatable(
		{
			GetParent = false,
			SetShown = false,
			GetDebugName = false,
			IsObjectType = false,
			GetChildren = false,
			GetRegions = false,
			[0] = "",
			[1] = "0",
		},
		{
			__index = function(tbl, key)
				local str = strrep("0", key);
				tbl[key] = str;
				return str;
			end,
		}
	);

	DT.IndexToClass = VT.__dep.__emulib.__classList;
	DT.ClassToIndex = VT.__dep.__emulib.__classHash;

-->		Compatible
	local _comptb = {  };
	VT._comptb = _comptb;
	if _G.GetMouseFocus then
		_comptb.GetMouseFocus = _G.GetMouseFocus;
	elseif _G.GetMouseFoci then
		local GetMouseFoci = _G.GetMouseFoci;
		_comptb.GetMouseFocus = function()
			return GetMouseFoci()[1];
		end
	else
		_comptb.GetMouseFocus = function()
		end
	end
	local GetTalentTabInfo = _G.GetTalentTabInfo;
	if CT.TOCVERSION >= 20000 and CT.TOCVERSION < 40000 then
		_comptb.GetTreeNumPoints = function(index) return select(3, GetTalentTabInfo(index)) or 0 end
	else
		_comptb.GetTreeNumPoints = function(index) return select(5, GetTalentTabInfo(index)) or 0 end
	end
	if _G.GetSpellLink then
		local GetSpellLink = _G.GetSpellLink;
		_comptb._GetSpellLink = function(id, name)
			return GetSpellLink(id);
		end
	elseif CT.TOCVERSION < 20000 then
		local GetSpellInfo = _G.GetSpellInfo;
		_comptb._GetSpellLink = function(id, name)
			--|cff71d5ff|Hspell:id|h[name]|h|r
			name = name or GetSpellInfo(id);
			if name then
				if __ala_meta__.chat and __ala_meta__.chat.alac_hyperLink and __ala_meta__.chat.alac_hyperLink() then
					return "|cff71d5ff|Hspell:" .. id .. "|h[" .. name .. "]|h|r";
				else
					return name;
				end
			else
				return nil;
			end
		end
	elseif CT.TOCVERSION < 50000 then
		local GetSpellInfo = _G.GetSpellInfo;
		_comptb._GetSpellLink = function(id, name)
			--|cff71d5ff|Hspell:id|h[name]|h|r
			name = name or GetSpellInfo(id);
			if name then
				return "|cff71d5ff|Hspell:" .. id .. "|h[" .. name .. "]|h|r";
			else
				return nil;
			end
		end
	end

-->
MT.BuildEnv('INIT');
-->		predef
	MT.GetUnifiedTime = _G.GetTimePreciseSec;

	MT.Print = print;
	function MT.Error(...)
		MT.Print(date('|cff00ff00%H:%M:%S|r'), ...);
	end
	function MT.DebugDev(...)
		MT.Print(date('|cff00ff00%H:%M:%S|r'), ...);
	end
	function MT.DebugRelease(...)
	end
	function MT.Notice(...)
		MT.Print(date('|cffff0000%H:%M:%S|r'), ...);
	end

	MT.After = _G.C_Timer.After;
	local _TimerPrivate = {  };		--	[callback] = { periodic, int, running, halting, limit, };
	function MT._TimerStart(callback, int, limit)
		if callback ~= nil and type(callback) == 'function' then
			local P = _TimerPrivate[callback];
			if P == nil then
				P = {
					[1] = function()	--	periodic
						if P[4] then
							P[3] = false;
						elseif P[5] == nil then
							MT.After(P[2], P[1]);
							callback();
						elseif P[5] > 1 then
							P[5] = P[5] - 1;
							MT.After(P[2], P[1]);
							callback();
						elseif P[5] > 0 then
							P[3] = false;
							callback();
						else
							P[3] = false;
						end
					end,
					[2] = int or 1.0,	--	int
					[3] = true,			--	isrunning
					[4] = false,		--	ishalting
					[5] = limit,
				};
				_TimerPrivate[callback] = P;
				return MT.After(P[2], P[1]);
			elseif not P[3] then
				P[2] = int or 1.0;
				P[3] = true;
				P[4] = false;
				P[5] = limit;
				return MT.After(P[2], P[1]);
			else
				P[2] = int or P[2];
				P[4] = false;
				P[5] = limit;
			end
		end
	end
	function MT._TimerHalt(callback)
		local P = _TimerPrivate[callback];
		if P ~= nil and P[3] then
			P[4] = true;
		end
	end
	local _CallbackPrivate = {  };
	function MT._RegisterCallback(event, callback)
		if callback ~= nil and type(callback) == 'function' then
			local E = _CallbackPrivate[event];
			if E == nil then
				_CallbackPrivate[event] = { callback, };
			else
				local N = #E;
				for index = 1, N do
					if E[index] == callback then
						return;
					end
				end
				E[N + 1] = callback;
			end
		end
	end
	function MT._UnregisterCallback(event, callback)
		local E = _CallbackPrivate[event];
		if E ~= nil and callback ~= nil and type(callback) == 'function' then
			for index = #E, 1, -1 do
				if E[index] == callback then
					tremove(E, index);
				end
			end
		end
	end
	function MT._TriggerCallback(event, ...)
		local E = _CallbackPrivate[event];
		if E ~= nil then
			for index = #E, 1, -1 do
				E[index](...);
			end
		end
	end

	function MT.NewCache()
		return { TalData = {  }, GlyData = {  }, EquData = {  }, EngData = {  }, PakData = {  }, };
	end

	local function BuildTipTextList(Tooltip, IsRight)
		local name = Tooltip:GetName();
		if name then
			return setmetatable(
				{
					Prefix = name .. (IsRight and "TextRight" or "TextLeft");
				},
				{
					__index = function(tbl, i)
						local Line = _G[tbl.Prefix .. i];
						if Line then
							tbl[i] = Line;
							return Line;
						end
						return nil;
					end,
				}
			);
		end
	end
	MT.TipTextLeft = setmetatable({  }, {
		__index = function(tbl, Tooltip)
			local List = BuildTipTextList(Tooltip);
			tbl[Tooltip] = List;
			return List;
		end,
	});
	MT.TipTextRight = setmetatable({  }, {
		__index = function(tbl, Tooltip)
			local List = BuildTipTextList(Tooltip, true);
			tbl[Tooltip] = List;
			return List;
		end,
	});

-->
	MT.UI = {  };
	MT.CALLBACK = {  };
	VT.TSpellLevelHash = {  };
	VT.ExternalCodec = {  };
	VT.ExternalAddOn = {  };
	VT.Frames = { num = 0, used = 0, };
	VT.TQueryCache = {  };	--	[GUID] = { [addon] = { data, time, }, }
	VT.QuerySent = {  };					--	尝试发送带弹出界面请求的时间，无论是否真实发送
	VT.TBattlegroundComm = {  };
	VT.NameBindingFrame = {  };
	VT.ImportTargetFrame = {  };
	VT.PrevQueryRequestSentTime = {  };		--	真实发送请求的时间
	VT.QueryRequestNotResponsed = {  };
	VT.ApplyingTalents = {  };
	VT.AutoShowEquipmentFrameOnComm = {  };

-->
-->		INIT
	local __oninit = {  };
	local __onlogin = {  };
	local __onquit = {  };
	function MT.RegisterOnInit(key, method)
		if type(key) == 'string' and type(method) == 'function' then
			__oninit[#__oninit + 1] = key;
			__oninit[key] = method;
		end
	end
	function MT.RegisterOnLogin(key, method)
		if type(key) == 'string' and type(method) == 'function' then
			__onlogin[#__onlogin + 1] = key;
			__onlogin[key] = method;
		end
	end
	function MT.RegisterOnQuit(key, method)
		if type(key) == 'string' and type(method) == 'function' then
			__onquit[#__onquit + 1] = key;
			__onquit[key] = method;
		end
	end

	MT.GetUnifiedTime();		--	initialized after call once
	local Driver = CreateFrame('FRAME');
	Driver:RegisterEvent("ADDON_LOADED");
	Driver:RegisterEvent("PLAYER_LOGOUT");
	Driver:RegisterEvent("PLAYER_LOGIN");
	Driver:RegisterEvent("PLAYER_ENTERING_WORLD");
	Driver:SetScript("OnEvent", function(Driver, event, addon)
		if event == "ADDON_LOADED" then
			if addon == __addon then
				Driver:UnregisterEvent("ADDON_LOADED");
				VT.__is_loggedin = IsLoggedIn();
				local ErrorHandler = geterrorhandler();
				for index = 1, #__oninit do
					local key = __oninit[index];
					local method = __oninit[key];
					xpcall(method, ErrorHandler, VT.__is_loggedin);
					--[==[local success, message = pcall(method);
					if not success then
						ErrorHandler(message or (__addon .. " INIT SCRIPT [[" .. key .. "]] ERROR."));
					end]==]
				end
				if VT.__is_loggedin then
					return Driver:GetScript("OnEvent")(Driver, "PLAYER_LOGIN");
				end
			end
		elseif event == "PLAYER_LOGIN" then
			Driver:UnregisterEvent("PLAYER_LOGIN");
			VT.__is_loggedin = true;
			local ErrorHandler = geterrorhandler();
			for index = 1, #__onlogin do
				local key = __onlogin[index];
				local method = __onlogin[key];
				xpcall(method, ErrorHandler, true);
			end
		elseif event == "PLAYER_LOGOUT" then
			local ErrorHandler = geterrorhandler();
			for index = 1, #__onquit do
				local key = __onquit[index];
				local method = __onquit[key];
				xpcall(method, ErrorHandler);
			end
		elseif event == "PLAYER_ENTERING_WORLD" then
			VT.__is_inbattleground = UnitInBattleground('player');
			local map = GetBestMapForUnit('player');
			if VT.__player_map ~= map then
				VT.__player_map = map;
				VT.TBattlegroundComm = {  };
			end
		end
	end);

	VT.__is_loggedin = IsLoggedIn();
	VT.__is_inbattleground = UnitInBattleground('player');
	VT.__player_map = GetBestMapForUnit('player');
	VT.__support_gem = VT.__dep.__emulib.CT.SUPPORT_GEM;
	VT.__support_glyph = VT.__dep.__emulib.CT.SUPPORT_GLYPH;
	VT.__support_engraving = VT.__dep.__emulib.CT.SUPPORT_ENGRAVING;

	if CT.BNTAG == "\97\108\101\120\35\53\49\54\55\50\50" or CT.BNTAG == "ALEX#125620" or CT.BNTAG == '\65\76\65\35\53\49\51\55\55' then
		MT.Debug = MT.DebugDev;
	else
		MT.Debug = MT.DebugRelease;
	end
	if CT.BNTAG == '\97\108\101\120\35\53\49\54\55\50\50' or CT.BNTAG == "ALEX#125620" or CT.BNTAG == '\65\76\65\35\53\49\51\55\55' or CT.BNTAG == '\229\141\149\233\133\146\231\170\157\35\53\49\54\51\55' then
		VT.__supreme = true;
	else
		VT.__supreme = false;
	end
	VT.ImportIndex = 0;

-->
