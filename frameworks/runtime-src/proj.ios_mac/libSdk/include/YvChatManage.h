//
//  YvChatManage.h
//  
//
//  Created by 朱文腾 on 14-8-12.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextMessageNotify.h"
#import "VoiceMessageNotify.h"
#import "RichMessageNotify.h"
#import "UserStateNotify.h"
#import "MicModeChangeNotify.h"
#import "YvRecognizerProtocol.h"
#import "TroopsChangeNotify.h"

#ifndef CHATMANAGE_HEAD_H

#define CHATMANAGE_HEAD_H
typedef NS_ENUM(int,kServerEnvironment)
{
    kServerEnvironment_Release = 0,                 //国内正式环境
    kServerEnvironment_Debug = 1,                   //国内测试环境
    kServerEnvironment_InternationalRelease = 2,    //国际正式环境
    kServerEnvironment_InternationalDebug = 3,      //国际测试环境（缺省）
    kServerEnvironment_ServerSynthesizerRelease = 4,    //（缺省）
    kServerEnvironment_ServerSynthesizerDebug = 5,      //（缺省）
    
};

typedef NS_ENUM(int, ReceiveStateType)
{
    ReceiveStateType_RealVoice_Message = 1,
    ReceiveStateType_RealVoice_UnMessage = 2,
    ReceiveStateType_UnRealVoice_Message = 3,
    ReceiveStateType_UnRealVoice_UnMessage  = 4,
};

typedef enum : NSUInteger {
    kUploadFile_Retain_Time_permanent	= 0,//永久
    kUploadFile_Retain_Time_year = 1, //一年
    kUploadFile_Retain_Time_6_months	= 2,	//六个月
    kUploadFile_Retain_Time_3_months	= 3,	//3个月
    kUploadFile_Retain_Time_1_months	= 4,	//1个月
    kUploadFile_Retain_Time_2_week		= 5,	//两周
    kUploadFile_Retain_Time_1_week		= 6,	//一周
    kUploadFile_Retain_Time_3_day		= 7,	//三天
    kUploadFile_Retain_Time_1_day		= 8,	//一天
    kUploadFile_Retain_Time_6_hours	= 9,	//六小时
} E_UploadFile_Retain_Time;//文件保存时长类型


typedef enum : int {
    kMicModeType_invalid = -1,     //无效的
    kMicModeType_freedomMode = 0, //0:自由模式:上麦即可说话，大家都可以同时说话
    kMicModeType_competitionMode = 1,//1:抢麦模式，谁抢到麦，谁就能说话，其他人就只能听，然后他下麦后，谁第一个去抢麦谁就能抢到。
    kMicModeType_chairmanMode = 2,//2:指挥模式(或叫主席模式):只有他自己能说话，其他人都不能说话,也无法抢麦,只能听
} E_MicModeType;//麦模式



@class YvChatManage;

#pragma mark   ------------------------------#### YvChatManageDelegate #####---------------------------------


@protocol YvChatManageDelegate <NSObject>

@optional

/**初始化完成*/
//-(void)ChatManage:(YvChatManage *)sender initComplete:(BOOL)issuccess;

/**网络断开后，重连三次失败返回*/
-(void)ChatManage:(YvChatManage *)sender OnConnectFail:(NSString *)desc;

/*!
 @callback 该函数为回调函数 add by huangzhijun 2015.1.23
 @brief 在网络异常(如:wifi-->3G, 3G-->wifi,无网络-->3G/wifi),开始自动重新登录
 @param tryReLoginTimes 重新登录尝试次数
 @result
 */
-(void)ChatManage:(YvChatManage *)sender BeginAutoReLoginWithTryTimes:(NSUInteger)tryReLoginTimes;


#pragma mark 认证结果-回调
/**登录返回LoginWithSeq 认证 结果回调 (内部鉴权成功会自动调进入房间操作，全部成功，会回调下面的登录结果 回调)**/
-(void)ChatManage:(YvChatManage *)sender AuthResp:(int)result msg:(NSString *)msg;

