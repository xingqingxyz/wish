import locale
import os
import platform
import sys
import time

import uiautomation as am


def set_dark_theme(dark=True):
    # 1. 打开 Windows 设置
    os.startfile("ms-settings:")
    time.sleep(1)

    # 2. 获取设置窗口
    window = am.WindowControl(Name="设置", ClassName="ApplicationFrameWindow")
    print("window: " + window.Name)

    print("activate window and set top most")
    window.SetActive()
    window.SetTopmost()
    search_box = window.EditControl(AutomationId="CommandSearchTextBox")
    print("send search text")
    search_box.SendKeys("浅色主题设置")
    print("click first suggestion")
    window.ListControl(AutomationId="SuggestionsList").GetFirstChildControl().Click(  # type: ignore
        simulateMove=False
    )
    combo = window.ComboBoxControl(
        AutomationId="SystemSettings_Personalize_Color_ColorMode_ComboBox"
    )
    print("click combo")
    combo.Click(simulateMove=False)
    print("click li")
    combo.ListItemControl(Name="深色" if dark else "浅色").Click()
    print("close window")
    window.SendKeys("{ALT}{F4}")


if __name__ == "__main__":
    if (
        platform.system() != "Windows"
        or locale.getlocale()[0] != "Chinese (Simplified)_China"
    ):
        raise SystemError("only supports windows chinese")
    if "###" in sys.argv:
        if not am.IsUserAnAdmin():
            am.RunScriptAsAdmin(sys.argv)
            exit()
    set_dark_theme(len(sys.argv) <= 1 or sys.argv[1] == "on")
