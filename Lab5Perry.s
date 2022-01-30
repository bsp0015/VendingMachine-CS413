@ File: Lab5Perry.s
@ Author: Brandon S. Perry
@ Email: bsp0015@uah.edu
@ Course: CS413-01 Fall 2021
@ History:
@	10-31-2021   File Created
@ Purpose: 
@	Simulate the operation of a vending machine
@	Now with added led interaction
@		Power on - red 5 seconds
@		Power off - red 5 seconds
@	Red Button - Gum dispensed - red flashes 3 seconds (1 second on 1 second off) and then
@				 stay on for 5 seconds
@	Yellow Button - Peanuts dispensed - yellow flashes 3 seconds (1 second on 1 second off) and then
@				    stay on for 5 seconds
@	Green Button - Cheese Crackers dispensed - green flashes 3 seconds (1 second on 1 second off) and then
@				   stay on for 5 seconds
@	Blue BNutton - M&Ms dispensed - blue flashes 3 seconds (1 second on 1 second off) and then
@				   stay on for 5 seconds
@
@	Machine will dispense, upon reception of correct amount of money, a choice of
@		Gum, Peanuts, Cheese Crackers, or M&Ms
@
@ Requirements:
@	1 - Display a welcome message and instructions
@	2 - Set the initial inventory to two (2) of each kind
@	3 - Prompt the user for item selection (G, P, C, M). Reject invalid input
@	4 - Confirm customers selection (Y/N)
@	5 - Prompt the user for amount to enter (Enter at least ...)
@	6 - Accept money input of dimes (D), quarters (Q), and one-dollar bills (B)
@	7 - If customer selects and out of inventory item, prompt to make another selection
@	8 - Vending machine will shut down if entire inventory reaches zero
@	9 - Assume there is no limit to amount of change vending machine has
@	10 - Make provisions for a secret code that when entered will display current inventory (A)
@
@ Use these commands to assemble, link, run, and debug the program
@
@   as -o Lab5Perry.o Lab5Perry.s
@   gcc -o Lab5Perry Lab5Perry.o -lwiringPi
@   ./Lab5Perry ;echo $?
@   gdb --args ./Lab5Perry
@

OUTPUT = 1		@ used to set the selected GPIO pins to ouptut only
INPUT = 0		@ used to set the selected buttions to input

PUD_UP = 2
PUD_DOWN = 1

LOW = 0			@ position of button low
HIGH = 1		@ position of button high

.equ READERROR, 0	@ used to check for scanf read error

.global main		@ have to use main because of C library

main:			@ label used to start executing code

@
@ Check the setup of the GPIO
@
   bl wiringPiSetup	@ r0 contains the pass/faile code
   mov r1, #-1
   cmp r0, r1
   bne init		@ everything is okay with code
   ldr r0, =ErrMsg
   bl printf
   b exit		@ there is a problem with the GPIO so exit code

@
@ Set four of the GPIO pins to output
@

init: 
@ set the pin 2 mode to output red?
   ldr r0, =pin2 
   ldr r0, [r0]
   mov r1, #OUTPUT
   bl pinMode

@ set the pin 3 mode to output yellow?
   ldr r0, =pin3 
   ldr r0, [r0]
   mov r1, #OUTPUT
   bl pinMode

@ set the pin 4 mode to output green?
   ldr r0, =pin4 
   ldr r0, [r0]
   mov r1, #OUTPUT
   bl pinMode

@ set the pin 5 mode to output blue?
   ldr r0, =pin5 
   ldr r0, [r0]
   mov r1, #OUTPUT
   bl pinMode


@
@ Set four of the buttons to input
@

buttonInit:
@ set the mode to input - Blue
   ldr r0, =buttonBlue
   ldr r0, [r0]
   mov r1, #INPUT
   bl pinMode

@ set the mode to input - Green
   ldr r0, =buttonGreen
   ldr r0, [r0]
   mov r1, #INPUT
   bl pinMode

@ set the mode to input - Yellow
   ldr r0, =buttonYellow
   ldr r0, [r0]
   mov r1, #INPUT
   bl pinMode

@ set the mode to input - Red
   ldr r0, =buttonRed
   ldr r0, [r0]
   mov r1, #INPUT
   bl pinMode


@
@ Setup and read all of the buttons
@ Set the buttons for pull-up and it is 0 when pressed
@

   ldr r0, =buttonBlue
   ldr r0, [r0]
   mov r1, #PUD_UP
   bl pullUpDnControl

   ldr r0, =buttonGreen
   ldr r0, [r0]
   mov r1, #PUD_UP
   bl pullUpDnControl

   ldr r0, =buttonYellow
   ldr r0, [r0]
   mov r1, #PUD_UP
   bl pullUpDnControl

   ldr r0, =buttonRed
   ldr r0, [r0]
   mov r1, #PUD_UP
   bl pullUpDnControl


