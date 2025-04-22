.model large
.stack 1000h


SMALL_BMP_HEIGHT = 40
SMALL_BMP_WIDTH = 40

NULL = -1

PLAYER_FILE_IN equ 'player3.bmp'
PAFILE_NAME_IN equ 'pause.bmp'

SCREEN_WIDTH equ 320  
SCREEN_HEIGHT equ 200

; Define colors
BLACK equ 0
BLUE equ 1
WHITE equ 15
YELLOW equ 14
RED equ 4

.data
    ; Define Pac-Man maze as a 2D array (1=wall, 0=empty)
    maze_map db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
            db 0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0
            db 0,1,0,1,1,0,1,1,1,0,1,0,1,1,1,0,1,1,0,1,0
            db 0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
            db 0,1,0,1,1,0,1,0,1,1,1,1,1,0,1,0,1,1,0,1,0
            db 0,1,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,1,0
            db 0,1,1,1,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1,0
            db 0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0
            db 1,1,1,1,1,0,1,0,1,1,0,1,1,0,1,0,1,1,1,1,1
            db 0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0
            db 1,1,1,1,1,0,1,0,1,1,1,1,1,0,1,0,1,1,1,1,1
            db 0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0
            db 0,1,1,1,1,0,1,0,1,1,1,1,1,0,1,0,1,1,1,1,0
            db 0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0
            db 0,1,0,1,1,0,1,1,1,0,1,0,1,1,1,0,1,1,0,1,0
            db 0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0
            db 0,1,1,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,1,0
            db 0,1,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,1,0
            db 0,1,0,1,1,1,1,1,1,0,1,0,1,1,1,1,1,1,0,1,0
            db 0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
            db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0

    maze_width db 21     ; Width of the maze in cells
    maze_height db 21    ; Height of the maze in cells
    cell_width dw 18     ; Width of each cell - increased from 16
    cell_height dw 13     ; Height of each cell - increased from 11

    x_pos dw 0           ; Current X position for drawing
    y_pos dw 0           ; Current Y position for drawing
    colorMaze db BLUE        ; Color to draw (blue for walls)
	
	ScrLine db SCREEN_WIDTH dup (0)  ; One Color line read buffer

    FileHandle dw ?
    Header db 54 dup(0)
    Palette db 400h dup (0)
    
    ;BmpFileErrorMsg db 'Error At Opening Bmp File ', P1FILE_NAME_IN, 0dh, 0ah, '$'
    ErrorFile db 0
    BB db "BB..", '$'
    
    Image db 40*40 dup(0) 
    Xclick dw ?
    Yclick dw ?
    Xp dw ?
    Yp dw ?
    SquareSize dw ?
     
    BmpLeft dw ?
    BmpTop dw ?
    BmpWidth dw ?
    BmpHeight dw ?
    
    player_x_pos dw 120
    player_y_pos dw 100
	PlayerFileName db PLAYER_FILE_IN, 0
	PAFileName db PAFILE_NAME_IN, 0
	
	up dw 1
	down dw 1
	left dw 1
	right dw 1
	current_direction db 0  ; 0=stopped, 1=up, 2=down, 3=left, 4=right

	player_bg_buffer db 12*12 dup (0)  ; Buffer for player background (adjust size as needed)

    ; Add these new variables to your data section
    wall_corner_radius dw 2     ; Radius for rounded corners
    
    ; Define the offset for wall drawing within cells (to create wider passages)
    wall_inset_x dw 2           ; Horizontal inset from cell edge
    wall_inset_y dw 1           ; Vertical inset from cell edge
    
    ; Set proper dimensions for walls
    wall_width dw 12            ; Just a bit less than full cell width
    wall_height dw 8            ; Just a bit less than full cell height
    
    ; Path width tolerance - increase this for easier navigation
    path_tolerance dw 2         ; Additional clearance for path detection
    
    ; Player hitbox - reduce for easier navigation through tight spaces
    player_hitbox_width dw 9    ; Smaller than visible sprite
    player_hitbox_height dw 9   ; Smaller than visible sprite


.code

