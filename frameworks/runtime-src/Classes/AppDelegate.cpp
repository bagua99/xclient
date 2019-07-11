#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"

#if (CC_TARGET_PLATFORM != CC_PLATFORM_LINUX)
#include "ide-support/CodeIDESupport.h"
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
#include "runtime/Runtime.h"
#include "ide-support/RuntimeLuaImpl.h"
#endif

#include "lua_extensions/cjson/lua_cjson.h"
#include "lua_extensions/lua_extensions_more.h"
#include "lua_extensions/lua_extensFunction_auto.hpp"

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate() : pRestartGameListener(NULL)
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    RuntimeEngine::getInstance()->end();
#endif

    if (pRestartGameListener != NULL)
    {
        Director::getInstance()->getEventDispatcher()->removeEventListener(pRestartGameListener);
        pRestartGameListener = NULL;
    }
}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 30.0f);

    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State *L = engine->getLuaStack()->getLuaState();
	lua_module_register(L);
	luaopen_lua_extensions_more(L);
	register_all_extensFunction(L);

	init();

    //register custom function
    //LuaStack* stack = engine->getLuaStack();
    //register_custom_function(stack->getLuaState());

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    auto runtimeEngine = RuntimeEngine::getInstance();
    runtimeEngine->addRuntime(RuntimeLuaImpl::create(), kRuntimeEngineLua);
    runtimeEngine->start();
#else
    if (engine->executeScriptFile("src/main.lua"))
    {
        return false;
    }
#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32   
	EventListenerKeyboard *listener = EventListenerKeyboard::create();
	listener->onKeyReleased = AppDelegate::keyEventCallback;
	Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(listener, 1);
#endif

    // 重启事件
    if (pRestartGameListener == NULL)
    {
        pRestartGameListener = Director::getInstance()->getEventDispatcher()->addCustomEventListener("RESTART_GAME", std::bind(&AppDelegate::RestartGame, this, std::placeholders::_1));
    }

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
    
   // SimpleAudioEngine::getInstance()->pauseBackgroundMusic();

    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("CUSTOMMSG_ENTER_BACKGROUND");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

   // SimpleAudioEngine::getInstance()->resumeBackgroundMusic();

    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("CUSTOMMSG_ENTER_FOREGROUND");
}

void AppDelegate::init()
{
	auto engine = LuaEngine::getInstance();

	LuaStack* stack = engine->getLuaStack();
	char szKey[] = "h.n.q.p.0";
	char szSign[] = "pdkgame";
	stack->setXXTEAKeyAndSign(szKey, strlen(szKey), szSign, strlen(szSign));
}

bool regist_lua()//这个函数为原来applicationDidFinishLaunching中内容
{
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 30.0f);

    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State *L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);
    luaopen_lua_extensions_more(L);
    register_all_extensFunction(L);

    LuaStack* stack = engine->getLuaStack();
    char szKey[] = "h.n.q.p.0";
    char szSign[] = "pdkgame";
    stack->setXXTEAKeyAndSign(szKey, strlen(szKey), szSign, strlen(szSign));

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    auto runtimeEngine = RuntimeEngine::getInstance();
    runtimeEngine->addRuntime(RuntimeLuaImpl::create(), kRuntimeEngineLua);
    runtimeEngine->start();
#else
    if (engine->executeScriptFile("src/main.lua"))
    {
        return false;
    }
#endif

    return true;
}

int fix_restart_lua()
{
    std::string key = "restart";
    CCDirector::getInstance()->getScheduler()->schedule([](float delta){//必须延迟执行，否则会报错
        ScriptHandlerMgr::destroyInstance();//把原理注册的函数ID清空
        ScriptEngineManager::getInstance()->removeScriptEngine();//把原来的luaEngine销毁
        regist_lua();//重新创建luaEngine
    }, CCDirector::getInstance()->getRunningScene(), 0.5f, 0, 0.5f, false, key);

    return 1;
}

void AppDelegate::keyEventCallback(cocos2d::EventKeyboard::KeyCode code, cocos2d::Event *event)
{
	typedef cocos2d::EventKeyboard::KeyCode KeyCode;
	switch (code)
	{
	case KeyCode::KEY_F5://重启
		fix_restart_lua();
		break;
	}
}

void AppDelegate::RestartGame(cocos2d::EventCustom* event)
{
    fix_restart_lua();
}


