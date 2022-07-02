#include "my_application.h"
#include <iostream>
#include <string.h>
#include <sys/types.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>
//执行命令并返回结果
void get_cmd_result(const std::string &_cmd, std::string &_result)
{
  FILE *_cmd_result = popen(_cmd.c_str(), "r");
  char buf[256]={0};
  fread(buf, 1, sizeof(buf), _cmd_result);
  _result = buf;

  pclose(_cmd_result);
//  delete buf;
//  buf = nullptr;
}

//向给定进程发送SIGUSR1信号
int send_proc_SIGUSR1(const std::string &proc_name)
{
  std::string _cmd = "ps -ax | grep " + proc_name + " | grep -v grep  | grep -v " + std::to_string( getpid()) + " | awk '{print $1}'";
  std::string proc_pid;
  get_cmd_result(_cmd, proc_pid);
  if(proc_pid.length()>0){
    kill(atoi(proc_pid.c_str()),SIGUSR1);
    return 0;
  }
    return 1;
}
int main(int argc, char** argv) {

    if(!send_proc_SIGUSR1("quiet")){
        return 0;
    }

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
