//
//  UserStateNotify.h
//  ChatSDK
//
//  Created by 朱文腾 on 14-8-27.
//  Copyright (c) 2014年 yunva.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserStateNotify : NSObject

@property (assign, nonatomic) UInt32 yunvaId;
@property (retain, nonatomic) NSString* chatRoomId;
//1是send,2是receiver
@property (assign, nonatomic) UInt8 type;

//11表示语音、文字都开启；00表示语音、文字都关闭 ；前面的表示语音，后面的表示文字，1表示开启，0表示关闭
//00表示全空，右边第一位是文字，左边是实时语音
@property (retain, nonatomic) NSString* state;
@property (retain, nonatomic) NSString* msg;


- (NSString *)jsonString;
- (NSDictionary *)getObjectDictionary;

@end
