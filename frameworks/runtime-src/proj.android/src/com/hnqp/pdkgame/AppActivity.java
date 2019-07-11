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
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;

import com.tencent.mm.sdk.openapi.*;
import com.yaya.sdk.RTV;
import com.yaya.sdk.RTV.Env;
import com.yaya.sdk.RTV.Mode;
import com.yaya.sdk.tlv.protocol.message.TextMessageNotify;
import com.yaya.sdk.VideoTroopsRespondListener;
import com.yaya.sdk.YayaNetStateListener;
import com.yaya.sdk.YayaRTV;
import com.yunva.extension.LiteIm;
import com.yunva.extension.YayaLiteIM;
import com.yunva.extension.audio.play.PlayListener;
import com.yunva.extension.audio.record.RecordListener;

import android.annotation.SuppressLint;
import android.app.Service;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;
import android.content.IntentFilter;
import android.content.Intent;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Looper;
import java.util.Timer;
import java.util.TimerTask;
import java.util.prefs.Preferences;
// 添加电话监听
import android.content.Context;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.Sensor;
import android.hardware.SensorManager;

import com.baidu.location.BDLocation;
import com.baidu.location.BDLocationListener;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;
import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.MapStatus;
import com.baidu.mapapi.map.MapStatusUpdateFactory;
import com.baidu.mapapi.map.MyLocationData;
import com.baidu.mapapi.map.MyLocationConfiguration.LocationMode;
import com.baidu.mapapi.model.LatLng;
import com.baidu.platform.comapi.map.w;
import com.hnqp.pdkgame.util.*;

import android.media.AudioManager;
import android.net.Uri;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import android.net.ConnectivityManager;
import android.content.ComponentName;

public class AppActivity extends Cocos2dxActivity {

	public static native void noticeEnterGround();	// 进入后台

	public static native void noticeForGround();	// 回到前台

	public static native void noticewxCode(String url);		// 微信code

	public static native void noticewxCancel();				// 微信用户取消

	private static final String TAG = "LUA";

	private IWXAPI api = null;

	private static AppActivity mainActivity = null;

	protected static final int THUMB_SIZE = 150;// 分享的图片大小

	public boolean bCall = false;
	
	private Cocos2dxGLSurfaceView glSurfaceView;
	
	private static int recordCall_id ;
	private static int map_id = 0 ; 
	String filePath;
	
