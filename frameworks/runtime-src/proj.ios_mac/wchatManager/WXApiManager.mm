//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"
#include "extensFunction.h"

@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

- (void)dealloc
{
    self.delegate = nil;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {

    
    NSLog(@"**onResp**");
    
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        
        
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvMessageResponse:)]) {
            SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
            [_delegate managerDidRecvMessageResponse:messageResp];
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        
        if (resp.errCode == WXErrCodeUserCancel) {
           // CCEventDispatcher::instance()->notifyEvent(EVENT_CLOSE_PROGRESS, NULL);
            return;
        }

        NSLog(@"**lua_wxlogin_over12**");
        SendAuthResp *authResp = (SendAuthResp *)resp;
     //   NSLog(@"%@,%@,%d",authResp.code, authResp.state, authResp.errCode);
        
        std::string *wx_code = new std::string([authResp.code UTF8String]);  
        cocos2d::UserDefault::getInstance()->setStringForKey("wx_code",wx_code->c_str());
        cocos2d::Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("CUSTOMMSG_WXCODE");



        /*
        NSString* url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",wAppID, wAppKey, authResp.code];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:20.0];
        request.HTTPShouldHandleCookies = NO;
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error != nil) {
                // 提示框
                return ;
            }
            NSLog(@"**lua_wxlogin_over1**");
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (resultDic) {
                NSString* access_token = [resultDic objectForKey:@"access_token"];
                NSString* openid        = [resultDic objectForKey:@"openid"];
                NSString* refresh_token = [resultDic objectForKey:@"refresh_token"];
                NSString* unionid = [resultDic objectForKey:@"unionid"];

                //  add new code
                if (access_token && openid && refresh_token && unionid) {
                    
                    NSLog(@"**lua_wxlogin_over**");
                    extensFunction::getInstance()->lua_wxlogin_over([access_token UTF8String], [openid UTF8String],
                                                                        [refresh_token UTF8String], [unionid UTF8String]);
            }
            
        }];
        [task resume];
        */

        
        
        
    } else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAddCardResponse:)]) {
            AddCardToWXCardPackageResp *addCardResp = (AddCardToWXCardPackageResp *)resp;
            [_delegate managerDidRecvAddCardResponse:addCardResp];
        }
    }
}

- (void)onReq:(BaseReq *)req
{
    NSLog(@"**onReq**");
    if ([req isKindOfClass:[GetMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvGetMessageReq:)]) {
            GetMessageFromWXReq *getMessageReq = (GetMessageFromWXReq *)req;
            [_delegate managerDidRecvGetMessageReq:getMessageReq];
        }
    } else if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvShowMessageReq:)]) {
            ShowMessageFromWXReq *showMessageReq = (ShowMessageFromWXReq *)req;
            [_delegate managerDidRecvShowMessageReq:showMessageReq];
        }
    } else if ([req isKindOfClass:[LaunchFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvLaunchFromWXReq:)]) {
            LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
            [_delegate managerDidRecvLaunchFromWXReq:launchReq];
        }
    }
}

@end
