package com.hnqp.pdkgame.wxapi;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.apache.http.client.ClientProtocolException;
import org.json.JSONException;
import org.json.JSONObject;

import com.hnqp.pdkgame.AppActivity;
import com.hnqp.pdkgame.Constants;
import com.hnqp.pdkgame.util.*;
import com.tencent.mm.sdk.openapi.BaseReq;
import com.tencent.mm.sdk.openapi.BaseResp;
import com.tencent.mm.sdk.openapi.ConstantsAPI;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.SendAuth;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.mm.sdk.openapi.WXTextObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.StrictMode;
import android.util.Log;
import android.widget.Toast;

public class WXEntryActivity extends Activity implements IWXAPIEventHandler{
	
	private static final String TAG = "WXEntryActivity";

	// IWXAPI 是第三方app和微信通信的openapi接口
    private IWXAPI api;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // 通过WXAPIFactory工厂，获取IWXAPI的实例
    	api = WXAPIFactory.createWXAPI(this, Constants.APP_ID, true);

		if(!api.isWXAppInstalled()){
			Toast.makeText(this,"您没有安装微信", Toast.LENGTH_LONG).show();
			return;
        }
    	api.registerApp(Constants.APP_ID);  

        api.handleIntent(getIntent(), this);
	}
        
	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		
		setIntent(intent);
        api.handleIntent(intent, this);
	}

	// 微信发送请求到第三方应用时，会回调到该方法
	@Override
	public void onReq(BaseReq req) {
		switch (req.getType()) {
		case ConstantsAPI.COMMAND_GETMESSAGE_FROM_WX:

			break;
		case ConstantsAPI.COMMAND_SHOWMESSAGE_FROM_WX:

			break;
		default:
			break;
		}
	}

	// 第三方应用发送到微信的请求处理后的响应结果，会回调到该方法
	@Override
	public void onResp(BaseResp resp) {
		switch (resp.errCode) {
		case BaseResp.ErrCode.ERR_OK:
		{
			Log.e("LUA", "ERR_OK");
			if (resp.getType() == ConstantsAPI.COMMAND_SENDAUTH) {
				SendAuth.Resp sendResp = (SendAuth.Resp) resp;
				getResult(sendResp.token);
				Log.e("LUA", "ERR_OK_TOKEN");
			}else{
				finish();
				Log.e("LUA", "ERR_OK11");
			}
		}
			break;
		case BaseResp.ErrCode.ERR_USER_CANCEL:
		{
			Intent intent = new Intent(this, AppActivity.class);
			startActivity(intent);
			AppActivity.wxCancel();
			Log.e("LUA", "ERR_USER_CANCEL");
			Log.i("cancel", "user cancel");
			finish();
		}
			break;
		default:
			finish();
			break;
		}
	}
	
	/**
	 * 获取结果
	 * @param code 请求码
	 */
	public void getResult(final String token) {
		AppActivity.call_wxCode(token);
		finish();
	}
}