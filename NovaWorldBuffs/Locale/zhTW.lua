--Big thanks to VJ KOKUSHO for translating the TW version of this addon.
--There is no TW version of wowhead and NovaWorldBuffs wouldn't work in TW without him.

local L = LibStub("AceLocale-3.0"):NewLocale("NovaWorldBuffs", "zhTW");
if (not L) then
	return;
end

--Rend buff aura name.
L["Warchief's Blessing"] = "酋長的祝福";
--Onyxia and Nefarian buff aura name.
L["Rallying Cry of the Dragonslayer"] = "屠龍者的咆哮";
--Songflower buff aura name from felwood.
L["Songflower Serenade"] = "風歌夜曲";
L["Songflower"] = "輕歌花";
--Spirit of Zandalar.
L["Spirit of Zandalar"] = "贊達拉之魂";
L["Flask of Supreme Power"] = "超級能量精煉藥水";
L["Flask of the Titans"] = "泰坦精煉藥水";
L["Flask of Distilled Wisdom"] = "智慧精煉藥水";
L["Flask of Chromatic Resistance"] = "多重抗性精煉藥水";
--3 of the flasks spells seem to be named differently than the flask item, but titan is exact same name as the flask item.
L["Supreme Power"] = "至高能量";
L["Distilled Wisdom"] = "萃取智慧";
L["Chromatic Resistance"] = "多彩抗性";
L["Sap"] = "悶棍";
L["Fire Festival Fortitude"] = "火焰節慶之韌";
L["Fire Festival Fury"] = "火焰節慶之怒";
L["Ribbon Dance"] = "緞帶舞";
L["Slip'kik's Savvy"] = "斯里基克的機智";
L["Fengus' Ferocity"] = "芬古斯的狂暴";
L["Mol'dar's Moxie"] = "摩爾達的勇氣";
L["Boon of Blackfathom"] = "黑澗深淵的恩賜";
L["Ashenvale Rallying Cry"] = "梣谷振奮咆哮";
L["Spark of Inspiration"] = "鼓舞火花"; --Phase 2 SoD world buff.
L["Fervor of the Temple Explorer"] = "神廟探險者狂熱";

---=====---
---Horde---
---=====---

--Horde Orgrimmar Rend buff NPC.
L["Thrall"] = "索爾";
--Horde The Barrens Rend buff NPC.
L["Herald of Thrall"] = "索爾的使者";
--Horde rend buff NPC first yell string (part of his first yell msg before before buff).
L["Rend Blackhand, has fallen"] = "為你們的英雄而歡慶";
--Horde rend buff NPC second yell string (part of his second yell msg before before buff).
L["Be bathed in my power"] = "沐浴在我的力量中吧";

--Horde Onyxia buff NPC.
L["Overlord Runthak"] = "倫薩克";
--Horde Onyxia buff NPC first yell string (part of his first yell msg before before buff).
L["Onyxia, has been slain"] = "部落的人民，奧格瑪的城民";
--Horde Onyxia buff NPC second yell string (part of his second yell msg before before buff).
L["Be lifted by the rallying cry"] = "在屠龍大軍的戰鬥口號聲中精神抖擻地前進吧";

--Horde Nefarian buff NPC.
L["High Overlord Saurfang"] = "薩魯法爾大王";
--Horde Nefarian buff NPC first yell string (part of his first yell msg before before buff).
L["NEFARIAN IS SLAIN"] = "奈法利安被幹掉了";
--Horde Nefarian buff NPC second yell string (part of his second yell msg before before buff).
L["Revel in his rallying cry"] = "為他的勝利而狂歡吧";

---===========----
---NPC's killed---
---============---

L["onyxiaNpcKilledHorde"] = "倫薩克已經被殺了!(奧妮克西婭增益NPC ).";
L["onyxiaNpcKilledAlliance"] = "瑪丁雷少校已經被殺了! (奧妮克西婭增益NPC).";
L["nefarianNpcKilledHorde"] = "薩魯法爾大王已經被殺了! (奈法利安增益NPC ).";
L["nefarianNpcKilledAlliance"] = "艾法希比元帥已經被殺了! (奈法利安增益NPC ).";
L["onyxiaNpcKilledHordeWithTimer"] = "奧妮克西婭增益NPC (倫薩克) 已經被殺了 %s 時間，之後沒有任何增益紀錄。";
L["nefarianNpcKilledHordeWithTimer"] = "奈法利安增益NPC (薩魯法爾) 以經被殺了 %s 時間，之後沒有任何增益紀錄。";
L["onyxiaNpcKilledAllianceWithTimer"] = "奧妮克西婭增益NPC (瑪丁雷) 已經被殺了 %s 時間，之後沒有任何增益紀錄。";
L["nefarianNpcKilledAllianceWithTimer"] = "奈法利安增益NPC (艾法希比) 以經被殺了 %s 時間，之後沒有任何增益紀錄。";
L["anyNpcKilledWithTimer"] = "在 %s 以前被殺了"; --Map timers tooltip msg.

---========---
---Alliance---
---========---

--Alliance Onyxia buff NPC.
L["Major Mattingly"] = "瑪丁雷少校";
--Alliance Onyxia buff NPC first yell string (part of his first yell msg before before buff).
L["history has been made"] = "暴風城的城民和盟友們";
--Alliance Onyxia buff NPC second yell string (part of his second yell msg before before buff).
L["Onyxia, hangs from the arches"] = "看看強大的聯盟吧";


--Alliance Nefarian buff NPC.
L["Field Marshal Afrasiabi"] = "艾法希比元帥";
L["Field Marshal Stonebridge"] = "戰場元帥石橋";
--Alliance Nefarian buff NPC first yell string (part of his first yell msg before before buff).
L["the Lord of Blackrock is slain"] = "聯盟的人民們";
--Alliance Nefarian buff NPC second yell string (part of his second yell msg before before buff).
L["Revel in the rallying cry"] = "興奮起來";

---==============---
---Darkmoon Faire---
---==============---

L["Darkmoon Faire"] = "暗月馬戲團";
L["Sayge's Dark Fortune of Agility"] = "賽吉的敏捷黑暗籤詩";
L["Sayge's Dark Fortune of Intelligence"] = "賽吉的智力黑暗籤詩";
L["Sayge's Dark Fortune of Spirit"] = "賽吉的精神黑暗籤詩";
L["Sayge's Dark Fortune of Stamina"] = "賽吉的耐力黑暗籤詩";
L["Sayge's Dark Fortune of Strength"] = "賽吉的力量黑暗籤詩";
L["Sayge's Dark Fortune of Armor"] = "賽吉的護甲黑暗籤詩";
L["Sayge's Dark Fortune of Resistance"] = "賽吉的抗性黑暗籤詩";
L["Sayge's Dark Fortune of Damage"] = "賽吉的傷害黑暗籤詩";
L["dmfBuffCooldownMsg"] = "你的暗月馬戲團增益倒數剩下 %s 。";
L["dmfBuffCooldownMsg2"] = "你的暗月馬戲團增益倒數剩下 %s 。";
L["dmfBuffCooldownMsg3"] = "暗月馬戲團增益冷卻時間也在伺服器每周重置時重置。"; --/wb frame 2nd msg.
L["dmfBuffReady"] = "你的暗月馬戲團增益已經停止倒數。";
L["dmfBuffReset"] = "你的暗月馬戲團增益冷卻時間已經重置。";
L["dmfBuffDropped"] = "暗月馬戲團增益 %s 已取得, 您可以使用 /dmf，查詢遊戲內冷卻時間，以再次獲得馬戲團增益。";
L["dmfSpawns"] = "暗月馬戲團出現在 %s (%s)";
L["dmfEnds"] = "暗月馬戲團活動已經開始，這結束在 %s (%s)";
L["mulgore"] = "莫高雷";
L["elwynnForest"] = "艾爾文森林";
				
---==============---
---Output Strings---
---==============---
L["rend"] = "雷德"; --Rend Blackhand
L["onyxia"] = "奧妮克西婭"; --Onyxia
L["nefarian"] = "奈法利安"; --Nefarian
L["dmf"] = "暗月馬戲團"; --Darkmoon Faire
L["noTimer"] = "未取得"; --No timer (used only in map timer frames)
L["noCurrentTimer"] = "未取得"; --No current timer
L["noActiveTimers"] = "未啟動";	--No active timers
L["newBuffCanBeDropped"] = "一個新的 %s 增益現在可以取得";
L["buffResetsIn"] = "%s 重置在 %s";
L["rendFirstYellMsg"] = "酋長祝福的閃電，將在6秒後施放。";
L["onyxiaFirstYellMsg"] = "奧妮克西婭的頭顱已插，閃電將在14秒後施放。";
L["nefarianFirstYellMsg"] = "奈法利安的頭顱已插，閃電將在15秒後施放。";
L["rendBuffDropped"] = "酋長的祝福(雷德) 已經施放。";
L["onyxiaBuffDropped"] = "屠龍者的咆哮 (奧妮克西婭) 已經施放。";
L["nefarianBuffDropped"] = "屠龍者的咆哮 (奈法利安) 已經施放。";
L["newSongflowerReceived"] = "收到了新的輕歌花計時"; --New songflower timer received
L["songflowerPicked"] = "輕歌花已被拾取，在 %s ，重生在25分鐘後。"; -- Guild msg when songflower picked.
L["North Felpaw Village"] = "魔爪村北邊"; --Felwood map subzones (flower1).
L["West Felpaw Village"] = "魔爪村西邊"; --Felwood map subzones (flower2).
L["North of Irontree Woods"] = "鐵木森林北邊"; --Felwood map subzones (flower3).
L["Talonbranch Glade"] = "刺枝林地"; --Felwood map subzones (flower4).
L["Shatter Scar Vale"] = "碎痕谷"; --Felwood map subzones (flower5).
L["Bloodvenom Post"] = "血毒崗哨"; --Felwood map subzones (flower6).
L["East of Jaedenar"] = "加德納爾東邊"; --Felwood map subzones (flower7).
L["North of Emerald Sanctuary"] = "翡翠聖地北邊"; --Felwood map subzones (flower8).
L["West of Emerald Sanctuary"] = "翡翠聖地西邊"; --Felwood map subzones (flower9).
L["South of Emerald Sanctuary"] = "翡翠聖地南邊"; --Felwood map subzones (flower10).
L["second"] = "秒"; --Second (singular).
L["seconds"] = "秒"; --Seconds (plural).
L["minute"] = "分"; --Minute (singular).
L["minutes"] = "分"; --Minutes (plural).
L["hour"] = "小時"; --Hour (singular).
L["hours"] = "小時"; --Hours (plural).
L["day"] = "天"; --Day (singular).
L["days"] = "天"; --Days (plural).
L["secondShort"] = "秒"; --Used in short timers like 1m30s (single letter only, usually the first letter of seconds).
L["minuteShort"] = "分"; --Used in short timers like 1m30s (single letter only, usually the first letter of minutes).
L["hourShort"] = "小時"; --Used in short timers like 1h30m (single letter only, usually the first letter of hours).
L["dayShort"] = "天"; --Used in short timers like 1d8h (single letter only, usually the first letter of days).
L["startsIn"] = "在 %s 後開始"; --"Starts in 1hour".
L["endsIn"] = "在 %s 後結束"; --"Ends in 1hour".
L["versionOutOfDate"] = "你的<Nova World Buffs>插件已經過期了，請上https://www.curseforge.com/wow/addons/nova-world-buffs 更新，或通過twitch客戶端更新。";
L["Your Current World Buffs"] = "目前已有的世界增益";
L["Options"] = " 設定";

