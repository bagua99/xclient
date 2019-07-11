#include "lua_extensFunction_auto.hpp"
#include "extensFunction.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "lua_extensions/pbc/pbc_head.h"

int lua_extensFunction_extensFunction_md5File(lua_State* tolua_S)
{
	int argc = 0;
	extensFunction* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "extensFunction", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (extensFunction*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_extensFunction_extensFunction_md5File'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1)
	{
		const char* arg0;

		std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "extensFunction:md5File"); arg0 = arg0_tmp.c_str();
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_md5File'", nullptr);
			return 0;
		}
		std::string ret = cobj->md5File(arg0);
		tolua_pushcppstring(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "extensFunction:md5File", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_extensFunction_extensFunction_md5File'.", &tolua_err);
#endif

	return 0;
}
int lua_extensFunction_extensFunction_safeCopyStr(lua_State* tolua_S)
{
	int argc = 0;
	extensFunction* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "extensFunction", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (extensFunction*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_extensFunction_extensFunction_safeCopyStr'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 2)
	{
		const char* arg0;
		int arg1;

		std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "extensFunction:safeCopyStr"); arg0 = arg0_tmp.c_str();

		ok &= luaval_to_int32(tolua_S, 3, (int *)&arg1, "extensFunction:safeCopyStr");
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_safeCopyStr'", nullptr);
			return 0;
		}
		std::string ret = cobj->safeCopyStr(arg0, arg1);
		tolua_pushcppstring(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "extensFunction:safeCopyStr", argc, 2);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_extensFunction_extensFunction_safeCopyStr'.", &tolua_err);
#endif

	return 0;
}
int lua_extensFunction_extensFunction_safeCopyNumStr(lua_State* tolua_S)
{
	int argc = 0;
	extensFunction* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "extensFunction", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (extensFunction*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_extensFunction_extensFunction_safeCopyNumStr'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 2)
	{
		const char* arg0;
		int arg1;

		std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "extensFunction:safeCopyNumStr"); arg0 = arg0_tmp.c_str();

		ok &= luaval_to_int32(tolua_S, 3, (int *)&arg1, "extensFunction:safeCopyNumStr");
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_safeCopyNumStr'", nullptr);
			return 0;
		}
		std::string ret = cobj->safeCopyNumStr(arg0, arg1);
		tolua_pushcppstring(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "extensFunction:safeCopyNumStr", argc, 2);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_extensFunction_extensFunction_safeCopyNumStr'.", &tolua_err);
#endif

	return 0;
}
int lua_extensFunction_extensFunction_getStrLen(lua_State* tolua_S)
{
    int argc = 0;
    extensFunction* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"extensFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (extensFunction*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_extensFunction_extensFunction_getStrLen'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "extensFunction:getStrLen"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_extensFunction_extensFunction_getStrLen'", nullptr);
            return 0;
        }
        int ret = cobj->getStrLen(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "extensFunction:getStrLen",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_extensFunction_extensFunction_getStrLen'.",&tolua_err);
#endif

    return 0;
}
int lua_extensFunction_extensFunction_httpForImg(lua_State* tolua_S)
{
	int argc = 0;
	extensFunction* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "extensFunction", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (extensFunction*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_extensFunction_extensFunction_httpForImg'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 3)
	{
		const char* arg0;
		const char* arg1;
		const char* arg2;

		std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "extensFunction:httpForImg"); arg0 = arg0_tmp.c_str();

		std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "extensFunction:httpForImg"); arg1 = arg1_tmp.c_str();

		std::string arg2_tmp; ok &= luaval_to_std_string(tolua_S, 4, &arg2_tmp, "extensFunction:httpForImg"); arg2 = arg2_tmp.c_str();
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_httpForImg'", nullptr);
			return 0;
		}
		cobj->httpForImg(arg0, arg1, arg2);
		lua_settop(tolua_S, 1);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "extensFunction:httpForImg", argc, 3);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_extensFunction_extensFunction_httpForImg'.", &tolua_err);
