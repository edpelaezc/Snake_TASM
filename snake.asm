; S N A K E

; by John L. Dalton
; st 881022-1841
; fn
; v.2

              ; CONSTANTS


off             equ 0
on              equ 1
MAXLEN          equ 500         ; maximum length of snake
EOS             equ '$'         ; end of string marker
space           equ ' '         ; space
lf              equ 10          ; line feed
cr              equ 13          ; carriage return
keybd           equ 16h         ; keyboard interrupt
video           equ 10h         ; video interrupt
DOSfunct        equ 21h         ; DOS function interrupt
printer         equ 17h         ; printer I/O interrupt
clock           equ 1Ah         ; clock interrupt
body            equ 15          ; snake body segment
sncolor         equ 1011b       ; bright cyan snake color
wall            equ 219
food            equ 42
air             equ 32

clrscr macro
        call clear_scr
        endm
;----
wait_key macro
        local weight
weight: call keypressed
        jz weight
        endm
;------

Print MACRO string
        lea dx,string
        mov ah,9
        int Dosfunct
        ENDM
;------
Set_Cursor MACRO row,col,state          ; affects AH,BH,CX,DX
        IFNB <state>            ; positions cursor and optionally turns it
           IFE state-ON         ; on or off
              mov cx,0607h         ; cursor on for color
              mov ax,es
              cmp ax,0B800h        ; make sure using color
              je $+5
              mov cx,0C0Dh         ; cursor on for mono
           ELSE
              mov cx,2020h         ; cursor off
           ENDIF
           mov ah,1
           int video               ; set cursor type
        ENDIF
        mov dh,row
        mov dl,col
        mov bh,0
        mov ah,2
        int video               ; set cursor position
        ENDM

; . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

STACK   segment stack           ; stack segment
        dw 128 dup (?)          ; allow 256 bytes for stack
STACK   ends

; . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

DATA    segment
        speed dw ?                  ; number from 0(fast)..60(slow)
        syze dw 1                       ; number of segments
        dir dw 0
        new_dir dw -162,-160,-158,0
                dw -2,0,2,0
                dw 158,160,162
        seed dw ?               ; for random numbers
        score dw ?
        endrow db ?
        endcol db ?
        game_msg db 'S N A K E',eos
        ask_msg db 'Instructions?',eos
        skor_msg db 'Score:',eos
        instruct label byte
db '                S N A K E     (P) 1988 by John L. Dalton',cr,lf,lf
db     'Maneuver your snake with the arrow keys located on the numeric keypad.'
db cr,lf,'Try to eat as much food as possible without running into the walls'
db cr,lf,'or yourself.  Every morsel you eat will cause you to grow bigger.'
db cr,lf,'The point value for food as well as the speed increases as you play.'
db cr,lf,'Press escape after playing to return to DOS.'
db cr,lf,lf,'                  ---Hit any letter to begin---'
db eos
        position dw MAXLEN dup(?)
        head equ position+2
        tmp db ?

DATA    ends
; . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

CODE    segment

program proc far
        assume cs:code, ds:data, ss:stack
prg:    push ds                 ; allow return to DOS
        mov ax,0
        push ax

        mov ax,data             ; set up DS for data segment
        mov ds,ax


start:  call init       ; draw screen,init vars,put food
main:   call peek       ; look at what head will hit (AL=screen data)
        cmp al,air
        je move
        cmp al,food
        jne endgame     ; anything besides food/air = death!
        call eat_it

move:   call move_snake ; move snake one space according to direction
        call get_input  ; get user input to change direction
        jc excape
        mov dx,speed
        call delay
        jmp main

endgame:mov tmp,255
        mov cx,0303h
        mov bl,wall
flash:  call random
        and al,1111b
        mov bh,al
        call outline
        dec tmp
        jne flash
        mov ax,0C01h    ; clear kb buff and get key
        int dosfunct
        cmp al,27       ; escape
        jne start
excape: clrscr
        set_cursor 3,0,on
        ret
program endp
;-----------
;       S U B R O U T I N E S
;
init proc near
        clrscr
        set_cursor 0,0,off      ; home the cursor, shut it off

; determine which screen to use
        assume es:nothing
        mov cx,0B800h           ; assume colour
        mov ah,15               ; read video mode (mono=7)
        int 10h
        cmp al,7
        jne usecga
        sub cx,800h
usecga: mov es,cx

; init vars
        mov ah,0                ; read timer (DX = low word)
        int clock
        mov seed,dx             ; set random seed value to clock
        mov dir,0               ; snake starts off stationary
        mov syze,1              ; snake starts off as just a head
        mov speed,37            ; initialize speed (fairly slow)
        mov score,0

        set_cursor 12,35
        print game_msg          ; ' S N A K E'

        mov bh,al
