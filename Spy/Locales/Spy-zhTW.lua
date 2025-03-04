local L = LibStub("AceLocale-3.0"):NewLocale("Spy", "zhTW") -- Traditional Chinese
if not L then return end
-- TOC Note: "偵測並警告你附近有敵方玩家出沒。"

-- Configuration
L["Spy"] = "PvP 偵測敵方玩家 Spy"
L["Version"] = "版本"
L["Spy Option"] = "PvP 偵測玩家"
L["Profiles"] = "設定檔"

-- About
L["About"] = "關於 Spy"
L["SpyDescription1"] = [[
Spy 是一個可以警告你附近有敵方玩家出沒的插件。這裡列出一些主要功能。

]]
L["SpyDescription2"] = [[
|cffffd000附近清單|cffffffff
附近清單會顯示已經被偵測到在附近的任何敵方玩家。點一下清單中的名字可以將玩家選取為目標，但是只能在非戰鬥中使用。一段時間後沒有偵測到的玩家會從清單中自動移除。

|cffffd000最近清單|cffffffff
顯示在一小時內檢測到的所有敵人。

|cffffd000忽略清單|cffffffff
Spy 不會顯示被加入到忽略清單中的玩家。透過滑鼠右鍵選單，或是按住 CTRL 鍵點擊名字將玩家加入清單和移除。

|cffffd000即殺清單|cffffffff
偵測到在即殺清單清單中的玩家時會發出警告。透過滑鼠右鍵選單，或是按住 SHIFT 鍵點擊名字將玩家加入清單和移除。滑鼠右鍵選單也可以設定將某人加入到即殺清單的原因。如果你想要輸入不在清單中的原因，請在其他清單中使用 "自行輸入原因..."。

]]

L["SpyDescription3"] = [[
|cffffd000統計視窗|cffffffff
統計視窗包含所有遇到過的敵方清單，可以依據名字、等級、公會、勝敗或最後偵測到的時間來排序，也能夠搜尋名字或公會來找出特定的玩家。還可以過濾，只顯示被標記為即殺、有過輸/贏，或是有輸入過原因的敵方玩家。

|cffffd000即殺按鈕|cffffffff
啟用這個功能後，選取目標是敵方玩家時，目標框架上面會顯示即殺按鈕，點一下按鈕會將該玩家加入或移出即殺清單。在按鈕上點右鍵能夠讓你輸入即殺的理由。

|cffffd000作者: Slipjack|cffffffff
]]

-- General Settings
L["GeneralSettings"] = "一般設定"
L["GeneralSettingsDescription"] = [[
啟用或禁用Spy時的選項。
]] 
L["EnableSpy"] = "啟用"
L["EnableSpyDescription"] = "啟用或停用 Spy。"
L["EnabledInBattlegrounds"] = "戰場中啟用"
L["EnabledInBattlegroundsDescription"] = "身處在戰場中時啟用或停用 Spy。"
L["EnabledInArenas"] = "競技場中啟用"
L["EnabledInArenasDescription"] = "身處在競技場中時啟用或停用 Spy。"
L["EnabledInWintergrasp"] = "世界戰鬥區域中啟用"
L["EnabledInWintergraspDescription"] = "身處在世界戰鬥區中時啟用或停用 Spy，例如北裂境的冬握湖。"
L["DisableWhenPVPUnflagged"] = "非 PVP 狀態時停用"
L["DisableWhenPVPUnflaggedDescription"] = "依據自身的 PVP 狀態啟用或停用 Spy。"
L["DisabledInZones"] = "在這些區域時停用 Spy"
L["DisabledInZonesDescription"]	= "選擇要停用 Spy 的區域。"
L["Booty Bay"] = "藏寶海灣"
L["Everlook"] = "永望鎮"						
L["Gadgetzan"] = "加基森"
L["Ratchet"] = "荊棘城"
L["The Salty Sailor Tavern"] = "水手之家旅店"
L["Shattrath City"] = "撒塔斯城"
L["Area 52"] = "52區"
L["Dalaran"] = "達拉然"
L["Dalaran (Northrend)"] = "達拉然(北裂境)"
L["Bogpaddle"] = "沼槳"
L["The Vindicaar"] = "梵迪卡爾"
L["Krasus' Landing"] = "卡薩斯平臺"
L["The Violet Gate"] = "紫羅蘭之門"
L["Magni's Encampment"] = "麥格尼的營地"
L["Silithus"] = "希利蘇斯"
L["Chamber of Heart"] = "心之室"
L["Hall of Ancient Paths"] = "古道大廳"
L["Sanctum of the Sages"] = "賢者聖所"
L["Rustbolt"] = "鏽栓鎮"
L["Oribos"] = "奧睿博司"
L["Valdrakken"] = "沃卓肯"
L["The Roasted Ram"] = "炙烤公羊旅店"

