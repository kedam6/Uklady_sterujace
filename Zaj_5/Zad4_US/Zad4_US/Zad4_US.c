/*
* Zad4_US.c
*
* Created: 2014-11-12 17:47:57
* Author: Damian Misiura, Michal Kurzynski
*/


#include <avr/io.h>
#include <avr/interrupt.h>
#include <Util/delay.h>
#include "lib.h"


// digits from 0 to 9
int digit[10] = {
	0b11000000,
	0b11111001,
	0b10100100,
	0b10110000,
	0b10011001,
	0b10010010,
	0b10000010,
	0b11111000,
	0b10000000,
	0b10010000
};

//represents active screen at the moment
int active = 0;

//screens initialized, initial time is 990,0
int first = 0;
int second = 0;
int third = 9;
int fourth = 9;



//dot needed to show before time 1000
static int dot = 0b10000000;


//initialization of interruption
void k_init(void)
{
	TCCR0 |= (0 << WGM00) | (1 << WGM01) | (0 << CS02) | (1 << CS01) | (1 <<CS00) | (1 << COM01) | (0 << COM00);
	OCR0 = 250;
	TIMSK |= (1 << OCIE0);
	DDRA|=0xFF;
	DDRD|=0xFF;
}

//interruption handling
ISR(TIMER0_COMP_vect)
{
	schedule();
}


//screen refresh mechanism, it checks whichs screens turn is it and updates value represented on screen
void screen(void* param)
{
	//make sure we use port D
	DDRD = 0xff;
	PORTD = 0xFF;
	
	//every if sends a new digit to show and screen its going to use
	if(active == 0)
	{
		PORTA = digit[first];
		PORTD = 0b11110111;
	}
	else if(active == 1)
	{
		PORTA = digit[second] - dot; //display a dot before number 1000, so we get 990,0 ; 990,1 etc
		PORTD = 0b11111011;
	}
	else if(active == 2)
	{
		PORTA = digit[third];
		PORTD = 0b11111101;
	}
	else if(active == 3)
	{
		PORTA = digit[fourth];
		PORTD = 0b11111110;
	}
	
	//this maes sure we cycle around 4 screens, not more
	active = (active + 1) % 4; 
}

//increases digits on screens, at 999,9 state it changes periods of tasks to 1s from 100ms
void timer(void* param)
{
	if(first == 9 && second == 9 && third == 9 && fourth == 9)
	{
		tasks[1].period = 1000;
		tasks[1].togo = 1000;
		
		//initializes new state, 1000, dot is eliminated from now on
		fourth = 1;
		third = 0;
		second = 0;
		first = 0;	
		dot = 0b00000000;
	}
	if(first + 1 < 10)
	{
		first ++;
	}
	else
	{
		first = 0;
		if(second + 1 < 10)
		{
			second ++;
		}
		else
		{
			second = 0;
			if(third + 1 < 10)
			{
				third++;
			}
			else
			{
				third = 0;
				if(fourth + 1 < 10)
				{
					fourth++;
				}
				else
				{
					fourth = 0;
				}
			}
		}
	}
}


int main(void)
{
	//add tasks for refreshing screen, 2ms delay and timer every 100ms
	AddTask(1, 3, screen, 0);
	AddTask(2, 100, timer, 0);
	//initialize kernel and interruption
	k_init();
	sei();
	//make sure we use correct ports
	PORTD = ~1;
	PORTA = digit[1];
	//start task checking
	execute();
}