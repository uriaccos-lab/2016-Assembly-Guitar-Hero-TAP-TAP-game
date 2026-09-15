# 2016-Assembly-Guitar-Hero-TAP-TAP-game
 Guitar Hero/ TAP TAP like game built in the assembly language
In order to run the game you need DOSBOX and to change directory to the game file,\
for this, write the following commands in the DOSBOX CONSOLE:
Mount c: c:\ \
c: \
cd assembly\
cd tasm\
cd new\
tasm /zi GuitarM.asm\
tlink /v GuitarM.obj \
GuitarM.exe\

NOTE: in this example of commands the file of the game "GuitarM.asm" was placed at "C:\assembly\tasm\new"



https://github.com/user-attachments/assets/2f8954fc-16c0-4563-97d9-39d2e3480651

**General Logic**
The general logic involves checking for a key press, then verifying whether the key is currently held down (to prevent cheating by keeping the key pressed to rack up points). If a key is pressed, the game state is updated to reflect a hit or a miss; if no key is pressed, the game proceeds to the next step. The game ends—and the score is displayed—upon three misses, the end of the song, or pressing the Esc key.\
**Implementation details:**\
The following are utilized, with one modification:\
Variables X and Y represent the starting positions of the fixed squares and the starting positions for drawing the fixed letters upon those squares.\
The `color` array stores the colors for the letter outlines and the fixed squares; its size is one byte, corresponding to the 256 colors available in the graphics mode used (where the maximum value is represented by 8 bits, or one byte).\
Variables `gamex` and `gamey` represent the position of the square moving across the screen.\
A loop variable represents the duration of the visual line or the sound.\
A score variable tracks the current score.\
The `scancode` variable stores the scan code of the key that was pressed.\
The `missc` variable counts the number of misses.\
Variables track whether a key is currently pressed and whether a previously pressed key has been released. The `yonatankarr` array represents the x-coordinates of the squares descending from the top of the screen in sequence.\
The `yonatansarr` array represents the constants displaying characters arranged according to the sequence of the song "Yonatan HaKatan."\
The `yonatansparr` array represents the note duration—the value multiplied by 0.055 seconds.\
The filename variable represents the image's filename.\
The ranking header is a 54-byte header indicating that the file is a BMP.\
The value table is designed to store the image colors and transfer them to the palette in memory.\
The `ScrLine` variable indicates the number of screen lines for the BMP image printing procedure.\
**Graphics design:**\
There is a procedure that draws a horizontal line. It is used to create a square when called repeatedly; an initial X-value is set, and the Y-value increases after a line is completed. This procedure is also used as part of writing the fixed characters on the screen. There are also procedures for diagonal lines (in both directions), where the X and Y values ​​increase or decrease with the drawing of each pixel.\
I split the procedures for the fixed squares and the moving squares: one procedure handles the fixed squares, and another handles the squares moving from the top of the screen. The procedures for the fixed squares and the characters do not accept parameters. I wrote two procedures for clearing the screen: one that clears the entire screen, and one that clears everything except the area containing the fixed squares.\

**List of Actions**
Square - Square\
The procedure draws a square\
Input: Starting position (X, Y), color, and size\
Output: A drawn square

Horizontal line - horizontaline\
The procedure draws a horizontal line\
Input: Starting position (X, Y), color, and size\
Output: A drawn horizontal line

Vertical line - verticaline\
The procedure draws a vertical line\
Input: Starting position (X, Y), color, and size\
Output: A drawn vertical line

Diagonal line - slant\
The procedure draws a diagonal line\
Input: Starting position (X, Y), color, and size\
Output: A drawn diagonal line

Diagonal line (opposite direction) - reverseslant\
The procedure draws a diagonal line\
Input: Starting position (X, Y), color, and size\
Output: A drawn diagonal line

Play miss sound - missnd\
Input: The program detects whether the player hit or missed\
Output: Plays a "miss" sound

Play song-segment sound - gamesound
Input: The program detects whether the player hit or missed\
Output: Plays a sound corresponding to the notes in the array

Clear screen - clrscr2\
The procedure clears the entire screen, excluding the area starting from the fixed squares and everything below them. Input argument: None\
Output argument: The procedure clears the screen

Clear entire screen - clrals\
The procedure clears the screen\
Input argument: None\
Output argument: The procedure clears the screen

Delay - delayp\
The procedure introduces a delay for a sound that is part of the song.\
Input argument: Number\
Output argument: The procedure pauses the program for a duration of [number] × 0.055 seconds.

0.055-second delay - ms055delay\
The procedure introduces a delay—either for a "miss" sound or for the program itself—to prevent it from running too fast;\ this allows execution with `cycles=max` without the program speed becoming unmanageably high.\
Input argument: None\
Output argument: The procedure pauses the program for 0.055 seconds.

Static squares - staticsquares\
Input argument: None\
Output argument: The procedure draws four squares on the screen with X-coordinates 70, 121, 173, and 226, and a Y-coordinate of 160.

Letter A - letterA\
Input argument: None\
Output argument: The procedure draws the letter A on the leftmost static square using procedures for straight (horizontal) and diagonal lines. Letter S - letterS\
Input: None\
Output: Prints the letter S in the fixed square adjacent to the fixed square of the letter A, using procedures for straight (horizontal) and diagonal lines.

Letter D - letterD\
Input: None\
Output: Prints the letter D in the fixed square adjacent to the fixed square of the letter S, using procedures for straight (horizontal) and diagonal lines.\

Letter F - letterF\
Input: None\
Output: Prints the letter F in the fixed square adjacent to the fixed square of the letter D, using procedures for straight (horizontal) and diagonal lines.\

Game Square - gamesquare\
Input: Position X from the array\
Output: The procedure prints the "moving" square to the screen at position X from the array.\

Hit - hitp\
Input: Whether the player scored a hit or not\
Output: The procedure plays a sound that is part of the song, advances the pointer of the falling squares' X-value array to the next square, advances the sound array pointer to the next sound, increments the score by 1, and returns to the `waitforkey` label.

Miss\
Input: Whether the player hit the target or not.\
Output: The procedure checks if the player has missed three times; if so, it exits the game; otherwise, it continues. It plays a "miss" sound, advances the pointer for the array of X-coordinates of the descending squares to the next square, advances the sound array pointer to the next sound, decrements the score by 1 (if it is greater than 0), and returns to the `waitforkey` label.\