-- Display
L["DisplayOptions"] = "顯示"
L["DisplayOptionsDescription"] = [[
Spy 視窗的選項和浮動提示資訊。
]]
L["ShowOnDetection"] = "偵測到敵方玩家時顯示"
L["ShowOnDetectionDescription"] = "偵測到敵方玩家時會自動將隱藏的 Spy 視窗和附近清單顯示出來。"
L["HideSpy"] = "沒有偵測到敵方玩家時隱藏"
L["HideSpyDescription"] = "附近清單內容是空的時候會自動隱藏。手動清空清單時不會隱藏 Spy。"
L["ShowOnlyPvPFlagged"] = "只顯示狀態為 PvP 的敵方玩家"
L["ShowOnlyPvPFlaggedDescription"] = "在附近清單中只顯示切換為 PvP 狀態的敵方玩家。"
L["ShowKoSButton"] = "在敵方目標框架上顯示即殺按鈕"
L["ShowKoSButtonDescription"] = "在敵方玩家的目標框架上面顯示即殺按鈕。"
L["Alpha"] = "透明度"
L["AlphaDescription"] = "設定 Spy 視窗的透明度。"
L["AlphaBG"] = "戰場透明度"
L["AlphaBGDescription"] = "設定在戰場中 Spy 視窗的透明度。"
L["LockSpy"] = "鎖定視窗"
L["LockSpyDescription"] = "鎖定 Spy 視窗讓它不能被移動。"
L["ClampToScreen"] = "不要超出畫面"
L["ClampToScreenDescription"] = "控制是否可以將 Spy 視窗拖曳出螢幕外面。"
L["InvertSpy"] = "翻轉視窗"
L["InvertSpyDescription"] = "上下翻轉 Spy 視窗。"
L["Reload"] = "重新載入"
L["ReloadDescription"] = "更改 Spy 視窗時需要重新載入介面。"
L["ResizeSpy"] = "自動調整視窗大小"
L["ResizeSpyDescription"] = "新增和移除敵方玩家時自動調整 Spy 視窗的大小。"
L["ResizeSpyLimit"] = "清單長度限制"
L["ResizeSpyLimitDescription"] = "限制 Spy 視窗中顯示的敵方玩家數量。"
L["DisplayTooltipNearSpyWindow"] = "在 Spy 視窗附近顯示浮動提示資訊"
L["DisplayTooltipNearSpyWindowDescription"] = "勾選時，浮動提示資訊會顯示在 Spy 視窗旁。"
L["SelectTooltipAnchor"] = "浮動提示資訊位置"
L["SelectTooltipAnchorDescription"] = "已勾選上面的選項時，可以選擇浮動提示資訊的對齊位置。"
L["ANCHOR_CURSOR"] = "跟隨游標"
L["ANCHOR_TOP"] = "上"
L["ANCHOR_BOTTOM"] = "下"
L["ANCHOR_LEFT"] = "左"			
L["ANCHOR_RIGHT"] = "右"
L["TooltipDisplayWinLoss"] = "浮動提示資訊中顯示勝/敗統計"
L["TooltipDisplayWinLossDescription"] = "在玩家的浮動提示資訊中顯示該玩家的勝/敗統計資訊。"
L["TooltipDisplayKOSReason"] = "浮動提示資訊中顯示即殺原因"
L["TooltipDisplayKOSReasonDescription"] = "在玩家的浮動提示資訊中顯示該玩家被加入到即殺清單中的原因。"
L["TooltipDisplayLastSeen"] = "浮動提示資訊中顯示上次遇到的詳情"
L["TooltipDisplayLastSeenDescription"] = "在玩家的浮動提示資訊中顯示最近一次遇到該玩家的時間和地點。"
L["DisplayListData"] = "選擇要顯示的敵方資料"
L["Name"] = "名字"
L["Class"] = "職業"
L["Rank"] = "等級"
L["SelectFont"] = "選擇字體"
L["SelectFontDescription"] = "選擇 Spy 視窗使用的字體。"
L["RowHeight"] = "選擇列高"
L["RowHeightDescription"] = "選擇 Spy 視窗橫列的高度。"
L["Texture"] = "材質"
L["TextureDescription"] = "選擇 Spy 視窗的材質"