@
@ Program starts so red light comes on for 5 seconds
@

@ turn on pin5
   ldr r0, =pin5
   ldr r0, [r0]
   mov r1, #1
   bl digitalWrite

@ delay for five seconds
   ldr r0, =delayFive
   ldr r0, [r0]
   bl delay

@ turn off pin5
   ldr r0, =pin5
   ldr r0, [r0]
   mov r1, #0
   bl digitalWrite
   


@ Initialize inventory values for each product
   mov r6, #2	@ Gum
   mov r7, #2	@ Peanuts
   mov r8, #2	@ Cheese Crackers
   mov r9, #2	@ M&Ms
   mov r10, #0  @ Running money total


@
@ Part 1 - Print welcome message and provide vending machine prices
@
welcome:

   ldr r0, =strWelcome	@ put address of welcome message into first parameter
   bl printf		@ display message


@
@ Part 2 - Prompt user to select an item from vending machine and get input
@	   Verify user input and branch appropriatly
@	   Exit code if all inventory is empty

prompt:

   mov r10, #0			@ reset running total to 0
   mov r11, #0			@ set r11 (counter) to 0

   cmp r6, #0			@ see if gum is empty
   addeq r11, r11, #1		@ increment counter by one if empty

   cmp r7, #0			@ see if peanuts is empty
   addeq r11, r11, #1		@ increment counter by one if empty

   cmp r8, #0			@ see if cheese is empty
   addeq r11, r11, #1		@ increment counter by one if empty

   cmp r9, #0			@ see if m&ms is empty
   addeq r11, r11, #1		@ increment counter by one if empty

   cmp r11, #4			@ see if all inventory is empty
   beq exitEmpty		@ exit program letting user know everything is empty

   ldr r0, =strCost		@ put address of cost message into first parameter
   bl printf			@ display message

   ldr r0, =strInputPrompt	@ put address of input prompt into first parameter
   bl printf			@ display input prompt

   ldr r0, =strInputPrompt2	@ let user know how to quit
   bl printf			@ display to screen

   b getInput			@ branch to get input

rePrompt:

   ldr r0, =strRePrompt		@ put address of invalid value prompt into first parameter
   bl printf			@ display input prompt
   b getInput			@ branch to get input

getInput:

@   ldr r0, = userInputPattern	@ setup to read in one letter
@   ldr r1, = userInput		@ load r1 with the address of where the input value will be stored
@   bl scanf			@ scans the keyboard
@   cmp r0, #READERROR		@ check for a read error
@   beq readerror		@ handle it if there was an error
@   ldr r1, =userInput		@ read the contents of userInputer and store in r1 so it can be printed
@   ldr r1, [r1]
@   mov r4, r1			@ mov contents of r1 into r4 to use for compare for reprompting

@ Start loop to read all buttons
buttonLoop:

   mov r2, #0xff
   mov r4, #0xff
   mov r5, #0xff
   mov r10, #0xff

   ldr r0, =delayHalf
   ldr r0, [r0]
   bl delay

readBlue:
   
   ldr r0, =buttonBlue
   ldr r0, [r0]
   bl digitalRead
   cmp r0, #HIGH	@ button is HIGH read next button
   moveq r2, r0		@ set the last time read value to HIGH
   beq readGreen		 

   cmp r2, #LOW		@ was last time called also down?
   beq readGreen	@ button is still down read next button value

   mov r2, r0		@ there is a new button press
   b mmVerify		@ branch to verify MM choice

readGreen:

   ldr r0, =buttonGreen
   ldr r0, [r0]
   bl digitalRead
   cmp r0, #HIGH	@ button is HIGH read next button
   moveq r5, r0		@ set the last time read value to HIGH
   beq readYellow		 

   cmp r5, #LOW		@ was last time called also down?
   beq readYellow	@ button is still down read next button value

   mov r5, r0		@ there is a new button press
   b cheeseVerify	@ branch to verify cheese crackers choice

readYellow:

   ldr r0, =buttonYellow
   ldr r0, [r0]
   bl digitalRead
   cmp r0, #HIGH	@ button is HIGH read next button
   moveq r4, r0		@ set the last time read value to HIGH
   beq readRed		 

   cmp r4, #LOW		@ was last time called also down?
   beq readRed		@ button is still down read next button value

   mov r4, r0		@ there is a new button press
   b peanutVerify	@ branch to verify peanuts choice

