return {["buf"]="\
™\26\
\
yzbp.proto\18\4yzbp\"–\2\
\12UserGameData\18\22\
\6userid\24\1 \2(\4R\6userid\18\26\
\8nickname\24\2 \2(\9R\8nickname\18\16\
\3sex\24\3 \2(\5R\3sex\18\30\
\
headimgurl\24\4 \2(\9R\
headimgurl\18\20\
\5score\24\5 \2(\5R\5score\18\14\
\2ip\24\6 \2(\9R\2ip\18\18\
\4seat\24\7 \2(\5R\4seat\18\24\
\7offline\24\8 \2(\8R\7offline\18\26\
\8latitude\24\9 \2(\9R\8latitude\18\28\
\9longitude\24\
 \2(\9R\9longitude\18\18\
\4adds\24\11 \2(\9R\4adds\"R\
\
RoomOption\18\16\
\3key\24\1 \1(\9R\3key\18\22\
\6nValue\24\2 \1(\5R\6nValue\18\26\
\8strValue\24\3 \1(\9R\8strValue\"6\
\8RoomInfo\18*\
\7options\24\1 \3(\0112\16.yzbp.RoomOptionR\7options\"E\
\19GAME_PlayerEnterAck\18.\
\8userData\24\1 \2(\0112\18.yzbp.UserGameDataR\8userData\"+\
\19GAME_PlayerLeaveAck\18\20\
\5nSeat\24\1 \2(\5R\5nSeat\"w\
\17GAME_EnterGameAck\18\16\
\3err\24\1 \2(\5R\3err\18,\
\7players\24\2 \3(\0112\18.yzbp.UserGameDataR\7players\18\"\
\4room\24\3 \2(\0112\14.yzbp.RoomInfoR\4room\"B\
\
VoteResult\18\20\
\5nSeat\24\1 \2(\5R\5nSeat\18\30\
\
nVoteState\24\2 \2(\5R\
nVoteState\"(\
\8CardData\18\28\
\9nCardData\24\1 \3(\5R\9nCardData\"á\4\
\17GAME_GameSceneAck\18 \
\11nGameStatus\24\1 \2(\5R\11nGameStatus\18\30\
\
nCellScore\24\2 \2(\5R\
nCellScore\18\"\
\12nDissoveSeat\24\3 \2(\5R\12nDissoveSeat\18\"\
\12nDissoveTime\24\4 \2(\5R\12nDissoveTime\18$\
\4vote\24\5 \3(\0112\16.yzbp.VoteResultR\4vote\18\30\
\
nGameScore\24\6 \3(\5R\
nGameScore\18\30\
\
nGameCount\24\7 \2(\5R\
nGameCount\18(\
\15nTotalGameCount\24\8 \2(\5R\15nTotalGameCount\18\22\
\6bReady\24\9 \3(\8R\6bReady\18 \
\11nBankerSeat\24\
 \2(\5R\11nBankerSeat\18\"\
\12nCurrentSeat\24\11 \2(\5R\12nCurrentSeat\18\28\
\9nCardData\24\12 \3(\5R\9nCardData\0182\
\12nOutCardData\24\13 \3(\0112\14.yzbp.CardDataR\12nOutCardData\18\30\
\
nCallScore\24\14 \2(\5R\
nCallScore\18\28\
\9nMainCard\24\15 \2(\5R\9nMainCard\18\30\
\
nPickScore\24\16 \2(\5R\
nPickScore\18$\
\13surrenderVote\24\17 \3(\8R\13surrenderVote\"'\
\13GAME_ReadyReq\18\22\
\6bReady\24\1 \2(\8R\6bReady\"=\
\13GAME_ReadyAck\18\20\
\5nSeat\24\1 \2(\5R\5nSeat\18\22\
\6bReady\24\2 \2(\8R\6bReady\"U\
\17GAME_GameStartAck\18\"\
\12nCurrentSeat\24\1 \2(\5R\12nCurrentSeat\18\28\
\9nCardData\24\2 \3(\5R\9nCardData\"3\
\17GAME_CallScoreReq\18\30\
\
nCallScore\24\1 \2(\5R\
nCallScore\"Å\1\
\17GAME_CallScoreAck\18\"\
\12nCurrentSeat\24\1 \2(\5R\12nCurrentSeat\18\30\
\
nCallScore\24\2 \2(\5R\
nCallScore\18&\
\14nNextCallScore\24\3 \2(\5R\14nNextCallScore\18 \
\11nBankerSeat\24\4 \2(\5R\11nBankerSeat\18\"\
\12nBankerScore\24\5 \2(\5R\12nBankerScore\"0\
\16GAME_MainCardReq\18\28\
\9nCardData\24\1 \2(\5R\9nCardData\"T\
\16GAME_MainCardAck\18\"\
\12nCurrentSeat\24\1 \2(\5R\12nCurrentSeat\18\28\
\9nCardData\24\2 \2(\5R\9nCardData\"X\
\20GAME_SendBackCardAck\18\"\
\12nCurrentSeat\24\1 \2(\5R\12nCurrentSeat\18\28\
\9nCardData\24\2 \3(\5R\9nCardData\"0\
\16GAME_BuryCardReq\18\28\
\9nCardData\24\1 \3(\5R\9nCardData\"T\
\16GAME_BuryCardAck\18\"\
\12nCurrentSeat\24\1 \2(\5R\12nCurrentSeat\18\28\
\9nCardData\24\2 \3(\5R\9nCardData\"\19\
\17GAME_SurrenderReq\"7\
\17GAME_SurrenderAck\18\"\
\12nCurrentSeat\24\1 \2(\5R\12nCurrentSeat\"S\
\21GAME_SurrenderVoteReq\18\"\
\12nCurrentSeat\24\1 \2(\5R\12nCurrentSeat\18\22\
\6bAgree\24\2 \2(\8R\6bAgree\"S\
\21GAME_SurrenderVoteAck\18\"\
\12nCurrentSeat\24\1 \2(\5R\12nCurrentSeat\18\22\
\6bAgree\24\2 \2(\8R\6bAgree\"A\
\27GAME_SurrenderVoteResultAck\18\"\
\12nCurrentSeat\24\1 \2(\5R\12nCurrentSeat\"/\
\15GAME_OutCardReq\18\28\
\9nCardData\24\1 \3(\5R\9nCardData\"Á\1\
\15GAME_OutCardAck\18\"\
\12nCurrentSeat\24\1 \2(\5R\12nCurrentSeat\18\"\
\12nOutCardSeat\24\2 \2(\5R\12nOutCardSeat\18\28\
\9nCardData\24\3 \3(\5R\9nCardData\18\20\
\5nType\24\4 \2(\5R\5nType\18\22\
\6nScore\24\5 \2(\5R\6nScore\18\26\
\8nBigSeat\24\6 \2(\5R\8nBigSeat\"b\
\20GAME_BuckleBottomAck\18\28\
\9nCardData\24\1 \3(\5R\9nCardData\18\22\
\6nScore\24\2 \2(\5R\6nScore\18\20\
\5nBase\24\3 \2(\5R\5nBase\",\
\14GAME_PromptAck\18\26\
\8szPrompt\24\1 \2(\9R\8szPrompt\"ó\1\
\15GAME_GameEndAck\18\30\
\
nGameScore\24\1 \3(\5R\
nGameScore\18 \
\11nTotalScore\24\2 \3(\5R\11nTotalScore\18 \
\11nBankerSeat\24\3 \2(\5R\11nBankerSeat\18\28\
\9nMainCard\24\4 \2(\5R\9nMainCard\18\30\
\
nCallScore\24\5 \2(\5R\
nCallScore\18\30\
\
nPickScore\24\6 \2(\5R\
nPickScore\18\30\
\
bSurrender\24\7 \2(\8R\
bSurrender\"Â\1\
\20GAME_GameTotalEndAck\18 \
\11nTotalScore\24\1 \3(\5R\11nTotalScore\18\"\
\12nBankerCount\24\2 \3(\5R\12nBankerCount\18\28\
\9nMaxScore\24\3 \3(\5R\9nMaxScore\18(\
\15nMaxBankerScore\24\4 \3(\5R\15nMaxBankerScore\18\28\
\9nWinCount\24\5 \3(\5R\9nWinCount",}