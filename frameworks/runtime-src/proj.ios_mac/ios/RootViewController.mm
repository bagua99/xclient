/****************************************************************************
 Copyright (c) 2010-2011 cocos2d-x.org
 Copyright (c) 2010      Ricardo Quesada
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "RootViewController.h"
#import "cocos2d.h"
#import "platform/ios/CCEAGLView-ios.h"
#include "ide-support/SimpleConfigParser.h"

 //sdk引用头文件
#import "YvChatManage.h"
#import "YvAudioTools.h" 

#import <AVFoundation/AVFoundation.h>

#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"

#import "WXApiManager.h"
#import "WXApi.h"

#import "MyWebView.h"

#import <CoreLocation/CoreLocation.h>

static RootViewController* s_instance = nil;
static int _scriptHandler1 = 0  ;
static int _scriptHandler2 = 0  ;
static int _scriptHandler3 = 0  ;
static int _scriptHandler4 = 0  ;
static NSString * g_filePath;

#define PI 3.1415926

@interface RootViewController ()<YvAudioToolsDelegate, CLLocationManagerDelegate, WXApiDelegate,MyWebViewDelegate>
{
   MyWebView *meWebView;
}
@property (nonatomic, strong) YvAudioTools *audioTools;             // 云娃语音工具
@property (nonatomic, strong) CLLocationManager *_locationManager;  // 定位服务管理类
@property (nonatomic, strong) CLGeocoder *_geocoder;                // 初始化地理编码器

@end
@implementation RootViewController

+ (RootViewController*) getInstance
{
    if (!s_instance)
    {
        s_instance = [RootViewController alloc];
    }
    return s_instance;
}

+ (void) destroyInstance
{
    [s_instance release];
}

+ (void) playRecordByFile:(NSDictionary *)dict
{
    _scriptHandler2 =  [[dict objectForKey:@"recordStart"] intValue];
    _scriptHandler3 =  [[dict objectForKey:@"recordFinish"] intValue];
    [[RootViewController getInstance] playRecordByFile_:dict];
}

+ (void) playRecord:(NSDictionary *)dict
{
    _scriptHandler2 =  [[dict objectForKey:@"recordStart"] intValue];
    _scriptHandler3 =  [[dict objectForKey:@"recordFinish"] intValue];
    [[RootViewController getInstance] playRecordByUrl:dict];
}

- (void) playRecordByUrl:(NSDictionary *)dict
{
    NSLog(@"playRecordByUrl");
    NSString *voiceUrl = [dict objectForKey:@"url"];
    [self.audioTools playOnlineAudio:voiceUrl];
}

- (void) playRecordByFile_:(NSDictionary *)dict
{
    [self.audioTools playAudio:g_filePath];
}

+ (void) record:(NSDictionary *)dict
{
    [[RootViewController getInstance] record_:dict];
}

+ (void) stopRecord:(NSDictionary *)dict
{
    [[RootViewController getInstance] stopRecord_:dict];
}

- (void) record_:(NSDictionary *)dict
{
    NSLog(@" start record....");
    NSDateFormatter * datefmt =[[NSDateFormatter alloc]init];
    [datefmt setDateFormat:@"yyyy-MM-dd-HH:mm:ss.SSS"];
    NSString * dateamr = [datefmt stringFromDate:[NSDate date]];
    NSString *path = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.amr",dateamr];
    self.audioTools.RecordfilePath = path;
    [self.audioTools startRecord];
    _scriptHandler1 =  [[dict objectForKey:@"scriptHandler"] intValue];
}

- (void) stopRecord_:(NSDictionary *)dict
{
    NSLog(@" stop record....");
    [self.audioTools stopRecord];
}

#pragma mark - /----------------------YvChatManage(SDK初始化 实时语音 收发消息 语音识别+文件上传)-----------------/

#pragma mark 初始化
-(void)__ChatManage_initWithAppId:(NSString *)appid isTest:(BOOL)isTest
{
     [[YvChatManage sharedInstance] SetInitParamWithAppId:appid istest:isTest];
}

// Override to allow orientations other than the default portrait orientation.
// This method is deprecated on ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (SimpleConfigParser::getInstance()->isLanscape()) {
        return UIInterfaceOrientationIsLandscape( interfaceOrientation );
    }else{
        return UIInterfaceOrientationIsPortrait( interfaceOrientation );
    }
}

// For ios6, use supportedInterfaceOrientations & shouldAutorotate instead
- (NSUInteger) supportedInterfaceOrientations{
#ifdef __IPHONE_6_0
    if (SimpleConfigParser::getInstance()->isLanscape()) {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
#endif
}

- (BOOL) shouldAutorotate {
    if (SimpleConfigParser::getInstance()->isLanscape()) {
        return YES;
    }else{
        return NO;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    cocos2d::GLView *glview = cocos2d::Director::getInstance()->getOpenGLView();

    if (glview)
    {
        CCEAGLView *eaglview = (CCEAGLView*) glview->getEAGLView();

        if (eaglview)
        {
            CGSize s = CGSizeMake([eaglview getWidth], [eaglview getHeight]);
            cocos2d::Application::getInstance()->applicationScreenSizeChanged((int) s.width, (int) s.height);
        }
    }
}

#pragma mark YvAudioTools初始化
//YvAudioTools初始化
-(void)__YvAudioTools_Init:(NSDictionary *)dict
{
    self.audioTools = [[YvAudioTools alloc] initWithDelegate:self];
}

#pragma mark - SDK 初始化
-(void) __chatSDK_Init:(NSDictionary *)dict
{
    self.AppId = @"1001730";
    self.isTest = false;
    self.Seq = nil ;
    [self __ChatManage_initWithAppId:self.AppId isTest:self.isTest];
}

//fix not hide status on ios7
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - /----------------------YvAudioToolsDelegate(YvAudioTools的回调函数)-----------------/
#pragma mark 语音录制结束-回调
/*!
 @callback
 @brief 功能：语音录制结束回调
 @param audiotools -- 接口对象
 @param voiceData -- 语音录制数据
 @param voiceDuration --语音时长
 @param filePath -- 语音录制数据保存文件
 @result YES:正在语音录制  NO:当前没有语音录制
 */
