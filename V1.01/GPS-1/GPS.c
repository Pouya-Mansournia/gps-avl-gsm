/*****************************************************
This program was produced by the
CodeWizardAVR V2.05.0 Advanced
Automatic Program Generator
© Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project : SIM908
Version : Version 2.0
Date    : 09/25/2011
Company : SanatGaran Mihan dooost 
Comments: pouya mansournia S.R.L


Chip type               : ATmega64
Program type            : Application
AVR Core Clock frequency: 8.000000 MHz
Memory model            : Small
External RAM size       : 0
Data Stack size         : 1024
*****************************************************/

#include <mega64.h>
#include <string.h>
#include <delay.h>
#include <stdio.h>
#include <stdlib.h>
#define  led_U PORTA.2
#define  led_D PORTB.5
#define  POWER PORTC.0

unsigned int adc_data;
#define ADC_VREF_TYPE 0x40

// ADC interrupt service routine
interrupt [ADC_INT] void adc_isr(void)
{
// Read the AD conversion result
adc_data=ADCW;
}

// Read the AD conversion result
// with noise canceling
unsigned int read_adc(unsigned char adc_input)
{
ADMUX=adc_input | (ADC_VREF_TYPE & 0xff);
// Delay needed for the stabilization of the ADC input voltage
delay_us(10);
#asm
    in   r30,mcucr
    cbr  r30,__sm_mask
    sbr  r30,__se_bit | __sm_adc_noise_red
    out  mcucr,r30
    sleep
    cbr  r30,__se_bit
    out  mcucr,r30
#endasm
return adc_data;
}

bit data_ready=0,trueData=0;
unsigned char caller_id[20];
float Kp,Ki,Kd,T,err,err1,err2,U,temperature;
unsigned char setpoint;
int Tocr;
//------------------------------------------------------------------
eeprom unsigned char sms_in_e2prom[256],setpoint_saved,gps_in_e2prom[256];


#ifndef RXB8
#define RXB8 1
#endif

#ifndef TXB8
#define TXB8 0
#endif

#ifndef UPE
#define UPE 2
#endif

#ifndef DOR
#define DOR 3
#endif

#ifndef FE
#define FE 4
#endif

#ifndef UDRE
#define UDRE 5
#endif

#ifndef RXC
#define RXC 7
#endif

#define FRAMING_ERROR (1<<FE)
#define PARITY_ERROR (1<<UPE)
#define DATA_OVERRUN (1<<DOR)
#define DATA_REGISTER_EMPTY (1<<UDRE)
#define RX_COMPLETE (1<<RXC)

// USART0 Receiver buffer
#define RX_BUFFER_SIZE0 200
char rx_buffer0[RX_BUFFER_SIZE0];

#if RX_BUFFER_SIZE0 <= 256
unsigned char rx_wr_index0,rx_rd_index0,rx_counter0;
#else
unsigned int rx_wr_index0,rx_rd_index0,rx_counter0;
#endif

// This flag is set on USART0 Receiver buffer overflow
bit rx_buffer_overflow0;

