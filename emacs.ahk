;;
;; An autohotkey script that provides emacs-like keybinding on Windows
;; heavily based upon https://github.com/usi3/emacs.ahk
;;
;; Works on Symless' Synergy (Mac server)
;; Note that the script uses ampersand hotkey technique which turns 
;; all combos into a wildcard accepting combo
;; if you are not using synergy then you can turn them back by replacing
;; "LControl & "  with "^"
;; 
;; has a concept of emacs-specific keys as well as bash typical Mac shortcuts
;; toggle emacs specific entries with ESC key
;; Kill script with ESC+x combo
;;
#InstallKeybdHook
#UseHook
#SingleInstance force

; The following line is a contribution of NTEmacs wiki http://www49.atwiki.jp/ntemacs/pages/20.html
SetKeyDelay 0

; turns to be 1 when ctrl-x is pressed
is_pre_x = 0
; turns to be 1 when ctrl-space is pressed
is_pre_spc = 0
; 1 when ctrl is held down
is_emacs = 0
is_mac_super_relevant = 0

do_emacs_and_mac( command, fn ){
  if no_neuter(1)
    for_Mac_super( command, Func(fn) )
  else 
    pipe_ctrl( command )
  return
}


;
do_emacs_only( command, fn){
  return do_emacs_and_mac( command, fn )
  ; this is the same for now
  ; TODO: refactor this to pass in is_emacs setting
}

no_neuter( is_emacs_relevant){
     WinGet, pname, ProcessName, A  ; e.g. Code.exe
    if( pname = "Code.exe" ){
      return 0
    } else {
      return is_target( is_emacs_relevant )
    }
    return 1 ; should never get here
}

; Applications you want to disable emacs-like keybindings
; (Please comment out applications you don't use)
is_target( is_emacs_relevant )
{
  ;;MsgBox %is_emacs_relevant%
  global is_emacs
  IfWinActive,ahk_class ConsoleWindowClass ; Cygwin
    Return 0
  IfWinActive,ahk_class MEADOW ; Meadow
    Return 1 
  IfWinActive,ahk_class cygwin/x X rl-xterm-XTerm-0
    Return 1
  IfWinActive,ahk_class MozillaUIWindowClass ; keysnail on Firefox
    Return 1
  ; Avoid VMwareUnity with AutoHotkey
  IfWinActive,ahk_class VMwareUnityHostWndClass
    Return 1
  IfWinActive,ahk_class Vim ; GVIM
    Return 1

      
;  IfWinActive,ahk_class SWT_Window0 ; Eclipse
;    Return 1
;   IfWinActive,ahk_class Xming X
;     Return 1
;   IfWinActive,ahk_class SunAwtFrame
;     Return 1
;   IfWinActive,ahk_class Emacs ; NTEmacs
;     Return 1  
;   IfWinActive,ahk_class XEmacs ; XEmacs on Cygwin
;     Return 1
	if(is_emacs and is_emacs_relevant){
	;Send 1
	    Return global is_emacs
	} 
  Return 0
}
pipe_ctrl( ctrl_command ){ 
   ;ctrl_command is the A_ThisHotkey
   global is_mac_super_relevant
   theKey :=  StrReplace( ctrl_command, "LControl & ", "^")  ; send the hotkey as typical
    theKey :=  StrReplace( theKey, "LWin & ", "#")  ; send the hotkey as typical
   MsgBox, 4,, %ctrl_command% %theKey% %is_mac_super_relevant%,1
   Send %theKey%
   Return
}

for_Mac_super( command, myfn ){
  global is_mac_super_relevant
  ;MsgBox %command% %is_mac_super_relevant% myfn.Name
  if (is_mac_super_relevant){
    global is_mac_super_relevant = 0
    if( myfn.Name ){
      myfn.Call()
    } else {
      pipe_ctrl( command )
    }
  } else if( myfn.Name ){
    myfn.Call()
  }
  return 0
}

; -----------
; Emacs stubs
; -----------

; ^o
open_line()
{
  Send {END}{Enter}{Up}
  global is_pre_spc = 0
  Return
}

; ^g
quit()
{
  Send {ESC}
  global is_pre_spc = 0
  Return
}

; ^m
newline()
{
  Send {Enter}
  global is_pre_spc = 0
  Return
}

; ^j
indent_for_tab_command()
{
  Send {Tab}
  global is_pre_spc = 0
  Return
}

; ^i
newline_and_indent()
{
  Send {Enter}{Tab}
  global is_pre_spc = 0
  Return
}

; ^s
isearch_forward()
{
  Send ^f
  global is_pre_spc = 0
  Return
}

; ^r
isearch_backward()
{
  Send ^f
  global is_pre_spc = 0
  Return
}

; ^w
kill_region()
{
  Send ^x
  global is_pre_spc = 0
  Return
}

; !w
kill_ring_save()
{
  Send ^c
  global is_pre_spc = 0
  Return
}

; ^y
yank()
{
  Send ^v
  global is_pre_spc = 0
  Return
}
undo()
{
  Send ^z
  global is_pre_spc = 0
  Return
}
find_file()
{
  Send ^o
  global is_pre_x = 0
  Return
}

; ^s
save_buffer()
{
  Send, ^s
  global is_pre_x = 0
  Return
}

; ^c
kill_emacs()
{
  Send !{F4}
  global is_pre_x = 0
  Return
}

; ^n
previous_line()
{
  global
  if is_pre_spc
    Send +{Up}
     ; 
  Else
    Send {Up}
  Return
}

; ^n
next_line()
{
  global
  if is_pre_spc
    Send +{Down}
  Else
    Send {Down}
  Return
}

; !v
scroll_up()
{
  global
  if is_pre_spc
    Send +{PgUp}
  Else
    Send {PgUp}
  Return
}
; ^>
scroll_all_down()
{
  global
  if is_pre_spc
    Send +^{End}
  else
     Send ^{End}
  Return
}
scroll_all_up()
{
  global
  if is_pre_spc
    Send +^{Home}
  else
     Send ^{Home}
  Return
}
; ^v
scroll_down() ; 
{
  global
  if is_pre_spc
    Send +{PgDn}
  Else
    Send {PgDn}
  Return
}
; ----------------------
; Dual Emacs & Mac behaviour
; ----------------------
; ^d
delete_char()
{
  Send {Del}
  global is_pre_spc = 0
  Return
}

; ^b ^h
delete_backward_char()
{
  Send {BS}
  global is_pre_spc = 0
  Return
}


; ^k
kill_line()
{
  ;TODO: if at the end of the line then kill the line feed (bringing the next line up)
  Send {ShiftDown}{END}{SHIFTUP}
  Sleep 50 ;[ms] this value depends on your environment
  Send ^x
  global is_pre_spc = 0
  Return
}

; ^a
move_beginning_of_line() 
{
  global
  if is_pre_spc
    Send +{HOME}
  Else
    Send {HOME}
  Return
}
;^e
move_end_of_line()  
{
  global
  if is_pre_spc
    Send +{END}
  Else
    Send {END}
  Return
}
;^f
forward_char()   
{
  global
  if is_pre_spc
    Send +{Right}
  Else
    Send {Right}
  Return
}
;^b
backward_char()
{
  global
  if is_pre_spc
    Send +{Left} 
  Else
    Send {Left}
  Return
}

; --------------------------------------------------
; hotkey triggers
; --------------------------------------------------

; Using LControl instead of ^ because most of the time 
; I am using a virtual keyboard on my windows machine
; via Symless' Synergy keyboard and Mouse sharing
; Seems that the ^ key doesn't get held down properly 
; so binding to 
; LControl & key 
; works but binding to ^key  does not work. weird 
; When "Send"ing the hot key I need to modify it otherwise it just prints out the word "LControl & Key"

LControl & x::
  If is_target( 1 ){
     pipe_ctrl(A_ThisHotkey)
}
  Else
    is_pre_x = 1
  Return 
LControl & c::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
} 
  Else
  {
    If is_pre_x
      kill_emacs()
  }
  Return  
