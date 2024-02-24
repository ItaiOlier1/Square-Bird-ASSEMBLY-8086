include macros.asm  ;the macros page
IDEAL
jumps
MODEL small
STACK 100h
DATASEG
	include "var.asm"  ;the variables page
	include "masks.asm"  ;the masks page
CODESEG
	include "procs.asm"  ;the procs page
	
	
	
start:
	mov ax, @data
	mov ds, ax
	
	
;Graphic mode
	call graphicMode

														;opening screen	
openS:                                                  
;#print the opening screen:
	mov dx, offset screen1
	call printPic  ;print the picture	
	
	;wait until there is a key pressed
	mov ah, 0h
	int 16h

	
;check the key pressed:
	;check if the key is ESC:
	cmp al, 27
	jne menu
	;the key is ESC, exit the program:
	jmp exit
	
													   ;menu				   
menu:                                                  														
;#print the menu:
	mov dx, offset screen2
	call printPic  ;print the menu page	

	
wait_until_key_pressed1:
	;wait until the user will press a button:
	mov ah, 7h
	int 21h
	
;the user pressed on a key
	
	;check if the user pressed 'o' (out back to the opening screen):
	cmp al, 111
	jne check_i_pressed
	jmp openS
	
	
	;check if the user pressed 'i' (Instructions):
check_i_pressed:
	cmp al, 105
	jne check_p_pressed
	jmp instructions
	
	;check if the user pressed 'p' (play the game):
check_p_pressed:
	cmp al, 112
	jne wait_until_key_pressed1  ;if any of the keys: 'p' 'i' 'o' had pressed, wait again to a pressed key 
	
	;the pressed key is 'p', jump to "play" and start the game:
	jmp play
	
	
	
													;instructions
	
													
	;the user selected the instructions:
instructions:
	;print the instructions:
	mov dx, offset rules
	call printPic  ;print the INSTRUCTIONS

wait_until_key_pressed2:
	;wait until the user will press a button:
	mov ah, 7h
	int 21h
	
	;check if the pressed button is 'r':
	cmp al, 114
	jne wait_until_key_pressed2
	jmp menu  ;the key is 'r', return back to the menu
	
	
	
	
									;print the disqualification screen:
												
disqualifications_screen:
	mov dx, offset dis_screen
	call printPic  ;print the picture
	
	;show the score of the user from the last game:
	
	
	;set cursor location 
	xor bh, bh  ;first screen
	mov dh,10  ;the line (y)
	mov dl,15  ;the row (x)
	mov ah,2h
	int 10h
	
	;print the message(score)
	mov dx, offset score
	mov ah, 9h
	int 21h
	
	
	;set cursor location
	xor bh, bh  ;first screen
	mov dh,10  ;the line (y)
	mov dl,21  ;the row (x)
	mov ah,2h
	int 10h
	
	;print the counter of points with the new score:
	mov al, [score_counter]

	;print the score:
	call printNumber
	
	
wait_until_key_pressed3:
	;wait until the user will press a button:
	mov ah, 7h
	int 21h
	
	;check if the user pressed 'p' (play again):
check_p_pressed2:
	cmp al, 112
	jne check_r
	jmp play
	
	;check if the pressed button is 'r':
check_r:
	cmp al, 114
	jne wait_until_key_pressed3
	jmp menu  ;the key is 'r', return back to the menu
	
	
	
													;play
	
	
	;the user selected to PLAY, print the game screen with the bird, sky and ground:
	
	
play:
	
	
	call print_regular_start_screen  ;print the game's regular start screen that has the blue sky, the ground and the bird
	
	;save the last location of the bird (for the blue background)
	mov [birdPosX_blue_background], 80
	mov [birdPosY_blue_background], 149
	
	mov [bird_y], 1  ;the first location of the bird on the screen
	

print_starting_message:
;print starting message

	;set cursor location to the middle()
	xor bh, bh  ;first screen
	mov dh,10  ;the line (y)
	mov dl,4  ;the row (x)
	mov ah,2h
	int 10h
	
	;print the message(msg1)
	mov dx,offset msg1
	mov ah,9h
	int 21h
	
	jmp waitToStart
	



;wait for pressed button to start:
waitToStart: 
;wait for pressed key:
	mov ah, 7h
	int 21h
;if the key is esc:
	cmp al, 27 
	jne checkSpace
	jmp menu

checkSpace:
;if the key is space:
	cmp al, 32
	je coverMessage
	
	jmp waitToStart



;#the user selected to start the game:


