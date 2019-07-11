#include "extensFunction.h"
#if (CC_TARGET_PLATFORM     == CC_PLATFORM_IOS)
#import "AppController.h"
#endif

extern "C"{
#include "md5/md5.h"
}
#include "network/HttpClient.h"

USING_NS_CC;
using namespace network;
static extensFunction* s_sharedExtensFunction = nullptr;

#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import "WXApi.h"
#import "WXApiObject.h"
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include "platform/android/jni/JniHelper.h"

extern "C"
{
	/////////////////////////////////// lua call c++ ///////////////////////////////////
	// 微信登陆
	void callJavawxLogin()
	{
		JniMethodInfo t;
		if(JniHelper::getStaticMethodInfo(t, "com/hnqp/pdkgame/AppActivity", "wxLogin", "()V"))
		{
			t.env->CallStaticVoidMethod(t.classID, t.methodID);
		}
	}

	// 邀请好友
	void callJavaInviteFriend(int nType, const char *pstrTitle, const char *pstrContent, const char *pstrPng, const char *pstrUrl)
	{
		JniMethodInfo t;
		if (JniHelper::getStaticMethodInfo(t, "com/hnqp/pdkgame/AppActivity", "inviteFriend", "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"))
		{
			jint jnType = (int)nType;
			jstring strTitle = t.env->NewStringUTF(pstrTitle);
			jstring strContent = t.env->NewStringUTF(pstrContent);
			jstring strPng = t.env->NewStringUTF(pstrPng);
			jstring strUrl = t.env->NewStringUTF(pstrUrl);
			t.env->CallStaticVoidMethod(t.classID, t.methodID, jnType, strTitle, strContent, strPng, strUrl);
		}
	}

	// 分享战绩
	void callJavaShareZhanJi(int nType, const char *pstrContent)
	{
		JniMethodInfo t;
		if (JniHelper::getStaticMethodInfo(t, "com/hnqp/pdkgame/AppActivity", "shareZhanJi", "(ILjava/lang/String;)V"))
		{
			jint jnType = (int)nType;
			jstring strContent = t.env->NewStringUTF(pstrContent);
			t.env->CallStaticVoidMethod(t.classID, t.methodID, jnType, strContent);
		}
	}

	// 分享结算
	void callJavaShareResult(int nType, const char *pstrTitle, const char *pstrContent, const char *pstrPng, const char *pstrUrl)
	{
		log("callJavaShareResult Success");
		JniMethodInfo t;
		if (JniHelper::getStaticMethodInfo(t, "com/hnqp/pdkgame/AppActivity", "shareResult", "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"))
		{
			jint jnType = (int)nType;
			jstring strTitle = t.env->NewStringUTF(pstrTitle);
			jstring strContent = t.env->NewStringUTF(pstrContent);
			jstring strPng = t.env->NewStringUTF(pstrPng);
			jstring strUrl = t.env->NewStringUTF(pstrUrl);
			t.env->CallStaticVoidMethod(t.classID, t.methodID, jnType, strTitle, strContent, strPng, strUrl);
		}
	}


	/////////////////////////////////// java call c++ ///////////////////////////////////
	// 微信请求
	void Java_com_hnqp_pdkgame_AppActivity_noticewxCode(JNIEnv *env, jobject thiz, jstring jsCode)
	{
		log("noticewxCode Success");
		const char *Code = env->GetStringUTFChars(jsCode, NULL);
		UserDefault::getInstance()->setStringForKey("wx_code", Code);
		Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("CUSTOMMSG_WXCODE");
	}

	// 微信取消
	void Java_com_hnqp_pdkgame_AppActivity_noticewxCancel(JNIEnv *env, jobject thiz)
	{
		log("noticeWeChatCancel");
		Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("CUSTOMMSG_WXCANCEL");
	}
}
#endif

extensFunction::extensFunction()
{
	m_strFileName.clear();
	m_strCopyStr.clear();
}

extensFunction::~extensFunction()
{

}

extensFunction* extensFunction::getInstance()
{
	if (!s_sharedExtensFunction)
	{
		s_sharedExtensFunction = new (std::nothrow) extensFunction();
	}

	return s_sharedExtensFunction;
}

// 取得文件md5
std::string extensFunction::md5File(const char *pstrFileName)
{
	FILE *file = fopen(pstrFileName, "rb");
	if (file == NULL)
		return "";

	MD5_CTX ctx;
	MD5_Init(&ctx);

	long i;
	const int BUFFER_SIZE = 1024;
	char buffer[BUFFER_SIZE];
	while ((i = fread(buffer, 1, BUFFER_SIZE, file)) > 0) {
		MD5_Update(&ctx, buffer, (unsigned)i);
	}

	fclose(file);
	unsigned char md5Info[16];
	MD5_Final(md5Info, &ctx);

	static const char* hextable = "0123456789abcdef";
	int binLength = 16;
	int hexLength = binLength * 2 + 1;
	char* hex = new char[hexLength];
	memset(hex, 0, sizeof(char) * hexLength);

	int ci = 0;
	for (int i = 0; i < 16; ++i)
	{
		unsigned char c = md5Info[i];
		hex[ci++] = hextable[(c >> 4) & 0x0f];
		hex[ci++] = hextable[c & 0x0f];
	}
	std::string strMd5(hex);

	return strMd5;
}

