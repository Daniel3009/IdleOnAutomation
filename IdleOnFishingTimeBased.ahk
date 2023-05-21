#NoEnv
#Persistent
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
DllCall("ntdll\ZwSetTimerResolution","Int",5000,"Int",1,"Int*",MyCurrentTimerResolution) ;setting the Windows Timer Resolution to 0.5ms, THIS IS A GLOBAL CHANGE

CoordMode Pixel, Client

CoordMode Mouse, Client

if WinExist("Legends Of Idleon")

	WinActivate

else

	msgbox, Game Not found

initialized := 0




;Functions
WaitAndReturnMouseClick(ByRef x, ByRef y){
	KeyWait, RButton, D, T5
	
	if (ErrorLevel = 0){
		MouseGetPos, x, y
	}
	
	return Errorlevel
}

CalculatePowerBarPercent(fishbar_percent){
	power_percent := 0.4664 * fishbar_percent**3 - 1.0693 * fishbar_percent**2 + 1.603 * fishbar_percent + 0.0036
	return max(min(power_percent,1),0)
}

CalculatePowerBarClickDuration(powerbar_bars){
	hold_duration := 2.268 * powerbar_bars**3  - 32.207 * powerbar_bars**2  + 232.423 * powerbar_bars + 82.220
	;msgbox, % powerbar_bars " --> " hold_duration
	return Min(Max(hold_duration, 20),900)
}

HoldLeftMouseMS(duration_ms){
	Mouseclick, left, , , , , D
	DllCall("Sleep","UInt", duration_ms)
	Mouseclick, left, , , , , U
}

Escape::
ExitApp
return

;setup 
s::
initialized := 0
init_started := 1
msgbox, right click the left side of lake
error := WaitAndReturnMouseClick(x_left_lake, _)
if (error){
	msgbox, No button detected, Try Setup again
	return
}

msgbox, right click the right side of lake
error := WaitAndReturnMouseClick(x_right_lake, _)
if (error){
	msgbox, No button detected, Try Setup again
	return
}


distance_pond := (x_right_lake - x_left_lake)
minimum_x := x_left_lake + distance_pond * 0.074
maximum_x := x_right_lake - distance_pond * 0.062
possible_distance := maximum_x - minimum_x

msgbox, Successfully initialized, %possible_distance%

initialized := 1
init_started := 0

return 


RButton::
if (initialized = 0){
	if !(init_started){
		msgbox, Press s to start setup
	}
	return
}
MouseGetPos, fish_position, _
if (fish_position < minimum_x - 50) or (fish_position > maximum_x + 50){
msgbox, Got bad coordinates: %fish_position%, expected between %minimum_x% and %maximum_x%
initialized := 0
return
}
fish_distance_percent:= (fish_position - minimum_x) / possible_distance
powerbar_percent := CalculatePowerBarPercent(fish_distance_percent)
hold_left_mouse_duration_ms := CalculatePowerBarClickDuration(powerbar_percent*7)
HoldLeftMouseMS(hold_left_mouse_duration_ms)

;msgbox, % "Fish Distance Percent: " fish_distance_percent*100 "%   " powerbar_percent * 7  " Power   " hold_left_mouse_duration_ms " ms" ;debug
return