coverMessage:
	;print blue square to cover the text message:
	mov dx, 80  		;the place of the line. (y)
	mov cx, 30  		;the place of the row. (x)
	mov al, 11  		;the color blue
	mov [cxFirst], cx  	;the first place on the screen(from the left)
	mov [widthS], 258  	;the width of the square
	mov [lenS], 7 		;the length of the square 
	call printSquare
	

print_a_scoreboard:

	;print the massege 'score':
	
	;set cursor location:
	xor bh, bh  ;first screen
	mov dh, 23  ;the line (y)
	mov dl, 1  ;the row (x)
	mov ah, 2h
	int 10h
	
	;print the message(score)
	mov dx, offset score
	mov ah, 9h
	int 21h
	
	;print the starting score (0):
	
	mov [score_counter], 0  ;the starting number (0)
	mov al, [score_counter]
	call printNumber
	
							;THE GAME LOOP:
	
	mov [obs_move_amount_pixels_counter], 5  ;the starting speed of the obstacle
	mov [obs_faster_counter], 0
	
gameLoop:	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;now after the user pressed on the space key, there are three main things
	;that happen in the same time:
	;1- print and move obstacles
	;2- move the bird and print the egg after pressing the space key
	;3- check if an obstacle touch an egg and after it passed the egg, print the bird and the eggs that are above the obstacle down

;print obstacle:


	;chose obstacle's location (y) by a random number (1-10):
	call random
	
	
	mov al, [random_number]
	cmp al, [last_random_number]
	je gameLoop
	mov [last_random_number], al  ;[last_random_number] gets the random number for the next cmp

	;set the first location of the obstacle on the screen by the random number:

	mov bx, 0
	mov [obs_last_location], 53104  ;the starting location before when [random_number] = 1 ("when [random_number] = 0")
set_the_first_location:
	sub [obs_last_location], 5120  ;set the next starting place
	inc bx  ;the new number to check
	cmp [random_number], bl  ;check if the two (y) locations(numbers) are the same number
	jne set_the_first_location  ;if the (y) place and the random number aren't equals, check the next location
	
	;the numbers are equals, set locations
	mov [obs_y], bx
	mov ax, [obs_last_location]
	mov [obs_first_location], ax


	

;the loop of moving the obstacle:

	
obstacle_loop:
	

	;move the last saved location of the obstacle to [newPos]
	;check the last location of the obstacle
	mov ax, [obs_last_location]
	mov [newPos], ax
	
;print a blue square to cover the last obstacle:
	
	call print_blue_background_cover_obs
	
	xor ax, ax
	mov al, [obs_move_amount_pixels_counter]
	sub [newPos], ax  ;amount of pixels to move
	

	;set size:
	mov [Hight_mask], 16
	mov [Width_mask], 16
	
	;print:
	mov si, offset obs1Mask
	call anding
	mov si, offset obs1
	call oring
	
	
	
;the delay 
	push cx
	mov cx, 1h  ;cx get the amount of time to waitLoop
	call delay
	pop cx
	
	
	;check the last location of the obstacle