-(void)AudioTools:(YvAudioTools *)audiotools RecordCompleteWithVoiceData:(NSData *)voiceData voiceDuration:(int)voiceDuration filePath:(NSString *)filePath
{
    NSLog(@"record audio success");
    g_filePath = filePath;
    // [self.audioTools playAudio:filePath];
    __weak __typeof(&*self)weakSelf = self;
    [self __ChatManage_uploadVoiceFile:filePath success:^(NSString *voiceUrl) {
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        if (!strongSelf)
        {
            return;
        }
        //voiceMsg.voiceUrl = voiceUrl;
        //[strongSelf deleteFile:filePath];//删除已上传的文件
        //发送纯语音消息
        [strongSelf __ChatManage_sendVoiceMessageWithVoiceUrl:voiceUrl voiceDuration:voiceDuration expand:nil];

            LuaBridge::pushLuaFunctionById(_scriptHandler1);
            LuaStack *stack = LuaBridge::getStack();
            std::string *url = new std::string([voiceUrl UTF8String]);  
            stack->pushString(url->c_str());
            stack->executeFunction(1);

        } failure:^(NSError *error) {  
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            //[strongSelf closeActivityIndicatorWithUniqueId:uniqueId];
            NSString * msg = [NSString stringWithFormat:@"网络错误code=%d,", error.code];
            //[strongSelf showSendErrorWithUniqueId:uniqueId];
            [strongSelf  showAlertViewTitle:@"【上传语音文件】失败" message:msg];
        }];
}

#pragma mark 发送纯语音消息
-(void)__ChatManage_sendVoiceMessageWithVoiceUrl:(NSString *)voiceUrl voiceDuration:(int)voiceDuration expand:(NSString *)expand
{
    [[YvChatManage sharedInstance] sendVoiceMessageWithVoiceUrl:voiceUrl voiceDuration:voiceDuration expand:expand];
}

#pragma mark 语音播放结束-回调
/**播放声音完毕*/
-(void)AudioToolsPlayComplete:(YvAudioTools *)audiotools WithResult:(int)result PlaySequenceId:(int)playSequenceId
{
    LuaBridge::pushLuaFunctionById(_scriptHandler3);
    LuaStack *stack = LuaBridge::getStack();
    stack->pushString("success");
    stack->executeFunction(1);
}