-- Alerts
L["AlertOptions"] = "警告"
L["AlertOptionsDescription"] = [[
偵測到敵方玩家時的警報、通報和警告選項。
]]
L["SoundChannel"] = "選擇聲音頻道"
L["Master"] = "主音量"
L["SFX"] = "音效"
L["Music"] = "音樂"
L["Ambience"] = "環境"
L["Announce"] = "通報到:"
L["None"] = "無"
L["NoneDescription"] = "偵測到敵方玩家時不要通報。"
L["Self"] = "自己"
L["SelfDescription"] = "偵測到敵方玩家時通知自己。"
L["Party"] = "隊伍"
L["PartyDescription"] = "偵測到敵方玩家時通報到你的隊伍。"
L["Guild"] = "公會"
L["GuildDescription"] = "偵測到敵方玩家時通報到你的公會。"
L["Raid"] = "團隊"
L["RaidDescription"] = "偵測到敵方玩家時通報到你的團隊。"
L["LocalDefense"] = "本地防務"
L["LocalDefenseDescription"] = "偵測到敵方玩家時通報到本地防務頻道。"
L["OnlyAnnounceKoS"] = "只通報即殺的敵方玩家"
L["OnlyAnnounceKoSDescription"] = "設定為只通報在即殺清單中的敵方玩家。"
L["WarnOnStealth"] = "隱形偵測警告"
L["WarnOnStealthDescription"] = "敵方玩家獲得隱形時顯示警告和音效。"
L["WarnOnKOS"] = "即殺偵測警告"
L["WarnOnKOSDescription"] = "偵測到在即殺清單中的敵方玩家時顯示警告和音效。"
L["WarnOnKOSGuild"] = "公會即殺偵測警告"
L["WarnOnKOSGuildDescription"] = "偵測到和即殺清單中有相同公會的敵方玩家時顯示警告和音效。"
L["WarnOnRace"] = "種族偵測警告"
L["WarnOnRaceDescription"] = "偵測到指定的種族時發出音效警告。"
L["SelectWarnRace"] = "選擇要偵測的種族"
L["SelectWarnRaceDescription"] = "選擇要發出警告音效的種族。"
L["WarnRaceNote"] = "注意: 至少需要將敵人選取為目標一次 (點 Spy 視窗中的玩家名字) 他的種族才會加入到資料庫中，下次偵測到時便可以發出警告音效。和偵測附近敵人一樣，戰鬥中無法點選。"
-- L["DisplayWarningsInErrorsFrame"] = "在錯誤訊息框架顯示警告"
-- L["DisplayWarningsInErrorsFrameDescription"] = "使用錯誤訊息框架來顯示警告，而不是使用圖形介面的彈出視窗。"
L["DisplayWarnings"] = "選擇警告訊息位置"
L["Default"] = "預設"
L["ErrorFrame"] = "錯誤訊息框架"
L["Moveable"] = "可移動"
L["EnableSound"] = "啟用警告音效"
L["EnableSoundDescription"] = "偵測到敵方玩家時啟用警告音效，隱形和即殺清單中的敵方玩家會發出不同的警告音效。"
L["OnlySoundKoS"] = "只有即殺清單使用警告音效"
L["OnlySoundKoSDescription"] = "只有偵測到即殺清單中的敵方玩家時才播放警告音效。"
L["StopAlertsOnTaxi"] = "乘坐鳥點飛行時關閉警報"
L["StopAlertsOnTaxiDescription"] = "在飛行路線上時停止所有新的警報和警告。"

