.model large
.stack 1000h

SCREEN_WIDTH = 320  
SCREEN_HEIGHT = 200

SMALL_BMP_HEIGHT = 40
SMALL_BMP_WIDTH = 40

NULL = -1

MAZE_FILE_IN equ 'maze.bmp'
PLAYER_FILE_IN equ 'player2.bmp'
PAFILE_NAME_IN equ 'pause.bmp'

; Todos:
; make pacman move alone unless it detects collision then movement stops
; the arrows will control pacman's direction

; For this we need a function that increase row left or right or column up or down
; depends on the direction as well


.data
    ScrLine db SCREEN_WIDTH dup (0)  ; One Color line read buffer

    FileHandle dw ?
    Header db 54 dup(0)
    Palette db 400h dup (0)
    
    ;BmpFileErrorMsg db 'Error At Opening Bmp File ', P1FILE_NAME_IN, 0dh, 0ah, '$'
    ErrorFile db 0
    BB db "BB..", '$'
    
    Image db 40*40 dup(0) 
    Color db ?
    Xclick dw ?
    Yclick dw ?
    Xp dw ?
    Yp dw ?
    SquareSize dw ?
     
    BmpLeft dw ?
    BmpTop dw ?
    BmpWidth dw ?
    BmpHeight dw ?
    
    player_x_pos dw 100
    player_y_pos dw 100
	MazeFileName db MAZE_FILE_IN, 0
	PlayerFileName db PLAYER_FILE_IN, 0
	PAFileName db PAFILE_NAME_IN, 0
	MazeData db 31*28 dup(1)       ; Collision data (31 rows, 28 columns)
	
	up dw 1
	down dw 1
	left dw 1
	right dw 1
	current_direction db 0  ; 0=stopped, 1=up, 2=down, 3=left, 4=right

	BackgroundBuffer db 14*14 dup(0)  ; Buffer to store background pixels (16x16)

.code

OpenShowBmp proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di  
    
    mov [ErrorFile], 0
    call OpenBmpFile
    cmp [ErrorFile], 1
    je @@ExitProc1
    
    call ReadBmpHeader
    call ReadBmpPalette
    call CopyBmpPalette
    call ShowBMP
    call CloseBmpFile

@@ExitProc1:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
OpenShowBmp endp

OpenBmpFile proc near
    mov ah, 3Dh
    xor al, al
    int 21h
    jc @@ErrorAtOpen
    mov [FileHandle], ax
    jmp @@ExitProc2
    
@@ErrorAtOpen:
    mov [ErrorFile], 1
@@ExitProc2:
    ret
OpenBmpFile endp

CloseBmpFile proc near
    mov ah, 3Eh
    mov bx, [FileHandle]
    int 21h
    ret
CloseBmpFile endp

ReadBmpHeader proc near
    push cx
    push dx
    
    mov ah, 3Fh
    mov bx, [FileHandle]
    mov cx, 54
    mov dx, offset Header
    int 21h
    
    pop dx
    pop cx
    ret
ReadBmpHeader endp

ReadBmpPalette proc near
    push cx
    push dx
    
    mov ah, 3Fh
    mov bx, [FileHandle]
    mov cx, 400h
    mov dx, offset Palette
    int 21h
    
    pop dx
    pop cx
    ret
ReadBmpPalette endp

CopyBmpPalette proc near
    push cx
    push dx
    
    mov si, offset Palette
    mov cx, 256
    mov dx, 3C8h
    mov al, 0
    out dx, al
    inc dx
    
CopyNextColor:
    mov al, [si+2]
    shr al, 2
    out dx, al
    mov al, [si+1]
    shr al, 2
    out dx, al
    mov al, [si]
    shr al, 2
    out dx, al
    add si, 4
    loop CopyNextColor
    
    pop dx
    pop cx
    ret
CopyBmpPalette endp

SetGraphic proc near
    mov ax, 13h
    int 10h
    ret
SetGraphic endp

ShowBMP proc near
    push cx
    
    mov ax, 0A000h
    mov es, ax
    
    mov ax, [BmpWidth]
    mov bp, 0
    and ax, 3
    jz @@row_ok
    mov bp, 4
    sub bp, ax
    