---New stuff---

--Spirit of Zandalar buff NPC first yell string (part of his first yell msg before before buff).
L["Begin the ritual"] = "開始儀式"
L["The Blood God"] = "血神"; --First Booty bay yell from Zandalarian Emissary.
--Spirit of Zandalar buff NPC second yell string (part of his second yell msg before before buff).
L["slayer of Hakkar"] = "殺死哈卡";

L["Molthor"] = "莫托爾"; --NPC on zaldalar sland you hand in ZG head to.
L["Zandalarian Emissary"] = "贊達拉大使";
L["Whipper Root Tuber"] = "鞭根塊莖";
L["Night Dragon's Breath"] = "夜龍之息";
L["Resist Fire"] = "抵抗火焰"; -- LBRS fire resist buff.
L["Blessing of Blackfathom"] = "黑暗深淵的祝福";

L["zan"] = "贊達拉";
L["zanFirstYellMsg"] = "贊達拉之魂，將在%s秒後施放。";
L["zanBuffDropped"] = "贊達拉之魂已經施放。";
L["singleSongflowerMsg"] = "%s 的輕歌花重生在 %s。"; -- Songflower at Bloodvenom Post spawns at 1pm.
L["spawn"] = "重生"; --Used in Felwood map marker tooltip (03:46pm spawn).
L["Irontree Woods"] = "鐵木森林";
L["West of Irontree Woods"] = "鐵木森林西邊";
L["Bloodvenom Falls"] = "血毒瀑布";
L["Jaedenar"] = "加德納爾";
L["North-West of Irontree Woods"] = "鐵木森林西北邊";
L["South of Irontree Woods"] = "鐵木森林南邊";

L["worldMapBuffsMsg"] = "輸入 /buffs 可以看到你\n所有角色的世界增益。";
L["cityMapLayerMsgHorde"] = "正確 %s\n選取奧格瑪的任何NPC\n 來更新鏡像資訊。|r";
L["cityMapLayerMsgAlliance"] = "正確 %s\n選取暴風城的任何NPC\n 來更新鏡像資訊。|r";
L["noLayerYetHorde"] = "請點選奧格瑪的任何NPC\n來取得鏡像資訊。";
L["noLayerYetAlliance"] = "請點選暴風城的任何NPC\n來取得鏡像資訊。";
L["Reset Data"] = "重置資料"; --A button to Reset buffs window data.

L["layerFrameMsgOne"] = "伺服器重啟後，舊的鏡像依會保持顯示幾個小時。"; --Msg at bottom of layer timers frame.
L["layerFrameMsgTwo"] = "沒有計時器後的幾個小時鏡像會消失。"; --Msg at bottom of layer timers frame.
L["You are currently on"] = "你目前正在"; --You are currently on [Layer 2]


-------------
---Config---
-------------
--There are 2 types of strings here, the names end in Title or Desc L["exampleTitle"] and L["exampleDesc"].
--Title must not be any longer than 21 characters (maybe less for chinese characters because they are larger).
--Desc can be any length.

---Description at the top---
L["mainTextDesc"] = "輸入 /wb 對你顯示計時器視窗。 \n輸入 /wb <頻道名> 對指定頻道顯示計時器。 \n往下滾動滑鼠有更多選項。";

---Show Buffs Button
L["showBuffsTitle"] = "單擊以顯示您當前的世界增益";
L["showBuffsDesc"] = "顯示你所有角色當前的世界增益， 這個功能同樣可輸入/buffs 開啟，或點擊聊天頻道開頭的 [WorldBuffs] 。";

---General Options---
L["generalHeaderDesc"] = "一般選項";

L["showWorldMapMarkersTitle"] = "城市計時器";
L["showWorldMapMarkersDesc"] = "在世界地圖上的奧格瑪/暴風城顯示計時圖標。";

L["receiveGuildDataOnlyTitle"] = "只接受公會數據";
L["receiveGuildDataOnlyDesc"] = "這會讓你不向公會以外的任何人取得計時資料。 僅當您認為有人故意製造錯誤的計時器數據時，才應啟用此功能，因為這樣做會降低計時器的準確性，減少了從中提取數據的人員。因為它們很短，所以很難獲得輕歌花計時器。公會中的每個人都需要啟用此功能才能正常工作。";

L["chatColorTitle"] = "聊天訊息顏色";
L["chatColorDesc"] = "聊天頻道的計時器聊天的顏色。";

L["middleColorTitle"] = "警告訊息顏色";
L["middleColorDesc"] = "在螢幕中的團隊警告訊息的顏色。";

L["resetColorsTitle"] = "重置顏色";
L["resetColorsDesc"] = "重置顏色回到預設值。";

L["showTimeStampTitle"] = "顯示時間戳";
L["showTimeStampDesc"] = "顯示時間戳 (1:23pm) 在計時器訊息旁邊。";

L["timeStampFormatTitle"] = "時間戳格式";
L["timeStampFormatDesc"] = "設置使用的時間戳格式為12小時制（1:23 pm）或24小時制（13:23）。";

L["timeStampZoneTitle"] = "本地時間/伺服器時間";
L["timeStampZoneDesc"] = "使用本地時間或是伺服器時間當時間戳。";

L["colorizePrefixLinksTitle"] = "字首連結的顏色";
L["colorizePrefixLinksDesc"] = "可以改變字首 [WorldBuffs] 顏色在所有聊天頻道。 這是在聊天頻道的字首你可以點擊顯示你所有角色當前的世界增益。";

L["showAllAltsTitle"] = "所有分身";
L["showAllAltsDesc"] = "在 /buffs 視窗中顯示所有分身，即使它們沒有作用中的增益。";

L["minimapButtonTitle"] = "顯示小地圖按鈕";
L["minimapButtonDesc"] = "在小地圖顯示NWB的按鈕。";

---Logon Messages---
L["logonHeaderDesc"] = "登入訊息";

L["logonPrintTitle"] = "登入計時器";
L["logonPrintDesc"] = "當你登入的時候顯示計時器時間, 你可以用這個選項關掉所有登入訊息。";

L["logonRendTitle"] = "雷德";
L["logonRendDesc"] = "在你登入的時候在聊天視窗顯示雷德計時。";

L["logonOnyTitle"] = "奧妮克西婭";
L["logonOnyDesc"] = "在你登入的時候在聊天視窗顯示奧妮克西婭計時。";

L["logonNefTitle"] = "奈法利安";
L["logonNefDesc"] = "在你登入的時候在聊天視窗顯示奈法利安計時。";

L["logonDmfSpawnTitle"] = "暗月馬戲團重生";
L["logonDmfSpawnDesc"] = "顯示暗月馬戲團重生時間, 這只有在不到六小時重生時才會顯示。";

L["logonDmfBuffCooldownTitle"] = "暗月馬戲團增益冷卻";
L["logonDmfBuffCooldownDesc"] = "顯示暗月馬戲團增益四小時倒數, 只有當你啟動冷卻時間及獲得按月增益才會顯示。";

---Chat Window Timer Warnings---
L["chatWarningHeaderDesc"] = "聊天視窗計時器警告";

L["chat30Title"] = "30 分";
L["chat30Desc"] = "在聊天視窗顯示還剩下 30 分。";

L["chat15Title"] = "15 分";
L["chat15Desc"] = "在聊天視窗顯示還剩下 15 分。";

L["chat10Title"] = "10 分";
L["chat10Desc"] = "在聊天視窗顯示還剩下 10 分。";

L["chat5Title"] = "5 分";
L["chat5Desc"] = "在聊天視窗顯示還剩下 5 分。";

L["chat1Title"] = "1 分";
L["chat1Desc"] = "在聊天視窗顯示還剩下 1 分。";

L["chatResetTitle"] = "增益重置時間";
L["chatResetDesc"] = "在增益重置及可獲得新的時，在聊天視窗顯示提示警告。";

L["chatZanTitle"] = "贊達拉增益警告";
L["chatZanDesc"] = "在贊達拉npc開始喊話及增益施放前30秒，在聊天視窗出現訊息警告。";

---Middle Of The Screen Timer Warnings---
L["middleWarningHeaderDesc"] = "螢幕中間計時器警告";

L["middle30Title"] = "30 分";
L["middle30Desc"] = "當剩餘時間為30分時，在螢幕中間出現團隊警告樣式的警告訊息。";

L["middle15Title"] = "15 分";
L["middle15Desc"] = "當剩餘時間為15分時，在螢幕中間出現團隊警告樣式的警告訊息。";

L["middle10Title"] = "10 分";
L["middle10Desc"] = "當剩餘時間為10分時，在螢幕中間出現團隊警告樣式的警告訊息。";

L["middle5Title"] = "5 分";
L["middle5Desc"] = "當剩餘時間為5分時，在螢幕中間出現團隊警告樣式的警告訊息。";

L["middle1Title"] = "1 分";
L["middle1Desc"] = "當剩餘時間為1分時，在螢幕中間出現團隊警告樣式的警告訊息。";