-- Nearby List
L["ListOptions"] = "附近清單"
L["ListOptionsDescription"] = [[
將敵方玩家加入附近清單和移除的選項。
]]
L["RemoveUndetected"] = "多久後從附近清單中移除敵方玩家:"
L["1Min"] = "1 分鐘"
L["1MinDescription"] = "移除超過 1 分鐘未偵測到的敵方玩家。"
L["2Min"] = "2 分鐘"
L["2MinDescription"] = "移除超過 2 分鐘未偵測到的敵方玩家。"
L["5Min"] = "5 分鐘"
L["5MinDescription"] = "移除超過 5 分鐘未偵測到的敵方玩家。"
L["10Min"] = "10 分鐘"
L["10MinDescription"] = "移除超過 10 分鐘未偵測到的敵方玩家。"
L["15Min"] = "15 分鐘"
L["15MinDescription"] = "移除超過 15 分鐘未偵測到的敵方玩家。"
L["Never"] = "永不移除"
L["NeverDescription"] = "永遠不要移除敵方玩家，仍然可以使用手動的方式清除附近清單。"
L["ShowNearbyList"] = "偵測到敵方玩家時自動切換到附近清單"
L["ShowNearbyListDescription"] = "偵測到敵方玩家時顯示附近清單，如果原本沒有顯示的話。"
L["PrioritiseKoS"] = "附近清單中優先排序即殺的敵方玩家"
L["PrioritiseKoSDescription"] = "在附近清單中總是將即殺的敵方玩家顯示在最前面。"

-- Map
L["MapOptions"] = "地圖"
L["MapOptionsDescription"] = [[
世界地圖和小地圖的選項，包括圖示和浮動提示資訊。
]]
L["MinimapDetection"] = "啟用小地圖偵測"
L["MinimapDetectionDescription"] = "將滑鼠游標移動到小地圖上偵測到的敵方玩家上面時，會將他們加入 '附近' 清單。"
L["MinimapNote"] = "          注意：僅適用於可以追踪人形生物的玩家。"
L["MinimapDetails"] = "浮動提示資訊中顯示等級/職業細節"
L["MinimapDetailsDescription"] = "更新小地圖的浮動提示資訊，隨著敵人名字一併顯示等級/職業的詳細資訊。"
L["DisplayOnMap"] = "在地圖上顯示圖示"
L["DisplayOnMapDescription"] = "當你的隊友、團隊或公會成員偵測到敵人時，在地圖上顯示他們的位置。"
L["SwitchToZone"] = "偵測到敵人時切換到目前區域的地圖"
L["SwitchToZoneDescription"] = "打開世界地圖並且偵測到敵人時，會自動切換到玩家目前所在的區域地圖。"
L["MapDisplayLimit"] = "限制顯示的地圖圖示:"
L["LimitNone"] = "任何地方"
L["LimitNoneDescription"] = "無視目前所在的地區，在地圖上顯示所有偵測到的敵人。"
L["LimitSameZone"] = "相同區域"
L["LimitSameZoneDescription"] = "只顯示同一個區域中偵測到的敵人。"
L["LimitSameContinent"] = "相同大陸"
L["LimitSameContinentDescription"] = "只顯示同一塊大陸中偵測到的敵人。"

