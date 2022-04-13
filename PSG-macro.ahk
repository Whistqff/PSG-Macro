; PSG MACRO by fiki, edited by Whistqff(will become obsolete when fiki fixes his version)
; PauseOnLoad and ShowF3 might not work on different languages
#NoEnv
#SingleInstance, Force

; Directories
global savesDir := "D:/MCSR/MultiMC/instances/1.16.1inst1/.minecraft/saves" ; Where your saves is
global oldWorlds := "D:/OldWorlds/PSG" ; Where old worlds will be placed
; Options
global showf3 := True ; If you want to display the f3 screen at the beggining of each run
global pauseload := True ; If you want to pause when you load into the world
global settingsreset := True ; If you want to change render distance after going into a world
global fovreset := True ; if you wanna reset your fov after going into the world
; Values, for settings reset set to 0 to not reset those settings.
global fov := 45 ; Set this to your fov, 110 == Quake pro
global renderDist := 8 ; Set to your desired render distance
global f3Dur := 100 ; How long f3 is shown in miliseconds

If !(FileExist("resets.txt"))
    FileAppend, 0, resets.txt

If !(FileExist(A_ScriptDir . "/PerfectWorld"))
    MsgBox, Please extract the PSG.zip in the same directory as this script and rename it to "PerfectWorld"

If !(FileExist(oldWorlds))
    FileCreateDir, %oldWorlds%

WorldCopy() {
    Loop, Files, %savesDir%/*
    {
        If (InStr(A_LoopFileName, "Speedrun #") && !HasEnteredEnd(A_LoopFilePath))
            FileMoveDir, %A_LoopFilePath%, %oldWorlds% %A_Now%
    }
    FileRead, worldVar, resets.txt
    If (ErrorLevel)
        worldVar := 0
    worldVar += 1
    FileDelete, resets.txt
    FileAppend, %worldVar%, resets.txt
    FileCopyDir, PerfectWorld, %savesDir%/PerfectSpeedrun #%worldVar%, 1
    Clipboard := "PerfectWorld " . worldVar
    While !(FileExist(savesDir . "/PerfectSpeedrun #" . worldVar)) {
        ; do nothing
    }
Return
}

HasEnteredEnd(world) {
    Loop, Files, %world%/advancements/*.json
    {
        AdvFile := A_LoopFileName
    }
    Loop, Read, %world%/advancements/%AdvFile%
    {
        If (InStr(A_LoopReadLine, "enter_the_end")) {
            FileReadLine, IsDone, %world%/advancements/%AdvFile%, A_Index + 4
            If (InStr(IsDone, """done"": true"))
                Return True
        }
    }
    Return False
}

Reset() {
    WinGetTitle, McVar, Minecraft
    If (InStr(McVar, " - "))
        ExitWorld()
    WorldCopy()
    Send, {Tab}{Enter}
    Sleep 300
    Send, ^v
    Sleep 100
    Send, {Tab}{Enter}
    Sleep 100
    Send, {Tab}{Enter}
    ExperimentalSettings()
    If (showf3)
        Showf3()
    If (pauseload)
        PauseOnLoad()
Return
}

ExperimentalSettings() {
    WinGetTitle, McVar, Minecraft*
    While !(InStr(McVar, " - ")) {
        Sleep, 70
        Send, {Tab 2}{Enter}
        WinGetTitle, McVar
    }
Return
}

ShowF3() {
    Loop {
        Sleep 70
        WinGetTitle, McTitle, Minecraft
        If InStr(McTitle, " - ") { 
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
    Loop {
        Sleep 70
        WinGetTitle, McTitle, Minecraft
        If InStr(McTitle, " - ") {
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
    ResetSettings(fov, renderDist)
    Send, {Esc}+{Tab}{Enter}
Return
}

OpenToLan() {
    WinGetTitle, McTitle, Minecraft
    If InStr(McTitle, " - ") {
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
    Clipboard := "data merge entity @e[type=ender_dragon,limit=1] {DragonPhase:2}"
    Send, /
    Sleep, 70
    Send, ^v{Enter}
    Return
}

DataList() {
    OpenToLan()
    WaitLan(100)
    Clipboard := "datapack list"
    Send, /
    Sleep, 70
    Send, ^v{Enter}
    Return
}

ResetSettings(fov, rd) {
    If (rd) {
        RDPresses := rd - 2
        Send, {F3 down}{rshift down}{f 32}{rshift up}{f %RDPresses%}d{F3 up}
    }
    If (fov) {
        FovPresses := Ceil((FOV-30)*1.763)
        Send, {Esc}{Tab 6}{enter}{Tab}{Left 151}{Right %FOVPresses%}{Esc 2}
    }
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
    F5::Reload
}