MailLogger：
1.0.0 测试版本
1.0.1 清空信息同时关闭窗口
1.0.3 找回了迷路的FormatMessage函數
1.0.4 新增几个按钮
1.0.5 添加小地图图标（其实是假的！并没有和小地图绑定）
1.0.6 优化代码
1.0.7 找回阻止恶意交易功能
1.0.8 阻止交易功能现在默认关闭，shift+左键重置小地图按钮位置，shift+右键重置Log窗口位置
1.0.9 添加小地图按钮Tips
1.1.0/9.1.0 修复错误阻止公会同僚交易的错误
1.1.1/9.1.1 增加可编辑物品忽略列表，处于忽略列表的物品将不会被通报和记录
1.1.2/9.1.2 小地圖按鈕現在只能在小地圖周圍移動了
1.1.3/9.1.3 让小地图按钮可以被收纳
1.1.4/9.1.4 修复翻译错误
1.1.5/9.1.5 因为很多人反映容易点错，把Log输出窗口的“清空记录”改成了“全部”
1.1.6/9.1.6 ESC关闭Log输出窗口，解决了包满了后错误记录未取出的邮件物品的错误
1.1.7/9.1.7 调整“全部”和“关闭”按钮位置，解决输出界面Scroll Bar闪烁问题
1.1.8/9.1.8 鼠标放在窗口上时才能ESC关闭窗口，鼠标不在窗口时不影响施法和移动
1.1.9/9.1.9 只有45秒内提取的邮件物品才会被合并到同一邮件中，超时的将被拆分
1.2.0/9.2.0 删除Debug信息……
1.2.1/9.2.1 每个邮件的时间以最后记录的物品时间为准
1.2.2/9.2.2 战斗中禁用输出窗口编辑
1.2.3/9.2.3 解决了和Spy冲突的问题，战斗中禁止移动窗口
1.2.4/9.2.4 预防性修复可能的冲突
1.2.5 增加角色筛选
1.2.6 优化角色筛选（不再需要Reload）
1.2.7 新增日历筛选模式
1.2.8 修复个位数日期错误
1.2.9 修复空表错误
1.3.0 新增日历开关
1.3.1 继续修复空表错误
1.3.2 修复错误
1.3.3 修复收件金额错误，优化收件同类物品存储逻辑，现在同类物品会被合并
1.3.4 修复交易数据清理工具的一个bug，增加寄件同类物品合并逻辑
1.3.5 添加对TitanPanel的支持
1.3.6 添加对正式服TitanPanel的支持
1.3.7 修复一个包满导致的错误
1.3.8 优化代码和判断，降低占用，修复LDB对象错误
1.3.9 修改统计重复物品方法，避免包满回退错误
1.3.10 修复一个罕见bug
1.4.0 解决未安装Titan Panel时小地图按钮问题
1.4.1 不再记录竞技场和战场中的交易内容，也不会密语
1.4.2(ERA) 尝试解决60怀旧跨服交易密语名称不正确的问题
1.4.3 解决跨服交易通报目标不正确的问题
1.4.4 解决部分翻译错误
1.4.6 Fix nil var error.
1.4.7 Fix misspelling.
1.4.8 Remove prevent trade function.
1.4.9 Update TOC, and Remove 'Prevent Trade' GUI and Checkbox. 
1.4.9new Update TOC
1.5.1 new toc system, and fix instance_chat error.
1.5.2 fix global variables error (maybe).
1.5.4 Support CATA version.
1.5.6 Fix checkbox bugs, and re-build setting interface.
2.0.1 Fix setting error, Added two-step authentication for "Delete data".
2.0.4 Optimized the interface, the confirmation buttons 'Y' and 'N' will disappear automatically after 5 seconds.
2.0.5 Fix the error in the addon that deletes records that include both giving and receiving items.
2.0.6 Mails received using Shift are now recorded as expected. Characters with the same name on different servers will no longer be confused with each other.
2.0.7 Fix the issue where MinimapIcon can't save its position when using the LDBIcon library, and add functionality to sort by both character and date.
2.0.8 Fix line command errors.
2.0.9 I forgot what I did
2.1.1 Fix a old 'no records' error.
2.1.2 Fix data form error in function 'find'.