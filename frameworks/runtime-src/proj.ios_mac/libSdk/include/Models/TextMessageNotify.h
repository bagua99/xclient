//
//  TextMessageNotify.h
//  ChatSDK
//
//  Created by 朱文腾 on 14-8-18.
//  Copyright (c) 2014年 yunva.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextMessageNotify : NSObject

@property (assign, nonatomic) UInt32 yunvaId;
@property (retain, nonatomic) NSString * chatRoomId;
@property (retain, nonatomic) NSString * text;
@property (assign, nonatomic) UInt64 time;
@property (retain, nonatomic) NSString * expand;


- (NSString *)jsonString;
- (NSDictionary *)getObjectDictionary;

@end
