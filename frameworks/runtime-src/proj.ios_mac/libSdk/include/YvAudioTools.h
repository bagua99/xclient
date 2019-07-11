//
//  YvAudioTools.h
//  
//
//  Created by 朱文腾 on 14-7-13.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YvRecognizerProtocol.h"



@class YvAudioTools;

@protocol YvAudioToolsDelegate <NSObject>

@optional

#pragma mark 语音录制结束回调
/*!
 @callback
 @brief 功能：语音录制结束回调
 @param audiotools -- 接口对象
 @param voiceData -- 语音录制数据
 @param voiceDuration --语音时长
 @param filePath -- 语音录制数据保存文件
 @result YES:正在语音录制  NO:当前没有语音录制
 */
-(void)AudioTools:(YvAudioTools *)audiotools RecordCompleteWithVoiceData:(NSData *)voiceData voiceDuration:(int)voiceDuration filePath:(NSString *)filePath;

#pragma mark 语音播放结束回调
/**播放声音完毕*/
-(void)AudioToolsPlayComplete:(YvAudioTools *)audiotools WithResult:(int)result PlaySequenceId:(int)playSequenceId;//result: 0--成功播放  非0--播放失败  playSequenceId:播放id，是调用播放函数(playAudio:或playOnlineAudio:)的返回值。
-(void)AudioToolsPlayComplete:(YvAudioTools *)audiotools WithResult:(int)result;//result: 0--成功播放  非0--播放失败
-(void)AudioToolsPlayComplete:(YvAudioTools *)audiotools;



#pragma mark 屏幕贴近检测回调
/**在播放声音的时候当贴近屏幕的时候的状态事件，yes:贴近屏幕  no:没有贴近屏幕*/
-(void)AudioTools:(YvAudioTools *)audiotools ProximityStateChange:(BOOL)state;

#pragma mark 语音播放峰值和平均值回调
/**当开启播放声音和录音的计量检测,返回播放声音的峰值和平均值*/
-(void)AudioTools:(YvAudioTools *)audiotools PlayMeteringPeakPower:(float)peakPower AvgPower:(float)avgPower;

#pragma mark 语音录制峰值和平均值回调
/**当开启播放声音和录音的计量检测,返回录音的峰值和平均值*/
-(void)AudioTools:(YvAudioTools *)audiotools RecorderMeteringPeakPower:(float)peakPower AvgPower:(float)avgPower;

@end


@interface YvAudioTools : NSObject

@property (nonatomic,weak) id<YvAudioToolsDelegate> delegate;
@property (nonatomic,retain) NSString * RecordfilePath;//语音录制数据存储的存储到的文件
@property (nonatomic,assign) int Minseconds;//识别录音最短时间(录音少于该时间不做处理)
@property (nonatomic,assign) int Maxseconds;//识别录音最长时间(超过该时间会自动停止录制)
    
//播放声音时,是否开启屏幕贴近检测,sdk会自动切换播放模式,默认是yes
@property (nonatomic,assign) BOOL ProximityMonitoringEnabled;
/**是否开启播放声音和录音时的计量检测,默认no*/
@property (nonatomic,assign) BOOL MeteringEnabled;

/**初始化音频工具默认参数
    recordfilePath:[NSTemporaryDirectory() stringByAppendingString:@"temp_audio.amr"] 
    minseconds:2 
    maxseconds:30 */
-(instancetype)initWithDelegate:(id<YvAudioToolsDelegate>)adelegate;

-(instancetype)initWithDelegate:(id<YvAudioToolsDelegate>)adelegate recordfilePath:(NSString *)recordfilePath minseconds:(int)minseconds maxseconds:(int)maxseconds;

#pragma mark - --语音录制
/*!
 @method
 @brief 开始语音录制
 */
-(void)startRecord;

/*!
 @method
 @brief 停止语音录制
 */
-(void)stopRecord;

/*!
 @method
 @brief 判断当前是否正在语音录制
 @result YES:正在语音录制  NO:当前没有语音录制
 */