#endif

	return 0;
}
int lua_extensFunction_extensFunction_wxlogin(lua_State* tolua_S)
{
	int argc = 0;
	extensFunction* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "extensFunction", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (extensFunction*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_extensFunction_extensFunction_wxlogin'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_wxlogin'", nullptr);
			return 0;
		}
		cobj->wxlogin();
		lua_settop(tolua_S, 1);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "extensFunction:wxlogin", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_extensFunction_extensFunction_wxlogin'.", &tolua_err);
#endif

	return 0;
}
int lua_extensFunction_extensFunction_wxInviteFriend(lua_State* tolua_S)
{
	int argc = 0;
	extensFunction* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "extensFunction", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (extensFunction*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_extensFunction_extensFunction_wxInviteFriend'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 5)
	{
		int arg0;
		const char* arg1;
		const char* arg2;
		const char* arg3;
		const char* arg4;


		ok &= luaval_to_int32(tolua_S, 2, (int *)&arg0, "extensFunction:wxInviteFriend");
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_wxInviteFriend'", nullptr);
			return 0;
		}

		std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "extensFunction:wxInviteFriend"); arg1 = arg1_tmp.c_str();

		std::string arg2_tmp; ok &= luaval_to_std_string(tolua_S, 4, &arg2_tmp, "extensFunction:wxInviteFriend"); arg2 = arg2_tmp.c_str();

		std::string arg3_tmp; ok &= luaval_to_std_string(tolua_S, 5, &arg3_tmp, "extensFunction:wxInviteFriend"); arg3 = arg3_tmp.c_str();

		std::string arg4_tmp; ok &= luaval_to_std_string(tolua_S, 6, &arg4_tmp, "extensFunction:wxInviteFriend"); arg4 = arg4_tmp.c_str();
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_wxInviteFriend'", nullptr);
			return 0;
		}
		cobj->wxInviteFriend(arg0, arg1, arg2, arg3, arg4);
		lua_settop(tolua_S, 1);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "extensFunction:wxInviteFriend", argc, 5);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_extensFunction_extensFunction_wxInviteFriend'.", &tolua_err);
#endif

	return 0;
}
int lua_extensFunction_extensFunction_wxshareZhanJi(lua_State* tolua_S)
{
    int argc = 0;
    extensFunction* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"extensFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (extensFunction*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_extensFunction_extensFunction_wxshareZhanJi'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
		int arg0;
		ok &= luaval_to_int32(tolua_S, 2, (int *)&arg0, "extensFunction:shareZhanJi");
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_wxshareZhanJi'", nullptr);
			return 0;
		}

        const char* arg1;
		std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "extensFunction:shareZhanJi"); arg1 = arg1_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_extensFunction_extensFunction_wxshareZhanJi'", nullptr);
            return 0;
        }
		cobj->wxshareZhanJi(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "extensFunction:shareZhanJi",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_extensFunction_extensFunction_wxshareZhanJi'.",&tolua_err);
#endif

    return 0;
}
int lua_extensFunction_extensFunction_wxshareResult(lua_State* tolua_S)
{
	int argc = 0;
	extensFunction* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "extensFunction", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (extensFunction*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_extensFunction_extensFunction_wxshareResult'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 5)
	{
		int arg0;
		const char* arg1;
		const char* arg2;
		const char* arg3;
		const char* arg4;

		ok &= luaval_to_int32(tolua_S, 2, (int *)&arg0, "extensFunction:wxshareResult");
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_wxshareResult'", nullptr);
			return 0;
		}

		std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "extensFunction:wxshareResult"); arg1 = arg1_tmp.c_str();

		std::string arg2_tmp; ok &= luaval_to_std_string(tolua_S, 4, &arg2_tmp, "extensFunction:wxshareResult"); arg2 = arg2_tmp.c_str();

		std::string arg3_tmp; ok &= luaval_to_std_string(tolua_S, 5, &arg3_tmp, "extensFunction:wxshareResult"); arg3 = arg3_tmp.c_str();

		std::string arg4_tmp; ok &= luaval_to_std_string(tolua_S, 6, &arg4_tmp, "extensFunction:wxshareResult"); arg4 = arg4_tmp.c_str();
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_wxshareResult'", nullptr);
			return 0;
		}
		cobj->wxshareResult(arg0, arg1, arg2, arg3, arg4);
		lua_settop(tolua_S, 1);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "extensFunction:wxshareResult", argc, 5);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_extensFunction_extensFunction_wxshareResult'.", &tolua_err);