;-----------------------------------------------------
; SetGraphic - Set video mode to 13h (320x200, 256 colors)
;-----------------------------------------------------
SetGraphic proc near
    mov ax, 13h
    int 10h
    ret
SetGraphic endp

;-----------------------------------------------------
; ExitGraphic - Return to text mode
;-----------------------------------------------------
ExitGraphic proc near
    mov ax, 3
    int 10h
    ret
ExitGraphic endp

;-----------------------------------------------------
; Draw a rectangle at (x_pos, y_pos) with color
;-----------------------------------------------------
draw_rect proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Get parameters for drawing
    mov cx, x_pos          ; Starting X position
    mov dx, y_pos          ; Starting Y position
    
    ; Add inset to create spacing between walls
    add cx, [wall_inset_x] ; Add horizontal inset
    add dx, [wall_inset_y] ; Add vertical inset
    
    mov si, [wall_height]  ; Height (Y) counter
    
rect_row_loop:
    push cx                ; Save starting X
    mov di, [wall_width]   ; Width (X) counter
    
rect_col_loop:
    ; Determine if we need to apply corner rounding
    ; Check if we're in a corner region
    push cx
    push dx
    
    ; Calculate position relative to rectangle start
    mov ax, cx
    sub ax, x_pos
    sub ax, [wall_inset_x]  ; Adjust for inset
    
    mov bx, dx
    sub bx, y_pos
    sub bx, [wall_inset_y]  ; Adjust for inset
    
    ; Check for top-left corner
    cmp ax, [wall_corner_radius]
    jg not_top_left_x
    cmp bx, [wall_corner_radius]
    jg not_top_left_y
    
    ; We're in the top-left corner region, check if we should draw
    ; (x^2 + y^2 <= r^2)
    push ax
    push bx
    
    ; Calculate x^2
    mul ax                 ; AX = x^2
    mov si, ax             ; Save x^2 in SI
    
    ; Calculate y^2
    mov ax, bx
    mul ax                 ; AX = y^2
    
    ; Calculate x^2 + y^2
    add ax, si             ; AX = x^2 + y^2
    
    ; Calculate r^2
    mov bx, [wall_corner_radius]
    mul bx                 ; BX*BX = r^2
    
    ; Compare
    cmp ax, bx
    pop bx
    pop ax
    jg skip_pixel          ; If x^2 + y^2 > r^2, outside the radius
    jmp draw_normal_pixel
    
not_top_left_x:
not_top_left_y:

    ; Additional corner checks for other corners would go here
    ; For simplicity in this example, we'll just check top-left
    ; Similar code would be needed for all four corners
    
draw_normal_pixel:
    ; Draw regular blue
    mov al, BLUE
    
    ; Draw pixel using INT 10h
    mov ah, 0Ch            ; Function 0Ch - Write pixel
    int 10h
    
    pop dx
    pop cx
    jmp continue_pixel

skip_pixel:
    pop dx
    pop cx
    ; Skip drawing this pixel (rounded corner area)
    
continue_pixel:
    ; Move to next X position
    inc cx
    dec di
    jnz rect_col_loop
    
    ; Move to next row
    pop cx                 ; Restore starting X
    inc dx
    dec si
    jnz rect_row_loop
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_rect endp


;-----------------------------------------------------
; DrawMaze - Draw the maze from the maze_map array
;-----------------------------------------------------
DrawMaze proc near
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Calculate horizontal and vertical offsets to center the maze
    ; Total maze width = 21 cells * 14 pixels = 294 pixels
    ; Total maze height = 21 cells * 9 pixels = 189 pixels
    ; X offset = (320 - 294) / 2 = 13
    ; Y offset = (200 - 189) / 2 = 5
    
    mov word ptr [x_pos], 13    ; Center horizontally
    mov word ptr [y_pos], 5     ; Center vertically
    
    ; Loop through maze rows
    xor bx, bx                  ; BX = row counter
    
draw_maze_row:
    ; Reset X position for this row
    mov word ptr [x_pos], 13
    
    ; Loop through maze columns
    xor cx, cx                  ; CX = column counter
    
