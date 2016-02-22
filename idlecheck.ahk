; AHK VERSION: Lexikos 1.1.23.00 Unicode 32-bit
; AUTHOR: William Quinn (wquinn@outlook.com)
; TITLE: IdleCheck
; UUID: 167edc5c-d98a-11e5-b5d2-0a1d41d68578

; Icon by Recep Kütük
; https://www.iconfinder.com/icons/728969/apple_computer_device_mouse_pc_technology_icon

; Set variables
#NoEnv
#Persistent
#SingleInstance,Force
SendMode,Input
SetWorkingDir,%A_ScriptDir%
FormatTime,Date,,yyyy/MM/dd
FormatTime,Time,,h:mm:ss tt

; Retrieve common Windows variables
EnvGet,Temp,Temp
EnvGet,Tmp,Tmp
EnvGet,WinDir,WinDir

; Script Variables
Install = %A_MyDocuments%\c5f530c5-8dfe-4f08-bb49-d5ef43adbc92
ScriptName = IdleCheck
Version = 1.0.0
DblClickSpeed := DllCall("GetDoubleClickTime") , firstClick := 0 ; autohotkey.com/board/topic/50788-double-click-tray-icon/?p=317446

; INI Location
INI = IdleCheck.ini

; Read INI for variables
IniRead,SetIdleTime1,%INI%,IdleCheck,SetIdleTime ; Variable read in minutes.
IniRead,PollTimer1,%INI%,IdleCheck,PollTimer ; Variable read in seconds.

; Overwrite INI with command line if they don't equal a blank
If 1 <>
  SetIdleTime1=%1%
If 2 <>
  PollTimer1=%2%

; Create an INI file if one doesn't exist AND no command line parameters were set.
IfNotExist,%INI%
{ If 1 =
  { If 2 =
    { FileAppend,`[IdleCheck`]`nSetIdleTime=60`nPollTimer=15,%INI%
      TrayTip,%ScriptName%,An INI file wasn't found and no command line parameters were sent. To fix this`, an INI file was placed where the script is located.,15,3
      Sleep,10000
      ExitApp
      }
    }
  }

; If one command line parameter was set, but not the second one, default it to 15 seconds.
If 2 =
  PollTimer1=15

; Convert times to milliseconds
SetIdleTime2 := (SetIdleTime1*60000) ; Variable converted to milliseconds.
PollTimer2 := (PollTimer1*1000) ; Variable converted to milliseconds.

; Modify the tray menu
If A_IsCompiled = 1
{ Menu,Tray,NoStandard
  }
Else {}
Menu,Tray,Add,About %ScriptName%,#about
Menu,Tray,Default,About %ScriptName%
Menu,Tray,Click,1
Menu,Tray,Tip,%ScriptName%`n`nAuto-Logoff: %SetIdleTime1% minutes idle.`nIdle Polling: %PollTimer1% seconds.

; TrayTip warning to let people know they'll be logged out on idle time.
TrayTip,%ScriptName%,This computer is using %ScriptName%`, which will automatically log you out of the machine after a set amount of time has passed.,15,1
Sleep,10000
TrayTip,%ScriptName%,Auto-Logoff: %SetIdleTime1% minutes idle.`nIdle Polling: %PollTimer1% seconds.,15,2

; Start the #idlecheck sub.
#idlecheck:
Gui,#cover:Destroy
Gui,#logoff:Destroy
Loop
{ If A_TimeIdle < %SetIdleTime2%
  Sleep,%PollTimer2%
  Else
  { ; Cover screen, similar to Windows UAC.
    Sysget,VirtualScreenWidth,78
    Sysget,VirtualScreenHeight,79
    Gui,#cover:Color,000000
    Gui,#cover:-Caption +ToolWindow
    Gui,#cover:Show,X0 Y0 W%VirtualScreenWidth% H%VirtualScreenHeight%,#cover
    WinSet,Transparent,220,#cover
    ; Progress GUI that lasts 30 seconds before forcing action.
    Gui,#logoff:Color,FFFFFF
    Gui,#logoff:Font,s9,Segoe UI
    Gui,#logoff:Add,Progress,vProgressBar w640 h10 cRed Range0-959
    Gui,#logoff:Add,Text,w640 Center,No activity has been detected.  You'll be automatically logged out in 30 seconds.
    Gui,#logoff:-Caption +AlwaysOnTop +Border
    Gui,#logoff:Show,,IdleCheck
    ; Loops for 30 seconds.  If A_TimeIdle is reset, restart the entire #idlecheck sub.
    Loop,960
    { GuiControl,#logoff:,ProgressBar,+1
      If A_TimeIdle < %SetIdleTime2%
      Gosub,#idlecheck
      Else
      Sleep,31.25
      }
    Gosub,#idlelogoff
    }
  }

#idlelogoff:
{ Gui,#cover:Destroy
  Gui,#logoff:Destroy
  If A_IsCompiled = 1
    Shutdown,0
  Else
    MsgBox,You would've been logged out`, yo!
  ExitApp
  }

#about: ; autohotkey.com/board/topic/50788-double-click-tray-icon/?p=317446
{ If ((A_TickCount-firstClick) < DblClickSpeed)
  { TrayTip,%ScriptName%,Yeah`, yeah`, you're not idle`, I get it.  You don`'t have to rub it in.,30,1
    }
  Else
  { firstClick := A_TickCount
    KeyWait,LButton
    KeyWait,LButton,% "D T" . DblClickSpeed/1000
    If (ErrorLevel && firstClick)
      TrayTip,%ScriptName%,Created by William Quinn`nwquinn@outlook.com`ngitlab.com/u/Hyperdaemon`n`nVersion %Version%,30,1
    }
  }
