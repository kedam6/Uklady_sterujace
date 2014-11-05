/*
 * zad2_US.asm
 *
 *  Created: 2014-11-05 11:41:19
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
CLC

LDI R20 , low(RAMEND)
LDI R21 , high(RAMEND) ; inicjalizacja stosu na znalezionym koncu pamieci
OUT SPL , R20
OUT SPH , R21 ;przekazanie wskaznika polozenia stosu

CALL DODAJ

;petla konczaca wykonywanie programu
END:
RJMP END 

DODAJ:
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R19 ;zapisanie stanu rejestrow R16-19 aby nie utracic potencjalnie waznych danych
	LDI R18, 0
	LDI R19, 0 ;wyzerowanie potrzebnych rejestrow

LOOP: ;znacznik petli
	CPSE ZH, R18 ;sprawdza czy ZH rowne 0
	RJMP LOOP_ENABLED ;jesli rozne od 0 to wraca do petli
	CPSE ZL, R18 ;sprawdza czy ZL rowne 0
	RJMP LOOP_ENABLED ;jesli nie to wraca do petli
	RJMP END_FUNCTION ;jesli wszystko rowne 0 to konczy program

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

END_FUNCTION:
;aktywuje sie gdy licznik jest rowny 0
	POP R19
	POP R18
	POP R17
	POP R16 ;oddaje wartosci ktore byly zapisane pierwotnie na rejestrach R16-19
	RET