readRed:

   ldr r0, =buttonRed
   ldr r0, [r0]
   bl digitalRead
   cmp r0, #HIGH	@ button is HIGH read next button
   moveq r10, r0	@ set the last time read value to HIGH
   beq buttonLoop		 

   cmp r10, #LOW	@ was last time called also down?
   beq buttonLoop	@ button is still down read next button value

   mov r10, r0		@ there is a new button press
   b gumVerify	@ branch to verify peanuts choice


selectionCmp:

   cmp r4, #0x47	@ compare user input with G
   beq gumVerify	@ branch to verify user input if equal

   cmp r4, #0x50	@ compare user input with P
   beq peanutVerify	@ branch to verify user input if equal

   cmp r4, #0x43	@ compare user input with C
   beq cheeseVerify	@ branch to verify user input if equal

   cmp r4, #0x4d	@ compare user input with M
   beq mmVerify		@ branch to verify user input if equal 

   cmp r4, #0x41	@ compare user input with A - secret code
   beq inventory	@ branch to verify user input if equal 

   cmp r4, #0x51	@ compare user input with Q - quit
   beq exit		@ exit program

   b readerror		@ branch to readerror if invalid input


@
@ Part 3 - Verify user's input selection and get input of yes or no
@	   Verify the Y/N selection
@
out:

   ldr r0, =strOut	@ let user know item is empty
   bl printf		@ display to screen

   b prompt		@ branch for new input

reSelectionPrompt:

   ldr r0, =strReSelectionPrompt	@ put address of invalid value prompt into first parameter
   bl printf				@ display input prompt
   	
   cmp r4, #0x47			@ compare user input with G
   beq gumVerify			@ branch to verify user input if equal

   cmp r4, #0x50			@ compare user input with P
   beq peanutVerify			@ branch to verify user input if equal

   cmp r4, #0x43			@ compare user input with C
   beq cheeseVerify			@ branch to verify user input if equal

   cmp r4, #0x4d			@ compare user input with M
   beq mmVerify				@ branch to verify user input if equal 


gumVerify:
   mov r10, #0
   mov r4, #0x47

   cmp r6, #0			@ check gum inventory 
   ble out			@ branch if empty

   ldr r0, = strGumSelection	@ ask user if selection is correct
   bl printf			@ display to screen

   ldr r0, = userInputPattern	@ setup to read in one letter
   ldr r1, = userInput		@ load r1 with the address of where the input value will be stored
   bl scanf			@ scans the keyboard
   cmp r0, #READERROR		@ check for a read error
   beq readerrorSelection	@ handle it if there was an error
   ldr r1, =userInput		@ read the contents of userInputer and store in r1 so it can be printed
   ldr r1, [r1]

   cmp r1, #0x59		@ compare user input with Y
   beq gumAmount		@ branch if equal to gum amount
   
   cmp r1, #0x4e		@ compare user input with N
   beq prompt			@ branch if equal to prompt

   b reSelectionPrompt		@ branch to reprompt Y/N if invalid input

peanutVerify:
   mov r10, #0
   mov r4, #0x50

   cmp r7, #0			@ check peanuts inventory 
   ble out			@ branch if empty

   ldr r0, = strPeanutSelection	@ ask user if selection is correct
   bl printf			@ diplasy to screen

   ldr r0, = userInputPattern	@ setup to read in one letter
   ldr r1, = userInput		@ load r1 with the address of where the input value will be stored
   bl scanf			@ scans the keyboard
   cmp r0, #READERROR		@ check for a read error
   beq readerrorSelection	@ handle it if there was an error
   ldr r1, =userInput		@ read the contents of userInputer and store in r1 so it can be printed
   ldr r1, [r1]

   cmp r1, #0x59		@ compare user input with Y
   beq peanutAmount		@ branch if equal to peanut amount
   
   cmp r1, #0x4e		@ compare user input with N
   beq prompt			@ branch if equal to prompt

   b reSelectionPrompt		@ branch to reprompt Y/N if invalid input

cheeseVerify:
   mov r10, #0
   mov r4, #0x43

   cmp r8, #0			@ check cheese inventory 
   ble out			@ branch if empty

   ldr r0, = strCheeseSelection	@ ask user if selection is correct
   bl printf			@ display to screen

   ldr r0, = userInputPattern	@ setup to read in one letter
   ldr r1, = userInput		@ load r1 with the address of where the input value will be stored
   bl scanf			@ scans the keyboard
   cmp r0, #READERROR		@ check for a read error
   beq readerrorSelection	@ handle it if there was an error
   ldr r1, =userInput		@ read the contents of userInputer and store in r1 so it can be printed
   ldr r1, [r1]

   cmp r1, #0x59		@ compare user input with Y
   beq cheeseAmount		@ branch if equal to cheese amount
   
   cmp r1, #0x4e		@ compare user input with N
   beq prompt			@ branch if equal to prompt

   b reSelectionPrompt		@ branch to reprompt Y/N if invalid input

