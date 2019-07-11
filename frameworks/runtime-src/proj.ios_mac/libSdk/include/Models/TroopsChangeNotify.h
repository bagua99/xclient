//
//  YvTroopsUserListChangeNotify.h
//  ChatSDK
//
//  Created by Apple on 2017/5/4.
//  Copyright © 2017年 com.yunva.yaya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TroopsChangeNotify : NSObject
@property(nonatomic, copy)NSString* seq;
@property(nonatomic, assign)UInt32 yunvaId;
@property(nonatomic, copy) NSString* userInfo;
@property(nonatomic, copy) NSString* actionType;

- (NSString *)jsonString;
- (NSDictionary *)getObjectDictionary;
@end
