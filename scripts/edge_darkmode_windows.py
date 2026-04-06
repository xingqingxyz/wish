import locale
import platform
import sys

import uiautomation as am


def set_page_color(dark=True):
    window = am.WindowControl(SubName="Edge", ClassName="Chrome_WidgetWin_1")
    print("window: " + window.Name)

    print("activate window")
    window.SetActive()

    print("click settings button")
    window.ToolBarControl(ClassName="EdgeToolbarView").ButtonControl(
        ClassName="BrowserAppMenuButton"
    ).Click(simulateMove=False)
    print("click settings menu-item")
    window.MenuBarControl(
        ClassName="MenuScrollViewContainer"
    ).MenuControl().MenuItemControl(Name="设置(g)", ClassName="MenuItemView").Click(
        simulateMove=False
    )

    page = window.DocumentControl(AutomationId="RootWebArea")
    print("click layout radio")
    page.GroupControl(ClassName="left").RadioButtonControl(Name="外观").Click(
        simulateMove=False
    )
    color_grp = page.GroupControl(ClassName="content-container").GroupControl(
        Name="页面颜色", ClassName="sections-container"
    )
    print("focus color button")
    color_grp.ButtonControl(RegexName="^页面颜色 ").SetFocus()
    window.SendKeys(" ")
    color_name = "水生" if dark else "系统"
    print(f"click {color_name} radio")
    color_grp.MenuControl(Name="页面颜色").RadioButtonControl(Name=color_name).Click(
        simulateMove=False
    )

    print("close tab")
    window.SendKeys("{CTRL}w")


if __name__ == "__main__":
    if (
        platform.system() != "Windows"
        or locale.getlocale()[0] != "Chinese (Simplified)_China"
    ):
        raise SystemError("only supports windows chinese")
    set_page_color(len(sys.argv) <= 1 or sys.argv[1] == "on")
