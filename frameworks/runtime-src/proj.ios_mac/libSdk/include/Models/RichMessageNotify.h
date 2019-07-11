//
//  RichMessageNotify.h
//  ChatSDK
//  (文本+语音)消息
//  Created by huangzj on 15/1/27.
//  Copyright (c) 2015年 com.yunva.yaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextMessageNotify.h"
#import "VoiceMessageNotify.h"

@interface RichMessageNotify : NSObject

@property (nonatomic,retain) TextMessageNotify  * textMsg;
@property (nonatomic,retain) VoiceMessageNotify * voiceMsg;


- (NSString *)jsonString;
- (NSDictionary *)getObjectDictionary;

@end