-- Data Management
L["DataOptions"] = "資料維護"
L["DataOptionsDescription"] = [[
關於 Spy 如何維護和收集數據的選項。
]]
L["PurgeData"] = "清除多久後未偵測到的敵方玩家:"
L["OneDay"] = "1 天"
L["OneDayDescription"] = "清除超過 1 天未偵測到的敵方玩家資料。"
L["FiveDays"] = "5 天"
L["FiveDaysDescription"] = "清除超過 5 天未偵測到的敵方玩家資料。"
L["TenDays"] = "10 天"
L["TenDaysDescription"] = "清除超過 10 天未偵測到的敵方玩家資料。"
L["ThirtyDays"] = "30 天"
L["ThirtyDaysDescription"] = "清除超過 30 天未偵測到的敵方玩家資料。"
L["SixtyDays"] = "60 天"
L["SixtyDaysDescription"] = "清除超過 60 天未偵測到的敵方玩家資料。"
L["NinetyDays"] = "90 天"
L["NinetyDaysDescription"] = "清除超過 90 天未偵測到的敵方玩家資料。"
L["PurgeKoS"] = "也要清除未偵測到的即殺玩家"
L["PurgeKoSDescription"] = "使用相同的時間，清除未偵測到的即殺玩家。"
L["PurgeWinLossData"] = "也要清除勝/敗資料"
L["PurgeWinLossDataDescription"] = "使用相同的時間，清除勝/敗資料。"
L["ShareData"] = "和其他 Spy 使用者分享資料"
L["ShareDataDescription"] = "和隊伍、團隊和公會中也有使用 Spy 插件的玩家分享你遇到敵方玩家的詳情。"
L["UseData"] = "使用來自於其他 Spy 使用者的資料"
L["UseDataDescription"] = "使用從隊伍、團隊和公會中也有使用 Spy 插件的玩家收集到的資料。"
L["ShareKOSBetweenCharacters"] = "不同角色共用即殺玩家資料"
L["ShareKOSBetweenCharactersDescription"] = "分享標記為即殺的玩家給你在同一個伺服器、同陣營的其他角色。"

-- Commands
L["SlashCommand"] = "聊天視窗指令"
L["SpySlashDescription"] = "這些按鈕會執行在聊天視窗輸入 /spy 時相同的指令選項動作。"
L["Enable"] = "啟用"
L["EnableDescription"] = "啟用 Spy 並顯示主視窗。"
L["Show"] = "顯示"
L["ShowDescription"] = "顯示主視窗。"
L["Hide"] = "隱藏"
L["HideDescription"] = "隱藏主視窗。"
L["Reset"] = "重置"
L["ResetDescription"] = "重設主視窗的位置和外觀。"
L["ClearSlash"] = "清空"
L["ClearSlashDescription"] = "清空已偵測到的玩家清單。"
L["Config"] = "設定"
L["ConfigDescription"] = "開啟介面 > 插件中的 Spy 設定選項。"
L["KOS"] = "即殺"
L["KOSDescription"] = "從即殺清單加入/移除玩家。"
L["InvalidInput"] = "無效的輸入"
L["Ignore"] = "忽略"
L["IgnoreDescription"] = "從忽略清單加入/移除玩家。"
L["Test"] = "測試"
L["TestDescription"] = "顯示警告，供調整位置使用。"

-- Lists
L["Nearby"] = "附近"
L["LastHour"] = "最近"
L["Ignore"] = "忽略"
L["KillOnSight"] = "即殺"

