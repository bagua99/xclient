//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 15/7/14.
//
//

#import "WXApiRequestHandler.h"
#import "WXApiManager.h"

@implementation WXApiRequestHandler

#pragma mark - Public Methods


+ (BOOL)sendAuthRequestScope:(NSString *)scope
                       State:(NSString *)state
            InViewController:(UIViewController *)viewController {
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = scope; // @"post_timeline,sns"
    req.state = state;
    
    return [WXApi sendAuthReq:req
               viewController:viewController
                     delegate:[WXApiManager sharedManager]];
}

@end
