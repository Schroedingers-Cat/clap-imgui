# clap-imgui

Minimal example of prototyping CLAP audio plugins using Dear ImGui as the user interface.

![](https://github.com/schwaaa/clap-plugin/blob/main/clap_imgui_screencap.gif?raw=true)

![](https://github.com/schwaaa/clap-plugin/blob/main/clap_imgui_screencap_2.gif?raw=true)
---
### CLAP

[CLAP](https://github.com/free-audio/clap#readme) is a platform-agnostic audio plugin interface that strives to be clear and flexible. It is a feature of CLAP that a valid plugin can implement a minimal subset of the API, as this example does. The only CLAP extensions supported by this example are the GUI, params, and timer extensions. CLAP supports many more extensions, like events, parameter automation, multiple audio ports, MIDI, etc. This is a bare-metal example of interacting directly with the API, not a framework.

CLAP does not specify or prefer any particular UI implementation. It's valid to use native Windows/Mac/X11/etc controls directly, or draw bitmaps to the screen, or use a full-featured GUI framework, or whatever works.

---
### ImGui

The UI for this example is presented via [Dear ImGui](https://github.com/ocornut/imgui). The ImGui concept is easy to misunderstand so please read [the Dear ImGui README](https://github.com/ocornut/imgui#readme). The key concept is that the caller (this plugin) does not retain any state related to the UI. This allows developers to quickly prototype controls.

100% of the plugin's UI code is in `plugin_impl__draw()`, a single small function. For example, this is the code for the volume slider, which draws the control, handles mouse and keyboard input, and links the control to the voldb variable:

```ImGui::SliderFloat("Volume", &voldb, -60.0f, 12.0f, "%+.1f dB", 1.0f);```

You have some control over the appearance and placement of the control, but the primary design goal is simplicity and ease of programmer use. ImGui is not typically used for end-user UI.

ImGui is helpful for this example because:
- Permissively licensed
- No external dependencies
- Very easy to interact with

---
### Usage
#### MacOS
```shell
# Checkout
git clone --recurse-submodules https://github.com/u-he-frank/clap-imgui
cd clap-imgui

# Generate project files
cmake -G Xcode -B build

# Build
xcodebuild -project build/clap-imgui.xcodeproj -scheme clap-imgui build

# Or open project
open build/clap-imgui.xcodeproj
```

The example code exports two very basic plugins, **Volume/Pan** and **Tone Generator**. You should be able to prototype basic plugins by editing (or adding) a [src/plugin_impl_#.cpp](https://github.com/schwaaa/clap-imgui/blob/main/src/plugin_impl_0.cpp) file, which contains the actual audio plugin and UI implementation. The plugin descriptor and parameter definitions are at the top of the file, and `plugin_impl__draw()` contains the plugin-specific UI code.

If you want to extend your plugin to add support for other CLAP extensions, you will need to add scaffolding code to  [src/plugin.cpp](https://github.com/schwaaa/clap-imgui/blob/main/src/plugin.cpp), similar to how the gui and parameter extensions are handled.

The rest of the repo consists of [CLAP](https://github.com/free-audio/clap), [ImGui](https://github.com/ocornut/imgui), and [GLFW](https://github.com/glfw/glfw), which is used as a backend for ImGui. You probably don't need to touch any of it.

---
### Note

ImGui, like many UI implementations, uses a polling update mechanism. This example uses SetTimer on Windows and NSTimer on MacOS, but in the interest of minimizing platform-specific code (and not having to deal with X11 threads), uses the CLAP timer extension on linux. If the host application does not support the CLAP timer extension, the linux version of this plugin will not show a UI.

---
### Builds

You can download a macOS, Windows, or linux binary by clicking [Actions](https://github.com/schwaaa/clap-imgui/actions) in the top bar, then clicking the latest (topmost) mac-build, win-build, or lin-build workflow run. The **clap-example.clap** binary will be under Artifacts at the bottom of the workflow run page.

*Note: linux does not compile on HEAD. The last commit that builds on linux is b5bc93c5.*
