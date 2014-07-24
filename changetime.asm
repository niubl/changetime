;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;All by 冰封血情 2009.12.12
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff changetime.asm
; Link /SUBSYSTEM:CONSOLE changetime.obj
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  .386
  .model flat, stdcall
  option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include    windows.inc
include    kernel32.inc
includelib kernel32.lib
include     masm32.Inc
includelib  masm32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  .data?
hStdIn      dd ?  ;控制台输入句柄
hStdOut      dd ?  ;控制台输出句柄
hfile         dd  ?   ;文件句柄
szBuffer     db MAX_PATH dup (?)
szBuff       db MAX_PATH dup (?)
dwBytesRead   dd ?
dwBytesWrite  dd  ?
ft         FILETIME<?>
ft0         FILETIME<?>
ft1         FILETIME<?>
systime    SYSTEMTIME<?>
szBuffer1 db MAX_PATH dup (?)
szBuffer2 db MAX_PATH dup (?)
szBuffer3 db MAX_PATH dup (?)
szBuffer4 db MAX_PATH dup (?)
szBuffer5 db MAX_PATH dup (?)
szBuffer6 db MAX_PATH dup (?)
;********************************************************************
  .const
szTitle      db 'Change the time',0
szSuccess     db  '................................OK!',0dh,0ah
szUsage       db  'USAGE,FOR EXAMPLE:change.exe [Enter] C:\1.txt [Enter] 2012(y) [Enter] 12(m) [Enter] 12(d) [Enter] 12(h) [Enter] 12(m) [Enter] 12(s)',0
szFail        db   'Fail to opean the file......      ',0dh,0ah
szFailtoconvert db 'Fail to convert......',0dh,0ah
sz            db   ' ',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  .code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 控制台 Ctrl-C 捕获例程
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CtrlHandler proc _dwCtrlType
 
  pushad
  mov eax,_dwCtrlType
  .if eax == CTRL_C_EVENT || eax == CTRL_BREAK_EVENT
   invoke CloseHandle,hStdIn
  .endif
  popad
  mov eax,TRUE
  ret
_CtrlHandler endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;去掉读入文件的回车和换行字符,修改字符串以0结尾
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Format proc uses esi _lpData,_dwSize
  mov esi,_lpData
  mov ecx,_dwSize
  lea edi,szBuff
  xor edx,edx
  cld
_LoopBegin:
  or ecx,ecx
  jz _end
  lodsb
  cmp al,0dh  ;遇到0dh则丢弃
  jz _LoopBegin
  cmp al,0ah  ;遇到0ah则丢弃
  jz _LoopBegin
  stosb
  inc edx
  loop _LoopBegin
_end:
      invoke lstrcat,addr szBuff,addr sz
  ret
_Format endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
;********************************************************************
; 获取控制台句柄、设置句柄属性
;********************************************************************
  invoke GetStdHandle,STD_INPUT_HANDLE
  mov hStdIn,eax
  invoke GetStdHandle,STD_OUTPUT_HANDLE
  mov hStdOut,eax
  invoke SetConsoleMode,hStdIn,ENABLE_LINE_INPUT or ENABLE_ECHO_INPUT or ENABLE_PROCESSED_INPUT
  invoke SetConsoleCtrlHandler,addr _CtrlHandler,TRUE
  invoke SetConsoleTitle,addr szTitle
;********************************************************************
; 读取控制台输入
;********************************************************************
      invoke  RtlZeroMemory, addr szBuffer ,sizeof szBuffer
   invoke ReadConsole,hStdIn,addr szBuffer,sizeof szBuffer,\
    addr dwBytesRead,NULL  
   invoke _Format,addr szBuffer,dwBytesRead
      invoke CreateFile,addr szBuff,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ or FILE_SHARE_WRITE,0,\
   OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
   .if eax == INVALID_HANDLE_VALUE
     invoke WriteConsole,hStdOut,addr szFail,sizeof szFail,\
    addr dwBytesWrite,NULL
    invoke WriteConsole,hStdOut,addr szUsage,sizeof szUsage,\
    addr dwBytesWrite,NULL
   ret
   .endif
      mov hfile,eax
   invoke ReadConsole,hStdIn,addr szBuffer1,sizeof szBuffer1,\
    addr dwBytesRead,NULL
    lea edx,szBuffer1
    invoke atol,edx
      mov systime.wYear,ax
      xor edx,edx
      xor eax,eax
   invoke ReadConsole,hStdIn,addr szBuffer2,sizeof szBuffer2,\
    addr dwBytesRead,NULL
    lea edx,szBuffer2
    invoke atol,edx
        mov systime.wMonth,ax
        xor edx,edx
      xor eax,eax
   invoke ReadConsole,hStdIn,addr szBuffer3,sizeof szBuffer3,\
    addr dwBytesRead,NULL
    lea edx,szBuffer3
    invoke atol,edx
        mov systime.wDay,ax       
        xor edx,edx
      xor eax,eax
   invoke ReadConsole,hStdIn,addr szBuffer4,sizeof szBuffer4,\
    addr dwBytesRead,NULL
    lea edx,szBuffer4
    invoke atol,edx
        mov systime.wHour,ax
        xor edx,edx
      xor eax,eax
   invoke ReadConsole,hStdIn,addr szBuffer5,sizeof szBuffer5,\
    addr dwBytesRead,NULL
    lea edx,szBuffer5
    invoke atol,edx
        mov systime.wMinute,ax
        xor edx,edx
      xor eax,eax
   invoke ReadConsole,hStdIn,addr szBuffer6,sizeof szBuffer6,\
    addr dwBytesRead,NULL
    lea edx,szBuffer6
    invoke atol,edx
        mov systime.wSecond,ax      
        xor edx,edx
      xor eax,eax      
      invoke SystemTimeToFileTime,addr systime,addr ft
      invoke LocalFileTimeToFileTime,addr ft,addr ft0
      invoke GetFileTime,hfile,addr ft1,addr ft1,addr ft1
    invoke SetFileTime,hfile,addr ft0,addr ft0,addr ft0
 
    xor edx,edx
    xor eax,eax
    mov eax,ft0.dwLowDateTime
    mov edx,ft0.dwHighDateTime
    cmp eax,ft1.dwLowDateTime
    jz _Fail
    cmp edx,ft1.dwHighDateTime
    jz _Fail
    invoke CloseHandle,hfile    
     invoke WriteConsole,hStdOut,addr szSuccess,sizeof szSuccess,\
    addr dwBytesWrite,NULL
   jmp _Success
    _Fail:
    invoke CloseHandle,hfile
    invoke WriteConsole,hStdOut,addr szFailtoconvert,sizeof szFailtoconvert,\
    addr dwBytesWrite,NULL
    _Success:
    invoke ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  end start