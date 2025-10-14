;;;;;;; P2 for QwikFlash board ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 
;
;;;;;;; Program hierarchy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Mainline
;   Initial
;
;;;;;;; Assembler directives ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        list  P=PIC18F4520, F=INHX32, C=160, N=0, ST=OFF, MM=OFF, R=DEC, X=ON
        #include <P18F4520.inc>
        __CONFIG  _CONFIG1H, _OSC_HS_1H  ;HS oscillator
        __CONFIG  _CONFIG2L, _PWRT_ON_2L & _BOREN_ON_2L & _BORV_2_2L  ;Reset
        __CONFIG  _CONFIG2H, _WDT_OFF_2H  ;Watchdog timer disabled
        __CONFIG  _CONFIG3H, _CCP2MX_PORTC_3H  ;CCP2 to RC1 (rather than to RB3)
        __CONFIG  _CONFIG4L, _LVP_OFF_4L & _XINST_OFF_4L  ;RB5 enabled for I/O
        errorlevel -314, -315          ;Ignore lfsr messages

;;;;;;; Variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        cblock  0x000                  ;Beginning of Access RAM
        VAR_1                          ;Define variables as needed
     
        V0L
        V0H
        V1L
        V1H
        V2L
        V2H
        V3L
        V3H
		SumTotalL
		SumTotalH
                Total
        endc

;;;;;;; Macro definitions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOVLF   macro  literal,dest
        movlw  literal
        movwf  dest
        endm



;;;;;;; Vectors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        org  0x0000                    ;Reset vector
        nop 
        goto  Mainline

        org  0x0008                    ;High priority interrupt vector
        goto  $                        ;Trap

        org  0x0018                    ;Low priority interrupt vector
        goto  $                        ;Trap

;;;;;;; Mainline program ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Mainline

        rcall		Initial                 ;Initialize everything

L1

;AC
        bsf             ADCON0,1
                
ADLoop

        btfsc           ADCON0,1
        bra             ADLoop

Memory
        movff           V2H,V3H
        movff           V2L,V3L
        movff           V1H,V2H
        movff           V1L,V2L
        movff           V0H,V1H
        movff           V0L,V1L
        movff           ADRESH,V0H
        movff           ADRESL,V0L

;Adder
        movff           V0L,SumTotalL
        movff           V0H,SumTotalH

        movf            V1L,W
        addwf           SumTotalL,F
        movf            V1H,W
        addwfc          SumTotalH,F
	
        movf            V2L,W
        addwf           SumTotalL,F
        movf            V2H,W
        addwfc          SumTotalH,F

        movf            V3L,W
        addwf           SumTotalL,F
        movf            V3H,W
        addwfc          SumTotalH,F

;Divider
	;rrcf	 SumTotalH,F
	;rrcf	 SumTotalL,F
        ;rrcf    SumTotalH,F
        ;rrcf    SumTotalL,F
        ;rrcf    SumTotalH,F
        ;rrcf    SumTotalL,F
        ;rrcf    SumTotalH,F
        ;rrcf    SumTotalL,F

        movf            SumTotalL,W
        andlw           B'11110000'
        movwf           SumTotalL
        swapf           SumTotalL,F

        movf            SumTotalH,W
        andlw           B'00001111'
        movwf           SumTotalH
        swapf           SumTotalH,F

        movf            SumTotalL,W
        addwf           SumTotalH,W
        movwf           Total

;DCHigh
        bcf     	PORTC,RC0
        bcf     	PIR1,SSPIF           
        MOVLF   	0x21,SSPBUF

DCLoop1
        btfss   	PIR1,SSPIF
        bra     	DCLoop1
        bcf     	PIR1,SSPIF
        movff   	Total,SSPBUF

DCLoop2
        btfss  		PIR1,SSPIF
        bra     	DCLoop2
        bsf     	PORTC,RC0

        bra             L1

;;;;;;; Initial subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This subroutine performs all initializations of variables and registers.

Initial
        MOVLF  B'11000000',SSPSTAT     
        MOVLF  B'00100000',SSPCON1     
        MOVLF  B'00011101',ADCON0      ;Channel 7(AN7)
        MOVLF  B'10001110',ADCON1      ;Enable PORTA & PORTE digital I/O pins
        MOVLF  B'11000100',ADCON2      ;Right = 1, 0 T_{AD} = 000, F_{OSC/4} = 100

        MOVLF  B'11100001',TRISA       ;Set I/O for PORTA
        MOVLF  B'11011100',TRISB       ;Set I/O for PORTB
        MOVLF  B'11010000',TRISC       ;Set I/0 for PORTC
        MOVLF  B'00001111',TRISD       ;Set I/O for PORTD
        MOVLF  B'00000100',TRISE       ;Set I/O for PORTE
        MOVLF  B'10001000',T0CON       ;Set up Timer0 for a looptime of 10 ms
        MOVLF  B'00010000',PORTA       ;Turn off all four LEDs driven from PORTA

	MOVLF  B'00000000',V0L
        MOVLF  B'00000000',V0H
        MOVLF  B'00000000',V1L
        MOVLF  B'00000000',V1H
        MOVLF  B'00000000',V2L
        MOVLF  B'00000000',V2H
        MOVLF  B'00000000',V3L
        MOVLF  B'00000000',V3H
        MOVLF  B'00000000',Total
        return






        end