L["middleResetTitle"] = "增益已經重置";
L["middleResetDesc"] = "當增益已經重置可施放新的增益的時候，在螢幕中間出現團隊警告樣式的警告訊息。";

L["middleBuffWarningTitle"] = "增益施放警告";
L["middleBuffWarningDesc"] = "當任何人看到任何增益及增益施放前npc喊話的時候，在螢幕中間出現團隊警告樣式的警告訊息。";

L["middleHideCombatTitle"] = "在戰鬥中隱藏";
L["middleHideCombatDesc"] = "在戰鬥中隱藏螢幕警告訊息。";

L["middleHideRaidTitle"] = "在團隊中隱藏";
L["middleHideRaidDesc"] = "在團隊副本中隱藏螢幕警告訊息(普通副本不隱藏)";

---Guild Messages---
L["guildWarningHeaderDesc"] = "公會訊息";

L["guild10Title"] = "10 分";
L["guild10Desc"] = "當剩餘時間為10分時傳送公會訊息。";

L["guild1Title"] = "1 分";
L["guild1Desc"] = "當剩餘時間為1分時傳送公會訊息。";

L["guildNpcDialogueTitle"] = "NPC喊話開始";
L["guildNpcDialogueDesc"] = "當有人掛頭的時候傳送公會訊息，在NPC第一句喊話時，你仍然有時間去重登如果你夠快。";

L["guildBuffDroppedTitle"] = "新的增益施放";
L["guildBuffDroppedDesc"] = "當新的增益施放時，傳送一個訊息給公會。 這個訊息會在NPC完成喊話及你時記得到增益的幾秒後。(雷德第一句喊話後6秒, 奧妮14秒, 奈法15秒)";

L["guildZanDialogueTitle"] = "ZG增益警告";
L["guildZanDialogueDesc"] = "當贊達拉之魂將要施放時，傳送一個訊息。 (如果你想要沒有顯示這個增益那公會的所有人都需要關閉這個選項)。";

L["guildNpcKilledTitle"] = "NPC被殺了";
L["guildNpcKilledDesc"] = "當NPC在奧格瑪或暴風城被殺時，傳送公會訊息。 (心控重置).";

L["guildCommandTitle"] = "公會指令";
L["guildCommandDesc"] = "當有人打!wb 及 !dmf 指令時，傳送公會訊息。 你應該開啟這個功能去幫助你的公會, 如果你真的要關閉所有公會訊息只保留此指令，應在公會訊息中選取其他選項，不要在上面打勾 關閉所有公會訊息 選項。 ";

L["disableAllGuildMsgsTitle"] = "關閉所有公會訊息";
L["disableAllGuildMsgsDesc"] = "關閉所有公會訊息，包刮計時與增益施放。 注意: 您可以一個一個停用所有訊息，如果願意，可以僅啟用一部分功能來幫助你的公會。";

---Songflowers---
L["songflowersHeaderDesc"] = "輕歌花";

L["guildSongflowerTitle"] = "當拾取時告訴公會";
L["guildSongflowerDesc"] = "當拾取輕歌花時，傳送公會訊息與下一個重生時間。";

L["mySongflowerOnlyTitle"] = "只有當自己拾取時";
L["mySongflowerOnlyDesc"] = "只有當自己拾取時，紀錄輕歌花的時間。 這個選項只有在你遇有人傳送假的計時才使用。 目前沒有辦法判定其他玩家的增益是否是新的，如果有玩家在你面前登入並帶有輕歌花的增益時，有極少機會造成錯誤的時間。 ";

L["syncFlowersAllTitle"] = "跟所有人同步輕歌花的時間";
L["syncFlowersAllDesc"] = "打開這選項可以跟公會以外的人分享輕歌花的時間，但不會分享其他世界增益。";

L["showNewFlowerTitle"] = "顯示新的輕歌花計時器";
L["showNewFlowerDesc"] = "''當找一個新的計時器在非公會成員身上時，顯示在聊天視窗警告'' (當公會成員取得輕歌花計時已經會出現在公會訊息).";

L["showSongflowerWorldmapMarkersTitle"] = "輕歌花世界地圖";
L["showSongflowerWorldmapMarkersDesc"] = "在世界地圖顯示輕歌花的圖示。";

L["showSongflowerMinimapMarkersTitle"] = "輕歌花小地圖";
L["showSongflowerMinimapMarkersDesc"] = "在小地圖顯示輕歌花。";

L["showTuberWorldmapMarkersTitle"] = "鞭根塊莖世界地圖";
L["showTuberWorldmapMarkersDesc"] = "在世界地圖顯示鞭根塊莖的圖示。";

L["showTuberMinimapMarkersTitle"] = "鞭根塊莖小地圖";
L["showTuberMinimapMarkersDesc"] = "在小地圖顯示輕歌花在。";

L["showDragonWorldmapMarkersTitle"] = "夜龍之息世界地圖";
L["showDragonWorldmapMarkersDesc"] = "在世界地圖顯示夜龍之息的圖示。";

L["showDragonMinimapMarkersTitle"] = "夜龍之息";
L["showDragonMinimapMarkersDesc"] = "在小地圖顯示夜龍之息。";

L["showExpiredTimersTitle"] = "顯示過期計時器";
L["showExpiredTimersDesc"] = "在費伍德顯示過期計時器。 它們將以紅色文字計時器顯示過期多長時間，默認時間為5分鐘 (有人說重生時會保持五分鐘乾淨的輕歌花。).";

L["expiredTimersDurationTitle"] = "過期計時器長短";
L["expiredTimersDurationDesc"] = "在廢伍德計時器過期後，顯示多久過期計時器時間。";

---Darkmoon Faire---
L["dmfHeaderDesc"] = "暗月馬戲團";

L["dmfTextDesc"] = "如果你有暗月馬戲團傷害增益冷卻時間並且暗月馬戲團當前處於活動狀態，則則暗月馬戲團傷害增益冷卻時間也會顯示在暗月馬戲團的地圖。";

L["showDmfWbTitle"] = "使用 /wb 顯示按月馬息團時間";
L["showDmfWbDesc"] = "使用 /wb 指令也一起顯示暗月馬戲團時間。";

L["showDmfBuffWbTitle"] = "使用 /wb 顯示暗月馬戲團增益倒數";
L["showDmfBuffWbDesc"] = "使用 /wb 指令也一起顯示暗月馬戲團增益冷卻時間。 只當你有暗月馬戲團增益冷卻狀態時.";

L["showDmfMapTitle"] = "顯示地圖標記";
L["showDmfMapDesc"] = "在莫高雷及艾爾文森林顯示暗月馬戲團地圖標記及冷卻時間 (下一個重生時間). 你也可以輸入 /dmf map 打開帶有標記的世界地圖。";

---Guild Chat Filter---
L["guildChatFilterHeaderDesc"] = "公會聊天過濾";

L["guildChatFilterTextDesc"] = "這將會阻擋所有從這個插件發送的公會訊息，如果你選了你將看不到它。 這將會停止你自己看到訊息及公會其他人使用這個插件的訊息。";

L["filterYellsTitle"] = "過濾增益警告";
L["filterYellsDesc"] = "過濾掉這個增益要施放時的訊息 (奧妮克西婭的頭顱已插，閃電將在14秒後施放。)。";

L["filterDropsTitle"] = "過濾增益施放警告";
L["filterDropsDesc"] = "過濾掉增益施放時的訊息 (屠龍者的咆嘯 (奧妮克西婭) 以施放)。";

L["filterTimersTitle"] = "過濾計時器訊息";
L["filterTimersDesc"] = "過濾掉計時器 (奧妮克西婭增益重置在1分鐘後)。";

L["filterCommandTitle"] = "過濾 !wb 命令";
L["filterCommandDesc"] = "當有公會的人打 !wb 及 !dmf 指令，會被過濾掉。";

L["filterCommandResponseTitle"] = "過濾 !wb 回復";
L["filterCommandResponseDesc"] = "當有公會的人打 !wb 及 !dmf 指令，回復的消息會被過濾掉。";

L["filterSongflowersTitle"] = "過濾輕歌花";
L["filterSongflowersDesc"] = "過濾當花被拾取的訊息";

L["filterNpcKilledTitle"] = "過濾NPC被殺訊息";
L["filterNpcKilledDesc"] = "'當你的主城有人殺掉NPC時訊息會被過濾。'";

---Sounds---
L["soundsHeaderDesc"] = "聲音";

L["soundsTextDesc"] = "將聲音設定成 \"None\" 來停用。";

L["disableAllSoundsTitle"] = "關閉所有聲音";
L["disableAllSoundsDesc"] = "關閉所以從這個插件來的聲音。";

L["extraSoundOptionsTitle"] = "額外聲音選項";
L["extraSoundOptionsDesc"] = "開啟這個選項在下拉選單顯示所有插件的音效。";

L["soundOnlyInCityTitle"] = "只有城市裡";
L["soundOnlyInCityDesc"] = "只有在你主城(有增益施放的地方)才撥放增益音效(包括贊達拉)。";

L["soundsDisableInInstancesTitle"] = "出團停用";
L["soundsDisableInInstancesDesc"] = "打團隊副本時停用。";

L["soundsFirstYellTitle"] = "增益準備施放";
L["soundsFirstYellDesc"] = "當增益準備施放 (第一句 NPC 的喊話時).";

L["soundsOneMinuteTitle"] = "一分鐘警告";
L["soundsOneMinuteDesc"] = "音效在剩下一分鐘時警告。";

L["soundsRendDropTitle"] = "獲得雷德增益";
L["soundsRendDropDesc"] = "音效在雷德增益施放時及你取得增益時播放。";

L["soundsOnyDropTitle"] = "獲得奧妮增益";
L["soundsOnyDropDesc"] = "音效在奧妮克西婭增益施放時及你取得增益時播放。";

L["soundsNefDropTitle"] = "獲得奈法增益";
L["soundsNefDropDesc"] = "音效在奈法利安增益施放時及你取得增益時播放。";

L["soundsZanDropTitle"] = "獲得贊達拉增益";
L["soundsZanDropDesc"] = "音效在贊達拉增益施放時及你取得增益時播放。";

---Flash When Minimized---
L["flashHeaderDesc"] = "當最小化時閃爍";