#pragma mark 登录(认证+进入房间)结果-回调
/**登录返回  LoginWithSeq、LoginBindingWithTT 都是该返回*/
-(void)ChatManage:(YvChatManage *)sender LoginResp:(int)result msg:(NSString *)msg yunvaid:(UInt64)yunvaid;
-(void)ChatManage:(YvChatManage *)sender LoginResp:(int)result msg:(NSString *)msg yunvaid:(UInt64)yunvaid MicModeType:(E_MicModeType)modeType leaderId:(UInt64)leaderId isLeader:(BOOL)isLeader;

#pragma mark 注销结束-回调
/**注销返回*/
-(void)ChatManage:(YvChatManage *)sender LogoutResp:(int)result msg:(NSString *)msg;

#pragma mark 发送文本结束-回调
/*成功发送文本消息返回 add by huangzhijun 2015.1.19*/
-(void)ChatManage:(YvChatManage *)sender SendTextMessageSuccessWithExpand:(NSString*)expand;

/**发送消息返回，只有消息发送失败才会收到回调*/
-(void)ChatManage:(YvChatManage *)sender SendTextMessageError:(int)result msg:(NSString *)msg;
-(void)ChatManage:(YvChatManage *)sender SendTextMessageError:(int)result msg:(NSString *)msg expand:(NSString*)expand;

#pragma mark 接收到文本消息通知-回调
/**接受到文本通知*/
-(void)ChatManage:(YvChatManage *)sender TextMessageNotify:(TextMessageNotify *)TextMessageNotify;

/**房间里用户变更通知**/
-(void)ChatManage:(YvChatManage *)sender TroopsChangeNotify:(TroopsChangeNotify*)changeNotify;

/*获取房间用户列表回调*/
-(void)ChatManage:(YvChatManage *)sender GetTroopsListResp:(int)result msg:(NSString*)msg userList:(NSMutableArray*)userList;

#pragma mark 发送语音-回调
/**发送语音留言返回,发送时会先上传到服务器并返回地址,故将上传的路径、时间返回*/
-(void)ChatManage:(YvChatManage *)sender SendVoiceMessageResp:(int)result msg:(NSString *)msg voiceUrl:(NSString *)voiceUrl voiceDuration:(UInt64)voiceDuration filePath:(NSString *)filePath expand:(NSString *)expand;

#pragma mark 收到语音消息通知-回调
/**接收到语音留言通知*/
-(void)ChatManage:(YvChatManage *)sender VoiceMessageNotify:(VoiceMessageNotify *)VoiceMessageNotify;

#pragma mark 富消息(同时有 语音+文本)相关-回调

/** 文本+语音留言 通知 (一般用于语音文字识别功能的通知) add 2014.12.5**/
-(void)ChatManage:(YvChatManage *)sender RichMessageNotifyWithTextMessage:(TextMessageNotify *)TextMessageNotify VoiceMessage:(VoiceMessageNotify *)VoiceMessageNotify;

/*发送文本+语音富消息返回，发送时会先上传语音到服务器并返回地址 add by huangzhijun 2014.12.8*/
-(void)ChatManage:(YvChatManage *)sender SendRichMessageResp:(int)result msg:(NSString *)msg textMsg:(NSString *)textMsg  voiceUrl:(NSString *)voiceUrl voiceDuration:(UInt64)voiceDuration filePath:(NSString *)filePath expand:(NSString *)expand;
/*********************************************************************/


#pragma mark 上下麦-回调
/**上下麦返回*/
-(void)ChatManage:(YvChatManage *)sender ChatMicResp:(int)result msg:(NSString *)msg onoff:(BOOL)onoff;

#pragma mark 实时语音相关-回调
/**实时语音错误返回，只有发送失败才会收到回调，注意音频是发送是频繁的，出现错误时此事件是一连串的*/
-(void)ChatManage:(YvChatManage *)sender SendRealTimeVoiceMessageError:(int)result msg:(NSString *)msg;

/**实时语音通知*/
-(void)ChatManage:(YvChatManage *)sender RealTimeVoiceMessageNotifyWithYunvaId:(UInt32)yunvaid chatroomId:(NSString *)chatroomId expand:(NSString *)expand;