--Stats
L["Won"] = "勝"
L["Lost"] = "敗"
L["Time"] = "時間"	
L["List"] = "清單"
L["Filter"] = "過濾"	
L["Show Only"] = "只顯示"
L["Realm"] = "同伺服器"
L["KOS"] = "即殺"
L["Won/Lost"] = "勝/敗"
L["Reason"] = "原因"	  
L["HonorKills"] = "榮譽擊殺"
L["PvPDeaths"] = "PvP 死亡"

-- Output messages
L["VersionCheck"] = "|cffc41e3a警告! 安裝了錯誤版本的 Spy，此版本是給浩劫與重生經典版用的。"
L["SpyEnabled"] = "|cff9933ff偵測敵方玩家插件已啟用。"
L["SpyDisabled"] = "|cff9933ff偵測敵方玩家插件已停用，輸入 |cffffffff/spy show|cff9933ff 來啟用。"
L["UpgradeAvailable"] = "|cff9933ff偵測敵方玩家插件已有新版本，可以到這裡下載：\n|cffffffffhttps://www.curseforge.com/wow/addons/spy-cataclysm"
L["AlertStealthTitle"] = "偵測到隱形玩家!"
L["AlertKOSTitle"] = "偵測到即殺玩家!"
L["AlertKOSGuildTitle"] = "偵測到公會即殺玩家!"
L["AlertTitle_kosaway"] = "發現即殺玩家的位置，由 "
L["AlertTitle_kosguildaway"] = "發現公會即殺玩家的位置，由 "
L["StealthWarning"] = "|cff9933ff偵測到隱形玩家：|cffffffff"
L["KOSWarning"] = "|cffff0000偵測到即殺玩家：|cffffffff"
L["KOSGuildWarning"] = "|cffff0000偵測到公會即殺玩家：|cffffffff"
L["SpySignatureColored"] = "|cff9933ff[Spy] "
L["PlayerDetectedColored"] = "偵測到玩家：|cffffffff"
L["PlayersDetectedColored"] = "偵測到玩家：|cffffffff"
L["KillOnSightDetectedColored"] = "偵測到即殺玩家：|cffffffff"
L["PlayerAddedToIgnoreColored"] = "玩家加入到忽略清單：|cffffffff"
L["PlayerRemovedFromIgnoreColored"] = "從忽略清單移除玩家：|cffffffff"
L["PlayerAddedToKOSColored"] = "玩家加入到即殺清單：|cffffffff"
L["PlayerRemovedFromKOSColored"] = "從即殺清單移除玩家：|cffffffff"
L["PlayerDetected"] = "[Spy] 偵測到玩家："
L["KillOnSightDetected"] = "[Spy] 偵測到即殺玩家："
L["Level"] = "等級"
L["LastSeen"] = "上次遇到"
L["LessThanOneMinuteAgo"] = "小於 1 分鐘前"
L["MinutesAgo"] = "分鐘前"
L["HoursAgo"] = "小時前"
L["DaysAgo"] = "天前"
L["Close"] = "關閉"
L["CloseDescription"] = "|cffffffff隱藏 Spy 主視窗。預設下次偵測到敵方玩家時會再次顯示。"
L["Left/Right"] = "左 / 右"
L["Left/RightDescription"] = "|cffffffff切換顯示附近、最近、忽略和即殺清單。"
L["Clear"] = "清空"
L["ClearDescription"] = "|cffffffff清空已偵測到的玩家清單。\nCtrl+左鍵點擊 啟用/停用 Spy。\nShift+左鍵點擊 開啟/關閉所有音效。"
L["SoundEnabled"] = "警告音效已啟用"
L["SoundDisabled"] = "警告音效已停用"
L["NearbyCount"] = "附近數量"
L["NearbyCountDescription"] = "|cffffffff附近玩家的數量。"
L["Statistics"] = "統計資料" 
L["StatsDescription"] = "|cffffffff顯示遇過的敵方玩家、勝/敗記錄和上次在哪遇到的清單。"
L["AddToIgnoreList"] = "加入忽略清單"
L["AddToKOSList"] = "加入即殺清單"
L["RemoveFromIgnoreList"] = "從忽略清單移除"
L["RemoveFromKOSList"] = "從即殺清單移除"
L["RemoveFromStatsList"] = "從統計列表中刪除"   
L["AnnounceDropDownMenu"] = "通報"
L["KOSReasonDropDownMenu"] = "設定即殺原因"
L["PartyDropDownMenu"] = "隊伍"
L["RaidDropDownMenu"] = "團隊"
L["GuildDropDownMenu"] = "公會"
L["LocalDefenseDropDownMenu"] = "本地防務"
L["Player"] = " (玩家)"
L["KOSReason"] = "即殺"
L["KOSReasonIndent"] = "    "
L["KOSReasonOther"] = "自行輸入原因..."
L["KOSReasonClear"] = "清空原因"
L["StatsWins"] = "|cff40ff00勝："
L["StatsSeparator"] = "  "
L["StatsLoses"] = "|cff0070dd敗："
L["Located"] = "位置:"
L["Yards"] = "碼"
L["LocalDefenseChannelName"] = "本地防務"