L["flashOneMinTitle"] = "一分鐘閃爍";
L["flashOneMinDesc"] = "當你最小化魔獸視窗及剩下一分鐘時閃爍。";

L["flashFirstYellTitle"] = "NPC喊話閃爍";
L["flashFirstYellDesc"] = "當你最小化魔獸視窗及NPC喊話在增益施放前閃爍。";

L["flashFirstYellZanTitle"] = "閃亮亮贊達拉";
L["flashFirstYellZanDesc"] = "當你最小化魔獸視窗及贊達拉增益準備出來吃。";

---Faction/realm specific options---

L["allianceEnableRendTitle"] = "開啟聯盟雷德";
L["allianceEnableRendDesc"] = "啟動選項聯盟可以追蹤雷德,為公會心控取得雷德增益。 如果你使用這個功能那公會使用此插件應該開啟，但是公會訊息可能不會顯示。 (個人計時器顯示正常)。";

L["minimapLayerFrameTitle"] = "顯示小地圖鏡像";
L["minimapLayerFrameDesc"] = "當你在主城，在小地圖上出現一個鏡像框架，顯示你的鏡像。";

L["minimapLayerFrameResetTitle"] = "重置小地圖鏡像";
L["minimapLayerFrameResetDesc"] = "重置小地圖鏡像框到預設位置 (按住 SHIFT 可以拖曳鏡像框).";

L["dispelsHeaderDesc"] = "驅散";

L["dispelsMineTitle"] = "顯示我被驅散";
L["dispelsMineDesc"] = "當我的增益被驅散時顯示?這將會顯示誰驅散了你什麼增益。";

L["dispelsMineWBOnlyTitle"] = "只顯示我的世界增益";
L["dispelsMineWBOnlyDesc"] = "只顯示我的世界增益被驅散，一般增益不顯示。";

L["soundsDispelsMineTitle"] = "增益驅散音效";
L["soundsDispelsMineDesc"] = "我的增益被驅散時要撥放什麼音效";

L["dispelsAllTitle"] = "所有驅散";
L["dispelsAllDesc"] = "在聊天顯示所有在我身邊被驅散的人? 這個會顯示所有靠近你的人被驅散了什麼增益。";

L["dispelsAllWBOnlyTitle"] = "只顯示世界增益";
L["dispelsAllWBOnlyDesc"] = "只會顯示在你身邊被驅散的世界增益，不會顯示一般增益。";

L["soundsDispelsAllTitle"] = "其他人的增益驅散音效";
L["soundsDispelsAllDesc"] = "其他人增益被驅散時要撥放什麼音效";

L["middleHideBattlegroundsTitle"] = "在戰場時隱藏";
L["middleHideBattlegroundsDesc"] = "在戰場時隱藏螢幕中間的警告訊息。";

L["soundsDisableInBattlegroundsTitle"] = "在戰場時關閉。";
L["soundsDisableInBattlegroundsDesc"] = "在戰場時關閉音效。";

L["autoBuffsHeaderDesc"] = "自動從NPC取得增益";

L["autoDmfBuffTitle"] = "自動取得暗月增益";
L["autoDmfBuffDesc"] = "你想跟賽吉講話時自動對話選擇你要的增益嗎? 確定你選擇你想要哪種增益。";

L["autoDmfBuffTypeTitle"] = "哪個暗月增益";
L["autoDmfBuffTypeDesc"] = "你想要在跟賽吉講話時，這個插件幫你選擇哪個暗月增益?";

L["autoDireMaulBuffTitle"] = "厄運增益";
L["autoDireMaulBuffDesc"] = "你想要這個插件在你對話時，自動幫你取得增益嗎?";

L["autoBwlPortalTitle"] = "自動使用黑翼之巢寶珠";
L["autoBwlPortalDesc"] = "你想要插件幫你在你點擊寶珠時自動進入副本嗎?";

L["showBuffStatsTitle"] = "顯示增益次數";
L["showBuffStatsDesc"] = "在/buff 框架顯示你獲得每個增益的次數?";

L["buffResetButtonTooltip"] = "這將會重置所有增益\n但增益次數資料不會被重置."; --/buff 框架的重置按鈕的提示。
L["time"] = "(%s 次)"; --Singular - This shows how many timers you got a buff. Example: (1 time)
L["times"] = "(%s 次)"; --Plural - This shows how many timers you got a buff. Example: (5 times)
L["flowerWarning"] = "輕歌花的鏡像紀錄已啟動，但是你沒有在到達費伍德時先點擊NPC，所以沒有計時器被記錄。";

L["mmColorTitle"] = "小地圖鏡像顏色";
L["mmColorDesc"] = "小地圖的鏡像要用什麼色? (Layer 1)";

L["layerHasBeenDisabled"] = "關閉鏡像 %s, 直到你再次開啟或是再次偵測之前，鏡像仍會在資料庫中。";
L["layerHasBeenEnabled"] = "啟用鏡像 %s, 現在回到計時與鏡像運算。";
L["layerDoesNotExist"] = "這鏡像編號 %s 不存在於資料庫。";
L["enableLayerButton"] = "啟動鏡像";
L["disableLayerButton"] = "關閉鏡像";
L["enableLayerButtonTooltip"] = "點擊以重新啟動鏡像,\n這將會將鏡像計時及圖層計算放回去。";
L["disableLayerButtonTooltip"] = "在伺服器重開之後，後點擊取消舊的鏡像。\n這將會忽略這個插件移除鏡像。";

L["minimapLayerHoverTitle"] = "滑鼠滑過小地圖顯示";
L["minimapLayerHoverDesc"] = "只有當你滑鼠滑過時顯示小地圖的鏡像框架。";






L["Blackrock Mountain"] = "黑石山";

L["onyxiaNpcKilledHordeWithTimer2"] = "奧妮克西婭增益NPC (倫薩克) 在 %s 前被殺了，在%s 後重生。";
L["nefarianNpcKilledHordeWithTimer2"] = "奈法利安增益NPC (薩魯法爾) 在 %s 前被殺了，在%s 後重生。";
L["onyxiaNpcKilledAllianceWithTimer2"] = "奧妮克西婭增益NPC (瑪丁雷) 在 %s 前被殺了，在%s 後重生。";
L["nefarianNpcKilledAllianceWithTimer2"] = "奈法利安增益NPC (艾法希比) 在 %s 前被殺了，在%s 後重生。";

L["onyxiaNpcRespawnHorde"] = "奧妮克西婭增益NPC (倫薩克) 將會在接下來的2分鐘內隨機重生。";
L["nefarianNpcRespawnHorde"] = "奈法利安增益NPC (薩魯法爾)  將會在接下來的2分鐘內隨機重生。";
L["onyxiaNpcRespawnAlliance"] = "奧妮克西婭增益NPC (瑪丁雷)  將會在接下來的2分鐘內隨機重生。";
L["nefarianNpcRespawnAlliance"] = "奈法利安增益NPC (艾法希比)  將會在接下來的2分鐘內隨機重生。";

L["soundsNpcKilledTitle"] = "NPC被殺";
L["soundsNpcKilledDesc"] = "當NPC被殺重置時間時撥放音效。";

L["autoDmfBuffCharsText"] = "暗月馬戲團特定字符增益設定：";

L["middleNpcKilledTitle"] = "NPC被殺";
L["middleNpcKilledDesc"] = "當黑妹或是奈法NPC被殺重置增益時間時，顯示一個團隊警告式樣的訊息在螢幕中間。";

L["chatNpcKilledTitle"] = "NPC被殺";
L["chatNpcKilledDesc"] = "當黑妹或是奈法NPC被殺重置增益時間時，在聊天顯示訊息。";

L["flashNpcKilledTitle"] = "NPC被殺時閃爍";
L["flashNpcKilledDesc"] = "當NPC被殺時，閃爍魔獸視窗?";

L["trimDataHeaderDesc"] = "清理資料";

L["trimDataBelowLevelTitle"] = "要移除的最高等級";
L["trimDataBelowLevelDesc"] = "選擇要從資料庫中移除的角色最高等級，所有等於或低於這個等級一下的角色都會被刪除。";

L["trimDataBelowLevelButtonTitle"] = "移除角色";
L["trimDataBelowLevelButtonDesc"] = "點一下按鈕來移除等於或低於所選等級的所有角色。注意: 將會永久性的移除增益次數資料。";

L["trimDataTextDesc"] = "從增益資料庫中移除多個角色:";
L["trimDataText2Desc"] = "從增益資料庫中移除一個角色:";

L["trimDataCharInputTitle"] = "輸入要移除的角色";
L["trimDataCharInputDesc"] = "在這裡輸入要移除的角色，格式為: 角色ID-伺服器名稱 (英文大小寫有區別)。注意: 將會永久性的移除增益次數資料。";

L["trimDataBelowLevelButtonConfirm"] = "是否確定要從資料庫中移除等級低於 %s 的所有角色?";
L["trimDataCharInputConfirm"] = "是否確定要從資料庫中移除這個角色: %s?";

L["trimDataMsg1"] = "增益記錄已經重置。"
L["trimDataMsg2"] = "正在移除等級低於 %s 的所有角色。";
L["trimDataMsg3"] = "已移除: %s。";
L["trimDataMsg4"] = "完成，沒有找到任何角色。";
L["trimDataMsg5"] = "完成，已移除 %s 個角色。";
L["trimDataMsg6"] = "請輸入要從資料庫中移除的正確 角色ID-伺服器名稱。";
L["trimDataMsg7"] = "此角色ID %s 沒有包含伺服器名稱，請輸入 角色ID-伺服器名稱。";
L["trimDataMsg8"] = "從資料庫中移除 %s 發生錯誤，無法找到該角色 (英文大小寫有區別)。";
L["trimDataMsg9"] = "已從資料庫中移除 %s 。";

L["serverTime"] = "伺服器時間";
L["serverTimeShort"] = "st";

L["showUnbuffedAltsTitle"] = "顯示沒有增益的分身";
L["showUnbuffedAltsDesc"] = "是否要在增益視窗中顯示沒有任何增益效果的分身? 這樣一來便能知道哪些分身還沒增益。";
L["timerWindowWidthTitle"] = "計時器視窗寬度";
L["timerWindowWidthDesc"] = "計時器的視窗寬度。";