#endif

	return 0;
}
int lua_extensFunction_extensFunction_getInstance(lua_State* tolua_S)
{
	int argc = 0;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(tolua_S, 1, "extensFunction", 0, &tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_getInstance'", nullptr);
			return 0;
		}
		extensFunction* ret = extensFunction::getInstance();
		object_to_luaval<extensFunction>(tolua_S, "extensFunction", (extensFunction*)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "extensFunction:getInstance", argc, 0);
	return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_extensFunction_extensFunction_getInstance'.", &tolua_err);
#endif
	return 0;
}
int lua_extensFunction_extensFunction_constructor(lua_State* tolua_S)
{
	int argc = 0;
	extensFunction* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
		{
			tolua_error(tolua_S, "invalid arguments in function 'lua_extensFunction_extensFunction_constructor'", nullptr);
			return 0;
		}
		cobj = new extensFunction();
		tolua_pushusertype(tolua_S, (void*)cobj, "extensFunction");
		tolua_register_gc(tolua_S, lua_gettop(tolua_S));
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "extensFunction:extensFunction", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_error(tolua_S, "#ferror in function 'lua_extensFunction_extensFunction_constructor'.", &tolua_err);
#endif

	return 0;
}
static int lua_extensFunction_extensFunction_finalize(lua_State* tolua_S)
{
	printf("luabindings: finalizing LUA object (extensFunction)");
	return 0;
}

int lua_register_extensFunction_extensFunction(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"extensFunction");
    tolua_cclass(tolua_S,"extensFunction","extensFunction","",nullptr);

    tolua_beginmodule(tolua_S,"extensFunction");
        tolua_function(tolua_S, "new",lua_extensFunction_extensFunction_constructor);
		tolua_function(tolua_S, "safeCopyStr",lua_extensFunction_extensFunction_safeCopyStr);
		tolua_function(tolua_S, "safeCopyNumStr", lua_extensFunction_extensFunction_safeCopyNumStr);
		tolua_function(tolua_S, "md5File", lua_extensFunction_extensFunction_md5File);
        tolua_function(tolua_S, "getStrLen",lua_extensFunction_extensFunction_getStrLen);
		tolua_function(tolua_S, "httpForImg", lua_extensFunction_extensFunction_httpForImg);
		tolua_function(tolua_S, "wxlogin", lua_extensFunction_extensFunction_wxlogin);
		tolua_function(tolua_S, "wxInviteFriend", lua_extensFunction_extensFunction_wxInviteFriend);
		tolua_function(tolua_S, "wxshareZhanJi", lua_extensFunction_extensFunction_wxshareZhanJi);
		tolua_function(tolua_S, "wxshareResult", lua_extensFunction_extensFunction_wxshareResult);
		tolua_function(tolua_S, "getInstance", lua_extensFunction_extensFunction_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(extensFunction).name();
    g_luaType[typeName] = "extensFunction";
    g_typeCast["extensFunction"] = "extensFunction";
    return 1;
}
TOLUA_API int register_all_extensFunction(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"ef",0);
	tolua_beginmodule(tolua_S,"ef");

	lua_register_extensFunction_extensFunction(tolua_S);

	tolua_endmodule(tolua_S);
	luaopen_protobuf_c(tolua_S);

	return 1;
}