// USART0 Receiver interrupt service routine
interrupt [USART0_RXC] void usart0_rx_isr(void)
{
char status,data;
status=UCSR0A;
data=UDR0;
if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
   {
   rx_buffer0[rx_wr_index0++]=data;
#if RX_BUFFER_SIZE0 == 256
   // special case for receiver buffer size=256
   if (++rx_counter0 == 0)
      {
#else
   if (rx_wr_index0 == RX_BUFFER_SIZE0) rx_wr_index0=0;
   if (++rx_counter0 == RX_BUFFER_SIZE0)
      {
      rx_counter0=0;
#endif
      rx_buffer_overflow0=1;
      }
   }
}

#ifndef _DEBUG_TERMINAL_IO_
// Get a character from the USART0 Receiver buffer
#define _ALTERNATE_GETCHAR_
#pragma used+
char getchar(void)
{
char data;
while (rx_counter0==0);
data=rx_buffer0[rx_rd_index0++];
#if RX_BUFFER_SIZE0 != 256
if (rx_rd_index0 == RX_BUFFER_SIZE0) rx_rd_index0=0;
#endif
#asm("cli")
--rx_counter0;
#asm("sei")
return data;
}
#pragma used-
#endif

// USART0 Transmitter buffer
#define TX_BUFFER_SIZE0 200
char tx_buffer0[TX_BUFFER_SIZE0];

#if TX_BUFFER_SIZE0 <= 256
unsigned char tx_wr_index0,tx_rd_index0,tx_counter0;
#else
unsigned int tx_wr_index0,tx_rd_index0,tx_counter0;
#endif

// USART0 Transmitter interrupt service routine
interrupt [USART0_TXC] void usart0_tx_isr(void)
{
if (tx_counter0)
   {
   --tx_counter0;
   UDR0=tx_buffer0[tx_rd_index0++];
#if TX_BUFFER_SIZE0 != 256
   if (tx_rd_index0 == TX_BUFFER_SIZE0) tx_rd_index0=0;
#endif
   }
}

#ifndef _DEBUG_TERMINAL_IO_
// Write a character to the USART0 Transmitter buffer
#define _ALTERNATE_PUTCHAR_
#pragma used+
void putchar(char c)
{
while (tx_counter0 == TX_BUFFER_SIZE0);
#asm("cli")
if (tx_counter0 || ((UCSR0A & DATA_REGISTER_EMPTY)==0))
   {
   tx_buffer0[tx_wr_index0++]=c;
#if TX_BUFFER_SIZE0 != 256
   if (tx_wr_index0 == TX_BUFFER_SIZE0) tx_wr_index0=0;
#endif
   ++tx_counter0;
   }
else
   UDR0=c;
#asm("sei")
}
#pragma used-
#endif

// USART1 Receiver buffer
#define RX_BUFFER_SIZE1 200
char rx_buffer1[RX_BUFFER_SIZE1];

#if RX_BUFFER_SIZE1 <= 256
unsigned char rx_wr_index1,rx_rd_index1,rx_counter1;
#else
unsigned int rx_wr_index1,rx_rd_index1,rx_counter1;
#endif

// This flag is set on USART1 Receiver buffer overflow
bit rx_buffer_overflow1;

// USART1 Receiver interrupt service routine
interrupt [USART1_RXC] void usart1_rx_isr(void)
{
char status,data;
status=UCSR1A;
data=UDR1;
if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
   {
   rx_buffer1[rx_wr_index1++]=data;
#if RX_BUFFER_SIZE1 == 256
   // special case for receiver buffer size=256
   if (++rx_counter1 == 0)
      {
#else
   if (rx_wr_index1 == RX_BUFFER_SIZE1) rx_wr_index1=0;
   if (++rx_counter1 == RX_BUFFER_SIZE1)
      {
      rx_counter1=0;
#endif
      rx_buffer_overflow1=1;
      }
   }
}

// Get a character from the USART1 Receiver buffer
#pragma used+
char getchar1(void)
{
char data;
while (rx_counter1==0);
data=rx_buffer1[rx_rd_index1++];
#if RX_BUFFER_SIZE1 != 256
if (rx_rd_index1 == RX_BUFFER_SIZE1) rx_rd_index1=0;
#endif
#asm("cli")
--rx_counter1;
#asm("sei")
return data;
}
#pragma used-
// USART1 Transmitter buffer
#define TX_BUFFER_SIZE1 200
char tx_buffer1[TX_BUFFER_SIZE1];

#if TX_BUFFER_SIZE1 <= 256
unsigned char tx_wr_index1,tx_rd_index1,tx_counter1;
#else
unsigned int tx_wr_index1,tx_rd_index1,tx_counter1;
#endif

// USART1 Transmitter interrupt service routine
interrupt [USART1_TXC] void usart1_tx_isr(void)
{
if (tx_counter1)
   {
   --tx_counter1;
   UDR1=tx_buffer1[tx_rd_index1++];
#if TX_BUFFER_SIZE1 != 256
   if (tx_rd_index1 == TX_BUFFER_SIZE1) tx_rd_index1=0;
#endif
   }
}

// Write a character to the USART1 Transmitter buffer
#pragma used+
void putchar1(char c)
{
while (tx_counter1 == TX_BUFFER_SIZE1);
#asm("cli")
if (tx_counter1 || ((UCSR1A & DATA_REGISTER_EMPTY)==0))
   {
   tx_buffer1[tx_wr_index1++]=c;
#if TX_BUFFER_SIZE1 != 256
   if (tx_wr_index1 == TX_BUFFER_SIZE1) tx_wr_index1=0;
#endif
   ++tx_counter1;
   }
else
   UDR1=c;
#asm("sei")
}
#pragma used-

// Standard Input/Output functions
#include <stdio.h>

// Declare your global variables here
typedef char * CHAR;
//*******************************************************************************************************
//*******************************************************************************************************
int GPSPosition(CHAR input)
{
    if ( strlen(input) >= 10 )
    {
        if (input[5] == 'C' || input[5] == 'c')
            return 1;
        else return 0;
    }
}
int GPSAnten(CHAR input)
{
    if ( strlen(input) >= 10 )
    {
        if (input[5] == 'A' || input[5] == 'a')
            return 1;
        else return 0;
    }
}
void process_gps()
{
    char GPSData[256];
    unsigned char chread;
    unsigned int  loopcount,index=0;
    unsigned int  pkindex;
    loopcount = 0;
    pkindex = 0;
    while (rx_counter1>0)
	{
	    chread=getchar();
	    if ((chread=='$'))
        {                     
            loopcount++;
            if (loopcount == 2)
            {
                 if (GPSPosition(GPSData))
                 {
                    if (strlen(GPSData) > 10)
                    {
                        for (;pkindex >= index;index++)
                            gps_in_e2prom[index]=GPSData[index];
                        trueData = 1;
                    }                
                    else 
                    {
                        trueData = 0;
                    }                
                    break;
                 }
                 else 
                 {
                        strcpy(GPSData,"");
                        pkindex = 0;   
                 }
            }
            else 
            {
                GPSData[pkindex] = chread;
            } 
            
        }
	}

}


CHAR Split (CHAR input, char tag, int Index)
{
      CHAR tmpstr;
      int  CountIndex = 0; 
      int Count;  
      for (Count = 0 ; Count < strlen (input); Count++)
      {
            if (input [Count] == tag)
            {
               if (CountIndex == Index)
               {
                    return tmpstr;
               } 
               else
               {
                    strcpy (tmpstr,"");
                    CountIndex++;
               }
            }  
            else 
            {
                strcat(tmpstr,(CHAR)(input[Count]));
            }
      }  
      return tmpstr;
}
float GPSGetAntenQ (CHAR input)
{
    float Anten = 0.0;
    if ( strlen(input) >= 10 )
    {
        if (input[5] == 'A' || input[5] == 'a')
        {
                Anten = atof(Split(input,',',9));
        }
        else
        {
                Anten = 0.0;
        }
    }
}
void CLSSMS ()
{
        puts("AT+CMGD=1 \r");                  
        delay_ms(1000);
        puts("AT+CMGD=2 \r");                  
        delay_ms(1000);
        puts("AT+CMGD=3 \r");                                 
        delay_ms(1000);

        puts("AT+CMGD=4 \r");                  
        delay_ms(1000);

        puts("AT+CMGD=5 \r");                  
        delay_ms(1000);

        puts("AT+CMGD=6 \r");                  
        delay_ms(1000);

        puts("AT+CMGD=7 \r");                  
        delay_ms(1000);

        puts("AT+CMGD=8 \r");                  
        delay_ms(1000);

        puts("AT+CMGD=9 \r");                  
        delay_ms(1000);

        puts("AT+CMGD=10 \r");                  
        delay_ms(1000);

        puts("AT+CMGD=11 \r");                  
        delay_ms(1000);

        puts("AT+CMGD=12 \r");                  
        delay_ms(1000);

        puts("AT+CMGD=13 \r");                  
        delay_ms(1000);

        puts("AT+CMGD=14 \r");                  
        delay_ms(1000);

        puts("AT+CMGD=15 \r");                  
        delay_ms(1000);

} 
void poweron(void)
{
    unsigned char i,ch1,ch2;

    while (rx_counter0>0)	getchar();
    while (1)
	{
	    for (i=0;i<20;i++)
		{
		    putchar('A');
		    putchar('T');
		    putchar(13);
		    putchar (10);
		    delay_ms(50);
		}
	    while (rx_counter0>0)
		{
		    ch1=ch2;
		    ch2=getchar();
		    if ((ch1=='O') && (ch2=='K'))
			{
			    while (rx_counter0>0)	getchar();
			    return;
			}
		}

	}
}
void init(void)
{
    unsigned char ch1,ch2,i,flag;
    delay_ms(100);

    poweron();

    flag=1;
    while (flag)
	{
	    putchar ('A');
	    putchar ('T');
	    putchar ('E');
	    putchar ('0');
	    putchar (13);
	    putchar (10);
	    delay_ms(50);
	    while (rx_counter0>0)
		{
		    ch1=ch2;
		    ch2=getchar();
		    if ((ch1=='O') && (ch2=='K'))	{flag=0;break;}
		}
	    while (rx_counter0>0)	getchar();
	}  	
    flag=1;
    while (flag)
	{
	    putchar ('A');
	    putchar ('T');
	    putchar ('+');
	    putchar ('C');
	    putchar ('M');
	    putchar ('G');
	    putchar ('F');
	    putchar ('=');
	    putchar ('1');
	    putchar (13);
	    putchar (10);
	    delay_ms(100);
	    while (rx_counter0>0)
		{
		    ch1=ch2;
		    ch2=getchar();
		    if ((ch1=='O') && (ch2=='K'))	{flag=0;break;}
		}
	    while (rx_counter0>0)	getchar();
	}  	
    for (i=1;i<=9;i++)
	{
	    putchar ('A');
	    putchar ('T');
	    putchar ('+');
	    putchar ('C');
	    putchar ('M');
	    putchar ('G');
	    putchar ('D');
	    putchar ('=');
	    putchar (i+48);
	    putchar (13);
	    putchar (10);
	    delay_ms(50);
	}

    while (rx_counter0>0)	getchar();
}
void SendSMS(CHAR Massage)
{       
     puts("AT \r");                  
     delay_ms(20);                     
     puts("AT+CMGF=1 \r");
     delay_ms(20);   
     puts("AT+CMGS=\"09384198683\" \r");
     delay_ms(300);
     puts(Massage);
     putchar(0x1A);
     delay_ms(20);
     puts("AT+CMGD=1 \r");
     delay_ms(1000);
     puts("AT+CMGD=2 \r");
     delay_ms(1000);
     puts("AT+CMGD=3 \r");
     delay_ms(1000);
     puts("AT+CMGD=4 \r");
     delay_ms(1000);
     puts("AT+CMGD=5 \r");
     delay_ms(1000);
     puts("AT+CMGD=6 \r");
     delay_ms(1000);
     
}

void SendSMSToNum(CHAR tel,CHAR Massage)
{   
     char tmp [];
     puts("AT \r");                  
     delay_ms(20);                     
     puts("AT+CMGF=1 \r");
     delay_ms(20);    
     tmp[0] = 'A';
     tmp[1] = 'T';
     tmp[2] = '+';
     tmp[3] = 'C';
     tmp[4] = 'M';
     tmp[5] = 'G';
     tmp[6] = 'S';
     tmp[7] = '=';
     tmp[8] = '"';
     tmp[9] = tel[0];
     tmp[10] = tel[1];
     tmp[11] = tel[2];
     tmp[12] = tel[3];
     tmp[13] = tel[4];
     tmp[14] = tel[5];
     tmp[15] = tel[6];
     tmp[16] = tel[7];
     tmp[17] = tel[8];
     tmp[18] = tel[9];
     tmp[19] = tel[10];
     tmp[20] = '"';
     tmp[21] = ' ';
     tmp[22] = '\r';
     puts(tmp);
     delay_ms(300);
     puts(Massage);
     putchar(0x1A);
     delay_ms(20);
     puts("AT+CMGD=1 \r");
     delay_ms(1000);
     puts("AT+CMGD=2 \r");
     delay_ms(1000);
     puts("AT+CMGD=3 \r");
     delay_ms(1000);
     puts("AT+CMGD=4 \r");
     delay_ms(1000);
     puts("AT+CMGD=5 \r");
     delay_ms(1000);
     puts("AT+CMGD=6 \r");
     delay_ms(1000);
     
}

void process_sms(void)
{
    unsigned char tmp [];
    unsigned char pos [];
    unsigned char ch1,ch2,ch3,ch4,ch5;
    unsigned char i,temp,sms_valid=0;
    unsigned int data_length, index,tagpos;             

    data_length=sms_in_e2prom[0];
    if (data_length>16) data_length=10;
    delay_ms(5000);
    data_length=sms_in_e2prom[0];
    for (i=1;i<=data_length;i++)
	{
	    ch1=ch2;
	    ch2=ch3;
	    ch3=ch4;
	    ch4=ch5;
	    ch5=sms_in_e2prom[i];

	    if ((ch1=='X') && (ch2=='1') && (ch3=='1') && (ch4=='0') && (ch5=='0'))	{sms_valid=1;break;}
	}

    if (!sms_valid)	
    {
        CLSSMS();
        delay_ms(1000);
        return;
    }
    
    tmp [0]=sms_in_e2prom[i+1];
    tmp [1]=sms_in_e2prom[i+2];
    tmp [2]=sms_in_e2prom[i+3];
    if (tmp[0] == 'p' && tmp[1] == 'o' && tmp[2] == 's')
    {       
        index  = -1;                
        tagpos = 0;
        while (1)
        {                       
            
            ch1 = getchar1();
            if (ch1 == '$' && tagpos == 1)
            {          
                    if(GPSPosition(pos))
                        break;          
                    else 
                    {
                        index  = 0;
                        tagpos = 0;
                    }
            }     
            else if (ch1 == '$')
            {
                tagpos++;             
                index = 0;
            }
            else
                index++;
            pos[index] = ch1;
        }
            SendSMS(pos);
            //SendSMSToNum(caller_id,pos);
    }   
    else
    {
        SendSMS(tmp);
    }

}  
void process_data(void)
{
    unsigned char ch1,ch2,ch3,ch4,ch5,ch6;
    unsigned char i=0,memory_index,temp,sms_ready=0;

    data_ready=0;
    delay_ms(1000);
    
    while (rx_counter0>0)
	{
	    ch1=ch2;
	    ch2=ch3;
	    ch3=ch4;
	    ch4=ch5;
	    ch5=ch6;
	    ch6=getchar();
	    if ((ch1=='+') && (ch2=='C') && (ch3=='M') && (ch4=='T') && (ch5=='I') && (ch6==':'))	{sms_ready=1;break;}
	}
    if (!sms_ready)	return;
    delay_ms(1000);
    while (rx_counter0>0)	getchar();
    putchar('a');
    putchar('t');
    putchar('+');
    putchar('c');
    putchar('m');
    putchar('g');
    putchar('r');
    putchar('=');
    putchar('1');
    putchar(13);
    putchar(10);
     for(i=0;i<=9;i++)
{
        puts("AT+CGPSPWR=1 \r");                  
        delay_ms(1000);
        puts("AT+CGPSRST=1 \r");                  
        delay_ms(1000);
}
    for (i=0;i<3;i++)	while(getchar()!='"');
    for (i=0;i<20;i++) caller_id[i]=0;
    for (i=1;i<20;i++)
	{
	    temp=getchar();
	    if (temp=='"') break;
	    caller_id[i]=temp;
	}
    caller_id[0]=i-1;
    delay_ms(1000);
    while (rx_counter0!=0)
	{
	    ch1=ch2;
	    ch2=getchar();
	    if ((ch1==13)&&(ch2==10)) break;
	}

    i=0;
    while (1)
	{
	    ch1=ch2;
	    ch2=getchar();
	    if ((ch1='O')&&(ch2=='K')) break;
	
	    sms_in_e2prom[++i]=ch2;
	}
    sms_in_e2prom[0]=i;
    while (rx_counter0>0)	getchar();

    for (i=1;i<=9;i++)
	{
	    putchar ('a');
    	putchar ('t');
	    putchar ('+');
	    putchar ('c');
	    putchar ('m');
	    putchar ('g');
	    putchar ('d');
	    putchar ('=');
	    putchar (i+48);
	    putchar (13);
	    putchar (10);
	}
    delay_ms(200);
    while (rx_counter0>0)	getchar();
    process_sms();
}

void CallTest ()
{
    puts("ATD 09384198683 \r");
}

void ClearBuffer ()
{
    int Count;
    for (Count = 0; Count < rx_counter0; Count++)
    {
        rx_buffer0[Count] = '';
    }
}
//*******************************************************************************************************
//*******************************************************************************************************
int count;
char chr;
int len;
char read[];
char *tmp;

void main(void)
{


// Input/Output Ports initialization
// Port A initialization
// Func7=In Func6=Out Func5=In Func4=In Func3=Out Func2=Out Func1=In Func0=In 
// State7=T State6=0 State5=T State4=T State3=0 State2=0 State1=T State0=T 
PORTA=0x00;
DDRA=0x4C;

// Port B initialization
// Func7=In Func6=In Func5=Out Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=0 State4=T State3=T State2=T State1=T State0=T 
PORTB=0x00;
DDRB=0x20;

// Port C initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=Out Func1=Out Func0=Out 
// State7=T State6=T State5=T State4=T State3=T State2=0 State1=0 State0=0 
PORTC=0x00;
DDRC=0x07;

// Port D initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
PORTD=0x00;
DDRD=0x00;

// Port E initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
PORTE=0x00;
DDRE=0x00;

// Port F initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
PORTF=0x00;
DDRF=0x00;

// Port G initialization
// Func4=In Func3=In Func2=In Func1=In Func0=In 
// State4=T State3=T State2=T State1=T State0=T 
PORTG=0x00;
DDRG=0x00;

// Timer/Counter 0 initialization
// Clock source: System Clock
// Clock value: Timer 0 Stopped
// Mode: Normal top=0xFF
// OC0 output: Disconnected
ASSR=0x00;
TCCR0=0x00;
TCNT0=0x00;
OCR0=0x00;

// Timer/Counter 1 initialization
// Clock source: System Clock
// Clock value: Timer1 Stopped
// Mode: Normal top=0xFFFF
// OC1A output: Discon.
// OC1B output: Discon.
// OC1C output: Discon.
// Noise Canceler: Off
// Input Capture on Falling Edge
// Timer1 Overflow Interrupt: Off
// Input Capture Interrupt: Off
// Compare A Match Interrupt: Off
// Compare B Match Interrupt: Off
// Compare C Match Interrupt: Off
TCCR1A=0x00;
TCCR1B=0x00;
TCNT1H=0x00;
TCNT1L=0x00;
ICR1H=0x00;
ICR1L=0x00;
OCR1AH=0x00;
OCR1AL=0x00;
OCR1BH=0x00;
OCR1BL=0x00;
OCR1CH=0x00;
OCR1CL=0x00;

// Timer/Counter 2 initialization
// Clock source: System Clock
// Clock value: Timer2 Stopped
// Mode: Normal top=0xFF
// OC2 output: Disconnected
TCCR2=0x00;
TCNT2=0x00;
OCR2=0x00;

// Timer/Counter 3 initialization
// Clock source: System Clock
// Clock value: Timer3 Stopped
// Mode: Normal top=0xFFFF
// OC3A output: Discon.
// OC3B output: Discon.
// OC3C output: Discon.
// Noise Canceler: Off
// Input Capture on Falling Edge
// Timer3 Overflow Interrupt: Off
// Input Capture Interrupt: Off
// Compare A Match Interrupt: Off
// Compare B Match Interrupt: Off
// Compare C Match Interrupt: Off
TCCR3A=0x00;
TCCR3B=0x00;
TCNT3H=0x00;
TCNT3L=0x00;
ICR3H=0x00;
ICR3L=0x00;
OCR3AH=0x00;
OCR3AL=0x00;
OCR3BH=0x00;
OCR3BL=0x00;
OCR3CH=0x00;
OCR3CL=0x00;

// External Interrupt(s) initialization
// INT0: Off
// INT1: Off
// INT2: Off
// INT3: Off
// INT4: Off
// INT5: Off
// INT6: Off
// INT7: Off
EICRA=0x00;
EICRB=0x00;
EIMSK=0x00;

// Timer(s)/Counter(s) Interrupt(s) initialization
TIMSK=0x00;

ETIMSK=0x00;

// USART0 initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART0 Receiver: On
// USART0 Transmitter: On
// USART0 Mode: Asynchronous
// USART0 Baud Rate: 9600 (Double Speed Mode)
UCSR0A=0x02;
UCSR0B=0xD8;
UCSR0C=0x06;
UBRR0H=0x00;
UBRR0L=0x67;

// USART1 initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART1 Receiver: On
// USART1 Transmitter: On
// USART1 Mode: Asynchronous
// USART1 Baud Rate: 4800 (Double Speed Mode)
UCSR1A=0x02;
UCSR1B=0xD8;
UCSR1C=0x06;
UBRR1H=0x00;
UBRR1L=0xCF;

// Analog Comparator initialization
// Analog Comparator: Off
// Analog Comparator Input Capture by Timer/Counter 1: Off
ACSR=0x80;
SFIOR=0x00;

// ADC initialization
// ADC Clock frequency: 1000.000 kHz
// ADC Voltage Reference: AVCC pin
ADMUX=ADC_VREF_TYPE & 0xff;
ADCSRA=0x8B;

// SPI initialization
// SPI disabled
SPCR=0x00;

// TWI initialization
// TWI disabled
TWCR=0x00;

// Global enable interrupts
#asm("sei")
POWER=1;
delay_ms(2000);
POWER=0;
delay_ms(3000);  
count =0;    
len = 0;
init();
CLSSMS();
delay_ms(1000);

while (1)
      { 

            if (rx_counter0)
		    {
		        TCCR1A=0x03;
		        delay_ms(2000);
		        process_data();
		        TCCR1A=0x83;
		    }
            /*if (rx_counter1)
            {
                process_gps();
           } 
           */


      }
}