L["timerWindowHeightTitle"] = "計時器視窗高度";
L["timerWindowHeightDesc"] = "計時器的視窗高度。";

L["buffWindowWidthTitle"] = "增益視窗寬度";
L["buffWindowWidthDesc"] = "增益視窗的寬度。";

L["buffWindowHeightTitle"] = "增益視窗高度";
L["buffWindowHeightDesc"] = "增益視窗的高度。";

L["dmfSettingsListTitle"] = "按月馬增益清單";
L["dmfSettingsListDesc"] = "點擊這個顯示你的暗月增益設定哪個種類。";

L["ignoreKillDataTitle"] = "忽略殺死NPC的訊息";
L["ignoreKillDataDesc"] = "忽略任何NPC被殺死的資料。";
L["noOverwriteTitle"] = "不要覆蓋計時器";
L["noOverwriteDesc"] = "你可以開啟此選項，所以當你已經有一個計時器時，將不會再覆蓋新的計時，直到你的計時器結束。";

L["layerMsg1"] = "你在一個有鏡像的區域。";
L["layerMsg2"] = "點一下這裡來檢視目前已有的世界增益。";
L["layerMsg3"] = "點選任何 NPC 得知目前所在的鏡像。";
L["layerMsg4"] = "點選%s的任何 NPC 得知目前所在的鏡像。"; --Target any NPC in Orgrimmar to see your current layer.
--NOTE: Darkmoon Faire buff type is now a character specific setting, changing buff type will only change it for this character.
L["note"] = "註記:";
L["dmfConfigWarning"] = "暗月馬戲團的增益種類特定設定，更改增益類型只會對此腳色進行修改。";
---New---
								  
										 
L["onyNpcMoving"] = "奧尼克西亞NPC開始移動了！";
L["nefNpcMoving"] = "奈法利安NPC開始移動了！";

L["buffHelpersHeaderDesc"] = "PVP伺服器增益助手";

L["buffHelpersTextDesc"] = "PVP伺服器增益助手 (如果你在取得增益的設定秒數內執行其中一項操作，即觸發以下操作，你可以調整以下秒數).";
L["buffHelpersTextDesc2"] = "\n贊達拉增益";
L["buffHelpersTextDesc3"] = "暗月馬戲團增益";
--L["buffHelpersTextDesc4"] = "Enter Battleground Macro (這只是阻擋他，你需要按兩下才能運作，如果你還沒有跳出，請小心不要提前按下。).\n|cFF9CD6DE/click DropDownList1Button2\n/click MiniMapBatlefieldFrame RightButton";

L["takeTaxiZGTitle"] = "自動點選飛行路線";
L["takeTaxiZGDesc"] = "從藏寶海灣一施放增益後， 與飛行管理員交談，或是曾是施放時以打開飛行管理員視窗都可以使用。|cFF00C800(你可以用鬼魂取得增益，所以我建議用鬼魂等待增益施放後復活點選飛行管理員自動飛走)";

L["takeTaxiNodeTitle"] = "飛行路線";
L["takeTaxiNodeDesc"] = "如果你有設定自動飛行路線，將自動選擇飛行";
			
L["dmfVanishSummonTitle"] = "消失招喚";
L["dmfVanishSummonDesc"] = "盜賊: 在取得暗月增益後，使用消失即自動接受招喚？";

L["dmfFeignSummonTitle"] = "假死招喚";
L["dmfFeignSummonDesc"] = "獵人: 在取得暗月增益後，使用假死即自動接受招喚？";
			
L["dmfCombatSummonTitle"] = "戰鬥結束時招喚";
L["dmfCombatSummonDesc"] = "在取得暗月增益後，離開戰鬥即自動接受招喚？";
			
L["dmfLeaveBGTitle"] = "自動離開戰場";
L["dmfLeaveBGDesc"] = "取得暗月增益後自動離開你的戰場群組？";

L["dmfGotBuffSummonTitle"] = "暗月增益招喚";
L["dmfGotBuffSummonDesc"] = "在取得暗月馬戲團增益後，自動接受招喚。";

L["zgGotBuffSummonTitle"] = "贊達拉增益招喚";
L["zgGotBuffSummonDesc"] = "在取得贊達拉增益後，自動接受招喚。";

L["buffHelperDelayTitle"] = "設定增益助手運作秒數";
L["buffHelperDelayDesc"] = "你取得增益後增益助手運作多少秒? 你可以設定這個選項，他只會在你取得增益後運作多少秒。";

L["showNaxxWorldmapMarkersTitle"] = "世界地圖NAXX";
L["showNaxxWorldmapMarkersDesc"] = "在世界地圖上顯示納克薩馬斯記號？";

L["showNaxxMinimapMarkersTitle"] = "小地圖顯示NAXX";
L["showNaxxMinimapMarkersDesc"] = "在小地圖顯示納克薩瑪斯記號？這在你出團死在副本裡的時候，將顯示返回naxx的方向。";

L["bigWigsSupportTitle"] = "BigWigs 支援";
L["bigWigsSupportDesc"] = "在你有安裝BigWigs時，在增益施放時啟用一個時間條，像DBM的樣式。";

L["soundsNpcWalkingTitle"] = "NPC開始移動";
L["soundsNpcWalkingDesc"] = "當奧格瑪的增益NPC開始移動時撥放音效?";

L["buffHelpersTextDesc4"] = "輕歌花增益";
L["songflowerGotBuffSummonTitle"] = "輕歌花招換";
L["songflowerGotBuffSummonDesc"] = "當你取得輕歌花增益後，自動接受招喚。";

L["buffHelpersTextDesc5"] = "龍頭/雷德 增益";
L["cityGotBuffSummonTitle"] = "龍頭/雷德 招喚";
L["cityGotBuffSummonDesc"] = "取得黑妹/奈法/雷德增益後，自動接受招喚";

L["heraldFoundCrossroads"] = "前鋒發現! 十字路口雷德增益將在20秒施放。";
L["heraldFoundTimerMsg"] = "十字路口-雷德"; --DBM/Bigwigs timer bar text.

L["guildNpcWalkingTitle"] = "NPC移動";
L["guildNpcWalkingDesc"] = "當你啟動NPC移動警報時，傳送公會訊息及播放音效? (打開聊天室窗當奧格黑妹/奈法NPC開始移動時，等待大家一起觸發這個早期通報。).";

L["buffHelpersTextDesc6"] = "暗月馬戲團幫助視窗";
L["dmfFrameTitle"] = "DMF幫助視窗";
L["dmfFrameDesc"] = "當你以鬼魂姿態接近賽格時彈出視窗，解決暴雪卡住的問題。";

L["Sheen of Zanza"] = "贊札之光";
L["Spirit of Zanza"] = "贊札之魂";
L["Swiftness of Zanza"] = "贊札之速";

L["Mind Control"] = "心靈控制";
L["Gnomish Mind Control Cap"] = "地精洗腦帽";


L["tbcHeaderText"] = "燃燒的遠征選項";
L["tbcNoteText"] = "注意: 所有公會提醒在TBC的鏡像下關閉。.";

L["disableSoundsAboveMaxBuffLevelTitle"] = "在64級以上關閉音效";
L["disableSoundsAboveMaxBuffLevelDesc"] = "在於TCB領域時為63級以上角色，關閉世界增益音效?";

L["disableSoundsAllLevelsTitle"] = "所有級別角色關閉音效";
L["disableSoundsAllLevelsDesc"] = "為 TBC 領域的所有級別的角色，關閉世界增益音效。";

L["disableMiddleAboveMaxBuffLevelTitle"] = "在64級以上關閉螢幕提示";
L["disableMiddleAboveMaxBuffLevelDesc"] = "在於TCB領域時為63級以上角色，關閉世界增益螢幕提示。";

L["disableMiddleAllLevelsTitle"] = "所有級別角色關閉螢幕提示";
L["disableMiddleAllLevelsDesc"] = "為 TBC 領域的所有級別的角色，關閉世界增益螢幕提示。";

L["disableChatAboveMaxBuffLevelTitle"] = "在64級以上關閉聊天提示";
L["disableChatAboveMaxBuffLevelDesc"] = "在於TCB領域時為63級以上角色，關閉世界增益聊天提示。";

L["disableChatAllLevelsTitle"] = "所有級別角色關閉聊天提示";
L["disableChatAllLevelsDesc"] = "為 TBC 領域的所有級別的角色，關閉世界增益聊天提醒示窗。";

L["disableFlashAboveMaxBuffLevelTitle"] = "在64級以上關閉螢幕閃爍";
L["disableFlashAboveMaxBuffLevelDesc"] = "在於TCB領域時為63級以上角色關閉螢幕閃爍。";

L["disableFlashAllLevelsTitle"] = "所有級別角色關閉螢幕閃爍";
L["disableFlashAllLevelsDesc"] = "為 TBC 領域的所有級別的角色，關閉螢幕閃爍。";

L["disableLogonAboveMaxBuffLevelTitle"] = "在64級以上關閉登錄計時器 ";
L["disableLogonAboveMaxBuffLevelDesc"] = "當您在 TBC 領域登錄 63 級以上的角色時，在聊天中關閉計時器？";

L["disableLogonAllLevelsTitle"] = "所有級別角色關閉登入計時器";
L["disableLogonAllLevelsDesc"] = "為 TBC 領域的所有級別的角色，關閉登入計時器。";

L["Flask of Fortification"] = "防禦精煉藥劑";
L["Flask of Pure Death"] = "純淨死亡精煉藥劑";
L["Flask of Relentless Assault"] = "強襲精煉藥劑";
L["Flask of Blinding Light"] = "盲目之光精煉藥劑";
L["Flask of Mighty Restoration"] = "法力恢復精煉藥劑";
L["Flask of Chromatic Wonder"] = "炫彩驚奇精煉藥劑";
L["Fortification of Shattrath"] = "撒塔斯防禦精煉藥劑";
L["Pure Death of Shattrath"] = "撒塔斯純淨死亡精煉藥劑";
L["Relentless Assault of Shattrath"] = "撒塔斯強襲精煉藥劑";
L["Blinding Light of Shattrath"] = "撒塔斯盲目之光精煉藥劑";
L["Mighty Restoration of Shattrath"] = "撒塔斯法力恢復精煉藥劑";
L["Supreme Power of Shattrath"] = "撒塔斯炫彩驚奇精煉藥劑";
L["Unstable Flask of the Beast"] = "野獸的不穩定精煉藥劑";
L["Unstable Flask of the Sorcerer"] = "巫師的不穩定精煉藥劑";
L["Unstable Flask of the Bandit"] = "強盜的不穩定精煉藥劑";
L["Unstable Flask of the Elder"] = "長者的不穩定精煉藥劑";
L["Unstable Flask of the Physician"] = "醫師的不穩定精煉藥劑";
L["Unstable Flask of the Soldier"] = "士兵的不穩定精煉藥劑";