#pragma mark 实时语音--播放语音的峰值和平均值-回调
/**当开启播放声音和录音的计量检测,返回实时语音或自动播放的峰值和平均值*/
-(void)ChatManage:(YvChatManage *)sender PlayMeteringPeakPower:(float)peakPower AvgPower:(float)avgPower;

#pragma mark 实时语音--录音的语音的峰值和平均值-回调
/**当开启录音的计量检测,返回实时录音的峰值和平均值*/
-(void)ChatManage:(YvChatManage *)sender RecorderMeteringPeakPower:(float)peakPower AvgPower:(float)avgPower;

/**设置消息接收的方式返回*/
//-(void)ChatManage:(YvChatManage *)sender SetReceiveStateResp:(ReceiveStateType)setReceiveStateResp;

#pragma mark 用户被踢出房间-回调
/**请出房间回调*/
-(void)ChatManage:(YvChatManage *)sender KickOutNotifyWithmsg:(NSString *)msg;

#pragma mark 用户状态改变-回调
/**用户状态改变回调*/
-(void)ChatManage:(YvChatManage *)sender UserStateNotify:(UserStateNotify *)userStateNotify;

#pragma mark 设置麦模式返回-回调
/**设置麦模式返回*/
-(void)ChatManage:(YvChatManage *)sender MicModeSettingResp:(int)result msg:(NSString *)msg;

#pragma mark 麦模式更改-通知回调
/**麦模式更改通知*/
-(void)ChatManage:(YvChatManage *)sender MicModeChangeNotify:(MicModeChangeNotify *)micModeChangeNotify;

#pragma mark 检测当前系统的音量-回调
/**检测当前系统的音量*/
-(void)ChatManage:(YvChatManage *)sender CurrentSystemVolume:(float)volume;

#pragma mark 获取聊天历史记录接口-回调
/**
 获取聊天历史记录接口回调
 @param roomMode - 2:主播模式、1:抢麦模式 4:麦序模式
 @param result -- 返回码:0 - 成功, 非0 - 失败
 @param msg -- 错误消息
 @param historyMsgArray -- 聊天历史记录 元素类型: TextMessageNotify对象(文本对象)  或者  VoiceMessageNotify对象(语音对象)  或者  RichMessageNotify对象(文本+语音)
 */
-(void)ChatManage:(YvChatManage *)sender QueryHistoryMsgResp:(int)result msg:(NSString*)msg historyMsgArray:(NSArray*)historyMsgArray;

/**网络延迟*/
- (void)ChatManage:(YvChatManage *)sender NetWorkDelay:(UInt64)delay;

/**太短时间发送异常数据比如小于10ms发送数据*/
-(void) ChatManage:(YvChatManage*)sender onYvExceptionRecord:(UInt64)time;

@end



#pragma mark   ------------------------------#### YvChatManage #####---------------------------------


@interface YvChatManage : NSObject 

@property (nonatomic,weak) id<YvChatManageDelegate> delegate;

@property (assign, readonly) UInt32 yunvaId;
@property (nonatomic,assign,readonly) E_MicModeType  currentMicModeType;//当前的麦模式，只读；

/**初始化,避免与sharedInstance一起使用(deprecated)(请改用单例 [YvChatManage sharedInstance] SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest)
 @param
 appid  : 你的appId
 istest : yes是测试环境 no 正式环境
 例如:
 chatmanage = [[YvChatManage alloc]initWithAppId:@“你的appId” istest:是否是测试环境];
 chatmanage.delegate = self;
 [chatmanage LoginWithSeq:self.Seq hasVideo:NO position:0 videoCount:0];*/
-(id)initWithAppId:(NSString *)appid istest:(BOOL)istest __attribute__((deprecated));


#pragma mark - ----额外设置----
/**
 *  设置所要连接的服务器地址域名(或ip)
 *  注：  1）本接口一般不需要设置，SDK内部已有默认的连接服务器地址,只是给某些也部署了我们的服务器的cp额外所需要的设置。
         2) 本接口需要在设置初始化[-(void)SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest]之前调用。
        3) 为支持ipv6，所以的ipv4都需要替换为域名，而不是ip地址。  除了这里，还有在获取房间信息时返回的聊天，和视频的地址也需要域名
 *
 *  @param host 所要连接的服务器地址域名(或ip) (host = nil 则SDK恢复连接SDK默认的服务器地址)
 */