std::string extensFunction::safeCopyStr(const char *pstrSrc, int nMaxLen)
{
	char strDst[2048] = { 0 };
	const unsigned char kFirstBitMask = 128;	// 1000000
	const unsigned char kThirdBitMask = 32;		// 0010000
	const unsigned char kFourthBitMask = 16;	// 0001000
	int nCopyLen = 0;
	bool bOverStep = false;
	for (int i = 0; i < nMaxLen; i++)
	{
		int nOffset = 1;
		char cCurByte = *(pstrSrc + i);
		if (cCurByte == '\0')
			break;
		if (cCurByte&kFirstBitMask)
		{
			if (cCurByte&kThirdBitMask)
			{
				if (cCurByte & kFourthBitMask)
				{
					nOffset = 4;
				}
				else
				{
					nOffset = 3;
				}
			}
			else
			{
				nOffset = 2;
			}
		}
		nCopyLen += nOffset;
		i += nOffset - 1;
		if (nCopyLen > nMaxLen - 3)
		{
			bOverStep = true;
			nCopyLen -= nOffset;
			break;
		}
	}
	strncpy(strDst, pstrSrc, nCopyLen);
	if (bOverStep)
	{
		for (int i = 0; i < 3; i++)
		{
			*(strDst + (nCopyLen + i)) = '.';
		}

	}
	m_strCopyStr = strDst;
	return m_strCopyStr;
}

std::string extensFunction::safeCopyNumStr(const char *pstrSrc, int nMaxNum)
{
	char strDst[2048] = { 0 };
	const unsigned char kFirstBitMask = 128;	// 1000000
	const unsigned char kThirdBitMask = 32;		// 0010000
	const unsigned char kFourthBitMask = 16;	// 0001000
	int nCopyLen = 0;
	int iCopyNum = 0;
	bool bOverStep = false;
	for (int i = 0; i < 50; i++)
	{
		int nOffset = 1;
		char cCurByte = *(pstrSrc + i);
		if (cCurByte == '\0')
			break;
		if (cCurByte&kFirstBitMask)
		{
			if (cCurByte&kThirdBitMask)
			{
				if (cCurByte & kFourthBitMask)
					nOffset = 4;
				else
					nOffset = 3;
			}
			else
			{
				nOffset = 2;
			}
		}
		nCopyLen += nOffset;
		iCopyNum++;
		i += nOffset - 1;
		if (iCopyNum > nMaxNum - 1)
		{
			bOverStep = true;
			nCopyLen -= nOffset;
			break;
		}
	}
	strncpy(strDst, pstrSrc, nCopyLen);
	if (bOverStep)
	{
		for (int i = 0; i < 3; i++)
		{
			*(strDst + (nCopyLen + i)) = '.';
		}

	}
	m_strCopyStr = strDst;
	return m_strCopyStr;
}

int extensFunction::getStrLen(const char *pstrText)
{
	const unsigned char kFirstBitMask = 128;	// 1000000
	const unsigned char kThirdBitMask = 32;		// 0010000
	const unsigned char kFourthBitMask = 16;	// 0001000
	int nCopyLen = 0;
	int iCopyNum = 0;
	bool bOverStep = false;
	for (int i = 0; i < 50; i++)
	{
		int nOffset = 1;
		char cCurByte = *(pstrText + i);
		if (cCurByte == '\0')
			break;
		if (cCurByte&kFirstBitMask)
		{
			if (cCurByte&kThirdBitMask)
			{
				if (cCurByte & kFourthBitMask)
					nOffset = 4;
				else
					nOffset = 3;
			}
			else
			{
				nOffset = 2;
			}
		}

		iCopyNum += nOffset;
		i += nOffset - 1;
	}
	return iCopyNum;
}

void extensFunction::httpForImg(const char *pstrImg, const char *pstrPosName, const char *pstrTag)
{
	m_strFileName = pstrPosName;

	HttpRequest	*pRequest = new (std::nothrow) HttpRequest;
	if (pRequest)
	{
		pRequest->setUrl(pstrImg);
		pRequest->setRequestType(HttpRequest::Type::GET);
		pRequest->setTag(pstrTag);

		pRequest->setResponseCallback([this](cocos2d::network::HttpClient* sender, cocos2d::network::HttpResponse *pResponse){
			if (!pResponse->isSucceed())
			{
				return;
			}
			std::vector<char> *buffer = pResponse->getResponseData();
			Image* imgHead = new Image;
			imgHead->initWithImageData((unsigned char*)buffer->data(), buffer->size());
			imgHead->saveToFile(m_strFileName);
			Director::getInstance()->getEventDispatcher()->dispatchCustomEvent(pResponse->getHttpRequest()->getTag());
			imgHead->release();
		});
		HttpClient::getInstance()->sendImmediate(pRequest);
		pRequest->release();
	}
}