draw_maze_col:
    ; Calculate offset in maze_map: row * width + column
    mov ax, bx                  ; AX = row
    xor ah, ah
    mov si, ax                  ; Save row in SI
    mov al, [maze_width]        ; AL = width
    mul si                      ; AX = row * width
    add ax, cx                  ; AX = row * width + column
    
    ; Get the maze value at this position
    mov si, offset maze_map
    add si, ax
    mov al, [si]                ; AL = maze value (0 or 1)
    
    ; Check if it's a wall (1)
    cmp al, 1
    jne skip_wall
    
    ; Draw a blue wall rectangle - now smaller than cell size
    mov byte ptr [colorMaze], BLUE
    call draw_rect
    
skip_wall:
    ; Move to next column
    add word ptr [x_pos], 14    ; Move right by cell width
    
    ; Next column
    inc cx
    mov al, [maze_width]
    cmp cl, al
    jl draw_maze_col
    
    ; Move to next row
    add word ptr [y_pos], 9    ; Move down by cell height
    
    ; Next row
    inc bx
    mov al, [maze_height]
    cmp bl, al
    jl draw_maze_row
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DrawMaze endp



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
    ; Check if this is color index 1 (BLUE)
    push cx
    mov ax, 256
    sub ax, cx
    cmp ax, 1         ; Is this color index 1?
    pop cx
    jne NotBlueIndex
    
    ; Special handling for color 1 (BLUE)
    mov al, 0         ; Red component (0 for blue)
    out dx, al
    mov al, 0         ; Green component (0 for blue)
    out dx, al
    mov al, 63        ; Blue component (maximum)
    out dx, al
    add si, 4         ; Skip this color in palette data
    jmp NextColor
    
NotBlueIndex:
    ; Regular color copying
    mov al, [si+2]    ; Blue component from BMP
    shr al, 2
    out dx, al
    mov al, [si+1]    ; Green component
    shr al, 2
    out dx, al
    mov al, [si]      ; Red component
    shr al, 2
    out dx, al
    add si, 4
    
NextColor:
    loop CopyNextColor
    
    pop dx
    pop cx
    ret
CopyBmpPalette endp


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



; XOR-based player drawing
draw_player_xor proc near
    push ax
    push bx
    
    ; Make sure we're not drawing outside the screen boundary
    mov ax, [player_x_pos]
    cmp ax, 5                ; Minimum X to avoid border issues
    jl @@adjust_x_min
    cmp ax, 302              ; Maximum X (320 - 12 - 6)
    jg @@adjust_x_max
    jmp @@x_ok
    
@@adjust_x_min:
    mov ax, 5
    mov [player_x_pos], ax
    jmp @@x_ok
    
@@adjust_x_max:
    mov ax, 302
    mov [player_x_pos], ax
    
@@x_ok:
    mov ax, [player_y_pos]
    cmp ax, 5                ; Minimum Y to avoid border issues
    jl @@adjust_y_min
    cmp ax, 183              ; Maximum Y (200 - 12 - 5)
    jg @@adjust_y_max
    jmp @@y_ok
    
@@adjust_y_min:
    mov ax, 5
    mov [player_y_pos], ax
    jmp @@y_ok
    
@@adjust_y_max:
    mov ax, 183
    mov [player_y_pos], ax
    
@@y_ok:
    ; Continue with normal drawing
    mov dx, offset PlayerFileName
    mov ax, [player_x_pos]
    mov [BmpLeft], ax
    mov ax, [player_y_pos]
    mov [BmpTop], ax
    mov [BmpWidth], 12    ; Player width
    mov [BmpHeight], 12   ; Player height
    call OpenShowBmpXor    ; Use XOR version
    
    pop bx
    pop ax
    ret
draw_player_xor endp



ShowBMPXor proc near
    push cx
    
    mov ax, 0A000h
    mov es, ax
    
    mov ax, [BmpWidth]
    mov bp, 0
    and ax, 3
    jz @@row_ok2
    mov bp, 4
    sub bp, ax
    
@@row_ok2:
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
@@NextLine2:
    push cx
    
    mov ah, 3Fh
    mov bx, [FileHandle]
    mov cx, [BmpWidth]
    add cx, bp
    mov dx, offset ScrLine
    int 21h
    
    mov cx, [BmpWidth]
    mov si, offset ScrLine
