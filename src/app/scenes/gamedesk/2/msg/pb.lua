return {["buf"]="\
Ô\13\
\8nn.proto\18\2nn\";\
\
RoomOption\18\11\
\3key\24\1 \1(\9\18\14\
\6nValue\24\2 \1(\5\18\16\
\8strValue\24\3 \1(\9\"+\
\8RoomInfo\18\31\
\7options\24\1 \3(\0112\14.nn.RoomOption\"z\
\12UserGameData\18\14\
\6userid\24\1 \2(\4\18\16\
\8nickname\24\2 \2(\9\18\11\
\3sex\24\3 \2(\5\18\18\
\
headimgurl\24\4 \2(\9\18\13\
\5score\24\5 \2(\5\18\
\
\2ip\24\6 \2(\9\18\12\
\4seat\24\7 \2(\5\"\19\
\17GAME_GameLeaveReq\"3\
\17GAME_GameLeaveAck\18\15\
\7nResult\24\1 \2(\5\18\13\
\5nSeat\24\2 \2(\5\"\"\
\16GAME_GameVoteReq\18\14\
\6bAgree\24\1 \2(\8\")\
\4Vote\18\13\
\5nSeat\24\1 \2(\5\18\18\
\
nVoteState\24\2 \2(\5\"@\
\16GAME_GameVoteAck\18\20\
\12nDissoveSeat\24\1 \2(\5\18\22\
\4vote\24\2 \3(\0112\8.nn.Vote\"/\
\
VoteResult\18\13\
\5nSeat\24\1 \2(\5\18\18\
\
nVoteState\24\2 \2(\5\"M\
\22GAME_GameVoteResultAck\18\15\
\7nResult\24\1 \2(\5\18\"\
\
voteResult\24\2 \3(\0112\14.nn.VoteResult\"9\
\19GAME_PlayerEnterAck\18\"\
\8userData\24\1 \2(\0112\16.nn.UserGameData\"$\
\19GAME_PlayerLeaveAck\18\13\
\5nSeat\24\1 \2(\5\"_\
\17GAME_EnterGameAck\18\11\
\3err\24\1 \2(\5\18!\
\7players\24\2 \3(\0112\16.nn.UserGameData\18\26\
\4room\24\3 \2(\0112\12.nn.RoomInfo\"•\2\
\17GAME_GameSceneAck\18\19\
\11nGameStatus\24\1 \2(\5\18\18\
\
nCellScore\24\2 \2(\5\18\20\
\12nDissoveSeat\24\3 \2(\5\18\18\
\
nVoteState\24\4 \3(\5\18\18\
\
nGameScore\24\5 \3(\5\18\18\
\
nGameCount\24\6 \2(\5\18\23\
\15nTotalGameCount\24\7 \2(\5\18\14\
\6bReady\24\8 \3(\8\18\19\
\11nBankerSeat\24\9 \2(\5\18\17\
\9bOperator\24\
 \3(\8\18\18\
\
nCallScore\24\11 \3(\5\18\17\
\9nCardData\24\12 \3(\5\18\13\
\5nNeed\24\13 \3(\5\"\31\
\13GAME_ReadyReq\18\14\
\6bAgree\24\1 \2(\8\"1\
\13GAME_ReadyAck\18\16\
\8wChairID\24\1 \2(\5\18\14\
\6bAgree\24\2 \2(\8\"\31\
\13GAME_BeginReq\18\14\
\6bBegin\24\1 \2(\8\"(\
\17GAME_GameStartAck\18\19\
\11wBankerUser\24\1 \2(\5\"(\
\17GAME_CallScoreReq\18\19\
\11nScoreIndex\24\1 \2(\5\"?\
\17GAME_CallScoreAck\18\22\
\14nCallScoreUser\24\1 \2(\5\18\18\
\
nCallScore\24\2 \2(\5\"\19\
\17GAME_BeginBankAck\"!\
\16GAME_GameBankReq\18\13\
\5bNeed\24\1 \2(\8\"3\
\16GAME_GameBankAck\18\16\
\8wChairID\24\1 \2(\5\18\13\
\5bNeed\24\2 \2(\8\"c\
\18GAME_GameEndPlayer\18\12\
\4seat\24\1 \2(\5\18\13\
\5score\24\2 \2(\5\18\19\
\11total_score\24\3 \2(\3\18\13\
\5cards\24\4 \3(\5\18\12\
\4type\24\5 \2(\5\"8\
\15GAME_GameEndAck\18%\
\5infos\24\1 \3(\0112\22.nn.GAME_GameEndPlayer\"O\
\23GAME_GameTotalEndPlayer\18\12\
\4seat\24\1 \2(\5\18\19\
\11total_count\24\2 \2(\3\18\17\
\9niu_array\24\3 \3(\5\"B\
\20GAME_GameTotalEndAck\18*\
\5infos\24\1 \3(\0112\27.nn.GAME_GameTotalEndPlayer",}