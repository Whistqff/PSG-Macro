; PSG MACRO by fiki, edited by Whistqff(will become obsolete when fiki fixes his version)
; PauseOnLoad and ShowF3 might not work on different languages
#NoEnv
#SingleInstance, Force

global savesDir := "D:/MCSR/MultiMC/instances/1.16.1inst1/.minecraft/saves" ; Where your saves is
global oldWorlds := "D:/OldWorlds/PSG" ; Where old worlds will be placed
global showf3 := True ; If you want to display the f3 screen at the beggining of each run
global pauseload := True ; If you want to pause when you load into the world
global f3Dur := "100" ; How long f3 is shown in miliseconds

IfNotExist, resets.txt
    FileAppend, 0, resets.txt

IfNotExist, %A_ScriptDir%/PerfectWorld
    MsgBox, Please extract the PSG.zip in the same directory as this script and rename it to "PerfectWorld"

IfNotExist, %oldWorlds%
    FileCreateDir, %oldWorlds%

WorldCopy() {
    FileRead, worldVar, resets.txt
    IfExist, %savesDir%/PerfectWorld %worldVar%
        FileMoveDir, %savesDir%/PerfectWorld %worldVar%, %oldWorlds%/, 1
    worldVar += 1
    FileDelete, resets.txt
    FileAppend, %worldVar%, resets.txt
    FileCopyDir, PerfectWorld, %savesDir%/PerfectWorld %worldVar%, 1
    Loop {
        IfNotExist, %savesDir%/PerfectWorld %worldVar%
            Sleep, 250 ; Increase if the worlds are corrupt when loading into them
        Else
            Break
    }
Return
}

Reset() {
    WinGetTitle, McVar, Minecraft
    If (InStr(McVar, "player"))
        ExitWorld()
    WorldCopy()
    Send, {Tab}{Enter}
    Sleep 300
    Send, psg
    Sleep 100
    Send, {Tab}{Enter}
    Sleep 100
    Send, {Tab}{Enter}
    ExperimentalSettings()
    If (pauseload)
        PauseOnLoad()
    If (showf3)
        Showf3()
Return
}

ExperimentalSettings() {
    Loop {
        Sleep 70
        WinGetTitle, McTitle, Minecraft
        If InStr(McTitle, "player")
            break
        Else
            Send, {Tab 2}{Enter}
    }
Return
}

ShowF3() {
    Loop {
        Sleep 70
        WinGetTitle, McTitle, Minecraft
        If InStr(McTitle, "player") { 
            Sleep 70
            Send, {F3}
            Sleep %f3Dur%
            Send, {F3}
            break
        }
        Else
            continue
    }
Return
}

PauseOnLoad() {
    If ShowF3()
        Send, {Esc}
    Loop {
        Sleep 70
        WinGetTitle, McTitle, Minecraft
        If InStr(McTitle, "player") {
            Sleep 70
            Send, {Esc}
            break
        }
        Else
            continue
    } 
Return
}

ExitWorld() {
    Send, {Esc}+{Tab}{Enter}
Return
}

OpenToLan() {
    WinGetTitle, McTitle, Minecraft
    If InStr(McTitle, "player") {
        Send, {Esc}
        Sleep 50
        Send, +{Tab 3}{Enter}
        Sleep 50
        Send, +{Tab}{Enter}
        Sleep 50
        Send, {Tab}{Enter}
    }
Return
}

Perch() {
    OpenToLan()
    WaitLan(200)
    Clipboard := "/data merge entity @e[type=ender_dragon,limit=1] {DragonPhase:2}"
    Send, t^v{Enter}
    Return
}

DataList() {
    OpenToLan()
    WaitLan(100)
    Clipboard := "/datapack list"
    Send, t^v{Enter}
    Return
}

WaitLan(miliseconds) {
    Loop {
        WinGetTitle, McTitle, Minecraft
        If (InStr(McTitle, "lan")) {
            Break
            Return
        }
        Else
            Sleep, %miliseconds%
    }
    Return
}

#IfWinActive, Minecraft
{
    U::Reset()
    P::Perch()
    O::DataList()
}