#include "main.h"
#include "SimulatorWin.h"
#include <shellapi.h>

#define USE_WIN32_CONSOLE  

int APIENTRY _tWinMain(HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	LPTSTR    lpCmdLine,
	int       nCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(lpCmdLine);
#ifdef USE_WIN32_CONSOLE  
	AllocConsole();
	freopen("CONIN$", "r", stdin);
	freopen("CONOUT$", "w", stdout);
	freopen("CONOUT$", "w", stderr);
#endif  
	auto simulator = SimulatorWin::getInstance();
    return simulator->run();
}
