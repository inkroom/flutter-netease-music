#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"
#include <tChar.h>
#include <tlhelp32.h>
#include <vector>
#pragma execution_character_set("utf-8")
typedef struct EnumHWndsArg
{
    std::vector<HWND> *vecHWnds;
    DWORD dwProcessId;
}EnumHWndsArg, *LPEnumHWndsArg;
BOOL CALLBACK lpEnumFunc(HWND hwnd, LPARAM lParam)
{
    EnumHWndsArg *pArg = (LPEnumHWndsArg)lParam;
    DWORD  processId;
    GetWindowThreadProcessId(hwnd, &processId);
    if (processId == pArg->dwProcessId)
    {
        pArg->vecHWnds->push_back(hwnd);
        //printf("%p\n", hwnd);
    }
    return TRUE;
}
// 确保单例运行
bool iaAlreadyRun(){
    HANDLE h = NULL;
    h = CreateMutex(NULL,FALSE,L"INKBOX_QUIET");
    if(h!=NULL){
        if(ERROR_ALREADY_EXISTS==GetLastError()){
            ReleaseMutex(h);
            return true;
        }
    }
    return false;
}

void GetHWndsByProcessID(DWORD processID, std::vector<HWND> &vecHWnds)
{
    EnumHWndsArg wi;
    wi.dwProcessId = processID;
    wi.vecHWnds = &vecHWnds;
    EnumWindows(lpEnumFunc, (LPARAM)&wi);
}

DWORD GetProcessIDByName(const wchar_t* pName)
{
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (INVALID_HANDLE_VALUE == hSnapshot) {
        return NULL;
    }
    PROCESSENTRY32 pe = { sizeof(pe) };
    for (BOOL ret = Process32First(hSnapshot, &pe); ret; ret = Process32Next(hSnapshot, &pe)) {
        if (wcscmp(pe.szExeFile, pName) == 0) {
            CloseHandle(hSnapshot);
            return pe.th32ProcessID;
        }
        //printf("%-6d %s\n", pe.th32ProcessID, pe.szExeFile);
    }
    CloseHandle(hSnapshot);
    return 0;
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {

   if(iaAlreadyRun()){
          DWORD pid = GetProcessIDByName(L"quiet.exe");
          if (pid!=NULL){

              std::vector<HWND> vecHWnds;
              GetHWndsByProcessID(pid, vecHWnds);

              for (const HWND &h : vecHWnds)
              {
                  HWND parent = GetParent(h);
                  if (parent == NULL)
                  {
                      ShowWindow(h,SW_SHOWNOACTIVATE);
                      SetForegroundWindow(h);
                      RECT rect;
                      GetWindowRect(h,&rect);
                      RedrawWindow(h,&rect,NULL,RDW_UPDATENOW |RDW_INTERNALPAINT  );

      //                          cout<<title<<endl;
                  }
                  else
                  {
                   //  MessageBoxW(NULL,L"program has running", L"ERROR",MB_OK);
                  }
              }
      } else{
         MessageBoxW(NULL,L"program has running", L"ERROR",MB_OK);
      }

    return EXIT_SUCCESS;
   }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(960, 720);
  if (!window.CreateAndShow(L"quiet", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