@@NextPixel:
    lodsb                  ; Load pixel color into AL
    
    ; Skip black pixels (assuming black is background)
    cmp al, 0              ; Is this black?
    je @@SkipPixel
    
    ; XOR with the screen pixel
    mov ah, es:[di]        ; Get current screen pixel
    xor ah, al             ; XOR with BMP pixel
    mov es:[di], ah        ; Store result
    
@@SkipPixel:
    inc di                 ; Move to next screen position
    loop @@NextPixel       ; Continue for all pixels in row
    
    sub di, [BmpWidth]
    sub di, SCREEN_WIDTH
    
    pop cx
    loop @@NextLine2
    
    pop cx
    ret
ShowBMPXor endp

OpenShowBmpXor proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di  
    
    mov [ErrorFile], 0
    call OpenBmpFile
    cmp [ErrorFile], 1
    je @@ExitProc3
    
    call ReadBmpHeader
    call ReadBmpPalette
    call CopyBmpPalette
    call ShowBMPXor      ; Use XOR version instead of normal ShowBMP
    call CloseBmpFile

@@ExitProc3:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
OpenShowBmpXor endp


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
    
    ; No key pressed, continue in current direction
    jmp continue_movement
    
key_available:
    ; Get the key
    mov ah, 0
    int 16h
        
    cmp ah, 48h   ; Up arrow scan code
    je try_dir_up
    cmp ah, 50h   ; Down arrow scan code
    je try_dir_down
    cmp ah, 4Bh   ; Left arrow scan code
    je try_dir_left
    cmp ah, 4Dh   ; Right arrow scan code
    je try_dir_right
    
    ; Check for ESC key to exit (scan code 01h)
    cmp ah, 01h
    jne not_exit
    
    ; It's ESC, so set exit flag and return
    mov ax, 1
    ret
    
not_exit:
    jmp continue_movement  ; Not a recognized key, continue

try_dir_up:
    mov al, 1              ; Direction = up
    call check_player_move
    cmp cl, 1              ; Can move?
    jne continue_movement  ; If not, skip
    mov [current_direction], 1
    jmp continue_movement

try_dir_down:
    mov al, 2              ; Direction = down
    call check_player_move
    cmp cl, 1              ; Can move?
    jne continue_movement  ; If not, skip
    mov [current_direction], 2
    jmp continue_movement

try_dir_left:
    mov al, 3              ; Direction = left
    call check_player_move
    cmp cl, 1              ; Can move?
    jne continue_movement  ; If not, skip
    mov [current_direction], 3
    jmp continue_movement

try_dir_right:
    mov al, 4              ; Direction = right
    call check_player_move
    cmp cl, 1              ; Can move?
    jne continue_movement  ; If not, skip
    mov [current_direction], 4
    jmp continue_movement

continue_movement:
    ; Check if current direction is valid before moving
    mov al, [current_direction]
    cmp al, 0
    je no_key  ; If direction is 0, don't move
    
    ; Check if we can move in the current direction
    call check_player_move
    cmp cl, 1
    jne stop_movement  ; If can't move, stop
    
    ; Move in the current direction
    cmp al, 1
    je auto_move_up
    cmp al, 2
    je auto_move_down
    cmp al, 3
    je auto_move_left
    cmp al, 4
    je auto_move_right
    jmp no_key
    
auto_move_up:
    mov ax, [player_y_pos]
    sub ax, [up]
    mov [player_y_pos], ax
    jmp no_key
    
auto_move_down:
    mov ax, [player_y_pos]
    add ax, [down]
    mov [player_y_pos], ax
    jmp no_key
    
auto_move_left:
    mov ax, [player_x_pos]
    sub ax, [left]
    mov [player_x_pos], ax
    jmp no_key
    
auto_move_right:
    mov ax, [player_x_pos]
    add ax, [right]
    mov [player_x_pos], ax
    jmp no_key
    
stop_movement:
    mov [current_direction], 0  ; Stop moving
 
