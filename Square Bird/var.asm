
						;the variables of the game: SQUARE BIRD


;screens:
	screen1 db 'screen1.bmp',0  ;screen1, starting screen
	screen2 db 'screen2.bmp',0  ;screen2, menu
	rules db 'rules.bmp',0      ;screen3, the rules of the game
	dis_screen db 'dis_scr.bmp',0  ;screen4, disqualification screen
	
;BMP
	filehandle dw ?  ;handle for bmp file
    Header db 54 dup (0)  ;header for bmp file
    Palette db 256*4 dup (0)  ;bmp color palette
    ScrLine db 320 dup (0)  ;saves line of pixels to copy from bmp image to screen
    ErrorMsg  db 'Error in open file', 13, 10,'$'  ;message if the bmp image printing failed
	picWidth dw 320  ;the width of the picture
	picHigh dw 200  ;the high of the picture
	leftGap dw 0  ;the distance from the left corner
	topGap dw 0  ;the distance from the top corner
	
;messages:
	msg1 db 'Press on the space bar to start:',13,10,'$'  ;message 1, showes that the user has to press on the space bar to start to play
	score db 'score:$'  ;the message: "score"
	
	
	
;counter of the score:
	divisorTable db 10,1,0  ;used to div&mod (at this code to random number)
	score_counter db ?  ;counter of points
	
	
;printing a square on screen:
	cxFirst dw ?  ;the first pixel's location in the line
	;amount of pixels in line and row:
	widthS dw 320  ;the amount of dots/pixels in each line (width square)
	lenS dw 200  ;the amount of lines in the square (len square)
	

;sound:
	beep_jump_sound dw 3418  ;1193180/349  ;the sound of every time that the bird jumps



;counter that every "amount of times/ obstacles" make the obstacles to move faster:
	obs_faster_counter dw 0

;the amount of steps of the obstacle each time:
	obs_move_amount_pixels_counter db 2

;(flags):	

	;checking if obstacle passed the egg:
	flag_obs_passed_egg db 0
	
	;checking if obstacle touch the bird:
	flag_obs_touch_bird db 0  ;if it has 1, we don't need to check if there is a disqualification, if it has 0 so we do need to check if there is a disqualification

	
;variable of saving the place that the obstacle passed the egg -20
	obstacle_saved_place_for_eggs dw ?
	
	
	;the bird's mask:
	newPosBird dw ?       ;the new possion of the bird 

				
	;the eggs mask:
	
	newPosEgg dw ?     ;the new possion of the egg
	
;counter of eggs:
	counter_eggs_above db 0 ;the amount of eggs that are above the obstacle
	

	
	
	
	
;anding and oring:
	newPos dw ?  ;the new position to print the mask
	oldPos dw ?  ;the last positon of the mask
	Hight_mask dw ?  ;the hight of the mask (pixels)
	Width_mask dw ?  ;the width of the mask (pixels)
		
	
			
;the blue background's location whos printed to cover the bird 			
	birdPosX_blue_background dw 80  ;the blue background's (x) location whos printed to cover the bird
	birdPosY_blue_background dw 149  ;the blue background's (y) location whos printed to cover the bird
	
;timer
	Clock equ es:6Ch  ;the clock of the computer (now it called "clock")
	
;random number:
	random_number db 0 ;a random number
	last_random_number db 0  ;the last random number
	
;obstacles:
	obs_last_location dw 0 ;the last location of the obstacle
	obs_first_location dw ? ;obstacle first location

	
	;check obstacle's location (y) from 10 parts of the screen:
	obs_y dw 1  ;obstacle y from 1-10
	
	;check bird's location (y) from 10 parts of the screen:
	bird_y dw 1  ;bird y from 1-10
	
	
	
	
	



