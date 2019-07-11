//
//  MyWebView.m
//

#import "MyWebView.h"

@interface MyWebView () <UIWebViewDelegate>

@end

@implementation MyWebView


#pragma mark - Life Circle Method
- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
    }
    return self;
}


#pragma mark - Private Method
+ (void)openURL:(NSURL *)object complete:(void(^)(BOOL))complete
{
    UIApplication *application = nil;
    application = [UIApplication sharedApplication];
    SEL selector = @selector(openURL:options:completionHandler:);
    if ([UIApplication instancesRespondToSelector:selector])
    {
#ifdef __IPHONE_10_0
        [application openURL:object
                     options:[NSDictionary dictionary]
           completionHandler:complete];
#else
        if (complete) {
            complete([application openURL:object]);
        }
#endif
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (complete) {
            complete([application openURL:object]);
        }
#pragma clang diagnostic pop
    }
}

- (BOOL)isOpenAppSpecialURLValue:(NSString *)string
{
    if ([string hasPrefix:@"http://"]) {
        return NO;
    } else if ([string hasPrefix:@"https://"]) {
        return NO;
    }
    return YES;
}


#pragma mark - UIWebViewDelegate Method
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *absoluteString = request.URL.absoluteString;
    if ([self isOpenAppSpecialURLValue:absoluteString]) {
        //空白地址就直接返回不执行加载
        if ([absoluteString hasPrefix:@"about:blank"]) {
            return NO;
        }
        
        //非http和https开头的链接就使用OpenURL方法打开
        [[self class] openURL:request.URL complete:^(BOOL status) {
            if (self.openComplete) {
                self.openComplete(absoluteString, status);
            }
        }];
        return NO;
    }
    
    //将代理传递到下一个代理对象
    if (self.webViewDelegate) {
        return [self.webViewDelegate webView:self
                  shouldStartLoadWithRequest:request
                              navigationType:navigationType];
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (self.webViewDelegate) {
        [self.webViewDelegate webViewDidStartLoad:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.webViewDelegate) {
        [self.webViewDelegate webViewDidFinishLoad:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (self.webViewDelegate) {
        [self.webViewDelegate webView:self didFailLoadWithError:error];
    }
}


@end

