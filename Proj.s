; Traffic light states

NorthSouthGreen				EQU		0x20000000
NorthSouthYellow			EQU		0x20000004
NorthSouthRed				EQU		0x20000008
EastWestGreen				EQU		0x2000000C
EastWestYellow				EQU		0x20000010
EastWestRed					EQU		0x20000014
PedNorthSouthGreen			EQU		0x20000018
PedNorthSouthRed			EQU		0x2000001C
PedEastWestGreen			EQU		0x20000020
PedEastWestRed				EQU		0x20000024
	
	PRESERVE8
    THUMB

    AREA RESET, DATA, READONLY

    EXPORT __Vectors

__Vectors    DCD 0x2000200
            DCD Reset_Handler

            ALIGN

            AREA MYCODE, CODE, READONLY
            ENTRY
            EXPORT Reset_Handler

;R0: Counter
;R1: Memory value
;R2: Pointer

;R3: 1 if there is a car from North to South or vice versa, 0 if there is none.
;R4: 1 if there is a car from East to West or vice versa, 0 if there is not.
;R5: 1 if there is a pedestrian from North to South or vice versa, 0 if there is not.
;R6: 1 if there is a pedestrian from East to West or vice versa, 0 if there is not.

;R7: 1 if there are cars or pedestrians in all directions (extreme case).

;R10: Real-time delay implementer

Reset_Handler
		
		;Initialize
		MOV		R0,#0 ;counter starts at 0
		MOV		R1,#0 ;no memory value allocated yet
		MOV		R2,#0 ;no pointer assigned yet
		
		;North South traffic light values for cars:
		MOV		R1,#1 ;pivot value of the traffic light state to change
		LDR		R2,=NorthSouthGreen ;traffic state NorthSouthGreen = 1
		STR		R1, [R2] ;updates the state R1 of the traffic light pointed to by R2
		
		MOV		R1,#0 ;pivot value of the traffic light state to change
		LDR		R2,=NorthSouthYellow ;state NorthSouthYellow = 0
		STR		R1, [R2] ;updates the state R1 of the traffic light pointed to by R2
		
		MOV		R1,#0 ;pivot value of the traffic light state to change
		LDR		R2,=NorthSouthRed ;state NorthSouthRed = 0
		STR		R1, [R2] ;updates the state R1 of the traffic light pointed to by R2

		;East West traffic light values for cars:
		MOV		R1,#0 ;pivot value of the traffic light state to change
		LDR		R2,=EastWestGreen ;state EastWestGreen = 0
		STR		R1, [R2] ;updates the state R1 of the traffic light pointed to by R2
		
		MOV		R1,#0 ;pivot value of the traffic light state to change
		LDR		R2,=EastWestYellow ;state EastWestYellow = 0
		STR		R1, [R2] ;updates the state R1 of the traffic light pointed to by R2
		
		MOV		R1,#1 ;pivot value of the traffic light state to change
		LDR		R2,=EastWestRed ;state EastWestRed = 1
		STR		R1, [R2] ;updates the state R1 of the traffic light pointed to by R2
		
		;North South pedestrian traffic lights
		MOV		R1,#1 ;pivot value of the traffic light state to change
		LDR		R2,=PedNorthSouthGreen ;state PedNorthSouthGreen = 1
		STR		R1, [R2] ;updates the state R1 of the traffic light pointed to by R2
		
		MOV		R1,#0 ;pivot value of the traffic light state to change
		LDR		R2,=PedNorthSouthRed ;state PedNorthSouthRed = 0
		STR		R1, [R2] ;updates the state R1 of the traffic light pointed to by R2
		
		;East West pedestrian traffic light values
		MOV		R1,#0 ;pivot value of the traffic light state to change
		LDR		R2,=PedEastWestGreen ;state PedNorthSouthGreen = 0
		STR		R1, [R2] ;updates the state R1 of the traffic light pointed to by R2
		
		MOV		R1,#1 ;pivot value of the traffic light state to change
		LDR		R2,=PedEastWestRed ;state PedEastWestRed = 1
		STR		R1, [R2] ;updates the state R1 of the traffic light pointed to by R2
		
Main
		MOV		R3,#0 ;there is no car from north to south (initial state)
		MOV		R4,#1 ;there is a car from east to west (initial state)
		MOV		R5,#0 ;there is no pedestrian from north to south (initial state)
		MOV		R6,#1 ;there is a pedestrian from east to west (initial state)
		
		MOV		R7,#0
		
		;Count 30 seconds in the initial state
		BL		CriticalChecker ;Verify which counter to use depending on R7 (critical flag)
		MOV		R0,	#0 ;To reset the counter
		
		;The traffic lights must now be changed to fit the initial conditions
		BL		TrafficLightChange
		
		;The conditions on the roads are changed
		MOV		R3, #1 ;There is a car from N to S
		MOV		R5, #0 ;There is no pedestrian from N to S
		MOV		R4,	#0 ;There is no car from E to W
		MOV		R6,	#0 ;There is no pedestrian from E to W
		
		ORR		R8, R3, R5 ;Check if there are cars or pedestrians from North to South or vice versa, it should be 1
		ORR		R9, R4, R6 ;Check if there are cars or pedestrians from East to West or vice versa, it should be 0
		AND		R7, R8, R9 ;Critical situation flag should be deactivated due to the new conditions
		
		BL		CriticalChecker ;Verify which counter to use depending on R7 (critical flag) 
		MOV		R0,	#0 ;To reset the counter
		
		;The traffic lights must now be changed to adjust to the new conditions
		BL		TrafficLightChange
		
		;The conditions on the roads are changed
		MOV		R3, #1 ;There is a car from N to S
		MOV		R5, #1 ;There is a pedestrian from N to S
		MOV		R4,	#1 ;There is a car from E to W
		MOV		R6,	#1 ;There is a pedestrian from E to W
		
		ORR		R8, R3, R5 ;Check if there are cars or pedestrians from North to South or vice versa, it should be 1
		ORR		R9, R4, R6 ;Check if there are cars or pedestrians from East to West or vice versa, it should be 0
		AND		R7, R8, R9 ;Critical situation flag should be deactivated due to the new conditions
		
		BL		CriticalChecker ;Verify which counter to use depending on R7 (critical flag) 
		MOV		R0,	#0 ;To reset the counter
		
		;The traffic lights must now be changed to adjust to the new conditions
		BL		TrafficLightChange
		
		B		Main ;Change to Stop to just do one loop.

