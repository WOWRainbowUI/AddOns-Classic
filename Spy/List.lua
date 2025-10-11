local HBDP = LibStub("HereBeDragons-Pins-2.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("Spy")
local _

StaticPopupDialogs["Spy_SetKOSReasonOther"] = {
	text = L["EnterKOSReason"],		
	button1 = ACCEPT,
	button2 = CANCEL,	
	timeout = 120,
	hasEditBox = 1,
	editBoxWidth = 260,	
	whileDead = 1,
	hideOnEscape = 1,
	OnShow = function(self)
		local editBox = self.GetEditBox and self:GetEditBox() or self.editBox
		editBox:SetText("")
	end,
    OnAccept = function(self)
		local editBox = self.GetEditBox and self:GetEditBox() or self.editBox
		local reason = editBox:GetText()
		Spy:SetKOSReason(self.playerName, reason, data)		
	end,
};

function Spy:RefreshCurrentList(player, source)
	local MainWindow = Spy.MainWindow
	if not MainWindow:IsShown() then
		return
	end

	local mode = Spy.db.profile.CurrentList
	local manageFunction = Spy.ListTypes[mode][2]
	if manageFunction then
		manageFunction()
	end

	local button = 1
	for index, data in pairs(Spy.CurrentList) do
		if button <= Spy.ButtonLimit then
			local description = ""
			local level = "??"
			local class = "UNKNOWN"
			local guild = "??"
--			local rank = 0
			local opacity = 1

			local playerData = SpyPerCharDB.PlayerData[data.player]
			if playerData then
				if playerData.level then
					level = playerData.level
					if playerData.isGuess == true and tonumber(playerData.level) < Spy.MaximumPlayerLevel then
						level = level.."+"
					end
				end
				if playerData.class then
					class = playerData.class
				end
				if playerData.guild then
					guild = playerData.guild
				end
--				if playerData.rank then
--					rank = playerData.rank
--				end
			end
			
			if Spy.db.profile.DisplayListData == "1NameLevelClass" then
				description = level.." "
				if L[class] and type(L[class]) == "string" then
					description = description..L[class]
				end
			elseif Spy.db.profile.DisplayListData == "2NameLevelGuild" then
				description = level.." "..guild
			elseif Spy.db.profile.DisplayListData == "3NameLevelOnly" then
				description = level.." "
			elseif Spy.db.profile.DisplayListData == "4NamePvPRank" then
				description = L["Rank"].." "..rank
			elseif Spy.db.profile.DisplayListData == "5NameGuild" then
				description = guild
			end
			if mode == 1 and Spy.InactiveList[data.player] then
				opacity = 0.5
			end
			if player == data.player then
				if not source or source ~= Spy.CharacterName then
					Spy:AlertPlayer(player, source)
					if not source then
						Spy:AnnouncePlayer(player)
					end
				end
			end

			Spy:SetBar(button, data.player, description, 100, "Class", class, nil, opacity)
			Spy.ButtonName[button] = data.player
			button = button + 1
		end
	end
	Spy.ListAmountDisplayed = button - 1

	if Spy.db.profile.ResizeSpy then
		Spy:AutomaticallyResize()
	else
		if not Spy.db.profile.InvertSpy then
			if not InCombatLockdown() and Spy.MainWindow:GetHeight()< 34 then
				Spy:RestoreMainWindowPosition(Spy.MainWindow:GetLeft(), Spy.MainWindow:GetTop(), Spy.MainWindow:GetWidth(), 34)
			end
		else
			if not InCombatLockdown() and Spy.MainWindow:GetHeight()< 34 then 
				Spy:RestoreMainWindowPosition(Spy.MainWindow:GetLeft(), Spy.MainWindow:GetBottom(), Spy.MainWindow:GetWidth(), 34)
			end
		end	
	end
	Spy:ManageBarsDisplayed()
end

function Spy:ManageNearbyList()
	local prioritiseKoS = Spy.db.profile.PrioritiseKoS

	local activeKoS = {}
	local active = {}
	for player in pairs(Spy.ActiveList) do
		local position = Spy.NearbyList[player]
		if position ~= nil then
			if prioritiseKoS and SpyPerCharDB.KOSData[player] then
				table.insert(activeKoS, { player = player, time = position })
			else
				table.insert(active, { player = player, time = position })
			end
		end
	end

	local inactiveKoS = {}
	local inactive = {}
	for player in pairs(Spy.InactiveList) do
		local position = Spy.NearbyList[player]
		if position ~= nil then
			if prioritiseKoS and SpyPerCharDB.KOSData[player] then
				table.insert(inactiveKoS, { player = player, time = position })
			else
				table.insert(inactive, { player = player, time = position })
			end
		end
	end

	table.sort(activeKoS, function(a, b) return a.time < b.time end)
	table.sort(inactiveKoS, function(a, b) return a.time < b.time end)
	table.sort(active, function(a, b) return a.time < b.time end)
	table.sort(inactive, function(a, b) return a.time < b.time end)

	local list = {}
	for player in pairs(activeKoS) do table.insert(list, activeKoS[player]) end
	for player in pairs(inactiveKoS) do table.insert(list, inactiveKoS[player]) end
	for player in pairs(active) do table.insert(list, active[player]) end
	for player in pairs(inactive) do table.insert(list, inactive[player]) end
	Spy.CurrentList = list
end

function Spy:ManageLastHourList()
	local list = {}
	for player in pairs(Spy.LastHourList) do
		table.insert(list, { player = player, time = Spy.LastHourList[player] })
	end
	table.sort(list, function(a, b) return a.time > b.time end)
	Spy.CurrentList = list
end

function Spy:ManageIgnoreList()
	local list = {}
	for player in pairs(SpyPerCharDB.IgnoreData) do
		local playerData = SpyPerCharDB.PlayerData[player]
		local position = time()
		if playerData then position = playerData.time end
		table.insert(list, { player = player, time = position })
	end
	table.sort(list, function(a, b) return a.time > b.time end)
	Spy.CurrentList = list
end

function Spy:ManageKillOnSightList()
	local list = {}
	for player in pairs(SpyPerCharDB.KOSData) do
		local playerData = SpyPerCharDB.PlayerData[player]
		local position = time()
		if playerData then position = playerData.time end
		table.insert(list, { player = player, time = position })
	end
	table.sort(list, function(a, b) return a.time > b.time end)
	Spy.CurrentList = list
end

function Spy:GetNearbyListSize()
	local entries = 0
	for v in pairs(Spy.NearbyList) do
		entries = entries + 1
	end
	return entries
end

function Spy:UpdateActiveCount()
    local activeCount = 0
    for k in pairs(Spy.ActiveList) do
        activeCount = activeCount + 1
    end
	local theFrame = Spy.MainWindow
    if activeCount > 0 then 
		theFrame.CountFrame.Text:SetText("|cFF0070DE" .. activeCount .. "|r") 
    else 
        theFrame.CountFrame.Text:SetText("|cFF0070DE0|r")
    end
end

function Spy:ManageExpirations()
	local mode = Spy.db.profile.CurrentList
	local expirationFunction = Spy.ListTypes[mode][3]
	if expirationFunction then
		expirationFunction()
	end
end

function Spy:ManageNearbyListExpirations()
	local expired = false
	local currentTime = time()
	for player in pairs(Spy.ActiveList) do
		if (currentTime - Spy.ActiveList[player]) > Spy.ActiveTimeout then
			Spy.InactiveList[player] = Spy.ActiveList[player]
			Spy.ActiveList[player] = nil
			expired = true
		end
	end
	if Spy.db.profile.RemoveUndetected ~= "Never" then
		for player in pairs(Spy.InactiveList) do
			if (currentTime - Spy.InactiveList[player]) > Spy.InactiveTimeout then
				if Spy.PlayerCommList[player] ~= nil then
					Spy.MapNoteList[Spy.PlayerCommList[player]].displayed = false
					Spy.MapNoteList[Spy.PlayerCommList[player]].worldIcon:Hide()
					HBDP:RemoveMinimapIcon(self, Spy.MapNoteList[Spy.PlayerCommList[player]].miniIcon)
					Spy.PlayerCommList[player] = nil
				end
				Spy.InactiveList[player] = nil
				Spy.NearbyList[player] = nil
				expired = true
			end
		end
	end
	if expired then
		Spy:RefreshCurrentList()
		Spy:UpdateActiveCount()
		if Spy.db.profile.HideSpy and Spy:GetNearbyListSize() == 0 then 
			if not InCombatLockdown() then
				Spy.MainWindow:Hide()
			else	
				Spy:HideSpyCombatCheck()
			end
		end
	end
end

function Spy:ManageLastHourListExpirations()
	local expired = false
	local currentTime = time()
	for player in pairs(Spy.LastHourList) do
		if (currentTime - Spy.LastHourList[player]) > 3600 then
			Spy.LastHourList[player] = nil
			expired = true
		end
	end
	if expired then
		Spy:RefreshCurrentList()
	end
end

function Spy:RemovePlayerFromList(player)
	Spy.NearbyList[player] = nil
	Spy.ActiveList[player] = nil
	Spy.InactiveList[player] = nil
	if Spy.PlayerCommList[player] ~= nil then
		Spy.MapNoteList[Spy.PlayerCommList[player]].displayed = false
		Spy.MapNoteList[Spy.PlayerCommList[player]].worldIcon:Hide()
		HBDP:RemoveMinimapIcon(self, Spy.MapNoteList[Spy.PlayerCommList[player]].miniIcon)
		Spy.PlayerCommList[player] = nil
	end
	Spy:RefreshCurrentList()
	Spy:UpdateActiveCount()	
end

function Spy:ClearList()
	if IsShiftKeyDown () then
		Spy:EnableSound(not Spy.db.profile.EnableSound, false)
	else	
		Spy.NearbyList = {}
		Spy.ActiveList = {}
		Spy.InactiveList = {}
		Spy.PlayerCommList = {}
		Spy.ListAmountDisplayed = 0
		for i = 1, Spy.MapNoteLimit do
			Spy.MapNoteList[i].displayed = false
			Spy.MapNoteList[i].worldIcon:Hide()
			HBDP:RemoveMinimapIcon(self, Spy.MapNoteList[i].miniIcon)
		end
		Spy:SetCurrentList(1)
		if IsControlKeyDown() then
			Spy:EnableSpy(not Spy.db.profile.Enabled, false)
		end
		Spy:UpdateActiveCount()
	end	
end

function Spy:AddPlayerData(name, class, level, race, guild, faction, isEnemy, isGuess)
	local info = {}
	info.name = name  --++ added to normalize data
	info.class = class
	if type(level) == "number" then info.level = level end
	info.race = race
	info.guild = guild
	info.faction = faction
	info.isEnemy = isEnemy
	info.isGuess = isGuess
	SpyPerCharDB.PlayerData[name] = info
	return SpyPerCharDB.PlayerData[name]
end

function Spy:UpdatePlayerData(name, class, level, race, guild, faction, isEnemy, isGuess)
	local detected = true
	local playerData = SpyPerCharDB.PlayerData[name]
	if not playerData then
		playerData = Spy:AddPlayerData(name, class, level, race, guild, faction, isEnemy, isGuess)
	else
		if name ~= nil then playerData.name = name end  
		if class ~= nil then playerData.class = class end
		if type(level) == "number" then playerData.level = level end
		if race ~= nil then playerData.race = race end
		if guild ~= nil then playerData.guild = guild end
		if faction ~= nil then playerData.faction = faction end
		if isEnemy ~= nil then playerData.isEnemy = isEnemy end
		if isGuess ~= nil then playerData.isGuess = isGuess end
	end
	if playerData then
		playerData.time = time()
		if not Spy.ActiveList[name] then
			if (WorldMapFrame:IsVisible() and Spy.db.profile.SwitchToZone) then
				WorldMapFrame:SetMapID(C_Map.GetBestMapForUnit("player"))
			end
			if (nil == C_Map.GetBestMapForUnit("player")) or (nil == C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player")) then
				local x,y = 0,0
				local InsName = GetInstanceInfo()
				playerData.zone = InsName
				playerData.subZone = ""
			else
				local mapX, mapY = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY()			
				if mapX ~= 0 and mapY ~= 0 then
					mapX = math.floor(tonumber(mapX) * 100) / 100
					mapY = math.floor(tonumber(mapY) * 100) / 100
					playerData.mapX = mapX
					playerData.mapY = mapY
					playerData.zone = GetZoneText()
					playerData.mapID = C_Map.GetBestMapForUnit("player") --++8.0
					playerData.subZone = GetSubZoneText()
				else
					detected = false
				end
			end
		end	
	end
	return detected
end

function Spy:UpdatePlayerStatus(name, class, level, race, guild, faction, isEnemy, isGuess)
	local playerData = SpyPerCharDB.PlayerData[name]
	if not playerData then
		playerData = Spy:AddPlayerData(name, class, level, race, guild, faction, isEnemy, isGuess)
	else
		if name ~= nil then playerData.name = name end  
		if class ~= nil then playerData.class = class end
		if type(level) == "number" then playerData.level = level end
		if race ~= nil then playerData.race = race end
		if guild ~= nil then playerData.guild = guild end
		if faction ~= nil then playerData.faction = faction end
		if isEnemy ~= nil then playerData.isEnemy = isEnemy end
		if isGuess ~= nil then playerData.isGuess = isGuess end
	end
	if playerData.time == nil then
		playerData.time = time()
	end	
end

function Spy:RemovePlayerData(name)
	local playerData = SpyPerCharDB.PlayerData[name]
		if ((playerData.loses == nil) and (playerData.wins == nil)) then
			SpyPerCharDB.PlayerData[name] = nil
		else
			playerData.isEnemy = false
		end
end

function Spy:RemovePlayerDataFromStats(name)
	SpyPerCharDB.PlayerData[name] = nil
end

function Spy:AddIgnoreData(name)
	SpyPerCharDB.IgnoreData[name] = true
end

function Spy:RemoveIgnoreData(name)
	if SpyPerCharDB.IgnoreData[name] then
		SpyPerCharDB.IgnoreData[name] = nil
	end
end

function Spy:AddKOSData(name)
	SpyPerCharDB.KOSData[name] = time()
--	SpyPerCharDB.PlayerData[name].kos = 1 
	if Spy.db.profile.ShareKOSBetweenCharacters then
		SpyDB.removeKOSData[Spy.RealmName][Spy.FactionName][name] = nil
	end
end

function Spy:RemoveKOSData(name)
	if SpyPerCharDB.KOSData[name] then
		local playerData = SpyPerCharDB.PlayerData[name]
		if playerData and playerData.reason then
			playerData.reason = nil
		end
		SpyPerCharDB.KOSData[name] = nil
		if SpyPerCharDB.PlayerData[name] then
			SpyPerCharDB.PlayerData[name].kos = nil
		end
		if Spy.db.profile.ShareKOSBetweenCharacters then
			SpyDB.removeKOSData[Spy.RealmName][Spy.FactionName][name] = time()
		end
	end
end

function Spy:SetKOSReason(name, reason, other)
	local playerData = SpyPerCharDB.PlayerData[name]
	if playerData then
		if not reason then
			playerData.reason = nil
		else
			if not playerData.reason then playerData.reason = {} end
			if reason == L["KOSReasonOther"] then
				if not other then 
					local dialog = StaticPopup_Show("Spy_SetKOSReasonOther", name)
					if dialog then
						dialog.playerName = name
					end
				else
					if other == "" then
						playerData.reason[L["KOSReasonOther"]] = nil
					else
						playerData.reason[L["KOSReasonOther"]] = other
					end
					Spy:RegenerateKOSCentralList(name)
				end
			else
				if playerData.reason[reason] then
					playerData.reason[reason] = nil
				else
					playerData.reason[reason] = true
				end
				Spy:RegenerateKOSCentralList(name)
			end
		end
	end
end

function Spy:AlertPlayer(player, source)
	local playerData = SpyPerCharDB.PlayerData[player]
	if SpyPerCharDB.KOSData[player] and Spy.db.profile.WarnOnKOS then
--		if Spy.db.profile.DisplayWarningsInErrorsFrame then
		if Spy.db.profile.DisplayWarnings == "ErrorFrame" then
			local text = Spy.db.profile.Colors.Warning["Warning Text"]
			local msg = L["KOSWarning"]..player
			UIErrorsFrame:AddMessage(msg, text.r, text.g, text.b, 1.0, UIERRORS_HOLD_TIME)
		else
			if source ~= nil and source ~= Spy.CharacterName then
				Spy:ShowAlert("kosaway", player, source, Spy:GetPlayerLocation(playerData))
			else
				local reasonText = ""
				if playerData.reason then
					for reason in pairs(playerData.reason) do
						if reasonText ~= "" then reasonText = reasonText..", " end
						if reason == L["KOSReasonOther"] then
							reasonText = reasonText..playerData.reason[reason]
						else
							reasonText = reasonText..reason
						end
					end
				end
				Spy:ShowAlert("kos", player, nil, reasonText)
			end
		end
		if Spy.db.profile.EnableSound then
			if source ~= nil and source ~= Spy.CharacterName then
				PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\detected-kosaway.mp3", Spy.db.profile.SoundChannel)
			else
				PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\detected-kos.mp3", Spy.db.profile.SoundChannel)
			end
		end
		if Spy.db.profile.ShareKOSBetweenCharacters then Spy:RegenerateKOSCentralList(player) end
	elseif Spy.db.profile.WarnOnKOSGuild then
		if playerData and playerData.guild and Spy.KOSGuild[playerData.guild] then
--			if Spy.db.profile.DisplayWarningsInErrorsFrame then
			if Spy.db.profile.DisplayWarnings == "ErrorFrame" then
				local text = Spy.db.profile.Colors.Warning["Warning Text"]
				local msg = L["KOSGuildWarning"].."<"..playerData.guild..">"
				UIErrorsFrame:AddMessage(msg, text.r, text.g, text.b, 1.0, UIERRORS_HOLD_TIME)				
			else
				if source ~= nil and source ~= Spy.CharacterName then
					Spy:ShowAlert("kosguildaway", "<"..playerData.guild..">", source, Spy:GetPlayerLocation(playerData))
				else
					Spy:ShowAlert("kosguild", "<"..playerData.guild..">")
				end
			end
			if Spy.db.profile.EnableSound then
				if source ~= nil and source ~= Spy.CharacterName then
					PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\detected-kosaway.mp3", Spy.db.profile.SoundChannel)
				else
					PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\detected-kosguild.mp3", Spy.db.profile.SoundChannel)
				end
			end
		else
			if Spy.db.profile.EnableSound and not Spy.db.profile.OnlySoundKoS then 
				if source == nil or source == Spy.CharacterName then
					if playerData and Spy.db.profile.WarnOnRace and playerData.race == Spy.db.profile.SelectWarnRace then --++
						PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\detected-race.mp3", Spy.db.profile.SoundChannel) 
					else
						PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\detected-nearby.mp3", Spy.db.profile.SoundChannel)
					end
				end
			end
		end 
	elseif Spy.db.profile.EnableSound and not Spy.db.profile.OnlySoundKoS then 
		if source == nil or source == Spy.CharacterName then
			if playerData and Spy.db.profile.WarnOnRace and playerData.race == Spy.db.profile.SelectWarnRace then
				PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\detected-race.mp3", Spy.db.profile.SoundChannel) 
			else
				PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\detected-nearby.mp3", Spy.db.profile.SoundChannel)
			end
		end
	elseif Spy.db.profile.EnableSound and not Spy.db.profile.OnlySoundKoS then
		if source == nil or source == Spy.CharacterName then
			PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\detected-nearby.mp3", Spy.db.profile.SoundChannel)
		end
	end
end

function Spy:AlertStealthPlayer(player)
	if Spy.db.profile.WarnOnStealth then
--		if Spy.db.profile.DisplayWarningsInErrorsFrame then
		if Spy.db.profile.DisplayWarnings == "ErrorFrame" then
			local text = Spy.db.profile.Colors.Warning["Warning Text"]
			local msg = L["StealthWarning"]..player
			UIErrorsFrame:AddMessage(msg, text.r, text.g, text.b, 1.0, UIERRORS_HOLD_TIME)
		else
			Spy:ShowAlert("stealth", player)
		end
		if Spy.db.profile.EnableSound then
			PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\detected-stealth.mp3", Spy.db.profile.SoundChannel)
		end
	end
end

function Spy:AlertProwlPlayer(player)
	if Spy.db.profile.WarnOnStealth then
--		if Spy.db.profile.DisplayWarningsInErrorsFrame then
		if Spy.db.profile.DisplayWarnings == "ErrorFrame" then
			local text = Spy.db.profile.Colors.Warning["Warning Text"]
			local msg = L["StealthWarning"]..player
			UIErrorsFrame:AddMessage(msg, text.r, text.g, text.b, 1.0, UIERRORS_HOLD_TIME)
		else
			Spy:ShowAlert("prowl", player)
		end
		if Spy.db.profile.EnableSound then
			PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\detected-stealth.mp3", Spy.db.profile.SoundChannel)
		end
	end
end

function Spy:AnnouncePlayer(player, channel)
	if not Spy_IgnoreList[player] then
		local msg = ""
		local isKOS = SpyPerCharDB.KOSData[player]
		local playerData = SpyPerCharDB.PlayerData[player]

		local announce = Spy.db.profile.Announce  
		if channel or announce == "Self" or announce == "LocalDefense" or (announce == "Guild" and GetGuildInfo("player") ~= nil and not Spy.InInstance) or (announce == "Party" and GetNumGroupMembers() > 0) or (announce == "Raid" and UnitInRaid("player")) then --++
			if announce == "Self" and not channel then
				if isKOS then
					msg = msg..L["SpySignatureColored"]..L["KillOnSightDetectedColored"]..player.." "
				else
					msg = msg..L["SpySignatureColored"]..L["PlayerDetectedColored"]..player.." "
				end
			else
				if isKOS then
					msg = msg..L["KillOnSightDetected"]..player.." "
				else
					msg = msg..L["PlayerDetected"]..player.." "
				end
			end
			if playerData then
				if playerData.guild and playerData.guild ~= "" then
					msg = msg.."<"..playerData.guild.."> "
				end
				if playerData.level or playerData.race or (playerData.class and playerData.class ~= "") then
					msg = msg.."- "
					if playerData.level and playerData.isGuess == false then
						msg = msg..L["Level"].." "..playerData.level.." "
					end
					if playerData.race and playerData.race ~= "" then
						msg = msg..playerData.race.." "
					end
					if playerData.class and playerData.class ~= "" then
						msg = msg..L[playerData.class].." "
					end
				end
				if playerData.zone then
					if playerData.subZone and playerData.subZone ~= "" and playerData.subZone ~= playerData.zone then
						msg = msg.."- "..playerData.subZone..", "..playerData.zone
					else
						msg = msg.."- "..playerData.zone
					end
				end
				if playerData.mapX and playerData.mapY then
					msg = msg.." ("..math.floor(tonumber(playerData.mapX) * 100)..","..math.floor(tonumber(playerData.mapY) * 100)..")"
				end
			end

			if channel then
				-- announce to selected channel
				if (channel == "PARTY" and GetNumGroupMembers() > 0) or (channel == "RAID" and UnitInRaid("player")) or (channel == "GUILD" and GetGuildInfo("player") ~= nil) then
					SendChatMessage(msg, channel)
				elseif channel == "LOCAL" then
					SendChatMessage(msg, "CHANNEL", nil, GetChannelName(L["LocalDefenseChannelName"].." - "..GetZoneText()))
				end
			else
				-- announce to standard channel
				if isKOS or not Spy.db.profile.OnlyAnnounceKoS then
					if announce == "Self" then
						DEFAULT_CHAT_FRAME:AddMessage(msg)
					elseif announce == "LocalDefense" then
						SendChatMessage(msg, "CHANNEL", nil, GetChannelName(L["LocalDefenseChannelName"].." - "..GetZoneText()))
					else
						SendChatMessage(msg, strupper(announce))
					end
				end
			end
		end

		-- announce to other Spy users
		if Spy.db.profile.ShareData then
			local class, level, race, zone, subZone, mapX, mapY, guild, mapID = "", "", "", "", "", "", "", "", ""
			if playerData then
				if playerData.class then class = playerData.class end
				if playerData.level and playerData.isGuess == false then level = playerData.level end
				if playerData.race then race = playerData.race end
				if playerData.zone then zone = playerData.zone end
				if playerData.mapID then mapID = playerData.mapID end
				if playerData.subZone then subZone = playerData.subZone end
				if playerData.mapX then mapX = playerData.mapX end
				if playerData.mapY then mapY = playerData.mapY end
				if playerData.guild then guild = playerData.guild end
			end
			local details = Spy.Version.."|"..player.."|"..class.."|"..level.."|"..race.."|"..zone.."|"..subZone.."|"..mapX.."|"..mapY.."|"..guild.."|"..mapID
			if strlen(details) < 240 then
				if channel then
					if (channel == "PARTY" and GetNumGroupMembers() > 0) or (channel == "RAID" and UnitInRaid("player")) or (channel == "GUILD" and GetGuildInfo("player") ~= nil) then
						Spy:SendCommMessage(Spy.Signature, details, channel)
					end
				else
					if GetNumGroupMembers() > 0 then
						Spy:SendCommMessage(Spy.Signature, details, "PARTY")
					end
					if UnitInRaid("player") then
						Spy:SendCommMessage(Spy.Signature, details, "RAID")
					end
					if Spy.InInstance == false and GetGuildInfo("player") ~= nil then
						Spy:SendCommMessage(Spy.Signature, details, "GUILD")
					end
				end
			end
		end
	end	
end

function Spy:SendKoStoGuild(player)
	local playerData = SpyPerCharDB.PlayerData[player]
	local class, level, race, zone, subZone, mapX, mapY, guild, mapID = "", "", "", "", "", "", "", "", ""	 			
	if playerData then
		if playerData.class then class = playerData.class end
		if playerData.level and playerData.isGuess == false then level = playerData.level end
		if playerData.race then race = playerData.race end
		if playerData.zone then zone = playerData.zone end
		if playerData.mapID then mapID = playerData.mapID end
		if playerData.subZone then subZone = playerData.subZone end
		if playerData.mapX then mapX = playerData.mapX end
		if playerData.mapY then mapY = playerData.mapY end
		if playerData.guild then guild = playerData.guild end
	end
	local details = Spy.Version.."|"..player.."|"..class.."|"..level.."|"..race.."|"..zone.."|"..subZone.."|"..mapX.."|"..mapY.."|"..guild.."|"..mapID
	if strlen(details) < 240 then
		if Spy.InInstance == false and GetGuildInfo("player") ~= nil then
			Spy:SendCommMessage(Spy.Signature, details, "GUILD")
		end
	end
end

function Spy:ToggleIgnorePlayer(ignore, player)
	if ignore then
		Spy:AddIgnoreData(player)
		Spy:RemoveKOSData(player)
		if Spy.db.profile.EnableSound then
			PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\list-add.mp3", Spy.db.profile.SoundChannel)
		end
		DEFAULT_CHAT_FRAME:AddMessage(L["SpySignatureColored"]..L["PlayerAddedToIgnoreColored"]..player)
	else
		Spy:RemoveIgnoreData(player)
		if Spy.db.profile.EnableSound then
			PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\list-remove.mp3", Spy.db.profile.SoundChannel)
		end
		DEFAULT_CHAT_FRAME:AddMessage(L["SpySignatureColored"]..L["PlayerRemovedFromIgnoreColored"]..player)
	end
	Spy:RegenerateKOSGuildList()
	if Spy.db.profile.ShareKOSBetweenCharacters then
		Spy:RegenerateKOSCentralList()
	end
	Spy:RefreshCurrentList()
end

function Spy:ToggleKOSPlayer(kos, player)
	if kos then
		Spy:AddKOSData(player)
		Spy:RemoveIgnoreData(player)
		if player ~= SpyPerCharDB.PlayerData[name] then
--			Spy:UpdatePlayerData(player, nil, nil, nil, nil, nil, true, nil)
			Spy:UpdatePlayerStatus(player, nil, nil, nil, nil, nil, true, nil)
			SpyPerCharDB.PlayerData[player].kos = 1
		end	
		if Spy.db.profile.EnableSound then
			PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\list-add.mp3", Spy.db.profile.SoundChannel)
		end
		DEFAULT_CHAT_FRAME:AddMessage(L["SpySignatureColored"]..L["PlayerAddedToKOSColored"]..player)
	else
		Spy:RemoveKOSData(player)
		if Spy.db.profile.EnableSound then
			PlaySoundFile("Interface\\AddOns\\Spy\\Sounds\\list-remove.mp3", Spy.db.profile.SoundChannel)
		end
		DEFAULT_CHAT_FRAME:AddMessage(L["SpySignatureColored"]..L["PlayerRemovedFromKOSColored"]..player)
	end
	Spy:RegenerateKOSGuildList()
	if Spy.db.profile.ShareKOSBetweenCharacters then
		Spy:RegenerateKOSCentralList()
	end
	Spy:RefreshCurrentList()
end

function Spy:PurgeUndetectedData()
	local secondsPerDay = 60 * 60 * 24
	local timeout = 90 * secondsPerDay
	if Spy.db.profile.PurgeData == "OneDay" then
		timeout = secondsPerDay
	elseif Spy.db.profile.PurgeData == "FiveDays" then
		timeout = 5 * secondsPerDay
	elseif Spy.db.profile.PurgeData == "TenDays" then
		timeout = 10 * secondsPerDay
	elseif Spy.db.profile.PurgeData == "ThirtyDays" then
		timeout = 30 * secondsPerDay
	elseif Spy.db.profile.PurgeData == "SixtyDays" then
		timeout = 60 * secondsPerDay
	elseif Spy.db.profile.PurgeData == "NinetyDays" then
		timeout = 90 * secondsPerDay
	end

	-- remove expired players held in character data
	local currentTime = time()
	for player in pairs(SpyPerCharDB.PlayerData) do
		local playerData = SpyPerCharDB.PlayerData[player]
		if Spy.db.profile.PurgeWinLossData then
--			if not playerData.time or (currentTime - playerData.time) > timeout or not playerData.isEnemy then
			if not playerData.time or (currentTime - playerData.time) > timeout then
				Spy:RemoveIgnoreData(player)
				Spy:RemoveKOSData(player)
				SpyPerCharDB.PlayerData[player] = nil
			end
		else
			if ((playerData.loses == nil) and (playerData.wins == nil)) then
--				if not playerData.time or (currentTime - playerData.time) > timeout or not playerData.isEnemy then
				if not playerData.time or (currentTime - playerData.time) > timeout then
					Spy:RemoveIgnoreData(player)
					if Spy.db.profile.PurgeKoS then
						Spy:RemoveKOSData(player)
						SpyPerCharDB.PlayerData[player] = nil
					else
						if (playerData.kos == nil) then
							SpyPerCharDB.PlayerData[player] = nil
						end	
					end	
				end
			end
		end
	end
	
	-- remove expired kos players held in central data
	local kosData = SpyDB.kosData[Spy.RealmName][Spy.FactionName]
	for characterName in pairs(kosData) do
		local characterKosData = kosData[characterName]
		for player in pairs(characterKosData) do
			local kosPlayerData = characterKosData[player]
			if Spy.db.profile.PurgeKoS then
				if not kosPlayerData.time or (currentTime - kosPlayerData.time) > timeout or not kosPlayerData.isEnemy then
					SpyDB.kosData[Spy.RealmName][Spy.FactionName][characterName][player] = nil
					SpyDB.removeKOSData[Spy.RealmName][Spy.FactionName][player] = nil
				end
			end
		end
	end
	if not Spy.db.profile.AppendUnitNameCheck then 	
		Spy:AppendUnitNames() end
	if not Spy.db.profile.AppendUnitKoSCheck then
		Spy:AppendUnitKoS() end
end

function Spy:RegenerateKOSGuildList()
	Spy.KOSGuild = {}
	for player in pairs(SpyPerCharDB.KOSData) do
		local playerData = SpyPerCharDB.PlayerData[player]
		if playerData and playerData.guild then
			Spy.KOSGuild[playerData.guild] = true
		end
	end
end

function Spy:RemoveLocalKOSPlayers()
	for player in pairs(SpyPerCharDB.KOSData) do
		if SpyDB.removeKOSData[Spy.RealmName][Spy.FactionName][player] then
			Spy:RemoveKOSData(player)
		end
	end
end

function Spy:RegenerateKOSCentralList(player)
	if player then
		local playerData = SpyPerCharDB.PlayerData[player]
		SpyDB.kosData[Spy.RealmName][Spy.FactionName][Spy.CharacterName][player] = {}
		if playerData then
			SpyDB.kosData[Spy.RealmName][Spy.FactionName][Spy.CharacterName][player] = playerData
		end
		SpyDB.kosData[Spy.RealmName][Spy.FactionName][Spy.CharacterName][player].added = SpyPerCharDB.KOSData[player]
	else
		for player in pairs(SpyPerCharDB.KOSData) do
			local playerData = SpyPerCharDB.PlayerData[player]
			SpyDB.kosData[Spy.RealmName][Spy.FactionName][Spy.CharacterName][player] = {}
			if playerData then
				SpyDB.kosData[Spy.RealmName][Spy.FactionName][Spy.CharacterName][player] = playerData
			end
			SpyDB.kosData[Spy.RealmName][Spy.FactionName][Spy.CharacterName][player].added = SpyPerCharDB.KOSData[player]
		end
	end
end

function Spy:RegenerateKOSListFromCentral()
	local kosData = SpyDB.kosData[Spy.RealmName][Spy.FactionName]
	for characterName in pairs(kosData) do
		if characterName ~= Spy.CharacterName then
			local characterKosData = kosData[characterName]
			for player in pairs(characterKosData) do
				if not SpyDB.removeKOSData[Spy.RealmName][Spy.FactionName][player] then
					local playerData = SpyPerCharDB.PlayerData[player]
					if not playerData then
						playerData = Spy:AddPlayerData(player, class, level, race, guild, faction, isEnemy, isGuess)
					end
					local kosPlayerData = characterKosData[player]
					if kosPlayerData.time and (not playerData.time or (playerData.time and playerData.time < kosPlayerData.time)) then
						playerData.time = kosPlayerData.time
						if kosPlayerData.class then
							playerData.class = kosPlayerData.class
						end
						if type(kosPlayerData.level) == "number" and (type(playerData.level) ~= "number" or playerData.level < kosPlayerData.level) then
							playerData.level = kosPlayerData.level
						end
						if kosPlayerData.race then
							playerData.race = kosPlayerData.race
						end
						if kosPlayerData.guild then
							playerData.guild = kosPlayerData.guild
						end
						if kosPlayerData.faction then
							playerData.faction = kosPlayerData.faction
						end
						if kosPlayerData.isEnemy then
							playerData.isEnemy = kosPlayerData.isEnemy
						end
						if kosPlayerData.isGuess then
							playerData.isGuess = kosPlayerData.isGuess
						end
						if type(kosPlayerData.wins) == "number" and (type(playerData.wins) ~= "number" or playerData.wins < kosPlayerData.wins) then
							playerData.wins = kosPlayerData.wins
						end
						if type(kosPlayerData.loses) == "number" and (type(playerData.loses) ~= "number" or playerData.loses < kosPlayerData.loses) then
							playerData.loses = kosPlayerData.loses
						end
						if kosPlayerData.mapX then
							playerData.mapX = kosPlayerData.mapX
						end
						if kosPlayerData.mapY then
							playerData.mapY = kosPlayerData.mapY
						end
						if kosPlayerData.zone then
							playerData.zone = kosPlayerData.zone
						end
						if kosPlayerData.mapID then
							playerData.mapID = kosPlayerData.mapID
						end
						if kosPlayerData.subZone then
							playerData.subZone = kosPlayerData.subZone
						end
						if kosPlayerData.reason then
							playerData.reason = {}
							for reason in pairs(kosPlayerData.reason) do
								playerData.reason[reason] = kosPlayerData.reason[reason]
							end
						end
					end
					local characterKOSPlayerData = SpyPerCharDB.KOSData[player]
					if kosPlayerData.added and (not characterKOSPlayerData or characterKOSPlayerData < kosPlayerData.added) then
						SpyPerCharDB.KOSData[player] = kosPlayerData.added
					end
				end
			end
		end
	end
end

function Spy:ButtonClicked(self, button)
	local name = Spy.ButtonName[self.id]
	if name and name ~= "" then
		if button == "LeftButton" then
			if IsShiftKeyDown() then
				if SpyPerCharDB.KOSData[name] then
					Spy:ToggleKOSPlayer(false, name)
				else
					Spy:ToggleKOSPlayer(true, name)
				end
			elseif IsControlKeyDown() then
				if SpyPerCharDB.IgnoreData[name] then
					Spy:ToggleIgnorePlayer(false, name)
				else
					Spy:ToggleIgnorePlayer(true, name)
				end
			else
				if not InCombatLockdown() then
					self:SetAttribute("macrotext", "/targetexact "..name)
				end
			end
		elseif button == "RightButton" then
			Spy:BarDropDownOpen(self)
			CloseDropDownMenus(1)
			ToggleDropDownMenu(1, nil, Spy_BarDropDownMenu)
		end
	end
end

function Spy:ParseMinimapTooltip(tooltip)
	local newTooltip = ""
	local newLine = false
	for text in string.gmatch(tooltip, "[^\n]*") do
		local name = text
		if string.len(text) > 0 then
			if strsub(text, 1, 2) == "|T" then
			name = strtrim(gsub(gsub(text, "|T.-|t", ""), "|r", ""))
			end
			local playerData = SpyPerCharDB.PlayerData[name]
			if not playerData then
				for index, v in pairs(Spy.LastHourList) do
					local realmSeparator = strfind(index, "-")
					if realmSeparator and realmSeparator > 1 and strsub(index, 1, realmSeparator - 1) == strsub(name, 1, realmSeparator - 1) then
						playerData = SpyPerCharDB.PlayerData[index]
						break
					end
				end
			end
			if playerData and playerData.isEnemy then
				local desc = ""
				if playerData.class and playerData.level then
					desc = L["MinimapClassText"..playerData.class].." ["..playerData.level.." "..L[playerData.class].."]|r"
				elseif playerData.class then
					desc = L["MinimapClassText"..playerData.class].." ["..L[playerData.class].."]|r"
				elseif playerData.level then
					desc = " ["..playerData.level.."]|r"
				end
				if (newTooltip and desc == "") then
					newTooltip = text 
				elseif (newTooltip == "") then	
					newTooltip = text.."|r"..desc
				else
					newTooltip = newTooltip.."\r"..text.."|r"..desc
				end	
				if not SpyPerCharDB.IgnoreData[name] and not Spy.InInstance then
					local detected = Spy:UpdatePlayerData(name, nil, nil, nil, nil, nil, true, nil)
					if detected and Spy.db.profile.MinimapDetection then
						Spy:AddDetected(name, time(), false)
					end
				end
			else
				if (newTooltip == "") then
					newTooltip = text
				else	
					newTooltip = newTooltip.."\n"..text
				end
			end
			newLine = false
		elseif not newLine then
			newTooltip = newTooltip
			newLine = true
		end
	end
	return newTooltip
end

function Spy:ParseUnitAbility(analyseSpell, event, player, class, race, spellId, spellName)
	local learnt = false
	if player then
--		local class = nil
		local level = nil
--		local race = nil
		local isEnemy = true
		local isGuess = true

		local playerData = SpyPerCharDB.PlayerData[player]
		if not playerData or playerData.isEnemy == nil then
			learnt = true
		end

		if analyseSpell then
			local abilityType = strsub(event, 1, 5)
			if abilityType == "SWING" or abilityType == "SPELL" or abilityType == "RANGE" then
--				local ability = Spy_AbilityList[spellName]
				local ability = Spy_AbilityList[spellId]
				if ability then
					if class == nil then
						if ability.class and not (playerData and playerData.class) then
							class = ability.class
							learnt = true
						end
					end
					if ability.level then
						local playerLevelNumber = nil
						if playerData and playerData.level then
							playerLevelNumber = tonumber(playerData.level)
						end
						if type(playerLevelNumber) ~= "number" or playerLevelNumber < ability.level then
							level = ability.level
							learnt = true
						end
					end
					if race == nil then
						if ability.race and not (playerData and playerData.race) then
							race = ability.race
							learnt = true
						end
					end	
				else	
--					print(spellId, " - ", spellName)
				end
				if class and race and level == Spy.MaximumPlayerLevel then
					isGuess = false
					learnt = true
				end
			end
		end

		Spy:UpdatePlayerData(player, class, level, race, nil, nil, isEnemy, isGuess)
		return learnt, playerData
	end
	return learnt, nil
end

function Spy:ParseUnitDetails(player, class, level, race, zone, subZone, mapX, mapY, guild, mapID)
	if player then
		local playerData = SpyPerCharDB.PlayerData[player]
		if not playerData then
			playerData = Spy:AddPlayerData(player, class, level, race, guild, nil, true, true)
		else
			if not playerData.class then playerData.class = class end
			if level then
				local levelNumber = tonumber(level)
				if type(levelNumber) == "number" then
					if playerData.level then
						local playerLevelNumber = tonumber(playerData.level)
						if type(playerLevelNumber) == "number" and playerLevelNumber < levelNumber then playerData.level = levelNumber end
					else
						playerData.level = levelNumber
					end
				end
			end
			if not playerData.race then
				playerData.race = race
			end
			if not playerData.guild then
				playerData.guild = guild
			end
		end
		playerData.isEnemy = true
		playerData.time = time()
		playerData.zone = zone
		playerData.mapID = mapID
		playerData.subZone = subZone
		playerData.mapX = mapX
		playerData.mapY = mapY

		return true, playerData
	end
	return true, nil
end

function Spy:AddDetected(player, timestamp, learnt, source)
	if Spy.db.profile.StopAlertsOnTaxi then
		if not UnitOnTaxi("player") then 
			Spy:AddDetectedToLists(player, timestamp, learnt, source)
		end
	else
		Spy:AddDetectedToLists(player, timestamp, learnt, source)
	end
--[[if Spy.db.profile.ShowOnlyPvPFlagged then
		if UnitIsPVP("target") then
			Spy:AddDetectedToLists(player, timestamp, learnt, source)
		end	
	else
		Spy:AddDetectedToLists(player, timestamp, learnt, source)
	end ]]--
end

function Spy:AddDetectedToLists(player, timestamp, learnt, source)
	if not Spy.NearbyList[player] then
		if Spy.db.profile.ShowOnDetection and not Spy.db.profile.MainWindowVis then
			Spy:SetCurrentList(1)
			Spy:EnableSpy(true, true, true)
		end
		if Spy.db.profile.CurrentList ~= 1 and Spy.db.profile.MainWindowVis and Spy.db.profile.ShowNearbyList then
			Spy:SetCurrentList(1)
		end

		if source and source ~= Spy.CharacterName and not Spy.ActiveList[player] then
			Spy.NearbyList[player] = timestamp
			Spy.LastHourList[player] = timestamp
			Spy.InactiveList[player] = timestamp
		else
			Spy.NearbyList[player] = timestamp
			Spy.LastHourList[player] = timestamp
			Spy.ActiveList[player] = timestamp
			Spy.InactiveList[player] = nil
		end

		if Spy.db.profile.CurrentList == 1 then
			Spy:RefreshCurrentList(player, source)
			Spy:UpdateActiveCount()			
		else
			if not source or source ~= Spy.CharacterName then
				Spy:AlertPlayer(player, source)
				if not source then Spy:AnnouncePlayer(player) end
			end
		end
	elseif not Spy.ActiveList[player] then
		if Spy.db.profile.ShowOnDetection and not Spy.db.profile.MainWindowVis then
			Spy:SetCurrentList(1)
			Spy:EnableSpy(true, true, true)
		end
		if Spy.db.profile.CurrentList ~= 1 and Spy.db.profile.MainWindowVis and Spy.db.profile.ShowNearbyList then
			Spy:SetCurrentList(1)
		end

		Spy.LastHourList[player] = timestamp
		Spy.ActiveList[player] = timestamp
		Spy.InactiveList[player] = nil

		if Spy.PlayerCommList[player] ~= nil then
			if Spy.db.profile.CurrentList == 1 then
				Spy:RefreshCurrentList(player, source)
			else
				if not source or source ~= Spy.CharacterName then
					Spy:AlertPlayer(player, source)
					if not source then Spy:AnnouncePlayer(player) end
				end
			end
		else
			if Spy.db.profile.CurrentList == 1 then
				Spy:RefreshCurrentList()
				Spy:UpdateActiveCount()
			end
		end
	else
		Spy.ActiveList[player] = timestamp
		Spy.LastHourList[player] = timestamp
		if learnt and Spy.db.profile.CurrentList == 1 then
			Spy:RefreshCurrentList()
			Spy:UpdateActiveCount()
		end
	end
end

function Spy:AppendUnitNames()
	for key, unit in pairs(SpyPerCharDB.PlayerData) do	
		-- find any units without a name
		if not unit.name then
			local name = key
		-- if unit.name does not exist update info
			if (not unit.name) and name then
				unit.name = key
			end
		end
    end
	-- set profile so it only runs once
	Spy.db.profile.AppendUnitNameCheck=true
end

function Spy:AppendUnitKoS()
	for kosName, value in pairs(SpyPerCharDB.KOSData) do
		if kosName then	
			local playerData = SpyPerCharDB.PlayerData[kosName]
			if not playerData then 
				Spy:UpdatePlayerData(kosName, nil, nil, nil, nil, nil, true, nil) 
				SpyPerCharDB.PlayerData[kosName].kos = 1
				SpyPerCharDB.PlayerData[kosName].time = value
			end
		end
    end
	-- set profile so it only runs once
	Spy.db.profile.AppendUnitKoSCheck=true
end

Spy.ListTypes = {
	{L["Nearby"], Spy.ManageNearbyList, Spy.ManageNearbyListExpirations},
	{L["LastHour"], Spy.ManageLastHourList, Spy.ManageLastHourListExpirations},
	{L["Ignore"], Spy.ManageIgnoreList},
	{L["KillOnSight"], Spy.ManageKillOnSightList},
}

Spy_AbilityList = {
--++ Racial Traits ++	
	[68976]={ race = "Worgen", level = 1, },
	[28877]={ race = "Blood Elf", level = 1, },
	[822]={ race = "Blood Elf", level = 1, },
	[20592]={ race = "Gnome", level = 1, },
	[129597]={ race = "Pandaren", level = 1, },
	[25046]={ race = "Blood Elf", level = 1, },
	[28730]={ race = "Blood Elf", level = 1, },
	[50613]={ race = "Blood Elf", level = 1, },
	[69179]={ race = "Blood Elf", level = 1, },
	[80483]={ race = "Blood Elf", level = 1, },
	[20574]={ race = "Orc", level = 1, },
	[20557]={ race = "Troll", level = 1, },
	[26297]={ race = "Troll", level = 1, },
	[69044]={ race = "Goblin", level = 1, },
	[69045]={ race = "Goblin", level = 1, },
	[20572]={ race = "Orc", level = 1, },
	[33697]={ race = "Orc", level = 1, },
	[33702]={ race = "Orc", level = 1, },
	[107076]={ race = "Pandaren", level = 1, },
	[20577]={ race = "Undead", level = 1, },
	[20575]={ race = "Orc", level = 1, },
	[54562]={ race = "Orc", level = 1, },
	[65222]={ race = "Orc", level = 1, },
	[20595]={ race = "Dwarf", level = 1, },
	[20552]={ race = "Tauren", level = 1, },
	[58943]={ race = "Troll", level = 1, },
	[68992]={ race = "Worgen", level = 1, },
	[26290]={ race = "Troll", level = 1, },
	[20599]={ race = "Human", level = 1, },
	[94293]={ race = "Worgen", level = 1, },
	[20550]={ race = "Tauren", level = 1, },
	[20593]={ race = "Gnome", level = 1, },
	[107072]={ race = "Pandaren", level = 1, },
	[20589]={ race = "Gnome", level = 1, },
	[20591]={ race = "Gnome", level = 1, },
	[92682]={ race = "Dwarf", level = 1, },
	[68978]={ race = "Worgen", level = 1, },
	[20596]={ race = "Dwarf", level = 1, },
	[28875]={ race = "Draenei", level = 1, },
	[121093]={ race = "Draenei", level = 1, },
	[28880]={ race = "Draenei", level = 1, },
	[59542]={ race = "Draenei", level = 1, },
	[59543]={ race = "Draenei", level = 1, },
	[59544]={ race = "Draenei", level = 1, },
	[59545]={ race = "Draenei", level = 1, },
	[59547]={ race = "Draenei", level = 1, },
	[59548]={ race = "Draenei", level = 1, },
	[107073]={ race = "Pandaren", level = 1, },
	[20573]={ race = "Orc", level = 1, },
	[6562]={ race = "Draenei", level = 1, },
	[28878]={ race = "Draenei", level = 1, },
	[107074]={ race = "Pandaren", level = 1, },
	[143368]={ race = "Pandaren", level = 1, },
	[131701]={ race = "Pandaren", level = 1, },
	[143369]={ race = "Pandaren", level = 1, },
	[76252]={ race = "Night Elf", level = 1, },
	[79738]={ race = "Human", level = 1, },
	[79739]={ race = "Dwarf", level = 1, },
	[79740]={ race = "Gnome", level = 1, },
	[79741]={ race = "Draenei", level = 1, },
	[79742]={ race = "Worgen", level = 1, },
	[79743]={ race = "Orc", level = 1, },
	[79744]={ race = "Troll", level = 1, },
	[79746]={ race = "Tauren", level = 1, },
	[79747]={ race = "Undead", level = 1, },
	[79748]={ race = "Blood Elf", level = 1, },
	[79749]={ race = "Goblin", level = 1, },
	[20864]={ race = "Human", level = 1, },
	[59224]={ race = "Dwarf", level = 1, },
	[20551]={ race = "Tauren", level = 1, },
	[20583]={ race = "Night Elf", level = 1, },
	[69046]={ race = "Goblin", level = 1, },
	[107079]={ race = "Pandaren", level = 1, },
	[20582]={ race = "Night Elf", level = 1, },
	[20555]={ race = "Troll", level = 1, },
	[69041]={ race = "Goblin", level = 1, },
	[69070]={ race = "Goblin", level = 1, },
	[87840]={ race = "Worgen", level = 1, },
	[132295]={ race = "Draenei", level = 1, },
	[20579]={ race = "Undead", level = 1, },
	[59221]={ race = "Draenei", level = 1, },
	[59535]={ race = "Draenei", level = 1, },
	[59536]={ race = "Draenei", level = 1, },
	[59538]={ race = "Draenei", level = 1, },
	[59539]={ race = "Draenei", level = 1, },
	[59540]={ race = "Draenei", level = 1, },
	[59541]={ race = "Draenei", level = 1, },
	[58984]={ race = "Night Elf", level = 1, },
	[92680]={ race = "Gnome", level = 1, },
	[20594]={ race = "Dwarf", level = 1, },
	[20597]={ race = "Human", level = 1, },
	[20598]={ race = "Human", level = 1, },
	[20558]={ race = "Troll", level = 1, },
	[69042]={ race = "Goblin", level = 1, },
	[5227]={ race = "Undead", level = 1, },
	[68996]={ race = "Worgen", level = 1, },
	[68975]={ race = "Worgen", level = 1, },
	[20549]={ race = "Tauren", level = 1, },
	[7744]={ race = "Undead", level = 1, },
	[59752]={ race = "Human", level = 1, },
	[20585]={ race = "Night Elf", level = 1, },
--++ Death Knight ++	
	[58623]={ class = "DEATHKNIGHT", level = 55, },
	[58669]={ class = "DEATHKNIGHT", level = 55, },
	[59336]={ class = "DEATHKNIGHT", level = 55, },
	[63330]={ class = "DEATHKNIGHT", level = 55, },
	[63331]={ class = "DEATHKNIGHT", level = 55, },
	[96279]={ class = "DEATHKNIGHT", level = 55, },
	[58629]={ class = "DEATHKNIGHT", level = 55, },
	[63333]={ class = "DEATHKNIGHT", level = 55, },
	[60200]={ class = "DEATHKNIGHT", level = 55, },
	[62259]={ class = "DEATHKNIGHT", level = 55, },
	[58671]={ class = "DEATHKNIGHT", level = 55, },
	[146650]={ class = "DEATHKNIGHT", level = 55, },
	[58631]={ class = "DEATHKNIGHT", level = 55, },
	[58686]={ class = "DEATHKNIGHT", level = 55, },
	[59332]={ class = "DEATHKNIGHT", level = 55, },
	[59307]={ class = "DEATHKNIGHT", level = 55, },
	[58657]={ class = "DEATHKNIGHT", level = 55, },
	[58635]={ class = "DEATHKNIGHT", level = 55, },
	[146648]={ class = "DEATHKNIGHT", level = 55, },
	[59309]={ class = "DEATHKNIGHT", level = 55, },
	[58618]={ class = "DEATHKNIGHT", level = 55, },
	[146645]={ class = "DEATHKNIGHT", level = 55, },
	[58640]={ class = "DEATHKNIGHT", level = 55, },
	[146653]={ class = "DEATHKNIGHT", level = 55, },
	[146646]={ class = "DEATHKNIGHT", level = 55, },
	[146652]={ class = "DEATHKNIGHT", level = 55, },
	[63335]={ class = "DEATHKNIGHT", level = 55, },
	[59327]={ class = "DEATHKNIGHT", level = 55, },
	[58620]={ class = "DEATHKNIGHT", level = 55, },
	[58677]={ class = "DEATHKNIGHT", level = 55, },
	[58642]={ class = "DEATHKNIGHT", level = 55, },
	[58680]={ class = "DEATHKNIGHT", level = 55, },
	[58673]={ class = "DEATHKNIGHT", level = 55, },
	[58647]={ class = "DEATHKNIGHT", level = 55, },
	[58616]={ class = "DEATHKNIGHT", level = 55, },
	[58676]={ class = "DEATHKNIGHT", level = 55, },
	[137006]={ class = "DEATHKNIGHT", level = 55, },
	[137007]={ class = "DEATHKNIGHT", level = 55, },
	[137008]={ class = "DEATHKNIGHT", level = 55, },
	[73313]={ class = "DEATHKNIGHT", level = 55, },
	[51052]={ class = "DEATHKNIGHT", level = 55, },
	[108194]={ class = "DEATHKNIGHT", level = 55, },
	[50041]={ class = "DEATHKNIGHT", level = 55, },
	[96268]={ class = "DEATHKNIGHT", level = 55, },
	[49039]={ class = "DEATHKNIGHT", level = 55, },
	[123693]={ class = "DEATHKNIGHT", level = 55, },
	[114556]={ class = "DEATHKNIGHT", level = 55, },
	[108170]={ class = "DEATHKNIGHT", level = 55, },
	[115989]={ class = "DEATHKNIGHT", level = 55, },
	[119975]={ class = "DEATHKNIGHT", level = 60, },
	[48743]={ class = "DEATHKNIGHT", level = 60, },
	[108196]={ class = "DEATHKNIGHT", level = 60, },
	[45529]={ class = "DEATHKNIGHT", level = 75, },
	[51462]={ class = "DEATHKNIGHT", level = 75, },
	[81229]={ class = "DEATHKNIGHT", level = 75, },
	[108201]={ class = "DEATHKNIGHT", level = 90, },
	[108199]={ class = "DEATHKNIGHT", level = 90, },
	[108200]={ class = "DEATHKNIGHT", level = 90, },
	[89832]={ class = "DEATHKNIGHT", level = 55, },
	[137005]={ class = "DEATHKNIGHT", level = 55, },
	[110498]={ class = "DEATHKNIGHT", level = 55, },
	[54729]={ class = "DEATHKNIGHT", level = 55, },
	[82246]={ class = "DEATHKNIGHT", level = 55, },
	[61250]={ class = "DEATHKNIGHT", level = 55, },
	[86524]={ class = "DEATHKNIGHT", level = 55, },
	[54637]={ class = "DEATHKNIGHT", level = 55, },
	[50034]={ class = "DEATHKNIGHT", level = 55, },
	[49143]={ class = "DEATHKNIGHT", level = 55, },
	[49184]={ class = "DEATHKNIGHT", level = 55, },
	[50887]={ class = "DEATHKNIGHT", level = 55, },
	[52143]={ class = "DEATHKNIGHT", level = 55, },
	[86113]={ class = "DEATHKNIGHT", level = 55, },
	[86536]={ class = "DEATHKNIGHT", level = 55, },
	[86537]={ class = "DEATHKNIGHT", level = 55, },
	[56835]={ class = "DEATHKNIGHT", level = 55, },
	[91107]={ class = "DEATHKNIGHT", level = 55, },
	[93099]={ class = "DEATHKNIGHT", level = 55, },
	[50029]={ class = "DEATHKNIGHT", level = 55, },
	[48778]={ class = "DEATHKNIGHT", level = 55, },
	[59879]={ class = "DEATHKNIGHT", level = 55, },
	[45902]={ class = "DEATHKNIGHT", level = 55, },
	[47541]={ class = "DEATHKNIGHT", level = 55, },
	[50977]={ class = "DEATHKNIGHT", level = 55, },
	[49576]={ class = "DEATHKNIGHT", level = 55, },
	[59921]={ class = "DEATHKNIGHT", level = 55, },
	[48266]={ class = "DEATHKNIGHT", level = 55, },
	[45477]={ class = "DEATHKNIGHT", level = 55, },
	[45462]={ class = "DEATHKNIGHT", level = 55, },
	[53341]={ class = "DEATHKNIGHT", level = 55, },
	[53343]={ class = "DEATHKNIGHT", level = 55, },
	[53428]={ class = "DEATHKNIGHT", level = 55, },
	[48721]={ class = "DEATHKNIGHT", level = 56, },
	[49998]={ class = "DEATHKNIGHT", level = 56, },
	[50842]={ class = "DEATHKNIGHT", level = 56, },
	[46584]={ class = "DEATHKNIGHT", level = 56, },
	[48263]={ class = "DEATHKNIGHT", level = 57, },
	[47528]={ class = "DEATHKNIGHT", level = 57, },
	[54447]={ class = "DEATHKNIGHT", level = 57, },
	[53342]={ class = "DEATHKNIGHT", level = 57, },
	[49020]={ class = "DEATHKNIGHT", level = 58, },
	[55090]={ class = "DEATHKNIGHT", level = 58, },
	[55050]={ class = "DEATHKNIGHT", level = 60, },
	[49572]={ class = "DEATHKNIGHT", level = 60, },
	[55610]={ class = "DEATHKNIGHT", level = 60, },
	[53331]={ class = "DEATHKNIGHT", level = 60, },
	[51986]={ class = "DEATHKNIGHT", level = 61, },
	[85948]={ class = "DEATHKNIGHT", level = 62, },
	[49509]={ class = "DEATHKNIGHT", level = 62, },
	[148211]={ class = "DEATHKNIGHT", level = 62, },
	[48792]={ class = "DEATHKNIGHT", level = 62, },
	[51128]={ class = "DEATHKNIGHT", level = 63, },
	[54446]={ class = "DEATHKNIGHT", level = 63, },
	[53323]={ class = "DEATHKNIGHT", level = 63, },
	[50371]={ class = "DEATHKNIGHT", level = 64, },
	[48982]={ class = "DEATHKNIGHT", level = 64, },
	[49530]={ class = "DEATHKNIGHT", level = 64, },
	[48265]={ class = "DEATHKNIGHT", level = 64, },
	[50385]={ class = "DEATHKNIGHT", level = 65, },
	[56815]={ class = "DEATHKNIGHT", level = 65, },
	[49542]={ class = "DEATHKNIGHT", level = 66, },
	[81328]={ class = "DEATHKNIGHT", level = 66, },
	[51160]={ class = "DEATHKNIGHT", level = 68, },
	[51271]={ class = "DEATHKNIGHT", level = 68, },
	[81132]={ class = "DEATHKNIGHT", level = 68, },
	[48707]={ class = "DEATHKNIGHT", level = 68, },
	[111673]={ class = "DEATHKNIGHT", level = 69, },
	[63560]={ class = "DEATHKNIGHT", level = 70, },
	[59057]={ class = "DEATHKNIGHT", level = 70, },
	[81164]={ class = "DEATHKNIGHT", level = 70, },
	[53344]={ class = "DEATHKNIGHT", level = 70, },
	[62158]={ class = "DEATHKNIGHT", level = 70, },
	[81127]={ class = "DEATHKNIGHT", level = 72, },
	[61999]={ class = "DEATHKNIGHT", level = 72, },
	[70164]={ class = "DEATHKNIGHT", level = 72, },
	[49028]={ class = "DEATHKNIGHT", level = 74, },
	[81333]={ class = "DEATHKNIGHT", level = 74, },
	[66192]={ class = "DEATHKNIGHT", level = 74, },
	[50392]={ class = "DEATHKNIGHT", level = 75, },
	[145676]={ class = "DEATHKNIGHT", level = 76, },
	[55233]={ class = "DEATHKNIGHT", level = 76, },
	[47568]={ class = "DEATHKNIGHT", level = 76, },
	[49222]={ class = "DEATHKNIGHT", level = 78, },
	[77513]={ class = "DEATHKNIGHT", level = 80, },
	[77515]={ class = "DEATHKNIGHT", level = 80, },
	[77514]={ class = "DEATHKNIGHT", level = 80, },
	[42650]={ class = "DEATHKNIGHT", level = 80, },
	[77575]={ class = "DEATHKNIGHT", level = 81, },
	[73975]={ class = "DEATHKNIGHT", level = 83, },
	[81136]={ class = "DEATHKNIGHT", level = 84, },
	[114866]={ class = "DEATHKNIGHT", level = 87, },
	[130735]={ class = "DEATHKNIGHT", level = 87, },
	[130736]={ class = "DEATHKNIGHT", level = 87, },
--++ Druid ++	
	[57856]={ class = "DRUID", level = 25, },
	[63057]={ class = "DRUID", level = 25, },
	[121840]={ class = "DRUID", level = 25, },
	[47180]={ class = "DRUID", level = 25, },
	[57855]={ class = "DRUID", level = 25, },
	[59219]={ class = "DRUID", level = 25, },
	[145529]={ class = "DRUID", level = 25, },
	[54760]={ class = "DRUID", level = 25, },
	[114237]={ class = "DRUID", level = 25, },
	[94386]={ class = "DRUID", level = 25, },
	[67598]={ class = "DRUID", level = 25, },
	[62080]={ class = "DRUID", level = 25, },
	[54810]={ class = "DRUID", level = 25, },
	[114295]={ class = "DRUID", level = 25, },
	[146655]={ class = "DRUID", level = 25, },
	[54825]={ class = "DRUID", level = 25, },
	[54831]={ class = "DRUID", level = 25, },
	[54832]={ class = "DRUID", level = 25, },
	[54811]={ class = "DRUID", level = 25, },
	[116238]={ class = "DRUID", level = 25, },
	[54812]={ class = "DRUID", level = 25, },
	[146656]={ class = "DRUID", level = 25, },
	[54821]={ class = "DRUID", level = 25, },
	[54733]={ class = "DRUID", level = 25, },
	[116218]={ class = "DRUID", level = 25, },
	[127540]={ class = "DRUID", level = 25, },
	[114234]={ class = "DRUID", level = 25, },
	[114300]={ class = "DRUID", level = 25, },
	[114222]={ class = "DRUID", level = 25, },
	[114301]={ class = "DRUID", level = 25, },
	[114223]={ class = "DRUID", level = 25, },
	[107059]={ class = "DRUID", level = 25, },
	[131113]={ class = "DRUID", level = 25, },
	[116172]={ class = "DRUID", level = 25, },
	[114333]={ class = "DRUID", level = 25, },
	[114280]={ class = "DRUID", level = 25, },
	[146654]={ class = "DRUID", level = 25, },
	[114338]={ class = "DRUID", level = 25, },
	[62970]={ class = "DRUID", level = 25, },
	[48514]={ class = "DRUID", level = 25, },
	[116203]={ class = "DRUID", level = 25, },
	[116186]={ class = "DRUID", level = 25, },
	[116216]={ class = "DRUID", level = 25, },
	[125047]={ class = "DRUID", level = 25, },
	[137010]={ class = "DRUID", level = 1, },
	[137011]={ class = "DRUID", level = 1, },
	[137012]={ class = "DRUID", level = 1, },
	[137013]={ class = "DRUID", level = 1, },
	[102280]={ class = "DRUID", level = 15, },
	[131768]={ class = "DRUID", level = 15, },
	[102401]={ class = "DRUID", level = 15, },
	[102351]={ class = "DRUID", level = 30, },
	[108238]={ class = "DRUID", level = 30, },
	[145108]={ class = "DRUID", level = 30, },
	[106707]={ class = "DRUID", level = 45, },
	[132469]={ class = "DRUID", level = 45, },
	[106737]={ class = "DRUID", level = 60, },
	[37846]={ class = "DRUID", level = 60, },
	[106731]={ class = "DRUID", level = 60, },
	[114107]={ class = "DRUID", level = 60, },
	[102794]={ class = "DRUID", level = 75, },
	[108373]={ class = "DRUID", level = 90, },
	[108288]={ class = "DRUID", level = 90, },
	[137009]={ class = "DRUID", level = 1, },
	[5420]={ class = "DRUID", level = 1, },
	[81097]={ class = "DRUID", level = 1, },
	[81098]={ class = "DRUID", level = 1, },
	[106732]={ class = "DRUID", level = 1, },
	[106733]={ class = "DRUID", level = 1, },
	[106734]={ class = "DRUID", level = 1, },
	[106735]={ class = "DRUID", level = 1, },
	[102352]={ class = "DRUID", level = 1, },
	[81269]={ class = "DRUID", level = 1, },
	[102354]={ class = "DRUID", level = 1, },
	[102355]={ class = "DRUID", level = 1, },
	[96206]={ class = "DRUID", level = 1, },
	[102543]={ class = "DRUID", level = 1, },
	[102558]={ class = "DRUID", level = 1, },
	[48503]={ class = "DRUID", level = 1, },
	[5176]={ class = "DRUID", level = 1, },
	[145109]={ class = "DRUID", level = 1, },
	[145110]={ class = "DRUID", level = 1, },
	[768]={ class = "DRUID", level = 6, },
	[20719]={ class = "DRUID", level = 6, },
	[125972]={ class = "DRUID", level = 6, },
	[22568]={ class = "DRUID", level = 6, },
	[80863]={ class = "DRUID", level = 6, },
	[33876]={ class = "DRUID", level = 6, },
	[33878]={ class = "DRUID", level = 6, },
	[33917]={ class = "DRUID", level = 6, },
	[5215]={ class = "DRUID", level = 6, },
	[102547]={ class = "DRUID", level = 6, },
	[5487]={ class = "DRUID", level = 8, },
	[17057]={ class = "DRUID", level = 8, },
	[6807]={ class = "DRUID", level = 8, },
	[33596]={ class = "DRUID", level = 10, },
	[79577]={ class = "DRUID", level = 10, },
	[112857]={ class = "DRUID", level = 10, },
	[17073]={ class = "DRUID", level = 10, },
	[62606]={ class = "DRUID", level = 10, },
	[2912]={ class = "DRUID", level = 10, },
	[18562]={ class = "DRUID", level = 10, },
	[5217]={ class = "DRUID", level = 10, },
	[84840]={ class = "DRUID", level = 10, },
	[16870]={ class = "DRUID", level = 10, },
	[102560]={ class = "DRUID", level = 10, },
	[50464]={ class = "DRUID", level = 12, },
	[78674]={ class = "DRUID", level = 12, },
	[50769]={ class = "DRUID", level = 12, },
	[84738]={ class = "DRUID", level = 14, },
	[16949]={ class = "DRUID", level = 14, },
	[85101]={ class = "DRUID", level = 14, },
	[16931]={ class = "DRUID", level = 14, },
	[18960]={ class = "DRUID", level = 14, },
	[24858]={ class = "DRUID", level = 16, },
	[84736]={ class = "DRUID", level = 16, },
	[5221]={ class = "DRUID", level = 16, },
	[783]={ class = "DRUID", level = 16, },
	[102795]={ class = "DRUID", level = 18, },
	[52610]={ class = "DRUID", level = 18, },
	[1066]={ class = "DRUID", level = 18, },
	[127663]={ class = "DRUID", level = 20, },
	[88423]={ class = "DRUID", level = 22, },
	[2782]={ class = "DRUID", level = 22, },
	[102545]={ class = "DRUID", level = 22, },
	[779]={ class = "DRUID", level = 22, },
	[62078]={ class = "DRUID", level = 22, },
	[106785]={ class = "DRUID", level = 22, },
	[1850]={ class = "DRUID", level = 24, },
	[16974]={ class = "DRUID", level = 26, },
	[93399]={ class = "DRUID", level = 26, },
	[5185]={ class = "DRUID", level = 26, },
	[48500]={ class = "DRUID", level = 28, },
	[78675]={ class = "DRUID", level = 28, },
	[106832]={ class = "DRUID", level = 28, },
	[115800]={ class = "DRUID", level = 28, },
	[770]={ class = "DRUID", level = 28, },
	[106830]={ class = "DRUID", level = 28, },
	[132158]={ class = "DRUID", level = 30, },
	[16961]={ class = "DRUID", level = 30, },
	[135288]={ class = "DRUID", level = 32, },
	[102546]={ class = "DRUID", level = 32, },
	[108299]={ class = "DRUID", level = 34, },
	[33873]={ class = "DRUID", level = 34, },
	[5225]={ class = "DRUID", level = 36, },
	[81062]={ class = "DRUID", level = 38, },
	[16864]={ class = "DRUID", level = 38, },
	[113043]={ class = "DRUID", level = 38, },
	[48484]={ class = "DRUID", level = 40, },
	[106996]={ class = "DRUID", level = 42, },
	[106998]={ class = "DRUID", level = 44, },
	[22812]={ class = "DRUID", level = 44, },
	[450759]={ class = "DRUID", level = 44, },
	[17007]={ class = "DRUID", level = 46, },
	[33886]={ class = "DRUID", level = 46, },
	[106952]={ class = "DRUID", level = 48, },
	[48393]={ class = "DRUID", level = 48, },
	[86093]={ class = "DRUID", level = 50, },
	[86096]={ class = "DRUID", level = 50, },
	[86097]={ class = "DRUID", level = 50, },
	[86104]={ class = "DRUID", level = 50, },
	[17076]={ class = "DRUID", level = 54, },
	[6785]={ class = "DRUID", level = 54, },
	[61336]={ class = "DRUID", level = 56, },
	[20484]={ class = "DRUID", level = 56, },
	[33943]={ class = "DRUID", level = 58, },
	[2908]={ class = "DRUID", level = 60, },
	[1126]={ class = "DRUID", level = 62, },
	[102342]={ class = "DRUID", level = 64, },
	[106839]={ class = "DRUID", level = 64, },
	[33778]={ class = "DRUID", level = 64, },
	[94447]={ class = "DRUID", level = 64, },
	[112071]={ class = "DRUID", level = 68, },
	[22842]={ class = "DRUID", level = 68, },
	[40120]={ class = "DRUID", level = 70, },
	[106922]={ class = "DRUID", level = 72, },
	[5229]={ class = "DRUID", level = 76, },
	[48505]={ class = "DRUID", level = 76, },
	[48438]={ class = "DRUID", level = 76, },
	[33786]={ class = "DRUID", level = 78, },
	[77495]={ class = "DRUID", level = 80, },
	[77494]={ class = "DRUID", level = 80, },
	[77493]={ class = "DRUID", level = 80, },
	[77492]={ class = "DRUID", level = 80, },
	[33605]={ class = "DRUID", level = 82, },
	[92364]={ class = "DRUID", level = 82, },
	[138611]={ class = "DRUID", level = 82, },
	[88747]={ class = "DRUID", level = 84, },
	[145205]={ class = "DRUID", level = 84, },
	[102791]={ class = "DRUID", level = 84, },
	[88751]={ class = "DRUID", level = 84, },
	[106898]={ class = "DRUID", level = 84, },
	[97993]={ class = "DRUID", level = 84, },
	[102792]={ class = "DRUID", level = 84, },
	[78777]={ class = "DRUID", level = 84, },
	[110309]={ class = "DRUID", level = 87, },
	[145518]={ class = "DRUID", level = 88, },
--++ Hunter ++	
	[126095]={ class = "HUNTER", level = 25, },
	[20895]={ class = "HUNTER", level = 25, },
	[119462]={ class = "HUNTER", level = 25, },
	[57904]={ class = "HUNTER", level = 25, },
	[122492]={ class = "HUNTER", level = 25, },
	[109263]={ class = "HUNTER", level = 25, },
	[119449]={ class = "HUNTER", level = 25, },
	[148484]={ class = "HUNTER", level = 25, },
	[119447]={ class = "HUNTER", level = 25, },
	[56850]={ class = "HUNTER", level = 25, },
	[126179]={ class = "HUNTER", level = 25, },
	[56844]={ class = "HUNTER", level = 25, },
	[123632]={ class = "HUNTER", level = 25, },
	[119410]={ class = "HUNTER", level = 25, },
	[148475]={ class = "HUNTER", level = 25, },
	[119403]={ class = "HUNTER", level = 25, },
	[57903]={ class = "HUNTER", level = 25, },
	[148473]={ class = "HUNTER", level = 25, },
	[56845]={ class = "HUNTER", level = 25, },
	[56847]={ class = "HUNTER", level = 25, },
	[57870]={ class = "HUNTER", level = 25, },
	[126193]={ class = "HUNTER", level = 25, },
	[63068]={ class = "HUNTER", level = 25, },
	[19573]={ class = "HUNTER", level = 25, },
	[56833]={ class = "HUNTER", level = 25, },
	[83495]={ class = "HUNTER", level = 25, },
	[56829]={ class = "HUNTER", level = 25, },
	[53299]={ class = "HUNTER", level = 25, },
	[19560]={ class = "HUNTER", level = 25, },
	[57866]={ class = "HUNTER", level = 25, },
	[63069]={ class = "HUNTER", level = 25, },
	[56849]={ class = "HUNTER", level = 25, },
	[119407]={ class = "HUNTER", level = 25, },
	[57902]={ class = "HUNTER", level = 25, },
	[119464]={ class = "HUNTER", level = 25, },
	[146657]={ class = "HUNTER", level = 25, },
	[119384]={ class = "HUNTER", level = 25, },
	[125042]={ class = "HUNTER", level = 25, },
	[126746]={ class = "HUNTER", level = 25, },
	[137015]={ class = "HUNTER", level = 1, },
	[137016]={ class = "HUNTER", level = 1, },
	[137017]={ class = "HUNTER", level = 1, },
	[82684]={ class = "HUNTER", level = 13, },
	[118675]={ class = "HUNTER", level = 15, },
	[109298]={ class = "HUNTER", level = 15, },
	[109215]={ class = "HUNTER", level = 15, },
	[109248]={ class = "HUNTER", level = 30, },
	[109260]={ class = "HUNTER", level = 45, },
	[109304]={ class = "HUNTER", level = 45, },
	[109212]={ class = "HUNTER", level = 45, },
	[120679]={ class = "HUNTER", level = 60, },
	[82726]={ class = "HUNTER", level = 60, },
	[109306]={ class = "HUNTER", level = 60, },
	[130392]={ class = "HUNTER", level = 75, },
	[120697]={ class = "HUNTER", level = 75, },
	[120360]={ class = "HUNTER", level = 90, },
	[117050]={ class = "HUNTER", level = 90, },
	[109259]={ class = "HUNTER", level = 90, },
	[138430]={ class = "HUNTER", level = 90, },
	[87324]={ class = "HUNTER", level = 3, },
	[137014]={ class = "HUNTER", level = 1, },
	[53296]={ class = "HUNTER", level = 1, },
	[82683]={ class = "HUNTER", level = 1, },
	[19287]={ class = "HUNTER", level = 1, },
	[136311]={ class = "HUNTER", level = 1, },
	[143392]={ class = "HUNTER", level = 1, },
	[3044]={ class = "HUNTER", level = 1, },
	[75]={ class = "HUNTER", level = 1, },
	[883]={ class = "HUNTER", level = 1, },
	[77442]={ class = "HUNTER", level = 1, },
	[982]={ class = "HUNTER", level = 1, },
	[110497]={ class = "HUNTER", level = 1, },
	[56641]={ class = "HUNTER", level = 3, },
	[1494]={ class = "HUNTER", level = 4, },
	[19878]={ class = "HUNTER", level = 4, },
	[19879]={ class = "HUNTER", level = 4, },
	[19880]={ class = "HUNTER", level = 4, },
	[19882]={ class = "HUNTER", level = 4, },
	[19885]={ class = "HUNTER", level = 4, },
	[19883]={ class = "HUNTER", level = 4, },
	[19884]={ class = "HUNTER", level = 4, },
	[118424]={ class = "HUNTER", level = 4, },
	[5116]={ class = "HUNTER", level = 8, },
	[19434]={ class = "HUNTER", level = 10, },
	[53301]={ class = "HUNTER", level = 10, },
	[34026]={ class = "HUNTER", level = 10, },
	[1462]={ class = "HUNTER", level = 10, },
	[93321]={ class = "HUNTER", level = 10, },
	[93322]={ class = "HUNTER", level = 10, },
	[2641]={ class = "HUNTER", level = 10, },
	[1978]={ class = "HUNTER", level = 10, },
	[1515]={ class = "HUNTER", level = 10, },
	[6991]={ class = "HUNTER", level = 11, },
	[13165]={ class = "HUNTER", level = 12, },
	[781]={ class = "HUNTER", level = 14, },
	[1130]={ class = "HUNTER", level = 14, },
	[19503]={ class = "HUNTER", level = 15, },
	[6197]={ class = "HUNTER", level = 16, },
	[136]={ class = "HUNTER", level = 16, },
	[83242]={ class = "HUNTER", level = 18, },
	[34483]={ class = "HUNTER", level = 20, },
	[34954]={ class = "HUNTER", level = 20, },
	[147362]={ class = "HUNTER", level = 22, },
	[115939]={ class = "HUNTER", level = 24, },
	[5118]={ class = "HUNTER", level = 24, },
	[2643]={ class = "HUNTER", level = 24, },
	[1499]={ class = "HUNTER", level = 28, },
	[35102]={ class = "HUNTER", level = 30, },
	[19623]={ class = "HUNTER", level = 30, },
	[34490]={ class = "HUNTER", level = 30, },
	[82692]={ class = "HUNTER", level = 32, },
	[5384]={ class = "HUNTER", level = 32, },
	[53351]={ class = "HUNTER", level = 35, },
	[19801]={ class = "HUNTER", level = 35, },
	[1513]={ class = "HUNTER", level = 36, },
	[13813]={ class = "HUNTER", level = 38, },
	[1543]={ class = "HUNTER", level = 38, },
	[19574]={ class = "HUNTER", level = 40, },
	[82654]={ class = "HUNTER", level = 40, },
	[83243]={ class = "HUNTER", level = 42, },
	[132106]={ class = "HUNTER", level = 43, },
	[53260]={ class = "HUNTER", level = 43, },
	[56343]={ class = "HUNTER", level = 43, },
	[35110]={ class = "HUNTER", level = 45, },
	[13809]={ class = "HUNTER", level = 46, },
	[77769]={ class = "HUNTER", level = 48, },
	[34692]={ class = "HUNTER", level = 50, },
	[86538]={ class = "HUNTER", level = 50, },
	[20736]={ class = "HUNTER", level = 52, },
	[53232]={ class = "HUNTER", level = 54, },
	[3045]={ class = "HUNTER", level = 54, },
	[19387]={ class = "HUNTER", level = 55, },
	[56315]={ class = "HUNTER", level = 58, },
	[34487]={ class = "HUNTER", level = 58, },
	[53209]={ class = "HUNTER", level = 60, },
	[83244]={ class = "HUNTER", level = 62, },
	[53253]={ class = "HUNTER", level = 63, },
	[53224]={ class = "HUNTER", level = 63, },
	[118976]={ class = "HUNTER", level = 63, },
	[63458]={ class = "HUNTER", level = 64, },
	[34600]={ class = "HUNTER", level = 66, },
	[87935]={ class = "HUNTER", level = 68, },
	[53270]={ class = "HUNTER", level = 69, },
	[82834]={ class = "HUNTER", level = 70, },
	[53238]={ class = "HUNTER", level = 72, },
	[53271]={ class = "HUNTER", level = 74, },
	[34477]={ class = "HUNTER", level = 76, },
	[19263]={ class = "HUNTER", level = 78, },
	[76658]={ class = "HUNTER", level = 80, },
	[76657]={ class = "HUNTER", level = 80, },
	[76659]={ class = "HUNTER", level = 80, },
	[77767]={ class = "HUNTER", level = 81, },
	[83245]={ class = "HUNTER", level = 82, },
	[51753]={ class = "HUNTER", level = 85, },
	[121818]={ class = "HUNTER", level = 87, },
--++ Mage ++	
	[115718]={ class = "MAGE", level = 25, },
	[57925]={ class = "MAGE", level = 25, },
	[62210]={ class = "MAGE", level = 25, },
	[98397]={ class = "MAGE", level = 25, },
	[56365]={ class = "MAGE", level = 25, },
	[56368]={ class = "MAGE", level = 25, },
	[147353]={ class = "MAGE", level = 25, },
	[115705]={ class = "MAGE", level = 25, },
	[115703]={ class = "MAGE", level = 25, },
	[56382]={ class = "MAGE", level = 25, },
	[115710]={ class = "MAGE", level = 25, },
	[134580]={ class = "MAGE", level = 25, },
	[146662]={ class = "MAGE", level = 25, },
	[56380]={ class = "MAGE", level = 25, },
	[56376]={ class = "MAGE", level = 25, },
	[61205]={ class = "MAGE", level = 25, },
	[115723]={ class = "MAGE", level = 25, },
	[56364]={ class = "MAGE", level = 25, },
	[63092]={ class = "MAGE", level = 25, },
	[89926]={ class = "MAGE", level = 25, },
	[56363]={ class = "MAGE", level = 25, },
	[56383]={ class = "MAGE", level = 25, },
	[63093]={ class = "MAGE", level = 25, },
	[56384]={ class = "MAGE", level = 25, },
	[56375]={ class = "MAGE", level = 25, },
	[146659]={ class = "MAGE", level = 25, },
	[89749]={ class = "MAGE", level = 25, },
	[115700]={ class = "MAGE", level = 25, },
	[115713]={ class = "MAGE", level = 25, },
	[56377]={ class = "MAGE", level = 25, },
	[58136]={ class = "MAGE", level = 25, },
	[57927]={ class = "MAGE", level = 25, },
	[52648]={ class = "MAGE", level = 25, },
	[57924]={ class = "MAGE", level = 25, },
	[146976]={ class = "MAGE", level = 25, },
	[63090]={ class = "MAGE", level = 25, },
	[126748]={ class = "MAGE", level = 25, },
	[86209]={ class = "MAGE", level = 25, },
	[137019]={ class = "MAGE", level = 1, },
	[137020]={ class = "MAGE", level = 1, },
	[137021]={ class = "MAGE", level = 1, },
	[108843]={ class = "MAGE", level = 15, },
	[108839]={ class = "MAGE", level = 15, },
	[12043]={ class = "MAGE", level = 15, },
	[140468]={ class = "MAGE", level = 30, },
	[11426]={ class = "MAGE", level = 30, },
	[115610]={ class = "MAGE", level = 30, },
	[113724]={ class = "MAGE", level = 45, },
	[86949]={ class = "MAGE", level = 60, },
	[11958]={ class = "MAGE", level = 60, },
	[110959]={ class = "MAGE", level = 60, },
	[114923]={ class = "MAGE", level = 75, },
	[1463]={ class = "MAGE", level = 90, },
	[114003]={ class = "MAGE", level = 90, },
	[116011]={ class = "MAGE", level = 90, },
	[137018]={ class = "MAGE", level = 1, },
	[114995]={ class = "MAGE", level = 1, },
	[44614]={ class = "MAGE", level = 1, },
	[121039]={ class = "MAGE", level = 1, },
	[110499]={ class = "MAGE", level = 1, },
	[122]={ class = "MAGE", level = 3, },
	[115757]={ class = "MAGE", level = 3, },
	[2136]={ class = "MAGE", level = 5, },
	[1953]={ class = "MAGE", level = 7, },
	[2139]={ class = "MAGE", level = 8, },
	[30451]={ class = "MAGE", level = 10, },
	[114664]={ class = "MAGE", level = 10, },
	[11366]={ class = "MAGE", level = 10, },
	[44448]={ class = "MAGE", level = 10, },
	[31687]={ class = "MAGE", level = 10, },
	[44425]={ class = "MAGE", level = 12, },
	[133]={ class = "MAGE", level = 12, },
	[116]={ class = "MAGE", level = 12, },
	[118]={ class = "MAGE", level = 14, },
	[12982]={ class = "MAGE", level = 16, },
	[3565]={ class = "MAGE", level = 17, },
	[32271]={ class = "MAGE", level = 17, },
	[3562]={ class = "MAGE", level = 17, },
	[3567]={ class = "MAGE", level = 17, },
	[32272]={ class = "MAGE", level = 17, },
	[3561]={ class = "MAGE", level = 17, },
	[49359]={ class = "MAGE", level = 17, },
	[3566]={ class = "MAGE", level = 17, },
	[3563]={ class = "MAGE", level = 17, },
	[1449]={ class = "MAGE", level = 18, },
	[30455]={ class = "MAGE", level = 22, },
	[5143]={ class = "MAGE", level = 24, },
	[79684]={ class = "MAGE", level = 24, },
	[112965]={ class = "MAGE", level = 24, },
	[108853]={ class = "MAGE", level = 24, },
	[45438]={ class = "MAGE", level = 26, },
	[120]={ class = "MAGE", level = 28, },
	[475]={ class = "MAGE", level = 29, },
	[130]={ class = "MAGE", level = 32, },
	[30482]={ class = "MAGE", level = 34, },
	[117216]={ class = "MAGE", level = 36, },
	[12472]={ class = "MAGE", level = 36, },
	[31589]={ class = "MAGE", level = 36, },
	[42955]={ class = "MAGE", level = 38, },
	[12051]={ class = "MAGE", level = 40, },
	[11419]={ class = "MAGE", level = 42, },
	[32266]={ class = "MAGE", level = 42, },
	[11416]={ class = "MAGE", level = 42, },
	[11417]={ class = "MAGE", level = 42, },
	[32267]={ class = "MAGE", level = 42, },
	[10059]={ class = "MAGE", level = 42, },
	[49360]={ class = "MAGE", level = 42, },
	[11420]={ class = "MAGE", level = 42, },
	[11418]={ class = "MAGE", level = 42, },
	[2120]={ class = "MAGE", level = 44, },
	[759]={ class = "MAGE", level = 47, },
	[2948]={ class = "MAGE", level = 48, },
	[55342]={ class = "MAGE", level = 49, },
	[89744]={ class = "MAGE", level = 50, },
	[10]={ class = "MAGE", level = 52, },
	[49361]={ class = "MAGE", level = 52, },
	[49358]={ class = "MAGE", level = 52, },
	[7302]={ class = "MAGE", level = 54, },
	[126201]={ class = "MAGE", level = 55, },
	[66]={ class = "MAGE", level = 56, },
	[1459]={ class = "MAGE", level = 58, },
	[113092]={ class = "MAGE", level = 60, },
	[114954]={ class = "MAGE", level = 60, },
	[28271]={ class = "MAGE", level = 60, },
	[28272]={ class = "MAGE", level = 60, },
	[61305]={ class = "MAGE", level = 60, },
	[61721]={ class = "MAGE", level = 60, },
	[61780]={ class = "MAGE", level = 60, },
	[12042]={ class = "MAGE", level = 62, },
	[31661]={ class = "MAGE", level = 62, },
	[84714]={ class = "MAGE", level = 62, },
	[33690]={ class = "MAGE", level = 62, },
	[35715]={ class = "MAGE", level = 62, },
	[30449]={ class = "MAGE", level = 64, },
	[44572]={ class = "MAGE", level = 66, },
	[33691]={ class = "MAGE", level = 66, },
	[35717]={ class = "MAGE", level = 66, },
	[12598]={ class = "MAGE", level = 70, },
	[120145]={ class = "MAGE", level = 71, },
	[53140]={ class = "MAGE", level = 71, },
	[43987]={ class = "MAGE", level = 72, },
	[120146]={ class = "MAGE", level = 74, },
	[117957]={ class = "MAGE", level = 74, },
	[53142]={ class = "MAGE", level = 74, },
	[125430]={ class = "MAGE", level = 75, },
	[44549]={ class = "MAGE", level = 77, },
	[11129]={ class = "MAGE", level = 77, },
	[76613]={ class = "MAGE", level = 80, },
	[12846]={ class = "MAGE", level = 80, },
	[76547]={ class = "MAGE", level = 80, },
	[61316]={ class = "MAGE", level = 80, },
	[6117]={ class = "MAGE", level = 80, },
	[84254]={ class = "MAGE", level = 82, },
	[80353]={ class = "MAGE", level = 84, },
	[132209]={ class = "MAGE", level = 85, },
	[88345]={ class = "MAGE", level = 85, },
	[88346]={ class = "MAGE", level = 85, },
	[88342]={ class = "MAGE", level = 85, },
	[88344]={ class = "MAGE", level = 85, },
	[133681]={ class = "MAGE", level = 86, },
	[108978]={ class = "MAGE", level = 87, },
	[132620]={ class = "MAGE", level = 90, },
	[132626]={ class = "MAGE", level = 90, },
	[132621]={ class = "MAGE", level = 90, },
	[132627]={ class = "MAGE", level = 90, },
--++ Monk ++	
	[125676]={ class = "MONK", level = 25, },
	[132005]={ class = "MONK", level = 25, },
	[123394]={ class = "MONK", level = 25, },
	[123399]={ class = "MONK", level = 25, },
	[125931]={ class = "MONK", level = 25, },
	[146954]={ class = "MONK", level = 25, },
	[120482]={ class = "MONK", level = 25, },
	[125872]={ class = "MONK", level = 25, },
	[125671]={ class = "MONK", level = 25, },
	[123403]={ class = "MONK", level = 25, },
	[124997]={ class = "MONK", level = 25, },
	[146953]={ class = "MONK", level = 25, },
	[123401]={ class = "MONK", level = 25, },
	[125732]={ class = "MONK", level = 25, },
	[125660]={ class = "MONK", level = 25, },
	[125967]={ class = "MONK", level = 25, },
	[124989]={ class = "MONK", level = 25, },
	[123763]={ class = "MONK", level = 25, },
	[146952]={ class = "MONK", level = 25, },
	[125755]={ class = "MONK", level = 25, },
	[146951]={ class = "MONK", level = 25, },
	[123334]={ class = "MONK", level = 25, },
	[125151]={ class = "MONK", level = 25, },
	[125673]={ class = "MONK", level = 25, },
	[120479]={ class = "MONK", level = 25, },
	[123405]={ class = "MONK", level = 25, },
	[125154]={ class = "MONK", level = 25, },
	[120483]={ class = "MONK", level = 25, },
	[146950]={ class = "MONK", level = 25, },
	[123391]={ class = "MONK", level = 25, },
	[125678]={ class = "MONK", level = 25, },
	[123023]={ class = "MONK", level = 25, },
	[125901]={ class = "MONK", level = 25, },
	[125893]={ class = "MONK", level = 25, },
	[120477]={ class = "MONK", level = 25, },
	[116346]={ class = "MONK", level = 1, },
	[137023]={ class = "MONK", level = 1, },
	[137024]={ class = "MONK", level = 1, },
	[137025]={ class = "MONK", level = 1, },
	[115173]={ class = "MONK", level = 15, },
	[115174]={ class = "MONK", level = 15, },
	[123986]={ class = "MONK", level = 30, },
	[115098]={ class = "MONK", level = 30, },
	[115396]={ class = "MONK", level = 45, },
	[115399]={ class = "MONK", level = 45, },
	[121817]={ class = "MONK", level = 45, },
	[122278]={ class = "MONK", level = 75, },
	[122783]={ class = "MONK", level = 75, },
	[122280]={ class = "MONK", level = 75, },
	[115008]={ class = "MONK", level = 90, },
	[123904]={ class = "MONK", level = 90, },
	[125170]={ class = "MONK", level = 1, },
	[115074]={ class = "MONK", level = 1, },
	[137022]={ class = "MONK", level = 1, },
	[108562]={ class = "MONK", level = 1, },
	[108977]={ class = "MONK", level = 1, },
	[120275]={ class = "MONK", level = 1, },
	[120277]={ class = "MONK", level = 1, },
	[123192]={ class = "MONK", level = 1, },
	[107500]={ class = "MONK", level = 1, },
	[128531]={ class = "MONK", level = 1, },
	[128591]={ class = "MONK", level = 1, },
	[123725]={ class = "MONK", level = 1, },
	[130654]={ class = "MONK", level = 1, },
	[117993]={ class = "MONK", level = 1, },
	[124040]={ class = "MONK", level = 1, },
	[132463]={ class = "MONK", level = 1, },
	[132467]={ class = "MONK", level = 1, },
	[118022]={ class = "MONK", level = 1, },
	[126890]={ class = "MONK", level = 1, },
	[117895]={ class = "MONK", level = 1, },
	[119650]={ class = "MONK", level = 1, },
	[117418]={ class = "MONK", level = 1, },
	[123586]={ class = "MONK", level = 1, },
	[124507]={ class = "MONK", level = 1, },
	[124041]={ class = "MONK", level = 1, },
	[135920]={ class = "MONK", level = 1, },
	[122281]={ class = "MONK", level = 1, },
	[115464]={ class = "MONK", level = 1, },
	[125355]={ class = "MONK", level = 1, },
	[135914]={ class = "MONK", level = 1, },
	[100780]={ class = "MONK", level = 1, },
	[128678]={ class = "MONK", level = 1, },
	[116812]={ class = "MONK", level = 1, },
	[119611]={ class = "MONK", level = 1, },
	[125953]={ class = "MONK", level = 1, },
	[117640]={ class = "MONK", level = 1, },
	[103985]={ class = "MONK", level = 1, },
	[116995]={ class = "MONK", level = 1, },
	[124335]={ class = "MONK", level = 1, },
	[110500]={ class = "MONK", level = 1, },
	[124280]={ class = "MONK", level = 1, },
	[126893]={ class = "MONK", level = 1, },
	[124098]={ class = "MONK", level = 1, },
	[124101]={ class = "MONK", level = 1, },
	[125033]={ class = "MONK", level = 1, },
	[100787]={ class = "MONK", level = 3, },
	[109132]={ class = "MONK", level = 5, },
	[100784]={ class = "MONK", level = 7, },
	[115129]={ class = "MONK", level = 7, },
	[115180]={ class = "MONK", level = 10, },
	[124146]={ class = "MONK", level = 10, },
	[113656]={ class = "MONK", level = 10, },
	[121278]={ class = "MONK", level = 10, },
	[115175]={ class = "MONK", level = 10, },
	[115069]={ class = "MONK", level = 10, },
	[115070]={ class = "MONK", level = 10, },
	[120272]={ class = "MONK", level = 10, },
	[120267]={ class = "MONK", level = 10, },
	[136336]={ class = "MONK", level = 10, },
	[121253]={ class = "MONK", level = 11, },
	[115612]={ class = "MONK", level = 12, },
	[115546]={ class = "MONK", level = 14, },
	[137384]={ class = "MONK", level = 15, },
	[124682]={ class = "MONK", level = 16, },
	[132120]={ class = "MONK", level = 16, },
	[115181]={ class = "MONK", level = 18, },
	[122057]={ class = "MONK", level = 18, },
	[101545]={ class = "MONK", level = 18, },
	[115178]={ class = "MONK", level = 18, },
	[128595]={ class = "MONK", level = 20, },
	[115451]={ class = "MONK", level = 20, },
	[139598]={ class = "MONK", level = 20, },
	[115450]={ class = "MONK", level = 20, },
	[120274]={ class = "MONK", level = 20, },
	[120278]={ class = "MONK", level = 20, },
	[126892]={ class = "MONK", level = 20, },
	[122470]={ class = "MONK", level = 22, },
	[115921]={ class = "MONK", level = 22, },
	[115080]={ class = "MONK", level = 22, },
	[121128]={ class = "MONK", level = 22, },
	[124334]={ class = "MONK", level = 23, },
	[115203]={ class = "MONK", level = 24, },
	[116092]={ class = "MONK", level = 26, },
	[115295]={ class = "MONK", level = 26, },
	[115072]={ class = "MONK", level = 26, },
	[116095]={ class = "MONK", level = 28, },
	[137562]={ class = "MONK", level = 30, },
	[126895]={ class = "MONK", level = 30, },
	[116694]={ class = "MONK", level = 32, },
	[116705]={ class = "MONK", level = 32, },
	[117967]={ class = "MONK", level = 34, },
	[116645]={ class = "MONK", level = 34, },
	[118672]={ class = "MONK", level = 34, },
	[123273]={ class = "MONK", level = 34, },
	[128938]={ class = "MONK", level = 36, },
	[115308]={ class = "MONK", level = 36, },
	[115288]={ class = "MONK", level = 36, },
	[117959]={ class = "MONK", level = 40, },
	[123332]={ class = "MONK", level = 40, },
	[115151]={ class = "MONK", level = 42, },
	[116023]={ class = "MONK", level = 42, },
	[115078]={ class = "MONK", level = 44, },
	[1245934]={ class = "MONK", level = 44, },
	[126046]={ class = "MONK", level = 45, },
	[122464]={ class = "MONK", level = 45, },
	[126060]={ class = "MONK", level = 45, },
	[126086]={ class = "MONK", level = 45, },
	[101546]={ class = "MONK", level = 46, },
	[115213]={ class = "MONK", level = 48, },
	[115073]={ class = "MONK", level = 48, },
	[120224]={ class = "MONK", level = 50, },
	[120225]={ class = "MONK", level = 50, },
	[120227]={ class = "MONK", level = 50, },
	[116849]={ class = "MONK", level = 50, },
	[117952]={ class = "MONK", level = 54, },
	[123766]={ class = "MONK", level = 56, },
	[123980]={ class = "MONK", level = 56, },
	[124502]={ class = "MONK", level = 56, },
	[115294]={ class = "MONK", level = 56, },
	[115869]={ class = "MONK", level = 56, },
	[107428]={ class = "MONK", level = 56, },
	[116740]={ class = "MONK", level = 56, },
	[116670]={ class = "MONK", level = 62, },
	[115460]={ class = "MONK", level = 64, },
	[116680]={ class = "MONK", level = 66, },
	[117368]={ class = "MONK", level = 68, },
	[115315]={ class = "MONK", level = 70, },
	[115313]={ class = "MONK", level = 70, },
	[119582]={ class = "MONK", level = 75, },
	[137639]={ class = "MONK", level = 75, },
	[115310]={ class = "MONK", level = 78, },
	[115543]={ class = "MONK", level = 78, },
	[115636]={ class = "MONK", level = 80, },
	[1247280]={ class = "MONK", level = 80, },
	[117906]={ class = "MONK", level = 80, },
	[117907]={ class = "MONK", level = 80, },
	[116781]={ class = "MONK", level = 81, },
	[115176]={ class = "MONK", level = 82, },
	[1251700]={ class = "MONK", level = 85, },
	[101643]={ class = "MONK", level = 87, },
	[119996]={ class = "MONK", level = 87, },
	[130610]={ class = "MONK", level = 90, },
--++ Paladin ++	
	[54927]={ class = "PALADIN", level = 25, },
	[63218]={ class = "PALADIN", level = 25, },
	[115934]={ class = "PALADIN", level = 25, },
	[54943]={ class = "PALADIN", level = 25, },
	[54934]={ class = "PALADIN", level = 25, },
	[54931]={ class = "PALADIN", level = 25, },
	[54928]={ class = "PALADIN", level = 25, },
	[56414]={ class = "PALADIN", level = 25, },
	[56420]={ class = "PALADIN", level = 25, },
	[146955]={ class = "PALADIN", level = 25, },
	[63223]={ class = "PALADIN", level = 25, },
	[54924]={ class = "PALADIN", level = 25, },
	[146956]={ class = "PALADIN", level = 25, },
	[63220]={ class = "PALADIN", level = 25, },
	[54939]={ class = "PALADIN", level = 25, },
	[54922]={ class = "PALADIN", level = 25, },
	[54935]={ class = "PALADIN", level = 25, },
	[57954]={ class = "PALADIN", level = 25, },
	[57955]={ class = "PALADIN", level = 25, },
	[54930]={ class = "PALADIN", level = 25, },
	[115738]={ class = "PALADIN", level = 25, },
	[63219]={ class = "PALADIN", level = 25, },
	[146957]={ class = "PALADIN", level = 25, },
	[54938]={ class = "PALADIN", level = 25, },
	[63224]={ class = "PALADIN", level = 25, },
	[54923]={ class = "PALADIN", level = 25, },
	[54937]={ class = "PALADIN", level = 25, },
	[56416]={ class = "PALADIN", level = 25, },
	[63225]={ class = "PALADIN", level = 25, },
	[54940]={ class = "PALADIN", level = 25, },
	[122028]={ class = "PALADIN", level = 25, },
	[146959]={ class = "PALADIN", level = 25, },
	[93466]={ class = "PALADIN", level = 25, },
	[115933]={ class = "PALADIN", level = 25, },
	[57947]={ class = "PALADIN", level = 25, },
	[54926]={ class = "PALADIN", level = 25, },
	[63222]={ class = "PALADIN", level = 25, },
	[119477]={ class = "PALADIN", level = 25, },
	[146958]={ class = "PALADIN", level = 25, },
	[115931]={ class = "PALADIN", level = 25, },
	[89401]={ class = "PALADIN", level = 25, },
	[57958]={ class = "PALADIN", level = 25, },
	[57979]={ class = "PALADIN", level = 25, },
	[54936]={ class = "PALADIN", level = 25, },
	[115547]={ class = "PALADIN", level = 25, },
	[125043]={ class = "PALADIN", level = 25, },
	[137027]={ class = "PALADIN", level = 1, },
	[137028]={ class = "PALADIN", level = 1, },
	[137029]={ class = "PALADIN", level = 1, },
	[148040]={ class = "PALADIN", level = 1, },
	[87172]={ class = "PALADIN", level = 15, },
	[26023]={ class = "PALADIN", level = 15, },
	[85499]={ class = "PALADIN", level = 15, },
	[110301]={ class = "PALADIN", level = 30, },
	[85804]={ class = "PALADIN", level = 45, },
	[105622]={ class = "PALADIN", level = 60, },
	[114154]={ class = "PALADIN", level = 60, },
	[86172]={ class = "PALADIN", level = 75, },
	[105809]={ class = "PALADIN", level = 75, },
	[53376]={ class = "PALADIN", level = 75, },
	[114157]={ class = "PALADIN", level = 90, },
	[114165]={ class = "PALADIN", level = 90, },
	[114158]={ class = "PALADIN", level = 90, },
	[86704]={ class = "PALADIN", level = 1, },
	[137026]={ class = "PALADIN", level = 1, },
	[86678]={ class = "PALADIN", level = 1, },
	[93417]={ class = "PALADIN", level = 1, },
	[94289]={ class = "PALADIN", level = 1, },
	[31849]={ class = "PALADIN", level = 1, },
	[123830]={ class = "PALADIN", level = 1, },
	[35395]={ class = "PALADIN", level = 1, },
	[114916]={ class = "PALADIN", level = 1, },
	[88263]={ class = "PALADIN", level = 1, },
	[114852]={ class = "PALADIN", level = 1, },
	[114871]={ class = "PALADIN", level = 1, },
	[82242]={ class = "PALADIN", level = 1, },
	[101423]={ class = "PALADIN", level = 1, },
	[114917]={ class = "PALADIN", level = 1, },
	[110501]={ class = "PALADIN", level = 1, },
	[105361]={ class = "PALADIN", level = 3, },
	[20271]={ class = "PALADIN", level = 5, },
	[81297]={ class = "PALADIN", level = 6, },
	[853]={ class = "PALADIN", level = 7, },
	[130552]={ class = "PALADIN", level = 9, },
	[85673]={ class = "PALADIN", level = 9, },
	[130551]={ class = "PALADIN", level = 9, },
	[136494]={ class = "PALADIN", level = 9, },
	[53592]={ class = "PALADIN", level = 10, },
	[112859]={ class = "PALADIN", level = 10, },
	[20473]={ class = "PALADIN", level = 10, },
	[53503]={ class = "PALADIN", level = 10, },
	[20113]={ class = "PALADIN", level = 10, },
	[85256]={ class = "PALADIN", level = 10, },
	[84839]={ class = "PALADIN", level = 10, },
	[25780]={ class = "PALADIN", level = 12, },
	[7328]={ class = "PALADIN", level = 13, },
	[19750]={ class = "PALADIN", level = 14, },
	[62124]={ class = "PALADIN", level = 15, },
	[633]={ class = "PALADIN", level = 16, },
	[642]={ class = "PALADIN", level = 18, },
	[2812]={ class = "PALADIN", level = 20, },
	[53595]={ class = "PALADIN", level = 20, },
	[115801]={ class = "PALADIN", level = 20, },
	[119072]={ class = "PALADIN", level = 20, },
	[53551]={ class = "PALADIN", level = 20, },
	[66907]={ class = "PALADIN", level = 20, },
	[4987]={ class = "PALADIN", level = 20, },
	[73629]={ class = "PALADIN", level = 20, },
	[69820]={ class = "PALADIN", level = 20, },
	[34769]={ class = "PALADIN", level = 20, },
	[13819]={ class = "PALADIN", level = 20, },
	[31801]={ class = "PALADIN", level = 24, },
	[498]={ class = "PALADIN", level = 26, },
	[82327]={ class = "PALADIN", level = 28, },
	[111529]={ class = "PALADIN", level = 28, },
	[105424]={ class = "PALADIN", level = 28, },
	[20217]={ class = "PALADIN", level = 30, },
	[20165]={ class = "PALADIN", level = 32, },
	[20167]={ class = "PALADIN", level = 32, },
	[26573]={ class = "PALADIN", level = 34, },
	[53385]={ class = "PALADIN", level = 34, },
	[635]={ class = "PALADIN", level = 34, },
	[31868]={ class = "PALADIN", level = 34, },
	[96231]={ class = "PALADIN", level = 36, },
	[24275]={ class = "PALADIN", level = 38, },
	[53563]={ class = "PALADIN", level = 39, },
	[53600]={ class = "PALADIN", level = 40, },
	[66906]={ class = "PALADIN", level = 40, },
	[66235]={ class = "PALADIN", level = 40, },
	[23214]={ class = "PALADIN", level = 40, },
	[73630]={ class = "PALADIN", level = 40, },
	[69826]={ class = "PALADIN", level = 40, },
	[34767]={ class = "PALADIN", level = 40, },
	[20154]={ class = "PALADIN", level = 42, },
	[450761]={ class = "PALADIN", level = 44, },
	[32223]={ class = "PALADIN", level = 44, },
	[42463]={ class = "PALADIN", level = 44, },
	[54428]={ class = "PALADIN", level = 46, },
	[879]={ class = "PALADIN", level = 46, },
	[10326]={ class = "PALADIN", level = 46, },
	[85043]={ class = "PALADIN", level = 50, },
	[53576]={ class = "PALADIN", level = 50, },
	[86102]={ class = "PALADIN", level = 50, },
	[86103]={ class = "PALADIN", level = 50, },
	[86539]={ class = "PALADIN", level = 50, },
	[87138]={ class = "PALADIN", level = 50, },
	[1044]={ class = "PALADIN", level = 52, },
	[82326]={ class = "PALADIN", level = 54, },
	[121783]={ class = "PALADIN", level = 54, },
	[88821]={ class = "PALADIN", level = 56, },
	[25956]={ class = "PALADIN", level = 58, },
	[31821]={ class = "PALADIN", level = 60, },
	[31842]={ class = "PALADIN", level = 62, },
	[105805]={ class = "PALADIN", level = 64, },
	[85512]={ class = "PALADIN", level = 64, },
	[1038]={ class = "PALADIN", level = 66, },
	[31850]={ class = "PALADIN", level = 70, },
	[85222]={ class = "PALADIN", level = 70, },
	[20164]={ class = "PALADIN", level = 70, },
	[31884]={ class = "PALADIN", level = 72, },
	[86659]={ class = "PALADIN", level = 75, },
	[86669]={ class = "PALADIN", level = 75, },
	[86698]={ class = "PALADIN", level = 75, },
	[140333]={ class = "PALADIN", level = 80, },
	[76671]={ class = "PALADIN", level = 80, },
	[76672]={ class = "PALADIN", level = 80, },
	[76669]={ class = "PALADIN", level = 80, },
	[96172]={ class = "PALADIN", level = 80, },
	[6940]={ class = "PALADIN", level = 80, },
	[84963]={ class = "PALADIN", level = 81, },
	[19740]={ class = "PALADIN", level = 81, },
	[115675]={ class = "PALADIN", level = 85, },
	[115750]={ class = "PALADIN", level = 87, },
--++ Priest ++	
	[145722]={ class = "PRIEST", level = 25, },
	[63248]={ class = "PRIEST", level = 25, },
	[58009]={ class = "PRIEST", level = 25, },
	[55675]={ class = "PRIEST", level = 25, },
	[58228]={ class = "PRIEST", level = 25, },
	[55673]={ class = "PRIEST", level = 25, },
	[119864]={ class = "PRIEST", level = 25, },
	[63229]={ class = "PRIEST", level = 25, },
	[55684]={ class = "PRIEST", level = 25, },
	[55678]={ class = "PRIEST", level = 25, },
	[147778]={ class = "PRIEST", level = 25, },
	[119853]={ class = "PRIEST", level = 25, },
	[126174]={ class = "PRIEST", level = 25, },
	[55686]={ class = "PRIEST", level = 25, },
	[14771]={ class = "PRIEST", level = 25, },
	[147072]={ class = "PRIEST", level = 25, },
	[119850]={ class = "PRIEST", level = 25, },
	[108939]={ class = "PRIEST", level = 25, },
	[126133]={ class = "PRIEST", level = 25, },
	[55691]={ class = "PRIEST", level = 25, },
	[87195]={ class = "PRIEST", level = 25, },
	[120585]={ class = "PRIEST", level = 25, },
	[33371]={ class = "PRIEST", level = 25, },
	[119866]={ class = "PRIEST", level = 25, },
	[55672]={ class = "PRIEST", level = 25, },
	[55685]={ class = "PRIEST", level = 25, },
	[55688]={ class = "PRIEST", level = 25, },
	[55676]={ class = "PRIEST", level = 25, },
	[55677]={ class = "PRIEST", level = 25, },
	[33202]={ class = "PRIEST", level = 25, },
	[119872]={ class = "PRIEST", level = 25, },
	[55690]={ class = "PRIEST", level = 25, },
	[57986]={ class = "PRIEST", level = 25, },
	[107906]={ class = "PRIEST", level = 25, },
	[57985]={ class = "PRIEST", level = 25, },
	[120583]={ class = "PRIEST", level = 25, },
	[147779]={ class = "PRIEST", level = 25, },
	[55692]={ class = "PRIEST", level = 25, },
	[119873]={ class = "PRIEST", level = 25, },
	[120581]={ class = "PRIEST", level = 25, },
	[147776]={ class = "PRIEST", level = 25, },
	[126094]={ class = "PRIEST", level = 25, },
	[120584]={ class = "PRIEST", level = 25, },
	[89489]={ class = "PRIEST", level = 25, },
	[126152]={ class = "PRIEST", level = 25, },
	[126745]={ class = "PRIEST", level = 25, },
	[137031]={ class = "PRIEST", level = 1, },
	[137032]={ class = "PRIEST", level = 1, },
	[137033]={ class = "PRIEST", level = 1, },
	[108921]={ class = "PRIEST", level = 15, },
	[108920]={ class = "PRIEST", level = 15, },
	[121536]={ class = "PRIEST", level = 30, },
	[64129]={ class = "PRIEST", level = 30, },
	[108942]={ class = "PRIEST", level = 30, },
	[109186]={ class = "PRIEST", level = 45, },
	[123040]={ class = "PRIEST", level = 45, },
	[139139]={ class = "PRIEST", level = 45, },
	[108945]={ class = "PRIEST", level = 60, },
	[19236]={ class = "PRIEST", level = 60, },
	[112833]={ class = "PRIEST", level = 60, },
	[109175]={ class = "PRIEST", level = 75, },
	[10060]={ class = "PRIEST", level = 75, },
	[109142]={ class = "PRIEST", level = 75, },
	[121135]={ class = "PRIEST", level = 90, },
	[120785]={ class = "PRIEST", level = 90, },
	[121148]={ class = "PRIEST", level = 90, },
	[110745]={ class = "PRIEST", level = 90, },
	[122128]={ class = "PRIEST", level = 90, },
	[120517]={ class = "PRIEST", level = 90, },
	[120692]={ class = "PRIEST", level = 90, },
	[120696]={ class = "PRIEST", level = 90, },
	[137030]={ class = "PRIEST", level = 1, },
	[78500]={ class = "PRIEST", level = 1, },
	[121196]={ class = "PRIEST", level = 1, },
	[88686]={ class = "PRIEST", level = 1, },
	[126154]={ class = "PRIEST", level = 1, },
	[124469]={ class = "PRIEST", level = 1, },
	[585]={ class = "PRIEST", level = 1, },
	[110502]={ class = "PRIEST", level = 1, },
	[589]={ class = "PRIEST", level = 3, },
	[124464]={ class = "PRIEST", level = 3, },
	[17]={ class = "PRIEST", level = 5, },
	[2061]={ class = "PRIEST", level = 7, },
	[588]={ class = "PRIEST", level = 9, },
	[88625]={ class = "PRIEST", level = 10, },
	[95860]={ class = "PRIEST", level = 10, },
	[95861]={ class = "PRIEST", level = 10, },
	[15407]={ class = "PRIEST", level = 10, },
	[47540]={ class = "PRIEST", level = 10, },
	[47536]={ class = "PRIEST", level = 10, },
	[87336]={ class = "PRIEST", level = 10, },
	[47573]={ class = "PRIEST", level = 10, },
	[124467]={ class = "PRIEST", level = 10, },
	[84733]={ class = "PRIEST", level = 10, },
	[124468]={ class = "PRIEST", level = 10, },
	[8122]={ class = "PRIEST", level = 12, },
	[122098]={ class = "PRIEST", level = 16, },
	[14914]={ class = "PRIEST", level = 18, },
	[2006]={ class = "PRIEST", level = 18, },
	[2944]={ class = "PRIEST", level = 21, },
	[8092]={ class = "PRIEST", level = 21, },
	[95740]={ class = "PRIEST", level = 21, },
	[127626]={ class = "PRIEST", level = 21, },
	[527]={ class = "PRIEST", level = 22, },
	[21562]={ class = "PRIEST", level = 22, },
	[47515]={ class = "PRIEST", level = 24, },
	[15473]={ class = "PRIEST", level = 24, },
	[586]={ class = "PRIEST", level = 24, },
	[528]={ class = "PRIEST", level = 26, },
	[139]={ class = "PRIEST", level = 26, },
	[2050]={ class = "PRIEST", level = 28, },
	[109964]={ class = "PRIEST", level = 28, },
	[34914]={ class = "PRIEST", level = 28, },
	[114884]={ class = "PRIEST", level = 28, },
	[124465]={ class = "PRIEST", level = 28, },
	[45243]={ class = "PRIEST", level = 30, },
	[20711]={ class = "PRIEST", level = 30, },
	[9484]={ class = "PRIEST", level = 32, },
	[2060]={ class = "PRIEST", level = 34, },
	[63733]={ class = "PRIEST", level = 34, },
	[1706]={ class = "PRIEST", level = 34, },
	[89485]={ class = "PRIEST", level = 36, },
	[126135]={ class = "PRIEST", level = 36, },
	[81749]={ class = "PRIEST", level = 38, },
	[78203]={ class = "PRIEST", level = 42, },
	[2096]={ class = "PRIEST", level = 42, },
	[34433]={ class = "PRIEST", level = 42, },
	[81662]={ class = "PRIEST", level = 44, },
	[73510]={ class = "PRIEST", level = 44, },
	[83968]={ class = "PRIEST", level = 44, },
	[47517]={ class = "PRIEST", level = 45, },
	[596]={ class = "PRIEST", level = 46, },
	[32379]={ class = "PRIEST", level = 46, },
	[32546]={ class = "PRIEST", level = 48, },
	[81700]={ class = "PRIEST", level = 50, },
	[34861]={ class = "PRIEST", level = 50, },
	[89745]={ class = "PRIEST", level = 50, },
	[89488]={ class = "PRIEST", level = 52, },
	[6346]={ class = "PRIEST", level = 54, },
	[81209]={ class = "PRIEST", level = 56, },
	[81206]={ class = "PRIEST", level = 56, },
	[81208]={ class = "PRIEST", level = 56, },
	[33206]={ class = "PRIEST", level = 58, },
	[47585]={ class = "PRIEST", level = 60, },
	[52798]={ class = "PRIEST", level = 62, },
	[95649]={ class = "PRIEST", level = 64, },
	[64901]={ class = "PRIEST", level = 66, },
	[33076]={ class = "PRIEST", level = 68, },
	[47788]={ class = "PRIEST", level = 70, },
	[62618]={ class = "PRIEST", level = 70, },
	[32375]={ class = "PRIEST", level = 72, },
	[64044]={ class = "PRIEST", level = 74, },
	[48045]={ class = "PRIEST", level = 76, },
	[64843]={ class = "PRIEST", level = 78, },
	[92297]={ class = "PRIEST", level = 78, },
	[15286]={ class = "PRIEST", level = 78, },
	[77485]={ class = "PRIEST", level = 80, },
	[77489]={ class = "PRIEST", level = 80, },
	[77486]={ class = "PRIEST", level = 80, },
	[77484]={ class = "PRIEST", level = 80, },
	[73413]={ class = "PRIEST", level = 80, },
	[73325]={ class = "PRIEST", level = 84, },
	[108968]={ class = "PRIEST", level = 87, },
	[142723]={ class = "PRIEST", level = 87, },
--++ Rogue ++	
	[56813]={ class = "ROGUE", level = 25, },
	[56818]={ class = "ROGUE", level = 25, },
	[91299]={ class = "ROGUE", level = 25, },
	[58039]={ class = "ROGUE", level = 25, },
	[56801]={ class = "ROGUE", level = 25, },
	[63269]={ class = "ROGUE", level = 25, },
	[63254]={ class = "ROGUE", level = 25, },
	[56800]={ class = "ROGUE", level = 25, },
	[125044]={ class = "ROGUE", level = 25, },
	[63268]={ class = "ROGUE", level = 25, },
	[58032]={ class = "ROGUE", level = 25, },
	[56799]={ class = "ROGUE", level = 25, },
	[56803]={ class = "ROGUE", level = 25, },
	[56804]={ class = "ROGUE", level = 25, },
	[56812]={ class = "ROGUE", level = 25, },
	[56809]={ class = "ROGUE", level = 25, },
	[56807]={ class = "ROGUE", level = 25, },
	[146631]={ class = "ROGUE", level = 25, },
	[146961]={ class = "ROGUE", level = 25, },
	[56805]={ class = "ROGUE", level = 25, },
	[63252]={ class = "ROGUE", level = 25, },
	[58027]={ class = "ROGUE", level = 25, },
	[58017]={ class = "ROGUE", level = 25, },
	[58038]={ class = "ROGUE", level = 25, },
	[146625]={ class = "ROGUE", level = 25, },
	[56806]={ class = "ROGUE", level = 25, },
	[146629]={ class = "ROGUE", level = 25, },
	[58033]={ class = "ROGUE", level = 25, },
	[56808]={ class = "ROGUE", level = 25, },
	[146628]={ class = "ROGUE", level = 25, },
	[56810]={ class = "ROGUE", level = 25, },
	[56819]={ class = "ROGUE", level = 25, },
	[56811]={ class = "ROGUE", level = 25, },
	[63253]={ class = "ROGUE", level = 25, },
	[146960]={ class = "ROGUE", level = 25, },
	[63256]={ class = "ROGUE", level = 25, },
	[89758]={ class = "ROGUE", level = 25, },
	[63249]={ class = "ROGUE", level = 25, },
	[137035]={ class = "ROGUE", level = 1, },
	[137036]={ class = "ROGUE", level = 1, },
	[137037]={ class = "ROGUE", level = 1, },
	[14062]={ class = "ROGUE", level = 15, },
	[108209]={ class = "ROGUE", level = 15, },
	[108208]={ class = "ROGUE", level = 15, },
	[74001]={ class = "ROGUE", level = 30, },
	[108210]={ class = "ROGUE", level = 30, },
	[31230]={ class = "ROGUE", level = 45, },
	[79008]={ class = "ROGUE", level = 45, },
	[108211]={ class = "ROGUE", level = 45, },
	[112974]={ class = "ROGUE", level = 45, },
	[108212]={ class = "ROGUE", level = 60, },
	[138106]={ class = "ROGUE", level = 60, },
	[36554]={ class = "ROGUE", level = 60, },
	[108216]={ class = "ROGUE", level = 75, },
	[131511]={ class = "ROGUE", level = 75, },
	[114015]={ class = "ROGUE", level = 90, },
	[137619]={ class = "ROGUE", level = 90, },
	[114014]={ class = "ROGUE", level = 90, },
	[137034]={ class = "ROGUE", level = 1, },
	[32743]={ class = "ROGUE", level = 1, },
	[22482]={ class = "ROGUE", level = 1, },
	[1248969]={ class = "ROGUE", level = 1, },
	[89775]={ class = "ROGUE", level = 1, },
	[86392]={ class = "ROGUE", level = 1, },
	[5374]={ class = "ROGUE", level = 1, },
	[27576]={ class = "ROGUE", level = 1, },
	[82245]={ class = "ROGUE", level = 1, },
	[1752]={ class = "ROGUE", level = 1, },
	[110503]={ class = "ROGUE", level = 1, },
	[121733]={ class = "ROGUE", level = 1, },
	[2098]={ class = "ROGUE", level = 3, },
	[79327]={ class = "ROGUE", level = 3, },
	[1784]={ class = "ROGUE", level = 5, },
	[8676]={ class = "ROGUE", level = 6, },
	[5277]={ class = "ROGUE", level = 8, },
	[13852]={ class = "ROGUE", level = 10, },
	[84601]={ class = "ROGUE", level = 10, },
	[13877]={ class = "ROGUE", level = 10, },
	[16511]={ class = "ROGUE", level = 10, },
	[14117]={ class = "ROGUE", level = 10, },
	[31223]={ class = "ROGUE", level = 10, },
	[1329]={ class = "ROGUE", level = 10, },
	[31220]={ class = "ROGUE", level = 10, },
	[61329]={ class = "ROGUE", level = 10, },
	[2823]={ class = "ROGUE", level = 10, },
	[113780]={ class = "ROGUE", level = 10, },
	[6770]={ class = "ROGUE", level = 12, },
	[5171]={ class = "ROGUE", level = 14, },
	[921]={ class = "ROGUE", level = 15, },
	[73651]={ class = "ROGUE", level = 16, },
	[1766]={ class = "ROGUE", level = 18, },
	[32645]={ class = "ROGUE", level = 20, },
	[91023]={ class = "ROGUE", level = 20, },
	[84617]={ class = "ROGUE", level = 20, },
	[3408]={ class = "ROGUE", level = 20, },
	[8680]={ class = "ROGUE", level = 20, },
	[1776]={ class = "ROGUE", level = 22, },
	[1804]={ class = "ROGUE", level = 24, },
	[2983]={ class = "ROGUE", level = 26, },
	[1725]={ class = "ROGUE", level = 28, },
	[5761]={ class = "ROGUE", level = 28, },
	[35551]={ class = "ROGUE", level = 30, },
	[14183]={ class = "ROGUE", level = 30, },
	[14190]={ class = "ROGUE", level = 30, },
	[1833]={ class = "ROGUE", level = 30, },
	[2818]={ class = "ROGUE", level = 30, },
	[113742]={ class = "ROGUE", level = 30, },
	[8679]={ class = "ROGUE", level = 30, },
	[14161]={ class = "ROGUE", level = 32, },
	[1856]={ class = "ROGUE", level = 34, },
	[8647]={ class = "ROGUE", level = 36, },
	[2094]={ class = "ROGUE", level = 38, },
	[13750]={ class = "ROGUE", level = 40, },
	[53]={ class = "ROGUE", level = 40, },
	[111240]={ class = "ROGUE", level = 40, },
	[408]={ class = "ROGUE", level = 40, },
	[2836]={ class = "ROGUE", level = 42, },
	[1966]={ class = "ROGUE", level = 44, },
	[1943]={ class = "ROGUE", level = 46, },
	[703]={ class = "ROGUE", level = 48, },
	[1860]={ class = "ROGUE", level = 48, },
	[51701]={ class = "ROGUE", level = 50, },
	[79096]={ class = "ROGUE", level = 50, },
	[79134]={ class = "ROGUE", level = 50, },
	[86092]={ class = "ROGUE", level = 50, },
	[51722]={ class = "ROGUE", level = 52, },
	[58423]={ class = "ROGUE", level = 54, },
	[1842]={ class = "ROGUE", level = 56, },
	[31224]={ class = "ROGUE", level = 58, },
	[84654]={ class = "ROGUE", level = 60, },
	[51667]={ class = "ROGUE", level = 60, },
	[79147]={ class = "ROGUE", level = 60, },
	[31209]={ class = "ROGUE", level = 62, },
	[58410]={ class = "ROGUE", level = 64, },
	[51723]={ class = "ROGUE", level = 66, },
	[14185]={ class = "ROGUE", level = 68, },
	[121152]={ class = "ROGUE", level = 70, },
	[79152]={ class = "ROGUE", level = 70, },
	[114842]={ class = "ROGUE", level = 72, },
	[5938]={ class = "ROGUE", level = 74, },
	[57934]={ class = "ROGUE", level = 78, },
	[51690]={ class = "ROGUE", level = 80, },
	[76808]={ class = "ROGUE", level = 80, },
	[76806]={ class = "ROGUE", level = 80, },
	[76803]={ class = "ROGUE", level = 80, },
	[51713]={ class = "ROGUE", level = 80, },
	[79140]={ class = "ROGUE", level = 80, },
	[73981]={ class = "ROGUE", level = 81, },
	[121411]={ class = "ROGUE", level = 83, },
	[122233]={ class = "ROGUE", level = 83, },
	[76577]={ class = "ROGUE", level = 85, },
	[121471]={ class = "ROGUE", level = 87, },
	[121473]={ class = "ROGUE", level = 87, },
	[121474]={ class = "ROGUE", level = 87, },
--++ Shaman ++	
	[147787]={ class = "SHAMAN", level = 25, },
	[58058]={ class = "SHAMAN", level = 25, },
	[55442]={ class = "SHAMAN", level = 25, },
	[55449]={ class = "SHAMAN", level = 25, },
	[55452]={ class = "SHAMAN", level = 25, },
	[55445]={ class = "SHAMAN", level = 25, },
	[63279]={ class = "SHAMAN", level = 25, },
	[147788]={ class = "SHAMAN", level = 25, },
	[147781]={ class = "SHAMAN", level = 25, },
	[58059]={ class = "SHAMAN", level = 25, },
	[63271]={ class = "SHAMAN", level = 25, },
	[55455]={ class = "SHAMAN", level = 25, },
	[55450]={ class = "SHAMAN", level = 25, },
	[55447]={ class = "SHAMAN", level = 25, },
	[147772]={ class = "SHAMAN", level = 25, },
	[55443]={ class = "SHAMAN", level = 25, },
	[59289]={ class = "SHAMAN", level = 25, },
	[55441]={ class = "SHAMAN", level = 25, },
	[89646]={ class = "SHAMAN", level = 25, },
	[55456]={ class = "SHAMAN", level = 25, },
	[55440]={ class = "SHAMAN", level = 25, },
	[63291]={ class = "SHAMAN", level = 25, },
	[55444]={ class = "SHAMAN", level = 25, },
	[101052]={ class = "SHAMAN", level = 25, },
	[147784]={ class = "SHAMAN", level = 25, },
	[55439]={ class = "SHAMAN", level = 25, },
	[147762]={ class = "SHAMAN", level = 25, },
	[147707]={ class = "SHAMAN", level = 25, },
	[63273]={ class = "SHAMAN", level = 25, },
	[63280]={ class = "SHAMAN", level = 25, },
	[147783]={ class = "SHAMAN", level = 25, },
	[55454]={ class = "SHAMAN", level = 25, },
	[147770]={ class = "SHAMAN", level = 25, },
	[55446]={ class = "SHAMAN", level = 25, },
	[55453]={ class = "SHAMAN", level = 25, },
	[147785]={ class = "SHAMAN", level = 25, },
	[55448]={ class = "SHAMAN", level = 25, },
	[58135]={ class = "SHAMAN", level = 25, },
	[63270]={ class = "SHAMAN", level = 25, },
	[62132]={ class = "SHAMAN", level = 25, },
	[58057]={ class = "SHAMAN", level = 25, },
	[55438]={ class = "SHAMAN", level = 25, },
	[63298]={ class = "SHAMAN", level = 25, },
	[55437]={ class = "SHAMAN", level = 25, },
	[55436]={ class = "SHAMAN", level = 25, },
	[55451]={ class = "SHAMAN", level = 25, },
	[137039]={ class = "SHAMAN", level = 1, },
	[137040]={ class = "SHAMAN", level = 1, },
	[137041]={ class = "SHAMAN", level = 1, },
	[108271]={ class = "SHAMAN", level = 15, },
	[30884]={ class = "SHAMAN", level = 15, },
	[108270]={ class = "SHAMAN", level = 15, },
	[51485]={ class = "SHAMAN", level = 30, },
	[63374]={ class = "SHAMAN", level = 30, },
	[108273]={ class = "SHAMAN", level = 30, },
	[108285]={ class = "SHAMAN", level = 45, },
	[108284]={ class = "SHAMAN", level = 45, },
	[108287]={ class = "SHAMAN", level = 45, },
	[16188]={ class = "SHAMAN", level = 60, },
	[108283]={ class = "SHAMAN", level = 60, },
	[16166]={ class = "SHAMAN", level = 60, },
	[114911]={ class = "SHAMAN", level = 75, },
	[108282]={ class = "SHAMAN", level = 75, },
	[147074]={ class = "SHAMAN", level = 75, },
	[117014]={ class = "SHAMAN", level = 90, },
	[117013]={ class = "SHAMAN", level = 90, },
	[117012]={ class = "SHAMAN", level = 90, },
	[137038]={ class = "SHAMAN", level = 1, },
	[73683]={ class = "SHAMAN", level = 1, },
	[73685]={ class = "SHAMAN", level = 1, },
	[73681]={ class = "SHAMAN", level = 1, },
	[114093]={ class = "SHAMAN", level = 1, },
	[25504]={ class = "SHAMAN", level = 1, },
	[33750]={ class = "SHAMAN", level = 1, },
	[52752]={ class = "SHAMAN", level = 1, },
	[123831]={ class = "SHAMAN", level = 1, },
	[10444]={ class = "SHAMAN", level = 1, },
	[403]={ class = "SHAMAN", level = 1, },
	[110504]={ class = "SHAMAN", level = 1, },
	[73899]={ class = "SHAMAN", level = 3, },
	[8042]={ class = "SHAMAN", level = 6, },
	[8004]={ class = "SHAMAN", level = 7, },
	[324]={ class = "SHAMAN", level = 8, },
	[89920]={ class = "SHAMAN", level = 10, },
	[86629]={ class = "SHAMAN", level = 10, },
	[60188]={ class = "SHAMAN", level = 10, },
	[30674]={ class = "SHAMAN", level = 10, },
	[29000]={ class = "SHAMAN", level = 10, },
	[60103]={ class = "SHAMAN", level = 10, },
	[95862]={ class = "SHAMAN", level = 10, },
	[30814]={ class = "SHAMAN", level = 10, },
	[51522]={ class = "SHAMAN", level = 10, },
	[16213]={ class = "SHAMAN", level = 10, },
	[61295]={ class = "SHAMAN", level = 10, },
	[62099]={ class = "SHAMAN", level = 10, },
	[112858]={ class = "SHAMAN", level = 10, },
	[123099]={ class = "SHAMAN", level = 10, },
	[51490]={ class = "SHAMAN", level = 10, },
	[8024]={ class = "SHAMAN", level = 10, },
	[8349]={ class = "SHAMAN", level = 12, },
	[8050]={ class = "SHAMAN", level = 12, },
	[370]={ class = "SHAMAN", level = 12, },
	[2008]={ class = "SHAMAN", level = 14, },
	[2645]={ class = "SHAMAN", level = 15, },
	[3599]={ class = "SHAMAN", level = 16, },
	[57994]={ class = "SHAMAN", level = 16, },
	[77130]={ class = "SHAMAN", level = 18, },
	[51886]={ class = "SHAMAN", level = 18, },
	[16282]={ class = "SHAMAN", level = 20, },
	[88766]={ class = "SHAMAN", level = 20, },
	[331]={ class = "SHAMAN", level = 20, },
	[88764]={ class = "SHAMAN", level = 20, },
	[52127]={ class = "SHAMAN", level = 20, },
	[8056]={ class = "SHAMAN", level = 22, },
	[546]={ class = "SHAMAN", level = 24, },
	[974]={ class = "SHAMAN", level = 26, },
	[17364]={ class = "SHAMAN", level = 26, },
	[2484]={ class = "SHAMAN", level = 26, },
	[8034]={ class = "SHAMAN", level = 26, },
	[115356]={ class = "SHAMAN", level = 26, },
	[421]={ class = "SHAMAN", level = 28, },
	[51730]={ class = "SHAMAN", level = 30, },
	[8232]={ class = "SHAMAN", level = 30, },
	[51945]={ class = "SHAMAN", level = 30, },
	[5394]={ class = "SHAMAN", level = 30, },
	[36936]={ class = "SHAMAN", level = 30, },
	[20608]={ class = "SHAMAN", level = 32, },
	[51558]={ class = "SHAMAN", level = 34, },
	[51505]={ class = "SHAMAN", level = 34, },
	[77657]={ class = "SHAMAN", level = 34, },
	[556]={ class = "SHAMAN", level = 34, },
	[6196]={ class = "SHAMAN", level = 36, },
	[8190]={ class = "SHAMAN", level = 36, },
	[8177]={ class = "SHAMAN", level = 38, },
	[16164]={ class = "SHAMAN", level = 40, },
	[16196]={ class = "SHAMAN", level = 40, },
	[51527]={ class = "SHAMAN", level = 40, },
	[77747]={ class = "SHAMAN", level = 40, },
	[115357]={ class = "SHAMAN", level = 40, },
	[115360]={ class = "SHAMAN", level = 40, },
	[1535]={ class = "SHAMAN", level = 44, },
	[450762]={ class = "SHAMAN", level = 44, },
	[1064]={ class = "SHAMAN", level = 44, },
	[8033]={ class = "SHAMAN", level = 46, },
	[77756]={ class = "SHAMAN", level = 50, },
	[51530]={ class = "SHAMAN", level = 50, },
	[86099]={ class = "SHAMAN", level = 50, },
	[86100]={ class = "SHAMAN", level = 50, },
	[86108]={ class = "SHAMAN", level = 50, },
	[51564]={ class = "SHAMAN", level = 50, },
	[77478]={ class = "SHAMAN", level = 50, },
	[86529]={ class = "SHAMAN", level = 50, },
	[8143]={ class = "SHAMAN", level = 54, },
	[51470]={ class = "SHAMAN", level = 55, },
	[30809]={ class = "SHAMAN", level = 55, },
	[16190]={ class = "SHAMAN", level = 56, },
	[2062]={ class = "SHAMAN", level = 58, },
	[61882]={ class = "SHAMAN", level = 60, },
	[51533]={ class = "SHAMAN", level = 60, },
	[77472]={ class = "SHAMAN", level = 60, },
	[58875]={ class = "SHAMAN", level = 60, },
	[73920]={ class = "SHAMAN", level = 60, },
	[108269]={ class = "SHAMAN", level = 63, },
	[30823]={ class = "SHAMAN", level = 65, },
	[108280]={ class = "SHAMAN", level = 65, },
	[2894]={ class = "SHAMAN", level = 66, },
	[98008]={ class = "SHAMAN", level = 70, },
	[76780]={ class = "SHAMAN", level = 72, },
	[51514]={ class = "SHAMAN", level = 75, },
	[8017]={ class = "SHAMAN", level = 75, },
	[120668]={ class = "SHAMAN", level = 78, },
	[77226]={ class = "SHAMAN", level = 80, },
	[77222]={ class = "SHAMAN", level = 80, },
	[77223]={ class = "SHAMAN", level = 80, },
	[116956]={ class = "SHAMAN", level = 80, },
	[73680]={ class = "SHAMAN", level = 81, },
	[73921]={ class = "SHAMAN", level = 83, },
	[79206]={ class = "SHAMAN", level = 85, },
	[114049]={ class = "SHAMAN", level = 87, },
	[114089]={ class = "SHAMAN", level = 87, },
--++ Warlock ++	
	[56250]={ class = "WARLOCK", level = 25, },
	[56235]={ class = "WARLOCK", level = 25, },
	[63312]={ class = "WARLOCK", level = 25, },
	[58080]={ class = "WARLOCK", level = 25, },
	[146963]={ class = "WARLOCK", level = 25, },
	[63303]={ class = "WARLOCK", level = 25, },
	[56249]={ class = "WARLOCK", level = 25, },
	[63309]={ class = "WARLOCK", level = 25, },
	[63302]={ class = "WARLOCK", level = 25, },
	[63304]={ class = "WARLOCK", level = 25, },
	[148683]={ class = "WARLOCK", level = 25, },
	[58081]={ class = "WARLOCK", level = 25, },
	[56247]={ class = "WARLOCK", level = 25, },
	[56244]={ class = "WARLOCK", level = 25, },
	[56246]={ class = "WARLOCK", level = 25, },
	[135557]={ class = "WARLOCK", level = 25, },
	[56248]={ class = "WARLOCK", level = 25, },
	[146962]={ class = "WARLOCK", level = 25, },
	[56238]={ class = "WARLOCK", level = 25, },
	[56224]={ class = "WARLOCK", level = 25, },
	[56242]={ class = "WARLOCK", level = 25, },
	[63320]={ class = "WARLOCK", level = 25, },
	[56232]={ class = "WARLOCK", level = 25, },
	[56240]={ class = "WARLOCK", level = 25, },
	[56218]={ class = "WARLOCK", level = 25, },
	[58070]={ class = "WARLOCK", level = 25, },
	[56226]={ class = "WARLOCK", level = 25, },
	[56231]={ class = "WARLOCK", level = 25, },
	[58094]={ class = "WARLOCK", level = 25, },
	[58107]={ class = "WARLOCK", level = 25, },
	[56217]={ class = "WARLOCK", level = 25, },
	[135032]={ class = "WARLOCK", level = 25, },
	[58079]={ class = "WARLOCK", level = 25, },
	[146964]={ class = "WARLOCK", level = 25, },
	[56233]={ class = "WARLOCK", level = 25, },
	[56241]={ class = "WARLOCK", level = 25, },
	[137043]={ class = "WARLOCK", level = 1, },
	[137044]={ class = "WARLOCK", level = 1, },
	[137046]={ class = "WARLOCK", level = 1, },
	[108359]={ class = "WARLOCK", level = 15, },
	[108371]={ class = "WARLOCK", level = 15, },
	[108370]={ class = "WARLOCK", level = 15, },
	[108366]={ class = "WARLOCK", level = 15, },
	[110913]={ class = "WARLOCK", level = 45, },
	[108416]={ class = "WARLOCK", level = 45, },
	[108415]={ class = "WARLOCK", level = 45, },
	[111400]={ class = "WARLOCK", level = 60, },
	[108482]={ class = "WARLOCK", level = 60, },
	[108503]={ class = "WARLOCK", level = 75, },
	[108501]={ class = "WARLOCK", level = 75, },
	[108499]={ class = "WARLOCK", level = 75, },
	[108505]={ class = "WARLOCK", level = 90, },
	[137587]={ class = "WARLOCK", level = 90, },
	[108508]={ class = "WARLOCK", level = 90, },
	[137042]={ class = "WARLOCK", level = 1, },
	[87330]={ class = "WARLOCK", level = 1, },
	[101508]={ class = "WARLOCK", level = 1, },
	[137206]={ class = "WARLOCK", level = 1, },
	[686]={ class = "WARLOCK", level = 1, },
	[63106]={ class = "WARLOCK", level = 1, },
	[688]={ class = "WARLOCK", level = 1, },
	[110505]={ class = "WARLOCK", level = 1, },
	[172]={ class = "WARLOCK", level = 3, },
	[131740]={ class = "WARLOCK", level = 3, },
	[146739]={ class = "WARLOCK", level = 3, },
	[689]={ class = "WARLOCK", level = 7, },
	[697]={ class = "WARLOCK", level = 8, },
	[6201]={ class = "WARLOCK", level = 9, },
	[111546]={ class = "WARLOCK", level = 10, },
	[17962]={ class = "WARLOCK", level = 10, },
	[104315]={ class = "WARLOCK", level = 10, },
	[109145]={ class = "WARLOCK", level = 10, },
	[29722]={ class = "WARLOCK", level = 10, },
	[103958]={ class = "WARLOCK", level = 10, },
	[30108]={ class = "WARLOCK", level = 10, },
	[93375]={ class = "WARLOCK", level = 10, },
	[131736]={ class = "WARLOCK", level = 10, },
	[755]={ class = "WARLOCK", level = 11, },
	[109151]={ class = "WARLOCK", level = 12, },
	[348]={ class = "WARLOCK", level = 12, },
	[6353]={ class = "WARLOCK", level = 13, },
	[5782]={ class = "WARLOCK", level = 14, },
	[103128]={ class = "WARLOCK", level = 15, },
	[1454]={ class = "WARLOCK", level = 16, },
	[109466]={ class = "WARLOCK", level = 17, },
	[20707]={ class = "WARLOCK", level = 18, },
	[1120]={ class = "WARLOCK", level = 19, },
	[105174]={ class = "WARLOCK", level = 19, },
	[117198]={ class = "WARLOCK", level = 19, },
	[74434]={ class = "WARLOCK", level = 19, },
	[5784]={ class = "WARLOCK", level = 20, },
	[104233]={ class = "WARLOCK", level = 20, },
	[713]={ class = "WARLOCK", level = 20, },
	[712]={ class = "WARLOCK", level = 20, },
	[124539]={ class = "WARLOCK", level = 20, },
	[5740]={ class = "WARLOCK", level = 21, },
	[1949]={ class = "WARLOCK", level = 22, },
	[126]={ class = "WARLOCK", level = 22, },
	[5697]={ class = "WARLOCK", level = 24, },
	[112089]={ class = "WARLOCK", level = 25, },
	[103139]={ class = "WARLOCK", level = 26, },
	[114129]={ class = "WARLOCK", level = 27, },
	[103101]={ class = "WARLOCK", level = 27, },
	[101976]={ class = "WARLOCK", level = 27, },
	[103130]={ class = "WARLOCK", level = 28, },
	[691]={ class = "WARLOCK", level = 29, },
	[5484]={ class = "WARLOCK", level = 30, },
	[108396]={ class = "WARLOCK", level = 30, },
	[1098]={ class = "WARLOCK", level = 31, },
	[108563]={ class = "WARLOCK", level = 32, },
	[18223]={ class = "WARLOCK", level = 32, },
	[114592]={ class = "WARLOCK", level = 32, },
	[710]={ class = "WARLOCK", level = 32, },
	[103133]={ class = "WARLOCK", level = 33, },
	[103140]={ class = "WARLOCK", level = 33, },
	[6229]={ class = "WARLOCK", level = 34, },
	[980]={ class = "WARLOCK", level = 36, },
	[80240]={ class = "WARLOCK", level = 36, },
	[124913]={ class = "WARLOCK", level = 36, },
	[131737]={ class = "WARLOCK", level = 36, },
	[104938]={ class = "WARLOCK", level = 38, },
	[103136]={ class = "WARLOCK", level = 38, },
	[23161]={ class = "WARLOCK", level = 40, },
	[108647]={ class = "WARLOCK", level = 42, },
	[116858]={ class = "WARLOCK", level = 42, },
	[114635]={ class = "WARLOCK", level = 42, },
	[103103]={ class = "WARLOCK", level = 42, },
	[116852]={ class = "WARLOCK", level = 42, },
	[30146]={ class = "WARLOCK", level = 42, },
	[698]={ class = "WARLOCK", level = 42, },
	[103129]={ class = "WARLOCK", level = 43, },
	[103967]={ class = "WARLOCK", level = 47, },
	[17877]={ class = "WARLOCK", level = 47, },
	[103134]={ class = "WARLOCK", level = 48, },
	[1122]={ class = "WARLOCK", level = 49, },
	[103135]={ class = "WARLOCK", level = 50, },
	[86091]={ class = "WARLOCK", level = 50, },
	[1490]={ class = "WARLOCK", level = 51, },
	[103131]={ class = "WARLOCK", level = 53, },
	[109784]={ class = "WARLOCK", level = 54, },
	[108559]={ class = "WARLOCK", level = 54, },
	[108683]={ class = "WARLOCK", level = 54, },
	[108558]={ class = "WARLOCK", level = 54, },
	[103142]={ class = "WARLOCK", level = 55, },
	[119898]={ class = "WARLOCK", level = 56, },
	[124538]={ class = "WARLOCK", level = 56, },
	[103141]={ class = "WARLOCK", level = 56, },
	[18540]={ class = "WARLOCK", level = 58, },
	[27243]={ class = "WARLOCK", level = 60, },
	[114790]={ class = "WARLOCK", level = 60, },
	[132566]={ class = "WARLOCK", level = 60, },
	[48181]={ class = "WARLOCK", level = 62, },
	[109797]={ class = "WARLOCK", level = 62, },
	[86664]={ class = "WARLOCK", level = 62, },
	[104773]={ class = "WARLOCK", level = 64, },
	[29858]={ class = "WARLOCK", level = 66, },
	[116208]={ class = "WARLOCK", level = 67, },
	[29893]={ class = "WARLOCK", level = 68, },
	[103150]={ class = "WARLOCK", level = 68, },
	[117896]={ class = "WARLOCK", level = 69, },
	[53759]={ class = "WARLOCK", level = 69, },
	[122351]={ class = "WARLOCK", level = 69, },
	[87385]={ class = "WARLOCK", level = 72, },
	[108869]={ class = "WARLOCK", level = 73, },
	[103112]={ class = "WARLOCK", level = 73, },
	[48018]={ class = "WARLOCK", level = 76, },
	[48020]={ class = "WARLOCK", level = 76, },
	[77799]={ class = "WARLOCK", level = 77, },
	[120451]={ class = "WARLOCK", level = 79, },
	[124917]={ class = "WARLOCK", level = 79, },
	[86121]={ class = "WARLOCK", level = 79, },
	[141931]={ class = "WARLOCK", level = 79, },
	[119678]={ class = "WARLOCK", level = 79, },
	[77220]={ class = "WARLOCK", level = 80, },
	[77219]={ class = "WARLOCK", level = 80, },
	[77215]={ class = "WARLOCK", level = 80, },
	[109773]={ class = "WARLOCK", level = 82, },
	[113858]={ class = "WARLOCK", level = 84, },
	[113861]={ class = "WARLOCK", level = 84, },
	[113860]={ class = "WARLOCK", level = 84, },
	[77801]={ class = "WARLOCK", level = 84, },
	[129343]={ class = "WARLOCK", level = 85, },
	[123686]={ class = "WARLOCK", level = 86, },
	[104243]={ class = "WARLOCK", level = 86, },
	[111771]={ class = "WARLOCK", level = 87, },
	[131973]={ class = "WARLOCK", level = 90, },
--++ Warrior ++	
	[112104]={ class = "WARRIOR", level = 25, },
	[58377]={ class = "WARRIOR", level = 25, },
	[58096]={ class = "WARRIOR", level = 25, },
	[58367]={ class = "WARRIOR", level = 25, },
	[58369]={ class = "WARRIOR", level = 25, },
	[94372]={ class = "WARRIOR", level = 25, },
	[115946]={ class = "WARRIOR", level = 25, },
	[89003]={ class = "WARRIOR", level = 25, },
	[115943]={ class = "WARRIOR", level = 25, },
	[63325]={ class = "WARRIOR", level = 25, },
	[58386]={ class = "WARRIOR", level = 25, },
	[58355]={ class = "WARRIOR", level = 25, },
	[58357]={ class = "WARRIOR", level = 25, },
	[58099]={ class = "WARRIOR", level = 25, },
	[58385]={ class = "WARRIOR", level = 25, },
	[58388]={ class = "WARRIOR", level = 25, },
	[58366]={ class = "WARRIOR", level = 25, },
	[58387]={ class = "WARRIOR", level = 25, },
	[58364]={ class = "WARRIOR", level = 25, },
	[146970]={ class = "WARRIOR", level = 25, },
	[122013]={ class = "WARRIOR", level = 25, },
	[63327]={ class = "WARRIOR", level = 25, },
	[58097]={ class = "WARRIOR", level = 25, },
	[58104]={ class = "WARRIOR", level = 25, },
	[58368]={ class = "WARRIOR", level = 25, },
	[58095]={ class = "WARRIOR", level = 25, },
	[58370]={ class = "WARRIOR", level = 25, },
	[94374]={ class = "WARRIOR", level = 25, },
	[58356]={ class = "WARRIOR", level = 25, },
	[58375]={ class = "WARRIOR", level = 25, },
	[63329]={ class = "WARRIOR", level = 25, },
	[63328]={ class = "WARRIOR", level = 25, },
	[58384]={ class = "WARRIOR", level = 25, },
	[123779]={ class = "WARRIOR", level = 25, },
	[146971]={ class = "WARRIOR", level = 25, },
	[146968]={ class = "WARRIOR", level = 25, },
	[146969]={ class = "WARRIOR", level = 25, },
	[146973]={ class = "WARRIOR", level = 25, },
	[146974]={ class = "WARRIOR", level = 25, },
	[68164]={ class = "WARRIOR", level = 25, },
	[58098]={ class = "WARRIOR", level = 25, },
	[146965]={ class = "WARRIOR", level = 25, },
	[58382]={ class = "WARRIOR", level = 25, },
	[63324]={ class = "WARRIOR", level = 25, },
	[58372]={ class = "WARRIOR", level = 25, },
	[137048]={ class = "WARRIOR", level = 1, },
	[137049]={ class = "WARRIOR", level = 1, },
	[137050]={ class = "WARRIOR", level = 1, },
	[119938]={ class = "WARRIOR", level = 1, },
	[102052]={ class = "WARRIOR", level = 1, },
	[103827]={ class = "WARRIOR", level = 15, },
	[103826]={ class = "WARRIOR", level = 15, },
	[103828]={ class = "WARRIOR", level = 15, },
	[55694]={ class = "WARRIOR", level = 30, },
	[103840]={ class = "WARRIOR", level = 30, },
	[118340]={ class = "WARRIOR", level = 30, },
	[29838]={ class = "WARRIOR", level = 30, },
	[102060]={ class = "WARRIOR", level = 45, },
	[46924]={ class = "WARRIOR", level = 60, },
	[118000]={ class = "WARRIOR", level = 60, },
	[114029]={ class = "WARRIOR", level = 75, },
	[107574]={ class = "WARRIOR", level = 90, },
	[137047]={ class = "WARRIOR", level = 1, },
	[128217]={ class = "WARRIOR", level = 1, },
	[88163]={ class = "WARRIOR", level = 1, },
	[2457]={ class = "WARRIOR", level = 1, },
	[50622]={ class = "WARRIOR", level = 1, },
	[95738]={ class = "WARRIOR", level = 1, },
	[123829]={ class = "WARRIOR", level = 1, },
	[113344]={ class = "WARRIOR", level = 1, },
	[117313]={ class = "WARRIOR", level = 1, },
	[78]={ class = "WARRIOR", level = 1, },
	[76858]={ class = "WARRIOR", level = 1, },
	[3127]={ class = "WARRIOR", level = 1, },
	[110506]={ class = "WARRIOR", level = 1, },
	[122475]={ class = "WARRIOR", level = 1, },
	[100]={ class = "WARRIOR", level = 3, },
	[34428]={ class = "WARRIOR", level = 5, },
	[118779]={ class = "WARRIOR", level = 5, },
	[5308]={ class = "WARRIOR", level = 7, },
	[71]={ class = "WARRIOR", level = 9, },
	[131086]={ class = "WARRIOR", level = 10, },
	[23881]={ class = "WARRIOR", level = 10, },
	[23588]={ class = "WARRIOR", level = 10, },
	[12294]={ class = "WARRIOR", level = 10, },
	[12712]={ class = "WARRIOR", level = 10, },
	[23922]={ class = "WARRIOR", level = 10, },
	[29144]={ class = "WARRIOR", level = 10, },
	[93098]={ class = "WARRIOR", level = 10, },
	[355]={ class = "WARRIOR", level = 12, },
	[13046]={ class = "WARRIOR", level = 14, },
	[7386]={ class = "WARRIOR", level = 16, },
	[2565]={ class = "WARRIOR", level = 18, },
	[1464]={ class = "WARRIOR", level = 18, },
	[100130]={ class = "WARRIOR", level = 18, },
	[6343]={ class = "WARRIOR", level = 20, },
	[115799]={ class = "WARRIOR", level = 20, },
	[57755]={ class = "WARRIOR", level = 22, },
	[6552]={ class = "WARRIOR", level = 24, },
	[20243]={ class = "WARRIOR", level = 26, },
	[1680]={ class = "WARRIOR", level = 26, },
	[676]={ class = "WARRIOR", level = 28, },
	[7384]={ class = "WARRIOR", level = 30, },
	[85288]={ class = "WARRIOR", level = 30, },
	[6572]={ class = "WARRIOR", level = 30, },
	[56636]={ class = "WARRIOR", level = 30, },
	[115767]={ class = "WARRIOR", level = 32, },
	[115768]={ class = "WARRIOR", level = 32, },
	[2458]={ class = "WARRIOR", level = 34, },
	[1715]={ class = "WARRIOR", level = 36, },
	[44949]={ class = "WARRIOR", level = 36, },
	[12975]={ class = "WARRIOR", level = 38, },
	[81099]={ class = "WARRIOR", level = 38, },
	[46917]={ class = "WARRIOR", level = 38, },
	[96103]={ class = "WARRIOR", level = 39, },
	[85384]={ class = "WARRIOR", level = 39, },
	[845]={ class = "WARRIOR", level = 44, },
	[84615]={ class = "WARRIOR", level = 46, },
	[871]={ class = "WARRIOR", level = 48, },
	[46915]={ class = "WARRIOR", level = 50, },
	[86101]={ class = "WARRIOR", level = 50, },
	[86110]={ class = "WARRIOR", level = 50, },
	[86535]={ class = "WARRIOR", level = 50, },
	[46953]={ class = "WARRIOR", level = 50, },
	[18499]={ class = "WARRIOR", level = 54, },
	[118038]={ class = "WARRIOR", level = 56, },
	[143268]={ class = "WARRIOR", level = 56, },
	[12950]={ class = "WARRIOR", level = 58, },
	[122509]={ class = "WARRIOR", level = 58, },
	[84608]={ class = "WARRIOR", level = 60, },
	[12972]={ class = "WARRIOR", level = 60, },
	[12328]={ class = "WARRIOR", level = 60, },
	[1719]={ class = "WARRIOR", level = 62, },
	[23920]={ class = "WARRIOR", level = 66, },
	[3411]={ class = "WARRIOR", level = 72, },
	[64382]={ class = "WARRIOR", level = 74, },
	[145672]={ class = "WARRIOR", level = 76, },
	[76857]={ class = "WARRIOR", level = 80, },
	[76838]={ class = "WARRIOR", level = 80, },
	[76856]={ class = "WARRIOR", level = 80, },
	[86346]={ class = "WARRIOR", level = 81, },
	[112048]={ class = "WARRIOR", level = 81, },
	[29725]={ class = "WARRIOR", level = 81, },
	[97462]={ class = "WARRIOR", level = 83, },
	[6544]={ class = "WARRIOR", level = 85, },
	[52174]={ class = "WARRIOR", level = 85, },
	[114203]={ class = "WARRIOR", level = 87, },
	[114192]={ class = "WARRIOR", level = 87, },
	[114207]={ class = "WARRIOR", level = 87, },
--++++++++++	
	[55078]={ level = 1, },
	[50452]={ level = 1, },
	[45524]={ level = 1, },
	[56222]={ level = 1, },
	[77606]={ level = 1, },
	[43265]={ level = 1, },
	[52212]={ level = 1, },
	[49560]={ level = 1, },
	[68766]={ level = 1, },
	[55095]={ level = 1, },
	[67719]={ level = 1, },
	[69917]={ level = 1, },
	[57330]={ level = 1, },
	[49203]={ level = 1, },
	[3714]={ level = 1, },
	[60068]={ level = 1, },
	[47476]={ level = 1, },
	[49206]={ level = 1, },
	[49194]={ level = 1, },
	[50536]={ level = 1, },
	[49016]={ level = 1, },
	[102359]={ level = 1, },
	[102793]={ level = 1, },
	[124974]={ level = 1, },
	[5209]={ level = 1, },
	[99]={ level = 1, },
	[339]={ level = 1, },
	[16979]={ level = 1, },
	[49376]={ level = 1, },
	[45334]={ level = 1, },
	[6795]={ level = 1, },
	[2637]={ level = 1, },
	[16914]={ level = 1, },
	[58179]={ level = 1, },
	[58180]={ level = 1, },
	[29166]={ level = 1, },
	[5570]={ level = 1, },
	[33745]={ level = 1, },
	[33763]={ level = 1, },
	[22570]={ level = 1, },
	[5211]={ level = 1, },
	[8921]={ level = 1, },
	[16689]={ level = 1, },
	[9005]={ level = 1, },
	[1822]={ level = 1, },
	[8936]={ level = 1, },
	[774]={ level = 1, },
	[1079]={ level = 1, },
	[80964]={ level = 1, },
	[80965]={ level = 1, },
	[77761]={ level = 1, },
	[77764]={ level = 1, },
	[97985]={ level = 1, },
	[93402]={ level = 1, },
	[467]={ level = 1, },
	[77758]={ level = 1, },
	[740]={ level = 1, },
	[44203]={ level = 1, },
	[13159]={ level = 1, },
	[19506]={ level = 1, },
	[19577]={ level = 1, },
	[19386]={ level = 1, },
	[131894]={ level = 1, },
	[120761]={ level = 1, },
	[121414]={ level = 1, },
	[413841]={ level = 1, },
	[57669]={ level = 1, },
	[102051]={ level = 1, },
	[111264]={ level = 1, },
	[112948]={ level = 1, },
	[44457]={ level = 1, },
	[116841]={ level = 1, },
	[124081]={ level = 1, },
	[119392]={ level = 1, },
	[119381]={ level = 1, },
	[116844]={ level = 1, },
	[116847]={ level = 1, },
	[107270]={ level = 1, },
	[31935]={ level = 1, },
	[79063]={ level = 1, },
	[79101]={ level = 1, },
	[19746]={ level = 1, },
	[465]={ level = 1, },
	[25771]={ level = 1, },
	[1022]={ level = 1, },
	[19891]={ level = 1, },
	[7294]={ level = 1, },
	[105593]={ level = 1, },
	[20066]={ level = 1, },
	[114163]={ level = 1, },
	[20925]={ level = 1, },
	[114039]={ level = 1, },
	[79105]={ level = 1, },
	[79107]={ level = 1, },
	[15487]={ level = 1, },
	[605]={ level = 1, },
	[110744]={ level = 1, },
	[3409]={ level = 1, },
	[26679]={ level = 1, },
	[108215]={ level = 1, },
	[114018]={ level = 1, },
	[2825]={ level = 1, },
	[73682]={ level = 1, },
	[57724]={ level = 1, },
	[32182]={ level = 1, },
	[57723]={ level = 1, },
	[32643]={ level = 1, },
	[108281]={ level = 1, },
	[50589]={ level = 1, },
	[47897]={ level = 1, },
	[6789]={ level = 1, },
	[30283]={ level = 1, },
	[111397]={ level = 1, },
	[6673]={ level = 1, },
	[1161]={ level = 1, },
	[469]={ level = 1, },
	[413763]={ level = 1, },
	[413764]={ level = 1, },
	[1160]={ level = 1, },
	[5246]={ level = 1, },
	[107566]={ level = 1, },
	[12323]={ level = 1, },
	[46968]={ level = 1, },
	[114028]={ level = 1, },
	[114030]={ level = 1, },
	[12292]={ level = 1, },
	[107570]={ level = 1, },
	[107]={ level = 1, },
	[674]={ level = 10, },
	[5019]={ level = 1, },
	[264]={ level = 1, },
	[5011]={ level = 1, },
	[1180]={ level = 1, },
	[15590]={ level = 1, },
	[266]={ level = 1, },
	[196]={ level = 1, },
	[198]={ level = 1, },
	[201]={ level = 1, },
	[200]={ level = 20, },
	[9116]={ level = 1, },
	[227]={ level = 1, },
	[197]={ level = 1, },
	[199]={ level = 1, },
	[202]={ level = 1, },
	[5009]={ level = 1, },
	[9077]={ level = 1, },
	[8737]={ level = 1, },
	[119811]={ level = 1, },
	[750]={ level = 40, },
	[43308]={ level = 1, },
	[2383]={ level = 1, },
	[8387]={ level = 1, },
	[2580]={ level = 1, },
	[8388]={ level = 1, },
	[28925]={ level = 1, },
	[32977]={ level = 1, },
	[28093]={ level = 1, },
	[38068]={ level = 1, },
	[50310]={ level = 1, },
	[29358]={ level = 1, },
	[29356]={ level = 1, },
	[29361]={ level = 1, },
	[377749]={ level = 1, },
	[45444]={ level = 1, },
	[29175]={ level = 1, },
	[46352]={ level = 1, },
	[48892]={ level = 1, },
	[48890]={ level = 1, },
	[48889]={ level = 1, },
	[48891]={ level = 1, },
	[24708]={ level = 1, },
	[24709]={ level = 1, },
	[24710]={ level = 1, },
	[24711]={ level = 1, },
	[24712]={ level = 1, },
	[24713]={ level = 1, },
	[24714]={ level = 1, },
	[24715]={ level = 1, },
	[24717]={ level = 1, },
	[24718]={ level = 1, },
	[24719]={ level = 1, },
	[24720]={ level = 1, },
	[24723]={ level = 1, },
	[24724]={ level = 1, },
	[24732]={ level = 1, },
	[24733]={ level = 1, },
	[24735]={ level = 1, },
	[24736]={ level = 1, },
	[24737]={ level = 1, },
	[24740]={ level = 1, },
	[24741]={ level = 1, },
	[39953]={ level = 1, },
	[39913]={ level = 1, },
	[39911]={ level = 1, },
	[22888]={ level = 1, },
	[24425]={ level = 1, },
	[16609]={ level = 1, },
	[15366]={ level = 1, },
	[22817]={ level = 50, },
	[22818]={ level = 50, },
	[22820]={ level = 50, },
	[58450]={ level = 70, },
	[58451]={ level = 80, },
	[58452]={ level = 70, },
	[48101]={ level = 70, },
	[60345]={ level = 48, },
	[3166]={ level = 10, },
	[53749]={ level = 27, },
	[60341]={ level = 48, },
	[60344]={ level = 48, },
	[53748]={ level = 48, },
	[60347]={ level = 48, },
	[28499]={ level = 55, },
	[41608]={ level = 70, },
	[67016]={ level = 15, },
	[67017]={ level = 15, },
	[67018]={ level = 15, },
	[67019]={ level = 15, },
	[8690]={ level = 1, },
	[50251]={ level = 1, },
	[32098]={ level = 55, },
	[30452]={ level = 1, },
	[51582]={ level = 1, },
	[349981]={ level = 1, },
	[33265]={ level = 55, },
	[33268]={ level = 55, },
	[35272]={ level = 55, },
	[57079]={ level = 70, },
	[57100]={ level = 70, },
	[57107]={ level = 70, },
	[57325]={ level = 70, },
	[57327]={ level = 70, },
	[57329]={ level = 70, },
};