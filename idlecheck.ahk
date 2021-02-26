#NoEnv
#Persistent
#SingleInstance, Force
ScriptName = IdleCheck
Version = 2.0-pre-1

; Registry
RegRead, allowExit, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, allowExit
RegRead, idleTime, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, idleTime
RegRead, pollTime, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, pollTime
If (!allowExit)
  RegWrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, allowExit, 1
If (!idleTime)
  RegWrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, idleTime, 15
If (!pollTime)
  RegWrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, pollTime, 15

; Convert times to milliseconds
idleTimeMS := (idleTime*60000) ; Variable converted to milliseconds.
pollTimeMS := (pollTime*1000) ; Variable converted to milliseconds.

; Modify the tray menu
If A_IsCompiled = 1
  Menu, Tray, NoStandard
Else {}
Menu, Tray, Add, About %ScriptName%, #about
Menu, Tray, Default, About %ScriptName%
If allowExit = 1
  Menu, Tray, Add, Exit, #exit
Menu, Tray, Click, 1
Menu, Tray, Tip, %ScriptName%`n`nAuto-Logoff: %SetIdleTime1% minutes idle.`nIdle Polling: %PollTimer1% seconds.

; TrayTip warning to let people know they'll be logged out on idle time.
TrayTip,%ScriptName%, This computer is using %ScriptName%`, which will automatically log you out of the machine after a set amount of time has passed., 15, 1
Sleep, 10000
TrayTip,%ScriptName%, Auto-Logoff: %SetIdleTime1% minutes idle.`nIdle Polling: %PollTimer1% seconds., 15, 2

; Start the #idlecheck sub.
#idlecheck:
Gui, #cover:Destroy
Gui, #logoff:Destroy
Loop
{ If A_TimeIdle < %idleTimeMS%
  Sleep,%pollTimeMS%
  Else
  { ; Cover screen, similar to Windows UAC.
    Sysget, VirtualScreenWidth, 78
    Sysget, VirtualScreenHeight, 79
    Gui, #cover:Color, 000000
    Gui, #cover:-Caption +ToolWindow
    Gui, #cover:Show, X0 Y0 W%VirtualScreenWidth% H%VirtualScreenHeight%, #cover
    WinSet, Transparent, 220, #cover
    ; Progress GUI that lasts 30 seconds before forcing action.
    Gui, #logoff:Color, FFFFFF
    Gui, #logoff:Font, s9, Segoe UI
    Gui, #logoff:Add, Progress, vProgressBar w640 h10 cRed Range0-959
    Gui, #logoff:Add, Text, w640 Center, No activity has been detected.  You'll be automatically logged out in 30 seconds.
    Gui, #logoff:-Caption +AlwaysOnTop +Border
    Gui, #logoff:Show,,IdleCheck
    ; Loops for 30 seconds.  If A_TimeIdle is reset, restart the entire #idlecheck sub.
    Loop, 960
    { GuiControl, #logoff:, ProgressBar,+1
      If A_TimeIdle < %idleTimeMS%
      Gosub, #idlecheck
      Else
      Sleep, 31.25
      }
    Gosub, #idlelogoff
    }
  }

#idlelogoff:
{ Gui, #cover:Destroy
  Gui, #logoff:Destroy
  If A_IsCompiled = 1
    Shutdown, 0
  Else
    MsgBox, 64, %ScriptName%, A machine lock would have occurred here`, but the app is not compiled.,
  ExitApp
  }

#about: 
{
  MsgBox, 64, About %ScriptName%, %ScriptName% was created by William Quinn (william@hyp5r.io). Source code for this app can be found at https://github.com/Hyp5r/IdleCheck.`n`nHKEY_CURRENT_USER\SOFTWARE\IdleCheck`n  - allowExit = %allowExit%`n  - idleTime = %idleTime%`n  - pollTime = %pollTime%`n`n%Version%,
  }

#exit:
  ExitApp