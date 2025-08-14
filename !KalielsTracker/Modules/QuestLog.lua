--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local _, KT = ...
local M = KT:NewModule("QuestLog")
KT.QuestLog = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db

--------------
-- Internal --
--------------

local function SetHooks()
	-- QuestLogFrame.lua
	function _QuestLog_ToggleQuestWatch(questIndex)  -- R
		if not db.filterAuto[1] then
			if IsQuestWatched(questIndex) then
				RemoveQuestWatch(questIndex)
			else
				if GetNumQuestWatches() < MAX_WATCHABLE_QUESTS then
					AddQuestWatch(questIndex)
				end
			end
			if WOW_PROJECT_ID > WOW_PROJECT_CLASSIC then
				QuestMapFrame_UpdateAll()
			end
		end
	end

	function QuestLogTitleButton_OnClick(self, button)  -- R
		local questIndex = self:GetID();
		if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
			questIndex = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		end
		if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
			-- If header then return
			if ( self.isHeader ) then
				return;
			end

			local questLink = GetQuestLink(GetQuestIDFromLogIndex(questIndex));
			if ( questLink ) then
				ChatEdit_InsertLink(questLink);
			end
		elseif ( IsShiftKeyDown() ) then
			-- If header then return
			if ( self.isHeader ) then
				return;
			end

			-- Shift-click toggles quest-watch on this quest.
			if not db.filterAuto[1] then
				_QuestLog_ToggleQuestWatch(questIndex);
			else
				return;
			end
		end
		QuestLog_SetSelection(questIndex)
		QuestLog_Update();
	end

	-- QuestMapFrame.lua
	if WOW_PROJECT_ID > WOW_PROJECT_CLASSIC then
		hooksecurefunc("QuestMapFrame_UpdateAll", function(numPOIs)
			if db.filterAuto[1] then
				WorldMapTrackQuest:Disable()
			else
				WorldMapTrackQuest:Enable()
			end
		end)
	end

	-- WatchFrame.lua
	if WOW_PROJECT_ID > WOW_PROJECT_CLASSIC then
		WatchFrame_Update = function() end
	else
		QuestWatch_OnLogin = function() end
		QuestWatch_Update = function() end
		AutoQuestWatch_CheckDeleted = function() end
		AutoQuestWatch_Update = function() end
		AutoQuestWatch_OnUpdate = function() end
	end
end

--------------
-- External --
--------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	SetHooks()
end