#Requires AutoHotkey v2+
#SingleInstance Force
#Warn
SendMode "Input"
CoordMode "ToolTip", "Screen"
exitDetected := 0
exitWarningTimeout := 5  ; 5 seconds to cancel exit

/*
This is the test mode of the shutdown, instead of actually shutting down, it will only 
display a message box
Change the hotkey below this comment block and run the script to try it out!

The 'exitWarningTimeout variable above gives the user that much time to double click the tooltip to cancel'
*/
Edit_This_Script_And_Change_This::
{
    autoShutdownTimer()
}
autoShutdownTimer() {
    ; Ask user for seconds to wait
    shutdownInputObject := InputBox("Input number of seconds to wait`n5 minutes = 300`n30 minutes = 1800`n2 hours = 7200`n`nDouble click the timer to cancel", "Shutdown Timer")
    shutdownInputVal := shutdownInputObject.Value
    if shutdownInputObject.Result = "Cancel"
        return
    if (!shutdownInputObject.Value || shutdownInputObject.Value <= 0)
        return
    msTimerVar := shutdownInputVal * -1000
    SetTimer(shutdownFunction, msTimerVar)
    shutdownToolTip(shutdownInputVal)
}

shutdownToolTip(shutdownRemaining) {
    ; Convert seconds to human-readable format
    readableTimeout := formatShutdownTime(shutdownRemaining)

    ToolTip("Shutting down in: " . readableTimeout . "`nDouble click here to cancel"
    , 0, 0, 14)
    sleep 1000
    shutdownRemaining -= 1
    if shutdownRemaining > 0
        shutdownToolTip(shutdownRemaining)
}

~LButton Up:: {
    ; Check if the click is in either tooltip window
    ttWindow1 := WinExist("ahk_class tooltips_class32 ahk_id " . WinExist("Shutting down in:"))
    ttWindow2 := WinExist("ahk_class tooltips_class32 ahk_id " . WinExist("Abort?"))
    global exitWarningTimeout, exitDetected
    MouseGetPos &x, &y, &detectedWindow

    if (detectedWindow == ttWindow1 || detectedWindow == ttWindow2) {
        if exitDetected > 0 {
            ExitApp
        } else {
            ToolTip("Abort? `n`nClick again within " . exitWarningTimeout . " seconds to cancel shutdown`n`n"
            , 0, 40, 12)
            SetTimer(clearToolTip, exitWarningTimeout * 1000)
            exitDetected := 1
        }
    }
}

clearToolTip() {
    global exitDetected
    ToolTip(,,,12)
    exitDetected := 0
}

shutdownFunction() {
    MsgBox "Test mode complete`nSystem would have shutdown now"
    Return
    ; Shutdown, 8  ; Uncomment this line to actually shut down the computer
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

