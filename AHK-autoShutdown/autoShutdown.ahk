/*
WARNING!
THIS WILL SHUTDOWN YOUR COMPUTER
WARNING!
This is set to test mode, it will display a message box
change the 'shutdownFunction' below when ready
*/
#Requires AutoHotkey v2+
#SingleInstance Force
#Warn
SendMode "Input"
CoordMode "ToolTip", "Screen"
exitConfirmed := 0
exitDetected := 0

; user defined variables
exitWarningTimeout := 5  ; 5 seconds to cancel exit
; tool tip position 
xPosTT := 0 ; top left X
yPosTT := 0 ; top left Y
; xPosTT := A_ScreenWidth-2 ; bottom right X
; yPosTT := A_ScreenHeight-4 ; bottom right Y

;shutdown function, change this for 'testing'
shutdownFunction() {
    msgbox "Computer would turn off now`nEdit this script when ready" ; msgbox for testing
    ; Shutdown 8 ; This is the line that shuts down the machine  
}

autoShutdownTimer ; calls the main function "autoShutdownTimer"
; user inputs number of seconds to delay shutdown
; click the tooltip twice before the exitWarningTimeout expires to cancel
; leave as is to run the program when it starts or
; create your own hotkey 

autoShutdownTimer() {
    global exitDetected, exitConfirmed
    exitDetected := 0
    exitConfirmed := 0
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
    global exitConfirmed, exitDetected, exitWarningTimeout, xPosTT, yPosTT
    exitWarnVar := exitWarningTimeout

    ; Convert seconds to human-readable format
        Loop {
            readableTimeout := formatShutdownTime(shutdownRemaining)
            if exitDetected > 0 {
            exitReadableTimeout := formatShutdownTime(exitWarnVar)    
            ToolTip("Abort? `nCountdown paused.`nClick again within " . exitReadableTimeout . " to cancel shutdown`n`n", xPosTT, yPosTT, 14)
            exitWarnVar -= 1
            sleep 1000
            continue
            }
            ToolTip("Shutting down in...                   `n" . readableTimeout . "`nClick here twice to cancel", xPosTT, yPosTT, 14)
            sleep 1000
            exitWarnVar := exitWarningTimeout
            shutdownRemaining -= 1
            if exitConfirmed < 1 {
                if shutdownRemaining > 0{
                    continue
                    }
                else {
                    resetToolTip
                    shutdownFunction
                    ExitApp ; this will only trigger if testing, otherwise the computer shutting down will exit the loop
                }
            }
            else { ;user clicked the tool tip twice, cancel shutdown 
                resetToolTip
                exitApp
                }    
    }
}

~LButton Up:: {
    global exitWarningTimeout, exitConfirmed, exitDetected, xPosTT, yPosTT
    exitWarnVar := exitWarningTimeout
    exitReadableTimeout := formatShutdownTime(exitWarnVar)    
    ; Check if the click is in either tooltip window
    ttWindow1 := WinExist("ahk_class tooltips_class32 ahk_id " . WinExist("Shutting down in..."))
    ttWindow2 := WinExist("ahk_class tooltips_class32 ahk_id " . WinExist("Abort?"))
    MouseGetPos &x, &y, &detectedWindow
    if (detectedWindow == ttWindow1 || detectedWindow == ttWindow2) {
        if exitDetected > 0 {
            resetToolTip
            exitConfirmed := 1
            exitApp
        } else {
            ToolTip("Abort? `n`nClick again within " . exitReadableTimeout . " to cancel shutdown`n`n", xPosTT, yPosTT, 14)
            ; ToolTip("Abort? `n`nClick again within " . exitWarningTimeout . " seconds to cancel shutdown`n`n", 0, 40, 12)
            SetTimer(resetToolTip, exitWarningTimeout * 1000)
            exitWarnVar := exitWarningTimeout
            exitDetected := 1
        }
    }
}

resetToolTip() {
global exitDetected
    exitDetected := 0
    ; ToolTip(,,,12)
    ToolTip(,,,14)
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