mmVerify:
   mov r10, #0
   mov r4, #0x4d

   cmp r9, #0			@ check M&M inventory 
   ble out			@ branch if empty

   ldr r0, = strMMSelection	@ ask user if selection is correct
   bl printf			@ display to screen

   ldr r0, = userInputPattern	@ setup to read in one letter
   ldr r1, = userInput		@ load r1 with the address of where the input value will be stored
   bl scanf			@ scans the keyboard
   cmp r0, #READERROR		@ check for a read error
   beq readerrorSelection	@ handle it if there was an error
   ldr r1, =userInput		@ read the contents of userInputer and store in r1 so it can be printed
   ldr r1, [r1]

   cmp r1, #0x59		@ compare user input with Y
   beq mmAmount			@ branch if equal to MM amount
   
   cmp r1, #0x4e		@ compare user input with N
   beq prompt			@ branch if equal to prompt

   b reSelectionPrompt		@ branch to reprompt Y/N if invalid input


@
@ Part 4 - Prompt user to enter a coin (money) and get input
@	   Verify user input
@
rePromptMoney:

   ldr r0, =rePromptMoney	@ load r0 with address of reprompting for money
   bl printf			@ display to screen
   
   cmp r4, #0x47		@ compare user input with G
   beq gumAmountInput		@ branch to get user input if equal

   cmp r4, #0x50		@ compare user input with P
   beq peanutAmountInput	@ branch to get user input if equal

   cmp r4, #0x43		@ compare user input with C
   beq cheeseAmountInput	@ branch to get user input if equal

   cmp r4, #0x4d		@ compare user input with M
   beq mmAmountInput		@ branch to get user input if equal 

gumAmount:

   ldr r0, =strGumAmount	@ let user know how much money to enter
   bl printf			@ display to screen

gumAmountOptions:

   ldr r0, =strOptions		@ display coin options
   bl printf 			@ display to screen

gumAmountInput:

   ldr r0, = userInputPattern	@ setup to read in one letter
   ldr r1, = userInput		@ load r1 with the address of where the input value will be stored
   bl scanf			@ scans the keyboard
   cmp r0, #READERROR		@ check for a read error
   beq readerror		@ handle it if there was an error
   ldr r1, =userInput		@ read the contents of userInputer and store in r1 so it can be printed
   ldr r1, [r1]

   b moneyVerifyAdd		@ branch to verify user input and add to total

peanutAmount:

   ldr r0, =strPeanutAmount	@ let user know how much money to enter
   bl printf			@ display to screen

peanutAmountOptions:

   ldr r0, =strOptions		@ display coin options
   bl printf 			@ display to screen

peanutAmountInput:

   ldr r0, = userInputPattern	@ setup to read in one letter
   ldr r1, = userInput		@ load r1 with the address of where the input value will be stored
   bl scanf			@ scans the keyboard
   cmp r0, #READERROR		@ check for a read error
   beq readerror		@ handle it if there was an error
   ldr r1, =userInput		@ read the contents of userInputer and store in r1 so it can be printed
   ldr r1, [r1]

   b moneyVerifyAdd		@ branch to verify user input and add to total

cheeseAmount:

   ldr r0, = strCheeseAmount	@ let user know how much money to enter
   bl printf			@ display to screen

cheeseAmountOptions:

   ldr r0, =strOptions		@ display coin options
   bl printf 			@ display to screen

cheeseAmountInput:

   ldr r0, = userInputPattern	@ setup to read in one letter
   ldr r1, = userInput		@ load r1 with the address of where the input value will be stored
   bl scanf			@ scans the keyboard
   cmp r0, #READERROR		@ check for a read error
   beq readerror		@ handle it if there was an error
   ldr r1, =userInput		@ read the contents of userInputer and store in r1 so it can be printed
   ldr r1, [r1]

   b moneyVerifyAdd		@ branch to verify user input and add to total

mmAmount:

   ldr r0, = strMMAmount	@ let user know how much money to enter
   bl printf			@ display to screen

mmAmountOptions:

   ldr r0, =strOptions		@ display coin options
   bl printf 			@ display to screen

mmAmountInput:

   ldr r0, = userInputPattern	@ setup to read in one letter
   ldr r1, = userInput		@ load r1 with the address of where the input value will be stored
   bl scanf			@ scans the keyboard
   cmp r0, #READERROR		@ check for a read error
   beq readerror		@ handle it if there was an error
   ldr r1, =userInput		@ read the contents of userInputer and store in r1 so it can be printed
   ldr r1, [r1]

   b moneyVerifyAdd		@ branch to verify user input and add to total


