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
;
try_emacs = 1
try_mac = 1
is_emacs_relevant = 1

; -----------------
; defaults
; -----------------
mac_command = 0
emacs_command = 0
super_command = 0

; ----------------------------
; return 1 if mac is in play
; ----------------------------
is_mac_env( is_relevant ){
  global try_mac
  if(  try_mac  ){
    WinGet, pname, ProcessName, A  ; e.g. Code.exe
    if( pname = "Code.exe" ){
      return 0
    } else {
       return is_target( try_mac )
    }
  } else {
    return 0
  }
}

; ----------------------------
; return 1 if emacs is in play (also mac)
; ----------------------------
is_emacs_env( is_relevant  ){
  ; if command-line mac is out then emacs is also out
  global try_emacs
  global try_mac = 1
  if( not is_mac_env( try_emacs ) ){
    return 0
  }

  if( try_emacs ){
    WinGet, pname, ProcessName, A  ; e.g. Code.exe
    if( pname = "Code.exe" ){
      return 0
    } else {
       return is_target( is_relevant )
    }
  } else {
    return 0
  }
}

; -----------------------------------------------------
; Applications you want to disable emacs-like keybindings
; (Please comment out applications you don't use)
is_target( is_emacs_relevant )
{
  ;;MsgBox %is_emacs_relevant%

  IfWinActive,ahk_class ConsoleWindowClass ; Cygwin
    Return 0
  IfWinActive,ahk_class MEADOW ; Meadow
    Return 0 
  IfWinActive,ahk_class cygwin/x X rl-xterm-XTerm-0
    Return 0
  IfWinActive,ahk_class MozillaUIWindowClass ; keysnail on Firefox
    Return 1
  ; Avoid VMwareUnity with AutoHotkey
  IfWinActive,ahk_class VMwareUnityHostWndClass
    Return 0
  IfWinActive,ahk_class Vim ; GVIM
    Return 0
      
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
	if(is_emacs_relevant){
	;Send 1
	    Return 1
	} 
  Return 0
}

pipe_ctrl( ctrl_command ){ 
   ;ctrl_command is the A_ThisHotkey
   theKey :=  StrReplace( ctrl_command, "LControl & ", "^")  ; send the hotkey as typical
    theKey :=  StrReplace( theKey, "LWin & ", "#")  ; send the hotkey as typical
   Send %theKey%
   Return
}



; ---------------------------------------------------------------------------------------
; e.g. 
; execute_this( "^a", "move_beginning_of_line", "move_beginning_of_line", super_command )
; ---------------------------------------------------------------------------------------
execute_this( fallback, mac_cmd, emacs_cmd, super_cmd ){
  ;MsgBox, 4, , %fallback% %emacs_cmd% %mac_cmd% %super_cmd%, 4
  global is_emacs_relevant
  if (super_cmd ){
   ;  MsgBox,4, , "has super %super_cmd%", 3""
    global super_command = 0   ;reset
    pipe_ctrl( super_cmd ) 
    ; ??? this will cause a 1-iteration loop, but when it comes back here
    ; it will fall through to fallback
    ; TODO: verify this issue
  } else if(emacs_cmd  and is_emacs_env(is_emacs_relevant) ) {
   ; MsgBox, 4, , "has emacs_cmd and is_emacs_env", 4
    myFn := Func(emacs_cmd)
    myFn.Call()
  } else if(mac_cmd and is_mac_env( is_mac_relevant )) {
    myFn := Func( mac_cmd )
    myFn.Call()
  } else {
    pipe_ctrl( fallback )
  }
  return
}
  
; -----------
; Emacs stubs
; -----------
nada(){
  return

}
mark_line(){
global
  if( not try_emacs)
    return
      
  if is_pre_spc
   is_pre_spc = 0
  else 
    is_pre_spc = 1
   ;  MsgBox, 4, , "mark_line %is_pre_spc%", 3
  return
}

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

find_file_or_fwd(){
  global
  if is_pre_x
    find_file()
  else
    forward_char()
  return
}


set_pre_x(){
  global is_pre_x = 1
  return
}

;
save_buff_or_search(){
  global
 if is_pre_x
  save_buffer()
 else
  isearch_forward()
 return
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
  global
  if (is_pre_x){
    Send !{F4}
    is_pre_x = 0
  }
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
  global super_command
  execute_this( "^x", "nada", "set_pre_x", super_command )
  Return 
LControl & c::
  global super_command
  execute_this( "^c", "nada", "kill_emacs", super_command )
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
  global super_command
  execute_this( "^g", "nada", "quit", super_command )
  ;  quit()
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
  global super_command
  execute_this( "^m", "nada", "newline", super_command )
   ; newline()
  Return
  
LControl & i::
  global super_command
  execute_this( "^i", "nada", "indent_for_tab_command", super_command )
   ; indent_for_tab_command()
  Return
  
LControl & s::
    global super_command 
  execute_this( "^s", "save_buffer", "save_buff_or_search", super_command )
  Return
  
LControl & r::
  global super_command 
  execute_this( "^r", "isearch_backward", "isearch_backward", super_command )
   ; isearch_backward()
  Return
  
LControl & w::
  global super_command 
  execute_this( "^w", "nada", "kill_region", super_command )
   ; kill_region()
  Return
  
!w::
  global super_command 
  execute_this( "!w", "nada", "kill_ring_save", super_command )
   ; kill_ring_save()
  Return
  
LControl & y::
  global super_command 
  execute_this( "^y", "yank", "yank", super_command )
    ;yank()
  Return

; +^-::      ; if not using Synergy uncomment this
LControl & -::   ; if using Synergy uncomment this
  global super_command 
  execute_this( "^-", "nada", "undo", super_command )
      ;scroll_up()
   ; undo()
  Return  

LControl & /::
  If is_target(1){ 
    pipe_ctrl( A_ThisHotkey )
}
  Else
    undo()
  Return  
  
Alt & >::
  global super_command
  execute_this( "+!.","nada", "scroll_all_down", super_command )
 
    ;  scroll_all_down()
   Return 
   
Alt & <::
  global super_command
  execute_this( "+!.", "nada", "scroll_all_up", super_command )
   ;  is_target(1) ?
   ;do_emacs_only( A_ThisHotkey , scroll_all_up)
   Return 
  
LControl & {::
   global super_command 
  execute_this( "^v", "nada", "scroll_up", super_command )
      ;scroll_up()
   Return 
   
LControl & }::
  global super_command 
  execute_this( "^v", "nada", "scroll_down", super_command )
  Return 
   
LControl & v::
  global super_command 
  execute_this( "^v", "scroll_down", "scroll_down", super_command )
  Return
  
!v::
  global super_command 
  execute_this( "!v", "nada", "scroll_up", super_command )
   ; scroll_up()
  Return

LControl & p::
  global super_command
  ;execute_this( fallback, mac_command, emacs_command, super_command )
  execute_this( "^p", "previous_line", "previous_line", super_command )
  Return

LControl & n::
  global super_command 
  execute_this( "^n", "next_line", "next_line", super_command )
  Return

;$^{Space}::
;^vk20sc039::
LControl & vk20::
  global super_command
  ;execute_this( fallback, mac_command, emacs_command, super_command )
  execute_this( "{CtrlDown}{Space}{CtrlUp}", "mark_line", "mark_line", super_command )
   ; Send {CtrlDown}{Space}{CtrlUp}
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
  global super_command 
  execute_this( "^d", "delete_char", "delete_char", super_command )
  Return
LControl & h::
  global super_command 
  execute_this( "^h", "delete_backward_char", "delete_backward_char", super_command )
  Return
LControl & k::
  global super_command 
  execute_this( "^k", "kill_line", "kill_line", super_command )
  Return

; ^a
LControl & a::
  global super_command 
  execute_this( "^a", "move_beginning_of_line", "move_beginning_of_line", super_command )
  Return
  
LControl & e::
  global super_command 
  execute_this( "^e", "move_end_of_line", "move_end_of_line", super_command )
  Return
  
; ^b
LControl & b::
  global super_command 
  execute_this( "^b", "backward_char", "backward_char", super_command )
  Return

LControl & f:: ; TODO: fix up is_pre_x
  global super_command 
  execute_this( "^f", "nada", "find_file_or_fwd", super_command )
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
  global super_command = "^s"
  Send, ^s
  return
  
; Selecting
LWin & a::
  global super_command = "^a"
  Send %super_command%
;
  ;pipe_ctrl("^a")
  return 
 
; Copying
LWin & c::
  Send {Lwin up}
;
  global super_command = "{ctrldown}{c}{ctrlup}"
  Send %super_command%
  return
  
; Pasting
LWin & v::
;
  global super_command = "^v"
  Send %super_command%
  return 

; Cutting
#x::
  ;Send, ^x
;
  global super_command = "^x"
  send %super_command%
  return 

; Opening
#o::
  ;Send ^o
;
  global super_command = "^o"
  Send %super_command%
  return 

; Finding
LWin & f::
  ;Send ^f
;
  global super_command = "^f"
  Send %super_command%
  return 

; Undo;
LWin & z::
  ;Send ^z
;
  global super_command = "^z"
  Send %super_command%
  return 

; Redo
Lwin & y::
  ;Send ^y
;
  global super_command = "^y"
  Send %super_command%
  return 

;refresh
#r::
;
  global super_command = "^r"
  Send %super_command%
  return 
  
; New tab
;#t::
  ;Send ^t
;
  pipe_ctrl("^tab")
  return 

; close tab
Lwin & w::
  ;Send ^w
  ;MsgBox %A_ThisHotKey%
;
  global super_command = "^w"
  Send %super_command%
  return 

; Close windows (cmd + q to Alt + F4)
#q::Send !{F4}
   return

;open run similar to spotlight
;#Space::
;
 ; pipe_ctrl("#r")
  ;return
  
; Remap Windows + Tab to Alt + Tab.
;Lwin & Tab::AltTab

; minimize windows
;#m::WinMinimize,a

   
;toggle Emacs using Esc key
; Note: Shared Mac basics will remain such as ^a for beginning of line
; TODO: turn on other Mac shortcuts such as super+W etc
^`::  
   global try_emacs
   global try_mac
   WinGetClass, class, A
   ;wtf := Process, Exist, "Code.exe"
   
   WinGet, wtf, ProcessName, A ;, ALControl & xLControl & s
    ;ahk_exe %activeprocess%
    
   If (try_emacs){
	MsgBox, 48, %wtf% , Emacs Mode is active (%try_emacs%) now, 2
       global try_emacs = 0
   }Else{ 
	MsgBox, 48, %wtf%, Emacs is off (%try_emacs%)- Mac is still active now, 2
		global try_emacs = 1
	}
	return
Esc & x::
   MsgBox, 48, ShortcutKeys, Emacs & Mac are off (you must relaunch the script), 4
   ExitApp  ;Escape + x key will exit


