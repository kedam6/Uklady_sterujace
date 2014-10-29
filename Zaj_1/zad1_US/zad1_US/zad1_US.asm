/*
 * zad1_US.asm
 *
 *  Created: 2014-10-29 10:49:16
 *   Author: Damian Misiura, Micha³ Kurzyñski
 */ 

 ;program wykonuje a+b dla dowolnej dlugosci liczb

.DSEG
.ORG 0x01FF ;dokladnie w tym miejscu pamieci zaczyna sie segment nas interesujacy

.EQU LEN = 2 ;stala dlugosci zmiennych
a: .BYTE LEN ;zmienna a
b: .BYTE LEN ;zmienna b

.CSEG ;zaczyna sie fragment wykonawczy programu

LDI ZL, LOW(LEN) ;wczytuje do rejestru dlugosc
LDI ZH, HIGH(LEN)

LDI XL, LOW(a) ;wczytuje a do rejestrow X
LDI XH, HIGH(a)

LDI YL, LOW(b) ;wczytuje b do rejestrow Y
LDI YH, HIGH(b)

LDI R18, 0
LDI R19, 0 ;wyzerowanie potrzebnych rejestrow
CLC

LOOP: ;znacznik petli

	CPSE ZH, R18 ;sprawdza czy ZH rowne 0
	RJMP LOOP_ENABLED ;jesli rozne od 0 to wraca do petli
	CPSE ZL, R18 ;sprawdza czy ZL rowne 0
	RJMP LOOP_ENABLED ;jesli nie to wraca do petli
	RJMP END ;jesli wszystko rowne 0 to konczy program

LOOP_ENABLED:
	CPI R19, 0 ;sprawdza czy zapamitana wartosc carry to 0
	BRNE CARRY_WAS_SET ;jezeli carry nie jest rowny 0, to skip do CARRY_WAS_SET
	CLC ;wylacza bit carry
	RJMP LOOP_ACTIVATED
	CARRY_WAS_SET:
	SEC ;aktywuje bit carry

LOOP_ACTIVATED:
	LD R16, X+ ;wczytuje wartosc x do rejestru R16, przy czy przesuwa X do nastepnego bajtu
	LD R17, Y
	ADC R17, R16 ;dodaje z przesunieciem flagi carry
	
	;
	BRCC CARRY_ZERO ;sprawdza czy carry jest zapalony
					;skacze do CARRY_ZERO jesli carry nie zapalony
	LDI R19, 1 ;wpisuje jego wartosc do rejestru 19
	RJMP CARRY_DONE
	
	CARRY_ZERO:
	LDI R19, 0 

	CARRY_DONE:
	ST Y+, R17 ;zapisuje wynik do zmiennej Y, po czym nastepnie przesuwa ja do przodu
	SBIW Z, 1 ;dekrementuje wartosc Z

; koniec petli
RJMP LOOP 

;petla konczaca wykonywanie programu
END:
RJMP END 