+(void)setAccessServer:(NSString *)host;//为支持ipv6，需要传入域名,

#pragma mark - ----单例----
/**获取一个共享实例,后续建议用此方法,单利模式可避免重新登录房间导致的多条连接
 使用例子:
 [YvChatManage SetInitParamWithAppId:@“你的appId” istest:是否是测试环境];
 [YvChatManage sharedInstance].delegate = self;
 [[YvChatManage sharedInstance] LoginWithSeq:self.Seq hasVideo:NO position:0 videoCount:0];*/
+(instancetype)sharedInstance;

#pragma mark - ----初始化----
/**设置初始化参数,设置之后需要重新登录*/
-(void)SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest;
-(void)SetInitParamWithEnvironment:(kServerEnvironment)environment AppId:(NSString*)appid;

/**设置日志级别:0--关闭日志  1--error  2--debug(不设置为默认该级别) 3--warn  4--info  5--trace*/
-(void)setLogLevel:(int)logLevel;

/*SDK版本信息*/
-(NSString *)getSDKVersion;

/**设置支持否后台运行,默认为NO,不支持*/
@property (nonatomic,assign) BOOL supportBackgroundingOnSocket;

#pragma mark - ----房间登录----
/**登录到房间，单独设计可用于切换房间*/ //注:登录操作=认证操作+进入房间操作
/* 参数说明:
 seq:代表房间号  只有房间号相同的才可以在同一个房间号里面视频,语音,文字聊天等。
 hasVideo = NO:没有视频,Yes:有视频 ;为NO时,position和videoCount失效;
 position:0~4,共5个值; 注意:不在0~4,则不能实时视频;
 videoCount:2~5,共4个值,两个人视频就写2，3个人视频就写3，以此类推;   注意：不在2~5,则不能实时视频;;(最多支持五个人视频)
 */
-(void)LoginWithSeq:(NSString *)seq hasVideo:(BOOL)hasVideo position:(UInt8)position videoCount:(int)videoCount;

/**登录绑定，用于第三方登录*/         //注:登录操作=认证操作+进入房间操作
//NSString *ttt = [NSString stringWithFormat:@"{\"uid\": \"%@\", \"nickname\": \"%@\"}",@"16d69",@"江南"];
//NSString *ttt = [NSString stringWithFormat:@"uid=%@&nickname=%@}",@"16d69",@"江南"];
-(void)LoginBindingWithTT:(NSString *)tt seq:(NSString *)seq hasVideo:(BOOL)hasVideo position:(UInt8)position videoCount:(int)videoCount;

/**注销，用于切换房间*/
-(void)Logout;

#pragma mark - ----实时语音接口----
/**聊天中的实时语音上麦，下麦*/
-(void)ChatMic:(BOOL)onoff expand:(NSString *)expand;
//上麦会根据时间限制自动下麦
- (void)ChatMicWithTimeLimit:(NSInteger)timeLimit expand:(NSString *)expand;
/**设置是否暂停【播放】实时语音聊天*/
-(void)setPausePlayRealAudio:(BOOL)isPasue;
/**获取当前是否已经暂停【播放】实时语音*/
-(BOOL)isPausePlayAudio;

/**设置麦模式，modeType:0自由模式，1抢麦模式，2指挥模式, 见枚举类型:E_MicModeType*/
-(void)MicModeSettingWithmodeType:(UInt8)modeType;

/**获取当前是否是上麦状态**/
-(BOOL)getCurrentMicState;

#pragma mark -- 屏蔽接口
-(void)AddShieldWithYunvaId:(UInt32)yunvaId;


-(void)RemoveShieldWithYunvaId:(UInt32)yunvaId;