CriticalChecker
		CMP 	R7, #1 ;Critical situation activated
		BEQ		Counter60Sec
		
		CMP		R7, #0 ;Normal situation
		BEQ		Counter30Sec
		
Counter30Sec
		;Counter for when the situation is not critical
		ADD 	R0, #1
		CMP 	R0, #30 ;30 seconds pass
		BEQ 	Pop2Top
;		MOV		R10, #0
;		LDR		R10, =12250000
;Delay30
;		SUBS	R10, R10, #1
;		BNE		Delay30;---------uncomment for real-time delay
		B 		Counter30Sec
	
Counter60Sec
		;Counter for when the situation is critical
		ADD 	R0, #1
		CMP 	R0, #60 ;1 minute passes
		BEQ		Pop2Top
;		MOV		R10, #0
;		LDR		R10, =12250000
;Delay60
;		SUBS	R10, R10, #1
;		BNE		Delay60;---------uncomment for real-time delay
		B		Counter60Sec

TrafficLightChange
		
		LDR		R2, =NorthSouthGreen
		LDR		R1, [R2]
		CMP		R1, #1 
		BEQ		NorthSouthShutoff ;If it is 1 turn off North South and then turn on East West
		
		B		EastWestShutoff

EastWestShutoff
		LDR		R2, =EastWestGreen
		STR		R1, [R2] ;Turn off EastWestGreen for cars
		LDR		R2, =PedEastWestGreen
		STR		R1, [R2] ;Turn off EastWestGreen for pedestrians
		
		MOV		R1, #1
		LDR		R2, =EastWestYellow ;Turn on EastWestYellow for cars
		STR		R1, [R2]
		MOV		R1, #0
;		MOV		R10, #0
;		LDR		R10, =25000000
;DelayYellowEW
;		SUBS	R10, R10, #1
;		BNE		DelayYellowEW;---------uncomment for delay
		STR		R1, [R2] ;Turn off EastWestYellow for cars
		
		MOV 	R1, #1
		LDR		R2, =EastWestRed
		STR		R1, [R2] ;Turn on EastWestRed for cars
		LDR		R2, =PedEastWestRed
		STR		R1, [R2] ;Turn on EastWestRed for pedestrians
		
		B		NorthSouthTurnon
		
NorthSouthTurnon

		MOV		R1, #0
		LDR		R2, =NorthSouthRed
		STR		R1, [R2] ;Turn off EastWestRed for cars
		LDR		R2,	=PedNorthSouthRed
		STR		R1, [R2] ;Turn off EastWestRed for pedestrians
		
		MOV		R1, #1
		LDR		R2, =NorthSouthGreen
		STR		R1, [R2] ;Turn on EastWestGreen for cars
		LDR		R2,	=PedNorthSouthGreen
		STR		R1, [R2] ;Turn on EastWestGreen for pedestrians

		B		Pop2Top
		
NorthSouthShutoff
		
		MOV		R1, #0
		STR		R1, [R2] ;Turn off the NorthSouthGreen traffic light for cars
		LDR		R2, =PedNorthSouthGreen
		STR		R1,	[R2] ;Turn off the NorthSouthGreen traffic light for pedestrians
		
		MOV		R1, #1
		LDR		R2, =NorthSouthYellow ;Turn on NorthSouthYellow for cars
		STR		R1, [R2]
		MOV		R1, #0
;		MOV		R10, #0
;		LDR		R10, =25000000
;DelayYellowNS
;		SUBS	R10, R10, #1
;		BNE		DelayYellowNS;---------uncomment for delay
		STR		R1, [R2] ;Turn off NorthSouthYellow for cars
		
		MOV		R1, #1 ;
		LDR		R2, =NorthSouthRed
		STR		R1, [R2] ;Turn on NorthSouthRed for cars
		LDR		R2, =PedNorthSouthRed
		STR		R1, [R2] ;Turn on NorthSouthRed for pedestrians
		
		B		EastWestTurnon

EastWestTurnon
		
		MOV		R1, #0
		LDR		R2, =EastWestRed
		STR		R1, [R2] ;Turn off EastWestRed for cars
		LDR		R2,	=PedEastWestRed
		STR		R1, [R2] ;Turn off EastWestRed for pedestrians
		
		MOV		R1, #1
		LDR		R2, =EastWestGreen
		STR		R1, [R2] ;Turn on EastWestGreen for cars
		LDR		R2,	=PedEastWestGreen
		STR		R1, [R2] ;Turn on EastWestGreen for pedestrians
		
		B		Pop2Top

Pop2Top
		BX 		LR

Stop
		B 		Stop ;Ends the program
		END