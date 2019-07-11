-------------事件优先级--------------------
TOUCHPRIORITY_ALL = -999   --最低优先级，阻断一切点击


-------------时间----------------
TIME_NET_SHOWARN = 1.5  --多少时间之后显示提示框


---------全局child的order和tag值，这个两个值全局对象会设置为相同的--------
ZORDER_LOCKLAYER = 9999   --锁屏layer的优先级，锁屏layer一般用于发送消息在收到回的消息锁闭屏幕


-----是否已经获取了人物图片
HEADIMG_HS = false


-----所有的场景
SCENE_LOGIN = 1
SCENE_LOBBY = 2


--不同游戏的游戏状态
--HM
GS_GAME_FREE = 0
GS_GAME_PLAY = 1
GS_GAME_VOTE = 2
GS_GAME_END = 3


MYDEF_FONT = "MYDEF_FONT"