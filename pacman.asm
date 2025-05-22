.model large
.stack 1000h


;Not used, but if the var is undefined, it automatically makes it null if used
NULL = -1


; variables of bmp files
PAC_UP1_FILE equ 'up1.bmp'
PAC_UP2_FILE equ 'up2.bmp'
PAC_DOWN1_FILE equ 'down1.bmp'
PAC_DOWN2_FILE equ 'down2.bmp'
PAC_LEFT1_FILE equ 'left1.bmp'
PAC_LEFT2_FILE equ 'left2.bmp'
PAC_RIGHT1_FILE equ 'right1.bmp'
PAC_RIGHT2_FILE equ 'right2.bmp'
PAC_DEFAULT_FILE equ 'default.bmp'
BLINKY_FILE_NAME equ 'blinky.bmp'
BLINKY_FILE_NAME2 equ 'blinky3.bmp'
PAFILE_NAME_IN equ 'pause.bmp'
MENU_FILE_IN equ 'menu.bmp'

; Game width, height in dosbox
SCREEN_WIDTH equ 320  
SCREEN_HEIGHT equ 200

; Define colors (Converts to VGA in procs)
BLACK equ 0
BLUE equ 1
WHITE equ 15
YELLOW equ 14
RED equ 4
GOLD_ORANGE equ 16  ; Assuming you set up palette entry 16

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
	; my score text that updates
	score_text db 'Score: $'  ; String to display before score ($ is terminator)

	;2d array of coins in map (position in converted in DrawCoins)
	little_coins_map db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; Row 0 (all zeros - top edge)
				   db 0,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,0  ; Row 1
				   db 0,0,1,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,1,0,0  ; Row 2
				   db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0  ; Row 3
				   db 0,0,1,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,1,0,0  ; Row 4
				   db 0,0,1,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,1,0,0  ; Row 5
				   db 0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,0,0  ; Row 6
				   db 0,0,0,0,0,1,0,1,1,1,1,1,1,1,0,1,0,0,0,0,0  ; Row 7
				   db 0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0  ; Row 8
				   db 0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0  ; Row 9 (mid - ghost house area)
				   db 0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0  ; Row 10
				   db 0,0,0,0,0,1,0,1,1,1,1,1,1,1,0,1,0,0,0,0,0  ; Row 11
				   db 0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0  ; Row 12
				   db 0,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,0  ; Row 13
				   db 0,0,1,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,1,0,0  ; Row 14
				   db 0,0,1,1,0,1,1,1,1,1,1,1,1,1,1,1,0,1,1,0,0  ; Row 15
				   db 0,0,0,1,0,1,0,1,0,0,0,0,0,1,0,1,0,1,0,0,0  ; Row 16
				   db 0,0,1,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,1,0,0  ; Row 17
				   db 0,0,1,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,1,0,0  ; Row 18
				   db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0  ; Row 19
				   db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; Row 20 (all zeros - bottom edge)	
		
	; Width of maze in cells
    maze_width db 21     
	; Height of the maze in cells
    maze_height db 21 
	;Width of each cell	
    cell_width dw 17     
	;Height of each cell	
    cell_height dw 13   
	
	; coins collected is my buffer in the game.
	;coins_collected: Temporary memory that changes during this game session (the value of the 1, 0 is changed during
	; the gameplay
	coins_collected db 21*21 dup(0)  

    x_pos dw 0           ; Current X position for drawing
    y_pos dw 0           ; Current Y position for drawing
	
	little_rect_x_pos dw 0    ; X coordinate for drawing a small coin
	little_rect_y_pos dw 0    ; Y coordinate for drawing a small coin
	
    colorMaze db BLUE        ; Color to draw (blue for walls)
	
	ScrLine db SCREEN_WIDTH dup (0)  ; One Color line read buffer (it chaged like my coins_collected variable)

    FileHandle dw ?
	Header db 54 dup(0)     ; Buffer of 54 bytes, all initialized to 0
	Palette db 400h dup(0)  ; Buffer of 1024 bytes, all initialized to 0
    
    ;BmpFileErrorMsg db 'Error At Opening Bmp File ', P1FILE_NAME_IN, 0dh, 0ah, '$'
    ErrorFile db 0
    BB db "BB..", '$'
    
	Image db 40*40 dup(0)   ; Buffer of 1600 bytes, all initialized to 0
    
	; Bmp placment when drawing (x, y)
    BmpLeft dw ?
    BmpTop dw ?
	; Bmp width and height
    BmpWidth dw ?
    BmpHeight dw ?
    
	; starting player x, y coordinates
    player_x_pos dw 120
    player_y_pos dw 100
	
	; Null-terminated filename strings for file operations
	; Converts the constants into strings that DOS file functions can use
	PacUp1FileName db PAC_UP1_FILE, 0
	PacUp2FileName db PAC_UP2_FILE, 0
	PacDown1FileName db PAC_DOWN1_FILE, 0
	PacDown2FileName db PAC_DOWN2_FILE, 0
	PacLeft1FileName db PAC_LEFT1_FILE, 0
	PacLeft2FileName db PAC_LEFT2_FILE, 0
	PacRight1FileName db PAC_RIGHT1_FILE, 0
	PacRight2FileName db PAC_RIGHT2_FILE, 0
	PacDefaultFileName db PAC_DEFAULT_FILE, 0
	BlinkyFileName db BLINKY_FILE_NAME, 0
	BlinkyFileName2 db BLINKY_FILE_NAME2, 0
	PAFileName db PAFILE_NAME_IN, 0
	MenuFileName db MENU_FILE_IN, 0
	
	; Directions for Pacman
	up dw 1
	down dw 1
	left dw 1
	right dw 1
	; === Player State Variables ===
	current_direction db 0      ; 0=stopped, 1=up, 2=down, 3=left, 4=right
	player_bg_buffer db 12*12 dup (0)  ; Background save area for clean sprite erasing

	; === Wall Rendering Settings ===  
	wall_corner_radius dw 2     ; Radius in pixels for rounded wall corners
	wall_inset_x dw 2          ; Horizontal spacing from cell edges (wider passages)
	wall_inset_y dw 1          ; Vertical spacing from cell edges
	wall_width dw 11           ; Wall graphics width (smaller than cell for navigation)
	wall_height dw 11          ; Wall graphics height

	; === Movement and Input === 
	queued_direction db 0       ; Next direction player wants to turn
	path_tolerance dw 2         ; Extra clearance pixels for path checking
	player_hitbox_width dw 11   ; Collision box width (forgiving movement)
	player_hitbox_height dw 11  ; Collision box height
	grid_snap_enabled db 1      ; Enable grid alignment to prevent wall clipping

	; === Animation System ===
	current_frame db 0          ; Animation frame: 0=mouth closed, 1=mouth open  
	frame_counter db 8          ; Timer controlling animation speed
	frame_delay db 20           ; Game cycles between frame changes
	is_moving db 0              ; Movement flag: 0=stopped, 1=moving

	; === Game State ===
	current_score dw 0          ; Player's score points
	current_type dw 0           ; Game mode type (0=playing, 1=paused)

	; Blinky (Red Ghost) Variables
	blinky_x_pos dw 150          ; Screen X position
	blinky_y_pos dw 80           ; Screen Y position  
	blinky_maze_x db 10          ; Maze X coordinate (center)
	blinky_maze_y db 11          ; Maze Y coordinate (ghost house)
	blinky_direction db 4        ; Current direction (1=up, 2=down, 3=left, 4=right)
	blinky_mode db 0             ; 0=scatter, 1=chase
	blinky_target_x db 20        ; Target maze X (top-right for scatter)
	blinky_target_y db 0         ; Target maze Y (top-right for scatter)
	blinky_move_counter db 0     ; Movement speed counter
	blinky_move_delay db 15      ; Higher = slower ghost
	blinky_bg_buffer db 12*12 dup(0) ; Background save buffer
	blinky_mode_timer dw 0       ; Timer for mode switching
	blinky_scatter_time dw 20   ; Time in scatter mode
	blinky_chase_time dw 300     ; Time in chase mode
	blinky_draw_mode dw 0

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

;Bmp Drawings:

;-----------------------------------------------------
; draw_menu - Displays the main menu screen
;-----------------------------------------------------
draw_menu proc near
    push ax
    push bx
    push dx
    
    mov dx, offset MenuFileName 
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
draw_menu endp

;-----------------------------------------------------
; draw_pause_menu - Displays the pause menu screen
;-----------------------------------------------------
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


;-----------------------------------------------------
; draw_player_improved - Draws Pac-Man sprite with animation and boundary checking
;-----------------------------------------------------
draw_player_improved proc near
    push ax
    push bx
    
    ; Boundary checks
    mov ax, [player_x_pos]
    cmp ax, 5
    jl @@adjust_x_min
    cmp ax, 302
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
    cmp ax, 5
    jl @@adjust_y_min
    cmp ax, 183
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
    ; First, save the background
    call save_background
    
    mov dx, offset PacDefaultFileName  ; Default sprite
    
    mov al, [current_direction]
    cmp al, 0                  ; Stopped
    je @use_default
    
    cmp al, 1                  ; Up
    jne @check_down
    cmp [current_frame], 0
    je @use_up1
    mov dx, offset PacUp2FileName
    jmp @draw_sprite
    
@use_up1:
    mov dx, offset PacUp1FileName
    jmp @draw_sprite
    
@check_down:
    cmp al, 2                  ; Down
    jne @check_left
    cmp [current_frame], 0
    je @use_down1
    mov dx, offset PacDown2FileName
    jmp @draw_sprite
    
@use_down1:
    mov dx, offset PacDown1FileName
    jmp @draw_sprite
    
@check_left:
    cmp al, 3                  ; Left
    jne @check_right
    cmp [current_frame], 0
    je @use_left1
    mov dx, offset PacLeft2FileName
    jmp @draw_sprite
    
@use_left1:
    mov dx, offset PacLeft1FileName
    jmp @draw_sprite
    
@check_right:
    cmp al, 4                  ; Right
    jne @use_default
    cmp [current_frame], 0
    je @use_right1
    mov dx, offset PacRight2FileName
    jmp @draw_sprite
    
@use_right1:
    mov dx, offset PacRight1FileName
    jmp @draw_sprite
    
@use_default:
    mov dx, offset PacDefaultFileName
    
@draw_sprite:
    ; Set up drawing parameters
    mov ax, [player_x_pos]
    mov [BmpLeft], ax
    mov ax, [player_y_pos]
    mov [BmpTop], ax
    mov [BmpWidth], 12
    mov [BmpHeight], 12
    
    ; Use transparent drawing
    call OpenShowBmpTransparent
    
    pop bx
    pop ax
    ret
draw_player_improved endp



;-----------------------------------------------------
; draw_rect - Draw a rectangle at (x_pos, y_pos) with color
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
; draw_blinky - Draws Blinky sprite at current position using transparent BMP
; First saves background, then draws sprite on top
;-----------------------------------------------------
draw_blinky proc near
    push ax
    push bx
    push dx
    
    ; First determine which sprite to use based on mode
    cmp [blinky_mode], 1
    je @use_chase_sprite
    
    ; Scatter mode sprite
    mov dx, offset BlinkyFileName
    jmp @draw_sprite2
    
@use_chase_sprite:
    ; Chase mode sprite
    mov dx, offset BlinkyFileName2
    
@draw_sprite2:
    ; Now set up position and dimensions
    mov ax, [blinky_x_pos]
    mov [BmpLeft], ax
    mov ax, [blinky_y_pos]
    mov [BmpTop], ax
    mov [BmpWidth], 12
    mov [BmpHeight], 12
    
    ; Draw the sprite
    call OpenShowBmpTransparent
    
    pop dx
    pop bx
    pop ax
    ret
draw_blinky endp


;-----------------------------------------------------
; draw_coin - Draw a single coin at position (little_rect_x_pos, little_rect_y_pos)
;-----------------------------------------------------

draw_coin proc near
    push ax
    push bx
    push cx
    push dx
    
    ; Position for drawing
    mov cx, little_rect_x_pos   ; X position
    mov dx, little_rect_y_pos   ; Y position
    
    ; Draw a bright yellow dot (3x3 pixels)
    mov al, GOLD_ORANGE         ; Use the golden orange color
    
    ; Draw a 3x3 pixel dot
    ; Top row
    mov ah, 0Ch                 ; Function to write pixel
    int 10h                     ; Draw pixel
    inc cx
    int 10h                     ; Draw pixel
    inc cx
    int 10h                     ; Draw pixel
    
    ; Move back to start of next row
    sub cx, 2
    inc dx
    
    ; Middle row
    int 10h                     ; Draw pixel
    inc cx
    int 10h                     ; Draw pixel (center pixel)
    inc cx
    int 10h                     ; Draw pixel
    
    ; Move back to start of next row
    sub cx, 2
    inc dx
    
    ; Bottom row
    int 10h                     ; Draw pixel
    inc cx
    int 10h                     ; Draw pixel
    inc cx
    int 10h                     ; Draw pixel
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_coin endp

;-----------------------------------------------------
; erase_coin - Draw a single coin at position (little_rect_x_pos, little_rect_y_pos) with colors black, means erasing
;-----------------------------------------------------
erase_coin proc near
    push ax
    push bx
    push cx
    push dx
    
    ; Position for drawing
    mov cx, little_rect_x_pos   ; X position
    mov dx, little_rect_y_pos   ; Y position
    
    ; Draw a bright yellow dot (3x3 pixels)
    mov al, BLACK         ; Use the golden orange color
    
    ; Draw a 3x3 pixel dot
    ; Top row
    mov ah, 0Ch                 ; Function to write pixel
    int 10h                     ; Draw pixel
    inc cx
    int 10h                     ; Draw pixel
    inc cx
    int 10h                     ; Draw pixel
    
    ; Move back to start of next row
    sub cx, 2
    inc dx
    
    ; Middle row
    int 10h                     ; Draw pixel
    inc cx
    int 10h                     ; Draw pixel (center pixel)
    inc cx
    int 10h                     ; Draw pixel
    
    ; Move back to start of next row
    sub cx, 2
    inc dx
    
    ; Bottom row
    int 10h                     
    inc cx
    int 10h                     
    inc cx
    int 10h                     ; Draw pixel
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
erase_coin endp


;-----------------------------------------------------
; DrawCoins - Draws coins throughout the maze at appropriate positions
; Loops through maze grid, placing coins in pathways (not walls)
; Skips outer borders and ghost house area in center
; Centers each coin within its cell for proper alignment
;-----------------------------------------------------
DrawCoins proc near
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Calculate the starting position with the maze offsets
    mov word ptr [x_pos], 13    ; Horizontal maze offset
    mov word ptr [y_pos], 5     ; Vertical maze offset
    
    ; Loop through maze rows
    xor bx, bx                  ; BX = row counter
    
draw_coins_row:
    ; Reset X position for this row
    mov ax, 13                  ; Horizontal maze offset
    mov word ptr [x_pos], ax
    
    ; Loop through maze columns
    xor cx, cx                  ; CX = column counter
    
draw_coins_col:
    ; Skip outer border: rows 0 and 20, columns 0 and 20
    cmp bx, 0
    je skip_coin
    cmp bx, 20
    je skip_coin
    cmp cx, 0
    je skip_coin
    cmp cx, 20
    je skip_coin
    
    ; Calculate offset in maze_map: row * width + column
    mov ax, bx                  ; AX = row
    xor ah, ah
    mov si, ax                  ; Save row in SI
    mov al, [maze_width]        ; AL = width
    mul si                      ; AX = row * width
    add ax, cx                  ; AX = row * width + column
    
    ; Only place coins in pathways (not walls)
    mov si, offset maze_map
    add si, ax
    mov al, [si]                ; AL = maze value (0 or 1)
    
    cmp al, 1                   ; Is it a wall?
    je skip_coin                ; If wall, skip coin
    
    ; Define a larger ghost house area to ensure a clear middle space
    ; Expanded ghost house area: rows 8-12, columns 7-13
	cmp bx, 7                   ; Check if row >= 8
	jl not_ghost_house
	cmp bx, 13                  ; Check if row <= 13
	jg not_ghost_house
	cmp cx, 6                   ; Check if column >= 6
	jl not_ghost_house
	cmp cx, 14                  ; Check if column <= 14
	jg not_ghost_house
		
    ; We're in the ghost house area, skip this coin
    jmp skip_coin
    
not_ghost_house:
    ; Calculate position for coin drawing - CENTER IT IN THE CELL
    mov ax, [x_pos]
    add ax, 7                   ; Center horizontally (cell width is 14, so +7)
    mov [little_rect_x_pos], ax
    
    mov ax, [y_pos]
    add ax, 5                   ; Better vertical centering (cell height is 9, so +5)
    mov [little_rect_y_pos], ax
    
    ; Draw the coin at calculated position
    call draw_coin
    
skip_coin:
    ; Move to next column
    add word ptr [x_pos], 14    ; Cell width
    
    ; Next column
    inc cx
    mov al, [maze_width]
    cmp cl, al
    jl draw_coins_col
    
    ; Move to next row
    add word ptr [y_pos], 9     ; Cell height
    
    ; Next row
    inc bx
    mov al, [maze_height]
    cmp bl, al
    jl draw_coins_row
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DrawCoins endp



;-----------------------------------------------------
; check_coin_collision - Checks if player is touching a coin and handles collection
; Converts player position to grid coordinates, verifies coin exists
; Marks coin as collected, erases it from screen, and updates score
;-----------------------------------------------------
check_coin_collision proc near
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Calculate player's center in grid coordinates
    mov ax, [player_x_pos]
    add ax, 6                   ; Half of player width (12/2)
    sub ax, 13                  ; Adjust for maze offset
    mov bx, 14                  ; Cell width
    xor dx, dx
    div bx                      ; AX = player grid X, DX = remainder
    mov cx, ax                  ; Save grid X in CX
    
    mov ax, [player_y_pos]
    add ax, 6                   ; Half of player height (12/2)
    sub ax, 5                   ; Adjust for maze offset
    mov bx, 9                   ; Cell height
    xor dx, dx
    div bx                      ; AX = player grid Y, DX = remainder
    mov bx, ax                  ; Save grid Y in BX
    
    ; Check bounds
    cmp cx, 0
    jl no_coin_here
    cmp cx, 20
    jge no_coin_here
    cmp bx, 0
    jl no_coin_here
    cmp bx, 20
    jge no_coin_here
    
    ; Calculate index in maze map: row * width + column
    mov ax, bx                  ; AX = row
    mov si, ax                  ; Save row in SI
    mov al, [maze_width]        ; AL = width
    mul si                      ; AX = row * width
    add ax, cx                  ; AX = row * width + column
    mov si, ax                  ; SI = index
    
    ; Check if this position is a wall (no coin possible)
    mov di, offset maze_map
    add di, si
    mov al, [di]                ; Get maze value
    
    cmp al, 1                   ; Is it a wall?
    je no_coin_here             ; If wall, exit - no coin possible
    
    ; Now check if this coin has already been collected
    mov di, offset coins_collected
    add di, si
    mov al, [di]                ; Get collected status
    
    cmp al, 1                   ; Already collected?
    je no_coin_here             ; If already collected, exit
    
    ; Check ghost house area - no coins there
    cmp bx, 7                   ; Row >= 7
    jl check_corners
    cmp bx, 13                  ; Row <= 13
    jg check_corners
    cmp cx, 6                   ; Column >= 6
    jl check_corners
    cmp cx, 14                  ; Column <= 14
    jg check_corners
    
    ; In ghost house area - skip
    jmp no_coin_here
    
check_corners:
    ; Skip coins in corner areas same as in DrawCoins
    ; (Add any specific corner checks if needed)
    
    ; If we get here, it's a valid coin to collect!
    
    ; Mark as collected FIRST
    mov byte ptr [di], 1
    
    ; Calculate screen position for the coin
    mov ax, cx                  ; Grid X
    mov si, 14                  ; Cell width
    mul si                      ; AX = Grid X * cell width
    add ax, 13                  ; Add horizontal maze offset
    add ax, 7                   ; Center within cell
    mov [little_rect_x_pos], ax ; Set X position for erasing
    
    mov ax, bx                  ; Grid Y
    mov si, 9                   ; Cell height
    mul si                      ; AX = Grid Y * cell height
    add ax, 5                   ; Add vertical maze offset
    add ax, 5                   ; Center within cell
    mov [little_rect_y_pos], ax ; Set Y position for erasing
    
    ; Now erase the coin
    call erase_coin
    
    ; Update score
    add word ptr [current_score], 10
    
    ; Display updated score immediately
    call display_score
    
no_coin_here:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
check_coin_collision endp

;-----------------------------------------------------
; display_score - Add this procedure to display the score
;-----------------------------------------------------
display_score proc near
    push ax
    push bx
    push cx
    push dx
    
    ; Position for score display (top-left corner)
    mov ah, 02h      ; Set cursor position
    mov bh, 0        ; Page number
    mov dh, 0        ; Row 0 (top)
    mov dl, 0        ; Column 0 (left)
    int 10h
    
    ; Display "Score: "
    mov ah, 09h      ; Display string function
    mov dx, offset score_text
    int 21h
    
    ; Convert score to ASCII and display
    mov ax, [current_score]
    call display_number
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_score endp

;-----------------------------------------------------
; display_number - Converts number in AX to decimal and displays it on screen
; Uses stack to reverse digits for correct left-to-right display
;-----------------------------------------------------
display_number proc near
    push ax
    push bx
    push cx
    push dx
    
    ; Convert number in AX to decimal digits
    mov bx, 10       ; Divisor
    xor cx, cx       ; Digit counter
    
convert_loop:
    xor dx, dx       ; Clear DX for division
    div bx           ; AX / 10, quotient in AX, remainder in DX
    push dx          ; Save remainder (current digit)
    inc cx           ; Increment digit counter
    test ax, ax      ; Check if quotient is zero
    jnz convert_loop ; If not zero, continue loop
    
display_loop:
    pop dx           ; Get digit
    add dl, '0'      ; Convert to ASCII
    mov ah, 02h      ; Function to display character
    int 21h
    loop display_loop
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_number endp

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


;-----------------------------------------------------
; OpenShowBmp - Loads and displays a BMP image at specified screen position
;-----------------------------------------------------
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

;-----------------------------------------------------
; OpenBmpFile - Opens BMP file and stores handle, sets error flag if failed
;-----------------------------------------------------
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

;-----------------------------------------------------
; CloseBmpFile - Closes the currently open BMP file
;-----------------------------------------------------
CloseBmpFile proc near
    mov ah, 3Eh
    mov bx, [FileHandle]
    int 21h
    ret
CloseBmpFile endp

;-----------------------------------------------------
; ReadBmpHeader - Reads 54-byte BMP header into Header buffer
;-----------------------------------------------------
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

;-----------------------------------------------------
; ReadBmpPalette - Reads 1024-byte color palette into Palette buffer
;-----------------------------------------------------
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

;-----------------------------------------------------
; CopyBmpPalette - Copies BMP palette to VGA, with special handling for BLUE and GOLD_ORANGE
;-----------------------------------------------------
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
    ; Get the current color index we're processing
    push cx
    mov ax, 256
    sub ax, cx
    
    ; We'll only override specific colors (BLUE=1, GOLD_ORANGE=16)
    ; and leave all other colors (including player colors) untouched
    
    cmp ax, 1         ; Is this color index 1? (BLUE)
    je SetBlue
    
    cmp ax, 16        ; Is this color index 16? (GOLD_ORANGE)
    je SetGold
    
    ; For all other colors, copy directly from BMP (including player colors)
    pop cx
    mov al, [si+2]    ; Blue component
    shr al, 2         ; Scale to VGA range (0-63)
    out dx, al
    
    mov al, [si+1]    ; Green component
    shr al, 2
    out dx, al
    
    mov al, [si]      ; Red component
    shr al, 2
    out dx, al
    
    add si, 4         ; Move to next color in palette
    jmp NextColor
    
SetBlue:
    ; Special handling for BLUE (index 1)
    pop cx
    mov al, 0         ; Red = 0
    out dx, al
    mov al, 0         ; Green = 0
    out dx, al
    mov al, 63        ; Blue = max (63)
    out dx, al
    add si, 4
    jmp NextColor
    
SetGold:
    ; Special handling for GOLD_ORANGE (index 16)
    pop cx
    mov al, 63        ; Red = max (63)
    out dx, al
    mov al, 40        ; Green = medium (40)
    out dx, al
    mov al, 0         ; Blue = 0
    out dx, al
    add si, 4
    
NextColor:
    loop CopyNextColor
    
    pop dx
    pop cx
    ret
CopyBmpPalette endp

;-----------------------------------------------------
; ShowBMP - Displays BMP image data to screen (non-transparent)
;-----------------------------------------------------
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


;-----------------------------------------------------
; ShowBMPTransparent - Displays BMP with transparency, skips black pixels and wall collisions
;-----------------------------------------------------
OpenShowBmpTransparent proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di  
    
    mov [ErrorFile], 0
    call OpenBmpFile
    cmp [ErrorFile], 1
    je @@ExitProc4
    
    call ReadBmpHeader
    call ReadBmpPalette
    call CopyBmpPalette
    call ShowBMPTransparent
    call CloseBmpFile

@@ExitProc4:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
OpenShowBmpTransparent endp

;-----------------------------------------------------
; ShowBMPTransparent - Displays BMP with transparency, skips black pixels and wall collisions
;-----------------------------------------------------
ShowBMPTransparent proc near
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
@@NextPixel2:
    lodsb                   ; Load pixel from BMP to AL
    
    ; Skip black pixels (transparent)
    cmp al, 0
    je @@SkipPixel2
    
    ; THIS IS THE CRITICAL FIX: Check pixel color BEFORE drawing
    ; If current pixel is a BLUE wall, DO NOT draw over it
    mov ah, es:[di]
    cmp ah, BLUE
    je @@SkipPixel2         ; Skip drawing if it's a wall
    
    ; Draw non-black pixels only if not drawing on a wall
    mov es:[di], al
    
@@SkipPixel2:
    inc di
    loop @@NextPixel2
    
    sub di, [BmpWidth]
    sub di, SCREEN_WIDTH
    
    pop cx
    loop @@NextLine2
    
    pop cx
    ret
ShowBMPTransparent endp

;-----------------------------------------------------
; snap_to_grid - Aligns player position to grid cells for smoother movement
;-----------------------------------------------------
snap_to_grid proc near
    push ax
    push bx
    push dx
    
    ; Only snap when changing directions
    cmp [grid_snap_enabled], 1
    jne @skip_snap
    
    ; Calculate proper X position (center in cell)
    mov ax, [player_x_pos]
    add ax, 6         ; Add half player width
    sub ax, 13        ; Subtract maze offset
    mov bx, 14        ; Cell width
    div bl            ; AL = cell index, AH = remainder
    
    ; If remainder is close to middle, snap to center
    cmp ah, 7
    jl @check_y       ; Less than half, don't snap X
    cmp ah, 9
    jg @check_y       ; More than half+2, don't snap X
    
    ; Snap X to center of cell
    mul bl            ; AX = cell_index * cell_width
    add ax, 13        ; Add maze offset
    add ax, 7         ; Center in cell
    sub ax, 6         ; Adjust for half player width
    mov [player_x_pos], ax
    
@check_y:
    ; Calculate proper Y position (center in cell)
    mov ax, [player_y_pos]
    add ax, 6         ; Add half player height
    sub ax, 5         ; Subtract maze offset
    mov bx, 9         ; Cell height
    div bl            ; AL = cell index, AH = remainder
    
    ; If remainder is close to middle, snap to center
    cmp ah, 4
    jl @skip_snap     ; Less than half, don't snap
    cmp ah, 6
    jg @skip_snap     ; More than half+2, don't snap
    
    ; Snap Y to center of cell
    mul bl            ; AX = cell_index * cell_height
    add ax, 5         ; Add maze offset
    add ax, 4         ; Center in cell
    sub ax, 6         ; Adjust for half player height
    mov [player_y_pos], ax
    
@skip_snap:
    pop dx
    pop bx
    pop ax
    ret
snap_to_grid endp



;-----------------------------------------------------
; check_input - Handles keyboard input and player movement logic
;-----------------------------------------------------
check_input proc near
    ; Check for keyboard input
    mov ah, 1
    int 16h
    jnz @handle_key    ; Key IS available, handle it
    jmp @check_queue   ; No key, check queue

@handle_key:
    ; Get the key
    mov ah, 0
    int 16h
    
    ; Check for ESC
    cmp ah, 01h        ; ESC scan code
    jne @check_dirs
    call toggle_pause
    ret
    
@check_dirs:
    ; Check direction keys
    cmp ah, 48h        ; Up arrow
    jne @not_up
    jmp @up_key
@not_up:
    cmp ah, 50h        ; Down arrow
    jne @not_down
    jmp @down_key
@not_down:    
    cmp ah, 4Bh        ; Left arrow
    jne @not_left
    jmp @left_key
@not_left:
    cmp ah, 4Dh        ; Right arrow
    jne @not_right
    jmp @right_key
@not_right:
    jmp @check_queue   ; Not a direction key

@up_key:
    ; Check if already moving up
    cmp [current_direction], 1
    jne @try_up
    jmp @check_queue
@try_up:
    ; Try moving up
    mov al, 1
    call check_player_move
    cmp cl, 1
    jne @queue_up
    jmp @set_up
@queue_up:
    ; Queue for later
    mov byte ptr [queued_direction], 1
    jmp @check_queue
    
@set_up:
    mov byte ptr [current_direction], 1
    mov byte ptr [queued_direction], 0
    jmp @check_queue
    
@down_key:
    ; Check if already moving down
    cmp [current_direction], 2
    jne @try_down
    jmp @check_queue
@try_down:
    ; Try moving down
    mov al, 2
    call check_player_move
    cmp cl, 1
    jne @queue_down
    jmp @set_down
@queue_down:
    ; Queue for later
    mov byte ptr [queued_direction], 2
    jmp @check_queue
    
@set_down:
    mov byte ptr [current_direction], 2
    mov byte ptr [queued_direction], 0
    jmp @check_queue
    
@left_key:
    ; Check if already moving left
    cmp [current_direction], 3
    jne @try_left
    jmp @check_queue
@try_left:
    ; Try moving left
    mov al, 3
    call check_player_move
    cmp cl, 1
    jne @queue_left
    jmp @set_left
@queue_left:
    ; Queue for later
    mov byte ptr [queued_direction], 3
    jmp @check_queue
    
@set_left:
    mov byte ptr [current_direction], 3
    mov byte ptr [queued_direction], 0
    jmp @check_queue
    
@right_key:
    ; Check if already moving right
    cmp [current_direction], 4
    jne @try_right
    jmp @check_queue
@try_right:
    ; Try moving right
    mov al, 4
    call check_player_move
    cmp cl, 1
    jne @queue_right
    jmp @set_right
@queue_right:
    ; Queue for later
    mov byte ptr [queued_direction], 4
    jmp @check_queue
    
@set_right:
    mov byte ptr [current_direction], 4
    mov byte ptr [queued_direction], 0
    
@check_queue:
    ; Check for queued direction
    mov al, [queued_direction]
    or al, al          ; Test if zero
    jz @check_movement ; No queued direction
    
    ; Try the queued direction
    call check_player_move
    cmp cl, 1
    jne @check_movement
    
    ; Apply queued direction
    mov al, [queued_direction]
    mov [current_direction], al
    mov byte ptr [queued_direction], 0
    
@check_movement:
    ; Check if current direction is valid
    mov al, [current_direction]
    cmp al, 0
    jne @do_move
    jmp no_key
@do_move:
    ; Check if we can move in current direction
    call check_player_move
    cmp cl, 1
    jne stop_movement
    
    ; Apply movement based on direction
    cmp al, 1
    jne @not_move_up
    jmp auto_move_up
@not_move_up:
    cmp al, 2
    jne @not_move_down
    jmp auto_move_down
@not_move_down:
    cmp al, 3
    jne @not_move_left
    jmp auto_move_left
@not_move_left:
    cmp al, 4
    jne @not_move_right
    jmp auto_move_right
@not_move_right:
    jmp no_key
    
auto_move_up:
    mov [is_moving], 1
    mov ax, [player_y_pos]
    sub ax, [up]
    mov [player_y_pos], ax
    call check_coin_collision
    jmp no_key
    
auto_move_down:
    mov [is_moving], 1
    mov ax, [player_y_pos]
    add ax, [down]
    mov [player_y_pos], ax
    call check_coin_collision
    jmp no_key
    
auto_move_left:
    mov [is_moving], 1
    mov ax, [player_x_pos]
    sub ax, [left]
    mov [player_x_pos], ax
    call check_coin_collision
    jmp no_key
    
auto_move_right:
    mov [is_moving], 1
    mov ax, [player_x_pos]
    add ax, [right]
    mov [player_x_pos], ax
    call check_coin_collision
    jmp no_key
    
stop_movement:
    mov [current_direction], 0
    mov [is_moving], 0
    
no_key:
    xor ax, ax
    ret
check_input endp



;-----------------------------------------------------
; handle_menu_input - Processes menu input (Enter to start, 'o' to exit)
;-----------------------------------------------------
handle_menu_input proc near
    menu_wait:
        mov ah, 00h       ; Wait for keypress
        int 16h
        
        cmp al, 0Dh       ; Enter key
        je start_game
        
        cmp al, 'o'       ; 'o' key
        je exit_program
        
        jmp menu_wait     ; Invalid key, keep waiting

    start_game:
        call clear_screen
        call run_game     ; This will never return
        ret               ; Safety return (unreachable)

    exit_program:
        call ExitGraphic ; This will terminate the program
        ret               ; Safety return (unreachable)
handle_menu_input endp

;-----------------------------------------------------
; clear_screen - Fills screen with black pixels
;-----------------------------------------------------
clear_screen proc near
    push ax
    push cx
    push di
    push es

    mov ax, 0a000h   ; set es to point to vga memory segment
    mov es, ax       
    xor di, di       ; start at video memory offset 0
    mov cx, 64000    ; 320 * 200 pixels
    mov al, 0        ; black color
    rep stosb        ; fill video memory with al (black)

    pop es
    pop di
    pop cx
    pop ax
    ret
clear_screen endp


;-----------------------------------------------------
; check_up_move - Checks if player can move upward without collision
;-----------------------------------------------------
check_up_move proc near
    push ax
    push bx
    
    
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

;-----------------------------------------------------
; check_down_move - Checks if player can move downward without collision
;-----------------------------------------------------
check_down_move proc near
    push ax
    push bx
    
    mov ax, [player_x_pos]
    add ax, 3               ; Further inset from left
    mov bx, [player_y_pos]
    add bx, [player_hitbox_height]
    call check_wall_collision
    cmp al, 1
    je @@down_blocked
    
    ; Skip the center check for better narrow passage navigation
    
    mov ax, [player_x_pos]
    add ax, [player_hitbox_width]
    sub ax, 3               ; Further inset from right
    mov bx, [player_y_pos]
    add bx, [player_hitbox_height]
    call check_wall_collision
    cmp al, 1
    je @@down_blocked
    
    mov cl, 1               ; Can move
    jmp @@down_exit
    
@@down_blocked:
    mov cl, 0               ; Can't move
    
@@down_exit:
    pop bx
    pop ax
    ret
check_down_move endp

;-----------------------------------------------------
; check_left_move - Checks if player can move left without collision
;-----------------------------------------------------
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

;-----------------------------------------------------
; check_right_move - Checks if player can move right without collision
;-----------------------------------------------------
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

;-----------------------------------------------------
; check_player_move - Main movement validation for any direction
;-----------------------------------------------------
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


;-----------------------------------------------------
; vsync - Waits for vertical retrace for smooth animation
;-----------------------------------------------------
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

;-----------------------------------------------------
; check_wall_collision - Converts pixel coordinates to grid and checks for walls
;-----------------------------------------------------
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

;-----------------------------------------------------
; save_background - Saves 12x12 area behind player for restoration
;-----------------------------------------------------
save_background proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Set video memory segment
    mov ax, 0A000h
    mov es, ax
    
    ; Calculate starting position in video memory
    mov ax, 320            ; Screen width
    mul [player_y_pos]     ; Y position * screen width
    add ax, [player_x_pos] ; Add X position
    mov si, ax             ; Source index = position in video memory
    
    ; Set destination to our buffer
    mov di, offset player_bg_buffer
    
    ; Save 12x12 background
    mov cx, 12             ; Player height
@@save_row:
    push cx
    push si
    
    mov cx, 12             ; Player width
@@save_col:
    mov al, es:[si]        ; Get pixel from screen
    mov [di], al           ; Store in buffer
    inc si                 ; Next source pixel
    inc di                 ; Next buffer position
    loop @@save_col
    
    pop si
    add si, 320            ; Move to next screen row
    pop cx
    dec cx
    jnz @@save_row
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
save_background endp

;-----------------------------------------------------
; restore_background - Restores saved background to erase player
;-----------------------------------------------------
restore_background proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Set video memory segment
    mov ax, 0A000h
    mov es, ax
    
    ; Calculate starting position in video memory
    mov ax, 320            ; Screen width
    mul [player_y_pos]     ; Y position * screen width
    add ax, [player_x_pos] ; Add X position
    mov di, ax             ; Destination index = position in video memory
    
    ; Set source to our buffer
    mov si, offset player_bg_buffer
    
    ; Restore 12x12 background
    mov cx, 12             ; Player height
@@restore_row:
    push cx
    push di
    
    mov cx, 12             ; Player width
@@restore_col:
    mov al, [si]           ; Get pixel from buffer
    mov es:[di], al        ; Restore to screen
    inc si                 ; Next buffer pixel
    inc di                 ; Next screen position
    loop @@restore_col
    
    pop di
    add di, 320            ; Move to next screen row
    pop cx
    dec cx
    jnz @@restore_row
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
restore_background endp

;-----------------------------------------------------
; update_animation - Controls Pac-Man mouth animation frames
;-----------------------------------------------------
update_animation proc near
    ; Only animate if moving
    cmp [is_moving], 1
    jne @reset_animation
    
    ; Update animation frame counter
    inc [frame_counter]
    mov al, [frame_delay]
    cmp [frame_counter], al
    jl @done
    
    ; Time to change frames
    mov [frame_counter], 0
    xor al, al              ; AL = 0
    cmp [current_frame], al
    je @switch_to_frame1
    mov [current_frame], 0  ; Toggle to frame 0
    jmp @done
    
@switch_to_frame1:
    mov [current_frame], 1  ; Toggle to frame 1
    jmp @done
    
@reset_animation:
    ; Reset to first frame when not moving
    mov [current_frame], 0
    mov [frame_counter], 0
    
@done:
    ret
update_animation endp

;-----------------------------------------------------
; toggle_pause - Switches between game and pause states
;-----------------------------------------------------
toggle_pause proc near
    cmp [current_type], 0
    jz do_pause
    ; Else unpause
    mov [current_type], 0
    ret

do_pause:
    mov [current_type], 1
    call pause_menu
    ret
toggle_pause endp

;-----------------------------------------------------
; pause_menu - Handles pause menu loop and input
;-----------------------------------------------------
pause_menu proc near
    call clear_screen
    call draw_pause_menu

pause_loop:
    mov ah, 00h
    int 16h
    
    cmp al, "o"
    je exit
    
    cmp al, 1Bh   ; ESC pressed?
    jne pause_loop
    
    call clear_screen
    call run_game
        
exit:
    call exit_and_cls
pause_menu endp


; Enemies Logic (without drawing):


;-----------------------------------------------------
; maze_to_screen_blinky - Converts Blinky's maze coordinates to screen pixels
; Uses same conversion as the maze drawing (14x9 cells with 13,5 offset)
;-----------------------------------------------------
maze_to_screen_blinky proc near
    push ax
    push bx
    
    ; Convert maze X to screen X: screen_x = maze_x * 14 + 13 + 1
    xor ah, ah
    mov al, [blinky_maze_x]
    mov bx, 14              ; Cell width
    mul bx                  ; AX = maze_x * cell_width
    add ax, 13              ; Add horizontal maze offset
    add ax, 1               ; Small centering adjustment
    mov [blinky_x_pos], ax
    
    ; Convert maze Y to screen Y: screen_y = maze_y * 9 + 5 + 1  
    xor ah, ah
    mov al, [blinky_maze_y]
    mov bx, 9               ; Cell height
    mul bx                  ; AX = maze_y * cell_height
    add ax, 5               ; Add vertical maze offset
    add ax, 1               ; Small centering adjustment
    mov [blinky_y_pos], ax
    
    pop bx
    pop ax
    ret
maze_to_screen_blinky endp


;-----------------------------------------------------
; save_blinky_background - Saves 12x12 area behind Blinky for clean erasing
; Same technique as player background saving
;-----------------------------------------------------
save_blinky_background proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Set video memory segment
    mov ax, 0A000h
    mov es, ax
    
    ; Calculate screen position: pos = y * 320 + x
    mov ax, 320            
    mul [blinky_y_pos]     
    add ax, [blinky_x_pos] 
    mov si, ax             ; Source index in video memory
    
    ; Point to our background buffer
    mov di, offset blinky_bg_buffer
    
    ; Save 12x12 pixel area
    mov cx, 12             ; Height in pixels
@save_row:
    push cx
    push si
    
    mov cx, 12             ; Width in pixels
@save_col:
    mov al, es:[si]        ; Get pixel from screen
    mov [di], al           ; Store in buffer
    inc si                 ; Next screen pixel
    inc di                 ; Next buffer position
    loop @save_col
    
    pop si
    add si, 320            ; Move to next screen row
    pop cx
    dec cx
    jnz @save_row
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
save_blinky_background endp

;-----------------------------------------------------
; restore_blinky_background - Restores saved background to erase Blinky
;-----------------------------------------------------
restore_blinky_background proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Set video memory segment
    mov ax, 0A000h
    mov es, ax
    
    ; Calculate screen position: pos = y * 320 + x
    mov ax, 320            
    mul [blinky_y_pos]     
    add ax, [blinky_x_pos] 
    mov di, ax             ; Destination index in video memory
    
    ; Point to our background buffer
    mov si, offset blinky_bg_buffer
    
    ; Restore 12x12 pixel area
    mov cx, 12             ; Height in pixels
@restore_row:
    push cx
    push di
    
    mov cx, 12             ; Width in pixels
@restore_col:
    mov al, [si]           ; Get pixel from buffer
    mov es:[di], al        ; Restore to screen
    inc si                 ; Next buffer pixel
    inc di                 ; Next screen position
    loop @restore_col
    
    pop di
    add di, 320            ; Move to next screen row
    pop cx
    dec cx
    jnz @restore_row
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
restore_blinky_background endp


;-----------------------------------------------------
; is_valid_maze_position - Checks if a maze coordinate is walkable (not a wall)
; Input: AL = maze_x, BH = maze_y
; Output: CL = 1 if valid path, 0 if wall or out of bounds
;-----------------------------------------------------
is_valid_maze_position proc near
    push ax
    push bx
    push dx
    push si
    
    ; Check if coordinates are within maze bounds (0-20)
    cmp al, 0
    jl @invalid_position
    cmp al, 20              
    jg @invalid_position
    cmp bh, 0
    jl @invalid_position
    cmp bh, 20              
    jg @invalid_position
    
    ; Calculate array index: index = row * width + column
    push ax                 ; Save column (maze_x)
    xor ah, ah              
    mov al, bh              ; Move row (maze_y) to AL
    mov bh, 0               
    mov bl, 21              ; maze_width
    mul bl                  ; AX = row * width
    mov si, ax              ; Store in SI
    pop ax                  ; Restore column to AL
    xor ah, ah              
    add si, ax              ; SI = row * width + column
    
    ; Check if this position is a wall in maze_map
    mov bx, offset maze_map
    add bx, si
    mov al, [bx]
    
    cmp al, 1               ; Is it a wall?
    je @invalid_position
    
    ; Valid position (empty path)
    mov cl, 1
    jmp @position_check_done
    
@invalid_position:
    mov cl, 0
    
@position_check_done:
    pop si
    pop dx
    pop bx
    pop ax
    ret
is_valid_maze_position endp

;-----------------------------------------------------
; update_blinky - Main Blinky update procedure
; Handles mode switching, movement timing, and AI behavior
;-----------------------------------------------------

update_blinky proc near
    push ax
    push bx
    
    ; Increment movement counter for speed control
    inc byte ptr [blinky_move_counter]
    mov al, [blinky_move_delay]
    cmp [blinky_move_counter], al
    jnl @dont_skip         ; Not time to move yet
	jmp @skip_blinky_move
@dont_skip:
    ; Restore background at CURRENT position before moving
    call restore_blinky_background
    
    ; Reset movement counter
    mov byte ptr [blinky_move_counter], 0
    
    ; Update mode timer and switch between scatter/chase
    inc word ptr [blinky_mode_timer]
    
    ; Check if we need to switch modes
    mov al, [blinky_mode]
    cmp al, 0                    ; Currently in scatter mode?
    je @check_scatter_timer
    
    ; In chase mode - check if time to switch to scatter
    mov ax, [blinky_mode_timer]
    cmp ax, [blinky_chase_time]
    jl @move_blinky             ; Continue chasing
    
    ; Switch to scatter mode
    mov byte ptr [blinky_mode], 0
    mov word ptr [blinky_mode_timer], 0
    mov word ptr [blinky_draw_mode], 0  ; Update draw mode when switching to scatter
    jmp @move_blinky
    
@check_scatter_timer:
    ; In scatter mode - check if time to switch to chase  
    mov ax, [blinky_mode_timer]
    cmp ax, [blinky_scatter_time]
    jl @move_blinky             ; Continue scattering
    
    ; Switch to chase mode
    mov byte ptr [blinky_mode], 1
    mov word ptr [blinky_mode_timer], 0
    mov word ptr [blinky_draw_mode], 1  ; Update draw mode when switching to chase
    
@move_blinky:
    ; Set target based on current mode
    mov al, [blinky_mode]
    cmp al, 0
    je @scatter_mode
    
    ; Chase mode - target Pac-Man's position
    call set_chase_target
    jmp @find_best_direction
    
@scatter_mode:
    ; Scatter mode - target top-right corner with bias for getting to top first
    cmp [blinky_maze_y], 5      ; If already high enough in the maze
    jl @target_right            ; Focus on getting to the right side
    
    ; Otherwise, prioritize going up first
    mov al, [blinky_maze_x]
    mov [blinky_target_x], al   ; Stay in same column
    mov byte ptr [blinky_target_y], 0   ; Head straight up
    jmp @find_best_direction
    
@target_right:
    mov byte ptr [blinky_target_x], 20  ; Target right side
    mov byte ptr [blinky_target_y], 0   ; Stay at top
    
@find_best_direction:
    ; Use pathfinding to move toward target
    call move_blinky_toward_target
    
    ; Convert maze coordinates back to screen position
    call maze_to_screen_blinky
    
    ; Save the background at the NEW position
    call save_blinky_background
    
    jmp @blinky_update_done

@skip_blinky_move:    
    ; No movement, do nothing to background
    
@blinky_update_done:
    pop bx
    pop ax
    ret
update_blinky endp

;-----------------------------------------------------
; set_chase_target - Sets Blinky's target to Pac-Man's current maze position
; Converts player screen coordinates to maze coordinates
;-----------------------------------------------------
set_chase_target proc near
    push ax
    push bx
    push dx
    
    ; Convert player X position to maze coordinate
    mov ax, [player_x_pos]
    add ax, 6               ; Center of player sprite
    sub ax, 13              ; Subtract maze offset
    mov bx, 14              ; Cell width
    xor dx, dx
    div bx                  ; AX = player maze X
    mov [blinky_target_x], al
    
    ; Convert player Y position to maze coordinate
    mov ax, [player_y_pos]
    add ax, 6               ; Center of player sprite
    sub ax, 5               ; Subtract maze offset
    mov bx, 9               ; Cell height
    xor dx, dx
    div bx                  ; AX = player maze Y
    mov [blinky_target_y], al
    
    pop dx
    pop bx
    pop ax
    ret
set_chase_target endp

;-----------------------------------------------------
; move_blinky_toward_target - COMPACT FIXED VERSION
; Better pathfinding in one function, prevents erratic movement
;-----------------------------------------------------
move_blinky_toward_target proc near
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov dl, [blinky_maze_x]     ; Current X position
    mov dh, [blinky_maze_y]     ; Current Y position
    mov cl, [blinky_direction]  ; Current direction
    
    ; STEP 1: Always try to continue current direction first
    ; This prevents erratic direction changes and jittering
    mov al, dl                  ; Current X
    mov bh, dh                  ; Current Y
    
    ; Modify position based on current direction
    cmp cl, 1                   ; Going up?
    jne blinky_check_down_current
    dec bh                      ; Try Y-1
    jmp blinky_test_current
    
blinky_check_down_current:
    cmp cl, 2                   ; Going down?
    jne blinky_check_left_current
    inc bh                      ; Try Y+1
    jmp blinky_test_current
    
blinky_check_left_current:
    cmp cl, 3                   ; Going left?
    jne blinky_check_right_current
    dec al                      ; Try X-1
    jmp blinky_test_current
    
blinky_check_right_current:
    cmp cl, 4                   ; Going right?
    jne blinky_choose_new_direction
    inc al                      ; Try X+1
    
blinky_test_current:
    ; Test if current direction is still valid
    call is_valid_maze_position
    cmp cl, 1
    jne blinky_choose_new_direction ; Blocked, need new direction
    
    ; Can continue current direction - update position
    mov al, [blinky_direction]
    cmp al, 1                   ; Was up?
    jne blinky_continue_not_up
    dec byte ptr [blinky_maze_y]
    jmp blinky_movement_done
    
blinky_continue_not_up:
    cmp al, 2                   ; Was down?
    jne blinky_continue_not_down
    inc byte ptr [blinky_maze_y]
    jmp blinky_movement_done
    
blinky_continue_not_down:
    cmp al, 3                   ; Was left?
    jne blinky_continue_not_left
    dec byte ptr [blinky_maze_x]
    jmp blinky_movement_done
    
blinky_continue_not_left:
    ; Must be right
    inc byte ptr [blinky_maze_x]
    jmp blinky_movement_done
    
blinky_choose_new_direction:
    ; STEP 2: Can't continue current direction - choose new one toward target
    ; Calculate differences to target
    mov al, [blinky_target_x]
    sub al, dl                  ; AL = signed X difference
    mov bl, al                  ; Save signed X diff
    jns blinky_x_positive
    neg al                      ; Make absolute
blinky_x_positive:
    
    mov ah, [blinky_target_y]
    sub ah, dh                  ; AH = signed Y difference
    mov bh, ah                  ; Save signed Y diff
    jns blinky_y_positive
    neg ah                      ; Make absolute
blinky_y_positive:
    
    ; AL = |x_diff|, AH = |y_diff|
    ; BL = signed x_diff, BH = signed y_diff
    
    ; Try the axis with larger difference first
    cmp al, ah
    jb blinky_try_vertical      ; |x_diff| < |y_diff|
    je blinky_choose_random     ; Equal differences, choose randomly
    
    ; Try horizontal first (larger X difference)
    cmp bl, 0
    jl blinky_try_left          ; Target is left
    jg blinky_try_right         ; Target is right
    jmp blinky_try_vertical     ; Same X, try vertical
    
blinky_choose_random:
    ; Use system timer to make a pseudo-random choice
    mov ah, 0
    int 1Ah                    ; Get system time - CX:DX = tick count
    test dl, 1                 ; Test lowest bit
    jz blinky_try_horizontal   ; If 0, try horizontal first
    jmp blinky_try_vertical    ; If 1, try vertical first
    
blinky_try_horizontal:
    cmp bl, 0
    jl blinky_try_left          ; Target is left
    jg blinky_try_right         ; Target is right
    jmp blinky_try_vertical     ; Same X, try vertical
    
blinky_try_right:
    ; Don't reverse from left to right
    cmp cl, 3                   ; Was going left?
    je blinky_try_left          ; Don't reverse
    
    ; Test moving right
    mov al, dl
    inc al                      ; Try X+1
    mov bh, dh
    call is_valid_maze_position
    cmp cl, 1
    jne blinky_try_left         ; Can't go right
    
    ; Move right
    mov byte ptr [blinky_direction], 4
    inc byte ptr [blinky_maze_x]
    jmp blinky_movement_done
    
blinky_try_left:
    ; Don't reverse from right to left
    cmp [blinky_direction], 4   ; Was going right?
    je blinky_try_vertical      ; Don't reverse
    
    ; Test moving left
    mov al, dl
    dec al                      ; Try X-1
    mov bh, dh
    call is_valid_maze_position
    cmp cl, 1
    jne blinky_try_vertical     ; Can't go left
    
    ; Move left
    mov byte ptr [blinky_direction], 3
    dec byte ptr [blinky_maze_x]
    jmp blinky_movement_done
    
blinky_try_vertical:
    ; Try vertical movement
    cmp bh, 0
    jl blinky_try_up            ; Target is up
    jg blinky_try_down          ; Target is down
    jmp blinky_try_any_direction ; Same Y, try any direction
    
blinky_try_down:
    ; Don't reverse from up to down
    cmp cl, 1                   ; Was going up?
    je blinky_try_up            ; Don't reverse
    
    ; Test moving down
    mov al, dl
    mov bh, dh
    inc bh                      ; Try Y+1
    call is_valid_maze_position
    cmp cl, 1
    jne blinky_try_up           ; Can't go down
    
    ; Move down
    mov byte ptr [blinky_direction], 2
    inc byte ptr [blinky_maze_y]
    jmp blinky_movement_done
    
blinky_try_up:
    ; Don't reverse from down to up
    cmp [blinky_direction], 2   ; Was going down?
    je blinky_try_any_direction ; Don't reverse
    
    ; Test moving up
    mov al, dl
    mov bh, dh
    dec bh                      ; Try Y-1
    call is_valid_maze_position
    cmp cl, 1
    jne blinky_try_any_direction ; Can't go up
    
    ; Move up
    mov byte ptr [blinky_direction], 1
    dec byte ptr [blinky_maze_y]
    jmp blinky_movement_done
    
blinky_try_any_direction:
    ; STEP 3: Emergency - try any valid direction except reverse
    mov si, 1                   ; Try directions 1,2,3,4
    
blinky_any_loop:
    cmp si, 5
    jnge blink_movement_isnt_done    ; No valid moves found
	jmp blinky_movement_done
blink_movement_isnt_done:
    ; Skip reverse directions
    mov al, [blinky_direction]
    cmp al, 1                   ; Was going up?
    jne blinky_not_up_reverse
    cmp si, 2                   ; Trying down?
    je blinky_next_any_direction ; Skip reverse
blinky_not_up_reverse:
    cmp al, 2                   ; Was going down?
    jne blinky_not_down_reverse
    cmp si, 1                   ; Trying up?
    je blinky_next_any_direction ; Skip reverse
blinky_not_down_reverse:
    cmp al, 3                   ; Was going left?
    jne blinky_not_left_reverse
    cmp si, 4                   ; Trying right?
    je blinky_next_any_direction ; Skip reverse
blinky_not_left_reverse:
    cmp al, 4                   ; Was going right?
    jne blinky_test_any_direction
    cmp si, 3                   ; Trying left?
    je blinky_next_any_direction ; Skip reverse
    
blinky_test_any_direction:
    ; Test direction SI
    mov al, dl
    mov bh, dh
    
    cmp si, 1                   ; Up?
    jne blinky_test_down_any
    dec bh
    jmp blinky_check_any_valid
    
blinky_test_down_any:
    cmp si, 2                   ; Down?
    jne blinky_test_left_any
    inc bh
    jmp blinky_check_any_valid
    
blinky_test_left_any:
    cmp si, 3                   ; Left?
    jne blinky_test_right_any
    dec al
    jmp blinky_check_any_valid
    
blinky_test_right_any:
    ; Must be right
    inc al
    
blinky_check_any_valid:
    call is_valid_maze_position
    cmp cl, 1
    jne blinky_next_any_direction ; Invalid
    
    ; Valid direction found - update position
    mov bx, si
    mov [blinky_direction], bl
    
    cmp si, 1                   ; Up?
    jne blinky_any_not_up
    dec byte ptr [blinky_maze_y]
    jmp blinky_movement_done
    
blinky_any_not_up:
    cmp si, 2                   ; Down?
    jne blinky_any_not_down
    inc byte ptr [blinky_maze_y]
    jmp blinky_movement_done
    
blinky_any_not_down:
    cmp si, 3                   ; Left?
    jne blinky_any_not_left
    dec byte ptr [blinky_maze_x]
    jmp blinky_movement_done
    
blinky_any_not_left:
    ; Must be right
    inc byte ptr [blinky_maze_x]
    jmp blinky_movement_done
    
blinky_next_any_direction:
    inc si
    jmp blinky_any_loop
    
blinky_movement_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
move_blinky_toward_target endp

;-----------------------------------------------------
; check_player_blinky_collision - Checks if Pac-Man and Blinky sprites overlap
; Returns 1 in AL if collision detected, 0 otherwise
;-----------------------------------------------------
check_player_blinky_collision proc near
    push bx
    push cx
    push dx
    
    ; Calculate distance between sprite centers
    mov ax, [player_x_pos]
    add ax, 6               ; Player center X
    mov bx, [blinky_x_pos]
    add bx, 6               ; Blinky center X
    sub ax, bx              ; X difference
    
    ; Get absolute value of X difference
    cmp ax, 0
    jge @positive_x_diff
    neg ax                  ; Make positive
@positive_x_diff:
    mov cx, ax              ; Save X difference
    
    ; Calculate Y difference
    mov ax, [player_y_pos]
    add ax, 6               ; Player center Y
    mov bx, [blinky_y_pos]
    add bx, 6               ; Blinky center Y
    sub ax, bx              ; Y difference
    
    ; Get absolute value of Y difference
    cmp ax, 0
    jge @positive_y_diff
    neg ax                  ; Make positive
@positive_y_diff:
    mov dx, ax              ; Save Y difference
    
    ; Check if collision (both distances less than 10 pixels)
    cmp cx, 10
    jge @no_collision
    cmp dx, 10
    jge @no_collision
    
    ; Collision detected
    mov al, 1
    jmp @collision_exit
    
@no_collision:
    mov al, 0
    
@collision_exit:
    pop dx
    pop cx
    pop bx
    ret
check_player_blinky_collision endp


;-----------------------------------------------------
; exit_and_cls - Exits to DOS and clears screen
;-----------------------------------------------------
exit_and_cls proc near
    call ExitGraphic  ; Return to text mode
    mov ax, 4C00h     ; DOS exit function
    int 21h           ; Call DOS
    ret               ; This will never execute
exit_and_cls endp


;-----------------------------------------------------
; run_game - Main game loop with initialization and gameplay
; Handles maze drawing, entity initialization, and the core game loop
; Includes Blinky AI, collision detection, and game state management
;-----------------------------------------------------
run_game proc near
    call SetGraphic
    call DrawMaze     
    call maze_to_screen_blinky
    
    push ax
    push cx
    push di
    push es
    
    push ds
    pop es
    mov cx, 21*21
    mov di, offset coins_collected
    mov al, 0
    cld
    rep stosb
    
    pop es
    pop di
    pop cx
    pop ax
    
    call DrawCoins
    
    mov word ptr [current_score], 0
	mov word ptr [blinky_draw_mode], 0
    mov word ptr [blinky_mode_timer], 0
    mov byte ptr [blinky_mode], 0
    
    call draw_player_improved
    call draw_blinky
    call check_coin_collision
    
game_loop:
    call restore_background
    
    mov ax, [player_x_pos]
    push ax
    mov ax, [player_y_pos]
    push ax
    
    call check_input
    
    call update_blinky
    
    call check_player_blinky_collision
    cmp al, 1
    je game_over
    
    call check_coin_collision
    
    call update_animation
    
    call draw_player_improved
    
    call draw_blinky
    
    call display_score
    
    mov cx, 1
delay_loop:
    push cx
    mov cx, 5000
inner_delay:
    loop inner_delay
    pop cx
    loop delay_loop
    
    call vsync
    
    jmp game_loop
    
game_over:
    call ExitGraphic
    mov ax, 4c00h
    int 21h
    
    ret
run_game endp


start:
   mov ax, @data
   mov ds, ax
   call SetGraphic
   call draw_menu
   call handle_menu_input 
   
END start
