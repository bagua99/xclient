//
//  MyWebView.h
//
//

#import <UIKit/UIKit.h>


#pragma mark - MyWebViewDelegate
@protocol MyWebViewDelegate <NSObject>

@optional
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end


@interface MyWebView : UIWebView


@property (nonatomic, assign) id<MyWebViewDelegate> webViewDelegate;


@property (nonatomic, copy) void(^openComplete)(NSString *string,BOOL status);


@end

