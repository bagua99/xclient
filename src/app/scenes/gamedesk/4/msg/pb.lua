return {["buf"]="\
È\18\
\11nxphz.proto\18\5nxphz\"¾\1\
\12UserGameData\18\14\
\6userid\24\1 \2(\4\18\16\
\8nickname\24\2 \2(\9\18\11\
\3sex\24\3 \2(\5\18\18\
\
headimgurl\24\4 \2(\9\18\13\
\5score\24\5 \2(\5\18\
\
\2ip\24\6 \2(\9\18\12\
\4seat\24\7 \2(\5\18\15\
\7offline\24\8 \2(\8\18\16\
\8latitude\24\9 \2(\9\18\17\
\9longitude\24\
 \2(\9\18\12\
\4adds\24\11 \2(\9\"\29\
\8CardData\18\17\
\9tCardData\24\1 \3(\5\"I\
\11WeaveOption\18\18\
\
nWeaveKind\24\1 \2(\5\18\19\
\11nCenterCard\24\2 \2(\5\18\17\
\9tCardData\24\3 \3(\5\"0\
\9WeaveInfo\18#\
\7options\24\1 \3(\0112\18.nxphz.WeaveOption\"*\
\11HuPaiOption\18\11\
\3key\24\1 \1(\9\18\14\
\6nValue\24\2 \1(\5\"0\
\9HuPaiInfo\18#\
\7options\24\1 \3(\0112\18.nxphz.HuPaiOption\";\
\
RoomOption\18\11\
\3key\24\1 \1(\9\18\14\
\6nValue\24\2 \1(\5\18\16\
\8strValue\24\3 \1(\9\".\
\8RoomInfo\18\"\
\7options\24\1 \3(\0112\17.nxphz.RoomOption\"<\
\19GAME_PlayerEnterAck\18%\
\8userData\24\1 \2(\0112\19.nxphz.UserGameData\"$\
\19GAME_PlayerLeaveAck\18\13\
\5nSeat\24\1 \2(\5\"e\
\17GAME_EnterGameAck\18\11\
\3err\24\1 \2(\5\18$\
\7players\24\2 \3(\0112\19.nxphz.UserGameData\18\29\
\4room\24\3 \2(\0112\15.nxphz.RoomInfo\"/\
\
VoteResult\18\13\
\5nSeat\24\1 \2(\5\18\18\
\
nVoteState\24\2 \2(\5\"ï\1\
\17GAME_GameSceneAck\18\19\
\11nGameStatus\24\1 \2(\5\18\18\
\
nCellScore\24\2 \2(\5\18\20\
\12nDissoveSeat\24\3 \2(\5\18\20\
\12nDissoveTime\24\4 \2(\5\18\31\
\4vote\24\5 \3(\0112\17.nxphz.VoteResult\18\18\
\
tGameScore\24\6 \3(\5\18\18\
\
nGameCount\24\7 \2(\5\18\23\
\15nTotalGameCount\24\8 \2(\5\18\14\
\6bReady\24\9 \3(\8\18\19\
\11nBankerSeat\24\
 \2(\5\"\31\
\13GAME_ReadyReq\18\14\
\6bReady\24\1 \2(\8\".\
\13GAME_ReadyAck\18\13\
\5nSeat\24\1 \2(\5\18\14\
\6bReady\24\2 \2(\8\"<\
\17GAME_GameStartAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\17\
\9nCardData\24\2 \3(\5\"$\
\15GAME_OutCardReq\18\17\
\9nCardData\24\1 \2(\5\":\
\15GAME_OutCardAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\17\
\9nCardData\24\2 \2(\5\"?\
\21GAME_OutCardNotifyAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\16\
\8bOutCard\24\2 \2(\8\"g\
\16GAME_SendCardAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\17\
\9nCardData\24\2 \2(\5\18\20\
\12nOutCardSeat\24\3 \2(\5\18\20\
\12nOutCardData\24\4 \2(\5\"9\
\19GAME_OperateCardReq\18\16\
\8nOperate\24\1 \2(\5\18\16\
\8nChiKind\24\2 \2(\5\"P\
\19GAME_OperateCardAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\17\
\9nCardData\24\2 \2(\5\18\16\
\8nOperate\24\3 \2(\5\"a\
\14GAME_TiCardAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\17\
\9nCardData\24\2 \2(\5\18\20\
\12nRemoveCount\24\3 \2(\5\18\16\
\8bWeiToTi\24\4 \2(\8\"L\
\15GAME_WeiCardAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\17\
\9nCardData\24\2 \2(\5\18\16\
\8bChouWei\24\3 \2(\8\"c\
\15GAME_PaoCardAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\17\
\9nCardData\24\2 \2(\5\18\20\
\12nRemoveCount\24\3 \2(\5\18\17\
\9bWeiToPao\24\4 \2(\8\":\
\15GAME_ChiCardAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\17\
\9tCardData\24\2 \3(\5\";\
\16GAME_PengCardAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\17\
\9nCardData\24\2 \2(\5\"ñ\1\
\15GAME_GameEndAck\18\18\
\
tGameScore\24\1 \3(\5\18\19\
\11tTotalScore\24\2 \3(\5\18\29\
\4card\24\3 \3(\0112\15.nxphz.CardData\18#\
\9weaveInfo\24\4 \3(\0112\16.nxphz.WeaveInfo\18\22\
\14tRepertoryCard\24\5 \3(\5\18\15\
\7nHuCard\24\6 \2(\5\18\16\
\8nWinSeat\24\7 \2(\5\18\17\
\9nBankSeat\24\8 \2(\5\18#\
\9huPaiInfo\24\9 \2(\0112\16.nxphz.HuPaiInfo\"\31\
\9GameScore\18\18\
\
tGameScore\24\1 \3(\5\"P\
\20GAME_GameTotalEndAck\18\19\
\11tTotalScore\24\1 \3(\5\18#\
\9gameScore\24\2 \3(\0112\16.nxphz.GameScore",}