;; ^o::
;;   If is_target()
;;     pipe_ctrl( A_ThisHotkey )
	;Send %theKey%
;}
;;   Elsen
;;     open_line()
;;   Return
LControl & g::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    quit()
  Return
;; ^j::
;;   If is_target()
;;     pipe_ctrl( A_ThisHotkey )
;	Send %theKey%
;}
;;   Else
;;     newline_and_indent()
;;   Return
LControl & m::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    newline()
  Return
LControl & i::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    indent_for_tab_command()
  Return
LControl & s::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
  {
    If is_pre_x
      save_buffer()
    Else
      isearch_forward()
  }
  Return
LControl & r::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    isearch_backward()
  Return
LControl & w::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    kill_region()
  Return
!w::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    kill_ring_save()
  Return
  
LControl & y::
  If is_target(0){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    yank()
  Return

; +^-::      ; if not using Synergy uncomment this
LControl & -::   ; if using Synergy uncomment this
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    undo()
  Return  

LControl & /::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    undo()
  Return  
  
Alt & >::
  do_emacs_only( A_ThisHotkey , scroll_all_down)
   if is_target(1)
       pipe_ctrl( A_ThisHotkey )
   Else 
      scroll_all_down()
   Return 
   
Alt & <::
   ;  is_target(1) ?
   do_emacs_only( A_ThisHotkey , scroll_all_up)
   Return 
  
LControl & {::
   if is_target(1)
       pipe_ctrl( A_ThisHotkey )
   Else 
      scroll_up()
   Return 
LControl & }::
   if is_target(1)
       pipe_ctrl( A_ThisHotkey )
   Else 
      scroll_down()
   Return 
LControl & v::
  If is_target(0){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    scroll_down()
  Return
!v::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    scroll_up()
  Return

LControl & p::
  If is_target(0) {
    pipe_ctrl( A_ThisHotkey )
  }
  Else{
    previous_line()
	}
  Return

LControl & n::
  If is_target(0){ 
   pipe_ctrl( A_ThisHotkey )
  }
  Else
    next_line()
  Return

;$^{Space}::
;^vk20sc039::
LControl & vk20::
  If is_target(1)
    Send {CtrlDown}{Space}{CtrlUp}
  Else
  {
    If is_pre_spc
      is_pre_spc = 0
    Else
      is_pre_spc = 1
  }
  Return
LControl & @::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
  {
    If is_pre_spc
      is_pre_spc = 0
    Else
      is_pre_spc = 1
  }
  Return
LControl & d::
  If is_target(0){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    delete_char()
  Return
LControl & h::
  If is_target(0){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    delete_backward_char()
  Return
LControl & k::
  do_emacs_and_mac( A_ThisHotKey,  Func("kill_line") )
 ; If no_neuter(0)
  ;  for_Mac_super( A_ThisHotKey, Func("kill_line") )
 ; else 
 ;   pipe_ctrl( A_ThisHotKey )
  Return

; ^a
LControl & a::
  If no_neuter(0) 
    for_Mac_super( A_ThisHotKey , Func("move_beginning_of_line") )
  else 
    pipe_ctrl( A_ThisHotKey ) 
  Return
  
LControl & e::
  If is_target(0){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    move_end_of_line()
  Return
  
; ^b
LControl & b::
  If is_target(0){ 
    pipe_ctrl( A_ThisHotkey )
  }
  Else
    backward_char()
  Return

LControl & f::
  If is_target( 0 ){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
  {
    If is_pre_x
      find_file()
    Else
      forward_char()
  }
  Return  
  

	
; --------------------------------------------------------------
; Mac-like screenshots in Windows (requires Windows 10 Snip & Sketch)
; --------------------------------------------------------------

; Capture entire screen with CMD/WIN + SHIFT + 3
#+3::send #{PrintScreen}

; Capture portion of the screen with CMD/WIN + SHIFT + 4
#+4::#+s
  
; --------------------------------------------------------------
; OS X system shortcuts
; --------------------------------------------------------------

; Make Ctrl + S work with cmd (windows) key
#s::
  global is_emacs
  if (is_emacs){
    ;MsgBox,0, Emacs is on, 2
    return
  }else 
    Send, ^s
  return
  
; Selecting
LWin & a::
  global is_mac_super_relevant = 1
  pipe_ctrl("^a")
  return 
 
; Copying
LWin & c::
  Send {Lwin up}
  global is_mac_super_relevant = 1
  for_mac_super( "^c", "")
  return
  
; Pasting
LWin & v::
  global is_mac_super_relevant = 1
  pipe_ctrl("^v")
  return 

; Cutting
#x::
  ;Send, ^x
  global is_mac_super_relevant = 1
  pipe_ctrl("^x")
  return 

; Opening
#o::
  ;Send ^o
  global is_mac_super_relevant = 1
  pipe_ctrl("^o")
  return 

; Finding
LWin & f::
  ;Send ^f
  global is_mac_super_relevant = 1
  pipe_ctrl("^f")
  return 

; Undo;
LWin & z::
  ;Send ^z
  global is_mac_super_relevant = 1
  pipe_ctrl("^z")
  return 

; Redo
Lwin & y::
  ;Send ^y
  global is_mac_super_relevant = 1
  pipe_ctrl("^y")
  return 

;refresh
#r::
  global is_mac_super_relevant = 1
  for_mac_super("^r","")
  return 
  
; New tab
;#t::
  ;Send ^t
  global is_mac_super_relevant = 1
  pipe_ctrl("^tab")
  return 

; close tab
Lwin & w::
  ;Send ^w
  ;MsgBox %A_ThisHotKey%
  global is_mac_super_relevant = 1
  pipe_ctrl("^w")
  return 

; Close windows (cmd + q to Alt + F4)
#q::Send !{F4}
   return

;open run similar to spotlight
#Space::
  global is_mac_super_relevant = 1
  pipe_ctrl("#r")
  return
  
; Remap Windows + Tab to Alt + Tab.
;Lwin & Tab::AltTab

; minimize windows
;#m::WinMinimize,a

   
;toggle Emacs using Esc key
; Note: Shared Mac basics will remain such as ^a for beginning of line
; TODO: turn on other Mac shortcuts such as super+W etc
^`::  
   global is_emacs
   WinGetClass, class, A
   ;wtf := Process, Exist, "Code.exe"
   
   WinGet, wtf, ProcessName, A ;, ALControl & xLControl & s
    ;ahk_exe %activeprocess%
    
   If (is_emacs){
	MsgBox, 48, %wtf% , Emacs Mode is active (%is_emacs%) now, 2
       global is_emacs = 0
   }Else{ 
	MsgBox, 48, %wtf%, Emacs is off (%is_emacs%)- Mac is still active now, 2
		global is_emacs = 1
	}
	return
Esc & x::
   MsgBox, 48, ShortcutKeys, Emacs & Mac are off (you must relaunch the script), 4
   ExitApp  ;Escape + x key will exit


