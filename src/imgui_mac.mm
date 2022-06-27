// imgui helpers for mac.
// plugin implementations should not need to touch this file.

#include <Cocoa/Cocoa.h>
#include <sys/time.h>

#include "main.h"

#include "GLFW/glfw3.h"
#include "GLFW/glfw3native.h"

bool imgui__attach(Plugin *plugin, void *native_display, void *native_window);

bool Plugin::gui__is_api_supported(const char *api, bool is_floating)
{
  return api && !strcmp(api, CLAP_WINDOW_API_COCOA) && !is_floating;
}

bool Plugin::gui__set_parent(const clap_window *parentWindow)
{
  return parentWindow && parentWindow->cocoa &&
    imgui__attach(this, NULL, parentWindow->cocoa);
}

void get_native_window_position(void *native_display, void *native_window,
  int *x, int *y, int *w, int *h)
{
  NSView *vw = (NSView*)native_window;
  NSRect vr = [vw convertRect:[vw bounds] toView:nil];
  NSRect wr = [[vw window] convertRectToScreen:vr];
  wr.origin.y = CGDisplayBounds(CGMainDisplayID()).size.height-(wr.origin.y+wr.size.height);
  *x = wr.origin.x;
  *y = wr.origin.y;
  *w = wr.size.width;
  *h = wr.size.height;
}

void set_native_parent(void *native_display, void *native_window, GLFWwindow *glfw_win)
{
  NSWindow *par = [(NSView*)native_window window];
  NSWindow *win = (NSWindow*)glfwGetCocoaWindow(glfw_win);
  [par addChildWindow:win ordered:NSWindowAbove];
}

@interface gui_timer : NSObject
{
@public
  NSTimer *timer;
}
-(void)on_timer:(id)sender;
@end

@implementation gui_timer
-(void)on_timer:(id)sender
{
  extern void imgui__on_timer();
  imgui__on_timer();
}
@end

gui_timer *timer;

bool create_timer(unsigned int ms)
{
  timer = [gui_timer new];
  timer->timer = [NSTimer scheduledTimerWithTimeInterval:(double)ms*0.001
    target:timer selector:@selector(on_timer:) userInfo:nil repeats:YES];
  return true;
}

void destroy_timer()
{
  [timer->timer invalidate];
  [timer release];
  timer = NULL;
}

unsigned int get_tick_count()
{
  struct timeval tm = {0};
  gettimeofday(&tm, NULL);
  return (unsigned int)(tm.tv_sec*1000 + tm.tv_usec/1000);
}

