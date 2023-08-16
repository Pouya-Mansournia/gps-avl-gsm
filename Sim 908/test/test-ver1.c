///////////////////////////////////////////////////////////////////////////////
#include <mega64.h>
#include <delay.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
///////////////////////////////////////////////////////////////////////////////
bit data_ready=0,trueData=0;
unsigned char caller_id[20];
char sms[50];
int count;
int len;
eeprom unsigned char sms_in_e2prom[256],setpoint_saved,gps_in_e2prom[256];
void Security(void);
void process_data(void);
void process_sms(void);
void gpspwr(void);
void CLSSMS (void);
void poweron(void);
void echooff(void);
void read_gps(void);
void Batt(void);
void getAntenna();

char *securityMode = "OFF";
//////////////////////////////////////////////////////////////////////////////
#define pwr    PORTD.5
#define alarm  PORTB.6
#define relay  PORTB.5
#define buzzer PORTB.4
#define led1   PORTC.0
#define led2   PORTC.1
#define led3   PORTC.2
#define led_m  PORTD.7
/////////////////////////
//PINC.5
//PINC.6
///////////////////////////////////////////////////////////////////////////////
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
#define RX_BUFFER_SIZE0 80
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
#define TX_BUFFER_SIZE0 40
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
#define RX_BUFFER_SIZE1 100
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
   if (++rx_counter1 == 0) rx_buffer_overflow1=1;
#else
   if (rx_wr_index1 == RX_BUFFER_SIZE1) rx_wr_index1=0;
   if (++rx_counter1 == RX_BUFFER_SIZE1)
      {
      rx_counter1=0;
      rx_buffer_overflow1=1;
      }