-- 自行加入
L["Your pet/guardian killed "] = "你的寵物/保鑣殺了 "

Spy_KOSReasonListLength = 6
Spy_KOSReasonList = {
	[1] = {
		["title"] = "主動攻擊";
		["content"] = {
			"毫無理由攻擊我",
			"接任務時攻擊我", 
			"在鳥點攻擊我",
			"在副本入口攻擊我",
			"我 AFK 暫離時攻擊我",
			"我在趕路/飛行時攻擊我",
			"我的血量/法力很低時攻擊我",
		};
	},
	[2] = {
		["title"] = "戰鬥風格";
		["content"] = {
			"偷襲我",
			"總是讓我看到他再殺我",
			"使用高等級角色殺我",
			"和一群敵人一起輾壓我",
			"沒有人支援時不會攻擊",
			"老是向外求援",
			"使用超多控場技",
		};
	},
	[3] = {
		["title"] = "守屍守點";
		["content"] = {
			"守我屍體",
			"守我分身",
			"守低等級的必取",
			"會隱形來守點",
			"和公會成員一起守點",
			"守遊戲的 NPC/任務點",
			"守城市/村莊",
		};
	},
	[4] = {
		["title"] = "妨礙任務";
		["content"] = {
			"正在解任務時攻擊我",
			"幫忙解任務後攻擊我",
			"擾亂任務目標",
			"搶我的任務",
			"殺死我方陣營的 NPC",
			"殺死任務 NPC",
		};
	},
	[5] = {
		["title"] = "偷搶資源";
		["content"] = {
			"搶我的草",
			"搶我的礦",
			"搶我的資源",
			"殺死我然後搶走我的目標/稀有怪",
			"殺死我要殺的怪",
			"搶走我要殺的怪",
			"搶我的魚點",
		};
	},
	[6] = {
		["title"] = "其他";
		["content"] = {
			"就愛殺人",
			"把我推下懸崖",
			"使用工程學道具",
			"總是落跑",
			"使用物品或技能落跑",
			"濫用遊戲機制",
			"自行輸入原因...",
		};
	},
}

StaticPopupDialogs["Spy_SetKOSReasonOther"] = {
	preferredIndex=STATICPOPUPS_NUMDIALOGS,  -- http://forums.wowace.com/showthread.php?p=320956
	text = "輸入 %s 的即殺原因:",
	button1 = "設定",
	button2 = "取消",
	timeout = 20,
	hasEditBox = 1,
	editBoxWidth = 260,		
	whileDead = 1,
	hideOnEscape = 1,
	OnShow = function(self)
		self.editBox:SetText("");
	end,
	OnAccept = function(self)
		local reason = self.editBox:GetText()
		Spy:SetKOSReason(self.playerName, "自行輸入原因...", reason)
	end,
};