no_key:
    ; Clear the exit flag
    xor ax, ax    ; Clear AX
    ret
check_input endp



; Improved check_up_move for better navigation in narrow passages
check_up_move proc near
    push ax
    push bx
    
    ; Use smaller collision points with more space between them
    
    ; Check left side of player's top (inset more)
    mov ax, [player_x_pos]
    add ax, 3               ; Further inset from left
    mov bx, [player_y_pos]
    sub bx, 1               ; Top edge - 1
    call check_wall_collision
    cmp al, 1
    je @@up_blocked
    
    ; Skip the center check to create two distinct collision points
    ; This helps with passing through narrow passages
    
    ; Check right side of player's top (inset more)
    mov ax, [player_x_pos]
    add ax, [player_hitbox_width]
    sub ax, 3               ; Further inset from right
    mov bx, [player_y_pos]
    sub bx, 1               ; Top edge - 1
    call check_wall_collision
    cmp al, 1
    je @@up_blocked
    
    ; No obstacles, can move up
    mov cl, 1               ; Can move
    jmp @@up_exit
    
@@up_blocked:
    mov cl, 0               ; Can't move
    
@@up_exit:
    pop bx
    pop ax
    ret
check_up_move endp

; Improved check_down_move for better navigation
check_down_move proc near
    push ax
    push bx
    
    ; Check left side of player's bottom (inset more)
    mov ax, [player_x_pos]
    add ax, 3               ; Further inset from left
    mov bx, [player_y_pos]
    add bx, [player_hitbox_height]
    call check_wall_collision
    cmp al, 1
    je @@down_blocked
    
    ; Skip the center check for better narrow passage navigation
    
    ; Check right side of player's bottom (inset more)
    mov ax, [player_x_pos]
    add ax, [player_hitbox_width]
    sub ax, 3               ; Further inset from right
    mov bx, [player_y_pos]
    add bx, [player_hitbox_height]
    call check_wall_collision
    cmp al, 1
    je @@down_blocked
    
    ; No obstacles, can move down
    mov cl, 1               ; Can move
    jmp @@down_exit
    
@@down_blocked:
    mov cl, 0               ; Can't move
    
@@down_exit:
    pop bx
    pop ax
    ret
check_down_move endp

; Improved check_left_move for better navigation
check_left_move proc near
    push ax
    push bx
    
    ; Check top of player's left side (inset more)
    mov ax, [player_x_pos]
    sub ax, 1               ; Left edge - 1
    mov bx, [player_y_pos]
    add bx, 3               ; Further inset from top
    call check_wall_collision
    cmp al, 1
    je @@left_blocked
    
    ; Skip the center check for better narrow passage navigation
    
    ; Check bottom of player's left side (inset more)
    mov ax, [player_x_pos]
    sub ax, 1               ; Left edge - 1
    mov bx, [player_y_pos]
    add bx, [player_hitbox_height]
    sub bx, 3               ; Further inset from bottom
    call check_wall_collision
    cmp al, 1
    je @@left_blocked
    
    ; No obstacles, can move left
    mov cl, 1               ; Can move
    jmp @@left_exit
    
@@left_blocked:
    mov cl, 0               ; Can't move
    
@@left_exit:
    pop bx
    pop ax
    ret
check_left_move endp

; Improved check_right_move for better navigation
check_right_move proc near
    push ax
    push bx
    
    ; Check top of player's right side (inset more)
    mov ax, [player_x_pos]
    add ax, [player_hitbox_width]
    mov bx, [player_y_pos]
    add bx, 3               ; Further inset from top
    call check_wall_collision
    cmp al, 1
    je @@right_blocked
    
    ; Skip the center check for better narrow passage navigation
    
    ; Check bottom of player's right side (inset more)
    mov ax, [player_x_pos]
    add ax, [player_hitbox_width]
    mov bx, [player_y_pos]
    add bx, [player_hitbox_height]
    sub bx, 3               ; Further inset from bottom
    call check_wall_collision
    cmp al, 1
    je @@right_blocked
    
    ; No obstacles, can move right
    mov cl, 1               ; Can move
    jmp @@right_exit
    
@@right_blocked:
    mov cl, 0               ; Can't move
    