@
@ Part 5 - Add user input money to running total
@
moneyVerifyAdd:

   cmp r1, #0x44		@ compare user input with D
   addeq r10, r10, #10		@ add 10 cents to total  
   beq moreMoneyPrompt  	@ branch to ask if user wants to add more money

   cmp r1, #0x51		@ compare user input with Q
   addeq r10, r10, #25		@ add 25 cents to total
   beq moreMoneyPrompt  	@ branch to ask if user wants to add more money

   cmp r1, #0x42		@ compare user input with B
   addeq r10, r10, #100		@ add 100 cents to total
   beq moreMoneyPrompt  	@ branch to ask if user wants to add more money


@
@ Part 6 - Ask if user wants to add more money
@
reMoreMoneyPrompt:

   ldr r0, =strReSelectionPrompt	@ ask user to input proper value
   bl printf				@ display to screen
   b moreMoneyInput			@ branch to get user input

moreMoneyPrompt:

   ldr r0, =strMoreMoneyPrompt	@ ask if user wants to input more coins
   bl printf			@ display to screen

moreMoneyInput:

   ldr r0, = userInputPattern	@ setup to read in one letter
   ldr r1, = userInput		@ load r1 with the address of where the input value will be stored
   bl scanf			@ scans the keyboard
   cmp r0, #READERROR		@ check for a read error
   beq readerrorMoreMoney	@ handle it if there was an error
   ldr r1, =userInput		@ read the contents of userInputer and store in r1 so it can be printed
   ldr r1, [r1]

moreMoneyVerify:

   cmp r1, #0x59		@ compare user input with Y
   beq 	branchCompare		@ branch if equal to MM amount
   
   cmp r1, #0x4e		@ compare user input with N
   beq checkIfEnough		@ branch if equal to prompt

   b reMoreMoneyPrompt		@ branch to reprompt Y/N if invalid input

branchCompare:

   cmp r4, #0x47		@ compare user input with G
   beq gumAmountOptions		@ branch to get user input if equal

   cmp r4, #0x50		@ compare user input with P
   beq peanutAmountOptions	@ branch to get user input if equal

   cmp r4, #0x43		@ compare user input with C
   beq cheeseAmountOptions	@ branch to get user input if equal

   cmp r4, #0x4d		@ compare user input with M
   beq mmAmountOptions		@ branch to get user input if equal 

@
@ Part 7 - Check if user inputted coins is enough for selection
@
checkIfEnough:

   cmp r4, #0x47	@ compare user input with G
   beq gumCheck		@ branch to see if there is enough to buy

   cmp r4, #0x50	@ compare user input with P
   beq peanutCheck	@ branch to see if there is enough to buy

   cmp r4, #0x43	@ compare user input with C
   beq cheeseCheck	@ branch to see if there is enough to buy

   cmp r4, #0x4d	@ compare user input with M
   beq mmCheck		@ branch to see if there is enough to buy

gumCheck:

   cmp r10, #50		@ compare running total with gum cost if equal
   bge gumDispense	@ branch to dispense gum
   b notEnough 		@ branch if not enough

peanutCheck:

   cmp r10, #55		@ compare running total with gum cost if equal
   bge peanutDispense	@ branch to dispense peanut
   b notEnough 		@ branch if not enough

cheeseCheck:

   cmp r10, #65		@ compare running total with gum cost if equal
   bge cheeseDispense	@ branch to dispense cheese
   b notEnough 		@ branch if not enough

mmCheck:

   cmp r10, #100	@ compare running total with gum cost if equal
   bge mmDispense	@ branch to dispense M&Ms
   b notEnough 		@ branch if not enough

notEnough:

   ldr r0, =strNotEnough
   bl printf
   b dispenseChange


@
@ Part 8 - Dispense item
@
gumDispense:
@ Flash red led 3 times
   mov r4, #0	@ initialize loop counter
   mov r5, #2	@ initialize loop end

gumLoop:
   cmp r4, r5		@ compare counter with limit
   bgt gumHoldFive	@ branch to hold for 5 seconds once for loop is done

@ turn on pin5
   ldr r0, =pin5
   ldr r0, [r0]
   mov r1, #1
   bl digitalWrite

@ delay for one second
   ldr r0, =delayMs
   ldr r0, [r0]
   bl delay

@ turn off pin5
   ldr r0, =pin5
   ldr r0, [r0]
   mov r1, #0
   bl digitalWrite

@ delay for one second
   ldr r0, =delayMs
   ldr r0, [r0]
   bl delay

   add r4, r4, #1		@ increment counter by one
   b gumLoop		@ branch to start of loop


@ hold for 5 seconds
gumHoldFive:
@ turn on pin5
   ldr r0, =pin5
   ldr r0, [r0]
   mov r1, #1
   bl digitalWrite

