/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
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
package com.hnqp.pdkgame;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.json.JSONException;
import org.json.JSONObject;

import com.tencent.mm.sdk.openapi.*;

import android.app.Service;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.content.IntentFilter;
import android.content.Intent;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Looper;
import java.util.Timer;
import java.util.TimerTask;
// 添加电话监听
import android.content.Context;
import android.telephony.TelephonyManager;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import com.hnqp.pdkgame.util.*;

import android.net.Uri;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import android.net.ConnectivityManager;

public class AppActivity extends Cocos2dxActivity {

	public static native void noticeEnterGround();	// 进入后台

	public static native void noticeForGround();	// 回到前台

	public static native void noticewxCode(String url);		// 微信code

	public static native void noticewxCancel();				// 微信用户取消

	private static final String TAG = "AppActivity";

	private IWXAPI api = null;

	private static AppActivity mainActivity = null;

	protected static final int THUMB_SIZE = 150;// 分享的图片大小

	public boolean bCall = false;

	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		api = WXAPIFactory.createWXAPI(this, Constants.APP_ID, false);
		api.registerApp(Constants.APP_ID);

		mainActivity = this;

		TelephonyManager tManager = (TelephonyManager) getContext()
				.getSystemService(Service.TELEPHONY_SERVICE);
		tManager.getCallState();
		PhoneStateListener listener = new PhoneStateListener()
		{
			@Override
			public void onCallStateChanged(int state, String number)
			{
				switch (state)
				{
					// 挂电话
					case TelephonyManager.CALL_STATE_IDLE:
						if (bCall) {
							Log.i(TAG, "挂电话------>");
							bCall = false;
							noticeForGround();
						}
						break;
					// 接电话
					case TelephonyManager.CALL_STATE_OFFHOOK:
						Log.i(TAG, "接电话------>");
						bCall = true;
						noticeEnterGround();
						break;
					// 来电铃响时
					case TelephonyManager.CALL_STATE_RINGING:
						Log.i(TAG, "响铃------>");
						break;
					default:
						break;
				}
				super.onCallStateChanged(state, number);
			}
		};
		// 监听电话通话状态的改变
		tManager.listen(listener, PhoneStateListener.LISTEN_CALL_STATE);
	}

	public Cocos2dxGLSurfaceView onCreateView() {

		String deviceId = ((TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE)).getDeviceId();

		Log.d("deviceid", "deviceid=" + deviceId);

		Cocos2dxGLSurfaceView glSurfaceView = new Cocos2dxGLSurfaceView(this);
		// TestCpp should create stencil buffer
		glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);

		return glSurfaceView;
	}

	public static Object getActivity() {
		return mainActivity;
	}

	// 请求code
	public void appwxLogin() {
		// send oauth request
		final SendAuth.Req req = new SendAuth.Req();
		req.scope = "snsapi_userinfo";
		req.state = "123";
		api.sendReq(req);
		if (api.sendReq(req)) {
			System.out.print("send ok");
		}
	}

	// 请求code
	public static void wxLogin() {
		mainActivity.appwxLogin();
	}

	// 分享好友
	public void appInviteFriend(int nType, String strTitle, String strContent, String strPng, String strUrl) {

		WXMediaMessage msg = new WXMediaMessage();
		msg.title = strTitle;
		msg.description = strContent;

		WXWebpageObject webpage = new WXWebpageObject();
		webpage.webpageUrl = strUrl;
		msg.mediaObject = webpage;

		//构造一个Req
		SendMessageToWX.Req req = new SendMessageToWX.Req();
		//transaction字段用于唯一标识一个请求
		req.transaction = buildTransaction("inviteFriend");
		req.message = msg;
		//发送的目标场景
		req.scene = SendMessageToWX.Req.WXSceneSession;
		if (nType == 0)
		{
			req.scene = SendMessageToWX.Req.WXSceneSession;
		}
		else if (nType == 1)
		{
			req.scene = SendMessageToWX.Req.WXSceneTimeline;
		}
		api.sendReq(req);
	}

	// 分享好友
	// nType 0聊天界面,1朋友圈,2微信收藏
	// 发送到聊天界面——WXSceneSession
	// 发送到朋友圈——WXSceneTimeline
	// 添加到微信收藏——WXSceneFavorite
	public static void inviteFriend(int nType, String strTitle, String strContent, String strPng, String strUrl) {
		mainActivity.appInviteFriend(nType, strTitle, strContent, strPng, strUrl);
	}

	private static String buildTransaction(final String type) {
		return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
	}

	// 分享回放
	public void appShareZhanJi(int nType, String strContent) {
		WXTextObject textObj = new WXTextObject();
		textObj.text = strContent;

		WXMediaMessage msg = new WXMediaMessage();
		msg.mediaObject = textObj;
		msg.description = strContent;

		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("shareZhanJi");

		req.message = msg;
		req.scene = SendMessageToWX.Req.WXSceneSession;
		if (nType == 0)
		{
			req.scene = SendMessageToWX.Req.WXSceneSession;
		}
		else if (nType == 1)
		{
			req.scene = SendMessageToWX.Req.WXSceneTimeline;
		}
		api.sendReq(req);
	}

	// 分享回放
	public static void shareZhanJi(int nType, String strContent) {
		mainActivity.appShareZhanJi(nType, strContent);
	}

	// 分享结算
	public void appshareResult(int nType, String strTitle, String strContent, String strPng, String strUrl) {
		WXImageObject imgObj = new WXImageObject(getimage(strPng, 200));

		WXMediaMessage msg = new WXMediaMessage();
		msg.title = strTitle;
		msg.description = strContent;
		msg.mediaObject = imgObj;

		Bitmap bmp = getimage(strPng, 32);
		if (bmp != null) {

			Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 200, 115, false);

			msg.thumbData = Util.bmpToByteArray(thumbBmp, true);

			SendMessageToWX.Req req = new SendMessageToWX.Req();
			req.transaction = buildTransaction("shareResult");
			req.message = msg;
			req.scene = SendMessageToWX.Req.WXSceneSession;
			if (nType == 0)
			{
				req.scene = SendMessageToWX.Req.WXSceneSession;
			}
			else if (nType == 1)
			{
				req.scene = SendMessageToWX.Req.WXSceneTimeline;
			}
			api.sendReq(req);
		}
	}
	
	// 分享结算
	public static void shareResult(int nType, String strTitle, String strContent, String strPng, String strUrl) {
		mainActivity.appshareResult(nType, strTitle, strContent, strPng, strUrl);
	}

	//压缩图片
	private Bitmap getimage(String srcPath, int maxsize) {
		try {
			BitmapFactory.Options newOpts = new BitmapFactory.Options();
			//开始读入图片，此时把options.inJustDecodeBounds 设回true了

			Bitmap bitmap = BitmapFactory.decodeFile(srcPath, newOpts);//此时返回bm为空

			newOpts.inJustDecodeBounds = false;

			newOpts.inSampleSize = 1;//be;//设置缩放比例
			//重新读入图片，注意此时已经把options.inJustDecodeBounds 设回false了
			bitmap = BitmapFactory.decodeFile(srcPath, newOpts);
			return compressImage(bitmap, maxsize);//压缩好比例大小后再进行质量压缩
		}
		catch (Exception e) {
		}
		return null;
	}

	// 压缩图片
	private Bitmap compressImage(Bitmap image, int maxsize) {

		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		image.compress(Bitmap.CompressFormat.JPEG, 100, baos);//质量压缩方法，这里100表示不压缩，把压缩后的数据存放到baos中
		int options = 100;
		while (baos.toByteArray().length / 1024 >= maxsize) {  //循环判断如果压缩后图片是否大于100kb,大于继续压缩
			options -= 5;//每次都减少10

			baos.reset();//重置baos即清空baos
			image.compress(Bitmap.CompressFormat.JPEG, options, baos);//这里压缩options%，把压缩后的数据存放到baos中
			Log.v("cur len is ", baos.toByteArray().length + " len");

		}
		ByteArrayInputStream isBm = new ByteArrayInputStream(baos.toByteArray());//把压缩后的数据baos存放到ByteArrayInputStream中
		Bitmap bitmap = BitmapFactory.decodeStream(isBm, null, null);//把ByteArrayInputStream数据生成图片
		return bitmap;
	}

	// 微信code
	public static void call_wxCode(String code) {
		// java call c++ func 微信code
		noticewxCode(code);
	}

	// 微信取消
	public static void wxCancel() {
		Timer timer = new Timer();// 实例化Timer类
		timer.schedule(new TimerTask() {
			public void run() {
				System.out.println("退出");
				// java call c++ func 
				noticewxCancel();
			}
		}, 3000);// 这里百毫秒
	}
}
