#NoEnv
#Persistent
#SingleInstance, Force
scriptName = IdleCheck
version = 2.0-pre-1

; Registry
; ========
RegRead, allowExit, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, allowExit
RegRead, idleTime, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, idleTime
RegRead, pollTime, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, pollTime
If (!allowExit)
  RegWrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, allowExit, 1
If (!idleTime)
  RegWrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, idleTime, 15
If (!pollTime)
  RegWrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\IdleCheck, pollTime, 15

; Millisecond Conversion
; ======================
idleTimeMS := (idleTime*60000)
;idleTimeMS := (idleTime*100)
pollTimeMS := (pollTime*1000)

; Tray Menu
; =========
If A_IsCompiled = 1
  Menu, Tray, NoStandard
Else {}
Menu, Tray, Add, About %scriptName%, about
Menu, Tray, Default, About %scriptName%
If allowExit = 1
  Menu, Tray, Add, Exit, exitApp

; IdleCheck Timer
; ===============
idleCheck:
Gui, coverPrimary: Destroy
Loop
{ If A_TimeIdle < %idleTimeMS%
  Sleep, %pollTimeMS%
  Else
  { ; Cover screen, similar to Windows UAC.
    Sysget, vScreenWidth, 78
    Sysget, vScreenHeight, 79
    Gui, coverPrimary: Color, 000000
    Gui, coverPrimary: -Caption +ToolWindow
    Gui, coverPrimary: Show, x0 y0 w%vScreenWidth% h%vScreenHeight%, coverPrimary
    transparentStart := 0
    WinSet, Transparent, %transparentStart%, coverPrimary
    TrayTip, %scriptName%, Computer will automatically lock in 30 seconds., 30, 2
    Loop, 255
    {
      If A_TimeIdle < %idleTimeMS%
        Gosub, idleCheck
      transparentStart := (transparentStart + 1)
      WinSet, Transparent, %transparentStart%, coverPrimary
      Sleep, 117.68
    }
    Gosub, action
    }
  }

action:
{ Gui, coverPrimary:Destroy
  Gui, coverSecondary:Destroy
  If A_IsCompiled = 1
    Shutdown, 0
  Else
    MsgBox, 64, %ScriptName%, A machine lock would have occurred here`, but the app is not compiled.,
  ExitApp
  }

about: 
{
  MsgBox, 64, About %ScriptName%, %ScriptName% was created by William Quinn (william@hyp5r.io). Source code for this app can be found at https://github.com/Hyp5r/IdleCheck.`n`nHKEY_CURRENT_USER\SOFTWARE\IdleCheck`n  - allowExit = %allowExit%`n  - idleTime = %idleTime%`n  - pollTime = %pollTime%`n`n%Version%,
  }

exitApp:
  ExitApp