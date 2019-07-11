#ifndef __APP_DELEGATE_H__
#define __APP_DELEGATE_H__

#include "cocos2d.h"
#include "base/CCEventListenerCustom.h"

/**
@brief    The cocos2d Application.

The reason for implement as private inheritance is to hide some interface call by Director.
*/
class  AppDelegate : private cocos2d::Application
{
public:
    AppDelegate();
    virtual ~AppDelegate();

    virtual void initGLContextAttrs();

    /**
    @brief    Implement Director and Scene init code here.
    @return true    Initialize success, app continue.
    @return false   Initialize failed, app terminate.
    */
    virtual bool applicationDidFinishLaunching();

    /**
    @brief  The function be called when the application enter background
    @param  the pointer of the application
    */
    virtual void applicationDidEnterBackground();

    /**
    @brief  The function be called when the application enter foreground
    @param  the pointer of the application
    */
    virtual void applicationWillEnterForeground();

	static void keyEventCallback(cocos2d::EventKeyboard::KeyCode code, cocos2d::Event *event);

private:
    // 初始化
	void init();
    // 重启游戏
    void RestartGame(cocos2d::EventCustom* event);

private:
    cocos2d::EventListenerCustom     *pRestartGameListener;
};

#endif  // __APP_DELEGATE_H__