-- Class descriptions
L["UNKNOWN"] = "未知"
L["DRUID"] = "德魯伊"
L["HUNTER"] = "獵人"
L["MAGE"] = "法師"
L["PALADIN"] = "聖騎士"
L["PRIEST"] = "牧師"
L["ROGUE"] = "盜賊"
L["SHAMAN"] = "薩滿"
L["WARLOCK"] = "術士"
L["WARRIOR"] = "戰士"
L["DEATHKNIGHT"] = "死亡騎士"
L["MONK"] = "武僧"
L["DEMONHUNTER"] = "惡魔獵人"
L["EVOKER"] = "喚能師"

-- Race descriptions
L["Human"] = "人類"
L["Orc"] = "獸人"
L["Dwarf"] = "矮人"
L["Tauren"] = "牛頭人"
L["Troll"] = "食人妖"
L["Night Elf"] = "夜精靈"
L["Undead"] = "不死族"
L["Gnome"] = "地精"
L["Blood Elf"] = "血精靈"
L["Draenei"] = "德萊尼"
L["Goblin"] = "哥布林"
L["Worgen"] = "狼人"
L["Pandaren"] = "熊貓人"
L["Highmountain Tauren"] = "高嶺牛頭人"
L["Lightforged Draenei"] = "光鑄德萊尼"
L["Nightborne"] = "夜裔精靈"
L["Void Elf"] = "虛無精靈"
L["Dark Iron Dwarf"] = "黑鐵矮人"
L["Mag'har Orc"] = "瑪格哈獸人"
L["Kul Tiran"] = "庫爾提拉斯人"
L["Zandalari Troll"] = "贊達拉食人妖"
L["Mechagnome"] = "機械地精"
L["Vulpera"] = "狐狸人"
L["Dracthyr"] = "半龍人"

-- Stealth abilities
L["Stealth"] = "隱形"
L["Prowl"] = "潛行"

-- Minimap color codes
L["MinimapGuildText"] = "|cffffffff"
L["MinimapClassTextUNKNOWN"] = "|cff191919"
L["MinimapClassTextDRUID"] = "|cffff7c0a"
L["MinimapClassTextHUNTER"] = "|cffaad372"
L["MinimapClassTextMAGE"] = "|cff68ccef"
L["MinimapClassTextPALADIN"] = "|cfff48cba"
L["MinimapClassTextPRIEST"] = "|cffffffff"
L["MinimapClassTextROGUE"] = "|cfffff468"
L["MinimapClassTextSHAMAN"] = "|cff2359ff"
L["MinimapClassTextWARLOCK"] = "|cff9382c9"
L["MinimapClassTextWARRIOR"] = "|cffc69b6d"
L["MinimapClassTextDEATHKNIGHT"] = "|cffc41e3a"
L["MinimapClassTextMONK"] = "|cff00ff96"
L["MinimapClassTextDEMONHUNTER"] = "|cffa330c9"
L["MinimapClassTextEVOKER"] = "|cff33937f"

Spy_IgnoreList = {
	["邮箱"]=true, ["Shred Master Mk1"]=true, ["Scrap-O-Matic 1000"]=true,
	["前往暴风城的船"]=true, ["前往伯拉勒斯港（提拉加德海峡）的船"]=true,
	["Treasure Chest"]=true, ["Small Treasure Chest"]=true,
	["阿昆达之噬"]=true, ["锚草"]=true, ["流波花苞"]=true,    
	["海潮茎杆"]=true, ["海妖花粉"]=true, ["星光苔"]=true,   
	["凛冬之吻"]=true, ["战争指挥部（PvP）"]=true,
	["联盟刺客"]=true, ["部落刺客"]=true,
	["秘法师鸟羽帽"]=true, ["表弟慢热手"]=true,	
	["联盟的艾泽里特"]=true, ["部落的艾泽里特"]=true,	
};