package com.hnqp.pdkgame.util;

import com.hnqp.pdkgame.wxapi.WXEntryActivity;

/**
 * Created by xudongxu on 16/9/25.
 */

public  class Userinfo {

    public Userinfo(){

    }
    public  static Userinfo conf=null;
    public static Userinfo getInstance(){
        if(conf==null){
            conf =new Userinfo();
        }
        return conf;
    }
    public String userId   = "";
    public String openid   = "";
    public String nickname = "";
    public String country  = "";
    public String province = "";
    public String city     = "";
    public String unionid  = "";
    public String headimgurl = "";
    public String sex = "";
    public   void SaveUserinfo(String _userId,String _openid,String _nickName
            ,String _country,String _province,String _city,String _unionid,String _headimgurl,String _sex  ){

        String userId   = _userId;
        String openid   = _openid;
        String nickname = _nickName;
        String country  = _country;
        String province = _province;
        String city     = _city;
        String unionid  = _unionid;
        String headimgurl = _headimgurl;
        String sex = _sex;
    }
}