@ delay for five seconds
   ldr r0, =delayFive
   ldr r0, [r0]
   bl delay

@ turn off pin5
   ldr r0, =pin5
   ldr r0, [r0]
   mov r1, #0
   bl digitalWrite


   sub r6, r6, #1		@ reduce inventory item of gum by 1

   ldr r0, =strGumDispense	@ tell user item as been dispensed
   bl printf			@ display to screen
   
   b dispenseChangeGum		@ branch to dispense change

peanutDispense:
@ Flash yellow led 3 times
   mov r4, #0	@ initialize loop counter
   mov r5, #2	@ initialize loop end

peanutLoop:
   cmp r4, r5		@ compare counter with limit
   bgt peanutHoldFive	@ branch to hold for five seconds once loop is done

@ turn on pin4
   ldr r0, =pin4
   ldr r0, [r0]
   mov r1, #1
   bl digitalWrite

@ delay for one second
   ldr r0, =delayMs
   ldr r0, [r0]
   bl delay

@ turn off pin4
   ldr r0, =pin4
   ldr r0, [r0]
   mov r1, #0
   bl digitalWrite

@ delay for one second
   ldr r0, =delayMs
   ldr r0, [r0]
   bl delay

   add r4, r4, #1		@ increment counter by one
   b peanutLoop		@ branch to start of for loop


@ hold for 5 seconds
peanutHoldFive:
@ turn on pin4
   ldr r0, =pin4
   ldr r0, [r0]
   mov r1, #1
   bl digitalWrite

@ delay for five seconds
   ldr r0, =delayFive
   ldr r0, [r0]
   bl delay

@ turn off pin4
   ldr r0, =pin4
   ldr r0, [r0]
   mov r1, #0
   bl digitalWrite


   sub r7, r7, #1		@ reduce inventory item of peanuts by 1

   ldr r0, =strPeanutDispense	@ tell user item as been dispensed
   bl printf			@ display to screen
   
   b dispenseChangePeanut	@ branch to dispense change

cheeseDispense:
@ Flash green led 3 times
   mov r4, #0	@ initialize loop counter
   mov r5, #2	@ initialize loop end

cheeseLoop:
   cmp r4, r5		@ compare counter and limit
   bgt cheeseHoldFive	@ branch to hold for five seconds once loop is done

@ turn on pin3
   ldr r0, =pin3
   ldr r0, [r0]
   mov r1, #1
   bl digitalWrite

@ delay for one second
   ldr r0, =delayMs
   ldr r0, [r0]
   bl delay

@ turn off pin3
   ldr r0, =pin3
   ldr r0, [r0]
   mov r1, #0
   bl digitalWrite

@ delay for one second
   ldr r0, =delayMs
   ldr r0, [r0]
   bl delay

   add r4, r4, #1		@ increment counter by one
   b cheeseLoop		@ branch to start of for loop

@ hold for 5 seconds
cheeseHoldFive:
@ turn on pin3
   ldr r0, =pin3
   ldr r0, [r0]
   mov r1, #1
   bl digitalWrite

@ delay for five seconds
   ldr r0, =delayFive
   ldr r0, [r0]
   bl delay

@ turn off pin3
   ldr r0, =pin3
   ldr r0, [r0]
   mov r1, #0
   bl digitalWrite


   sub r8, r8, #1		@ reduce inventory item of cheese by 1

   ldr r0, =strCheeseDispense	@ tell user item as been dispensed
   bl printf			@ display to screen
   
   b dispenseChangeCheese	@ branch to dispense change

mmDispense:
@ Flash blue led 3 times
   mov r4, #0	@ initialize loop counter
   mov r5, #2	@ initialize loop end

mmLoop:
   cmp r4, r5		@ compare counter with limit
   bgt mmHoldFive	@ branch to hold for five seconds once loop ends

@ turn on pin2
   ldr r0, =pin2
   ldr r0, [r0]
   mov r1, #1
   bl digitalWrite

@ delay for one second
   ldr r0, =delayMs
   ldr r0, [r0]
   bl delay

@ turn off pin2
   ldr r0, =pin2
   ldr r0, [r0]
   mov r1, #0
   bl digitalWrite

@ delay for one second
   ldr r0, =delayMs
   ldr r0, [r0]
   bl delay

   add r4, r4, #1		@ increment counter by one
   b mmLoop		@ branch to start of for loop


@ hold for 5 seconds
mmHoldFive:
@ turn on pin2
   ldr r0, =pin2
   ldr r0, [r0]
   mov r1, #1
   bl digitalWrite

@ delay for five seconds
   ldr r0, =delayFive
   ldr r0, [r0]
   bl delay