#pragma mark 语音录制峰值和平均值-回调
/**当开启播放声音和录音的计量检测,返回录音的峰值和平均值*/
-(void)AudioTools:(YvAudioTools *)audiotools RecorderMeteringPeakPower:(float)peakPower AvgPower:(float)avgPower
{
    LuaBridge::pushLuaFunctionById(_scriptHandler2);
    LuaStack *stack = LuaBridge::getStack();
    stack->pushString("success");
    stack->executeFunction(1);
}

#pragma mark 上传语音文件
-(void)__ChatManage_uploadVoiceFile:(NSString *)voiceFilePath
                            success:(void (^)(NSString * voiceUrl))success
                            failure:(void (^)( NSError *error))failure
{
    E_UploadFile_Retain_Time fileRetainTimeType = kUploadFile_Retain_Time_2_week;//上传文件保存时间 2星期
    
    [[YvChatManage sharedInstance] uploadVoiceMessage:voiceFilePath retainTimeType:fileRetainTimeType success:success failure:failure];
}

+ (void) initSDK:(NSDictionary *)dict
{
    [[RootViewController getInstance] __YvAudioTools_Init:dict];
    [[RootViewController getInstance] __chatSDK_Init:dict];
}

-(void) __initLoctionSDK:(NSDictionary *)dict
{
    // 初始化定位管理器
    self._locationManager = [[CLLocationManager alloc] init];
    [self._locationManager requestWhenInUseAuthorization];
    //[_locationManager requestAlwaysAuthorization];//iOS8必须，这两行必须有一行执行，否则无法获取位置信息，和定位
    // 设置代理
    self._locationManager.delegate = self;
    // 设置定位精确度到米
    self._locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // 设置过滤器为无
    self._locationManager.distanceFilter = kCLDistanceFilterNone;
    //初始化地理编码器
    self._geocoder = [[CLGeocoder alloc] init];
}

+ (void) initLoctionSDK:(NSDictionary *)dict
{
    [[RootViewController getInstance] __initLoctionSDK:dict];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    NSLog(@"%lu",(unsigned long)locations.count);
    CLLocation *location = locations.lastObject;
    //NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f", location.coordinate.longitude, location.coordinate.latitude,location.altitude,location.course,location.speed);
    
    std::string *adds = new std::string();
    [self._geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            // 国家
            if (placemark.country != nil)
                adds->append([placemark.country UTF8String]);
            // 区
            if (placemark.subLocality != nil)
                adds->append([placemark.subLocality UTF8String]);
            // 市
            if (placemark.locality != nil)
                adds->append([placemark.locality UTF8String]);
            // 子街道
            if (placemark.subThoroughfare != nil)
                adds->append([placemark.subThoroughfare UTF8String]);
            // 街道
            if (placemark.thoroughfare != nil)
                adds->append([placemark.thoroughfare UTF8String]);
                
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:@(location.coordinate.latitude) forKey:@"latitude"];
            [dictionary setValue:@(location.coordinate.longitude) forKey:@"longitude"];
            [dictionary setValue:@(adds->c_str()) forKey:@"addr"];
            NSError *error = nil;
            //转成JSON
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
            if (error)
            {
                NSLog(@"dic->%@",error);
            }
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            std::string *str = new std::string([jsonString UTF8String]);
            LuaBridge::pushLuaFunctionById(_scriptHandler4);
            LuaStack *stack = LuaBridge::getStack();
            stack->pushString(str->c_str());
            stack->executeFunction(1);
        }else if (error == nil && [placemarks count] == 0) {
            NSLog(@"No results were returned.");
        } else if (error != nil){
            NSLog(@"An error occurred = %@", error);
        }
    }];
    // 停止定位
    [self._locationManager stopUpdatingLocation];
}

- (void) __startLocation
{
    // 开始定位
    [self._locationManager startUpdatingLocation];
}

- (void) __stopLocation
{
    // 停止定位
    [self._locationManager stopUpdatingLocation];
}

+ (void) startLocation:(NSDictionary *)dict
{
    _scriptHandler4 = [[dict objectForKey:@"scriptHandler"] intValue];
    [[RootViewController getInstance] __startLocation];
}

+ (void) stopLocation
{
    [[RootViewController getInstance] __stopLocation];
}