@@row_ok:
    mov cx, [BmpHeight]
    dec cx
    add cx, [BmpTop]
    mov di, cx
    shl cx, 6
    shl di, 8
    add di, cx
    add di, [BmpLeft]
    cld
    
    mov cx, [BmpHeight]
@@NextLine:
    push cx
    
    mov ah, 3Fh
    mov bx, [FileHandle]
    mov cx, [BmpWidth]
    add cx, bp
    mov dx, offset ScrLine
    int 21h
    
    mov cx, [BmpWidth]
    mov si, offset ScrLine
    rep movsb
    
    sub di, [BmpWidth]
    sub di, SCREEN_WIDTH
    
    pop cx
    loop @@NextLine
    
    pop cx
    ret
ShowBMP endp

draw_maze proc near
    push ax
    push bx
    push dx
    
    mov dx, offset MazeFileName 
    mov ax, 0     
    mov [BmpLeft], ax
    mov ax, 0      
    mov [BmpTop], ax
    mov [BmpWidth],  320   ; Set width
    mov [BmpHeight], 200    ; Set height
    
    call OpenShowBmp         
    
    pop dx
    pop bx
    pop ax
    ret
draw_maze endp

draw_player proc near
	push ax
	push bx
	push dx
	
	mov dx, offset PlayerFileName
	mov ax, [player_x_pos]
	mov [BmpLeft], ax
	mov ax, [player_y_pos]
	mov [BmpTop], ax
    mov [BmpWidth],  14   ; Set width
    mov [BmpHeight], 14    ; Set height
    call OpenShowBmp         
    
    pop dx
    pop bx
    pop ax
    ret

draw_player endp

draw_pause_menu proc near
    push ax
    push bx
    push dx
    
    mov dx, offset PAFileName  
    mov ax, 0       ; Use dynamic X position
    mov [BmpLeft], ax
    mov ax, 0       
    mov [BmpTop], ax
    mov [BmpWidth],  320   ; Set width
    mov [BmpHeight], 200    ; Set height
    
    call OpenShowBmp       
    
    pop dx
    pop bx
    pop ax
    ret
draw_pause_menu endp



check_input proc near
    mov ah, 1
    int 16h
    jnz key_available   ; If key IS available, jump to handle it
    
    ; No key pressed, so continue moving in current direction
    jmp continue_movement
    
key_available:
    ; Get the key
    mov ah, 0
    int 16h
        
    cmp ah, 48h   ; Up arrow scan code
    je set_dir_up
    cmp ah, 50h   ; Down arrow scan code
    je set_dir_down
    cmp ah, 4Bh   ; Left arrow scan code
    je set_dir_left
    cmp ah, 4Dh   ; Right arrow scan code
    je set_dir_right
    
    ; Check for ESC key to exit (scan code 01h)
    cmp ah, 01h
    jne not_exit
    
    ; It's ESC, so set exit flag and return
    mov ax, 1
    ret
    
not_exit:
    jmp continue_movement  ; Not a recognized key, continue with movement

set_dir_up:
    mov [current_direction], 1
    jmp continue_movement

set_dir_down:
    mov [current_direction], 2
    jmp continue_movement

set_dir_left:
    mov [current_direction], 3
    jmp continue_movement

set_dir_right:
    mov [current_direction], 4
    jmp continue_movement

continue_movement:
    ; Move based on current direction
    mov al, [current_direction]
    cmp al, 0
    je no_key  ; If direction is 0, don't move
    
    ; Move 2 steps in the current direction
    mov cx, 1
    
auto_move_loop:
    push cx
	
    cmp al, 1
    je auto_move_up
    cmp al, 2
    je auto_move_down
    cmp al, 3
    je auto_move_left
    cmp al, 4
    je auto_move_right
    jmp auto_move_done
    
auto_move_up:
    mov ax, [player_y_pos]
    sub ax, [up]
    mov [player_y_pos], ax
    jmp auto_move_done
    
