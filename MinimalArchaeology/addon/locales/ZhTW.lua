-- If you would like to help with translations, please use https://curseforge.com/wow/addons/minimal-archaeology/localization
local L = LibStub("AceLocale-3.0"):NewLocale("MinArch", "zhTW")
if not L then return end

L["BINDINGS_COMMANDS"] = "指令"
L["BINDINGS_COMPANION_MORE"] = "相關助手指令，更多資訊請輸入:"
L["BINDINGS_COMPANION_RESETPOS"] = "重置助手方塊的位置"
L["BINDINGS_HIDEMAIN"] = "隱藏主考古小幫手框架"
L["BINDINGS_MINARCH_CASTSURVEY"] = "施放勘察"
L["BINDINGS_MINARCH_COMPANION_COMMANDS"] = "考古小幫手助手相關指令"
L["BINDINGS_MINARCH_MAIN_COMMANDS"] = "考古小幫手指令"
L["BINDINGS_MINARCH_SHOWHIDE"] = "顯示/隱藏 考古小幫手"
L["BINDINGS_MINARCH_VERSION"] = "顯示正在運行的考古小幫手版本"
L["BINDINGS_SHOWMAIN"] = "顯示主考古小幫手框架"
L["BINDINGS_TOGGLEMAIN"] = "切換主考古小幫手框架"
L["BINDINGS_USAGE"] = "用法"
L["COMPANION_TUTORIAL_1"] = "這是考古小幫手助手框架，包含距離追蹤器等等。|n|n|cFFFFD100[右鍵點擊]|r以停用此教學提示框並顯示自訂設定。"
L["DATABROKER_HINT_ALT_LEFTCLICK"] = "Alt + 左鍵點擊以隱藏所有考古小幫手視窗。"
L["DATABROKER_HINT_CTRL_LEFTCLICK"] = "Ctrl + 左鍵點擊以切換考古小幫手挖掘點視窗。"
L["DATABROKER_HINT_LEFTCLICK"] = "提示: 左鍵點擊以切換考古小幫手主視窗。"
L["DATABROKER_HINT_RIGHTCLICK"] = "右鍵點擊以開啟設定"
L["DATABROKER_HINT_SHIFT_LEFTCLICK"] = "Shift + 左鍵點擊以切換考古小幫手歷史記錄視窗。"
L["DIGSITES_DIGSITE"] = "挖掘點"
L["GLOBAL_BROKEN_ISLES"] = "破碎群島"
L["GLOBAL_DRAENOR"] = "德拉諾"
L["GLOBAL_EASTERN_KINGDOMS"] = "東部王國"
L["GLOBAL_KALIMDOR"] = "卡林多"
L["GLOBAL_KUL_TIRAS"] = "庫爾提拉斯"
L["GLOBAL_NORTHREND"] = "北裂境"
L["GLOBAL_OUTLAND"] = "外域"
L["GLOBAL_PANDARIA"] = "潘達利亞"
L["GLOBAL_ZANDALAR"] = "贊達拉"
L["HISTORY_SOLVE_CONFIRMATION_ALWAYS"] = "是，總是！"
L["HISTORY_SOLVE_CONFIRMATION_NO"] = "否"
L["HISTORY_SOLVE_CONFIRMATION_QUESTION"] = "你確定要為這個碎片上限種族解決這個神器嗎？"
L["HISTORY_SOLVE_CONFIRMATION_YES"] = "是"
L["HISTORY_TOOLTIP_PROGRESSINFO"] = "神器進度資訊"
L["HISTORY_TOTAL"] = "總計"
L["NAVIGATION_CLOSEST"] = "最近的"
L["NAVIGATION_FLIGHTMASTER"] = "飛行管理員"
L["OPTIONS_AUTOHIDE_TITLE"] = "自動隱藏主視窗"
L["OPTIONS_AUTOSHOW_CAP_DESC"] = "當一個種族的碎片達到上限時自動顯示考古小幫手。"
L["OPTIONS_AUTOSHOW_CAP_TITLE"] = "達到上限時顯示"
L["OPTIONS_AUTOSHOW_DIGSITES_DESC"] = "在挖掘點附近移動時自動顯示考古小幫手。"
L["OPTIONS_AUTOSHOW_DIGSITES_TITLE"] = "在挖掘點顯示"
L["OPTIONS_AUTOSHOW_SOLVES_DESC"] = "當可以解決神器時自動顯示考古小幫手。"
L["OPTIONS_AUTOSHOW_SOLVES_TITLE"] = "解決時顯示"
L["OPTIONS_AUTOSHOW_SURVEY_DESC"] = "在挖掘點勘察時自動顯示考古小幫手。"
L["OPTIONS_AUTOSHOW_SURVEY_TITLE"] = "勘察時顯示"
L["OPTIONS_AUTOSHOW_TITLE"] = "自動顯示主視窗"
L["OPTIONS_COMPANION_DESCRIPTION"] = " |cFFF96854助手|r 是一個小型的浮動視窗，具有技能欄，距離追蹤器以及導航，解決方案，箱子按鈕和用於召喚隨機坐騎的按鈕。可以停用每個按鈕，您還可以自訂它們的順序。助手具有與其餘視窗分離的縮放和自動顯示/自動隱藏功能。"
L["OPTIONS_COMPANION_FEATURES_TITLE"] = "自訂助手功能"
L["OPTIONS_COMPANION_GENERAL_ALWAYS_SHOW_DESC"] = "啟用後，即使您不在挖掘點（除了在副本中以及啟用“在戰鬥中隱藏”），也始終顯示助手框架。"
L["OPTIONS_COMPANION_GENERAL_ALWAYS_SHOW_TITLE"] = "總是顯示"
L["OPTIONS_COMPANION_GENERAL_COLORING_BG_TITLE"] = "背景顏色"
L["OPTIONS_COMPANION_GENERAL_COLORING_OPACITY_TITLE"] = "背景不透明度"
L["OPTIONS_COMPANION_GENERAL_COLORING_TITLE"] = "|n顏色設定"
L["OPTIONS_COMPANION_GENERAL_ENABLE_DESC"] = "切換考古小幫手的助手框架插件。助手是一個小型框架，帶有距離追蹤器和導航/勘察/解決/箱子按鈕。"
L["OPTIONS_COMPANION_GENERAL_ENABLE_TITLE"] = "啟用助手框架"
L["OPTIONS_COMPANION_GENERAL_HIDEINCOMBAT_DESC"] = "啟用後在戰鬥中隱藏（即使已啟用始終顯示）。"
L["OPTIONS_COMPANION_GENERAL_HIDEINCOMBAT_TITLE"] = "戰鬥中隱藏"
L["OPTIONS_COMPANION_GENERAL_HIDENA_DESC"] = "啟用後，當世界地圖上沒有可用的挖掘點時隱藏。"
L["OPTIONS_COMPANION_GENERAL_HIDENA_TITLE"] = "不可用時隱藏"
L["OPTIONS_COMPANION_GENERAL_SIZING_PADDING_DESC"] = "設定助手框架的填充大小。預設值：3。"
L["OPTIONS_COMPANION_GENERAL_SIZING_PADDING_TITLE"] = "填充大小"
L["OPTIONS_COMPANION_GENERAL_SIZING_SCALE_DESC"] = "設定助手的大小。預設值：100。"
L["OPTIONS_COMPANION_GENERAL_SIZING_SCALE_TITLE"] = "助手縮放"
L["OPTIONS_COMPANION_GENERAL_SIZING_SPACING_DESC"] = "設定按鈕之間的間距大小。預設值：2。"
L["OPTIONS_COMPANION_GENERAL_SIZING_SPACING_TITLE"] = "按鈕間距"
L["OPTIONS_COMPANION_GENERAL_SIZING_TITLE"] = "大小設定"
L["OPTIONS_COMPANION_GENERAL_TITLE"] = "一般設定"
L["OPTIONS_COMPANION_POSITION_FEATURES_CRATE_SHOW_DESC"] = "在助手框架上顯示箱子按鈕"
L["OPTIONS_COMPANION_POSITION_FEATURES_CRATE_SHOW_TITLE"] = "顯示箱子按鈕"
L["OPTIONS_COMPANION_POSITION_FEATURES_CRATE_TITLE"] = "箱子按鈕設定"
L["OPTIONS_COMPANION_POSITION_FEATURES_DT_SHAPE_TITLE"] = "形狀"
L["OPTIONS_COMPANION_POSITION_FEATURES_DT_SHOW_DESC"] = "切換助手框架上的距離追蹤器"
L["OPTIONS_COMPANION_POSITION_FEATURES_DT_SHOW_TITLE"] = "顯示距離追蹤器"
L["OPTIONS_COMPANION_POSITION_FEATURES_DT_TITLE"] = "距離追蹤器設定"
L["OPTIONS_COMPANION_POSITION_FEATURES_MOUNT_SHOW_DESC"] = "在助手框架上顯示隨機坐騎按鈕"
L["OPTIONS_COMPANION_POSITION_FEATURES_MOUNT_SHOW_TITLE"] = "顯示隨機坐騎按鈕"
L["OPTIONS_COMPANION_POSITION_FEATURES_MOUNT_TITLE"] = "隨機坐騎按鈕設定"
L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_CLICK_DESC"] = "點擊進度條時解決當前啟動的神器"
L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_CLICK_TITLE"] = "點擊解決"
L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_SHOW_DESC"] = "在助手框架上顯示神器進度條"
L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_SHOW_TITLE"] = "顯示進度條"
L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_TITLE"] = "進度條設定"
L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_TOOLTIP_DESC"] = "將鼠標懸停在進度條上時顯示神器提示"
L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_TOOLTIP_TITLE"] = "顯示提示"
L["OPTIONS_COMPANION_POSITION_FEATURES_SKILLBAR_SHOW_DESC"] = "在助手框架上顯示技能進度條"
L["OPTIONS_COMPANION_POSITION_FEATURES_SKILLBAR_SHOW_TITLE"] = "顯示技能條"
L["OPTIONS_COMPANION_POSITION_FEATURES_SKILLBAR_TITLE"] = "技能條設定"
L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_DESC"] = "在助手框架上顯示解決按鈕"
L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_KEYSTONES_DESC"] = "啟用後，如果當前解決方案可用，則在解決按鈕上顯示鑰石。還可以讓您應用/移除鑰石（如果未設定自動應用）"
L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_KEYSTONES_TITLE"] = "顯示鑰石"
L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_NEAREST_DESC"] = "啟用後，即使您尚未解決該項目，也顯示與最近的挖掘點相關的項目"
L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_NEAREST_TITLE"] = "顯示正在進行的神器"
L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_RELEVANT_DESC"] = "啟用後，僅顯示相關種族的解決方案（在「種族」部分中自訂）"
L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_RELEVANT_TITLE"] = "僅顯示相關的"
L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_SOLVABLE_DESC"] = "啟用後，通過顯示可以解決的項目來覆蓋先前的設定，即使該項目與最近的挖掘點無關"
L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_SOLVABLE_TITLE"] = "始終顯示可解決的神器"
L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_TITLE"] = "顯示解決按鈕"
L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_TITLE"] = "解決按鈕設定"
L["OPTIONS_COMPANION_POSITION_FEATURES_SURVEY_SHOW_DESC"] = "在助手框架上顯示勘察按鈕"
L["OPTIONS_COMPANION_POSITION_FEATURES_SURVEY_SHOW_TITLE"] = "顯示勘察按鈕"
L["OPTIONS_COMPANION_POSITION_FEATURES_SURVEY_TITLE"] = "勘察按鈕設定"
L["OPTIONS_COMPANION_POSITION_FEATURES_WP_SHOW_DESC"] = "在助手框架上顯示自動導航按鈕"
L["OPTIONS_COMPANION_POSITION_FEATURES_WP_SHOW_TITLE"] = "顯示導航按鈕"
L["OPTIONS_COMPANION_POSITION_FEATURES_WP_TITLE"] = "導航按鈕設定"
L["OPTIONS_COMPANION_POSITION_HOFFSET_DESC"] = "螢幕上的水平位置"
L["OPTIONS_COMPANION_POSITION_HOFFSET_TITLE"] = "水平偏移"
L["OPTIONS_COMPANION_POSITION_LOCK_DESC"] = "停用在助手框架上的拖動，但您仍然可以通過在此選項頁上手動修改偏移來移動它。"
L["OPTIONS_COMPANION_POSITION_LOCK_TITLE"] = "鎖定位置"
L["OPTIONS_COMPANION_POSITION_RESET"] = "重置位置"
L["OPTIONS_COMPANION_POSITION_SAVEPOS_DESC"] = "啟用後，將位置保存在設定檔案中，以便助手在所有使用相同設定檔案的角色上都位於同一位置。"
L["OPTIONS_COMPANION_POSITION_SAVEPOS_TITLE"] = "將位置保存在檔案中"
L["OPTIONS_COMPANION_POSITION_TITLE"] = "定位"
L["OPTIONS_COMPANION_POSITION_VOFFSET_DESC"] = "螢幕上的垂直位置"
L["OPTIONS_COMPANION_POSITION_VOFFSET_TITLE"] = "垂直偏移"
L["OPTIONS_COMPANION_TITLE"] = "助手設定"
L["OPTIONS_DEV_DEBUG_DEV_DESC"] = "在聊天中顯示除錯訊息。除錯訊息顯示有關插件的更多詳細資訊，而不是狀態訊息。"
L["OPTIONS_DEV_DEBUG_DEV_TITLE"] = "顯示除錯訊息"
L["OPTIONS_DEV_DEBUG_STATUS_DESC"] = "在聊天中顯示考古小幫手狀態訊息。"
L["OPTIONS_DEV_DEBUG_STATUS_TITLE"] = "顯示狀態訊息"
L["OPTIONS_DEV_DEBUG_TITLE"] = "除錯訊息"
L["OPTIONS_DEV_EXPERIMENTAL_DESC"] = "實驗性功能放置在此處，因為它們處於測試階段，可能需要額外的工作和反饋。可以使用實驗性功能而無需啟用除錯訊息，但如果出現任何問題，我可能會要求提供這些訊息。"
L["OPTIONS_DEV_EXPERIMENTAL_OPTIMIZE_DESC"] = "導航不會始終指向最近的站點，而是嘗試從長遠來看優化行程時間。"
L["OPTIONS_DEV_EXPERIMENTAL_OPTIMIZE_MOD_DESC"] = "將優化修改器設定為自訂值。"
L["OPTIONS_DEV_EXPERIMENTAL_OPTIMIZE_MOD_TITLE"] = "優化修改器"
L["OPTIONS_DEV_EXPERIMENTAL_OPTIMIZE_TITLE"] = "優化路徑"
L["OPTIONS_DEV_EXPERIMENTAL_TITLE"] = "實驗性功能"
L["OPTIONS_DEV_TITLE"] = "測試人員/開發人員設定"
L["OPTIONS_DISABLE_SOUND_DESC"] = "停用可以解決神器時播放的聲音。"
L["OPTIONS_DISABLE_SOUND_TITLE"] = "停用聲音"
L["OPTIONS_GENERAL_MAIN_TITLE"] = "一般設定 - 主視窗"
L["OPTIONS_GENERAL_MAIN_WINDOWS"] = "打開此部分以配置 |cFFF96854點兩下右鍵勘察|r 以及 |cFFF96854主要|r、|cFFF96854歷史記錄|r 和 |cFFF96854挖掘點|r 視窗。如果您不熟悉考古小幫手，請點擊下面的按鈕以切換每個特定視窗。"
L["OPTIONS_GENERAL_TITLE"] = "一般設定"
L["OPTIONS_GLOBAL_CIRCLE"] = "圓形"
L["OPTIONS_GLOBAL_ORDER_TITLE"] = "順序"
L["OPTIONS_GLOBAL_SQUARE"] = "正方形"
L["OPTIONS_GLOBAL_TRIANGLE"] = "三角形"
L["OPTIONS_HIDE_AFTER_DIGSITES_DESC"] = "完成挖掘點後隱藏考古小幫手。"
L["OPTIONS_HIDE_AFTER_DIGSITES_TITLE"] = "挖掘點後自動隱藏"
L["OPTIONS_HIDE_IN_COMBAT_DESC"] = "戰鬥開始時隱藏考古小幫手，並在戰鬥後重新打開它。"
L["OPTIONS_HIDE_IN_COMBAT_TITLE"] = "戰鬥中自動隱藏"
L["OPTIONS_HIDE_MINIMAPBUTTON_DESC"] = "隱藏小地圖按鈕"
L["OPTIONS_HIDE_MINIMAPBUTTON_TITLE"] = "隱藏小地圖按鈕"
L["OPTIONS_HIDE_WATE_FOR_SOLVES_DESC"] = "在自動隱藏之前，請等到所有神器都解決了。"
L["OPTIONS_HIDE_WATE_FOR_SOLVES_TITLE"] = "等待解決神器"
L["OPTIONS_HISTORY_AUTORESIZE_DESC"] = "啟用後，自動調整歷史記錄視窗的大小以適合所有項目"
L["OPTIONS_HISTORY_AUTORESIZE_TITLE"] = "自動調整大小"
L["OPTIONS_HISTORY_GROUP_DESC"] = "如果啟用，神器將按進度分組：當前 > 未完成 > 已完成。"
L["OPTIONS_HISTORY_GROUP_TITLE"] = "按進度分組"
L["OPTIONS_HISTORY_SHOW_STATS_DESC"] = "顯示每個種族的進度和總解決數量。"
L["OPTIONS_HISTORY_SHOW_STATS_TITLE"] = "顯示統計資訊"
L["OPTIONS_HISTORY_WINDOW_TITLE"] = "歷史記錄視窗設定"
L["OPTIONS_INTRO"] = "有關配置選項，請展開左側的考古小幫手部分。這是插件和設定的概述："
L["OPTIONS_MAP_PIN_SCALE_DESC"] = "世界地圖上挖掘點圖示的縮放比例。更改後重新打開您的地圖。"
L["OPTIONS_MAP_PIN_SCALE_TITLE"] = "地圖圖示縮放"
L["OPTIONS_MISC_TITLE"] = "其他選項"
L["OPTIONS_NAV_AUTO_CONT_DESC"] = "持續建立/更新到最近的挖掘點的自動導航。"
L["OPTIONS_NAV_AUTO_CONT_TITLE"] = "持續"
L["OPTIONS_NAV_AUTO_IGNOREHIDDEN_DESC"] = "啟用此選項可在建立導航時忽略隱藏的種族。注意：如果當前所有可用的挖掘點都屬於該種族，它仍會導航到隱藏的種族。"
L["OPTIONS_NAV_AUTO_IGNOREHIDDEN_TITLE"] = "忽略隱藏的種族"
L["OPTIONS_NAV_AUTO_ONCOMPLETE_DESC"] = "完成一個挖掘點後，自動建立一個到最近的挖掘點的導航。"
L["OPTIONS_NAV_AUTO_ONCOMPLETE_TITLE"] = "完成時"
L["OPTIONS_NAV_AUTO_PRIORITY_NOTE"] = "注意：優先級選項已移至種族設定部分"
L["OPTIONS_NAV_AUTO_TITLE"] = "自動建立到最近的挖掘點的導航。"
L["OPTIONS_NAV_BLIZZ_FLOATPIN_DESC"] = "啟用後，在目的地上方顯示浮動圖示（僅在主線可用）。"
L["OPTIONS_NAV_BLIZZ_FLOATPIN_TITLE"] = "顯示浮動圖示"
L["OPTIONS_NAV_BLIZZ_PIN_DESC"] = "啟用後，在地點上建立地圖圖示（僅在主線可用）。"
L["OPTIONS_NAV_BLIZZ_PIN_TITLE"] = "地圖圖示"
L["OPTIONS_NAV_BLIZZ_TITLE"] = "暴雪導航"
L["OPTIONS_NAV_TAXI_AUTODISABLE_DESC"] = "當世界地圖上沒有挖掘點時以及登錄時，在飛行地圖上自動停用考古模式"
L["OPTIONS_NAV_TAXI_AUTODISABLE_TITLE"] = "自動停用"
L["OPTIONS_NAV_TAXI_AUTOENABLE_DESC"] = "當考古小幫手建立導航時，在飛行地圖上自動啟用考古模式"
L["OPTIONS_NAV_TAXI_AUTOENABLE_TITLE"] = "自動啟用"
L["OPTIONS_NAV_TAXI_DISTANCE_DESC"] = "如果啟用，如果最近的挖掘點的距離超過配置的距離限制，則將建立到最近的飛行管理員的導航。"
L["OPTIONS_NAV_TAXI_DISTANCE_TITLE"] = "距離限制"
L["OPTIONS_NAV_TAXI_ENABLE_DESC"] = "啟用後，如果最近的挖掘點的距離超過配置的距離限制，則將導航設定為最近的飛行管理員。"
L["OPTIONS_NAV_TAXI_ENABLE_TITLE"] = "導航到最近的飛行管理員"
L["OPTIONS_NAV_TAXI_PINOPA_DESC"] = "設定飛行地圖上不相關的出租車節點的不透明度"
L["OPTIONS_NAV_TAXI_PINOPA_TITLE"] = "圖示不透明度"
L["OPTIONS_NAV_TAXI_TITLE"] = "出租車選項"
L["OPTIONS_NAV_TITLE"] = "考古小幫手 - TomTom"
L["OPTIONS_NAV_TOMTOM_ARROW_DESC"] = "顯示考古小幫手建立的導航的箭頭。這不會更改已經存在的導航。"
L["OPTIONS_NAV_TOMTOM_ARROW_TITLE"] = "顯示箭頭"
L["OPTIONS_NAV_TOMTOM_ENABLE_DESC"] = "切換考古小幫手中的 TomTom 整合。停用 TomTom 整合將刪除考古小幫手建立的所有導航"
L["OPTIONS_NAV_TOMTOM_ENABLE_TITLE"] = "在考古小幫手中啟用 TomTom 整合"
L["OPTIONS_NAV_TOMTOM_TITLE"] = "TomTom 選項"
L["OPTIONS_NAV_TOMTOM_WP_DESC"] = "切換導航持久性。這不會更改已經存在的導航。"
L["OPTIONS_NAV_TOMTOM_WP_TITLE"] = "保留導航"
L["OPTIONS_NAVIGATION_DESCRIPTION"] = " |cFFF96854TomTom|r 整合和暴雪 |cFFF96854導航|r 系統支援的選項（如果可用）。"
L["OPTIONS_NAVIGATION_TITLE"] = "導航設定"
L["OPTIONS_PATRONS_DESC"] = "感謝您使用考古小幫手 Minimal Archaeology。如果您喜歡這個插件，請考慮成為 |cFFF96854patreon.com/minarch|r 上的贊助者，以支援開發。"
L["OPTIONS_PATRONS_SUBTITLE"] = "贊助者"
L["OPTIONS_PATRONS_TITLE"] = "考古小幫手贊助者"
L["OPTIONS_RACE_AFFECTS_BOTH"] = "（影響北裂境和東部王國）"
L["OPTIONS_RACE_CAP_ALWAYS"] = "總是使用所有可用的"
L["OPTIONS_RACE_CAP_ALWAYS_USE"] = "神器。"
L["OPTIONS_RACE_CAP_ALWAYS_USE_TO_SOLVE"] = "以解決"
L["OPTIONS_RACE_CAP_CONFIRM_DESC"] = "在為啟用農場模式的種族解決神器之前顯示確認"
L["OPTIONS_RACE_CAP_CONFIRM_TITLE"] = "顯示碎片上限解決方案的確認"
L["OPTIONS_RACE_CAP_DESC"] = "如果您為種族啟用農場模式，則主視窗將顯示該種族的碎片上限，而不是當前解決方案所需的碎片。適用於收集暗月馬戲團的化石碎片。"
L["OPTIONS_RACE_CAP_KEYSTONE_DESC"] = "自動將鑰石（不常見的碎片）應用於選中的種族。"
L["OPTIONS_RACE_CAP_KEYSTONE_FOSSIL_NOTE"] = "注意: 化石沒有鑰石。"
L["OPTIONS_RACE_CAP_KEYSTONE_TITLE"] = "自動鑰石"
L["OPTIONS_RACE_CAP_PRIORITY_DESC"] = "優先級目前僅適用於導航生成順序。自動導航將指向優先級種族，然後指向其他（否則更近）挖掘點。數字越小表示優先級越高。"
L["OPTIONS_RACE_CAP_PRIORITY_RESETALL"] = "全部重置"
L["OPTIONS_RACE_CAP_PRIORITY_TITLE"] = "優先級"
L["OPTIONS_RACE_CAP_TITLE"] = "農場模式"
L["OPTIONS_RACE_CAP_USE"] = "使用碎片上限 - "
L["OPTIONS_RACE_CAP_USE_FOR"] = "神器欄。"
L["OPTIONS_RACE_DESCRIPTION"] = "種族相關選項：|cFFF96854隱藏|r 或 |cFFF96854優先級化|r 種族，設定 |cFFF96854農場模式|r 或啟用 |cFFF96854自動鑰石|r 應用。"
L["OPTIONS_RACE_HIDE_DESC"] = "勾選您希望始終隱藏的種族。這將覆蓋相關性設定。\n\n 隱藏的種族不會顯示在主視窗中，助手也不會顯示它們的解決方案。"
L["OPTIONS_RACE_HIDE_EVEN"] = "神器欄，即使它已被發現。"
L["OPTIONS_RACE_HIDE_THE"] = "隱藏"
L["OPTIONS_RACE_HIDE_TITLE"] = "隱藏"
L["OPTIONS_RACE_HIDE_WPIGNORE_DESC"] = "啟用此選項，也可以在建立導航時忽略隱藏的種族。"
L["OPTIONS_RACE_HIDE_WPIGNORE_TITLE"] = "建立導航時忽略隱藏的種族"
L["OPTIONS_RACE_RELEVANCY_CUSTOMIZE"] = "自訂相關性"
L["OPTIONS_RACE_RELEVANCY_DESC"] = "自訂當切換相關種族時，您希望在主視窗中顯示哪些種族。\n"
L["OPTIONS_RACE_RELEVANCY_EXPANSION_DESC"] = "顯示可能在您當前大陸（或資料片）上可用的種族，即使它們目前沒有活動的挖掘點。"
L["OPTIONS_RACE_RELEVANCY_EXPANSION_TITLE"] = "特定資料片"
L["OPTIONS_RACE_RELEVANCY_NEARBY_DESC"] = "顯示目前在您當前大陸上有可用挖掘點的種族。"
L["OPTIONS_RACE_RELEVANCY_NEARBY_TITLE"] = "附近可用"
L["OPTIONS_RACE_RELEVANCY_OVERRIDE_FRAGCAP_DESC"] = "啟用後，將啟用農場模式（碎片上限）的種族視為不相關，因為它們有可用的解決方案，但根據其他相關性設定，它們將是不相關的。"
L["OPTIONS_RACE_RELEVANCY_OVERRIDE_FRAGCAP_TITLE"] = "隱藏設定為農場模式（碎片上限）的種族的不相關解決方案"
L["OPTIONS_RACE_RELEVANCY_OVERRIDES_TITLE"] = "相關性覆蓋"
L["OPTIONS_RACE_RELEVANCY_SOLVABLE_DESC"] = "顯示有可用解決方案的種族，即使它們既不可用，也與您當前大陸無關。"
L["OPTIONS_RACE_RELEVANCY_SOLVABLE_TITLE"] = "可解決"
L["OPTIONS_RACE_RELEVANCY_TITLE"] = "相關性"
L["OPTIONS_RACE_SECTION_TITLE"] = "種族設定"
L["OPTIONS_RACE_SET"] = "設定"
L["OPTIONS_RACE_SET_PRIORITY"] = "優先級"
L["OPTIONS_RACE_TITLE"] = "種族設定"
L["OPTIONS_REGISTER_MINARCH"] = "專業-考古"
L["OPTIONS_REGISTER_MINARCH_COMPANION_SUBTITLE"] = "助手設定"
L["OPTIONS_REGISTER_MINARCH_COMPANION_TITLE"] = "考古小幫手助手設定"
L["OPTIONS_REGISTER_MINARCH_DEV_SUBTITLE"] = "開發人員設定"
L["OPTIONS_REGISTER_MINARCH_DEV_TITLE"] = "考古小幫手開發人員設定"
L["OPTIONS_REGISTER_MINARCH_GENERAL_SUBTITLE"] = "一般設定"
L["OPTIONS_REGISTER_MINARCH_GENERAL_TITLE"] = "考古小幫手一般設定"
L["OPTIONS_REGISTER_MINARCH_NAV_SUBTITLE"] = "導航設定"
L["OPTIONS_REGISTER_MINARCH_NAV_TITLE"] = "考古小幫手導航設定"
L["OPTIONS_REGISTER_MINARCH_PATRONS_SUBTITLE"] = "贊助者"
L["OPTIONS_REGISTER_MINARCH_PATRONS_TITLE"] = "考古小幫手贊助者"
L["OPTIONS_REGISTER_MINARCH_PROFILES_SUBTITLE"] = "設定檔"
L["OPTIONS_REGISTER_MINARCH_PROFILES_TITLE"] = "考古小幫手設定檔"
L["OPTIONS_REGISTER_MINARCH_RACE_SUBTITLE"] = "種族設定"
L["OPTIONS_REGISTER_MINARCH_RACE_TITLE"] = "考古小幫手種族設定"
L["OPTIONS_REMEMBER_WINDOW_STATES_DESC"] = "記住登出（或重新加載UI）時哪些考古小幫手視窗是打開的。"
L["OPTIONS_REMEMBER_WINDOW_STATES_TITLE"] = "記住視窗狀態"
L["OPTIONS_SHOW_WORLD_MAP_ICONS_DESC"] = "在世界地圖上的挖掘點旁邊顯示種族圖示。"
L["OPTIONS_SHOW_WORLD_MAP_ICONS_TITLE"] = "顯示世界地圖覆蓋圖示"
L["OPTIONS_START_HIDDEN_DESC"] = "始終以隱藏狀態啟動考古小幫手。"
L["OPTIONS_START_HIDDEN_TITLE"] = "以隱藏狀態啟動"
L["OPTIONS_STARTUP_NOTE"] = "注意：這些設定不影響助手框架。"
L["OPTIONS_STARTUP_SETTINGS_TITLE"] = "啟動設定"
L["OPTIONS_SURVEY_DONT_FLYING_DESC"] = "勾選此選項以防止在您飛行時施放勘察。"
L["OPTIONS_SURVEY_DONT_FLYING_TITLE"] = "飛行時不要施放"
L["OPTIONS_SURVEY_DONT_MOUNTED_DESC"] = "勾選此選項以防止在您騎坐騎時施放勘察。"
L["OPTIONS_SURVEY_DONT_MOUNTED_TITLE"] = "騎坐騎時不要施放"
L["OPTIONS_SURVEY_ON_DBL_CLICK_BTN_DESC"] = "用於點兩下勘察的按鈕。"
L["OPTIONS_SURVEY_ON_DBL_CLICK_BTN_LMB"] = "滑鼠左鍵"
L["OPTIONS_SURVEY_ON_DBL_CLICK_BTN_RMB"] = "滑鼠右鍵"
L["OPTIONS_SURVEY_ON_DBL_CLICK_BTN_TITLE"] = "點兩下按鈕"
L["OPTIONS_SURVEY_ON_DBL_RCLICK_DESC"] = "啟用後，當您用滑鼠右鍵點兩下時施放勘察。"
L["OPTIONS_SURVEY_ON_DBL_RCLICK_TITLE"] = "點兩下右鍵進行勘察"
L["OPTIONS_SURVEYING_TITLE"] = "勘察"
L["OPTIONS_THANKS"] = "感謝您使用考古小幫手 Minimal Archaeology"
L["OPTIONS_TOGGLE_DIGSITES"] = "切換挖掘點"
L["OPTIONS_TOGGLE_HISTORY"] = "切換歷史記錄"
L["OPTIONS_TOGGLE_MAIN"] = "切換主要"
L["OPTIONS_WINDOW_SCALE_DESC"] = "主視窗、歷史記錄和挖掘點視窗的縮放比例。助手使用助手部分中的單獨滑塊進行縮放。"
L["OPTIONS_WINDOW_SCALE_TITLE"] = "視窗縮放"
L["TOOLTIP_CRATE_BUTTON_LEFTCLICK"] = "點擊以將此神器裝箱"
L["TOOLTIP_CRATE_BUTTON_RIGHTCLICK"] = "您沒有任何東西可以裝箱。"
L["TOOLTIP_DIGSITE_TAXI_TRAVEL"] = "提示：左鍵點擊以在這裡旅行。"
L["TOOLTIP_DIGSITE_WP"] = "提示：左鍵點擊以在這裡建立導航。"
L["TOOLTIP_FRAGMENTS"] = "碎片"
L["TOOLTIP_HISTORY_AUTORESIZE_DISABLE"] = "點擊以將歷史記錄視窗的高度設定為固定大小|r"
L["TOOLTIP_HISTORY_AUTORESIZE_ENABLE"] = "點擊以啟用歷史記錄視窗的自動調整大小"
L["TOOLTIP_HISTORY_DISCOVEREDON"] = "發現於"
L["TOOLTIP_HISTORY_HAVENT_DISCOVERED"] = "您尚未發現這個種族。"
L["TOOLTIP_HISTORY_LEGIONQUEST_AVAILABLE"] = "目前可從每兩週一次的軍團任務中獲得"
L["TOOLTIP_HISTORY_PRISTINE_COMPLETE"] = "已找到原始版本"
L["TOOLTIP_HISTORY_PRISTINE_INCOMPLETE"] = "尚未找到原始版本"
L["TOOLTIP_HISTORY_PRISTINE_ONQUEST"] = "已找到原始版本，但尚未提交"
L["TOOLTIP_HISTORY_PROGRESS_ACHI_COMPLETE"] = "已完成收藏家成就"
L["TOOLTIP_HISTORY_PROGRESS_ACHI_INCOMPLETE"] = "收藏家成就正在進行中："
L["TOOLTIP_HISTORY_PROGRESS_CURRENT"] = "目前可用於此種族"
L["TOOLTIP_HISTORY_PROGRESS_KNOWN"] = "已完成 |cFFDDDDDD"
L["TOOLTIP_HISTORY_PROGRESS_PLURAL"] = "次"
L["TOOLTIP_HISTORY_PROGRESS_SINGULAR"] = "次"
L["TOOLTIP_HISTORY_PROGRESS_UNKNOWN"] = "您尚未找到此神器"
L["TOOLTIP_KEYSTONES_LEFTCLICK"] = "左鍵點擊以應用鑰石"
L["TOOLTIP_KEYSTONES_RIGHTCLICK"] = "右鍵點擊以移除鑰石"
L["TOOLTIP_KEYSTONES_YOUHAVE"] = "您有"
L["TOOLTIP_KEYSTONES_YOUHAVE_INYOURBAGS"] = "在您的背包中"
L["TOOLTIP_KEYSTONES_YOUHAVE_INYOURBAGS_PLURAL"] = "個"
L["TOOLTIP_LEFTCLICK_SOLVE"] = "左鍵點擊以解決此神器"
L["TOOLTIP_MAIN_RELEVANCY_DISABLE"] = "顯示所有種族。|n|n|cFF00FF00右鍵點擊以打開設定並自訂相關性選項。|r"
L["TOOLTIP_MAIN_RELEVANCY_ENABLE"] = "僅顯示相關種族。|n|n|cFF00FF00右鍵點擊以打開設定並自訂相關性選項。|r"
L["TOOLTIP_NEW"] = "新的"
L["TOOLTIP_OPEN_DIGSITES"] = "打開挖掘點"
L["TOOLTIP_OPEN_HISTORY"] = "打開歷史記錄"
L["TOOLTIP_PROGRESS"] = "進度"
L["TOOLTIP_PROJECT"] = "項目"
L["TOOLTIP_RACE"] = "種族"
L["TOOLTIP_SOLVABLE"] = "可解決"
L["TOOLTIP_SURVEY_CANTCAST"] = "現在無法施放"
L["TOOLTIP_TAXIFRAME_TOGGLE_DIGSITE"] = "切換挖掘點"
L["TOOLTIP_WP_BUTTON_LEFTCLICK"] = "左鍵點擊以建立到最近的可用挖掘點的導航"
L["TOOLTIP_WP_BUTTON_RIGHTCLICK"] = "右鍵點擊以打開導航設定"

-- 自行加入
L["OPTIONS_REGISTER_MINARCH_TITLE"] = "考古小幫手"