L["Chronoboon Displacer"] = "時光祝福置換器";

L["Silithyst"] = "水晶塵";

L["Gold"] = "金錢";
L["level"] = "等級";
L["realmGold"] = "伺服器金錢 - ";
L["total"] = "總計";
L["guild"] = "公會";
L["bagSlots"] = "背包欄位";
L["durability"] = "耐久度";
L["items"] = "物品";
L["ammunition"] = "彈藥";
L["attunements"] = "Attunements";
L["currentRaidLockouts"] = "當前副本進度";
L["none"] = "無";



L["dmfDamagePercent"] = "這個新的暗夜增益是 %s%% 傷害。";
L["dmfDamagePercentTooltip"] = "NWB檢測到這個 %s 傷害。";
L["guildLTitle"] = "分享公會鏡像"
L["guildLDesc"] = "跟你的公會分享你在哪個鏡像? 輸入 /wb guild 指令，你可以看到妳的公會鏡像列表。";		
L["terokkarTimer"] = "泰洛卡";
L["terokkarWarning"] = "泰洛卡森林靈魂尖塔重置再 %s";

L["Nazgrel"] = "納茲格雷爾";
L["Hellfire Citadel is ours"] = "地獄火堡壘是我們的";
L["The time for us to rise"] = "我們崛起的時刻到了";
L["Force Commander Danath Trollbane"] = "Force Commander Danath Trollbane";
L["The feast of corruption is no more"] = "The feast of corruption is no more";
L["Hear me brothers"] = "Hear me brothers";

L["terokkarChat10Title"] = "泰洛卡10分鐘";
L["terokkarChat10Desc"] = "在泰洛卡靈魂尖塔還剩 10 分鐘時，在聊天視窗顯示訊息。";

L["terokkarMiddle10Title"] = "泰洛卡10分鐘";
L["terokkarMiddle10Desc"] = "在泰洛卡靈魂尖塔還剩 10 分鐘時，顯示一個團隊警告式樣的訊息在螢幕中間。";

L["showShatWorldmapMarkersTitle"] = "顯示每日副本";
L["showShatWorldmapMarkersDesc"] = "在世界地圖上顯示每日副本?"; 
L["disableBuffTimersMaxBuffLevelTitle"] = "64級以上關閉小地圖增益計時器";
L["disableBuffTimersMaxBuffLevelDesc"] = "是否在64級以上角色的小地圖圖標上時隱藏世界增益計時器？你只會看到泰羅卡塔的計時器和每日任務等。";

L["hideMinimapBuffTimersTitle"] = "關閉所有等級的小地圖增益計時器";
L["hideMinimapBuffTimersDesc"] = "是否在所有角色的小地圖圖標上時隱藏世界增益計時器？你只會看到泰羅卡塔的計時器和每日任務等。";

L["guildTerok10Title"] = "公會計時器訊息"; 
L["guildTerok10Desc"] = "當世界事件即將出現時，例如 TBC 的泰羅卡森林塔樓、巫妖王之怒的冬泉谷、大災變的托爾巴拉德等，向公會聊天發送一條訊息。";

L["showShatWorldmapMarkersTerokTitle"] = "在薩塔斯世界地圖顯示泰洛卡計時器";
L["showShatWorldmapMarkersTerokDesc"] = "是否在在薩塔斯世界地圖上顯示泰洛卡計時器圖標?";



L["sodHeaderText"] = "探索賽季服選項";

L["disableOnlyNefRendBelowMaxLevelTitle"] = "關閉 Ony/Nef/Rend 顯示";
L["disableOnlyNefRendBelowMaxLevelDesc"] = "是否在特定等級以下時關閉 Ony/Nef/Rend 顯示?";

L["disableOnlyNefRendBelowMaxLevelNumTitle"] = "Ony/Nef/Rend 最低等級";
L["disableOnlyNefRendBelowMaxLevelNumDesc"] = "我們應該在哪個等級以下隱藏 Ony/Nef/Rend 圖示，不讓它們顯示在地圖和小地圖按鈕提示?";

L["soundsBlackfathomBoonTitle"] = "黑澗深淵的恩賜音效";
L["soundsBlackfathomBoonDesc"] = "在獲得黑澗深淵的恩賜增益效果時播放音效嗎?";

L["soundsAshenvaleStartsSoonTitle"] = "梣谷即將開始音效";
L["soundsAshenvaleStartsSoonDesc"] = "在梣谷即將開始時播放音效嗎?";

L["blackfathomBoomBuffDropped"] = "黑澗深淵的恩賜增益效果已消失。";

L["showAshenvaleOverlayTitle"] = "梣谷浮動提示";
L["showAshenvaleOverlayDesc"] = "是否在你的介面上永久顯示可移動的梣谷資源提示?";

L["lockAshenvaleOverlayTitle"] = "鎖定浮動提示";
L["lockAshenvaleOverlayDesc"] = "鎖定梣谷提示，使其忽略你的滑鼠懸停。";

L["ashenvaleOverlayScaleTitle"] = "梣谷提示縮放";
L["ashenvaleOverlayScaleDesc"] = "設定梣谷提示的大小。";

L["ashenvaleOverlayText"] = "|cFFFFFF00-在你的介面上永遠顯示梣谷資源提示-";
L["layersNoteText"] = "|cFFFF6900關於 SoD 中的鏡像說明:|r |cFF9CD6DENWB 最多只能追蹤 10 個鏡像，這是為了讓資料大小不會太大，而能很容易地在玩家之間分享。在目前人口眾多的 SoD 伺服器上，鏡像超過了 10 個，因此如果它沒有顯示你所在的鏡像，那是因為你不是在 10 個已記錄的鏡像之一。一旦推出時的高峰期過去，數量可能會減少至低於 10 個，但在那之前它可能不可靠，對此我們感到抱歉。|r";

L["Temple of Atal'Hakkar"] = "阿塔哈卡神廟";
--wolk
L["showShatWorldmapMarkersTerokTitle"] = "佔塔/冬握湖顯示";
L["showShatWorldmapMarkersTerokDesc"] = "在主城中顯示泰洛卡/冬握湖時間?";
																				  

													  
																									  

L["Completed PvP dailies:"] = "已完成 PvP 每日任務";
L["Hellfire Towers"] = "地獄火佔塔";
L["Terokkar Towers"] = "泰洛卡佔塔";
L["Nagrand Halaa"] = "納格蘭哈剌";

L["wintergraspTimer"] = "冬握湖";
L["wintergraspWarning"] = "冬握湖重置於 %s";

 --		 