//计算距离
+ (void) getDistance:(NSDictionary *)dict
{
    float longitude1 =  [[dict objectForKey:@"longitude11"] floatValue];
    float latitude1 =  [[dict objectForKey:@"latitude11"] floatValue];
    float longitude2 =  [[dict objectForKey:@"longitude21"] floatValue];
    float latitude2 =  [[dict objectForKey:@"latitude21"] floatValue];
    double er = 6378137; // 6378700.0f;
    double radlat1 = PI*latitude1/180.0f;
    double radlat2 = PI*latitude2/180.0f;
    //now long.
    double radlong1 = PI*longitude1/180.0f;
    double radlong2 = PI*longitude2/180.0f;
    if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;

    NSString* ss =  [NSString stringWithFormat:@"%f", dist]; 
    std::string *distance = new std::string([ss UTF8String]);  
    // getDistanceFinish
    int _scriptHandler5 =  [[dict objectForKey:@"getDistanceFinish"] intValue];
    LuaBridge::pushLuaFunctionById(_scriptHandler5);
    LuaStack *stack = LuaBridge::getStack();
    stack->pushString(distance->c_str());
    stack->executeFunction(1);
}

- (void)onResp:(BaseResp *)resp {
    NSLog(@"BaseResp_onResp");
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation {
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //向微信注册
    NSLog(@"didFinishLaunchingWithOptions");
    [WXApi registerApp:@"wx17eaba1ec30075bd" enableMTA:YES];
    //向微信注册支持的文件类型
    UInt64 typeFlag = MMAPP_SUPPORT_TEXT | MMAPP_SUPPORT_PICTURE | MMAPP_SUPPORT_LOCATION | MMAPP_SUPPORT_VIDEO |MMAPP_SUPPORT_AUDIO | MMAPP_SUPPORT_WEBPAGE | MMAPP_SUPPORT_DOC | MMAPP_SUPPORT_DOCX | MMAPP_SUPPORT_PPT | MMAPP_SUPPORT_PPTX | MMAPP_SUPPORT_XLS | MMAPP_SUPPORT_XLSX | MMAPP_SUPPORT_PDF;
    [WXApi registerAppSupportContentFlag:typeFlag];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"handleOpenURL");
    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

+(void) openUIWebView:(NSDictionary *)dict
{
    [[RootViewController getInstance] openWebView:dict];
}

-(void) openWebView:(NSDictionary *)dict
{
    NSLog(@"openWebView");
    cocos2d::GLView *glview = cocos2d::Director::getInstance()->getOpenGLView();
    if (glview)
    {
        CCEAGLView *eaglview = (CCEAGLView*) glview->getEAGLView();
        if (eaglview)
        {
			UIViewAutoresizing autoresizingMask;
			autoresizingMask = UIViewAutoresizingFlexibleWidth;
			autoresizingMask |= UIViewAutoresizingFlexibleHeight;
    
			//创建WebView对象展示H5网页
			meWebView = [[MyWebView alloc] init];
			meWebView.frame = CGRectMake(0, 0, 0, 0);
            
			meWebView.scalesPageToFit = YES;
			meWebView.webViewDelegate = self;
			meWebView.dataDetectorTypes = YES;
			meWebView.autoresizingMask = autoresizingMask;
			
            NSMutableURLRequest *request = nil;
            NSString *url1 = [dict objectForKey:@"url"];
            const char *cString2 = [url1 UTF8String];
            NSLog(@"openWebView%s",cString2);

            NSURL *url = [NSURL URLWithString:url1];
            request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
            request.timeoutInterval = 15.0f;
            [meWebView setUserInteractionEnabled:YES];
            [meWebView loadRequest:request];

            [eaglview addSubview:meWebView];

        }
    }
    
}

#pragma mark - MyWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //在此处截取链接获取支付结果
    NSString *absoluteString = request.URL.absoluteString;
    if ([absoluteString hasPrefix:@"支付成功后跳转的链接"]) {
        //在此处提示支付成功的支付结果
         NSLog(@"success");
        return NO;
    } else if ([absoluteString hasPrefix:@"支付失败后跳转的链接"]) {
        //在此处提示支付失败的支付结果
         NSLog(@"faild");
        return NO;
    } else if ([absoluteString hasPrefix:@"支付取消后跳转的链接"]) {
        //在此处提示支付取消的支付结果
         NSLog(@"faild");
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");   
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
     NSLog(@"didFailLoadWithError");
}
    
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
}

@end
