LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

NDK_TOOLCHAIN_VERSION := 4.9
APP_CPPFLAGS := -frtti -DCC_ENABLE_CHIPMUNK_INTEGRATION=1 -std=c++11 -o -fsigned-char
APP_LDFLAGS := -latomic

LOCAL_SRC_FILES := \
../../Classes/lua_extensions/extensFunction.cpp \
../../Classes/lua_extensions/lua_extensFunction_auto.cpp \
../../Classes/lua_extensions/lua_extensions_more.cpp \
../../Classes/lua_extensions/cjson/fpconv.c \
../../Classes/lua_extensions/cjson/lua_cjson.c \
../../Classes/lua_extensions/cjson/strbuf.c \
../../Classes/lua_extensions/lpack/lpack.c \
../../Classes/lua_extensions/md5/md5.c \
../../Classes/lua_extensions/pbc/alloc.c \
../../Classes/lua_extensions/pbc/array.c \
../../Classes/lua_extensions/pbc/bootstrap.c \
../../Classes/lua_extensions/pbc/context.c \
../../Classes/lua_extensions/pbc/decode.c \
../../Classes/lua_extensions/pbc/map.c \
../../Classes/lua_extensions/pbc/pattern.c \
../../Classes/lua_extensions/pbc/pbc-lua.c \
../../Classes/lua_extensions/pbc/proto.c \
../../Classes/lua_extensions/pbc/register.c \
../../Classes/lua_extensions/pbc/rmessage.c \
../../Classes/lua_extensions/pbc/stringpool.c \
../../Classes/lua_extensions/pbc/varint.c \
../../Classes/lua_extensions/pbc/wmessage.c \
../../Classes/AppDelegate.cpp \
../../Classes/ide-support/SimpleConfigParser.cpp \
../../Classes/ide-support/RuntimeLuaImpl.cpp \
../../Classes/ide-support/lua_debugger.c \
hellolua/main.cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END

LOCAL_STATIC_LIBRARIES := cocos2d_lua_static
LOCAL_STATIC_LIBRARIES += cocos2d_simulator_static

# _COCOS_LIB_ANDROID_BEGIN
# _COCOS_LIB_ANDROID_END

include $(BUILD_SHARED_LIBRARY)

$(call import-module,scripting/lua-bindings/proj.android)
$(call import-module,tools/simulator/libsimulator/proj.android)

# _COCOS_LIB_IMPORT_ANDROID_BEGIN
# _COCOS_LIB_IMPORT_ANDROID_END