@ turn off pin2
   ldr r0, =pin2
   ldr r0, [r0]
   mov r1, #0
   bl digitalWrite


   sub r9, r9, #1		@ reduce inventory item of mm by 1

   ldr r0, =strMMDispense	@ tell user item as been dispensed
   bl printf			@ display to screen
   
   b dispenseChangeMM		@ branch to dispense change


@
@ Part 9 - Dispense change
@
dispenseChange:

   ldr r0, =strDispenseChange1		@ tell user change is being dispensed
   bl printf				@ display to screen

   ldr r0, =dispenseChangePattern 	@ %d for printing the change
   mov r1, r10				@ move change into r1 to print
   bl printf				@ display to screen

   ldr r0, =strDispenseChange2		@ tell user change is being dispensed
   bl printf				@ display to screen

   b prompt				@ loop back to prompt

dispenseChangeGum:

   sub r10, r10, #50	@ subtract cost from total
   b dispenseChange	@ branch to print out change

dispenseChangePeanut:

   sub r10, r10, #55	@ subtract cost from total
   b dispenseChange	@ branch to print out change

dispenseChangeCheese:

   sub r10, r10, #65	@ subtract cost from total
   b dispenseChange	@ branch to print out change

dispenseChangeMM:

   sub r10, r10, #100	@ subtract cost from total
   b dispenseChange	@ branch to print out change


@
@ Part 10 - Print inventory
@
inventory:

   ldr r0, =strInventory	@ print out that the invetory is going to be printed
   bl printf			@ display to screen

   ldr r0, =strInventoryGum	@ display gum inventory
   bl printf			@ display to screen

   ldr r0, =inventoryPattern	@ load pattern to print value
   mov r1, r6			@ move inventory amount into r1
   bl printf			@ display amount to screen

   ldr r0, =enter		@ load a new line to show number
   bl printf			@ display to screen


   ldr r0, =strInventoryPeanut	@ display peanut inventory
   bl printf			@ display to screen

   ldr r0, =inventoryPattern	@ load pattern to print value
   mov r1, r7			@ move inventory amount into r1
   bl printf			@ display amount to screen

   ldr r0, =enter		@ load a new line to show number
   bl printf			@ display to screen


   ldr r0, =strInventoryCheese	@ display cheese inventory
   bl printf			@ display to screen

   ldr r0, =inventoryPattern	@ load pattern to print value
   mov r1, r8			@ move inventory amount into r1
   bl printf			@ display amount to screen

   ldr r0, =enter		@ load a new line to show number
   bl printf			@ display to screen


   ldr r0, =strInventoryMM	@ display M&Ms inventory
   bl printf			@ display to screen

   ldr r0, =inventoryPattern	@ load pattern to print value
   mov r1, r9			@ move inventory amount into r1
   bl printf			@ display amount to screen

   ldr r0, =enter		@ load a new line to show number
   bl printf			@ display to screen


   b prompt			@ return to prompt


@
@ Part 11 - Force the exit of this program and return command to OS
@
exit:	
@
@ Program ends so red light comes on for 5 seconds
@
@ turn on pin5
   ldr r0, =pin5
   ldr r0, [r0]
   mov r1, #1
   bl digitalWrite

@ delay for five seconds
   ldr r0, =delayFive
   ldr r0, [r0]
   bl delay

@ turn off pin5
   ldr r0, =pin5
   ldr r0, [r0]
   mov r1, #0
   bl digitalWrite
	
   mov r7, #0X01
   svc 0

exitEmpty:
@
@ Program ends so red light comes on for 5 seconds
@
@ turn on pin5
   ldr r0, =pin5
   ldr r0, [r0]
   mov r1, #1
   bl digitalWrite

@ delay for five seconds
   ldr r0, =delayFive
   ldr r0, [r0]
   bl delay

@ turn off pin5
   ldr r0, =pin5
   ldr r0, [r0]
   mov r1, #0
   bl digitalWrite


   ldr r0, =strExitEmpty	@ let user know vending machine is closing due to no inventory
   bl printf			@ display to screen

   mov r7, #0X01
   svc 0


@ Clear out input buffer if there was a read error
readerror:

   ldr r0,=strInputPattern
   ldr r1, =strInputError	@ Put address into r1 for read
   bl scanf			@ scan the keyboard
   b rePrompt			@ branch back to prompt

readerrorSelection:

   ldr r0,=strInputPattern
   ldr r1, =strInputError	@ Put address into r1 for read
   bl scanf			@ scan the keyboard
   b reSelectionPrompt		@ branch back to prompt

readerrorMoney:

   ldr r0,=strInputPattern
   ldr r1, =strInputError	@ Put address into r1 for read
   bl scanf			@ scan the keyboard
   b rePromptMoney		@ branch back to prompt

