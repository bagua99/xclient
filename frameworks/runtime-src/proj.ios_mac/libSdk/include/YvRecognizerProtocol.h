//
//  YvRecognizerProtocol.h
//  ChatSDK
//
//  Created by wind on 14-12-8.
//  Copyright (c) 2014年 com.yunva.yaya. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YVRECOGNIZERPROTOCOL_HEAD_H 1 

#ifndef YVVOICERECOGNIZE_HEADER
#define YVVOICERECOGNIZE_HEADER

typedef enum : NSUInteger {
    kOutputLanguageType_SimplifiedChinese = 0, //简体中文
    kOutputLanguageType_TraditionalChinese = 1, //繁体中文
} E_OutputLanguageType;//识别后，输出语言类型


/**************************************[begin] come form BDVoiceRecognitionClient.h*********************************************************/

// 枚举 - 语音识别状态
enum TVoiceRecognitionClientWorkStatus
{
    EVoiceRecognitionClientWorkStatusNone = 0,               // 空闲
    EVoiceRecognitionClientWorkPlayStartTone,                // 播放开始提示音
    EVoiceRecognitionClientWorkPlayStartToneFinish,          // 播放开始提示音完成
    EVoiceRecognitionClientWorkStatusStartWorkIng,           // 识别工作开始，开始采集及处理数据
    EVoiceRecognitionClientWorkStatusStart,                  // 检测到用户开始说话
    EVoiceRecognitionClientWorkStatusSentenceEnd,            // 输入模式下检测到语音说话完成
    EVoiceRecognitionClientWorkStatusEnd,                    // 本地声音采集结束结束，等待识别结果返回并结束录音
    EVoiceRecognitionClientWorkPlayEndTone,                  // 播放结束提示音
    EVoiceRecognitionClientWorkPlayEndToneFinish,            // 播放结束提示音完成
    
    EVoiceRecognitionClientWorkStatusNewRecordData,          // 录音数据回调
    EVoiceRecognitionClientWorkStatusFlushData,              // 连续上屏
    EVoiceRecognitionClientWorkStatusReceiveData,            // 输入模式下有识别结果返回
    EVoiceRecognitionClientWorkStatusFinish,                 // 语音识别功能完成，服务器返回正确结果
    
    EVoiceRecognitionClientWorkStatusCancel,                 // 用户取消
    EVoiceRecognitionClientWorkStatusError                   // 发生错误，详情见VoiceRecognitionClientErrorStatus接口通知
};

// 枚举 - 网络工作状态
enum TVoiceRecognitionClientNetWorkStatus
{
    EVoiceRecognitionClientNetWorkStatusStart = 1000,        // 网络开始工作
    EVoiceRecognitionClientNetWorkStatusEnd,                 // 网络工作完成
};

// 枚举 - 语音识别错误通知状态分类
enum TVoiceRecognitionClientErrorStatusClass
{
    EVoiceRecognitionClientErrorStatusClassVDP = 1100,        // 语音数据处理过程出错
    EVoiceRecognitionClientErrorStatusClassRecord = 1200,     // 录音出错
    EVoiceRecognitionClientErrorStatusClassLocalNet = 1300,   // 本地网络联接出错
    EVoiceRecognitionClientErrorStatusClassServerNet = 3000,  // 服务器返回网络错误
};

// 枚举 - 语音识别错误通知状态
enum TVoiceRecognitionClientErrorStatus
{
    //以下状态为错误通知，出现错语后，会自动结束本次识别
    EVoiceRecognitionClientErrorStatusUnKnow = EVoiceRecognitionClientErrorStatusClassVDP+1,          // 未知错误(异常)
    EVoiceRecognitionClientErrorStatusNoSpeech,               // 用户未说话
    EVoiceRecognitionClientErrorStatusShort,                  // 用户说话声音太短
    EVoiceRecognitionClientErrorStatusException,              // 语音前端库检测异常
    
    
    EVoiceRecognitionClientErrorStatusChangeNotAvailable = EVoiceRecognitionClientErrorStatusClassRecord+1,     // 录音设备不可用
    EVoiceRecognitionClientErrorStatusIntrerruption,          // 录音中断
    
    
    EVoiceRecognitionClientErrorNetWorkStatusUnusable = EVoiceRecognitionClientErrorStatusClassLocalNet+1,            // 网络不可用
    EVoiceRecognitionClientErrorNetWorkStatusError,               // 网络发生错误
    EVoiceRecognitionClientErrorNetWorkStatusTimeOut,             // 网络本次请求超时
    EVoiceRecognitionClientErrorNetWorkStatusParseError,          // 解析失败
    
    
    //服务器返回错误
    EVoiceRecognitionClientErrorNetWorkStatusServerParamError = EVoiceRecognitionClientErrorStatusClassServerNet+1,       // 协议参数错误
    EVoiceRecognitionClientErrorNetWorkStatusServerRecognError,      // 识别过程出错
    EVoiceRecognitionClientErrorNetWorkStatusServerNoFindResult,     // 没有找到匹配结果
    EVoiceRecognitionClientErrorNetWorkStatusServerAppNameUnknownError,     // AppnameUnkown错误
    EVoiceRecognitionClientErrorNetWorkStatusServerSpeechQualityProblem,    // 声音不符合识别要求
    EVoiceRecognitionClientErrorNetWorkStatusServerSpeechTooLong,           // 语音过长
    EVoiceRecognitionClientErrorNetWorkStatusServerUnknownError,            // 未知错误
};