check_the_last_location_of_the_obstacle:
	mov ax, [newPos]
	mov [obs_last_location], ax
	
	
	
	;check if [bird_y] and [obs_y] are the same number to make sure that there is a chance of a disqualification:
	mov ax, [bird_y]
	
	
	cmp ax, [obs_y]  ;check the gap between the two ([[bird_y],[obs_y])
	ja put_one_to_bird_and_obs_flag
	
	cmp ax, [obs_y]  ;check the gap between the two ([[bird_y],[obs_y])
	jb bird_under_obstacle
	
	cmp [obs_y], ax  ;check the gap between the two ([[bird_y],[obs_y])
	je check_flag_obs_touch_bird  	;if they aren't equals, so, there is no chance of a disqualification
	
	jmp no_disqualification    ;[bird_y] and [obs_y] are the same number. so, there is no chance of a disqualification. jump to "check_obs_touch_bird"
	
	
	
	;if the bird is above the obstacle so it isn't necessary to check if there is a disqualification (if the bird touch the obstacle)
	;that's why we put the number 1 in the flag [flag_obs_touch_bird] and it tells us that we don't need to check if there is a disqualification
put_one_to_bird_and_obs_flag:
	mov [flag_obs_touch_bird], 1
	jmp check_flag_obs_touch_bird
	
	
check_flag_obs_touch_bird:
	cmp [flag_obs_touch_bird], 0
	jnz no_disqualification
	jmp check_obs_touch_bird
	
	
	
	
	;check if there is a disqualification by checking if the obstacle is touching the bird:
	
check_obs_touch_bird:

	;check if the obstacle touch the bird in the origin:
	mov ax, [newPosBird]  ;mov to ax the location of the bird
	add ax, 4*320
	add ax, 19
	
	cmp ax, [obs_last_location]  ;cmp the location of the origin with the location of the obstacle
	jb no_disqualification
	
	;check if the obstacle passed the bird (disqualification)
	;check the possability of a disqualification when the obstacles passed the origin and touch the body of the bird
check2_bird_touch_obstacle:
	;we know that the obstacle is in a left posion from the origin but we need to check if the obstacle is touching the bird itself
	;so, we need to check the rang of the bird:
	sub ax, 19
	mov bx, [obs_last_location]
	add bx, 16  ;the length of the obstacle
	cmp bx, ax
	ja disqualification  ;if the obstacle is in the rang of the bird's head, so there is a disqualification
	;else
	mov [flag_obs_touch_bird], 1  ;there isn't a chance of a future disqualification (until the next obstacle) so put 1 in [flag_obs_touch_bird] flag
	
bird_under_obstacle:
	mov [flag_obs_touch_bird], 0
	
;check if the (y) rang between the obstacle and the bird is by 1 (obstacle is above the bird by 1), 
;and if it true so we need to print the bird again because the obstacle erased the crest
check_print_the_crest:

	;check if [bird_y] is under by 1 from [obs_y]:
	mov ax, [bird_y]
	mov bx, [obs_y]
	sub bx, ax
	cmp bx, 1
	jne not_disqualification
	
	
	;print the bird with the crest:
	;(we don't need to check the range for just printing the bird)
	
	mov ax, [newPosBird]
	mov [newPos], ax
	
	;print the bird:
	call print_bird
	
not_disqualification:	
	jmp no_disqualification
	
;if there is a disqualification, go the disqualification:
disqualification:
	;delay:
	mov cx, 3
	call delay
	
	;Back to text mode
	call textMode
	;Graphic mode
	call graphicMode
	
	jmp disqualifications_screen  ;disqualifications screen
	
	
	
no_disqualification:
	;there is no disqualification, the game can still run:
	




	
	
;check if the obstacle passed an egg and if it true, move the bird and the eggs above the obstacle down:

	;check if we need or not to do this check:
	
check_if_there_are_eggs_or_bird_above_the_obs:
	mov ax, [obs_y]  ;the (y) location of the obstacle
	cmp [bird_y], ax
	ja check_flag_obs_passed_egg  ;if the bird is above the obstacle, check if the flag says that we need to check if the obstacle passed the egg or even not to check it at all
	jmp space_bar  ;if the bird isn't above the obstacle so, the obstacle can't hit the bird's eggs

check_flag_obs_passed_egg:
	cmp [flag_obs_passed_egg], 0  ;if the flag is 0, we need to check if the obstacle passed the egg
	jnz space_bar  ;if the flag isn't 0, check the space bar (if it pressed by the user)
	jmp check_if_the_obs_passed_the_egg


;check if the obstacle passed an egg:
check_if_the_obs_passed_the_egg:
	;ax has the location to check, cmp [obs_last_location] with ax and move the bird and the eggs above the obstacle down:
	mov ax, [obs_first_location]
	sub ax, 242
	cmp [obs_last_location], ax  ;cmp the obstacle location with the location that comes after the egg
	ja space_bar
	mov [obstacle_saved_place_for_eggs], ax
	jmp move_bird_and_eggs_down
	
	






	
move_bird_and_eggs_down:
	
	;now we got to the part we have the amount of eggs that are above the obstacle + the egg that was in the obstacle's line
	mov [flag_obs_passed_egg], 1  ;now we will move the bird down but we change the flag for the next time because next time we won't have to check and move the bird down (until the next obstacle)
	
	
	
	
	
	;check how many eggs are above the obstacle:
	mov ax, [obs_y]
	mov bx, [bird_y]
	dec bx  ;sub the head of the bird from the sum and then bx will have the amount of the eggs that are on the screen
	
	sub bx, ax  ;"the amount of the eggs on the screen" - "obstacle y posion" = the amount of eggs that are only above the obstacle
	mov [counter_eggs_above], bl  ;[counter_eggs_above] gets the amount of eggs that above the obstacle
	

	;if there are no eggs above the obstacle and only the bird is above the obstacle, inc the counter by 1
	cmp [counter_eggs_above], 0
	jnz cover_eggs_and_bird_blue
	
	;print the counter of points with the new score because: by the ruls, if the bird is stepping on the obstacle itself, 
	;we need to add 1 to the counter:
	
	;set the cursor location on the screen:
	xor bh, bh  ;first screen
	mov dh, 23  ;the line (y)
	mov dl, 7  ;the row (x)
	mov ah, 2h
	int 10h
	
	;add one to [score_counter]
	inc [score_counter]  ;only the bird is above the obstacle, add 1 to the counter of points
	mov al, [score_counter]

	;print the score:
	call printNumber
	
	
	
	
	
cover_eggs_and_bird_blue:
	
	;the algorithm of this covering the bird with blue background is happend by useing [birdPosY_blue_background] that saves the (y) location 
	;of the last crest of the bird (the top of his head before the space bar pressed)
	;that's why when we want to chose the current location of the head we need to sub from [birdPosY_blue_background] 4 pixles to move the location 4 pixels up and
	;then we need to print the blue square by the amount of eggs that are above the obstacle (and if there are no eggs above, cover just the bird)
	
	;print a blue square to cover the obstacls and the bird that are above the obstacle:
	
	mov cx, 80  ;the place in the line (row 'x') where the bird is
	mov dx, [birdPosY_blue_background]  ;the place of the line. (y)
	sub dx, 4  
	xor bh, bh
	mov al, 11 	;the color blue
	
	
	mov cx, 80  ;the place in the line (row 'x')
	mov [cxFirst], cx  	;the first place on the screen(from the left)
	mov [widthS], 20  	;the width of the square
	
	;the length of the square
	push ax
	
	xor ax, ax
	mov al, [counter_eggs_above]
	shl al, 4  ;[counter_eggs_above]*16
	add ax, 20
	mov [lenS], ax 		;the length of the square 
	
	pop ax
	
	
	call printSquare  ;print the blue square
	
	;check if there are eggs in [counter_eggs_above]
	cmp [counter_eggs_above], 0
	je move_bird_down  ;if there aren't, print just the bird again in the new location
	
	
	;there are eggs in [counter_eggs_above]
	;so print the eggs (one after another):
	
	;the algorithm is printing the eggs one after another by a loop that happens [counter_eggs_above] times
	;at the first time before the loop begins, we set the (x) location , and after that in the actual loop we only change the y location and
	;print an egg each time
	
	xor cx, cx
	mov cl, [counter_eggs_above]  ;cx is the counter of the loop so, move [counter_eggs_above] to cx
	jmp move_eggs_down_init

	
move_eggs_down_init:  ;set the first (x) location to print the eggs, happens once (at the first time of the loop)


	;set the location to the place of the egg
	mov ax, [obs_first_location]
	sub ax, 224
	mov [newPos], ax
	jmp move_egg_down1
	
move_eggs_down:	;set the (x) location to print the egg
	sub ax, 5120
	mov [newPos], ax  ;the current locationto print the egg
	
move_egg_down1: 
;print the egg in the new location: 
	;the size of the egg
	mov [Hight_mask], 16
	mov [Width_mask], 16
	
	;print the egg
	mov si, offset eggMask
	call anding
	mov si, offset egg
	call oring
	
	loop move_eggs_down
	
	
	
	
	;print the bird down:
	
move_bird_down:
	mov ax, [newPosBird]
	add ax, 16*320  ;move the location 16 pixels down
	mov [newPos], ax
	
	
	;print the bird:
	call print_bird
	
	;set [birdPosY_blue_background] down by 16 pixels
	add [birdPosY_blue_background], 16
	
	
	mov ax, [newPos]
	mov[newPosBird], ax
	dec [bird_y]
	jmp space_bar
	
	





	



;check if there is a pressed key by the user:


space_bar:
;check if there is a pressed key:
	mov ah, 0Bh
	int 21h
	
	cmp al, 0 			;if the key is pressed, al get's 0FFh, else, al get's 0
	jne key_check1  	;if the key has pressed, jump to "key_check1"
	
	;the key hasn't pressed, don't print the bird and the egg and check the obstacle's 
	;loop by jumping to: "check_obs_loop"
	jmp check_obs_loop  

;there is a key pressed, check what key had pressed:
key_check1:	
	;check what is the key:
	mov ah, 7h
	int 21h

	;if the key is esc:
	cmp al, 27 
	jne check_SpaceBar  ;if the pressed key isn't ESC, check the second key: SPACE BAR (jump to "check_SpaceBar")
	
	;the key is ESC, close the program:
	call textMode
	call graphicMode
	jmp menu  ;go back to the menu if the user pressed esc
	
	
	
	
;check if the key pressed is the SPACE BAR:
	
check_SpaceBar:	
;check if the key is the space bar:
	cmp al, 20h
	jne checkObsLoop  ;if the key isn't the SPACE BAR, so it means nothing for the game.
					  ;don't print the bird and the egg and ,check the obstacle's loop by jumping to: "checkObsLoop" (from there to: "check_obs_loop")
	
	
	;the SPACE BAR pressed, jump to "space_bar_pressed"
	jmp space_bar_pressed 
	
	;the space bar didn't press
checkObsLoop: 
	jmp check_obs_loop
	


;the space bar pressed, move the bird one step upwards and print the egg under the bird:
	
space_bar_pressed:
;check the last location of the obstacle
	mov ax, [newPos]
	mov [oldPos], ax


 	
;#the key pressed is the space bar, move the bird upwards and print the egg:
	
	;check if the bird got to the top of the screen:
	cmp [newPosBird], 500
	jae cover_bird_blue
	
	;the location of the bird is at the top of the screen
	jmp check_obs_loop
	
cover_bird_blue:
	;cover the bird with blue background before moving the bird to the next place
	mov dx, [birdPosY_blue_background]  ;the place of the line. (y)
	sub dx, 5 			
	mov cx, [birdPosX_blue_background]  ;the place of the row. (x)
	mov al, 11 		  	;the color blue
	mov [cxFirst], cx  	;the first place on the screen(from the left)
	mov [widthS], 20  	;the width of the square
	mov [lenS], 20 		;the length of the square 
	call printSquare
	
	
	
	
;Move the bird upwards:
;#PRINT the white BIRD by using mask:
	
	;save the last location for the next egg:
	mov ax, [newPosBird]
	add ax, 1280  ;320*4 (four pixels up)
	mov [newPosEgg], ax
	
;move the bird upwards and PRINT THE BIRD:

	mov ax, [newPosBird]
	sub ax, 5120  ;320*16 (16 pixels up)
	mov [newPosBird], ax  ;the new location
	mov [newPos], ax
	
	;print the bird:
	call print_bird
	
	
	inc [bird_y]  ;increase the bird's location (y) for the disqualification's check with an obstacle
	
	;save the next location for the blue sky's printing (Y)
	sub [birdPosY_blue_background], 16  ;save the location (that saves space for the printing egg) for the blue sky's printing (Y)
	
	
;print the egg:
	mov ax, [newPosEgg]
	mov [newPos], ax
	
	;the size of the egg
	mov [Hight_mask], 16
	mov [Width_mask], 16
	
	;print the egg
	mov si, offset eggMask
	call anding
	mov si, offset egg
	call oring
	
	
play_sound_beep:	
	;play the jump sound of the bird  ("beep"):
	call speackerOn  ;turning on the speacker and changeing the frequency before playing	
	mov ax,[beep_jump_sound]
	call playSound
	call delay1
	call speackerOff
	




;check the obstacles loop:
;check if the obstacle got to the left end of the screen: 
check_obs_loop:
	mov bx, [obs_first_location]
	sub bx, 300  ;almost the left end of the screen
	add bx, [obs_faster_counter]  ;we don't want the obstacle to start over in the right corner so we add to the finishing location the amount of pixels that the obstacle moves each time
	add bx, 8
	cmp [obs_last_location], bx
	ja obstacle_loop  ;continue the obstacle loop if the obstacle didn't get to the left end of the screen
	;the obstacle loop is over
	jmp obs_loop_over
	
	
	
	
	
	
	
	
obs_loop_over:
;;;;;;;;;;;;;;;;;;;;


	;get the obs out of the screen":
	mov ax, [obs_last_location]
	mov [newPos], ax
	
	call print_blue_background_cover_obs
	
	
	;set new checks for the next obstacle:  (init the flag)
set_new_check_for_obstacle_touch_egg:
	mov [flag_obs_passed_egg], 0  ;new check for a new obstacle
	mov [flag_obs_touch_bird], 0	;new check for a new obstacle
	
	
	
	;check the [obs_faster_counter] to see if the next obstacles need to move faster:
	cmp [obs_move_amount_pixels_counter], 20
	jae gameLoop_jmp
	
	inc [obs_faster_counter]
	cmp [obs_faster_counter], 4  ;amount of obstacles until the obstacle gets faster
	jne gameLoop_jmp
	mov [obs_faster_counter], 0
	add [obs_move_amount_pixels_counter], 1
	

	
	
gameLoop_jmp:
	jmp gameLoop  ;the game won't over until the user will be disqualified
	
ended_game:
	;wait until there is a key pressed
	mov ah, 0h
	int 16h
	
	
exit:
	call textMode
	mov ax, 4c00h
	int 21h
END start