readerrorMoreMoney:

   ldr r0,=strInputPattern
   ldr r1, =strInputError	@ Put address into r1 for read
   bl scanf			@ scan the keyboard
   b reMoreMoneyPrompt		@ branch back to prompt


@ Declare the strings
.data

@values for the pins
pin2: .word 2
pin3: .word 3
pin4: .word 4
pin5: .word 5

@values for the buttons
buttonBlue: .word 7
buttonGreen: .word 0
buttonYellow: .word 6
buttonRed: .word 1

@delay for pins
delayMs: .word 1000	@ set delay for one seconds
delayFive: .word 5000	@ seet delay for five seconds
delayHalf: .word 250	@ set a delay for half a second

@ strings

.balign 4	@ force a word boundary
strWelcome: .asciz "\nWelcome to Brandon's Vending Machine!\n"

.balign 4
strCost: .asciz "\nCost of Gum ($0.50), Peanuts ($0.55), Cheese Crackers ($0.65), or M&Ms ($1.00)\n" 

.balign 4
strInputPrompt: .asciz "\nPress item selection button: Gum (Red Button), Peanuts (Yellow Button), Cheese Crackers (Green Button), or M&Ms (Blue Button)\n"

.balign 4
strInputPrompt2: .asciz "Enter (Q) to quit.\n"

.balign 4
strGumSelection: .asciz "\nYou selected Gum. Is this correct (Y/N)?\n"

.balign 4
strPeanutSelection: .asciz "\nYou selected Peanuts. Is this correct (Y/N)?\n"

.balign 4
strCheeseSelection: .asciz "\nYou selected Cheese Crackers. Is this correct (Y/N)?\n"

.balign 4
strMMSelection: .asciz "\nYou selected M&Ms. Is this correct (Y/N)?\n"

.balign 4
strGumDispense: .asciz "\nGum has been dispensed.\n"

.balign 4
strPeanutDispense: .asciz "\nPeanuts have been dispensed.\n"

.balign 4
strCheeseDispense: .asciz "\nCheese Crackers have been dispensed.\n"

.balign 4
strMMDispense: .asciz "\nM&Ms have been dispensed.\n"

.balign 4
strGumAmount: .asciz "\nEnter at least 50 cents for selection\n"

.balign 4
strPeanutAmount: .asciz "\nEnter at least 55 cents for selection\n"

.balign 4
strCheeseAmount: .asciz "\nEnter at least 65 cents for selection\n"

.balign 4
strMMAmount: .asciz "\nEnter at least 1 dollar (100 cents) for selection\n"

.balign 4
strOptions: .asciz "\nDimes (D), Quarters (Q), and Dollar Bills (B)\n"


.balign 4
strRePrompt: .asciz "Invalid input. Please press red, green, yellow, or blue button.\n"

.balign 4
strRePromptMoney: .asciz "Invalid input. Please enter 'D', 'Q', or 'B'.\n"

.balign 4
strReSelectionPrompt: .asciz "Invalid input. Please enter 'Y' or 'N'.\n"

.balign 4
strDispenseChange1: .asciz "Change of "

.balign 4
strDispenseChange2: .asciz " cents has been dispensed.\n"

.balign 4
strOut: .asciz "\nSorry, we are currently out of that item.\n"

.balign 4
strInventory: .asciz "\n\nThe vending machine currently has:\n"

.balign 4
strInventoryGum: .asciz "Gum: "

.balign 4
strInventoryPeanut: .asciz "Peanuts: "

.balign 4
strInventoryCheese: .asciz "Cheese Crackers: "

.balign 4
strInventoryMM: .asciz "M&Ms: "

.balign 4
strMoreMoneyPrompt: .asciz "\nWould you like to insert more coins (Y/N)?\n"

.balign 4
strNotEnough: .asciz "\nNot enough money was inserted.\n"

.balign 4
strExitEmpty: .asciz "\n\nVending Machine Closed: Out of Inventory\n"

.balign 4
enter: .asciz "\n"

.balign 4
ErrMsg: .asciz "Setup didn't work ... Aborting ...\n"


@ Format pattern for scanf call

.balign 4
inventoryPattern: .asciz " %d "

.balign 4
dispenseChangePattern: .asciz "%d"

.balign 4
userInputPattern: .asciz "%s"		@ integer format for read

.balign 4
strInputPattern: .asciz "%[^\n]"	@ used to clear the input buffer for invalid input

.balign 4
strInputError: .skip 100*4 		@ used to clear the input buffer for invalid input

.balign 4
userInput: .word 0			@ Location used to store the user input


@ Let the assembler know these are the C library functions

.global printf

.global scanf

.extern wiringPiSetup
.extern delay
.extern digitWrite
.extern pinMode


@ End of code
