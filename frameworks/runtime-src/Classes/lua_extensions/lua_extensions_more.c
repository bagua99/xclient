
#include "lua_extensions_more.h"

#if __cplusplus
extern "C" {
#endif
#include "cjson/lua_cjson.h"
static luaL_Reg luax_exts[] = {
	{ "cjson", luaopen_cjson },
    {NULL, NULL}
};

void luaopen_lua_extensions_more(lua_State *L)
{
    // load extensions
    luaL_Reg* lib = luax_exts;
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    for (; lib->func; lib++)
    {
        lua_pushcfunction(L, lib->func);
        lua_setfield(L, -2, lib->name);
    }
    lua_pop(L, 2);
}

#if __cplusplus
} // extern "C"
#endif