//2016-12-12
//#pragma mark - ----获取历史消息----
///*获取聊天历史记录接口*/
-(void)queryHistoryMsgReqWithPageIndex:(int)pageIndex PageSize:(int)pageSize;
//
//#pragma mark - ----发送消息接口----
///**发送文本信息*/
-(void)sendTextMessage:(NSString *)text expand:(NSString *)expand;
//
//**发送语音留言*/
-(void)sendVoiceMessage:(NSString *)filePath voiceDuration:(int)voiceDuration expand:(NSString *)expand;
-(void)sendVoiceMessageWithVoiceUrl:(NSString *)voiceUrl voiceDuration:(int)voiceDuration expand:(NSString *)expand;
//
/**发送文字+语音留言*/
-(void)sendRichMessageWithTextMsg:(NSString *)text VoiceMsg:(NSString *)filePath voiceDuration:(int)voiceDuration expand:(NSString *)expand;
-(void)sendRichMessageWithTextMsg:(NSString *)text voiceUrl:(NSString *)voiceUrl voiceDuration:(int)voiceDuration expand:(NSString *)expand;

/**获取房间用户列表*/
- (void)ChatGetTroopsListReq;

/**设置是否自动播放收到的语音留言消息,默认为NO*/
@property (nonatomic,assign) BOOL isAutoPlayVoiceMessage;

/**是否开启实时语音的计量检测,默认NO*/
@property (nonatomic,assign) BOOL MeteringEnabled;

/*
 1.default:Yes
   默认sdk在房间登入成功后 自动连接视频并初始化视频解码器;退出房间前自动关闭视频解码器和断开视频连接，再退出房间
 2.若用户设置为NO，则需要用户自己管理，具体可以看demo的YvRoomViewController.m文件中的_isAutoConnectVideo：
                                登入房间成功 后 :发起视频的连接，视频连接成功后再初始化视频编码器
                                退出房间 前 :关闭视频编码器，视频断开连接，退出房间；
 */
@property (nonatomic,assign) BOOL isAutoConnectVideo; /* */

//2016-12-12
//#pragma mark - //--------------------------------------------------语音识别---------------------------------------------------------------//
//#pragma mark - ----语音上传+语音识别 (http方式)----
//
///*!
// @method
// @brief 语音上传+语音识别
// 
// 注意:调用本函数前请确认：
//        1.已调用初始化函数:-(void)SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest;
//        2.如果不使用本SDK 收发消息通道和实时语音功能，只用录音和语音识别功能，需调用登录:(seq = nil)
//                -(void)LoginWithSeq:(NSString *)seq hasVideo:(BOOL)hasVideo position:(UInt8)position videoCount:(int)videoCount;
//        3.调用登录接口，有回调认证成功(-(void)ChatManage:(YvChatManage *)sender AuthResp:(int)result msg:(NSString *)msg;)。即可调用该方法。
// 
// @param recognizeLanguage 您说话的类型 (普通话,广东话,美式英语)
// @param outputTextLanguageType  输出文字的类型 (简体中文，繁体中文)
// @param voiceFilePath 要上传(语音识别)的语音文件路径
// @param voiceDuration 语音时长(单位:毫秒)
// @param fileRetainTimeType 文件保存在服务器的时长类型
// @param voiceUrl 要语音识别的语音文件下载地址(与voiceFilePath 二选一种方式), 可为空
// @param expand 自定义扩展字段，回调函数会原本返回。
// 
// @param responseCallback 回调函数：
//            (void (^)(int result, NSString * errMsg, NSString * text, NSString * voiceDownloadUrl, NSString * voiceFilePath, int voiceDuration, NSString * expand, id reserve)
//                    result              ----语音上传+语音识别 结果，0：成功  其他：失败(语音上传成功，但语音识别识别，也是返回失败值，所以只要有voiceDownloadUrl返回有值，则算保存语音文件成功，可以发纯语音消息)
//                    errMsg              ----错误信息
//                    text                ----识别出来的文本
//                    voiceDownloadUrl    ----语音文件下载地址
//                    voiceFilePath       ----带回参数设置的voiceFilePath
//                    voiceDuration       ----带回参数设置的voiceDuration
//                    expand              ----带回参数设置的expand
//                    reserve             ----保留字段
// @result
// */
-(void)httpVoiceRecognizeReqWithRecognizeLanguage:(E_TVoiceRecognitionLanguage)recognizeLanguage
                               OutputLanguageType:(E_OutputLanguageType)outputTextLanguageType
                                    voiceFilePath:(NSString *)voiceFilePath
                                    voiceDuration:(int)voiceDuration
                                   retainTimeType:(E_UploadFile_Retain_Time)fileRetainTimeType
                                         voiceUrl:(NSString *)voiceUrl
                                           expand:(NSString *)expand
                                 responseCallback:(void (^)(int result, NSString * errMsg, NSString * text, NSString * voiceDownloadUrl, NSString * voiceFilePath, int voiceDuration, NSString * expand, id reserve))responseCallback;
