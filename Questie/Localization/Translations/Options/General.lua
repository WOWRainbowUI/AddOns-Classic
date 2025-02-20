---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local generalOptionsLocales = {
    ["General"] = {
        ["ptBR"] = "Geral",
        ["ruRU"] = "Общее",
        ["deDE"] = "Allgemein",
        ["koKR"] = "일반",
        ["esMX"] = true,
        ["enUS"] = true,
        ["zhCN"] = "选项",
        ["zhTW"] = "一般",
        ["esES"] = true,
        ["frFR"] = "Général",
    },
    ["General Options"] = {
        ["ptBR"] = "Opções generais",
        ["ruRU"] = "Общие настройки",
        ["deDE"] = "Allgemeine Einstellungen",
        ["koKR"] = "일반 설정",
        ["esMX"] = "Opciones generales",
        ["enUS"] = true,
        ["zhCN"] = "Questie选项",
        ["zhTW"] = "一般選項",
        ["esES"] = "Opciones generales",
        ["frFR"] = "Options générales",
    },
    ["Enable Minimap Button"] = {
        ["ptBR"] = "Ativar botão do minimapa",
        ["ruRU"] = "Кнопка у миникарты",
        ["deDE"] = "Minimap-Button aktivieren",
        ["koKR"] = "미니맵 버튼 활성화",
        ["esMX"] = "Activar botón del minimapa",
        ["enUS"] = true,
        ["zhCN"] = "启用Questie的小地图按钮",
        ["zhTW"] = "啟用小地圖按鈕",
        ["esES"] = "Activar botón del minimapa",
        ["frFR"] = "Bouton de la minicarte",
    },
    ["Enable or disable the Questie minimap button. You can still access the options menu with /questie."] = {
        ["ptBR"] = "Ativa ou desativa o botão do minimapa da missão. Você ainda pode acessar o menu de opções com o comando /questie.",
        ["ruRU"] = "Показать/скрыть кнопку Questie у миникарты. Доступ к настройкам аддона также можно получить через команду '/questie'",
        ["deDE"] = "Questie Minimap-Button aktivieren/deaktivieren. Mit /questie kannst du trotzdem die Einstellungen aufrufen.",
        ["koKR"] = "Questie 미니맵 버튼을 사용합니다. /questie 명령어로도 설정 메뉴를 열 수 있습니다.",
        ["esMX"] = "Activa o desactiva el botón del minimapa. Puedes seguir accediendo al menú de opciones con el comando /questie.",
        ["enUS"] = true,
        ["zhCN"] = "启用小地图按钮；禁用后以 /questie 打开配置",
        ["zhTW"] = "啟用或停用任務位置提示的小地圖按鈕，停用後仍可輸入 /questie 開啟設定選項。",
        ["esES"] = "Activa o desactiva el botón del minimapa. Puedes seguir accediendo al menú de opciones con el comando /questie.",
        ["frFR"] = "Active le bouton de la minicarte. Le panneau de configuration reste accessible avec la commande /questie.",
    },
    ["Enable Instant Quest Text"] = {
        ["ptBR"] = "Ativar texto de missão instantâneo",
        ["ruRU"] = "Мгновенное отображение текста",
        ["deDE"] = "Questtext sofort anzeigen",
        ["koKR"] = "퀘스트 내용 바로 표시",
        ["esMX"] = "Activar texto de misión instantáneo",
        ["enUS"] = true,
        ["zhCN"] = "立即显示任务文本",
        ["zhTW"] = "啟用立即顯示任務內容",
        ["esES"] = "Activar texto de misión instantáneo",
        ["frFR"] = "Activer le texte des quêtes instantané",
    },
    ["Toggles the default Instant Quest Text option. This is just a shortcut for the WoW option in Interface."] = {
        ["ptBR"] = "Ativa ou desativa a opção de texto de missão instantâneo.",
        ["ruRU"] = "Включает мгновенное отображение полного текста заданий. Это всего лишь ярлык для стандартной опции в настройках интерфейса игры",
        ["deDE"] = "Die Standardeinstellung für 'Questtext sofort anzeigen' aktivieren/deaktivieren. Dies ist nur eine Abkürzung zum WoW-Interface-Menü.",
        ["koKR"] = "퀘스트 지문이 한번에 표시됩니다. 이 설정은 게임설정의 '퀘스트 내용 바로 표시'와 동일합니다.",
        ["esMX"] = "Activa o desactiva el texto de misión instantáneo.",
        ["enUS"] = true,
        ["zhCN"] = "使任务直接显示完整文本，这其实是一个暴雪原生自带的功能",
        ["zhTW"] = "啟用遊戲內建的立刻顯示任務內容選項，這只是方便調整魔獸介面設定中的選項的捷徑。",
        ["esES"] = "Activa o desactiva el texto de misión instantáneo.",
        ["frFR"] = "Active l’option de texte des quêtes instantané.",
    },
    ["Auto Accept Quests"] = {
        ["ptBR"] = "Aceitar missões",
        ["ruRU"] = "Вкл/выкл",
        ["deDE"] = "Quests automatisch annehmen",
        ["koKR"] = "자동 퀘스트 수락",
        ["esMX"] = "Aceptar misiones",
        ["enUS"] = true,
        ["zhCN"] = "自动接受任务",
        ["zhTW"] = "自動接受任務",
        ["esES"] = "Aceptar misiones",
        ["frFR"] = "Acceptation des quêtes",
    },
    ["Enable or disable Questie auto-accepting quests."] = {
        ["ptBR"] = "Ativa ou desativa as missões de aceitação automática de Questie.",
        ["ruRU"] = "Включить/отключить автоматическое принятие заданий",
        ["deDE"] = "Aktiviert/Deaktiviert, ob Questie Quests automatisch annimmt.",
        ["koKR"] = "퀘스티 자동 퀘스트 수락을 할지 말지 선택합니다.",
        ["esMX"] = "Activa o desactiva aceptar misiones automáticamente.",
        ["enUS"] = true,
        ["zhCN"] = "启用后和NPC对话，自动接受任务。",
        ["zhTW"] = "啟用或停用自動接受任務。",
        ["esES"] = "Activa o desactiva aceptar misiones automáticamente.",
        ["frFR"] = "Active l'acceptation automatique des quêtes par Questie.",
    },
    ["Auto Complete"] = {
        ["ptBR"] = "Conclusão automática",
        ["ruRU"] = "Автозавершение",
        ["deDE"] = "Quests automatisch abgeben",
        ["koKR"] = "자동 완료",
        ["esMX"] = "Completación automática",
        ["enUS"] = true,
        ["zhCN"] = "自动完成",
        ["zhTW"] = "自動交回任務",
        ["esES"] = "Completación automática",
        ["frFR"] = "Terminaison automatique",
    },
    ["Enable or disable Questie auto-completing quests."] = {
        ["ptBR"] = "Ativa ou desativa a conclusão automática de missões.",
        ["ruRU"] = "Включить/отключить автоматическое завершение выполненных заданий",
        ["deDE"] = "Aktiviert/Deaktiviert, ob Questie Quests automatisch abgibt.",
        ["koKR"] = "퀘스트 자동 퀘스트 완료를 할지 말지 선택합니다.",
        ["esMX"] = "Activa o desactiva la completación automática de misiones.",
        ["enUS"] = true,
        ["zhCN"] = "启用后和NPC交谈，自动完成。",
        ["zhTW"] = "啟用或停用完成任務並與指定任務 NPC 交談時，自動回報並完成任務。",
        ["esES"] = "Activa o desactiva la completación automática de misiones.",
        ["frFR"] = "Active la terminaison automatique des quêtes.",
    },
    ["Enable Automatic NPC Dialog"] = {
        ["ptBR"] = "Ativar diálogo do NPC automática",
        ["ruRU"] = "Автодиалог с NPC",
        ["deDE"] = "NPC-Dialoge automatisieren",
        ["koKR"] = "자동 NPC 대화 활성화",
        ["esMX"] = "Activar el diálogo automático de PNJ",
        ["enUS"] = true,
        ["zhCN"] = "自动执行NPC对话",
        ["zhTW"] = "啟用自動進行 NPC 對話",
        ["esES"] = "Activar el diálogo automático de PNJ",
        ["frFR"] = "Activation des dialogues PNJ automatiques",
    },
    ["Enable or disable Questie automatically advancing through NPC dialog."] = {
        ["ptBR"] = "Ativa ou desativa o Questie avançando automaticamente através da caixa de diálogo do NPC",
        ["ruRU"] = "Включить/отключить автоматическое ведение диалога с NPC",
        ["deDE"] = "Aktiviert/Deaktiviert, ob Questie Dialoge mit NPCs automatisch durchführt",
        ["koKR"] = "NPC 대화 상자를 통해 자동으로 진행 중인 Questie를 활성화 또는 비활성화합니다.",
        ["esMX"] = "Activa o desactiva que Questie avanza automáticamente a través del diálogo PNJ",
        ["enUS"] = true,
        ["zhCN"] = "启用或禁用Questie自动和NPC的对话框。",
        ["zhTW"] = "啟用或停用任務位置提示插件的自動與 NPC 進行對話功能。",
        ["esES"] = "Activa o desactiva que Questie avanza automáticamente a través del diálogo PNJ",
        ["frFR"] = "Active l'avancement automatique des dialogues PNJ par Questie.",
    },
    ["Auto Modifier"] = {
        ["ptBR"] = "Modificador auto",
        ["ruRU"] = "Авто-модификатор",
        ["deDE"] = "Auto Modifikator",
        ["koKR"] = "자동 수정",
        ["esMX"] = "Modificador auto",
        ["enUS"] = true,
        ["zhCN"] = "自动调整",
        ["zhTW"] = "自動輔助鍵",
        ["esES"] = "Modificador auto",
        ["frFR"] = "Modificateur auto",
    },
    ["The modifier to NOT auto-accept/-complete quests when either option is enabled and you interact with a quest NPC."] = {
        ["ptBR"] = "O modificador para NÃO aceitar ou concluir automaticamente missões quando uma das opções está ativada e você interage com um NPC de missões.",
        ["ruRU"] = "Клавиша, при зажатии которой автопринятие/автозавершение задания НЕ сработает при его принятии/завершении",
        ["deDE"] = "Die Taste, um Quests NICHT automatisch anzunehmen/abzugeben, wenn die jeweilige Einstellung aktiviert ist und mit einem Quest NPC interagiert wird.",
        ["koKR"] = "두 옵션 중 하나를 사용하고 사용자가 퀘스트 NPC와 상호 작용할 때 퀘스트를 자동 수락/완성하지 않음.",
        ["esMX"] = "El modificador para NO aceptar ni completar automáticamente las misiones cuando cualquiera de las opciones está activada e interactúas con un asignador de misiones.",
        ["enUS"] = true,
        ["zhCN"] = "当与NPC互动时，即便您已启用自动接受/自动完成，启用额外按键以触发对应功能.",
        ["zhTW"] = "與 NPC 互動時按住輔助鍵則 '不會' 自動接受/完成任務。",
        ["esES"] = "El modificador para NO aceptar ni completar automáticamente las misiones cuando cualquiera de las opciones está activada e interactúas con un asignador de misiones.",
        ["frFR"] = "Le modificateur pour NE PAS accepter ni terminer automatiquement une quête lorsque l'une de ces options est activée et que vous interagissez avec un PNJ de quête.",
    },
    ["Accept trivial (low level) quests"] = {
        ["ptBR"] = "Aceitar missões triviais (nível baixo)",
        ["ruRU"] = "Автопринятие низкоуровневых",
        ["deDE"] = "Triviale (niedrigstufige) Quests annehmen",
        ["koKR"] = "저레벨 퀘스트 수락",
        ["esMX"] = "Aceptar misiones triviales (de bajo nivel)",
        ["enUS"] = true,
        ["zhCN"] = "自动接受琐碎的（低等级）任务",
        ["zhTW"] = "接受不重要的 (低等級) 任務",
        ["esES"] = "Aceptar misiones triviales (de bajo nivel)",
        ["frFR"] = "Accepter les quêtes obsolètes (bas niveau)",
    },
    ["When this is enabled trivial (gray) quests will be auto accepted as well."] = {
        ["ptBR"] = "Se ativado, missões triviais (cinza) também serão aceitas automaticamente.",
        ["ruRU"] = "Включить/отключить автоматическое принятие заданий низкого уровня (серых)",
        ["deDE"] = "Aktiviert/Deaktiviert, ob Questie triviale (graune) Quests automatisch annimmt.",
        ["koKR"] = "이 옵션을 선택하면 저레벨(회색) 퀘스트도 자동으로 수락됩니다.",
        ["esMX"] = "Si está activado, las misiones triviales (grises) también se aceptarán automáticamente.",
        ["enUS"] = true,
        ["zhCN"] = "启用此功能后，低级（灰色）的任务也会被自动接受。",
        ["zhTW"] = "啟用時，也會自動接受不重要的 (灰色) 任務。",
        ["esES"] = "Si está activado, las misiones triviales (grises) también se aceptarán automáticamente.",
        ["frFR"] = "Étend l'acceptation automatique aux quêtes obsolètes (grises).",
    },
    ["Quest Level Options"] = {
        ["ptBR"] = "Opções de nível de missão",
        ["ruRU"] = "Настройки уровней заданий",
        ["deDE"] = "Questlevel-Einstellungen",
        ["koKR"] = "퀘스트 레벨 설정",
        ["esMX"] = "Opciones de nivel de misión",
        ["enUS"] = true,
        ["zhCN"] = "任务等级选项",
        ["zhTW"] = "任務等級選項",
        ["esES"] = "Opciones de nivel de misión",
        ["frFR"] = "Options du niveau des quêtes",
    },
    ["Player level offset"] = {
        ["ptBR"] = "Compensação de nível",
        ["ruRU"] = "Смещение уровня игрока",
        ["deDE"] = "Spielerlevelabstand",
        ["koKR"] = "플레이어 레벨 오프셋",
        ["esMX"] = "Compensación de nivel",
        ["enUS"] = true,
        ["zhCN"] = "与玩家等级的差距",
        ["zhTW"] = "與玩家等級的差距",
        ["esES"] = "Compensación de nivel",
        ["frFR"] = "Décalage de niveau",
    },
    ["Show only quests granting experience (Default)"] = {
        ["ptBR"] = "Mostrar apenas missões que concedem experiência (Padrão)",
        ["ruRU"] = "Задания, дающие опыт (по умолчанию)",
        ["deDE"] = "Zeige nur Quests an die Erfahrung gewähren (Standard)",
        ["koKR"] = "경험치를 주는 퀘스트만 표시 (기본값)",
        ["esMX"] = "Mostrar solo misiones que otorgan experiencia (Predeterminado)",
        ["enUS"] = true,
        ["zhCN"] = "仅显示授予经验的任务（默认）",
        ["zhTW"] = "只顯示能獲得經驗值的任務 (預設)",
        ["esES"] = "Mostrar solo misiones que otorgan experiencia (Predeterminado)",
        ["frFR"] = "Afficher uniquement les quêtes octroyant de l'expérience (Par défaut)",
    },
    ["Show all low level quests"] = {
        ["ptBR"] = "Mostrar todas as missões de baixo nível",
        ["ruRU"] = "Все задания",
        ["deDE"] = "Zeige alle niedrigstufigen Quests",
        ["koKR"] = "모든 저레벨 퀘스트 표시",
        ["esMX"] = "Mostrar todas las misiones de bajo nivel",
        ["enUS"] = true,
        ["zhCN"] = "显示所有低等级任务",
        ["zhTW"] = "顯示所有低等級任務",
        ["esES"] = "Mostrar todas las misiones de bajo nivel",
        ["frFR"] = "Afficher toutes les quêtes de bas niveau",
    },
    ["Show quests to a set level below the player"] = {
        ["ptBR"] = "Mostrar missões até um nível definido abaixo do jogador",
        ["ruRU"] = "Задания с уровнем ниже уровня игрока",
        ["deDE"] = "Zeige Quests bis zu einem einstellbaren Level unter dem Spieler",
        ["koKR"] = "플레이어보다 설정된 레벨 이하의 퀘스트 표시",
        ["esMX"] = "Mostrar misiones a un nivel establecido por debajo del jugador",
        ["enUS"] = true,
        ["zhCN"] = "显示低于玩家设定等级的任务",
        ["zhTW"] = "顯示低於玩家指定等級的任務",
        ["esES"] = "Mostrar misiones a un nivel establecido por debajo del jugador",
        ["frFR"] = "Afficher les quêtes à un niveau défini en dessous du joueur",
    },
    ["Show quests between two set levels"] = {
        ["ptBR"] = "Mostrar missões entre dois níveis definidos",
        ["ruRU"] = "Задания между двумя заданными уровнями",
        ["deDE"] = "Zeige Quests zwischen zwei einstellbaren Leveln",
        ["koKR"] = "설정된 두 레벨 사이의 퀘스트 표시",
        ["esMX"] = "Mostrar misiones entre dos niveles establecidos",
        ["enUS"] = true,
        ["zhCN"] = "显示两个设定等级之间的任务",
        ["zhTW"] = "顯示指定等級範圍的任務",
        ["esES"] = "Mostrar misiones entre dos niveles establecidos",
        ["frFR"] = "Afficher les quêtes entre deux niveaux définis",
    },
    ["Which available quests should be displayed"] = {
        ["ptBR"] = "Quais missões disponíveis devem ser mostradas",
        ["ruRU"] = "Отображение доступных заданий",
        ["deDE"] = "Welche verfügbaren Quests angezeigt werden sollen",
        ["koKR"] = "표시할 수 있는 퀘스트",
        ["esMX"] = "Qué misiones disponibles deberían mostrarse",
        ["enUS"] = true,
        ["zhCN"] = "哪些可用任务应显示",
        ["zhTW"] = "要顯示哪些可接的任務",
        ["esES"] = "Qué misiones disponibles deberían mostrarse",
        ["frFR"] = "Quelles quêtes disponibles doivent être affichées",
    },
    ["How many levels below your character to show. ( Default: %s )"] = {
        ["ptBR"] = "Quantos níveis sobre o seu personagem para exibir. (Padrão: %s)",
        ["ruRU"] = "Отображение заданий, у которых уровень ниже, чем ваш уровень, на выбранное значение (по умолчанию: %s)",
        ["deDE"] = "Quests bis X Level unter deinem eigenen anzeigen. (Standard: %s)",
        ["koKR"] = "현재 레벨보다 얼마나 낮은 퀘스트까지 표시할지 설정합니다. (기본값: %s)",
        ["esMX"] = "Cuantos niveles por debajo de tu personaje. (Predeterminado: %s)",
        ["enUS"] = true,
        ["zhCN"] = "显示比你低了多少级的任务（默认：%s）",
        ["zhTW"] = "要顯示低於你的角色多少等級以內的任務。(預設值: %s)",
        ["esES"] = "Cuantos niveles por debajo de tu personaje. (Predeterminado: %s)",
        ["frFR"] = "Définis l'écart maximal entre le niveau des quêtes et celui du joueur. (Par défaut : %s)",
    },
    ["Level from"] = {
        ["ptBR"] = "De Nível",
        ["ruRU"] = "Уровень от",
        ["deDE"] = "Level ab",
        ["koKR"] = "Level from",
        ["esMX"] = "De nivel",
        ["enUS"] = true,
        ["zhCN"] = "等级从",
        ["zhTW"] = "從等級",
        ["esES"] = "De nivel",
        ["frFR"] = "Du niveau :",
    },
    ["Minimum quest level to show."] = {
        ["ptBR"] = "Nível mínimo de missão para mostrar.",
        ["ruRU"] = "Минимальный уровень заданий для отображения",
        ["deDE"] = "Zeige Quests ab dem eingestellten Level.",
        ["koKR"] = "표시하는 최소 퀘스트 레벨",
        ["esMX"] = "Nivel mínimo de misión para mostrar.",
        ["enUS"] = true,
        ["zhCN"] = "显示最低任务等级。",
        ["zhTW"] = "要顯示的最低任務等級。",
        ["esES"] = "Nivel mínimo de misión para mostrar.",
        ["frFR"] = "Niveau minimum des quêtes à afficher.",
    },
    ["Level to"] = {
        ["ptBR"] = "Para Nível",
        ["ruRU"] = "Уровень до",
        ["deDE"] = "Level bis",
        ["koKR"] = "Level to",
        ["esMX"] = "A nivel",
        ["enUS"] = true,
        ["zhCN"] = "到等级",
        ["zhTW"] = "到等級",
        ["esES"] = "A nivel",
        ["frFR"] = "Au niveau :",
    },
    ["Maximum quest level to show."] = {
        ["ptBR"] = "Nível máximo de missões para mostrar.",
        ["ruRU"] = "Максимальный уровень заданий для отображения",
        ["deDE"] = "Zeige Quests bis zu dem eingestellten Level.",
        ["koKR"] = "표시하는 최고 퀘스트 레벨",
        ["esMX"] = "Máximo nivel de misión para mostrar.",
        ["enUS"] = true,
        ["zhCN"] = "显示最高任务等级",
        ["zhTW"] = "要顯示的最高任務等級。",
        ["esES"] = "Máximo nivel de misión para mostrar.",
        ["frFR"] = "Niveau maximum des quêtes à afficher.",
    },
    ["Objective icon cluster amount"] = {
        ["ptBR"] = "Quantidade de ícones de objetivos",
        ["ruRU"] = "Группировка значков",
        ["deDE"] = "Ziel-Icon-Cluster-Menge",
        ["koKR"] = "퀘스트 목표 아이콘 합치기",
        ["esMX"] = "Cantidad de objetivos a agrupar",
        ["enUS"] = true,
        ["zhCN"] = "目标图标聚集数量",
        ["zhTW"] = "目標圖示聚集數量",
        ["esES"] = "Cantidad de objetivos a agrupar",
        ["frFR"] = "Fusion des icônes des objectifs",
    },
    ["How much objective icons should cluster."] = {
        ["ptBR"] = "Quantos ícones de objetivos devem ser agrupados.",
        ["ruRU"] = "Установка количества значков целей, при котором значки будут группироваться",
        ["deDE"] = "Wie viele Ziel-Icons in einem Cluster gezeigt werden sollen.",
        ["koKR"] = "퀘스트 목표 아이콘을 몇개까지 합쳐서 보여줄지 설정합니다.",
        ["esMX"] = "Cuántos iconos de objetivo deberian agruparse.",
        ["enUS"] = true,
        ["zhCN"] = "应聚集多少个目标图标。",
        ["zhTW"] = "應聚集多少個目標圖示。",
        ["esES"] = "Cuántos iconos de objetivo deberian agruparse.",
        ["frFR"] = "Définis le nombre d'icônes des objectifs proches les unes des autres à fusionner.",
    },
    ["Isle of Quel'Danas Phase"] = {
        ["ptBR"] = "Fase da Ilha de Quel'Danas",
        ["ruRU"] = "Фаза Острова Кель'Данас",
        ["deDE"] = "Insel von Quel'Danas Phase",
        ["koKR"] = "쿠엘다나스 섬 단계",
        ["esMX"] = "Fase de Isla of Quel'Danas",
        ["enUS"] = true,
        ["zhCN"] = "奎尔丹纳斯岛阶段",
        ["zhTW"] = "奎爾達納斯島階段",
        ["esES"] = "Fase de Isla of Quel'Danas",
        ["frFR"] = "Phase de L'île de Quel'Danas",
    },
    ["Select the phase fitting your realm progress on the Isle of Quel'Danas"] = {
        ["ptBR"] = "Seleciona a fase correspondente ao progresso do seu reino na Ilha de Quel'Danas",
        ["ruRU"] = "Выбор фазы прогресса Острова Кель'Данас на вашем сервере",
        ["deDE"] = "Setz die Phase entsprechend des Fortschritts deines Servers",
        ["koKR"] = "쿠엘다나스 섬의 왕국 진행 상황에 맞는 단계를 선택하세요",
        ["esMX"] = "Selecciona la fase que se ajuste al progreso de tu reino en la Isla de Quel'Danas",
        ["enUS"] = true,
        ["zhCN"] = "选择适合你在奎尔丹纳斯岛上阶段的任务进度",
        ["zhTW"] = "選擇符合你的伺服器在奎爾達納斯島上的任務階段。",
        ["esES"] = "Selecciona la fase que se ajuste al progreso de tu reino en la Isla de Quel'Danas",
        ["frFR"] = "Choisissez la phase correspondante à votre serveur pour la progression sur l'Ile de Quel'Danas",
    },
    ["Disable Phase reminder"] = {
        ["ptBR"] = "Desativar lembrete de fase",
        ["ruRU"] = "Отключить напоминание",
        ["deDE"] = "Phasen Erinnerung deaktivieren",
        ["koKR"] = "단계 알림 비활성화",
        ["esMX"] = "Desactivar recordatorio de fase",
        ["enUS"] = true,
        ["zhCN"] = "禁用进度提醒",
        ["zhTW"] = "停用階段提醒",
        ["esES"] = "Desactivar recordatorio de fase",
        ["frFR"] = "Désactiver le rappel de phase.",
    },
    ["Enable or disable the reminder on login to set the Isle of Quel'Danas phase"] = {
        ["ptBR"] = "Ativa ou desativa o lembrete ao conectar para definir a fase da Ilha de Quel'Danas",
        ["ruRU"] = "Включить/отключить напоминание выбора фазы Острова Кель'Данас при входе в игру",
        ["deDE"] = "Aktiviert/Deaktiviert die Erinnerung beim Login die Phase für die Insel von Quel'Danas anzupassen",
        ["koKR"] = "로그인 시 쿠엘다나스 섬 단계를 설정하라는 알림을 활성화 또는 비활성화합니다.",
        ["esMX"] = "Activa o desactiva el recordatorio al iniciar sesión para configurar la fase de la Isla de Quel'Danas",
        ["enUS"] = true,
        ["zhCN"] = "启用或禁用来设置登录时提醒奎尔丹纳斯岛的进度阶段",
        ["zhTW"] = "啟用或停用登入時提醒奎爾達納斯島上的任務階段。",
        ["esES"] = "Activa o desactiva el recordatorio al iniciar sesión para configurar la fase de la Isla de Quel'Danas",
        ["frFR"] = "Activer ou désactiver le rappel du choix de la phase sur l'Ile de Quel'Danas à la connection.",
    },
    ["Current active phase of Isle of Quel'Danas is '%s'. Check the General settings to change the phase or disable this message."] = {
        ["ptBR"] = "A fase ativa atual da Ilha de Quel'Danas é '%s'. Verifique as configurações gerais para alterar a fase ou desativar esta mensagem.",
        ["ruRU"] = "Текущая фаза Острова Кель'Данас: '%s'. Для изменения фазы или для отключения этого сообщения проверьте настройки (вкладка 'Общее').",
        ["deDE"] = "Aktuell aktive Phase auf der Insel von Quel'Danas ist '%s'. Zum Ändern der Phase oder dieser Erinnerung schau in die Allgemein Einstellungen.",
        ["koKR"] = "현재 쿠엘다나스 섬의 활성 단계는 '%s'입니다. 일반 설정에서 단계를 변경하거나 이 메시지를 비활성화할 수 있습니다.",
        ["esMX"] = "La fase activa actual de la Isla de Quel'Danas es '%s'. Verifique la configuración general para cambiar la fase o desactivar este mensaje.",
        ["enUS"] = true,
        ["zhCN"] = "启用或禁用设置登录时提醒奎尔丹纳斯岛当前阶段是'%s'。检查常规设置来更改阶段或禁用此消息。",
        ["zhTW"] = "奎爾達納斯島現在的進度是 '%s'，可以在一般設定中更改階段或是停用此訊息。",
        ["esES"] = "La fase activa actual de la Isla de Quel'Danas es '%s'. Verifique la configuración general para cambiar la fase o desactivar este mensaje.",
        ["frFR"] = "La phase actuelle de l'Ile de Quel Danas est '%s'. Vérifiez vos paramètres généraux pour la changer la phase en cours ou désactiver ce message.",
    },
    ["You picked up a quest from '%s'. Automatically switching to this phase..."] = {
        ["ptBR"] = "Você pegou uma missão de '%s'. Alternando automaticamente para esta fase...",
        ["ruRU"] = "Вы приняли задание из '%s'. Автоматическое переключение на эту фазу...",
        ["deDE"] = "Du hast eine Quest aus '%s' angenommen. Es wird automatisch zu dieser Phase gewechselt...",
        ["koKR"] = "'%s'에서 퀘스트를 수락했습니다. 이 단계로 자동 전환 중...",
        ["esMX"] = "Elegiste una misión de '%s'. Cambiando automáticamente a esta fase...",
        ["enUS"] = true,
        ["zhCN"] = "你从'%s'那里接了一个任务，自动切换到这个阶段...",
        ["zhTW"] = "你和 '%s' 接了任務，自動切換到此階段...",
        ["esES"] = "Elegiste una misión de '%s'. Cambiando automáticamente a esta fase...",
        ["frFR"] = "Vous avez accepté la quête de ‘%s’. Changement automatique pour la phase …",
    },
    ["Phase 1 - Sun's Reach Sanctum"] = {
        ["ptBR"] = "Fase 1 - Sacrário Beirassol",
        ["ruRU"] = "Фаза 1 - Святилище Солнечного Края",
        ["deDE"] = "Phase 1 - Sanktum der Sonnenweiten",
        ["koKR"] = "1단계 - 태양의 요새 성소",
        ["esMX"] = "Fase 1 - Sagrario de Tramo del Sol",
        ["enUS"] = true,
        ["zhCN"] = "第 1 阶段 - 攻占阳湾圣殿",
        ["zhTW"] = "階段 1 - 攻佔太陽海灣聖殿",
        ["esES"] = "Fase 1 - Sagrario de Tramo del Sol",
        ["frFR"] = "Phase 1 - Sanctum des confins du soleil",
    },
    ["Phase 2 - Activating the Sunwell Portal"] = {
        ["ptBR"] = "Fase 2 - Ativando o Portal para a Nascente do Sol",
        ["ruRU"] = "Фаза 2 - Портал в Шаттрате",
        ["deDE"] = "Phase 2 - Portal zur Insel von Quel'Danas",
        ["koKR"] = "2단계 - 태양샘 차원문 활성화",
        ["esMX"] = "Fase 2 - Activar el Portal de La Fuente del Sol",
        ["enUS"] = true,
        ["zhCN"] = "第 2 阶段 - 激活太阳之井大门",
        ["zhTW"] = "階段 2 - 啟動太陽之井傳送門",
        ["esES"] = "Fase 2 - Activar el Portal de La Fuente del Sol",
        ["frFR"] = "Phase 2 - Activer le portail du Puit du soleil",
    },
    ["Phase 2.1 - Sun's Reach Armory"] = {
        ["ptBR"] = "Fase 2.1 - Armaria de Beirassol",
        ["ruRU"] = "Фаза 2.1 - Оружейная",
        ["deDE"] = "Phase 2.1 - Waffenkammer der Sonnenweiten",
        ["koKR"] = "2.1단계 - 태양의 요새 무기고",
        ["esMX"] = "Fase 2.1 - Arsenal de Tramo del Sol",
        ["enUS"] = true,
        ["zhCN"] = "第 2.1 阶段 - 攻占阳湾军械库",
        ["zhTW"] = "階段 2.1 - 攻佔太陽海灣軍械庫",
        ["esES"] = "Fase 2.1 - Arsenal de Tramo del Sol",
        ["frFR"] = "Phase 2.1 - Armurerie des confins du soleil",
    },
    ["Phase 3 - Rebuilding the Anvil and Forge"] = {
        ["ptBR"] = "Fase 3 - Reconstruindo a Bigorna e a Forja",
        ["ruRU"] = "Фаза 3 - Наковальня и кузница",
        ["deDE"] = "Phase 3 - Schmiede und Amboss",
        ["koKR"] = "3단계 - 모루와 제련소 재건",
        ["esMX"] = "Fase 3 - Reconstruyendo el Yunque y la Forja",
        ["enUS"] = true,
        ["zhCN"] = "第 3 阶段 - 重建鐵砧和熔爐",
        ["zhTW"] = "階段 3 - 重建鐵砧和熔爐",
        ["esES"] = "Fase 3 - Reconstruyendo el Yunque y la Forja",
        ["frFR"] = "Phase 3 - Rebâtir la forge et l'enclume",
    },
    ["Phase 3.1 - Sun's Reach Harbor"] = {
        ["ptBR"] = "Fase 3.1 - Porto de Beirassol",
        ["ruRU"] = "Фаза 3.1 - Гавань Солнечного Края",
        ["deDE"] = "Phase 3.1 - Hafen der Sonnenweiten",
        ["koKR"] = "3.1단계 - 태양의 요새 항구",
        ["esMX"] = "Fase 3.1 - Puerto de Tramo del Sol",
        ["enUS"] = true,
        ["zhCN"] = "第 3.1 阶段 - 攻占阳湾港口",
        ["zhTW"] = "階段 3.1 - 攻佔太陽海灣港口",
        ["esES"] = "Fase 3.1 - Puerto de Tramo del Sol",
        ["frFR"] = "Phase 3.1 - Port des confins du soleil ",
    },
    ["Phase 4 - Creating the Alchemy Lab"] = {
        ["ptBR"] = "Fase 4 - Criando o Laboratório de Alquimia",
        ["ruRU"] = "Фаза 4 - Лаборатория",
        ["deDE"] = "Phase 4 - Alchemielabor",
        ["koKR"] = "4단계 - 연금술 연구소 건설",
        ["esMX"] = "Fase 4 - Crear el laboratorio de alquimia",
        ["enUS"] = true,
        ["zhCN"] = "第 4 阶段 - 建设炼金实验室",
        ["zhTW"] = "階段 4 - 建設煉金實驗室",
        ["esES"] = "Fase 4 - Crear el laboratorio de alquimia",
        ["frFR"] = "Phase 4 - Créer le laboratoire d'alchimie",
    },
    ["Phase 4.1 - Building the Monument to the Fallen"] = {
        ["ptBR"] = "Fase 4.1 - Construindo o Monumento aos Caídos",
        ["ruRU"] = "Фаза 4.1 - Монумент Павшим",
        ["deDE"] = "Phase 4.1 - Monument für die Gefallenen",
        ["koKR"] = "4.1단계 - 전몰자 기념비 건설",
        ["esMX"] = "Fase 4.1 - Construcción del Monumento a los Caídos",
        ["enUS"] = true,
        ["zhCN"] = "第 4.1 阶段 - 为阵亡者建造纪念碑",
        ["zhTW"] = "階段 4.1 - 為陣亡者建造紀念碑",
        ["esES"] = "Fase 4.1 - Construcción del Monumento a los Caídos",
        ["frFR"] = "Phase 4.1 - Construire le monument aux morts",
    },
    ["Phase 4.2 - Sun's Reach"] = {
        ["ptBR"] = "Fase 4.2 - Beirassol",
        ["ruRU"] = "Фаза 4.2 - Солнечный Край",
        ["deDE"] = "Phase 4.2 - Sonnenweiten",
        ["koKR"] = "4.2단계 - 태양의 요새",
        ["esMX"] = "Fase 4.2 - Tramo del Sol",
        ["enUS"] = true,
        ["zhCN"] = "第 4.2 阶段 - 破碎残阳的延伸",
        ["zhTW"] = "階段 4.2 - 破碎殘陽的延伸",
        ["esES"] = "Fase 4.2 - Tramo del Sol",
        ["frFR"] = "Phase 4.2 - Confins du soleil",
    },
    ["Phase 5"] = {
        ["ptBR"] = "Fase 5",
        ["ruRU"] = "Фаза 5",
        ["deDE"] = true,
        ["koKR"] = "5 단계",
        ["esMX"] = "Fase 5",
        ["enUS"] = true,
        ["zhCN"] = "第 5 阶段",
        ["zhTW"] = "階段 5",
        ["esES"] = "Fase 5",
        ["frFR"] = true,
    },
    ["Interface Options"] = {
        ["ptBR"] = "Opções de interface",
        ["ruRU"] = "Опции интерфейса",
        ["deDE"] = "Interface-Einstellungen",
        ["koKR"] = "인터페이스 옵션",
        ["esMX"] = "Opciones de interfaz",
        ["enUS"] = true,
        ["zhCN"] = "界面选项",
        ["zhTW"] = "介面選項",
        ["esES"] = "Opciones de interfaz",
        ["frFR"] = "Options de l'interface",
    },
    ["Sound Options"] = {
        ["ptBR"] = "Opções de som",
        ["ruRU"] = "Настройки звука",
        ["deDE"] = "Sound-Einstellungen",
        ["koKR"] = "사운드 옵션",
        ["esMX"] = "Opciones de sonido",
        ["enUS"] = true,
        ["zhCN"] = "声音选项",
        ["zhTW"] = "聲音選項",
        ["esES"] = "Opciones de sonido",
        ["frFR"] = "Options sonores",
    },
    ["By default, Questie only shows quests that are relevant for your level. You can change this behavior below."] = {
        ["ptBR"] = "Por padrão, o Questie só mostra missões relevantes para o seu nível. Você pode alterar esse comportamento abaixo.",
        ["ruRU"] = "По умолчанию Questie отображает задания, соответствующие вашему уровню. Это можно изменить ниже",
        ["deDE"] = "Standardmäßig zeigt Questie nur Quests an, die für dein Level relevant sind. Du kannst dieses Verhalten unten ändern.",
        ["koKR"] = "기본적으로 Questie는 레벨에 맞는 퀘스트만 표시합니다. 아래에서 이 동작을 변경할 수 있습니다.",
        ["esMX"] = "De forma predeterminada, Questie solo muestra misiones que son relevantes para tu nivel. Puedes cambiar este comportamiento a continuación.",
        ["enUS"] = true,
        ["zhCN"] = "默认只显示与你当前等级相符的任务，可在下方更改。",
        ["zhTW"] = "預設只會顯示與你等級相當的任務，可以在下方更改。",
        ["esES"] = "De forma predeterminada, Questie solo muestra misiones que son relevantes para tu nivel. Puedes cambiar este comportamiento a continuación.",
        ["frFR"] = "Par défaut, Questie n'affiche que les quêtes pertinentes pour votre niveau. Vous pouvez modifier ce comportement ci-dessous.",
    },
    ["Show quest level in tooltips"] = {
        ["ptBR"] = "Mostrar o nível da missão nas dicas de ferramentas",
        ["ruRU"] = "Уровень заданий в подсказках",
        ["deDE"] = "Questlevel in Tooltips aktivieren",
        ["koKR"] = "툴팁에 퀘스트 레벨 표시",
        ["esMX"] = "Mostrar nivel de misión en tooltips",
        ["enUS"] = true,
        ["zhCN"] = "在悬浮窗中显示任务等级",
        ["zhTW"] = "在浮動提示資訊中顯示任務等級",
        ["esES"] = "Mostrar nivel de misión en tooltips",
        ["frFR"] = "Niveau des quêtes dans les infobulles",
    },
    ["When this is checked, the level of quests will show in the tooltips."] = {
        ["ptBR"] = "Se ativado, o nível das missões será mostrado nas dicas de ferramentas.",
        ["ruRU"] = "Показать/скрыть уровень заданий во всплывающих подсказках",
        ["deDE"] = "Aktiviert/Deaktiviert, ob das Questlevel in den Tooltips angezeigt wird.",
        ["koKR"] = "툴팁에 퀘스트의 레벨을 표시합니다.",
        ["esMX"] = "Si está activado, el nivel de las misiones se mostrará en los tooltips.",
        ["enUS"] = true,
        ["zhCN"] = "启用后，任务等级将显示在悬浮窗提示中",
        ["zhTW"] = "啟用時，浮動提示資訊中會顯示任務的等級。",
        ["esES"] = "Si está activado, el nivel de las misiones se mostrará en los tooltips.",
        ["frFR"] = "Active l'affichage du niveau des quêtes dans les infobulles.",
    },
    ["Enable World Tooltips"] = {
        ["ptBR"] = "Ativar dicas do mundo",
        ["ruRU"] = "Информация о заданиях",
        ["deDE"] = "Welt-Tooltips aktivieren",
        ["koKR"] = "세계 툴팁 활성화",
        ["esMX"] = "Activar tooltips del mundo",
        ["enUS"] = true,
        ["zhCN"] = "启用世界悬浮窗",
        ["zhTW"] = "啟用世界浮動提示資訊",
        ["esES"] = "Activar tooltips del mundo",
        ["frFR"] = "Activer les infobulles mondiales",
    },
    ["When this is enabled, quest info will be added to relevant mob/item tooltips."] = {
        ["ptBR"] = "Se ativado, as informações da missão serão adicionadas às dicas relevantes de mob/item.",
        ["ruRU"] = "Показать/скрыть информацию о заданиях в соответствующих всплывающих подсказках",
        ["deDE"] = "Aktiviert/Deaktiviert zusätzliche Informationen zu Gegnern und Gegenständen als Tooltip.",
        ["koKR"] = "몬스터와 아이템의 툴팁에 관련된 퀘스트 정보를 표시합니다.",
        ["esMX"] = "Si está activado, la información de la mision se mostrará en el tooltip de los monstruos/objetos relevantes.",
        ["enUS"] = true,
        ["zhCN"] = "当启用此项时，任务信息将被添加到相关的怪物/物品工具提示中。",
        ["zhTW"] = "當啟用此項時，任務資訊將會加入到相關的怪物/物品浮動提示中。",
        ["esES"] = "Si está activado, la información de la mision se mostrará en el tooltip de los monstruos/objetos relevantes.",
        ["frFR"] = "Active l'affichage des informations de quête dans les infobulles des monstres et des objets.",
    },
}

for k, v in pairs(generalOptionsLocales) do
    l10n.translations[k] = v
end