	static LocationClient mLocClient;
	public static MyLocationListenner myListener;
	private LocationMode mCurrentMode;
	BitmapDescriptor mCurrentMarker;
	private static final int accuracyCircleFillColor = 0xAAFFFF88;
	private static final int accuracyCircleStrokeColor = 0xAA00FF00;
	private SensorManager mSensorManager;
	private Double lastX = 0.0;
	private int mCurrentDirection = 0;
	private double mCurrentLat = 0.0;
	private double mCurrentLon = 0.0;
	private float mCurrentAccracy;
	boolean isFirstLoc = true; // 是否首次定位
	private MyLocationData locData;
	private float direction;
	private static int m_FunID;
	private static boolean m_payFlag=false;
	private static int m_CheckID;

	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	
		Log.e("LUA","onCreate");

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
		mainActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				initYunwa();
			}
		});
		initBaiduSdk();
	}
	


	public Cocos2dxGLSurfaceView onCreateView() {

		String deviceId = ((TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE)).getDeviceId();
		Log.d("LUA", "deviceid=" + deviceId);
		glSurfaceView = new Cocos2dxGLSurfaceView(this);
		this.hideSystemUI();
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
	// nType 0聊天界面,1朋友圈,2微信收藏(android已取消)
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
		msg.mediaObject = imgObj;

		Bitmap bmp = getimage(strPng, 32);
		if (bmp != null) {
			Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 200,
					115, false);

			msg.thumbData = Util.bmpToByteArray(thumbBmp, true);

			SendMessageToWX.Req req = new SendMessageToWX.Req();
			req.transaction = buildTransaction("img");
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
	public static void shareResult(final int nType, final String strTitle, final String strContent, final String strPng, final String strUrl) {
		Log.e(TAG,"shareResult");
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
	public static void call_wxCode(final String code) {
		// java call c++ func 微信code
		mainActivity.runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				noticewxCode(code);
				Log.e("LUA", "call_wxCode");
			}
		});
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
	
	public static void exit(int id){
		Log.e("LUA","exit");
		mainActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				
				new AlertDialog.Builder(mainActivity).setTitle("确认退出吗？") 
		           .setIcon(android.R.drawable.ic_dialog_info) 
		           .setPositiveButton("确定", new DialogInterface.OnClickListener() { 
		        
		               @Override 
		               public void onClick(DialogInterface dialog, int which) { 
		            	   // 点击“确认”后的操作 
		            	   mainActivity.finish(); 
		            	   mainActivity = null ;
		            	   System.exit(0);
		               } 
		           }) 
		           .setNegativeButton("返回", new DialogInterface.OnClickListener() { 
		               @Override 
		               public void onClick(DialogInterface dialog, int which) { 
		            	   // 点击“返回”后的操作,这里不设置没有任何操作
		            	   
		               } 
		           }).show(); 
			}
		});
	}

	@Override
	public void onWindowFocusChanged(boolean hasFocus) {
		// TODO Auto-generated method stub
		super.onWindowFocusChanged(hasFocus);
		if (hasFocus)
	    {
	        this.hideSystemUI();
	    }
	}
	
	@SuppressLint("NewApi") private void hideSystemUI()
	{
		// Set the IMMERSIVE flag.
		// Set the content to appear under the system bars so that the content
		// doesn't resize when the system bars hide and show.
		if (Build.VERSION.SDK_INT >= 19) {
			glSurfaceView.setSystemUiVisibility(
					Cocos2dxGLSurfaceView.SYSTEM_UI_FLAG_LAYOUT_STABLE 
					| Cocos2dxGLSurfaceView.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
					| Cocos2dxGLSurfaceView.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
					| Cocos2dxGLSurfaceView.SYSTEM_UI_FLAG_HIDE_NAVIGATION // hide nav bar
					| Cocos2dxGLSurfaceView.SYSTEM_UI_FLAG_FULLSCREEN // hide status bar
					| Cocos2dxGLSurfaceView.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
		}
	}
	
	 //开始录音
	 public static void record(final int id){
		Log.e("LUA","**开始录音**");
		if(YayaLiteIM.getInstance().isRecording()){
			return; 
		}
		mainActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				recordCall_id = id ;
				mainActivity.filePath = Environment.getExternalStorageDirectory() + "/im.amr";
				Log.e(TAG,"testRecordOutFile:"+mainActivity.filePath);
			    YayaLiteIM.getInstance().startVoiceRecord(mainActivity.filePath,new RecordListener() {
	                @Override
	                public void onRecordStart() {
	                    Log.d(TAG, "start record");
	                }

	                @Override
	                public void onRecordFinish(String filePath, long duration, final String url, String text) {
	                    Log.d(TAG, "record finish");
	                    Log.d(TAG, "url:"+url);
	                    mainActivity.runOnGLThread(new Runnable() {
							
							@Override
							public void run() {
								// TODO Auto-generated method stub
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(id,url);
				            	Cocos2dxLuaJavaBridge.releaseLuaFunction(id);
							}
						});
	                   
	                }

	                @Override
	                public void onRecordException(int code, String msg) {
	                    Log.d(TAG, "record exception");
	                }
	            });
				
			}
		});
	 }
	
	// 检测支付宝
	private void appcheckAliPayInstalled() {
		Uri uri = Uri.parse("alipays://platformapi/startApp");
        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
        ComponentName componentName = intent.resolveActivity(mainActivity.getApplicationContext().getPackageManager());
        if (componentName == null)
        {
			Toast.makeText(mainActivity.getApplicationContext(),"你的手机没安装支付宝，请安装之后进行购买",Toast.LENGTH_SHORT).show();
			Cocos2dxLuaJavaBridge.callLuaFunctionWithString(m_CheckID, "zfb_nofind");
			Cocos2dxLuaJavaBridge.releaseLuaFunction(m_CheckID);
			return;
        }
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(m_CheckID, "success");
		Cocos2dxLuaJavaBridge.releaseLuaFunction(m_CheckID);
	}

	// 检测支付宝
	private static void checkAliPayInstalled(final int funID) {
		m_CheckID = funID;
		mainActivity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				mainActivity.appcheckAliPayInstalled();
			}
		});
	}

	// 检测微信
	private void appCheckWXPayInstalled() {
		if(!api.isWXAppInstalled()){
			Toast.makeText(mainActivity.getApplicationContext(),"你的手机没安装微信，请安装之后进行购买", Toast.LENGTH_LONG).show();
			Cocos2dxLuaJavaBridge.callLuaFunctionWithString(m_CheckID, "wx_nofind");
			Cocos2dxLuaJavaBridge.releaseLuaFunction(m_CheckID);
			return;
        }
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(m_CheckID, "success");
		Cocos2dxLuaJavaBridge.releaseLuaFunction(m_CheckID);
	}

	// 检测微信
	private static void checkWXPayInstalled(final int funID) {
		m_CheckID = funID;
		mainActivity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				mainActivity.appCheckWXPayInstalled();
			}
		});
	}
	 
	private  void toLoadInnerApp(String url) {
		try {
			Log.e(TAG,"**内置支付**"+url);
			Intent it = new Intent(Intent.ACTION_VIEW);
			it.setData(Uri.parse(url));
			mainActivity.startActivity(it);
		} catch (Exception e) {
			//这里需要处理 发生异常的情况
			//可能情况： 手机没有安装支付宝或者微信。或者安装支付宝或者微信但是版本过低
			Log.e(TAG,"**没安装微信或者支付宝??**");
			Toast.makeText(mainActivity.getApplicationContext(),"你的手机没安装微信或者支付宝，请安装之后进行购买",Toast.LENGTH_SHORT).show();
			if(m_payFlag==true){
				//开始查询
				Log.e(TAG,"开始查询");
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(m_FunID,"success");
				Cocos2dxLuaJavaBridge.releaseLuaFunction(m_FunID);
			}
		}
	}

	 private static void setStatus(final String url){
		 m_payFlag = false;
	 }
	 
	 //支付
	 private static void pay(final String url,final int FunID){
		 Log.e("LUA"," **开始支付了**");
		 m_FunID = FunID;
		 mainActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				 WebView webView = new WebView(mainActivity);  
				 webView.getSettings().setJavaScriptEnabled(true);
				 webView.getSettings().setDomStorageEnabled(true);
				 webView.setWebChromeClient(new WebChromeClient());
				 
				 webView.setWebViewClient(new WebViewClient() {
					@Override
					public boolean shouldOverrideUrlLoading(WebView view, String url2) 
					{
						Log.e("LUA"," **开始支付URL:"+url2);
						if (!TextUtils.isEmpty(url2))
						{
							m_payFlag = true;
							if (!url2.startsWith("http") && !url2.startsWith("https")) {
								//加载手机内置支付
								mainActivity.toLoadInnerApp(url2);
								return true;
							}
						}
						return false;
					}
				});
				webView.loadUrl(url);
			}
		});
	 }
	 
	 private void initYunwa(){
		String appId = "1001730";
		YayaRTV.getInstance().init(mainActivity,appId,new VideoTroopsRespondListener() {
			
			@Override
			public void onTroopsModeChangeNotify(Mode arg0, boolean arg1) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onTroopsListChangeNotify(String arg0, long arg1, String arg2,
					int arg3) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onTextMessageNotify(TextMessageNotify arg0) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onSendTextMessageResp(long arg0, String arg1, String arg2) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onSendRealTimeVoiceMessageResp(long arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onRecordVolumeNotify(float arg0, float arg1) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onReconnectSuccess() {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onReconnectStart() {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onReconnectFail(int arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onRealTimeVoiceMessageNotify(String arg0, long arg1, String arg2) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onPlayVolumeNotify(float arg0, float arg1) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onModeSettingResp(long arg0, String arg1, Mode arg2) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onMicStateChangeNotify(String arg0, long arg1, String arg2,
					int arg3) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onMicResp(long arg0, String arg1, String arg2) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onLogoutResp(long arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onLoginResp(int arg0, String arg1, long arg2, byte arg3,
					boolean arg4, int arg5) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onGetRoomResp(long arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onAuthResp(long arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void initComplete() {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void audioRecordUnavailableNotify(int arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}
		},Env.Product,RTV.Mode.Free);
		 YayaRTV.getInstance().setNetStateListener(new YayaNetStateListener() {
			
			@Override
			public void onNetStateUpdate(long arg0, long arg1) {
				// TODO Auto-generated method stub
				
			}
		});
		YayaLiteIM.getInstance().init(mainActivity,Env.Product,appId);
	 }

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		YayaLiteIM.getInstance().destroy();
	    mLocClient.stop();
	    // 关闭定位图层
//	    mBaiduMap.setMyLocationEnabled(false);
	}
	
	private static void stopRecord(){
		mainActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				YayaLiteIM.getInstance().stopVoiceRecord();
			}
		});
	}
	
	private static void playRecord(String url,final int funcIdStart,final int funcIdFinishId){
		if(YayaLiteIM.getInstance().isPlaying()){
			return;
		}
		Log.e(TAG,"开始播放别人的录音:"+url);
		YayaLiteIM.getInstance().startPlayVoiceByUrl(url, null,new PlayListener() {
			
			@Override
			public void onPlayStart() {
				// TODO Auto-generated method stub
				Log.e(TAG,"播放开始");
				mainActivity.runOnGLThread(new Runnable() {
					
					@Override
					public void run() {
						// TODO Auto-generated method stub
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(funcIdStart,"startRecord");
						Cocos2dxLuaJavaBridge.releaseLuaFunction(funcIdStart);
					}
				});
			}
			
			@Override
			public void onPlayException(int arg0, String arg1) {
				// TODO Auto-generated method stub
				Log.e(TAG,"播放异常");
			}
			
			@Override
			public void onPlayComplete() {
				// TODO Auto-generated method stub
				Log.e(TAG,"播放完成");
				mainActivity.runOnGLThread(new Runnable() {
					
					@Override
					public void run() {
						// TODO Auto-generated method stub
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(funcIdFinishId,"onPlayComplete");
						Cocos2dxLuaJavaBridge.releaseLuaFunction(funcIdFinishId);
					}
				});
			}
		});
	}
	
	private static void playRecordByFile(String url,final int funcIdStart,final int funcIdFinishId){
		if(YayaLiteIM.getInstance().isPlaying()){
			return;
		}
		Log.e(TAG,"开始播放自己的录音:"+mainActivity.filePath);
	    YayaLiteIM.getInstance().startPlayVoice(mainActivity.filePath,new PlayListener() {
            @Override
            public void onPlayStart() {
                Log.d(TAG, "start play");
                mainActivity.runOnGLThread(new Runnable() {
					
					@Override
					public void run() {
						// TODO Auto-generated method stub
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(funcIdStart,"startRecord");
						Cocos2dxLuaJavaBridge.releaseLuaFunction(funcIdStart);
					}
				});
            }

            @Override
            public void onPlayComplete() {
                Log.d(TAG, "play complete");
                mainActivity.runOnGLThread(new Runnable() {
					
					@Override
					public void run() {
						// TODO Auto-generated method stub
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(funcIdFinishId,"startRecord");
						Cocos2dxLuaJavaBridge.releaseLuaFunction(funcIdFinishId);
					}
				});
            }

            @Override
            public void onPlayException(int i, String s) {
                Log.d(TAG, "play exception");
            }
        });
		
	}
	
	public void initBaiduSdk(){
		Log.e(TAG,"initBaiduSdk");
		mLocClient = new LocationClient(this);
		myListener = new MyLocationListenner();
	    mLocClient.registerLocationListener(myListener);
	    LocationClientOption option = new LocationClientOption();
	    option.setOpenGps(true); // 打开gps
	    option.setCoorType("bd09ll"); // 设置坐标类型
	    option.setScanSpan(1000);
	    option.setIsNeedAddress(true);
	    mLocClient.setLocOption(option);
	}
	
	public static void  getLocation( final int funcId ){
		Log.e(TAG,"getLocation");
		map_id = funcId;
		mLocClient.start();
	}
	
	 public class MyLocationListenner implements BDLocationListener {

	        @Override
	        public void onReceiveLocation(BDLocation location) {
	            // map view 销毁后不在处理新接收的位置
				if (location == null)
					return ;
	        	int LocType = location.getLocType();
	        	Log.e(TAG,"LocType:"+LocType);
	        	if(LocType==BDLocation.TypeGpsLocation||LocType==BDLocation.TypeNetWorkLocation){
	        		StringBuffer sb = new StringBuffer(256);
					sb.append("time:");
					sb.append(location.getTime());
					sb.append(";latitude:");
					sb.append(location.getLatitude());
					sb.append(";lontitude:");
					sb.append(location.getLongitude());
					sb.append(";radius:");
					sb.append(location.getRadius());
					sb.append(";addr:");
					sb.append(location.getAddrStr());					
					sb.append(location.getAddress()+"\n");  
					sb.append("\n省:"+location.getAddress().province+"\n市:"+location.getAddress().city  
					+"\n区 :"+location.getAddress().district+"\n街道:"+location.getAddress().street+"\n街道号码:"+location.getAddress().streetNumber+"\n");  
					Log.e(TAG,sb.toString());
					JSONObject json = new JSONObject();
					try {
						json.put("latitude",location.getLatitude());
						json.put("longitude",location.getLongitude());
						json.put("addr",location.getAddrStr());
						Log.e(TAG,json.toString());
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(map_id,json.toString());
						Cocos2dxLuaJavaBridge.releaseLuaFunction(map_id);
						mLocClient.stop();
					} catch (JSONException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
	        	}
	        	else if(LocType==BDLocation.TypeServerError){
	        		Log.e(TAG,"服务器定位失败");
	        	}
	        	else if(LocType==BDLocation.TypeNetWorkException){
	        		Log.e(TAG,"网络异常");
	        	}
	        	else if (LocType == BDLocation.TypeCriteriaException) {
	        		Log.e(TAG,"获取定位失败");
	        		return; 
	        	}
	        }
	        public void onReceivePoi(BDLocation poiLocation) {
	        
	        }
	    }

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		//为系统的方向传感器注册监听器
		if(m_payFlag==true){
			//开始查询
    		Log.e(TAG,"开始查询");
    		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(m_FunID,"success");
			Cocos2dxLuaJavaBridge.releaseLuaFunction(m_FunID);
		}
	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
	}
	
	public static void  getDistance(final String longitude11, final String latitude11, final String longitude21, final String latitude21,final int funId) {
		double longitude1 = Double.parseDouble(longitude11);
		double latitude1 = Double.parseDouble(latitude11);
		double longitude2 = Double.parseDouble(longitude21);
		double latitude2 = Double.parseDouble(latitude21);
		// 维度
		double lat1 = (Math.PI / 180) * latitude1;
		double lat2 = (Math.PI / 180) * latitude2;
		// 经度
		double lon1 = (Math.PI / 180) * longitude1;
		double lon2 = (Math.PI / 180) * longitude2;
		// 地球半径
		double R = 6371;
		// 两点间距离 km，如果想要米的话，结果*1000就可以了
		double d = Math.acos(Math.sin(lat1) * Math.sin(lat2) + Math.cos(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1)) * R; 
		double  d1=d*1000;
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(funId,Double.toString(d1));
		Cocos2dxLuaJavaBridge.releaseLuaFunction(funId);
	}
	
	 public static double getDistance_(double lat_a, double lng_a, double lat_b, double lng_b){
		 double pk = 180 / 3.14169;
	     double a1 = lat_a / pk;
	     double a2 = lng_a / pk;
	     double b1 = lat_b / pk;
	     double b2 = lng_b / pk;
	     double t1 = Math.cos(a1) * Math.cos(a2) * Math.cos(b1) * Math.cos(b2);
	     double t2 = Math.cos(a1) * Math.sin(a2) * Math.cos(b1) * Math.sin(b2);
	     double t3 = Math.sin(a1) * Math.sin(b1);
	     double tt = Math.acos(t1 + t2 + t3);
	     return 6371000 * tt;
	 }

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	public void startActivityForResult(Intent intent, int requestCode,
			Bundle options) {
		// TODO Auto-generated method stub
		super.startActivityForResult(intent, requestCode, options);
	}
	
}