effect: mov cx,0B0Bh            ; title display mode
        mov bl,wall
        stc                     ; set carry to have multiple colors
        call border             ; flashing colours effect
        mov dx,40
        call delay
        call keypressed         ; until key is pressed
        jz effect

        set_cursor 12,33        ; ask if want instructions
        print ask_msg
        mov ah,1
        int dosfunct
        or al,32
        cmp al,'y'
        pushf                   ; save user's answer

        mov cx,0C0Ch            ; erase entire screen outline by outline
        mov bh,15
open1:  mov bl,air
        call outline
        mov dx,13
        call delay
        dec cl
        dec ch
        jns open1

        popf                    ; did they want instructions?
        jne play
        set_cursor 0,0          ; yes, print 'em out
        print instruct
        wait_key                ;      and wait for a key
        clrscr

                                ; draw playing screen border
play:   mov cx,0303h
        mov bh,04               ; red,magenta,brown,grey
        mov bl,wall
        stc
        call border
        mov cx,0C0Ch            ; put line in middle
        mov bl,wall
        mov bh,3                ; cyan
        call outline

        call rnd_pos            ; AX = 0..3998 even #
        mov head,ax             ; position snake at random spot
        call move_snake         ; since dir=0, this draws head at its position
        mov cx,5                ; cx = number of foods to start with
        call put_food
        set_cursor 24,34        ; print the word "score" at bottom of screen
        print skor_msg
        call report_score       ; prints the value of current score
        ret
init endp
;--------
keypressed proc near    ; returns Z if no key, NZ if key pressed
        mov ah,1        ; keypressed?
        int keybd
        jz out1         ; no, return with ZF=1
        pushf
        mov ah,0        ; yes, read it and return with ZF=0
        int keybd       ; returns AL=ascii char
        popf
out1:   ret
keypressed endp
;--------------
clear_scr proc near             ; clear screen (affects AX,BH,CX,DX)
        mov cx,0000             ; 0,0 = top left corner
        mov dx,184Fh            ; 18h,4Fh = 24,79 = bot right corner
        mov ax,0600h            ; set clear screen function
        mov bh,100b             ; fill color memory with red
        int video
        ret
clear_scr endp
;-------------
border proc near  ; send CX = start row,col   BX = attrib,char
                  ; draws border on screen of same colour (if carry clr)
                  ;                           diff colors (if carry set)

        pushf                   ; save flags word
bo1:    call outline
        pop ax                  ; get contents of flags in AX
        push ax                 ; and put back on stack
        and ax,1b               ; clear all bits except carry flag bit
        add bh,al               ; change colour only if carry was set
        and bh,0fh              ; make sure we don't touch backgd color
        dec cl
        dec ch                  ; move outward toward edge of screen
        jns bo1                 ; repeat until we go past outer edge
        popf                    ; returns original flags word
        ret
border endp
;----------
outline proc near ; send CH=start row, CL=start col, BL = char, BH=attrib
                  ; draws rectangle where (CH,CL) is top left corner

        mov word ptr endrow,4F18h       ; assume end row,col = (24,79)
        sub endrow,ch                   ; adjust according to start row,col
        sub endcol,cl
        mov dl,cl               ; for DL = begcol to endcol do ##############
loop1:  mov dh,ch               ;       row = beg_row
        call plot               ;       plot (row,DL)
        mov dh,endrow           ;       row = end_row
        call plot               ;       plot (row,DL)
        inc dl                  ; next DL                      ##############
        cmp dl,endcol
        jbe loop1

        mov dh,ch               ; for DH = begrow to endrow do #            #
loop2:  mov dl,cl               ;       col = begcol           #            #
        call plot               ;       plot (DH,col)          #            #
        mov dl,endcol           ;       col = endcol           #            #
        call plot               ;       plot (DH,col)          #            #
        inc dh                  ; next DH                      #            #
        cmp dh,endrow
        jbe loop2
        ret
outline endp
;----------
plot proc near                  ; send DH=row,DL=col,BL=char,BH=attribute
        push dx
        mov al,160
        mul dh                  ; AX = AL*DH
        mov si,ax               ; SI = row*160.....
        mov dh,0
        shl dl,1
        add si,dx               ; .....+ col*2
        mov es:[si],bl          ; plot given character
        mov es:[si+1],bh        ; ...with given attribute
        pop dx
        ret
plot endp
;--------
random proc near        ; returns AX = random word
        push bx
        mov ax,seed
        mov bx,25173
        mul bx
        add ax,13849
        mov seed,ax
        pop bx
        ret
random endp
;----------
rnd_pos proc near       ; returns AX = random "free" position
                        ; i.e.  AX = even # 0..3998 pointing to air
        call random
        and ax,4094     ; put ax in range and make it even
        cmp ax,3998
        jae rnd_pos
        mov bx,ax
        cmp byte ptr es:[bx],air
        jne rnd_pos
        ret