// 枚举 - 语音识别类型
typedef enum TBDVoiceRecognitionProperty
{
    EVoiceRecognitionPropertyMusic = 10001, // 音乐
    EVoiceRecognitionPropertyVideo = 10002, // 视频
    EVoiceRecognitionPropertyApp = 10003, // 应用
    EVoiceRecognitionPropertyWeb = 10004, // web
    EVoiceRecognitionPropertySearch = 10005, // 热词
    EVoiceRecognitionPropertyEShopping = 10006, // 电商&购物
    EVoiceRecognitionPropertyHealth = 10007, // 健康&母婴
    EVoiceRecognitionPropertyCall = 10008, // 打电话
    EVoiceRecognitionPropertySong = 10009, // 录歌识别
    EVoiceRecognitionPropertyMedicalCare = 10052, // 医疗
    EVoiceRecognitionPropertyCar = 10053, // 汽车
    EVoiceRecognitionPropertyCatering = 10054, // 娱乐餐饮
    EVoiceRecognitionPropertyFinanceAndEconomics = 10055, // 财经
    EVoiceRecognitionPropertyGame = 10056, // 游戏
    EVoiceRecognitionPropertyCookbook = 10057, // 菜谱
    EVoiceRecognitionPropertyAssistant = 10058, // 助手
    EVoiceRecognitionPropertyRecharge = 10059, // 话费充值
    EVoiceRecognitionPropertyMap = 10060,  // 地图
    EVoiceRecognitionPropertyInput = 20000, // 输入
} TBDVoiceRecognitionProperty;

// 枚举 - 播放录音提示音
enum TVoiceRecognitionPlayTones
{
    EVoiceRecognitionPlayTonesRecStart = 1,                 // 录音开始提示音
    EVoiceRecognitionPlayTonesRecEnd = 2,                   // 录音结束提示音
    //所有日志打开
    EVoiceRecognitionPlayTonesAll = (EVoiceRecognitionPlayTonesRecStart | EVoiceRecognitionPlayTonesRecEnd )
};

// 枚举 - 调用启动语音识别，返回结果（startVoiceRecognition）
enum TVoiceRecognitionStartWorkResult
{
    EVoiceRecognitionStartWorking = 2000,                    // 开始工作
    EVoiceRecognitionStartWorkNOMicrophonePermission,        // 没有麦克风权限
    EVoiceRecognitionStartWorkNoAPIKEY,                      // 没有设定应用API KEY
    EVoiceRecognitionStartWorkGetAccessTokenFailed,          // 获取accessToken失败
    EVoiceRecognitionStartWorkNetUnusable,                   // 当前网络不可用
    EVoiceRecognitionStartWorkDelegateInvaild,               // 没有实现MVoiceRecognitionClientDelegate中VoiceRecognitionClientWorkStatus方法,或传入的对像为空
    EVoiceRecognitionStartWorkRecorderUnusable,              // 录音设备不可用
    EVoiceRecognitionStartWorkPreModelError,                 // 启动预处理模块出错
    EVoiceRecognitionStartWorkPropertyInvalid,               // 设置的识别属性无效
};

// 枚举 - 设置识别语言
enum TVoiceRecognitionLanguage
{
    EVoiceRecognitionLanguageChinese = 0,  // 普通话
    EVoiceRecognitionLanguageCantonese,    //广东话
    EVoiceRecognitionLanguageEnglish,      //美式英语
    EVoiceRecognitionLanguageSichuanDialect, //四川方言
};


/**************************************[end] come form BDVoiceRecognitionClient.h*********************************************************/

typedef enum TVoiceRecognitionLanguage E_TVoiceRecognitionLanguage;

#endif



#ifndef YVVIOCEPCMDATARECOGNIZE_PROTOCOL
#define YVVIOCEPCMDATARECOGNIZE_PROTOCOL

#pragma mark - 

@protocol YvVoicePcmDataRecognizerManageDelegate <NSObject>

/*语音识别结束后返回的最终识别文字*/
-(void)onVoicePcmDataRecognition_FinishRecognizeTextResp:(NSString*)text;

/**在识别过程中连续上屏的文字*/
-(void)onVoicePcmDataRecognition_ContinuousRecognizeTextResp:(NSString *)continuousText;

/* 识别过程中错误的错误码:  (aStatus: 枚举enum TVoiceRecognitionClientErrorStatusClass)  (aSubStatus: 枚举enum TVoiceRecognitionClientErrorStatus)*/
-(void)onVoicePcmDataRecognition_VoiceRecognitionClientErrorStatus:(int) aStatus subStatus:(int)aSubStatus;

@end


@protocol YvRecognizerProtocol <NSObject>

/**
 * @brief 初始化识别器,设置识别出来的文字信息回调的delegate
 * 
 * @param recognizeLanguage 识别语言类型
   @param delegate 识别出来的文字信息回调的delegate (弱引用)
 *
 */
-(void)setUpVoicePcmRecognizerWithRecognizeLanguage:(E_TVoiceRecognitionLanguage)recognizeLanguage OutputLanguageType: (E_OutputLanguageType)outputTextLanguageType Delegate:(id<YvVoicePcmDataRecognizerManageDelegate>)delegate;


/**
 * @brief 重设置识别出来的文字信息回调的delegate
 *
 * @param delegate 识别出来的文字信息回调的delegate (弱引用)
 *
 */
-(void)reSetDelegate:(id<YvVoicePcmDataRecognizerManageDelegate>)delegate;


/**
 * @brief 开始识别
 *
 * @return 状态码 状态码 (请参考 枚举enum TVoiceRecognitionStartWorkResult)
 */
- (int)startVoicePcmDataRecognition;

/**
 * @brief 向识别器发送数据
 *
 * @param data 发送的数据
 */
- (void)sendVoicePcmDataToRecognizer:(NSData *)pcmData;

/**
 * @brief 数据发送完成
 */
- (void)allVoicePcmDataHasSent;


/**
 * @brief 释放资源(释放资源后再使用需要重新初始化)
 */
-(void)releaseInstance;


@end

#endif
