// imgui helpers for win.
// plugin implementations should not need to touch this file.


#include <windows.h>
#include <windowsx.h>
#include <tchar.h>
#include <stdio.h>

#include "main.h"

#include "glfw/include/GLFW/glfw3.h"
#include "glfw/include/GLFW/glfw3native.h"

bool imgui__attach(Plugin *plugin, void *native_display, void *native_window);

bool gui__attach_win(const clap_plugin *plugin, void *parent)
{
  return imgui__attach((Plugin*)plugin->plugin_data, NULL, parent);
}

bool gui__attach_mac(const clap_plugin *plugin, void *parent) { return false; }
bool gui__attach_lin(const clap_plugin *plugin, const char *display_name, unsigned long parent) { return false; }

void get_native_window_position(void *native_display, void *native_window,
  int *x, int *y, int *w, int *h)
{
  RECT wr;
  GetWindowRect((HWND)native_window, &wr);
  *x = wr.left;
  *y = wr.top;
  *w = wr.right-wr.left;
  *h = wr.bottom-wr.top;
}

void set_native_parent(void *native_display, void *native_window, GLFWwindow *glfw_win)
{
  HWND hpar = (HWND)native_window;
  HWND hwnd = (HWND)glfwGetWin32Window(glfw_win);
  SetParent(hwnd, hpar);
  long style=GetWindowLong(hwnd, GWL_STYLE);
  style &= ~WS_POPUP;
  style |= WS_CHILDWINDOW;
  SetWindowLong(hwnd, GWL_STYLE, style);
  SetWindowPos(hwnd, NULL, 0, 0, 0, 0, SWP_NOZORDER|SWP_NOSIZE|SWP_NOACTIVATE);
}

unsigned int timer_id;

void CALLBACK timer_proc(HWND hwnd, UINT a, UINT_PTR b, DWORD c)
{
  extern void imgui__on_timer();
  imgui__on_timer();
}

bool create_timer(unsigned int ms)
{
  timer_id = SetTimer(NULL, 1, ms, timer_proc);
  return true;
}

void destroy_timer()
{
  KillTimer(NULL, timer_id);
  timer_id=0;
}

unsigned int get_tick_count()
{
  return GetTickCount();
}
