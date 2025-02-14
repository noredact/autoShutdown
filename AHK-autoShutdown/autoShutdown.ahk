#Requires AutoHotkey v2+
#SingleInstance Force
#Warn
SendMode "Input"
exitConfirmed := 0
exitDetected := 0
exitWarningTimeout := 5  ; 5 seconds to cancel exit

/*
WARNING!
THIS WILL SHUTDOWN YOUR COMPUTER
WARNING!

This is the working version of the shutdown timer
This WILL shutdown your computer

No hotkey is set here, you have to make one yourself
It is recommended to instead add this script to your #includes and call it elsewhere
Call it by setting a hotkey to trigger 'autoShutdownTimer'
Or call it by some other means (I use a script I made to trigger functions from a tooltip menu, for example)

Change the 'exitWarningTimeout variable above should you so desire, default is 5 seconds'

WARNING!
THIS WILL SHUTDOWN YOUR COMPUTER
WARNING!
*/



autoShutdownTimer() {
    global exitDetected
    exitDetected := 0
    ; Ask user for seconds to wait
    shutdownInputObject := InputBox("Input number of seconds to wait`n5 minutes = 300`n30 minutes = 1800`n2 hours = 7200`n`nDouble click the timer to cancel", "Shutdown Timer")
    shutdownInputVal := shutdownInputObject.Value
    if shutdownInputObject.Result = "Cancel"
        return
    if (!shutdownInputObject.Value || shutdownInputObject.Value <= 0)
        return
    msTimerVar := shutdownInputVal * -1000
    ; SetTimer(shutdownFunction, msTimerVar)
    shutdownToolTip(shutdownInputVal)
}

shutdownToolTip(shutdownRemaining) {
    global exitConfirmed
    ; Convert seconds to human-readable format
    readableTimeout := formatShutdownTime(shutdownRemaining)
    ToolTip("Shutting down in: " . readableTimeout . "`nDouble click here to cancel"
    , 0, 0, 14)
    sleep 1000
    shutdownRemaining -= 1
    if exitConfirmed < 1 {
        if shutdownRemaining > 0
            shutdownToolTip(shutdownRemaining)
    else {
        clearToolTip
        shutdownFunction
    }
    }
    else {
        clearToolTip
        return
    }
}

~LButton Up:: {
    ; Check if the click is in either tooltip window
    ttWindow1 := WinExist("ahk_class tooltips_class32 ahk_id " . WinExist("Shutting down in:"))
    ttWindow2 := WinExist("ahk_class tooltips_class32 ahk_id " . WinExist("Abort?"))
    global exitWarningTimeout, exitConfirmed, exitDetected
    MouseGetPos &x, &y, &detectedWindow
    if (detectedWindow == ttWindow1 || detectedWindow == ttWindow2) {
        if exitDetected > 0 {
            clearToolTip
            exitConfirmed := 1
        } else {
            ToolTip("Abort? `n`nClick again within " . exitWarningTimeout . " seconds to cancel shutdown`n`n"
            , 0, 40, 12)
            SetTimer(clearToolTip, exitWarningTimeout * 1000)
            exitDetected := 1
        }
    }
}

clearToolTip() { 
    ToolTip(,,,12)
    ToolTip(,,,14)
}

shutdownFunction() {
    Shutdown 8
}

formatShutdownTime(totalSeconds) {
    ; Convert total seconds to minutes and seconds
    minutes := totalSeconds // 60
    seconds := Mod(totalSeconds, 60)
    ; Format the time string
    if (minutes > 0 && seconds > 0) {
        return minutes . " minute" . (minutes > 1 ? "s " : " ") . seconds . " second" . (seconds > 1 ? "s" : "")
    } else if (minutes > 0) {
        return minutes . " minute" . (minutes > 1 ? "s" : "")
    } else {
        return seconds . " second" . (seconds > 1 ? "s" : "")
    }
}