L["|cFF9CD6DETarget any NPC to see your current layer.|r"] = "|cFF9CD6DE點擊任何NPC以取得鏡像資料。|r"
L["Nova World Buffs"] = "Nova 世界增益監控"
L["NovaWorldBuffs"] = "增益效果-世界"
L["|HNWBCustomLink:timers|hYou are on a layered realm.|h"] = "|HNWBCustomLink:timers|h你在一個有鏡像功能的伺服器。|h";
L["|HNWBCustomLink:timers|hClick here to view current timers.|h"] = "|HNWBCustomLink:timers|h請點一下這裡來檢視目前的世界增益計時。|h";
L["Hold to drag"] = "點這裡可拖曳移動";
L["Timers"] = " 計時";
L["|cffffff00No characters with buffs found."] = "|cffffff00沒有角色有增益。";
L["|cFFFF5100NovaWorldBuffs v"] = "|cFFFF5100Nova 世界增益監控 v";
L["|cFF9CD6DETarget any NPC to see your current layer.|r"] = "|cFF9CD6DE請點選任何 NPC 以得知目前所在的鏡像。|r";
L["|cFFDEDE42Layers may be inaccurate for a few hours after server restarts.\n"] = "|cFFDEDE42伺服器重啟後的幾小時內鏡像可能會不準確。\n";
L["Layers will disappear from here 6 hours after having no timers."] = "沒有計時後的 6 小時，此處記錄的鏡像會消失。";
L["Buffs"] = " 增益";
L["\n|cff00ff00[Layer "] = "\n|cff00ff00[鏡像 ";
L["|cff00ff00[Layer "] = "|cff00ff00[鏡像";
L["\nNo current timers found."] = "\n沒有目前的時間。";
L["Out of date version "] = "插件已過期，目前版本是 ";
L[" (New version: "] = " (新版本: ";
L[")\nPlease update so your timers are accurate."] = ")\n請更新插件以取得準確的計時。";
L["|cFF9CD6DETarget any NPC in Orgrimmar to see your current layer.|r"] = "|cFF9CD6DE點選奧格瑪的任何 NPC \n得知目前所在鏡像|r";
L["|cFF9CD6DETarget any NPC in Stormwind to see your current layer.|r"] = "|cFF9CD6DE點選暴風城的任何 NPC \n得知目前所在鏡像|r";
L["|cFF9CD6DEYou are currently on |cff00ff00[Layer "] = "|cFF9CD6DE你目前在 |cff00ff00[鏡像 ";
L["]|cFF9CD6DE.|r"] = "]|cFF9CD6DE。|r";
L["|cFF9CD6DECan't find current layer or no timers active for this layer.|r"] = "|cFF9CD6DE無法得知目前的鏡像，或此鏡像沒啟動中的計時。|r";
L["|cFFFFFF00Guild versions seen since logon|r"] = "|cFFFFFF00自登入以來看過的公會版本|r";
L["Buff records have been reset."] = "增益資料已經重置。";
L["Layer Map"] = "鏡像地圖"
L["Guild Layers"] = "公會鏡像"
L["Rend Log"] = "雷德紀錄"
L["Refresh"] = "重新整理"
L["|cFFFFFF00NovaWorldBuffs Rend Log|r"] = "|cFFFFFF00Nova世界增益 雷德紀錄|r"
L["Target a NPC to\nupdate your layer"] = "SHIFT+滑鼠拖曳\n可移動鏡像框 \n 點選 NPC 更新鏡像"
L["Layer Map"] = "鏡像對應"
L["|cFFFFFF00Layer Mapping for "] = "|cFFFFFF00鏡像對應 - "
L["  -|cffFFFF00No zones mapped for this layer yet.\n"] = "  -|cffFFFF00此鏡像尚未有對應的區域。\n"
L["|cffFFFF00No zones have been mapped yet since server restart.\n"] = "|cffFFFF00伺服器重啟後尚未有對應的區域。\n"
L[" zones mapped)|r\n"] = " 個區域已對應)|r\n"
L["|cFF9CD6DELeft-Click|r Timers"] = "|cFF9CD6DE左鍵|r 計時器"
L["|cFF9CD6DERight-Click|r Buffs"] = "|cFF9CD6DE右鍵|r 增益"
L["|cFF9CD6DEShift Left-Click|r Felwood Map"] = "|cFF9CD6DEShift+左鍵|r 費伍德森林地圖"
L["|cFF9CD6DEShift Right-Click|r Config"] = "|cFF9CD6DEShift+右鍵|r 設定選項"
L["NovaWorldBuffs Copy Frame|r"] = "Nova 世界增益複製視窗|r"
L["Copy/Paste"] = "複製/貼上"
L["Format the text to paste in discord? (Adds colors etc)"] = "是否要格式化文字以方便貼到 Discord? (加入顏色...等)"
L["Show Stats"] = "顯示統計"
L["Show how many times you got each buff."] = "顯示每種增益拿過幾次。"
L["All"] = "全部"
L["|cFFA0A0A0All"] = "|cFFA0A0A0全部"
L["Show all alts that have buff stats? (stats must be enabled)."] = "顯示所有分身的增益統計 (需要先啟用顯示統計)。"
L["Orgrimmar"] = "奧格瑪"
L["Stormwind"] = "暴風城"
L["Delete buff data?"] = "是否要刪除增益資料?"
L["|cffffff00Mouseover char names for extra info"] = "|cffffff00滑鼠指向角色名字會顯示更多資訊"
L["Chronoboon CD:|r "] = "Chronoboon CD:|r "
L["Ready.|r"] = "完成|r"
L[".|r"] = "|r"
L["|cFFFFFF00Guild Layers|r"] = "|cFFFFFF00公會鏡像|r"
L["|cffFFFF00No guild members online sharing layer data found."] = "|cffFFFF00沒有找到分享鏡像資料的公會成員在線"
L["|cffFFFF00You have no guild, this command shows guild members only.\n"] = "|cffFFFF00你沒有公會，此命令只顯示公會成員。\n"
L["Merge Layers"] = "合併鏡像"
L["Today"] = "今天"
L["Yesterday"] = "昨天"
L["If multiple layers have the same timer this will merge them into [All Layers] instead of showing them separately."] = "如果多個鏡像有同樣的時間，將合併到 [所有鏡像]中，而不是分別顯示。"
L["|cff00ff00[All Layers]|r "] = "|cff00ff00[所有鏡像]|r"
L["|cff00ff00[Layer "] = "|cff00ff00[鏡像 "
L[" |cff9CD6DE(Dropped "] =" |cff9CD6DE(在 "
L[" ago)|r"] = "之前施放)|r"
--
L["Unknown."] = "未知。"
L["|cffFFFF00Rend handed in by "] = "|cffFFFF00掛頭玩家為 "						
L["|cFFFF6900Daily|r |cFF9CD6DE(|r|cff00ff00N|r|cFF9CD6DE)|r "] = "|cFFFF6900每日|r |cFF9CD6DE(|r|cff00ff00普通|r|cFF9CD6DE)|r "
L["|cFFFF6900Daily|r |cFF9CD6DE(|r|cff00ff00N|r|cFF9CD6DE)|r Unknown."] = "|cFFFF6900每日|r |cFF9CD6DE(|r|cff00ff00普通|r|cFF9CD6DE)|r 未知。"
L["|cFFFF6900Daily|r |cFF9CD6DE(|r|cFFFF2222H|r|cFF9CD6DE)|r "] = "|cFFFF6900每日|r |cFF9CD6DE(|r|cFFFF2222英雄|r|cFF9CD6DE)|r "
L["|cFFFF6900Daily|r |cFF9CD6DE(|r|cFFFF2222H|r|cFF9CD6DE)|r Unknown."] = "|cFFFF6900每日|r |cFF9CD6DE(|r|cFFFF2222英雄|r|cFF9CD6DE)|r 未知。"
L["|cFFFF6900Dungeon Daily|r |cFF9CD6DE(|r|cff00ff00N|r|cFF9CD6DE)|r "] = "|cFFFF6900每日地下城|r |cFF9CD6DE(|r|cff00ff00普通|r|cFF9CD6DE)|r "
L["|cFFFF6900Dungeon Daily|r |cFF9CD6DE(|r|cff00ff00N|r|cFF9CD6DE)|r  Unknown."] = "|cFFFF6900每日地下城|r |cFF9CD6DE(|r|cff00ff00普通|r|cFF9CD6DE)|r  未知。"
L["|cFFFF6900Dungeon Daily|r |cFF9CD6DE(|r|cFFFF2222H|r|cFF9CD6DE)|r "] = "|cFFFF6900每日地下城|r |cFF9CD6DE(|r|cFFFF2222英雄|r|cFF9CD6DE)|r "
L["|cFFFF6900Dungeon Daily|r |cFF9CD6DE(|r|cFFFF2222H|r|cFF9CD6DE)|r Unknown."] = "|cFFFF6900每日地下城|r |cFF9CD6DE(|r|cFFFF2222英雄|r|cFF9CD6DE)|r 未知。"
L["|cFFFF6900Daily|r |cFF9CD6DE(|r"] = "|cFFFF6900每日|r |cFF9CD6DE(|r"
L["|cFF9CD6DE)|r Unknown."] = "|cFF9CD6DE)|r 未知。"
L["|cFF9CD6DEControl Left-Click|r Guild Layers"] = "|cFF9CD6DEctrl+左鍵|r 公會鏡像"										
L["10 minutes"] = "10分鐘"
L["|CffDEDE42Shift Left-Click to send timers to guild chat.\nShift Right-Click to send timers to say."] = "|CffDEDE42Shift+左鍵點擊傳送計時到公會聊天。\nShift+右鍵點擊傳送到一般聊天。"
L["Terokkar Towers\n|CffDEDE42Shift Left-Click to send timers to guild chat.\nShift Right-Click to send timers to say."] = "泰洛卡計時器|CffDEDE42Shift+左鍵點擊傳送計時到公會聊天。\nShift+右鍵點擊傳送到一般聊天。"
L["[NWB] Terokkar Towers reset in "] = "[NWB]泰洛卡占塔重置於"

L["minimapLayerFontTitle"] = "小地圖鏡像字體";
L["minimapLayerFontDesc"] = "小地圖鏡像文字使用哪種字體。";

L["minimapLayerFontSizeTitle"] = "小地圖鏡像文字大小";
L["minimapLayerFontSizeDesc"] = "小地圖鏡像文字的大小。";

L["wintergraspChat10Title"] = "冬握湖 10 分鐘";
L["wintergraspChat10Desc"] = "當冬握湖靈魂塔剩下 10 分鐘時，顯示聊天訊息。";

L["wintergraspMiddle10Title"] = "冬握湖 10 分鐘";
L["wintergraspMiddle10Desc"] = "當冬握湖靈魂塔剩下 10 分鐘時，在畫面中間顯示一個團隊警告訊息。";

L["Left-Click"] = "左鍵"
L["Right-Click"] = "右鍵"
L["Shift Left-Click"] = "Shift+左鍵"
L["Shift Right-Click"] = "Shift+右鍵"
L["Felwood Map"] = "費伍德地圖"
L["Config"] = "設定選項"

L["Yes"] = "是"
L["No"] = "否"
--5/20					  

L["Mouseover char names for extra info"] = "滑鼠懸停在角色名稱上以獲取更多資訊";
L["Show Stats"] = "顯示統計"; 
L["Event Running"] = "活動進行中";

L["Left-Click"] = "左鍵點擊";
L["Right-Click"] = "右鍵點擊";
L["Shift Left-Click"] = "Shift + 左鍵點擊";
L["Shift Right-Click"] = "Shift + 右鍵點擊";
L["Control Left-Click"] = "Ctrl + 左鍵點擊";

--Try keep these roughly the same length or shorter.
L["Guild Layers"] = "公會層級";
L["Timers"] = "計時器";
L["Buffs"] = "增益效果";
L["Felwood Map"] = "費伍德地圖";
L["Config"] = "設定";
L["Resources"] = "資源"; 
L["Layer"] = "層級";
L["Layer Map"] = "層級地圖";
L["Rend Log"] = "撕裂記錄";
L["Timer Log"] = "計時器記錄";
L["Copy/Paste"] = "複製/貼上";
L["Ashenvale PvP Event Resources"] = "梣谷 PvP 活動資源";
L["All other alts using default"] = "所有其他分身角色使用預設設定";
L["Chronoboon CD"] = "時空寶珠冷卻時間"; 
L["All"] = "全部"; 
L["Old Data"] = "舊資料";
L["Ashenvale data is old"] = "梣谷資料過舊";
L["Ashenvale"] = "梣谷";
L["Ashenvale Towers"] = "梣谷占塔";
L["Warning"] = "警告";
L["Refresh"] = "刷新";
L["PvP enabled"] = "已啟用 PvP";
L["Hold Shift to drag"] = "按住 Shift 鍵拖曳";
L["Hold to drag"] = "按住拖曳";

L["Can't find current layer or no timers active for this layer."] = "找不到當前鏡像或此鏡像沒有啟用的計時器。";
L["No guild members online sharing layer data found."] = "找不到線上分享鏡像資料的公會成員。";

L["ashenvaleOverlayFontTitle"] = "覆蓋文字字體";
L["ashenvaleOverlayFontDesc"] = "覆蓋顯示要使用的字體。";