-(BOOL)isRecording;

#pragma mark - --语音播放
/*!
 @method
 @brief 播放本地语音文件
 @param filePath 文件本地全路径(amr文件的地址)
 @result 播放顺序id(playSequenceId),播放结束回调函数有该值。
 */
-(int)playAudio:(NSString *)filePath;

/*!
 @method
 @brief 播放url语音文件
 @param fileurl 语音文件下载url
 @result 播放顺序id(playSequenceId),播放结束回调函数有该值。
 */
-(int)playOnlineAudio:(NSString *)fileurl;

/*!
 @method
 @brief 播放url语音文件(带进度/完成回调)
 @param fileurl 语音文件下载url
 @param downloadProgressBlock 下载进度回调 totalSize-文件总大小 progressSize-已下载大小 fileurl-文件url playSequenceId - 播放顺序id
 @param downloadFinishedBlock 下载完成回调 result-0:下载成功 其他:下载失败 errMsg-失败信息 fileurl-文件url playSequenceId - 播放顺序id
 @result 播放顺序id(playSequenceId),播放结束回调函数有该值。
 */
-(int)playOnlineAudio:(NSString *)fileurl
    downloadProgress:(void (^)(int totalSize, int progressSize, NSString * fileurl, int playSequenceId))downloadProgressBlock
    downloadFinished:(void (^)(int result, NSString * errMsg, NSString * fileurl, int playSequenceId))downloadFinishedBlock;

/*!
 @method
 @brief 停止播放
 */
-(void)stopPlayAudio;

/*!
 @method
 @brief 判断当前是否正在播放
 @result YES:正在播放  NO:没有播放
 */
-(BOOL)isPlaying;


#pragma mark - 需要识别录制的语音设置的识别插件(YvVoicePcmDataRecognizerManage 设置初始化后放入)
/*****************语音录制同时语音识别专用******************/
/*语音识别设置的插件(插件需要初始化后再设置进来)*/
-(void)setRecognizerPlugin:(id<YvRecognizerProtocol>)recognizePluginDelegate;

/**开始语音识别，同时返回文字, 识别的文字回调由YvVoicePcmDataRecognizerManageDelegate 实现*/
-(int)startRecordAndRecognize;

/**录制+语音识别结束*/
-(void)stopRecordAndRecognize;
/***********************************/



#pragma mark -
/*!
 是否sdk自动控制录制模式(默认YES:自动控制)
 自动控制录制模式: 1)用户调用开始语音录制接口，sdk调用设置为AVAudioSessionCategoryPlayAndRecord
 2)录制结束后， sdk自动恢复为 设置录制模式前的模式(一般为AVAudioSessionCategorySoloAmbient)
 
 非自动控制录制模式: 1）集成者需要手动调用设置录制模式接口为YES，才能录制和识别功能。 2）不使用语音录制和识别功能，则关闭录制模式(录制模式会导致app静音键无法使用)
 
 注释:
 1.在录制模式(Category:PlayAndRecord)中，IOS才提供录制语音功能，但是会出现一个现象--静音键无法静音，所以在不需要录制功能时，恢复非录制模式
 2.<录制模式> <---> <非录制模式>  两个模式之间的切换时刻, IOS操作系统会有卡顿(没有背景音乐体现不出来)，如果有背景音乐情况下，卡顿很明显，我们给的方案就是设置isAutoSetRecordCategory 为 NO(集成者自己控制录制模式)，然后进入聊天室就手动设置录制模式[setRecordCategory:YES]，退出聊天室就设置为非录制模式
 
 @param isAutoSetRecordCategory YES:SDK自动控制录制模式  NO: SDK非自动控制录制模式(也可以理解为:手动控制录制模式)
 */
-(void)setIsAutoSetRecordCategory:(BOOL)isAutoSetRecordCategory;
-(void)setRecordCategory:(BOOL)isRecordCategory;

@end