rnd_pos endp
;-----------
put_food proc near          ; send CX = number of foods to put
        call rnd_pos                    ; pick random location for food
        mov bx,ax
        mov byte ptr es:[bx],food       ; draw food on screen
        call random                     ; pick random number for color
        and al,1111b
        or al,100b          ; possible colors: red,magenta,brown,lt grey
                            ;                  lt red,lt mag,yellow,white
        mov byte ptr es:[bx+1],al       ; color the food
        loop put_food                   ; repeat until we put all foods
        ret
put_food endp
;--------
eat_it proc near          ; called when snake collides with food

        mov ax,syze       ; score for eating food:  whatever current size is
        add score,ax
        call report_score

        test syze,111b    ; every time size is multiple of 8, make snake faster
        jnz same_speed
        cmp speed,10
        jbe same_speed    ; ...unless speed is 10 (maximum speed)
        sub speed,3
same_speed:
        cmp syze,MAXLEN   ; is snake at fully mature size?
        jbe grow          ; once snake reaches maxlen, it sheds its body
        mov syze,0        ; ...and becomes just a head (as at start of game)

grow:   inc syze          ; eating food causes snake to increase in size by 1
        mov cx,1          ; put another food on screen to replace eaten one
        call put_food
        ret
eat_it endp
;----------
peek proc near          ; send DIR, returns AL = what snake will run into next
                        ; also sets BX=location of next head position

        mov bx,head             ; get current head position
        add bx,dir              ; add direction value
        mov al,es:[bx]          ; see whats at new head position
        cmp dir,0               ; if dir=0 then not moving
        jne out2
        mov al,air              ; ...therefore, return null (i.e. air)
out2:   ret
peek endp
;--------
move_snake proc near    ; moves snake one space according to its direction

; *** first, erase tail
        mov si,syze                       ; get pointer to tail
        shl si,1
        mov bx,position[si]               ; get screen loc. of tail
        mov byte ptr es:[bx],air          ; put "air" at the loc.
        mov byte ptr es:[bx+1],111b       ; set color to normal white on black

; *** then, shift body segments forward
        call move_body                    ; shift body segments

; *** finally, draw head at new postion
        call peek                         ; get loc of new head (BX)
        mov byte ptr es:[bx],body         ; draw snake head
        mov byte ptr es:[bx+1],sncolor    ; color snake
        mov head,bx                       ; save new head position
        ret

move_body:      ;for c = SIZE downto 1 do
                ;   position(c) := position(c-1);

        mov ax,position[si]
        mov position[si+2],ax
        dec si
        dec si
        jnz move_body
        ret
move_snake endp
;--------------
get_input proc near     ; allows user to alter snakes direction using
                        ; numeric keypad

        call keypressed ; see if key has been pressed
        jz keepsame     ; no, keep same direction
                        ; yes, AL=ascii, AH=scan
        cmp al,27       ; escape
        stc             ; set carry to denote user wants to exit program
        je getout
        cmp ah,71       ; key pad #7 (top left = northwest)
        jb keepsame
        cmp ah,81       ; key pad #3 (bot rite = southeast)
        ja keepsame
        sub ah,71
        mov bl,ah       ; sets bl = 0..10
        shl bl,1        ; sets bl = even 0..20
        mov bh,0
        mov ax,new_dir[bx] ; get new direction corresponding to key pressed
        cmp ax,0        ; if ax=0 then non-direction-key pressed
        je keepsame     ; therefore, don't set direction to zero
                        ;  but rather keep old direction (i.e don't allow
                        ;  user to stop snake!
        mov dir,ax
keepsame:clc            ; clear carry (since user didnt type esc to stop)
getout: ret
get_input endp
;-------------
delay proc near                 ; send DX=0(fast)..60(slow)
                        ; NOTE : should use clock chip for delays!
        push cx
        push dx
        mov ax,dir
        add ax,2                ; if not a horizontal dir then
                                ; ax will be greater than 4
        cmp ax,4
        jbe d0
        mov cx,dx
        shr cx,1                ; vertical dir is 3/2 slower
        add dx,cx

d0:     mov ax,1000
        mul dx                  ; AX = 1000*(DX)
        mov cx,ax
d1:     loop d1                 ; delay loop
        pop dx
        pop cx
        ret
delay endp
;---------
report_score proc near
        mov si,10
        mov ax,score
rsloop: mov dx,0
        mov bx,10
        div bx          ; ax = quot, dx = rmdr
        add dl,'0'
        mov es:[3920+si],dl
        mov byte ptr es:[3920+si+1],1111b ; white
        mov byte ptr es:[3908+si+1],1111b
        sub si,2
        jns rsloop
        ret
report_score endp
;----------------

CODE    ends                    ;end of code segment
        end prg                 ;end of program