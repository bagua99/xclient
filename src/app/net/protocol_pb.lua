return {["buf"]="\
Ç\17\
\14protocol.proto\18\8protocol\"g\
\12UserGameData\18\17\
\9ullUserID\24\1 \2(\5\18\18\
\
szNickName\24\2 \2(\9\18\19\
\11ullRoomCard\24\3 \2(\5\18\11\
\3sex\24\4 \2(\5\18\14\
\6imgurl\24\5 \2(\9\"5\
\13ReplayWinLose\18\16\
\8nickname\24\1 \2(\9\18\18\
\
deltascore\24\2 \2(\5\"†\1\
\13ReplaListInfo\18\18\
\
gameresult\24\1 \2(\5\18\14\
\6roomid\24\2 \2(\5\18\15\
\7tableid\24\3 \2(\5\18.\
\13ReplayWinLose\24\4 \3(\0112\23.protocol.ReplayWinLose\18\16\
\8datetime\24\5 \2(\9\"…\1\
\16CL_LoginLobbyReq\18\15\
\7account\24\1 \2(\9\18\14\
\6userid\24\2 \2(\5\18\14\
\6openid\24\3 \2(\9\18\16\
\8nickname\24\4 \2(\9\18\11\
\3sex\24\5 \2(\5\18\18\
\
headimgurl\24\6 \2(\9\18\13\
\5token\24\7 \2(\9\"™\1\
\16CL_LoginLobbyAck\18\16\
\8dwResult\24\1 \2(\5\18\13\
\5score\24\2 \2(\5\18\16\
\8roomcard\24\3 \2(\5\18\14\
\6roomid\24\4 \1(\5\18\14\
\6gameid\24\5 \1(\5\18\15\
\7room_ip\24\6 \1(\9\18\17\
\9room_port\24\7 \1(\5\18\14\
\6ticket\24\8 \1(\9\"\18\
\16CL_ReplayListReq\"\18\
\16CL_ReplayListAck\"$\
\18CL_ReplayDetailReq\18\14\
\6roomid\24\1 \2(\5\"\20\
\18CL_ReplayDetailAck\"M\
\12CreateOption\18\11\
\3key\24\1 \2(\9\18\15\
\7snvalue\24\2 \1(\5\18\15\
\7ssvalue\24\3 \1(\9\18\14\
\6mvalue\24\4 \3(\9\"L\
\16CL_CreateGameReq\18\15\
\7nGameID\24\1 \2(\5\18'\
\7options\24\2 \3(\0112\22.protocol.CreateOption\"o\
\16CL_CreateGameAck\18\16\
\8dwResult\24\1 \2(\5\18\14\
\6roomid\24\2 \2(\5\18\
\
\2ip\24\3 \2(\9\18\12\
\4port\24\4 \2(\5\18\14\
\6ticket\24\5 \2(\9\18\15\
\7nGameID\24\6 \2(\5\".\
\14CL_JoinGameReq\18\14\
\6roomid\24\1 \2(\5\18\12\
\4mode\24\2 \2(\5\"m\
\14CL_JoinGameAck\18\16\
\8dwResult\24\1 \2(\5\18\14\
\6roomid\24\2 \2(\5\18\
\
\2ip\24\3 \2(\9\18\12\
\4port\24\4 \2(\5\18\14\
\6ticket\24\5 \2(\9\18\15\
\7nGameID\24\6 \2(\5\"H\
\21CL_AddUserRoomCardReq\18\14\
\6userid\24\1 \2(\5\18\17\
\9deltacard\24\2 \2(\5\18\12\
\4type\24\3 \2(\5\" \
\15CL_BroadCastAck\18\13\
\5count\24\1 \2(\5\"e\
\12UserBaseInfo\18\14\
\6userid\24\1 \2(\5\18\16\
\8nickname\24\2 \2(\9\18\18\
\
headimgurl\24\3 \2(\9\18\13\
\5score\24\4 \2(\5\18\16\
\8roomcard\24\5 \2(\5\"D\
\20CL_UpdateUserDataAck\18,\
\12UserBaseInfo\24\1 \2(\0112\22.protocol.UserBaseInfo\"„\1\
\12EnterGameReq\18\14\
\6userid\24\1 \2(\5\18\14\
\6roomid\24\2 \2(\5\18\14\
\6ticket\24\3 \2(\9\18\17\
\9reconnect\24\4 \2(\8\18\16\
\8latitude\24\5 \2(\9\18\17\
\9longitude\24\6 \2(\9\18\12\
\4adds\24\7 \2(\9\"\27\
\12EnterGameAck\18\11\
\3err\24\1 \2(\5\"'\
\7ChatReq\18\14\
\6nMsgID\24\1 \2(\5\18\12\
\4text\24\2 \2(\9\"9\
\7ChatAck\18\16\
\8wChairID\24\1 \2(\5\18\14\
\6nMsgID\24\2 \2(\5\18\12\
\4text\24\3 \2(\9\"\28\
\12HeartBeatReq\18\12\
\4time\24\1 \2(\5\"\28\
\12HeartBeatAck\18\12\
\4time\24\1 \2(\5\" \
\14UserOfflineAck\18\14\
\6userid\24\1 \2(\5\"\29\
\12VoiceChatReq\18\13\
\5voice\24\1 \2(\9\"-\
\12VoiceChatAck\18\14\
\6userid\24\1 \2(\5\18\13\
\5voice\24\2 \2(\9\"\14\
\12GameSceneReq\"\16\
\14GameLBSVoteReq\"\16\
\14GameLBSVoteAck\"\14\
\12GameLeaveReq\".\
\12GameLeaveAck\18\15\
\7nResult\24\1 \2(\5\18\13\
\5nSeat\24\2 \2(\5\"\29\
\11GameVoteReq\18\14\
\6bAgree\24\1 \2(\8\")\
\4Vote\18\13\
\5nSeat\24\1 \2(\5\18\18\
\
nVoteState\24\2 \2(\5\"A\
\11GameVoteAck\18\20\
\12nDissoveSeat\24\1 \2(\5\18\28\
\4vote\24\2 \3(\0112\14.protocol.Vote\"/\
\
VoteResult\18\13\
\5nSeat\24\1 \2(\5\18\18\
\
nVoteState\24\2 \2(\5\"N\
\17GameVoteResultAck\18\15\
\7nResult\24\1 \2(\5\18(\
\
voteResult\24\2 \3(\0112\20.protocol.VoteResult",}