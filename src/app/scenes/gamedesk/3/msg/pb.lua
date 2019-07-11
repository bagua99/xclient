return {["buf"]="\
Ü\14\
\
dgnn.proto\18\4dgnn\";\
\
RoomOption\18\11\
\3key\24\1 \1(\9\18\14\
\6nValue\24\2 \1(\5\18\16\
\8strValue\24\3 \1(\9\"-\
\8RoomInfo\18!\
\7options\24\1 \3(\0112\16.dgnn.RoomOption\"š\2\
\12UserGameData\18\14\
\6userid\24\1 \2(\4\18\16\
\8nickname\24\2 \2(\9\18\11\
\3sex\24\3 \2(\5\18\18\
\
headimgurl\24\4 \2(\9\18\13\
\5score\24\5 \2(\5\18\
\
\2ip\24\6 \2(\9\18\12\
\4seat\24\7 \2(\5\18\13\
\5ready\24\8 \2(\8\18\17\
\9callscore\24\9 \1(\5\18\15\
\7suanniu\24\
 \2(\8\18\13\
\5cards\24\11 \3(\5\18\12\
\4type\24\12 \2(\5\18\16\
\8latitude\24\13 \2(\9\18\17\
\9longitude\24\14 \2(\9\18\12\
\4adds\24\15 \2(\9\18\14\
\6online\24\16 \2(\8\18\11\
\3out\24\17 \2(\8\";\
\19GAME_PlayerEnterAck\18$\
\8userData\24\1 \2(\0112\18.dgnn.UserGameData\"$\
\19GAME_PlayerLeaveAck\18\13\
\5nSeat\24\1 \2(\5\"c\
\17GAME_EnterGameAck\18\11\
\3err\24\1 \2(\5\18#\
\7players\24\2 \3(\0112\18.dgnn.UserGameData\18\28\
\4room\24\3 \2(\0112\14.dgnn.RoomInfo\"/\
\
VoteResult\18\13\
\5nSeat\24\1 \2(\5\18\18\
\
nVoteState\24\2 \2(\5\"ú\1\
\17GAME_GameSceneAck\18\11\
\3err\24\1 \2(\5\18\28\
\4room\24\2 \2(\0112\14.dgnn.RoomInfo\18\14\
\6status\24\3 \2(\9\18#\
\7players\24\4 \3(\0112\18.dgnn.UserGameData\18\17\
\9bank_seat\24\5 \2(\5\18\18\
\
bank_score\24\6 \2(\5\18\20\
\12nDissoveSeat\24\7 \2(\5\18\20\
\12nDissoveTime\24\8 \2(\5\18\30\
\4vote\24\9 \3(\0112\16.dgnn.VoteResult\18\18\
\
bank_count\24\
 \2(\5\"\31\
\13GAME_ReadyReq\18\14\
\6bAgree\24\1 \2(\8\"1\
\13GAME_ReadyAck\18\16\
\8wChairID\24\1 \2(\5\18\14\
\6bAgree\24\2 \2(\8\"\16\
\14GAME_XiaZhuang\"\15\
\13GAME_BeginReq\"\19\
\17GAME_GameStartAck\"(\
\17GAME_CallScoreReq\18\19\
\11nScoreIndex\24\1 \2(\5\"\\\
\17GAME_CallScoreAck\18\22\
\14nCallScoreUser\24\1 \2(\5\18\18\
\
nCallScore\24\2 \2(\5\18\13\
\5cards\24\3 \3(\5\18\12\
\4type\24\4 \1(\5\"r\
\18GAME_GameEndPlayer\18\12\
\4seat\24\1 \2(\5\18\13\
\5score\24\2 \2(\5\18\19\
\11total_score\24\3 \2(\3\18\13\
\5cards\24\4 \3(\5\18\12\
\4type\24\5 \2(\5\18\13\
\5stake\24\6 \2(\5\"b\
\15GAME_GameEndAck\18'\
\5infos\24\1 \3(\0112\24.dgnn.GAME_GameEndPlayer\18\18\
\
bank_score\24\2 \2(\5\18\18\
\
bank_count\24\3 \2(\5\"P\
\21GAME_GameXiaZhuangAck\18\26\
\18old_bank_user_seat\24\1 \2(\5\18\27\
\19old_bank_user_score\24\2 \2(\5\"^\
\23GAME_GameShangZhuangAck\18\18\
\
bank_score\24\1 \2(\5\18\22\
\14bank_user_seat\24\2 \2(\5\18\23\
\15bank_user_score\24\3 \2(\5\"O\
\23GAME_GameTotalEndPlayer\18\12\
\4seat\24\1 \2(\5\18\19\
\11total_count\24\2 \2(\3\18\17\
\9niu_array\24\3 \3(\5\"D\
\20GAME_GameTotalEndAck\18,\
\5infos\24\1 \3(\0112\29.dgnn.GAME_GameTotalEndPlayer\"\26\
\24GAME_GameSuanNiuBeginAck\"\21\
\19GAME_GameSuanNiuReq\"@\
\19GAME_GameSuanNiuAck\18\12\
\4seat\24\1 \2(\5\18\13\
\5cards\24\2 \3(\5\18\12\
\4type\24\3 \2(\5\"\31\
\15GAME_GameOutAck\18\12\
\4seat\24\1 \2(\5",}