//
//
//#pragma mark - ----文件上传接口----
///**********/
//#pragma mark 单独上传语音文件
///*!
// @method
// @brief 上传语音文件
//        注意:调用本函数前请确认已调用初始化函数:-(void)SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest;
// 
// @param voiceFilePath 语音文件全路径
// @param fileRetainTimeType  文件保存时长类型
// @param success 语音文件上传成功后的回调, 参数voiceUrl是语音文件保存在服务器的url
// @param failure 上传失败的回调
// @result
// */
-(void)uploadVoiceMessage:(NSString *)voiceFilePath
           retainTimeType:(E_UploadFile_Retain_Time)fileRetainTimeType
                  success:(void (^)(NSString * voiceUrl))success
                  failure:(void (^)( NSError *error))failure;
//
//#pragma mark 上传图片
///*!
// @method
// @brief 上传图片
//        注意:调用本函数前请确认已调用初始化函数:-(void)SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest;
// 
// @param fileData 图片数据
// @param fileType 图片类型,支持: @"jpg"  @"png"
//
// @param fileRetainTimeType  文件保存时长类型
// @param success 语音文件上传成功后的回调, 参数pictureUrl是原图url 
// @param failure 上传失败的回调
// @result
// */
-(void)uploadPictureWithFileData:(NSData *)fileData
                        FileType:(NSString *)fileType
                  retainTimeType:(E_UploadFile_Retain_Time)fileRetainTimeType
                         success:(void (^)(NSString * pictureUrl))success
                         failure:(void (^)( NSError *error))failure;
//
//
///*!
// @method
// @brief 上传图片(服务器实现缩略图功能，但不稳定，建议缩略图客户端自己实现，调用上面的单纯图片上传功能)
//        注意:调用本函数前请确认已调用初始化函数:-(void)SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest;
// 
// @param fileData 图片数据
// @param fileType 图片类型,支持: @"jpg"  @"png"
// @param scaleToSize 缩略图大小，比如缩略图是114x114 则填114
// @param fileRetainTimeType  文件保存时长类型
// @param success 语音文件上传成功后的回调, 参数pictureUrl是原图url  thumbnailPictureUrl 是缩略图url
// @param failure 上传失败的回调
// @result
// */
-(void)uploadPictureWithFileData:(NSData *)fileData
                        FileType:(NSString *)fileType
                     scaleToSize:(int)scaleToSize
                  retainTimeType:(E_UploadFile_Retain_Time)fileRetainTimeType
                         success:(void (^)(NSString * pictureUrl, NSString * thumbnailPictureUrl))success
                         failure:(void (^)( NSError *error))failure;
///**********/
//
//
//#pragma mark - ----语音文件下载到缓存文件区----
///*!
// @method
// @brief 在【wifi】情况下下载语音文件到缓存中(不是wifi不下载)
//        注:AudioTools类的播放voiceUrl语音接口会先从缓存中查询是否有已下载的缓存文件播放，如果没下载再去下载播放。
// @param voiceUrl 文件下载url
// 
// */
-(void)downloadVoiceFileToCacheWhenWifi:(NSString *)voiceUrl;
//
//
//
//#pragma mark - ----对实时语音进行语音识别插件----
-(void)setRecognizerPlugin:(id<YvRecognizerProtocol>)recognizePlugin;
-(int)startRealVoiceRecognize; //在上麦，并且设置了才能后调用实时语音识别
-(void)stopRealVoiceRecognize;  //结束实时语音识别



@end
#endif
