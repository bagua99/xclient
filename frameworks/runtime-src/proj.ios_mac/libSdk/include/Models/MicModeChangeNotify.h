//
//  MicModeChangeNotify.h
//  ChatSDK
//
//  Created by 朱文腾 on 14-9-4.
//  Copyright (c) 2014年 yunva.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MicModeChangeNotify : NSObject


//0自由模式，1抢麦模式，2指挥模式
@property (assign, nonatomic) UInt8 modeType;
//自己是否是队长
@property (assign, nonatomic) BOOL isLeader;


- (NSString *)jsonString;
- (NSDictionary *)getObjectDictionary;

@end
