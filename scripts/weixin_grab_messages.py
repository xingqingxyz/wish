import json
import os
import subprocess
import tempfile

import uiautomation as auto


def has_weixin_running():
    return any(p.exeName == "Weixin.exe" for p in auto.GetProcesses(False))


def grab_messages():
    window = auto.WindowControl(Name="微信", ClassName="mmui::MainWindow")
    window.SetFocus()
    window.ToolBarControl(AutomationId="MainView.main_tabbar").ButtonControl(
        Name="微信"
    ).Click()
    session_list = window.ListControl(AutomationId="session_list")
    msgs_map = {}
    for session in session_list.GetChildren():
        lines = session.Name.splitlines()
        if len(lines) < 4 or not lines[1].endswith("条] "):
            break
        name, cnt, msg0 = (
            lines[0],
            int(lines[1][1 : lines[1].index("条")]),
            "\n".join(lines[2:-1]),
        )
        msgs_map[name] = {"time": lines[-1]}
        if cnt == 1:
            msgs_map[name]["messages"] = [msg0]
            continue
        session.Click()
        msgs_map[name]["messages"] = [
            li.Name
            for li in window.ListControl(
                AutomationId="chat_message_list"
            ).GetChildren()[-cnt:]
        ]
    return msgs_map


def main():
    weixin_processes = [p for p in auto.GetProcesses() if p.exeName == "Weixin.exe"]
    if weixin_processes:
        children = auto.WindowControl(
            Name="微信", ClassName="mmui::MainWindow"
        ).GetChildren()
        if not children:
            print("Weixin window found but no child window, please close it first")
            restart = input("Force stop and Restart? (y/n)")
            if restart.lower() != "y":
                exit(130)
            if not all(auto.TerminateProcess(p.pid) for p in weixin_processes):
                print("cannot terminate weixin processes")
                exit(1)
            ec = subprocess.call(
                rf'start "" "{weixin_processes[0].exePath}"', shell=True
            )
            if ec != 0:
                print(rf"cannot start {weixin_processes[0].exePath}")
                exit(ec)
    else:
        ec = subprocess.call(
            rf'start "" "{os.path.expandvars(r"%ProgramFiles%\Tencent\Weixin\Weixin.exe")}"',
            shell=True,
        )
        if ec != 0:
            print("cannot start WeChat.exe")
            exit(ec)
    msgs_map = grab_messages()
    messages_json = os.path.join(tempfile.gettempdir(), "weixin_messages.json")
    with open(
        messages_json,
        "w",
        encoding="utf8",
    ) as f:
        json.dump(msgs_map, f)
        try:
            subprocess.call(["jq", ".", messages_json])
        finally:
            pass


if __name__ == "__main__":
    main()