auto_move_down:
    mov ax, [player_y_pos]
    add ax, [down]
    mov [player_y_pos], ax
    jmp auto_move_done
    
auto_move_left:
    mov ax, [player_x_pos]
    sub ax, [left]
    mov [player_x_pos], ax
    jmp auto_move_done
    
auto_move_right:
    mov ax, [player_x_pos]
    add ax, [right]
    mov [player_x_pos], ax
    
auto_move_done:
    pop cx
    mov al, [current_direction]  ; Reload direction
    loop auto_move_loop

 
no_key:
    ; Clear the exit flag
    xor ax, ax    ; Clear AX
    ret
check_input endp


clear_bmp_area proc near
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    ; Set video memory segment
    mov ax, 0A000h
    mov es, ax

    ; Calculate memory location (y_pos * SCREEN_WIDTH + x_pos)
    mov ax, [BmpTop]
    mov bx, SCREEN_WIDTH
    mul bx
    add ax, [BmpLeft]
    mov di, ax

    ; Ensure the width does not exceed screen limits
    mov ax, [BmpLeft]
    add ax, [BmpWidth]
    cmp ax, SCREEN_WIDTH
    jle @width_ok
    mov ax, SCREEN_WIDTH
    sub ax, [BmpLeft]
    mov [BmpWidth], ax
@width_ok:

    ; Ensure the height does not exceed screen limits
    mov ax, [BmpTop]
    add ax, [BmpHeight]
    cmp ax, SCREEN_HEIGHT
    jle @height_ok
    mov ax, SCREEN_HEIGHT
    sub ax, [BmpTop]
    mov [BmpHeight], ax
@height_ok:

    ; Clear the area with color index 0 (black in Pacman maze)
    ; or whatever color your maze background uses
    mov cx, [BmpHeight]  ; Number of rows
    mov dx, [BmpWidth]   ; Row width

@clear_rows:
    push cx
    push di

    mov cx, dx    ; Number of pixels to clear
    mov al, 0     ; Black color (adjust if your maze uses different background)
    rep stosb     ; Store AL into ES:[DI]

    pop di
    add di, SCREEN_WIDTH  ; Move to next row
    pop cx
    loop @clear_rows

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
clear_bmp_area endp


clear_player proc near
    ; Clear the player's previous position
    mov ax, [player_x_pos]
    mov [BmpLeft], ax
    mov ax, [player_y_pos]
    mov [BmpTop], ax
    mov [BmpWidth], 16
    mov [BmpHeight], 16
    call clear_bmp_area
    ret
clear_player endp


vsync proc near
    push ax
    push dx
    
    mov dx, 03DAh        ; VGA status port
    
@@wait_retrace1:
    in al, dx
    test al, 08h         ; Check if retrace is happening
    jnz @@wait_retrace1  ; Wait for retrace to end
    
@@wait_retrace2:
    in al, dx
    test al, 08h         ; Wait for next retrace to start
    jz @@wait_retrace2
    
    pop dx
    pop ax
    ret
vsync endp



start:
    mov ax, @data
    mov ds, ax
    
    call SetGraphic
    call draw_maze     ; Draw maze first
    call draw_player   ; Then draw player

game_loop:
    ; Clear player's old position by redrawing the maze at that position
    call clear_player
    
    ; Store old position in case we need to restore it
    push [player_x_pos]
    push [player_y_pos]
    
    ; Check for input and update player position
    call check_input
    
    ; Check if ESC was pressed (returns non-zero in AX)
    cmp ax, 0
    jnz exit_game
    
    ; Draw player at new position
    call draw_player
    
    ; Add delay for game speed
    mov cx, 1
delay_loop:
    push cx
    mov cx, 5000  ; Adjust for speed (reduced from 10000)
inner_delay:
    loop inner_delay
    pop cx
    loop delay_loop
    
    ; Call vsync for smoother animation
    call vsync
    
    jmp game_loop
    
exit_game:
    mov ax, 3     ; Text mode
    int 10h
    mov ax, 4c00h ; Exit to DOS
    int 21h	
	
	
END start