void extensFunction::lua_wxlogin_over(const char* access_token, const char* openid,
                                      const char* refresh_token, const char* unionid)
{
    UserDefault::getInstance()->setStringForKey("access_token",access_token);
    UserDefault::getInstance()->setStringForKey("openid",openid);
    UserDefault::getInstance()->setStringForKey("refresh_token",refresh_token);
    UserDefault::getInstance()->setStringForKey("unionid",unionid);
    UserDefault::getInstance()->flush();
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("CUSTOMMSG_WXLOGIN");
}

void extensFunction::wxlogin()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	[[AppController sharedInstance] sendAuthRequest];
#else
	callJavawxLogin();
#endif
}

void extensFunction::wxInviteFriend(int nType, const char *pstrTitle, const char *pstrContent, const char *pstrPng, const char *pstrUrl)
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

	WXMediaMessage *message = [WXMediaMessage message];
	message.title = [NSString stringWithUTF8String:pstrTitle];
	message.description = [NSString stringWithUTF8String:pstrContent];

	[message setThumbImage:[UIImage imageNamed:[NSString stringWithUTF8String:pstrPng] ]];

	WXWebpageObject *webObj = [WXWebpageObject object];
	webObj.webpageUrl = [NSString stringWithUTF8String:pstrUrl];
	message.mediaObject = webObj;

	SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
	req.bText = NO;
	req.message = message;
	req.scene = WXSceneSession;
	if (nType == 0)
	{
		req.scene = WXSceneSession;
	}
	else if (nType == 1)
	{
		req.scene = WXSceneTimeline;
	}
	else if (nType == 2)
	{
		req.scene = WXSceneFavorite;
	}

	[WXApi sendReq:req];
#else
	callJavaInviteFriend(nType, pstrTitle, pstrContent, pstrPng, pstrUrl);
#endif
}

void extensFunction::wxshareZhanJi(int nType, const char *pszContent)
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
	req.text = [NSString stringWithUTF8String:pszContent];
	req.bText = YES;
	req.scene = WXSceneSession;
	if (nType == 0)
	{
		req.scene = WXSceneSession;
	}
	else if (nType == 1)
	{
		req.scene = WXSceneTimeline;
	}
	else if (nType == 2)
	{
		req.scene = WXSceneFavorite;
	}

	[WXApi sendReq:req];
#else
	callJavaShareZhanJi(nType, pszContent);
#endif
}

void extensFunction::wxshareResult(int nType, const char *pstrTitle, const char *pstrContent, const char *pstrPng, const char *pstrUrl)
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	WXMediaMessage *message = [WXMediaMessage message];
	NSString *filePath = [NSString stringWithUTF8String:pstrPng];

	// 压缩压缩图
	NSData *imgData = [NSData dataWithContentsOfFile:filePath];
	UIImage *image = [UIImage imageWithData: imgData];

	CGFloat compression = 0.9f;
	CGFloat maxCompression = 0.1f;
	int maxFileSize = 150*1024;

	NSData *imageData = UIImageJPEGRepresentation(image, compression);
	while ([imageData length] > maxFileSize && compression > maxCompression)
	{
		compression -= 0.1;
		imageData = UIImageJPEGRepresentation(image, compression);
	}

	WXImageObject *ext = [WXImageObject object];
	ext.imageData = imageData;

	message.mediaObject = ext;

	if (image.size.width > 284 || image.size.height > 167)
	{
		//尺寸减到284*167
		UIGraphicsBeginImageContext(CGSizeMake(200, 115));
		[image drawInRect : CGRectMake(0, 0, 200, 115)];
		UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		imgData = UIImageJPEGRepresentation(newImage, 0.5);
		image = [UIImage imageWithData : imgData];
	}

	maxFileSize = 32 * 1024;

	imageData = UIImageJPEGRepresentation(image, compression);
	while ([imageData length] > maxFileSize && compression > maxCompression)
	{
		compression -= 0.1;
		imageData = UIImageJPEGRepresentation(image, compression);
	}

	UIImage *compressedImage = [UIImage imageWithData : imageData];
	[message setThumbImage : compressedImage];

	SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
	req.bText = NO;
	req.message = message;
	req.scene = WXSceneSession;
	if (nType == 0)
	{
		req.scene = WXSceneSession;
	}
	else if (nType == 1)
	{
		req.scene = WXSceneTimeline;
	}
	else if (nType == 2)
	{
		req.scene = WXSceneFavorite;
	}

	[WXApi sendReq : req];
#else
	callJavaShareResult(nType, pstrTitle, pstrContent, pstrPng, pstrUrl);
#endif
}