#endif
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
// Standard Input/Output functions
#include <stdio.h>
/////////////////////////
void GPSRST()
{
putchar ('A');
putchar ('T');
putchar ('+');
putchar ('C');
putchar ('G');
putchar ('P');
putchar ('S');
putchar ('R');
putchar ('S');
putchar ('T');
putchar ('=');
putchar ('1');
delay_ms(20);
putchar (13);
putchar (10);
delay_ms(5000);
}
typedef char * CHAR;
//*******************************************************************************************************
//*******************************************************************************************************
int GPSPosition(CHAR input)
{
    if ( strlen(input) >= 10 )
    {
        if (input[5] == 'C' || input[5] == 'c')
            return 1;
        else 
        {
            return 0;
        }
    }   
    return 0;
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
	    chread=getchar1();
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

///////////////////////////////////////////////////////////////////
void main(void)
{
PORTA=0x00;
DDRA=0x00;
PORTB=0x00;
DDRB=0x70;
PORTC=0x00;
DDRC=0x07;
PORTD=0x00;
DDRD=0xA0;

TCNT0=0x00;
TCCR1A=0x00;
TCCR1B=0x00;
TCCR2=0x00;
TCCR3A=0x00;
TCCR3B=0x00;

// External Interrupt(s) initialization
EICRA=0x00;
EICRB=0x00;
EIMSK=0x00;

// Timer(s)/Counter(s) Interrupt(s) initialization
TIMSK=0x00;

ETIMSK=0x00;

UCSR0A=0x00;
UCSR0B=0xD8;
UCSR0C=0x06;
UBRR0H=0x00;
UBRR0L=0x2F;
UCSR1A=0x00;
UCSR1B=0x90;
UCSR1C=0x06;
UBRR1H=0x00;
UBRR1L=0x2F;

ACSR=0x80;
SFIOR=0x00;

// ADC initialization
// ADC disabled
ADCSRA=0x00;

// SPI initialization
// SPI disabled
SPCR=0x00;

// TWI initialization
// TWI disabled
TWCR=0x00;

// Global enable interrupts
#asm("sei")

led1=1;
pwr=1;
delay_ms(1500);
pwr=0;
delay_ms(10000);
poweron();
echooff();
alarm=1;delay_ms(75);alarm=0;
CLSSMS();
gpspwr();
GPSRST();
alarm=1;delay_ms(95);alarm=0;
while (rx_counter0>0)	getchar();
while (1)
      {
      led1=0;
      led_m=!led_m; delay_ms(150);
      if (rx_counter0) process_data();
      led3=!led3; delay_ms(200);
      if( securityMode[1] == 'N' )
      Security();
      //Batt();
      }
}

//////////////////////////////////////////////
void CLSSMS ()
{
        delay_ms(1000);
        puts("AT+CMGD=1 \r");delay_ms(1000);
        puts("AT+CMGD=2 \r");delay_ms(1000);
        puts("AT+CMGD=3 \r");delay_ms(1000);
        puts("AT+CMGD=4 \r");delay_ms(1000);
        puts("AT+CMGD=5 \r");delay_ms(1000);
        puts("AT+CMGD=6 \r");delay_ms(1000);
        puts("AT+CMGD=7 \r");delay_ms(1000);
        puts("AT+CMGD=8 \r");delay_ms(1000);
        puts("AT+CMGD=9 \r");delay_ms(1000);
        puts("AT+CMGD=10 \r");delay_ms(1000);
        puts("AT+CMGD=11 \r");delay_ms(1000);
        puts("AT+CMGD=12 \r");delay_ms(1000);
        puts("AT+CMGD=1 \r");delay_ms(1000);
}
//////////////////////////////////////////////////////     
void gpspwr()
{
        unsigned char ch1,ch2,flag;
        while (rx_counter0>0)    getchar();
        
        delay_ms(100);
        putchar ('A');
        putchar ('T');
        putchar ('+');
        putchar ('C');
        putchar ('M');
        putchar ('G');
        putchar ('F');
        putchar ('=');
        putchar ('1');
        delay_ms(10);
        putchar (13);
        putchar (10);
        delay_ms(100);
        while (rx_counter0>0)
        {
            ch1=ch2;
            ch2=getchar();
            if ((ch1=='O') && (ch2=='K'))    {flag=0;break;}
        }
        while (rx_counter0>0)    getchar();
        delay_ms(100);
        putchar('A');
        delay_ms(10);
    	putchar ('T');
        delay_ms(10);
        putchar (13);
	    putchar (10);
        delay_ms(80);
        putchar (13);
	    putchar (10);
        delay_ms(20);
////////////////////////////////////////////////////           
        putchar ('A');
    	putchar ('T');
	    putchar ('+');
	    putchar ('C');
	    putchar ('G');
	    putchar ('P');
	    putchar ('S');
	    putchar ('P');
	    putchar ('W');
        putchar ('R');
        putchar ('=');
        putchar ('1');
        delay_ms(10);
	    putchar (13);
	    putchar (10);
        delay_ms(80);
        delay_ms(1900);
///////////////////////////////////////////////////////
        putchar ('A');
    	putchar ('T');
	    putchar ('+');
	    putchar ('C');
	    putchar ('G');
	    putchar ('P');
	    putchar ('S');
	    putchar ('R');
	    putchar ('S');
        putchar ('T');
        putchar ('=');
        putchar ('1');
        delay_ms(20);
	    putchar (13);
	    putchar (10);
        delay_ms(280);
////////////////////////////////////////////////////////
        puts("AT+CMGS=\"09384198683\" \r");
        putchar (13);
	    putchar (10);
        delay_ms(180);
        printf("GSM ON");
        delay_ms(90);
        putchar (26);
        delay_ms(200);  
}
//////////////////////////////////////////////////////////////////  
typedef char * CHAR;
void SendSMS(CHAR Massage)
{    
     
        puts("AT+CMGS=\"09384198683\" \r");
        putchar (13);
	    putchar (10);
        delay_ms(180);
        puts(Massage);
        delay_ms(90);
        putchar (26);
        delay_ms(200);
}
///////////////////////////////////////////////////////////////////////////////
void process_sms(void)
{
    int counter=0;
    int faildGPS = 0;
    unsigned char tmp [];
    unsigned char pos [];
    unsigned char ch1,ch2,ch3,ch4,ch5,ch6,ch7,ch8,catch[5];
    unsigned char i,temp,sms_valid=0;
    unsigned int data_length, index,tagpos;             
    
    int lastGetTrueCode=0;
    
    data_length=sms_in_e2prom[0];
    if (data_length>10) data_length=10;

    for (i=1;i<=data_length;i++)
	{
	    ch1=ch2;
	    ch2=ch3;
	    ch3=ch4;
	    ch4=ch5;
        ch5=ch6;
        ch6=ch7;
        ch7=ch8;
	    ch8=sms_in_e2prom[i];
        if ((ch8>='a')&&(ch8<='z')) ch8-=32;

	    if ((ch1=='P') && (ch2=='1') && (ch3=='3') && (ch4=='9') && (ch5=='1'))	{sms_valid=1;break;}
        if ((ch4=='A') && (ch5=='L') && (ch6=='A') && (ch7=='R') && (ch8=='M'))	{sms_valid=2;break;}
	    if ((ch3=='S') && (ch4=='I') && (ch5=='L') && (ch6=='E') && (ch7=='N') && (ch8=='T'))	{sms_valid=3;break;}
        if ((ch5=='S') && (ch6=='T') && (ch7=='O') && (ch8=='P'))	{sms_valid=4;break;}
        if ((ch4=='S') && (ch5=='E') && (ch6=='C') && (ch7=='O') && (ch8=='N'))	{sms_valid=5;break;}
        if ((ch3=='S') && (ch4=='E') && (ch5=='C') && (ch6=='O') && (ch7=='F') && (ch8=='F'))	{sms_valid=6;break;}
        if ((ch3=='G') && (ch4=='E') && (ch5=='T') && (ch6=='A') && (ch7=='N') && (ch8=='T'))	{sms_valid=7;break;}
	}

    if (!sms_valid)	
    {
        CLSSMS();
        delay_ms(1000);
        SendSMS("invalid command!");
        return;
    }
    

    switch (sms_valid)
    {       
        case 1:
        counter = 0;   
        faildGPS = 0;
        index  = -1;                
        tagpos = 0;
        lastGetTrueCode=0;
        delay_ms(1000);
        
        while (rx_counter1>0) getchar1();
        
        buzzer=1;
        
        while (1)
        {
            ch1=getchar1();
                                               
            switch( lastGetTrueCode )
            {
                case 0:
                    if( ch1 == 'A' )
                        lastGetTrueCode = 1;
                break;
                case 1:
                    if( ch1 == 'N' )
                        lastGetTrueCode = 2;
                break;
                case 2:
                    if( ch1 == ',' )
                        lastGetTrueCode = 3;
                break;
                case 3:
                    if( ch1 == ',' )
                        lastGetTrueCode = 4;
                break;
                case 4:
                    if( ch1 == 'E' || ch1 == 'W' )
                        lastGetTrueCode = 5;
                break;
                case 5:
                    if( ch1 == ',' )
                        lastGetTrueCode = 6;
                break;
            }
             
            if (ch1 == '$' && tagpos )
            {          
                    if(GPSPosition(pos) && lastGetTrueCode == 6)
                    {
                        faildGPS = 0;
                        break;
                    }          
                    else 
                    {
                        counter++;
                        index  = 0;
                        tagpos = 0;
                        lastGetTrueCode = 0;
                    }
            }     
            else if (ch1 == '$')
            {  
                counter++;
                tagpos++;             
                index = 0;
                lastGetTrueCode = 0; 
            }
            else
                index++;
            
            if( counter > 500 )
            {
                faildGPS = 1;
                break;
            }
            
            pos[index] = ch1;
        }   
                        
            if( faildGPS )
            {
                SendSMS("data is faild !!!");
            }
            else
            {
                SendSMS(pos);
            }
            
            buzzer=0;
            //SendSMSToNum(caller_id,pos);
        
        break;
        case 2:
            alarm=1;
            delay_ms(2000);
            puts("AT+CMGS=\"09384198683\" \r");
            putchar (13);
            putchar (10);
            delay_ms(180);
            printf("Alarm ON");
            delay_ms(90);
            putchar (26);
            delay_ms(200);
            alarm=1;
        break;
        case 3:
            buzzer=0;
            alarm=0;
            relay=0;
            delay_ms(2000);
            puts("AT+CMGS=\"09384198683\" \r");
            putchar (13);
            putchar (10);
            delay_ms(180);
            printf("Silent ON");
            delay_ms(90);
            putchar (26);
            delay_ms(200);
        break;
        case 4:
            relay=1;
            delay_ms(2000);
            puts("AT+CMGS=\"09384198683\" \r");
            putchar (13);
            putchar (10);
            delay_ms(180);
            printf("Stop ON");
            delay_ms(90);
            putchar (26);
            delay_ms(200);
        break;
        case 5:
            alarm=1;
            delay_ms(70);
            alarm=0;
            delay_ms(2000);
            puts("AT+CMGS=\"09384198683\" \r");
            putchar (13);
            putchar (10);
            delay_ms(180);
            if( securityMode[1] == 'N' )
                printf("SECURITY was ON");
            else                       
                printf("SECURITY is ON");
            delay_ms(90);
            putchar (26);
            delay_ms(200);
            securityMode[0] = 'O';
            securityMode[1] = 'N';
        break;
        case 6:
            alarm=1;
            delay_ms(70);
            alarm=0;
            delay_ms(2000);
            puts("AT+CMGS=\"09384198683\" \r");
            putchar (13);
            putchar (10);
            delay_ms(180);
            if( securityMode[1] == 'N' )
                printf("SECURITY is OFF");
            else                       
                printf("SECURITY was OFF");
            delay_ms(90);
            putchar (26);
            delay_ms(200);
            alarm=0;
            securityMode[0] = 'O';
            securityMode[1] = 'F';
            securityMode[2] = 'F';
        break;
        case 7:
            delay_ms(2000);
            getAntenna();
        break;
        default:
            SendSMS("invalid command");
            relay=0;
        break;
        }
    
}  
///////////////////////////////////////////////////////////////////////////////
void process_data(void)
{
    unsigned char ch1,ch2,ch3,ch4,ch5,ch6;
    unsigned char i=0,memory_index,temp,sms_ready=0;
    data_ready=0;
    delay_ms(1000);
    
    led1=1;
    
    while (rx_counter0>0)
	{
	    ch1=ch2;
	    ch2=ch3;
	    ch3=ch4;
	    ch4=ch5;
	    ch5=ch6;
	    ch6=getchar();
        //buzzer=1;delay_ms(50);   
        //buzzer=0;delay_ms(50);     
	    if ((ch1=='+') && (ch2=='C') && (ch3=='M') && (ch4=='T') && (ch5=='I') && (ch6==':'))	{buzzer=1;delay_ms(100);buzzer=0;sms_ready=1;break;}
	}
    if (!sms_ready)	return;
    
   delay_ms(1000);
/*    
    while(getchar()!=',');
    char1=getchar();
    //char2=getchar();
    //char3=getchar();

        puts("AT+CMGS=\"09384198683\" \r");
        putchar (13);
	    putchar (10);
        delay_ms(180);
        putchar(char1);delay_ms(50);
        //putchar(char2);delay_ms(50);
        //putchar(char3);delay_ms(50);
        putchar('.');delay_ms(50);
        delay_ms(90);
        putchar (26);
        delay_ms(200);
        
        delay_ms(15000);
        delay_ms(2000);
    
 */
    while (rx_counter0>0)	getchar();
    
        led1=0;led2=1;
    
    putchar('A');//delay_ms(50);
    putchar('T');//delay_ms(50);
    putchar('+');//delay_ms(50);
    putchar('C');//delay_ms(50);
    putchar('M');//delay_ms(50);
    putchar('G');//delay_ms(50);
    putchar('R');//delay_ms(50);
    putchar('=');//delay_ms(50);
    putchar('1');//delay_ms(50);
    putchar(13);//delay_ms(50);
    putchar(10);//delay_ms(50);
    delay_ms(6000);
 
    for (i=0;i<3;i++)	while(getchar()!='"');

//    alarm=1;delay_ms(1000);alarm=0;    

    
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
    
//    alarm=1;delay_ms(1000);alarm=0;
    
    puts("AT+CMGD=1 \r");delay_ms(1000);
    puts("AT+CMGD=1 \r");delay_ms(1000);
    puts("AT+CMGD=2 \r");delay_ms(1000);
    process_sms();

    
}
///////////////////////////////////////////////////////////////////////////////
void echooff(void)
{
bit flag=1;
char ch1,ch2;
while (flag)
	{
	putchar ('A');delay_ms(50);
	putchar ('T');delay_ms(50);
	putchar ('E');delay_ms(50);
	putchar ('0');delay_ms(50);
	putchar (13);delay_ms(50);
	putchar (10);delay_ms(50);
	delay_ms(500);
	while (rx_counter0>0)
		{
		ch1=ch2;
		ch2=getchar();
		if ((ch1=='O') && (ch2=='K'))	{flag=0;break;}
		}
	while (rx_counter0>0)	getchar();
	} 
}
///////////////////////////////////////////////////////////////////////////////
void poweron(void)
{
    unsigned char i,ch1,ch2;
    bit flag=1;

    while (rx_counter0>0)	getchar();

    while (flag)
        {
            putchar('A');delay_ms(50);
            putchar('T');delay_ms(50);
            putchar(13);delay_ms(50);
            putchar (10);delay_ms(50);
            
            delay_ms(500);
            while (rx_counter0>0)
            {
                ch1=ch2;
                ch2=getchar();
                if ((ch1=='O') && (ch2=='K'))	{flag=0;break;}

            }
            while (rx_counter0) getchar();
            }
///////////////////////////////////////////////////////////////            
}
void Security(void)
{
if((PINC.5==0 || PINC.6==0 ) && securityMode[1] == 'N')  ///////Dozdgir//////
 {
  alarm=1;
  delay_ms(8000);
  puts("AT+CMGS=\"09384198683\" \r");
  putchar (13);
  putchar (10);
  delay_ms(180);
  printf("DozD!");
  delay_ms(90);
  putchar (26);
  delay_ms(200); 
 }
 else{alarm=0;};
};
void Batt(void)
{
if(PIND.4==0) //////Power supply off///////
 {
 buzzer=!buzzer; delay_ms(300); 
 led2=1; 
 alarm=!alarm; delay_ms(700);
 led1=!led1; delay_ms(40);    
 delay_ms(5000);
 puts("AT+CMGS=\"09384198683\" \r");
 putchar (13);
 putchar (10);
 delay_ms(180);
 printf("Power Supply off ! Please Check a Car VoltaZh");
 delay_ms(90);
 putchar (26);
 delay_ms(200); 
 }
}; 
void getAntenna()
{   
    int index = 0;
    unsigned char antenna [];
    unsigned char ch1;
    
    while (rx_counter0>0)	getchar();
    putchar('A');
    putchar('T');
    putchar('+');
    putchar('C');
    putchar('S');
    putchar('Q');
    putchar(13);
    putchar(10);
    delay_ms(1000);
    
    while (rx_counter0>0)
    {
        ch1 = getchar();
        antenna[index] = ch1;
        index++;
    }  
    
    SendSMS(antenna);
};