@@right_exit:
    pop bx
    pop ax
    ret
check_right_move endp

; Main procedure to check player movement in any direction
check_player_move proc near
    push ax
    push bx
    push dx
    
    ; Save direction value
    push ax
    
    ; Adjust position based on direction and check for wall
    cmp al, 1               ; Up
    je check_up_direction
    cmp al, 2               ; Down
    je check_down_direction
    cmp al, 3               ; Left
    je check_left_direction
    cmp al, 4               ; Right
    je check_right_direction
    
    ; Invalid direction
    mov cl, 0               ; Can't move
    jmp finish_check

check_up_direction:
    call check_up_move
    jmp finish_check

check_down_direction:
    call check_down_move
    jmp finish_check

check_left_direction:
    call check_left_move
    jmp finish_check

check_right_direction:
    call check_right_move
    jmp finish_check

finish_check:
    ; Restore direction value
    pop ax
    
    pop dx
    pop bx
    pop ax
    ret
check_player_move endp


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

check_wall_collision proc near
    push bx
    push cx
    push dx
    push si
    
    ; Convert pixel position to maze cell coordinates
    ; First, adjust for maze offset (13, 5)
    sub ax, 13      ; Subtract X offset
    sub bx, 5       ; Subtract Y offset
    
    ; Check if coordinates are negative (outside maze)
    cmp ax, 0
    jl @@out_of_bounds
    cmp bx, 0
    jl @@out_of_bounds
    
    ; Divide by cell size to get maze coordinates
    xor dx, dx
    mov cx, 14      ; cell_width
    div cx          ; AX = X / cell_width, DX = X % cell_width
    mov cx, ax      ; CX = maze X coordinate
    
    mov ax, bx
    xor dx, dx
    mov bx, 9       ; cell_height
    div bx          ; AX = Y / cell_height, DX = Y % cell_height
    mov dx, ax      ; DX = maze Y coordinate
    
    ; Check if coordinates are within maze bounds
    xor ah, ah
    mov al, [maze_width]
    cmp cx, ax
    jge @@out_of_bounds
    
    xor ah, ah
    mov al, [maze_height]
    cmp dx, ax
    jge @@out_of_bounds
    
    ; Calculate offset in maze_map: row * width + column
    mov ax, dx                  ; AX = row
    xor ah, ah
    mov bl, [maze_width]        ; BL = width
    xor bh, bh
    mul bx                      ; AX = row * width
    add ax, cx                  ; AX = row * width + column
    
    ; Get the maze value at this position
    mov si, offset maze_map
    add si, ax
    mov al, [si]                ; AL = maze value (0 or 1)
    
    ; If it's a wall, we need more precise collision with the smaller wall area
    cmp al, 1
    jne @@exit_proc2            ; If it's not a wall, we're done
    
    ; Key improvement: Check if we're within the actual wall area
    ; Rather than the whole cell, taking into account insets and rounded corners
    ; Note: For simplicity, we're just returning the wall status
    ; In a more precise version, you could calculate the exact position within the cell
    ; and check if it's inside the drawn wall area
    
    jmp @@exit_proc2
    
@@out_of_bounds:
    mov al, 1                   ; Treat out of bounds as wall
    
@@exit_proc2:
    pop si
    pop dx
    pop cx
    pop bx
    ret
check_wall_collision endp


start:
    mov ax, @data
    mov ds, ax
    
    call SetGraphic
    call DrawMaze     ; Draw maze first
    call draw_player_xor   ; Draw player using XOR method
    
game_loop:
    ; Since we're using XOR, drawing again will erase the player
    call draw_player_xor   ; This removes the old player
    
    ; Store old position
    mov ax, [player_x_pos]
    push ax
    mov ax, [player_y_pos]
    push ax
    
    ; Check for input and update player position
    call check_input
    
    ; Check if ESC was pressed
    cmp ax, 0
    jnz exit_game
    
    ; Draw player at new position (XOR method)
    call draw_player_xor
    
    ; Add delay for game speed
    mov cx, 1
delay_loop:
    push cx
    mov cx, 5000  ; Adjust for speed
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