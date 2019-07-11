return {["buf"]="\
¢\12\
\9pdk.proto\18\3pdk\"¾\1\
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
\4adds\24\11 \2(\9\";\
\
RoomOption\18\11\
\3key\24\1 \1(\9\18\14\
\6nValue\24\2 \1(\5\18\16\
\8strValue\24\3 \1(\9\",\
\8RoomInfo\18 \
\7options\24\1 \3(\0112\15.pdk.RoomOption\":\
\19GAME_PlayerEnterAck\18#\
\8userData\24\1 \2(\0112\17.pdk.UserGameData\"$\
\19GAME_PlayerLeaveAck\18\13\
\5nSeat\24\1 \2(\5\"a\
\17GAME_EnterGameAck\18\11\
\3err\24\1 \2(\5\18\"\
\7players\24\2 \3(\0112\17.pdk.UserGameData\18\27\
\4room\24\3 \2(\0112\13.pdk.RoomInfo\"/\
\
VoteResult\18\13\
\5nSeat\24\1 \2(\5\18\18\
\
nVoteState\24\2 \2(\5\"×\2\
\17GAME_GameSceneAck\18\19\
\11nGameStatus\24\1 \2(\5\18\18\
\
nCellScore\24\2 \2(\5\18\20\
\12nDissoveSeat\24\3 \2(\5\18\20\
\12nDissoveTime\24\4 \2(\5\18\29\
\4vote\24\5 \3(\0112\15.pdk.VoteResult\18\18\
\
nGameScore\24\6 \3(\5\18\18\
\
nGameCount\24\7 \2(\5\18\23\
\15nTotalGameCount\24\8 \2(\5\18\14\
\6bReady\24\9 \3(\8\18\19\
\11nBankerSeat\24\
 \2(\5\18\20\
\12nLastOutSeat\24\11 \2(\5\18\20\
\12nCurrentSeat\24\12 \2(\5\18\17\
\9nCardData\24\13 \3(\5\18\18\
\
nCardCount\24\14 \3(\5\18\21\
\13nTurnCardData\24\15 \3(\5\"\31\
\13GAME_ReadyReq\18\14\
\6bReady\24\1 \2(\8\".\
\13GAME_ReadyAck\18\13\
\5nSeat\24\1 \2(\5\18\14\
\6bReady\24\2 \2(\8\"<\
\17GAME_GameStartAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\17\
\9nCardData\24\2 \3(\5\"$\
\15GAME_OutCardReq\18\17\
\9nCardData\24\1 \3(\5\"b\
\15GAME_OutCardAck\18\20\
\12nCurrentSeat\24\1 \2(\5\18\20\
\12nOutCardSeat\24\2 \2(\5\18\17\
\9nCardData\24\3 \3(\5\18\16\
\8bLeftOne\24\4 \2(\8\"\18\
\16GAME_PassCardReq\"M\
\16GAME_PassCardAck\18\16\
\8bNewTurn\24\1 \2(\8\18\17\
\9nPassSeat\24\2 \2(\5\18\20\
\12nCurrentSeat\24\3 \2(\5\"\"\
\14GAME_PromptAck\18\16\
\8szPrompt\24\1 \2(\9\"\29\
\8CardData\18\17\
\9nCardData\24\1 \3(\5\"k\
\15GAME_GameEndAck\18\18\
\
nGameScore\24\1 \3(\5\18\19\
\11nTotalScore\24\2 \3(\5\18\18\
\
nBombCount\24\3 \3(\5\18\27\
\4card\24\4 \3(\0112\13.pdk.CardData\"h\
\20GAME_GameTotalEndAck\18\19\
\11nTotalScore\24\1 \3(\5\18\17\
\9nMaxScore\24\2 \3(\5\18\21\
\13nAllBombCount\24\3 \3(\5\18\17\
\9nWinCount\24\4 \3(\5",}