L["minimapLayerFontTitle"] = "小地圖鏡像文字字體";
L["minimapLayerFontDesc"] = "小地圖鏡像文字要使用的字體。";

L["minimapLayerFontSizeTitle"] = "小地圖鏡像文字字體大小";
L["minimapLayerFontSizeDesc"] = "小地圖鏡像文字要使用的字體大小。";

L["zone"] = "區域";
L["zones mapped"] = "已映射的區域";
L["Layer Mapping for"] = "鏡像映射用於";
L["formatForDiscord"] = "將文字格式化以貼到 Discord 中？(添加顏色等)";
L["Copy Frame"] = "複製框架";
L["Show how many times you got each buff."] = "顯示您獲得每個增益效果的次數。";
L["Show all alts that have buff stats? (stats must be enabled)."] = "顯示所有具有增益效果統計數據的分身角色？(必須啟用統計數據)。";
L["No timer logs found."] = "沒有找到計時器記錄。";
L["Merge Layers"] = "合併鏡像";
L["mergeLayersTooltip"] = "如果多個鏡像具有相同的計時器，這將將它們合併到 [所有鏡像] 中，而不是單獨顯示。";
L["Ready"] = "準備就緒";
L["Chronoboon"] = "時空寶珠";
L["Local Time"] = "當地時間";
L["Server Time"] = "伺服器時間";
L["12 hour"] = "12 小時";
L["24 hour"] = "24 小時";
L["Alliance"] = "聯盟";
L["Horde"] = "部落";
L["No Layer"] = "無鏡像";
L["No data yet."] = "尚未有資料。";
L["Ashenvale Resources"] = "[梣谷資源";
L["No character specific buffs set yet."] = "尚未設定角色特定增益效果。";
L["All characters are using default"] = "所有角色都使用預設設定";
L["Orgrimmar"] = "奧格瑪";
L["Stormwind"] = "暴風城";
L["Dalaran"] = "達拉然";
L["left"] = "剩餘";  --Same as remaining basically.
L["remaining"] = "剩餘";

L["Online"] = "線上";
L["Offline"] = "離線";
L["Rested"] = "已休息";
L["Not Rested"] = "未休息";
L["No zones mapped for this layer yet."] = "此鏡像沒有對應的區域。";
L["Cooldown"] = "冷卻時間";
L["dmfLogonBuffResetMsg"] = "這些角色在已休息區域離線 8 小時以上，而黑暗之門的增益效果冷卻時間已重置";
L["dmfOfflineStatusTooltip"] = "暗月馬戲團增益冷卻時間 8 小時以上離線狀態（已休息區域）";
L["chronoboonReleased"] = "您已使用時空寶珠釋放了一個黑暗之門的增益效果，新的 4 小時冷卻時間已開始。";

L["Stranglethorn"] = "荊棘谷大戰"; 
L["ashenvaleEventRunning"] = "梣谷大戰正在進行：%s";
L["ashenvaleEventStartsIn"] = "梣谷大戰將在 %s 開始";
L["ashenvaleStartSoon"] = "梣谷大戰將在 %s 開始"; 
L["stranglethornEventRunning"] = "荊棘谷大戰正在進行：%s";
L["stranglethornEventStartsIn"] = "荊棘谷大戰將在 %s 開始";
L["stranglethornStartSoon"] = "荊棘谷大戰將在 %s 開始"; 
L["Spark of Inspiration"] = "靈感火花"; 
L["specificBuffDropped"] = "%s 增益效果已掉落。";
L["3 day raid reset"] = "3 天團本重置";
L["Darkmoon Faire is up"] = "黑暗之門正在舉行";
L["dmfAbbreviation"] = "暗月馬戲團";
L["Ashenvale PvP Event"] = "梣谷大戰 PvP 活動";
L["Stranglethorn PvP Event"] = "荊棘谷大戰 PvP 活動";

L["overlayShowArtTitle"] = "顯示浮動圖示";
L["overlayShowArtDesc"] = "顯示浮動圖示？";

L["overlayShowAshenvaleTitle"] = "顯示梣谷大戰圖示";
L["overlayShowAshenvaleDesc"] = "顯示艾梣谷大戰計時器？";

L["overlayShowStranglethornTitle"] = "顯示荊棘谷大戰圖示";
L["overlayShowStranglethornDesc"] = "顯示剃刀高地計時器？";

L["overlayShowBlackrockTitle"] = "顯示黑石計時器";
L["overlayShowBlackrockDesc"] = "顯示荊棘谷黑石計時器?";

L["sodMiddleScreenWarningTitle"] = "螢幕警告";
L["sodMiddleScreenWarningDesc"] = "在螢幕中間顯示一個 15/30 分鐘的警告，提醒您關於像 STV 等的 SoD 事件。";

L["stvBossMarkerTooltip"] = "NWB 首領標記（實驗性）";
L["Boss"] = "首領"; 
L["stvBossSpotted"] = "發現了 Loa 首領！請查看地圖以獲取位置。";
L["Total coins this event"] = "此活動的硬幣總數"; 
L["Last seen"] = "上次看見";
L["World Events"] = "世界事件";
L["layersNoGuild"] = "您沒有公會，此命令僅顯示公會成員。";

L["No guild"] = "無公會";

L["Temple of Atal'Hakkar"] = "阿塔哈卡神殿"; 

L["cappingSupportTitle"] = "佔領支持";
L["cappingSupportDesc"] = "如果安裝了佔領功能，是否為梣谷/荊棘谷大戰啟動計時條？";

L["Tol Barad"] = "托爾巴拉德";
L["eventIsRunning"] = "%s 正在進行中";

L["Might of Stormwind"] = "暴風城之力";

L["printStvCoinsTitle"] = "顯示 斯坦索姆聖水";
L["printStvCoinsDesc"] = "在聊天視窗顯示活動期間獲得的斯坦索姆聖水數量。";

L["printBlackrockHonorTitle"] = "顯示 黑石競技場榮譽";
L["printBlackrockHonorDesc"] = "在聊天視窗顯示活動期間獲得的黑石競技場榮譽數量。";

L["chatOnlyInCityTitle"] = "僅限主城";
L["chatOnlyInCityDesc"] = "僅在您位於增益掉落的主要城市（包括贊達拉增益的荊棘谷）時，才列印計時器和增益掉落聊天訊息。";

L["middleOnlyInCityTitle"] = "僅限主城";
L["middleOnlyInCityDesc"] = "僅在您位於增益掉落的主要城市（包括贊達拉增益的荊棘谷）時，才顯示螢幕中間的計時器和增益掉落訊息。";

L["flashOnlyInCityTitle"] = "僅限主城";
L["flashOnlyInCityDesc"] = "僅在您位於增益掉落的主要城市（包括贊達拉增益的荊棘谷）時，最小化時才會閃爍。";

L["blueShamansTitle"] = "藍色薩滿";
L["blueShamansDesc"] = "在經典版中，在此插件中將薩滿顯示為藍色。";

L["Battle Shout"] = "戰鬥怒吼";

L["dmfBuffDroppedNoCooldown"] = "獲得了暗月馬戲團增益效果 %s，在此遊戲版本中沒有冷卻時間。";
L["chronoboonReleasedNoCooldown"] = "你已使用時光之末釋放了一個暗月馬戲團增益效果，在此遊戲版本中沒有冷卻時間。";

L["skipDmfCookieTitle"] = "跳過幸運餅乾";
L["skipDmfCookieDesc"] = "啟用此選項在獲得 DMF 增益後跳過取得幸運餅乾。";

L["No layers found yet."] = "還沒發現鏡像。";
L["Bi-Weekly raid reset"] = "雙週團隊重置";

L["Min Level"] = "最低等級";
L["Rend handed in by"] = "Rend handed in by";
L["ago"] = "前";
L["Dropped"] = "已刪除";
L["Yes"] = "是";
L["No"] = "否";
L["Delete buff data?"] = "是否要刪除增益資料?";
L["No characters with buffs found."] = "沒有找到有增益效果的角色。";
L["Unknown Layer"] = "未知的鏡像";

L["Active"] = "啟用";

L["noZonesMappedYet"] = "自伺服器重啟後，尚未有任何區域被偵測到。";
L["Rend log adjusted"] = "已由雷德記錄調整";

L["flashDisableRendTitle"] = "停用雷德畫面閃爍";
L["flashDisableRendDesc"] = "啟用此選項將覆寫並停用所有與雷德相關的客戶端畫面閃爍事件。";

L["flashDisableOnyTitle"] = "停用奧妮克希亞畫面閃爍";
L["flashDisableOnyDesc"] = "啟用此選項將覆寫並停用所有與奧妮克希亞/奈法利安相關的客戶端畫面閃爍事件。";

L["flashDisableZanTitle"] = "停用贊達拉畫面閃爍";
L["flashDisableZanDesc"] = "啟用此選項將覆寫並停用所有與贊達拉相關的客戶端畫面閃爍事件。";

L["soundsFirstYellTitle"] = "其他增益即將到來";
L["soundsFirstYellDesc"] = "當贊達拉/其他增益上繳，且增益即將套用前的幾秒播放的音效（首次NPC喊話）。";

L["soundsFirstYellRendTitle"] = "雷德增益即將到來";
L["soundsFirstYellRendDesc"] = "當雷德頭顱上繳，且增益即將套用前的幾秒播放的音效（首次NPC喊話）。";

L["soundsFirstYellOnyTitle"] = "奧妮克希亞/奈法利安增益即將到來";
L["soundsFirstYellOnyDesc"] = "當奧妮克希亞/奈法利安頭顱上繳，且增益即將套用前的幾秒播放的音效（首次NPC喊話）。";

L["resetFramesTitle"] = "重設視窗位置";
L["resetFramesDesc"] = "點擊此處將所有視窗位置重設回螢幕中央。";

L["buffHasNoCooldown"] = "此次上繳不會觸發冷卻時間";
L["noCooldown"] = "無冷卻時間";

["showDisableLayerButtonsTitle"] = "顯示停用鏡像按鈕"
L["showDisableLayerButtonsDesc"] = "在時間/鏡像框架顯示停用鏡像按鈕。";

L["Show Quest Handins Only"] = "只顯示已交回的任務";
L["showQuestHandinsTooltip"] = "只顯示已交回的「為部落而戰！」任務日誌項目。"
