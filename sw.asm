.MODEL SMALL
.STACK 100h

.DATA
    ; UI Strings
    header      DB '==================================================', '$'
    title_msg   DB '             8086 ASSEMBLY STOPWATCH              ', '$'
    controls    DB '     [SPACE] Start/Stop   [R] Reset   [Q] Quit    ', '$'
    status_stop DB 'STATUS: STOPPED ', '$'
    status_run  DB 'STATUS: RUNNING ', '$'
    
    ; Time Data
    start_tick  DW 0
    accumulated DW 0       
    current_tick DW 0
    is_running  DB 0       
    
    ; Output Buffer
    time_str    DB '00:00:00', '$' 

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Set Video Mode 03h (80x25 Text Mode)
    MOV AX, 0003h
    INT 10h

    ; Hide Cursor
    MOV AH, 01h
    MOV CX, 2000h 
    INT 10h

    CALL DRAW_INTERFACE

MAIN_LOOP:
    ; ---------------------------------------------------------
    ; KEYBOARD CHECK (SAFE BRANCHING)
    ; ---------------------------------------------------------
    MOV AH, 01h
    INT 16h
    
    ; Logic: INT 16h/01h sets ZF=1 if no key, ZF=0 if key waiting.
    ; We want to fall through if NO key (ZF=1) to go to timer.
    ; So if ZF=0 (Key Waiting), we jump to input handler.
    
    JNZ HANDLE_INPUT    ; Jump if key is waiting
    JMP TIMER_SECTION   ; Otherwise, go to timer logic

HANDLE_INPUT:
    ; Consume the key
    MOV AH, 00h
    INT 16h

    ; Q - QUIT
    CMP AL, 'q'
    JNE CHECK_Q_CAPS    ; If not 'q', check 'Q'
    JMP EXIT_ROUTINE    ; It is 'q', exit
CHECK_Q_CAPS:
    CMP AL, 'Q'
    JNE CHECK_SPACE     ; If not 'Q', check Space
    JMP EXIT_ROUTINE    ; It is 'Q', exit

    ; SPACE - TOGGLE
CHECK_SPACE:
    CMP AL, ' '
    JNE CHECK_R         ; If not Space, check 'r'
    JMP TOGGLE_ROUTINE  ; It is Space, toggle

    ; R - RESET
CHECK_R:
    CMP AL, 'r'
    JNE CHECK_R_CAPS    ; If not 'r', check 'R'
    JMP RESET_ROUTINE   ; It is 'r', reset
CHECK_R_CAPS:
    CMP AL, 'R'
    JNE TIMER_SECTION   ; If not 'R', ignore and go to timer
    JMP RESET_ROUTINE   ; It is 'R', reset


; ---------------------------------------------------------
; ACTION ROUTINES
; ---------------------------------------------------------
EXIT_ROUTINE:
    JMP EXIT_PROGRAM

RESET_ROUTINE:
    MOV is_running, 0
    MOV accumulated, 0
    MOV start_tick, 0
    CALL DRAW_ZEROS
    JMP TIMER_SECTION

TOGGLE_ROUTINE:
    XOR is_running, 1
    
    CMP is_running, 1
    JNE STOPPING_LOGIC
    
    ; STARTING
    MOV AH, 00h
    INT 1Ah
    MOV start_tick, DX
    
    ; Draw "RUNNING"
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 6
    MOV DL, 25
    INT 10h
    LEA DX, status_run
    MOV AH, 09h
    INT 21h
    
    JMP TIMER_SECTION

STOPPING_LOGIC:
    ; STOPPING
    MOV AH, 00h
    INT 1Ah
    SUB DX, start_tick
    ADD accumulated, DX
    
    ; Draw "STOPPED"
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 6
    MOV DL, 25
    INT 10h
    LEA DX, status_stop
    MOV AH, 09h
    INT 21h
    JMP TIMER_SECTION

; ---------------------------------------------------------
; TIMER LOGIC
; ---------------------------------------------------------
TIMER_SECTION:
    CMP is_running, 1
    JNE WAIT_LOOP       ; If not running, skip math

    ; Get Current Time
    MOV AH, 00h
    INT 1Ah
    
    ; Calculate
    SUB DX, start_tick
    ADD DX, accumulated
    MOV current_tick, DX
    
    CALL TICKS_TO_TIME
    CALL DRAW_TIME

WAIT_LOOP:
    ; Delay loop
    MOV CX, 0FFFh
DELAY:
    LOOP DELAY
    JMP MAIN_LOOP

EXIT_PROGRAM:
    MOV AH, 01h
    MOV CX, 0607h
    INT 10h
    MOV AH, 4Ch
    INT 21h

MAIN ENDP

; =============================================================
; SUBROUTINES
; =============================================================

DRAW_INTERFACE PROC
    MOV AH, 02h
    MOV DH, 2
    MOV DL, 15
    INT 10h
    LEA DX, header
    MOV AH, 09h
    INT 21h

    MOV AH, 02h
    MOV DH, 3
    MOV DL, 15
    INT 10h
    LEA DX, title_msg
    MOV AH, 09h
    INT 21h

    MOV AH, 02h
    MOV DH, 4
    MOV DL, 15
    INT 10h
    LEA DX, header
    MOV AH, 09h
    INT 21h
    
    MOV AH, 02h
    MOV DH, 6
    MOV DL, 25
    INT 10h
    LEA DX, status_stop
    MOV AH, 09h
    INT 21h

    MOV AH, 02h
    MOV DH, 12
    MOV DL, 15
    INT 10h
    LEA DX, controls
    MOV AH, 09h
    INT 21h
    
    CALL DRAW_ZEROS
    RET
DRAW_INTERFACE ENDP

DRAW_ZEROS PROC
    MOV AH, 02h
    MOV DH, 9
    MOV DL, 35
    INT 10h
    
    LEA DX, time_str
    MOV byte ptr [time_str], '0'
    MOV byte ptr [time_str+1], '0'
    MOV byte ptr [time_str+3], '0'
    MOV byte ptr [time_str+4], '0'
    MOV byte ptr [time_str+6], '0'
    MOV byte ptr [time_str+7], '0'
    MOV AH, 09h
    INT 21h
    RET
DRAW_ZEROS ENDP

DRAW_TIME PROC
    MOV AH, 02h
    MOV DH, 9
    MOV DL, 35
    INT 10h
    LEA DX, time_str
    MOV AH, 09h
    INT 21h
    RET
DRAW_TIME ENDP

TICKS_TO_TIME PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV AX, current_tick
    
    ; Hundredths
    MOV DX, 0
    MOV BX, 55
    MUL BX
    MOV BX, 10
    DIV BX
    MOV DX, 0
    MOV BX, 100
    DIV BX
    PUSH DX
    
    ; Seconds
    MOV DX, 0
    MOV BX, 60
    DIV BX
    PUSH DX
    
    ; Minutes
    PUSH AX
    
    ; Convert to ASCII
    POP AX ; Minutes
    MOV BL, 10
    DIV BL
    ADD AL, '0'
    ADD AH, '0'
    MOV [time_str], AL
    MOV [time_str+1], AH
    
    POP AX ; Seconds
    MOV BL, 10
    DIV BL
    ADD AL, '0'
    ADD AH, '0'
    MOV [time_str+3], AL
    MOV [time_str+4], AH
    
    POP AX ; Hundredths
    MOV BL, 10
    DIV BL
    ADD AL, '0'
    ADD AH, '0'
    MOV [time_str+6], AL
    MOV [time_str+7], AH

    POP DX
    POP CX
    POP BX
    POP AX
    RET
TICKS_TO_TIME ENDP

END MAIN
