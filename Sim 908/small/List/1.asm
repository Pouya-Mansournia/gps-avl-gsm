
;CodeVisionAVR C Compiler V2.05.0 Advanced
;(C) Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type                : ATmega64
;Program type             : Application
;Clock frequency          : 7.372800 MHz
;Memory model             : Small
;Optimize for             : Speed
;(s)printf features       : int, width
;(s)scanf features        : int, width
;External RAM size        : 0
;Data Stack size          : 1024 byte(s)
;Heap size                : 0 byte(s)
;Promote 'char' to 'int'  : Yes
;'char' is unsigned       : Yes
;8 bit enums              : Yes
;global 'const' stored in FLASH: No
;Enhanced core instructions    : On
;Smart register allocation     : On
;Automatic register allocation : On

	#pragma AVRPART ADMIN PART_NAME ATmega64
	#pragma AVRPART MEMORY PROG_FLASH 65536
	#pragma AVRPART MEMORY EEPROM 2048
	#pragma AVRPART MEMORY INT_SRAM SIZE 4351
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU XMCRA=0x6D
	.EQU XMCRB=0x6C

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0100
	.EQU __SRAM_END=0x10FF
	.EQU __DSTACK_SIZE=0x0400
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __GETD1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X+
	LD   R22,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _count=R4
	.DEF _len=R6
	.DEF _securityMode=R8
	.DEF _rx_wr_index0=R11
	.DEF _rx_rd_index0=R10
	.DEF _rx_counter0=R13
	.DEF _tx_wr_index0=R12

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _usart0_rx_isr
	JMP  0x00
	JMP  _usart0_tx_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _usart1_rx_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

_tbl10_G100:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G100:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

;REGISTER BIT VARIABLES INITIALIZATION
__REG_BIT_VARS:
	.DW  0x0000

_0x53:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0
_0xF9:
	.DB  LOW(_0x3),HIGH(_0x3)
_0x0:
	.DB  0x4F,0x46,0x46,0x0,0x41,0x54,0x2B,0x43
	.DB  0x4D,0x47,0x44,0x3D,0x31,0x20,0xD,0x0
	.DB  0x41,0x54,0x2B,0x43,0x4D,0x47,0x44,0x3D
	.DB  0x32,0x20,0xD,0x0,0x41,0x54,0x2B,0x43
	.DB  0x4D,0x47,0x44,0x3D,0x33,0x20,0xD,0x0
	.DB  0x41,0x54,0x2B,0x43,0x4D,0x47,0x44,0x3D
	.DB  0x34,0x20,0xD,0x0,0x41,0x54,0x2B,0x43
	.DB  0x4D,0x47,0x44,0x3D,0x35,0x20,0xD,0x0
	.DB  0x41,0x54,0x2B,0x43,0x4D,0x47,0x44,0x3D
	.DB  0x36,0x20,0xD,0x0,0x41,0x54,0x2B,0x43
	.DB  0x4D,0x47,0x44,0x3D,0x37,0x20,0xD,0x0
	.DB  0x41,0x54,0x2B,0x43,0x4D,0x47,0x44,0x3D
	.DB  0x38,0x20,0xD,0x0,0x41,0x54,0x2B,0x43
	.DB  0x4D,0x47,0x44,0x3D,0x39,0x20,0xD,0x0
	.DB  0x41,0x54,0x2B,0x43,0x4D,0x47,0x44,0x3D
	.DB  0x31,0x30,0x20,0xD,0x0,0x41,0x54,0x2B
	.DB  0x43,0x4D,0x47,0x44,0x3D,0x31,0x31,0x20
	.DB  0xD,0x0,0x41,0x54,0x2B,0x43,0x4D,0x47
	.DB  0x44,0x3D,0x31,0x32,0x20,0xD,0x0,0x41
	.DB  0x54,0x2B,0x43,0x4D,0x47,0x53,0x3D,0x22
	.DB  0x30,0x39,0x33,0x38,0x34,0x31,0x39,0x38
	.DB  0x36,0x38,0x33,0x22,0x20,0xD,0x0,0x47
	.DB  0x53,0x4D,0x20,0x4F,0x4E,0x0,0x69,0x6E
	.DB  0x76,0x61,0x6C,0x69,0x64,0x20,0x63,0x6F
	.DB  0x6D,0x6D,0x61,0x6E,0x64,0x21,0x0,0x64
	.DB  0x61,0x74,0x61,0x20,0x69,0x73,0x20,0x66
	.DB  0x61,0x69,0x6C,0x64,0x20,0x21,0x21,0x21
	.DB  0x0,0x41,0x6C,0x61,0x72,0x6D,0x20,0x4F
	.DB  0x4E,0x0,0x53,0x69,0x6C,0x65,0x6E,0x74
	.DB  0x20,0x4F,0x4E,0x0,0x53,0x74,0x6F,0x70
	.DB  0x20,0x4F,0x4E,0x0,0x53,0x45,0x43,0x55
	.DB  0x52,0x49,0x54,0x59,0x20,0x77,0x61,0x73
	.DB  0x20,0x4F,0x4E,0x0,0x53,0x45,0x43,0x55
	.DB  0x52,0x49,0x54,0x59,0x20,0x69,0x73,0x20
	.DB  0x4F,0x4E,0x0,0x53,0x45,0x43,0x55,0x52
	.DB  0x49,0x54,0x59,0x20,0x69,0x73,0x20,0x4F
	.DB  0x46,0x46,0x0,0x53,0x45,0x43,0x55,0x52
	.DB  0x49,0x54,0x59,0x20,0x77,0x61,0x73,0x20
	.DB  0x4F,0x46,0x46,0x0,0x69,0x6E,0x76,0x61
	.DB  0x6C,0x69,0x64,0x20,0x63,0x6F,0x6D,0x6D
	.DB  0x61,0x6E,0x64,0x0,0x44,0x6F,0x7A,0x44
	.DB  0x21,0x0
_0x2020060:
	.DB  0x1
_0x2020000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x01
	.DW  0x02
	.DW  __REG_BIT_VARS*2

	.DW  0x04
	.DW  _0x3
	.DW  _0x0*2

	.DW  0x01
	.DW  _0x2D
	.DW  _0x0*2+3

	.DW  0x01
	.DW  _0x35
	.DW  _0x0*2+3

	.DW  0x0C
	.DW  _0x44
	.DW  _0x0*2+4

	.DW  0x0C
	.DW  _0x44+12
	.DW  _0x0*2+16

	.DW  0x0C
	.DW  _0x44+24
	.DW  _0x0*2+28

	.DW  0x0C
	.DW  _0x44+36
	.DW  _0x0*2+40

	.DW  0x0C
	.DW  _0x44+48
	.DW  _0x0*2+52

	.DW  0x0C
	.DW  _0x44+60
	.DW  _0x0*2+64

	.DW  0x0C
	.DW  _0x44+72
	.DW  _0x0*2+76

	.DW  0x0C
	.DW  _0x44+84
	.DW  _0x0*2+88

	.DW  0x0C
	.DW  _0x44+96
	.DW  _0x0*2+100

	.DW  0x0D
	.DW  _0x44+108
	.DW  _0x0*2+112

	.DW  0x0D
	.DW  _0x44+121
	.DW  _0x0*2+125

	.DW  0x0D
	.DW  _0x44+134
	.DW  _0x0*2+138

	.DW  0x0C
	.DW  _0x44+147
	.DW  _0x0*2+4

	.DW  0x18
	.DW  _0x51
	.DW  _0x0*2+151

	.DW  0x18
	.DW  _0x52
	.DW  _0x0*2+151

	.DW  0x11
	.DW  _0x71
	.DW  _0x0*2+182

	.DW  0x12
	.DW  _0x71+17
	.DW  _0x0*2+199

	.DW  0x18
	.DW  _0x71+35
	.DW  _0x0*2+151

	.DW  0x18
	.DW  _0x71+59
	.DW  _0x0*2+151

	.DW  0x18
	.DW  _0x71+83
	.DW  _0x0*2+151

	.DW  0x18
	.DW  _0x71+107
	.DW  _0x0*2+151

	.DW  0x18
	.DW  _0x71+131
	.DW  _0x0*2+151

	.DW  0x10
	.DW  _0x71+155
	.DW  _0x0*2+308

	.DW  0x0C
	.DW  _0xCD
	.DW  _0x0*2+4

	.DW  0x0C
	.DW  _0xCD+12
	.DW  _0x0*2+4

	.DW  0x0C
	.DW  _0xCD+24
	.DW  _0x0*2+16

	.DW  0x18
	.DW  _0xEE
	.DW  _0x0*2+151

	.DW  0x02
	.DW  0x08
	.DW  _0xF9*2

	.DW  0x01
	.DW  __seed_G101
	.DW  _0x2020060*2

_0xFFFFFFFF:
	.DW  0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30
	STS  XMCRB,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x500

	.CSEG
;///////////////////////////////////////////////////////////////////////////////
;#include <mega64.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif
;#include <delay.h>
;#include <stdio.h>
;#include <stdlib.h>
;#include <string.h>
;///////////////////////////////////////////////////////////////////////////////
;bit data_ready=0,trueData=0;
;unsigned char caller_id[20];
;char sms[50];
;int count;
;int len;
;eeprom unsigned char sms_in_e2prom[256],setpoint_saved,gps_in_e2prom[256];
;void Security(void);
;void process_data(void);
;void process_sms(void);
;void gpspwr(void);
;void CLSSMS (void);
;void poweron(void);
;void echooff(void);
;void read_gps(void);
;void Batt(void);
;void getAntenna();
;
;char *securityMode = "OFF";

	.DSEG
_0x3:
	.BYTE 0x4
;//////////////////////////////////////////////////////////////////////////////
;#define  led_U PORTA.2
;#define  led_D PORTB.5
;#define  POWER PORTC.0
;///////////////////////////////////////////////////////////////////////////////
;#ifndef RXB8
;#define RXB8 1
;#endif
;
;#ifndef TXB8
;#define TXB8 0
;#endif
;
;#ifndef UPE
;#define UPE 2
;#endif
;
;#ifndef DOR
;#define DOR 3
;#endif
;
;#ifndef FE
;#define FE 4
;#endif
;
;#ifndef UDRE
;#define UDRE 5
;#endif
;
;#ifndef RXC
;#define RXC 7
;#endif
;
;#define FRAMING_ERROR (1<<FE)
;#define PARITY_ERROR (1<<UPE)
;#define DATA_OVERRUN (1<<DOR)
;#define DATA_REGISTER_EMPTY (1<<UDRE)
;#define RX_COMPLETE (1<<RXC)
;
;// USART0 Receiver buffer
;#define RX_BUFFER_SIZE0 80
;char rx_buffer0[RX_BUFFER_SIZE0];
;
;#if RX_BUFFER_SIZE0 <= 256
;unsigned char rx_wr_index0,rx_rd_index0,rx_counter0;
;#else
;unsigned int rx_wr_index0,rx_rd_index0,rx_counter0;
;#endif
;
;// This flag is set on USART0 Receiver buffer overflow
;bit rx_buffer_overflow0;
;
;// USART0 Receiver interrupt service routine
;interrupt [USART0_RXC] void usart0_rx_isr(void)
; 0000 0050 {

	.CSEG
_usart0_rx_isr:
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0051 char status,data;
; 0000 0052 status=UCSR0A;
	ST   -Y,R17
	ST   -Y,R16
;	status -> R17
;	data -> R16
	IN   R17,11
; 0000 0053 data=UDR0;
	IN   R16,12
; 0000 0054 if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
	MOV  R30,R17
	ANDI R30,LOW(0x1C)
	BRNE _0x4
; 0000 0055    {
; 0000 0056    rx_buffer0[rx_wr_index0++]=data;
	MOV  R30,R11
	INC  R11
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	ST   Z,R16
; 0000 0057 #if RX_BUFFER_SIZE0 == 256
; 0000 0058    // special case for receiver buffer size=256
; 0000 0059    if (++rx_counter0 == 0)
; 0000 005A       {
; 0000 005B #else
; 0000 005C    if (rx_wr_index0 == RX_BUFFER_SIZE0) rx_wr_index0=0;
	LDI  R30,LOW(80)
	CP   R30,R11
	BRNE _0x5
	CLR  R11
; 0000 005D    if (++rx_counter0 == RX_BUFFER_SIZE0)
_0x5:
	INC  R13
	LDI  R30,LOW(80)
	CP   R30,R13
	BRNE _0x6
; 0000 005E       {
; 0000 005F       rx_counter0=0;
	CLR  R13
; 0000 0060 #endif
; 0000 0061       rx_buffer_overflow0=1;
	SET
	BLD  R2,2
; 0000 0062       }
; 0000 0063    }
_0x6:
; 0000 0064 }
_0x4:
	LD   R16,Y+
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	RETI
;
;#ifndef _DEBUG_TERMINAL_IO_
;// Get a character from the USART0 Receiver buffer
;#define _ALTERNATE_GETCHAR_
;#pragma used+
;char getchar(void)
; 0000 006B {
_getchar:
; 0000 006C char data;
; 0000 006D while (rx_counter0==0);
	ST   -Y,R17
;	data -> R17
_0x7:
	TST  R13
	BREQ _0x7
; 0000 006E data=rx_buffer0[rx_rd_index0++];
	MOV  R30,R10
	INC  R10
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	LD   R17,Z
; 0000 006F #if RX_BUFFER_SIZE0 != 256
; 0000 0070 if (rx_rd_index0 == RX_BUFFER_SIZE0) rx_rd_index0=0;
	LDI  R30,LOW(80)
	CP   R30,R10
	BRNE _0xA
	CLR  R10
; 0000 0071 #endif
; 0000 0072 #asm("cli")
_0xA:
	cli
; 0000 0073 --rx_counter0;
	DEC  R13
; 0000 0074 #asm("sei")
	sei
	RJMP _0x20A0007
; 0000 0075 return data;
; 0000 0076 }
;#pragma used-
;#endif
;
;// USART0 Transmitter buffer
;#define TX_BUFFER_SIZE0 40
;char tx_buffer0[TX_BUFFER_SIZE0];
;
;#if TX_BUFFER_SIZE0 <= 256
;unsigned char tx_wr_index0,tx_rd_index0,tx_counter0;
;#else
;unsigned int tx_wr_index0,tx_rd_index0,tx_counter0;
;#endif
;
;// USART0 Transmitter interrupt service routine
;interrupt [USART0_TXC] void usart0_tx_isr(void)
; 0000 0086 {
_usart0_tx_isr:
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0087 if (tx_counter0)
	LDS  R30,_tx_counter0
	CPI  R30,0
	BREQ _0xB
; 0000 0088    {
; 0000 0089    --tx_counter0;
	SUBI R30,LOW(1)
	STS  _tx_counter0,R30
; 0000 008A    UDR0=tx_buffer0[tx_rd_index0++];
	LDS  R30,_tx_rd_index0
	SUBI R30,-LOW(1)
	STS  _tx_rd_index0,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer0)
	SBCI R31,HIGH(-_tx_buffer0)
	LD   R30,Z
	OUT  0xC,R30
; 0000 008B #if TX_BUFFER_SIZE0 != 256
; 0000 008C    if (tx_rd_index0 == TX_BUFFER_SIZE0) tx_rd_index0=0;
	LDS  R26,_tx_rd_index0
	CPI  R26,LOW(0x28)
	BRNE _0xC
	LDI  R30,LOW(0)
	STS  _tx_rd_index0,R30
; 0000 008D #endif
; 0000 008E    }
_0xC:
; 0000 008F }
_0xB:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
;
;#ifndef _DEBUG_TERMINAL_IO_
;// Write a character to the USART0 Transmitter buffer
;#define _ALTERNATE_PUTCHAR_
;#pragma used+
;void putchar(char c)
; 0000 0096 {
_putchar:
; 0000 0097 while (tx_counter0 == TX_BUFFER_SIZE0);
;	c -> Y+0
_0xD:
	LDS  R26,_tx_counter0
	CPI  R26,LOW(0x28)
	BREQ _0xD
; 0000 0098 #asm("cli")
	cli
; 0000 0099 if (tx_counter0 || ((UCSR0A & DATA_REGISTER_EMPTY)==0))
	LDS  R30,_tx_counter0
	CPI  R30,0
	BRNE _0x11
	SBIC 0xB,5
	RJMP _0x10
_0x11:
; 0000 009A    {
; 0000 009B    tx_buffer0[tx_wr_index0++]=c;
	MOV  R30,R12
	INC  R12
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer0)
	SBCI R31,HIGH(-_tx_buffer0)
	LD   R26,Y
	STD  Z+0,R26
; 0000 009C #if TX_BUFFER_SIZE0 != 256
; 0000 009D    if (tx_wr_index0 == TX_BUFFER_SIZE0) tx_wr_index0=0;
	LDI  R30,LOW(40)
	CP   R30,R12
	BRNE _0x13
	CLR  R12
; 0000 009E #endif
; 0000 009F    ++tx_counter0;
_0x13:
	LDS  R30,_tx_counter0
	SUBI R30,-LOW(1)
	STS  _tx_counter0,R30
; 0000 00A0    }
; 0000 00A1 else
	RJMP _0x14
_0x10:
; 0000 00A2    UDR0=c;
	LD   R30,Y
	OUT  0xC,R30
; 0000 00A3 #asm("sei")
_0x14:
	sei
; 0000 00A4 }
	ADIW R28,1
	RET
;#pragma used-
;#endif
;
;
;// USART1 Receiver buffer
;#define RX_BUFFER_SIZE1 100
;char rx_buffer1[RX_BUFFER_SIZE1];
;
;#if RX_BUFFER_SIZE1 <= 256
;unsigned char rx_wr_index1,rx_rd_index1,rx_counter1;
;#else
;unsigned int rx_wr_index1,rx_rd_index1,rx_counter1;
;#endif
;
;// This flag is set on USART1 Receiver buffer overflow
;bit rx_buffer_overflow1;
;
;// USART1 Receiver interrupt service routine
;interrupt [USART1_RXC] void usart1_rx_isr(void)
; 0000 00B8 {
_usart1_rx_isr:
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 00B9 char status,data;
; 0000 00BA status=UCSR1A;
	ST   -Y,R17
	ST   -Y,R16
;	status -> R17
;	data -> R16
	LDS  R17,155
; 0000 00BB data=UDR1;
	LDS  R16,156
; 0000 00BC if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
	MOV  R30,R17
	ANDI R30,LOW(0x1C)
	BRNE _0x15
; 0000 00BD    {
; 0000 00BE    rx_buffer1[rx_wr_index1++]=data;
	LDS  R30,_rx_wr_index1
	SUBI R30,-LOW(1)
	STS  _rx_wr_index1,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer1)
	SBCI R31,HIGH(-_rx_buffer1)
	ST   Z,R16
; 0000 00BF #if RX_BUFFER_SIZE1 == 256
; 0000 00C0    // special case for receiver buffer size=256
; 0000 00C1    if (++rx_counter1 == 0) rx_buffer_overflow1=1;
; 0000 00C2 #else
; 0000 00C3    if (rx_wr_index1 == RX_BUFFER_SIZE1) rx_wr_index1=0;
	LDS  R26,_rx_wr_index1
	CPI  R26,LOW(0x64)
	BRNE _0x16
	LDI  R30,LOW(0)
	STS  _rx_wr_index1,R30
; 0000 00C4    if (++rx_counter1 == RX_BUFFER_SIZE1)
_0x16:
	LDS  R26,_rx_counter1
	SUBI R26,-LOW(1)
	STS  _rx_counter1,R26
	CPI  R26,LOW(0x64)
	BRNE _0x17
; 0000 00C5       {
; 0000 00C6       rx_counter1=0;
	LDI  R30,LOW(0)
	STS  _rx_counter1,R30
; 0000 00C7       rx_buffer_overflow1=1;
	SET
	BLD  R2,3
; 0000 00C8       }
; 0000 00C9 #endif
; 0000 00CA    }
_0x17:
; 0000 00CB }
_0x15:
	LD   R16,Y+
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
;
;// Get a character from the USART1 Receiver buffer
;#pragma used+
;char getchar1(void)
; 0000 00D0 {
_getchar1:
; 0000 00D1 char data;
; 0000 00D2 while (rx_counter1==0);
	ST   -Y,R17
;	data -> R17
_0x18:
	LDS  R30,_rx_counter1
	CPI  R30,0
	BREQ _0x18
; 0000 00D3 data=rx_buffer1[rx_rd_index1++];
	LDS  R30,_rx_rd_index1
	SUBI R30,-LOW(1)
	STS  _rx_rd_index1,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer1)
	SBCI R31,HIGH(-_rx_buffer1)
	LD   R17,Z
; 0000 00D4 #if RX_BUFFER_SIZE1 != 256
; 0000 00D5 if (rx_rd_index1 == RX_BUFFER_SIZE1) rx_rd_index1=0;
	LDS  R26,_rx_rd_index1
	CPI  R26,LOW(0x64)
	BRNE _0x1B
	LDI  R30,LOW(0)
	STS  _rx_rd_index1,R30
; 0000 00D6 #endif
; 0000 00D7 #asm("cli")
_0x1B:
	cli
; 0000 00D8 --rx_counter1;
	LDS  R30,_rx_counter1
	SUBI R30,LOW(1)
	STS  _rx_counter1,R30
; 0000 00D9 #asm("sei")
	sei
_0x20A0007:
; 0000 00DA return data;
	MOV  R30,R17
	LD   R17,Y+
	RET
; 0000 00DB }
;#pragma used-
;// Standard Input/Output functions
;#include <stdio.h>
;/////////////////////////
;void GPSRST()
; 0000 00E1 {
_GPSRST:
; 0000 00E2 putchar ('A');
	LDI  R30,LOW(65)
	ST   -Y,R30
	RCALL _putchar
; 0000 00E3 putchar ('T');
	LDI  R30,LOW(84)
	ST   -Y,R30
	RCALL _putchar
; 0000 00E4 putchar ('+');
	LDI  R30,LOW(43)
	ST   -Y,R30
	RCALL _putchar
; 0000 00E5 putchar ('C');
	LDI  R30,LOW(67)
	ST   -Y,R30
	RCALL _putchar
; 0000 00E6 putchar ('G');
	LDI  R30,LOW(71)
	ST   -Y,R30
	RCALL _putchar
; 0000 00E7 putchar ('P');
	LDI  R30,LOW(80)
	ST   -Y,R30
	RCALL _putchar
; 0000 00E8 putchar ('S');
	LDI  R30,LOW(83)
	ST   -Y,R30
	RCALL _putchar
; 0000 00E9 putchar ('R');
	LDI  R30,LOW(82)
	ST   -Y,R30
	RCALL _putchar
; 0000 00EA putchar ('S');
	LDI  R30,LOW(83)
	ST   -Y,R30
	RCALL _putchar
; 0000 00EB putchar ('T');
	LDI  R30,LOW(84)
	ST   -Y,R30
	RCALL _putchar
; 0000 00EC putchar ('=');
	LDI  R30,LOW(61)
	ST   -Y,R30
	RCALL _putchar
; 0000 00ED putchar ('1');
	LDI  R30,LOW(49)
	ST   -Y,R30
	RCALL _putchar
; 0000 00EE delay_ms(20);
	LDI  R30,LOW(20)
	LDI  R31,HIGH(20)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 00EF putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 00F0 putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 00F1 delay_ms(5000);
	LDI  R30,LOW(5000)
	LDI  R31,HIGH(5000)
	RJMP _0x20A0006
; 0000 00F2 }
;typedef char * CHAR;
;//*******************************************************************************************************
;//*******************************************************************************************************
;int GPSPosition(CHAR input)
; 0000 00F7 {
_GPSPosition:
; 0000 00F8     if ( strlen(input) >= 10 )
;	*input -> Y+0
	LD   R30,Y
	LDD  R31,Y+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _strlen
	SBIW R30,10
	BRLO _0x1C
; 0000 00F9     {
; 0000 00FA         if (input[5] == 'C' || input[5] == 'c')
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,5
	LD   R26,X
	CPI  R26,LOW(0x43)
	BREQ _0x1E
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,5
	LD   R26,X
	CPI  R26,LOW(0x63)
	BRNE _0x1D
_0x1E:
; 0000 00FB             return 1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	RJMP _0x20A0005
; 0000 00FC         else
_0x1D:
; 0000 00FD         {
; 0000 00FE             return 0;
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	RJMP _0x20A0005
; 0000 00FF         }
; 0000 0100     }
; 0000 0101     return 0;
_0x1C:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	RJMP _0x20A0005
; 0000 0102 }
;
;void process_gps()
; 0000 0105 {
; 0000 0106 
; 0000 0107     char GPSData[256];
; 0000 0108     unsigned char chread;
; 0000 0109     unsigned int  loopcount,index=0;
; 0000 010A     unsigned int  pkindex;
; 0000 010B     loopcount = 0;
;	GPSData -> Y+8
;	chread -> R17
;	loopcount -> R18,R19
;	index -> R20,R21
;	pkindex -> Y+6
; 0000 010C     pkindex = 0;
; 0000 010D     while (rx_counter1>0)
; 0000 010E     {
; 0000 010F         chread=getchar1();
; 0000 0110         if ((chread=='$'))
; 0000 0111         {
; 0000 0112             loopcount++;
; 0000 0113             if (loopcount == 2)
; 0000 0114             {
; 0000 0115                  if (GPSPosition(GPSData))
; 0000 0116                  {
; 0000 0117                     if (strlen(GPSData) > 10)
; 0000 0118                     {
; 0000 0119                         for (;pkindex >= index;index++)
; 0000 011A                             gps_in_e2prom[index]=GPSData[index];
; 0000 011B trueData = 1;
; 0000 011C                     }
; 0000 011D                     else
; 0000 011E                     {
; 0000 011F                         trueData = 0;
; 0000 0120                     }
; 0000 0121                     break;
; 0000 0122                  }
; 0000 0123                  else
; 0000 0124                  {
; 0000 0125                         strcpy(GPSData,"");
; 0000 0126                         pkindex = 0;
; 0000 0127                  }
; 0000 0128             }
; 0000 0129             else
; 0000 012A             {
; 0000 012B                 GPSData[pkindex] = chread;
; 0000 012C             }
; 0000 012D 
; 0000 012E         }
; 0000 012F     }
; 0000 0130 
; 0000 0131 }

	.DSEG
_0x2D:
	.BYTE 0x1
;
;CHAR Split (CHAR input, char tag, int Index)
; 0000 0134 {

	.CSEG
; 0000 0135       CHAR tmpstr;
; 0000 0136       int  CountIndex = 0;
; 0000 0137       int Count;
; 0000 0138       for (Count = 0 ; Count < strlen (input); Count++)
;	*input -> Y+9
;	tag -> Y+8
;	Index -> Y+6
;	*tmpstr -> R16,R17
;	CountIndex -> R18,R19
;	Count -> R20,R21
; 0000 0139       {
; 0000 013A             if (input [Count] == tag)
; 0000 013B             {
; 0000 013C                if (CountIndex == Index)
; 0000 013D                {
; 0000 013E                     return tmpstr;
; 0000 013F                }
; 0000 0140                else
; 0000 0141                {
; 0000 0142                     strcpy (tmpstr,"");
; 0000 0143                     CountIndex++;
; 0000 0144                }
; 0000 0145             }
; 0000 0146             else
; 0000 0147             {
; 0000 0148                 strcat(tmpstr,(CHAR)(input[Count]));
; 0000 0149             }
; 0000 014A       }
; 0000 014B       return tmpstr;
; 0000 014C }

	.DSEG
_0x35:
	.BYTE 0x1
;
;///////////////////////////////////////////////////////////////////
;void main(void)
; 0000 0150 {

	.CSEG
_main:
; 0000 0151 PORTA=0x00;
	LDI  R30,LOW(0)
	OUT  0x1B,R30
; 0000 0152 DDRA=0x00;
	OUT  0x1A,R30
; 0000 0153 PORTB=0x00;
	OUT  0x18,R30
; 0000 0154 DDRB=0x70;
	LDI  R30,LOW(112)
	OUT  0x17,R30
; 0000 0155 PORTC=0x00;
	LDI  R30,LOW(0)
	OUT  0x15,R30
; 0000 0156 DDRC=0x07;
	LDI  R30,LOW(7)
	OUT  0x14,R30
; 0000 0157 PORTD=0x00;
	LDI  R30,LOW(0)
	OUT  0x12,R30
; 0000 0158 DDRD=0xA0;
	LDI  R30,LOW(160)
	OUT  0x11,R30
; 0000 0159 
; 0000 015A TCNT0=0x00;
	LDI  R30,LOW(0)
	OUT  0x32,R30
; 0000 015B TCCR1A=0x00;
	OUT  0x2F,R30
; 0000 015C TCCR1B=0x00;
	OUT  0x2E,R30
; 0000 015D TCCR2=0x00;
	OUT  0x25,R30
; 0000 015E TCCR3A=0x00;
	STS  139,R30
; 0000 015F TCCR3B=0x00;
	STS  138,R30
; 0000 0160 
; 0000 0161 // External Interrupt(s) initialization
; 0000 0162 EICRA=0x00;
	STS  106,R30
; 0000 0163 EICRB=0x00;
	OUT  0x3A,R30
; 0000 0164 EIMSK=0x00;
	OUT  0x39,R30
; 0000 0165 
; 0000 0166 // Timer(s)/Counter(s) Interrupt(s) initialization
; 0000 0167 TIMSK=0x00;
	OUT  0x37,R30
; 0000 0168 
; 0000 0169 ETIMSK=0x00;
	STS  125,R30
; 0000 016A 
; 0000 016B UCSR0A=0x00;
	OUT  0xB,R30
; 0000 016C UCSR0B=0xD8;
	LDI  R30,LOW(216)
	OUT  0xA,R30
; 0000 016D UCSR0C=0x06;
	LDI  R30,LOW(6)
	STS  149,R30
; 0000 016E UBRR0H=0x00;
	LDI  R30,LOW(0)
	STS  144,R30
; 0000 016F UBRR0L=0x2F;
	LDI  R30,LOW(47)
	OUT  0x9,R30
; 0000 0170 UCSR1A=0x00;
	LDI  R30,LOW(0)
	STS  155,R30
; 0000 0171 UCSR1B=0x90;
	LDI  R30,LOW(144)
	STS  154,R30
; 0000 0172 UCSR1C=0x06;
	LDI  R30,LOW(6)
	STS  157,R30
; 0000 0173 UBRR1H=0x00;
	LDI  R30,LOW(0)
	STS  152,R30
; 0000 0174 UBRR1L=0x2F;
	LDI  R30,LOW(47)
	STS  153,R30
; 0000 0175 
; 0000 0176 ACSR=0x80;
	LDI  R30,LOW(128)
	OUT  0x8,R30
; 0000 0177 SFIOR=0x00;
	LDI  R30,LOW(0)
	OUT  0x20,R30
; 0000 0178 
; 0000 0179 // ADC initialization
; 0000 017A // ADC disabled
; 0000 017B ADCSRA=0x00;
	OUT  0x6,R30
; 0000 017C 
; 0000 017D // SPI initialization
; 0000 017E // SPI disabled
; 0000 017F SPCR=0x00;
	OUT  0xD,R30
; 0000 0180 
; 0000 0181 // TWI initialization
; 0000 0182 // TWI disabled
; 0000 0183 TWCR=0x00;
	STS  116,R30
; 0000 0184 
; 0000 0185 // Global enable interrupts
; 0000 0186 #asm("sei")
	sei
; 0000 0187 
; 0000 0188 POWER=1;
	SBI  0x15,0
; 0000 0189 delay_ms(1500);
	LDI  R30,LOW(1500)
	LDI  R31,HIGH(1500)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 018A POWER=0;
	CBI  0x15,0
; 0000 018B delay_ms(10000);
	LDI  R30,LOW(10000)
	LDI  R31,HIGH(10000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 018C poweron();
	RCALL _poweron
; 0000 018D echooff();
	RCALL _echooff
; 0000 018E CLSSMS();
	RCALL _CLSSMS
; 0000 018F gpspwr();
	RCALL _gpspwr
; 0000 0190 GPSRST();
	RCALL _GPSRST
; 0000 0191 while (rx_counter0>0)    getchar();
_0x3B:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0x3D
	RCALL _getchar
	RJMP _0x3B
_0x3D:
; 0000 0192 while (1)
_0x3E:
; 0000 0193       {
; 0000 0194       if (rx_counter0) process_data();
	TST  R13
	BREQ _0x41
	RCALL _process_data
; 0000 0195 
; 0000 0196       if( securityMode[1] == 'N' )
_0x41:
	MOVW R30,R8
	LDD  R26,Z+1
	CPI  R26,LOW(0x4E)
	BRNE _0x42
; 0000 0197       Security();
	RCALL _Security
; 0000 0198       //Batt();
; 0000 0199       }
_0x42:
	RJMP _0x3E
; 0000 019A }
_0x43:
	RJMP _0x43
;
;//////////////////////////////////////////////
;void CLSSMS ()
; 0000 019E {
_CLSSMS:
; 0000 019F         delay_ms(1000);
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01A0         puts("AT+CMGD=1 \r");delay_ms(1000);
	__POINTW1MN _0x44,0
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01A1         puts("AT+CMGD=2 \r");delay_ms(1000);
	__POINTW1MN _0x44,12
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01A2         puts("AT+CMGD=3 \r");delay_ms(1000);
	__POINTW1MN _0x44,24
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01A3         puts("AT+CMGD=4 \r");delay_ms(1000);
	__POINTW1MN _0x44,36
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01A4         puts("AT+CMGD=5 \r");delay_ms(1000);
	__POINTW1MN _0x44,48
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01A5         puts("AT+CMGD=6 \r");delay_ms(1000);
	__POINTW1MN _0x44,60
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01A6         puts("AT+CMGD=7 \r");delay_ms(1000);
	__POINTW1MN _0x44,72
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01A7         puts("AT+CMGD=8 \r");delay_ms(1000);
	__POINTW1MN _0x44,84
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01A8         puts("AT+CMGD=9 \r");delay_ms(1000);
	__POINTW1MN _0x44,96
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01A9         puts("AT+CMGD=10 \r");delay_ms(1000);
	__POINTW1MN _0x44,108
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01AA         puts("AT+CMGD=11 \r");delay_ms(1000);
	__POINTW1MN _0x44,121
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01AB         puts("AT+CMGD=12 \r");delay_ms(1000);
	__POINTW1MN _0x44,134
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01AC         puts("AT+CMGD=1 \r");delay_ms(1000);
	__POINTW1MN _0x44,147
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
_0x20A0006:
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01AD }
	RET

	.DSEG
_0x44:
	.BYTE 0x9F
;//////////////////////////////////////////////////////
;void gpspwr()
; 0000 01B0 {

	.CSEG
_gpspwr:
; 0000 01B1         unsigned char ch1,ch2,flag;
; 0000 01B2         while (rx_counter0>0)    getchar();
	CALL __SAVELOCR4
;	ch1 -> R17
;	ch2 -> R16
;	flag -> R19
_0x45:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0x47
	RCALL _getchar
	RJMP _0x45
_0x47:
; 0000 01B4 delay_ms(100);
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01B5         putchar ('A');
	LDI  R30,LOW(65)
	ST   -Y,R30
	RCALL _putchar
; 0000 01B6         putchar ('T');
	LDI  R30,LOW(84)
	ST   -Y,R30
	RCALL _putchar
; 0000 01B7         putchar ('+');
	LDI  R30,LOW(43)
	ST   -Y,R30
	RCALL _putchar
; 0000 01B8         putchar ('C');
	LDI  R30,LOW(67)
	ST   -Y,R30
	RCALL _putchar
; 0000 01B9         putchar ('M');
	LDI  R30,LOW(77)
	ST   -Y,R30
	RCALL _putchar
; 0000 01BA         putchar ('G');
	LDI  R30,LOW(71)
	ST   -Y,R30
	RCALL _putchar
; 0000 01BB         putchar ('F');
	LDI  R30,LOW(70)
	ST   -Y,R30
	RCALL _putchar
; 0000 01BC         putchar ('=');
	LDI  R30,LOW(61)
	ST   -Y,R30
	RCALL _putchar
; 0000 01BD         putchar ('1');
	LDI  R30,LOW(49)
	ST   -Y,R30
	RCALL _putchar
; 0000 01BE         delay_ms(10);
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01BF         putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 01C0         putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 01C1         delay_ms(100);
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01C2         while (rx_counter0>0)
_0x48:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0x4A
; 0000 01C3         {
; 0000 01C4             ch1=ch2;
	MOV  R17,R16
; 0000 01C5             ch2=getchar();
	RCALL _getchar
	MOV  R16,R30
; 0000 01C6             if ((ch1=='O') && (ch2=='K'))    {flag=0;break;}
	CPI  R17,79
	BRNE _0x4C
	CPI  R16,75
	BREQ _0x4D
_0x4C:
	RJMP _0x4B
_0x4D:
	LDI  R19,LOW(0)
	RJMP _0x4A
; 0000 01C7         }
_0x4B:
	RJMP _0x48
_0x4A:
; 0000 01C8         while (rx_counter0>0)    getchar();
_0x4E:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0x50
	RCALL _getchar
	RJMP _0x4E
_0x50:
; 0000 01C9 delay_ms(100);
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01CA         putchar('A');
	LDI  R30,LOW(65)
	ST   -Y,R30
	RCALL _putchar
; 0000 01CB         delay_ms(10);
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01CC         putchar ('T');
	LDI  R30,LOW(84)
	ST   -Y,R30
	RCALL _putchar
; 0000 01CD         delay_ms(10);
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01CE         putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 01CF         putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 01D0         delay_ms(80);
	LDI  R30,LOW(80)
	LDI  R31,HIGH(80)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01D1         putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 01D2         putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 01D3         delay_ms(20);
	LDI  R30,LOW(20)
	LDI  R31,HIGH(20)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01D4 ////////////////////////////////////////////////////
; 0000 01D5         putchar ('A');
	LDI  R30,LOW(65)
	ST   -Y,R30
	RCALL _putchar
; 0000 01D6         putchar ('T');
	LDI  R30,LOW(84)
	ST   -Y,R30
	RCALL _putchar
; 0000 01D7         putchar ('+');
	LDI  R30,LOW(43)
	ST   -Y,R30
	RCALL _putchar
; 0000 01D8         putchar ('C');
	LDI  R30,LOW(67)
	ST   -Y,R30
	RCALL _putchar
; 0000 01D9         putchar ('G');
	LDI  R30,LOW(71)
	ST   -Y,R30
	RCALL _putchar
; 0000 01DA         putchar ('P');
	LDI  R30,LOW(80)
	ST   -Y,R30
	RCALL _putchar
; 0000 01DB         putchar ('S');
	LDI  R30,LOW(83)
	ST   -Y,R30
	RCALL _putchar
; 0000 01DC         putchar ('P');
	LDI  R30,LOW(80)
	ST   -Y,R30
	RCALL _putchar
; 0000 01DD         putchar ('W');
	LDI  R30,LOW(87)
	ST   -Y,R30
	RCALL _putchar
; 0000 01DE         putchar ('R');
	LDI  R30,LOW(82)
	ST   -Y,R30
	RCALL _putchar
; 0000 01DF         putchar ('=');
	LDI  R30,LOW(61)
	ST   -Y,R30
	RCALL _putchar
; 0000 01E0         putchar ('1');
	LDI  R30,LOW(49)
	ST   -Y,R30
	RCALL _putchar
; 0000 01E1         delay_ms(10);
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01E2         putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 01E3         putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 01E4         delay_ms(80);
	LDI  R30,LOW(80)
	LDI  R31,HIGH(80)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01E5         delay_ms(1900);
	LDI  R30,LOW(1900)
	LDI  R31,HIGH(1900)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01E6 ///////////////////////////////////////////////////////
; 0000 01E7         putchar ('A');
	LDI  R30,LOW(65)
	ST   -Y,R30
	RCALL _putchar
; 0000 01E8         putchar ('T');
	LDI  R30,LOW(84)
	ST   -Y,R30
	RCALL _putchar
; 0000 01E9         putchar ('+');
	LDI  R30,LOW(43)
	ST   -Y,R30
	RCALL _putchar
; 0000 01EA         putchar ('C');
	LDI  R30,LOW(67)
	ST   -Y,R30
	RCALL _putchar
; 0000 01EB         putchar ('G');
	LDI  R30,LOW(71)
	ST   -Y,R30
	RCALL _putchar
; 0000 01EC         putchar ('P');
	LDI  R30,LOW(80)
	ST   -Y,R30
	RCALL _putchar
; 0000 01ED         putchar ('S');
	LDI  R30,LOW(83)
	ST   -Y,R30
	RCALL _putchar
; 0000 01EE         putchar ('R');
	LDI  R30,LOW(82)
	ST   -Y,R30
	RCALL _putchar
; 0000 01EF         putchar ('S');
	LDI  R30,LOW(83)
	ST   -Y,R30
	RCALL _putchar
; 0000 01F0         putchar ('T');
	LDI  R30,LOW(84)
	ST   -Y,R30
	RCALL _putchar
; 0000 01F1         putchar ('=');
	LDI  R30,LOW(61)
	ST   -Y,R30
	RCALL _putchar
; 0000 01F2         putchar ('1');
	LDI  R30,LOW(49)
	ST   -Y,R30
	RCALL _putchar
; 0000 01F3         delay_ms(20);
	LDI  R30,LOW(20)
	LDI  R31,HIGH(20)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01F4         putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 01F5         putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 01F6         delay_ms(280);
	LDI  R30,LOW(280)
	LDI  R31,HIGH(280)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01F7 ////////////////////////////////////////////////////////
; 0000 01F8         puts("AT+CMGS=\"09384198683\" \r");
	__POINTW1MN _0x51,0
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
; 0000 01F9         putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 01FA         putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 01FB         delay_ms(180);
	LDI  R30,LOW(180)
	LDI  R31,HIGH(180)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01FC         printf("GSM ON");
	__POINTW1FN _0x0,175
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	CALL _printf
	ADIW R28,2
; 0000 01FD         delay_ms(90);
	LDI  R30,LOW(90)
	LDI  R31,HIGH(90)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 01FE         putchar (26);
	LDI  R30,LOW(26)
	ST   -Y,R30
	RCALL _putchar
; 0000 01FF         delay_ms(200);
	LDI  R30,LOW(200)
	LDI  R31,HIGH(200)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0200 }
	RJMP _0x20A0002

	.DSEG
_0x51:
	.BYTE 0x18
;//////////////////////////////////////////////////////////////////
;typedef char * CHAR;
;void SendSMS(CHAR Massage)
; 0000 0204 {

	.CSEG
_SendSMS:
; 0000 0205 
; 0000 0206         puts("AT+CMGS=\"09384198683\" \r");
;	*Massage -> Y+0
	__POINTW1MN _0x52,0
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
; 0000 0207         putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 0208         putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 0209         delay_ms(180);
	LDI  R30,LOW(180)
	LDI  R31,HIGH(180)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 020A         puts(Massage);
	LD   R30,Y
	LDD  R31,Y+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
; 0000 020B         delay_ms(90);
	LDI  R30,LOW(90)
	LDI  R31,HIGH(90)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 020C         putchar (26);
	LDI  R30,LOW(26)
	ST   -Y,R30
	RCALL _putchar
; 0000 020D         delay_ms(200);
	LDI  R30,LOW(200)
	LDI  R31,HIGH(200)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 020E }
_0x20A0005:
	ADIW R28,2
	RET

	.DSEG
_0x52:
	.BYTE 0x18
;///////////////////////////////////////////////////////////////////////////////
;void process_sms(void)
; 0000 0211 {

	.CSEG
_process_sms:
; 0000 0212     int counter=0;
; 0000 0213     int faildGPS = 0;
; 0000 0214     unsigned char tmp [];
; 0000 0215     unsigned char pos [];
; 0000 0216     unsigned char ch1,ch2,ch3,ch4,ch5,ch6,ch7,ch8,catch[5];
; 0000 0217     unsigned char i,temp,sms_valid=0;
; 0000 0218     unsigned int data_length, index,tagpos;
; 0000 0219 
; 0000 021A     int lastGetTrueCode=0;
; 0000 021B 
; 0000 021C     data_length=sms_in_e2prom[0];
	SBIW R28,22
	LDI  R24,9
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0x53*2)
	LDI  R31,HIGH(_0x53*2)
	CALL __INITLOCB
	CALL __SAVELOCR6
;	counter -> R16,R17
;	faildGPS -> R18,R19
;	tmp -> Y+28
;	pos -> Y+28
;	ch1 -> R21
;	ch2 -> R20
;	ch3 -> Y+27
;	ch4 -> Y+26
;	ch5 -> Y+25
;	ch6 -> Y+24
;	ch7 -> Y+23
;	ch8 -> Y+22
;	catch -> Y+17
;	i -> Y+16
;	temp -> Y+15
;	sms_valid -> Y+14
;	data_length -> Y+12
;	index -> Y+10
;	tagpos -> Y+8
;	lastGetTrueCode -> Y+6
	__GETWRN 16,17,0
	__GETWRN 18,19,0
	LDI  R26,LOW(_sms_in_e2prom)
	LDI  R27,HIGH(_sms_in_e2prom)
	CALL __EEPROMRDB
	LDI  R31,0
	STD  Y+12,R30
	STD  Y+12+1,R31
; 0000 021D     if (data_length>10) data_length=10;
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	SBIW R26,11
	BRLO _0x54
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	STD  Y+12,R30
	STD  Y+12+1,R31
; 0000 021E 
; 0000 021F     for (i=1;i<=data_length;i++)
_0x54:
	LDI  R30,LOW(1)
	STD  Y+16,R30
_0x56:
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	LDD  R26,Y+16
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BRSH PC+3
	JMP _0x57
; 0000 0220     {
; 0000 0221         ch1=ch2;
	MOV  R21,R20
; 0000 0222         ch2=ch3;
	LDD  R20,Y+27
; 0000 0223         ch3=ch4;
	LDD  R30,Y+26
	STD  Y+27,R30
; 0000 0224         ch4=ch5;
	LDD  R30,Y+25
	STD  Y+26,R30
; 0000 0225         ch5=ch6;
	LDD  R30,Y+24
	STD  Y+25,R30
; 0000 0226         ch6=ch7;
	LDD  R30,Y+23
	STD  Y+24,R30
; 0000 0227         ch7=ch8;
	LDD  R30,Y+22
	STD  Y+23,R30
; 0000 0228         ch8=sms_in_e2prom[i];
	LDD  R26,Y+16
	LDI  R27,0
	SUBI R26,LOW(-_sms_in_e2prom)
	SBCI R27,HIGH(-_sms_in_e2prom)
	CALL __EEPROMRDB
	STD  Y+22,R30
; 0000 0229         if ((ch8>='a')&&(ch8<='z')) ch8-=32;
	LDD  R26,Y+22
	CPI  R26,LOW(0x61)
	BRLO _0x59
	CPI  R26,LOW(0x7B)
	BRLO _0x5A
_0x59:
	RJMP _0x58
_0x5A:
	LDD  R30,Y+22
	LDI  R31,0
	SBIW R30,32
	STD  Y+22,R30
; 0000 022A 
; 0000 022B         if ((ch1=='P') && (ch2=='1') && (ch3=='3') && (ch4=='9') && (ch5=='1'))    {sms_valid=1;break;}
_0x58:
	CPI  R21,80
	BRNE _0x5C
	CPI  R20,49
	BRNE _0x5C
	LDD  R26,Y+27
	CPI  R26,LOW(0x33)
	BRNE _0x5C
	LDD  R26,Y+26
	CPI  R26,LOW(0x39)
	BRNE _0x5C
	LDD  R26,Y+25
	CPI  R26,LOW(0x31)
	BREQ _0x5D
_0x5C:
	RJMP _0x5B
_0x5D:
	LDI  R30,LOW(1)
	STD  Y+14,R30
	RJMP _0x57
; 0000 022C         if ((ch4=='A') && (ch5=='L') && (ch6=='A') && (ch7=='R') && (ch8=='M'))    {sms_valid=2;break;}
_0x5B:
	LDD  R26,Y+26
	CPI  R26,LOW(0x41)
	BRNE _0x5F
	LDD  R26,Y+25
	CPI  R26,LOW(0x4C)
	BRNE _0x5F
	LDD  R26,Y+24
	CPI  R26,LOW(0x41)
	BRNE _0x5F
	LDD  R26,Y+23
	CPI  R26,LOW(0x52)
	BRNE _0x5F
	LDD  R26,Y+22
	CPI  R26,LOW(0x4D)
	BREQ _0x60
_0x5F:
	RJMP _0x5E
_0x60:
	LDI  R30,LOW(2)
	STD  Y+14,R30
	RJMP _0x57
; 0000 022D         if ((ch3=='S') && (ch4=='I') && (ch5=='L') && (ch6=='E') && (ch7=='N') && (ch8=='T'))    {sms_valid=3;break;}
_0x5E:
	LDD  R26,Y+27
	CPI  R26,LOW(0x53)
	BRNE _0x62
	LDD  R26,Y+26
	CPI  R26,LOW(0x49)
	BRNE _0x62
	LDD  R26,Y+25
	CPI  R26,LOW(0x4C)
	BRNE _0x62
	LDD  R26,Y+24
	CPI  R26,LOW(0x45)
	BRNE _0x62
	LDD  R26,Y+23
	CPI  R26,LOW(0x4E)
	BRNE _0x62
	LDD  R26,Y+22
	CPI  R26,LOW(0x54)
	BREQ _0x63
_0x62:
	RJMP _0x61
_0x63:
	LDI  R30,LOW(3)
	STD  Y+14,R30
	RJMP _0x57
; 0000 022E         if ((ch5=='S') && (ch6=='T') && (ch7=='O') && (ch8=='P'))    {sms_valid=4;break;}
_0x61:
	LDD  R26,Y+25
	CPI  R26,LOW(0x53)
	BRNE _0x65
	LDD  R26,Y+24
	CPI  R26,LOW(0x54)
	BRNE _0x65
	LDD  R26,Y+23
	CPI  R26,LOW(0x4F)
	BRNE _0x65
	LDD  R26,Y+22
	CPI  R26,LOW(0x50)
	BREQ _0x66
_0x65:
	RJMP _0x64
_0x66:
	LDI  R30,LOW(4)
	STD  Y+14,R30
	RJMP _0x57
; 0000 022F         if ((ch4=='S') && (ch5=='E') && (ch6=='C') && (ch7=='O') && (ch8=='N'))    {sms_valid=5;break;}
_0x64:
	LDD  R26,Y+26
	CPI  R26,LOW(0x53)
	BRNE _0x68
	LDD  R26,Y+25
	CPI  R26,LOW(0x45)
	BRNE _0x68
	LDD  R26,Y+24
	CPI  R26,LOW(0x43)
	BRNE _0x68
	LDD  R26,Y+23
	CPI  R26,LOW(0x4F)
	BRNE _0x68
	LDD  R26,Y+22
	CPI  R26,LOW(0x4E)
	BREQ _0x69
_0x68:
	RJMP _0x67
_0x69:
	LDI  R30,LOW(5)
	STD  Y+14,R30
	RJMP _0x57
; 0000 0230         if ((ch3=='S') && (ch4=='E') && (ch5=='C') && (ch6=='O') && (ch7=='F') && (ch8=='F'))    {sms_valid=6;break;}
_0x67:
	LDD  R26,Y+27
	CPI  R26,LOW(0x53)
	BRNE _0x6B
	LDD  R26,Y+26
	CPI  R26,LOW(0x45)
	BRNE _0x6B
	LDD  R26,Y+25
	CPI  R26,LOW(0x43)
	BRNE _0x6B
	LDD  R26,Y+24
	CPI  R26,LOW(0x4F)
	BRNE _0x6B
	LDD  R26,Y+23
	CPI  R26,LOW(0x46)
	BRNE _0x6B
	LDD  R26,Y+22
	CPI  R26,LOW(0x46)
	BREQ _0x6C
_0x6B:
	RJMP _0x6A
_0x6C:
	LDI  R30,LOW(6)
	STD  Y+14,R30
	RJMP _0x57
; 0000 0231         if ((ch3=='G') && (ch4=='E') && (ch5=='T') && (ch6=='A') && (ch7=='N') && (ch8=='T'))    {sms_valid=7;break;}
_0x6A:
	LDD  R26,Y+27
	CPI  R26,LOW(0x47)
	BRNE _0x6E
	LDD  R26,Y+26
	CPI  R26,LOW(0x45)
	BRNE _0x6E
	LDD  R26,Y+25
	CPI  R26,LOW(0x54)
	BRNE _0x6E
	LDD  R26,Y+24
	CPI  R26,LOW(0x41)
	BRNE _0x6E
	LDD  R26,Y+23
	CPI  R26,LOW(0x4E)
	BRNE _0x6E
	LDD  R26,Y+22
	CPI  R26,LOW(0x54)
	BREQ _0x6F
_0x6E:
	RJMP _0x6D
_0x6F:
	LDI  R30,LOW(7)
	STD  Y+14,R30
	RJMP _0x57
; 0000 0232     }
_0x6D:
	LDD  R30,Y+16
	SUBI R30,-LOW(1)
	STD  Y+16,R30
	RJMP _0x56
_0x57:
; 0000 0233 
; 0000 0234     if (!sms_valid)
	LDD  R30,Y+14
	CPI  R30,0
	BRNE _0x70
; 0000 0235     {
; 0000 0236         CLSSMS();
	RCALL _CLSSMS
; 0000 0237         delay_ms(1000);
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0238         SendSMS("invalid command!");
	__POINTW1MN _0x71,0
	ST   -Y,R31
	ST   -Y,R30
	RCALL _SendSMS
; 0000 0239         return;
	RJMP _0x20A0004
; 0000 023A     }
; 0000 023B 
; 0000 023C 
; 0000 023D     switch (sms_valid)
_0x70:
	LDD  R30,Y+14
	LDI  R31,0
; 0000 023E     {
; 0000 023F         case 1:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BREQ PC+3
	JMP _0x75
; 0000 0240         counter = 0;
	__GETWRN 16,17,0
; 0000 0241         faildGPS = 0;
	__GETWRN 18,19,0
; 0000 0242         index  = -1;
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	STD  Y+10,R30
	STD  Y+10+1,R31
; 0000 0243         tagpos = 0;
	LDI  R30,LOW(0)
	STD  Y+8,R30
	STD  Y+8+1,R30
; 0000 0244         lastGetTrueCode=0;
	STD  Y+6,R30
	STD  Y+6+1,R30
; 0000 0245         delay_ms(1000);
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0246 
; 0000 0247         while (rx_counter1>0) getchar1();
_0x76:
	LDS  R26,_rx_counter1
	CPI  R26,LOW(0x1)
	BRLO _0x78
	RCALL _getchar1
	RJMP _0x76
_0x78:
; 0000 024B while (1)
_0x79:
; 0000 024C         {
; 0000 024D             ch1=getchar1();
	RCALL _getchar1
	MOV  R21,R30
; 0000 024E 
; 0000 024F             switch( lastGetTrueCode )
	LDD  R30,Y+6
	LDD  R31,Y+6+1
; 0000 0250             {
; 0000 0251                 case 0:
	SBIW R30,0
	BRNE _0x7F
; 0000 0252                     if( ch1 == 'A' )
	CPI  R21,65
	BRNE _0x80
; 0000 0253                         lastGetTrueCode = 1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0254                 break;
_0x80:
	RJMP _0x7E
; 0000 0255                 case 1:
_0x7F:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x81
; 0000 0256                     if( ch1 == 'N' )
	CPI  R21,78
	BRNE _0x82
; 0000 0257                         lastGetTrueCode = 2;
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0258                 break;
_0x82:
	RJMP _0x7E
; 0000 0259                 case 2:
_0x81:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x83
; 0000 025A                     if( ch1 == ',' )
	CPI  R21,44
	BRNE _0x84
; 0000 025B                         lastGetTrueCode = 3;
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 025C                 break;
_0x84:
	RJMP _0x7E
; 0000 025D                 case 3:
_0x83:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x85
; 0000 025E                     if( ch1 == ',' )
	CPI  R21,44
	BRNE _0x86
; 0000 025F                         lastGetTrueCode = 4;
	LDI  R30,LOW(4)
	LDI  R31,HIGH(4)
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0260                 break;
_0x86:
	RJMP _0x7E
; 0000 0261                 case 4:
_0x85:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x87
; 0000 0262                     if( ch1 == 'E' || ch1 == 'W' )
	CPI  R21,69
	BREQ _0x89
	CPI  R21,87
	BRNE _0x88
_0x89:
; 0000 0263                         lastGetTrueCode = 5;
	LDI  R30,LOW(5)
	LDI  R31,HIGH(5)
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0264                 break;
_0x88:
	RJMP _0x7E
; 0000 0265                 case 5:
_0x87:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x7E
; 0000 0266                     if( ch1 == ',' )
	CPI  R21,44
	BRNE _0x8C
; 0000 0267                         lastGetTrueCode = 6;
	LDI  R30,LOW(6)
	LDI  R31,HIGH(6)
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0268                 break;
_0x8C:
; 0000 0269             }
_0x7E:
; 0000 026A 
; 0000 026B             if (ch1 == '$' && tagpos )
	CPI  R21,36
	BRNE _0x8E
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	SBIW R30,0
	BRNE _0x8F
_0x8E:
	RJMP _0x8D
_0x8F:
; 0000 026C             {
; 0000 026D                     if(GPSPosition(pos) && lastGetTrueCode == 6)
	MOVW R30,R28
	ADIW R30,28
	ST   -Y,R31
	ST   -Y,R30
	RCALL _GPSPosition
	SBIW R30,0
	BREQ _0x91
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	SBIW R26,6
	BREQ _0x92
_0x91:
	RJMP _0x90
_0x92:
; 0000 026E                     {
; 0000 026F                         faildGPS = 0;
	__GETWRN 18,19,0
; 0000 0270                         break;
	RJMP _0x7B
; 0000 0271                     }
; 0000 0272                     else
_0x90:
; 0000 0273                     {
; 0000 0274                         counter++;
	__ADDWRN 16,17,1
; 0000 0275                         index  = 0;
	LDI  R30,LOW(0)
	STD  Y+10,R30
	STD  Y+10+1,R30
; 0000 0276                         tagpos = 0;
	STD  Y+8,R30
	STD  Y+8+1,R30
; 0000 0277                         lastGetTrueCode = 0;
	STD  Y+6,R30
	STD  Y+6+1,R30
; 0000 0278                     }
; 0000 0279             }
; 0000 027A             else if (ch1 == '$')
	RJMP _0x94
_0x8D:
	CPI  R21,36
	BRNE _0x95
; 0000 027B             {
; 0000 027C                 counter++;
	__ADDWRN 16,17,1
; 0000 027D                 tagpos++;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 027E                 index = 0;
	LDI  R30,LOW(0)
	STD  Y+10,R30
	STD  Y+10+1,R30
; 0000 027F                 lastGetTrueCode = 0;
	STD  Y+6,R30
	STD  Y+6+1,R30
; 0000 0280             }
; 0000 0281             else
	RJMP _0x96
_0x95:
; 0000 0282                 index++;
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADIW R30,1
	STD  Y+10,R30
	STD  Y+10+1,R31
; 0000 0283 
; 0000 0284             if( counter > 500 )
_0x96:
_0x94:
	__CPWRN 16,17,501
	BRLT _0x97
; 0000 0285             {
; 0000 0286                 faildGPS = 1;
	__GETWRN 18,19,1
; 0000 0287                 break;
	RJMP _0x7B
; 0000 0288             }
; 0000 0289 
; 0000 028A             pos[index] = ch1;
_0x97:
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	MOVW R26,R28
	ADIW R26,28
	ADD  R30,R26
	ADC  R31,R27
	ST   Z,R21
; 0000 028B         }
	RJMP _0x79
_0x7B:
; 0000 028C 
; 0000 028D             if( faildGPS )
	MOV  R0,R18
	OR   R0,R19
	BREQ _0x98
; 0000 028E             {
; 0000 028F                 SendSMS("data is faild !!!");
	__POINTW1MN _0x71,17
	RJMP _0xF6
; 0000 0290             }
; 0000 0291             else
_0x98:
; 0000 0292             {
; 0000 0293                 SendSMS(pos);
	MOVW R30,R28
	ADIW R30,28
_0xF6:
	ST   -Y,R31
	ST   -Y,R30
	RCALL _SendSMS
; 0000 0294             }
; 0000 0295 
; 0000 0296 
; 0000 0297             //SendSMSToNum(caller_id,pos);
; 0000 0298 
; 0000 0299         break;
	RJMP _0x74
; 0000 029A         case 2:
_0x75:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x9A
; 0000 029B 
; 0000 029C             delay_ms(2000);
	LDI  R30,LOW(2000)
	LDI  R31,HIGH(2000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 029D             puts("AT+CMGS=\"09384198683\" \r");
	__POINTW1MN _0x71,35
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
; 0000 029E             putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 029F             putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 02A0             delay_ms(180);
	LDI  R30,LOW(180)
	LDI  R31,HIGH(180)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02A1             printf("Alarm ON");
	__POINTW1FN _0x0,217
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	CALL _printf
	ADIW R28,2
; 0000 02A2             delay_ms(90);
	LDI  R30,LOW(90)
	LDI  R31,HIGH(90)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02A3             putchar (26);
	LDI  R30,LOW(26)
	ST   -Y,R30
	RCALL _putchar
; 0000 02A4             delay_ms(200);
	LDI  R30,LOW(200)
	LDI  R31,HIGH(200)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02A5 
; 0000 02A6         break;
	RJMP _0x74
; 0000 02A7         case 3:
_0x9A:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x9B
; 0000 02A8 
; 0000 02A9             delay_ms(2000);
	LDI  R30,LOW(2000)
	LDI  R31,HIGH(2000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02AA             puts("AT+CMGS=\"09384198683\" \r");
	__POINTW1MN _0x71,59
	ST   -Y,R31
	ST   -Y,R30
	RCALL _puts
; 0000 02AB             putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 02AC             putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 02AD             delay_ms(180);
	LDI  R30,LOW(180)
	LDI  R31,HIGH(180)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02AE             printf("Silent ON");
	__POINTW1FN _0x0,226
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	CALL _printf
	ADIW R28,2
; 0000 02AF             delay_ms(90);
	LDI  R30,LOW(90)
	LDI  R31,HIGH(90)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02B0             putchar (26);
	LDI  R30,LOW(26)
	ST   -Y,R30
	RCALL _putchar
; 0000 02B1             delay_ms(200);
	LDI  R30,LOW(200)
	LDI  R31,HIGH(200)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02B2         break;
	RJMP _0x74
; 0000 02B3         case 4:
_0x9B:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x9C
; 0000 02B4 
; 0000 02B5             delay_ms(2000);
	LDI  R30,LOW(2000)
	LDI  R31,HIGH(2000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02B6             puts("AT+CMGS=\"09384198683\" \r");
	__POINTW1MN _0x71,83
	ST   -Y,R31
	ST   -Y,R30
	RCALL _puts
; 0000 02B7             putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 02B8             putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 02B9             delay_ms(180);
	LDI  R30,LOW(180)
	LDI  R31,HIGH(180)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02BA             printf("Stop ON");
	__POINTW1FN _0x0,236
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	CALL _printf
	ADIW R28,2
; 0000 02BB             delay_ms(90);
	LDI  R30,LOW(90)
	LDI  R31,HIGH(90)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02BC             putchar (26);
	LDI  R30,LOW(26)
	ST   -Y,R30
	RCALL _putchar
; 0000 02BD             delay_ms(200);
	LDI  R30,LOW(200)
	LDI  R31,HIGH(200)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02BE         break;
	RJMP _0x74
; 0000 02BF         case 5:
_0x9C:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x9D
; 0000 02C0 
; 0000 02C1             delay_ms(2000);
	LDI  R30,LOW(2000)
	LDI  R31,HIGH(2000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02C2             puts("AT+CMGS=\"09384198683\" \r");
	__POINTW1MN _0x71,107
	ST   -Y,R31
	ST   -Y,R30
	RCALL _puts
; 0000 02C3             putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 02C4             putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 02C5             delay_ms(180);
	LDI  R30,LOW(180)
	LDI  R31,HIGH(180)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02C6             if( securityMode[1] == 'N' )
	MOVW R30,R8
	LDD  R26,Z+1
	CPI  R26,LOW(0x4E)
	BRNE _0x9E
; 0000 02C7                 printf("SECURITY was ON");
	__POINTW1FN _0x0,244
	RJMP _0xF7
; 0000 02C8             else
_0x9E:
; 0000 02C9                 printf("SECURITY is ON");
	__POINTW1FN _0x0,260
_0xF7:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	CALL _printf
	ADIW R28,2
; 0000 02CA             delay_ms(90);
	LDI  R30,LOW(90)
	LDI  R31,HIGH(90)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02CB             putchar (26);
	LDI  R30,LOW(26)
	ST   -Y,R30
	RCALL _putchar
; 0000 02CC             delay_ms(200);
	LDI  R30,LOW(200)
	LDI  R31,HIGH(200)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02CD             securityMode[0] = 'O';
	MOVW R26,R8
	LDI  R30,LOW(79)
	ST   X,R30
; 0000 02CE             securityMode[1] = 'N';
	MOVW R30,R8
	ADIW R30,1
	LDI  R26,LOW(78)
	STD  Z+0,R26
; 0000 02CF         break;
	RJMP _0x74
; 0000 02D0         case 6:
_0x9D:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BREQ PC+3
	JMP _0xA0
; 0000 02D1 
; 0000 02D2             delay_ms(2000);
	LDI  R30,LOW(2000)
	LDI  R31,HIGH(2000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02D3             puts("AT+CMGS=\"09384198683\" \r");
	__POINTW1MN _0x71,131
	ST   -Y,R31
	ST   -Y,R30
	RCALL _puts
; 0000 02D4             putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 02D5             putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 02D6             delay_ms(180);
	LDI  R30,LOW(180)
	LDI  R31,HIGH(180)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02D7             if( securityMode[1] == 'N' )
	MOVW R30,R8
	LDD  R26,Z+1
	CPI  R26,LOW(0x4E)
	BRNE _0xA1
; 0000 02D8                 printf("SECURITY is OFF");
	__POINTW1FN _0x0,275
	RJMP _0xF8
; 0000 02D9             else
_0xA1:
; 0000 02DA                 printf("SECURITY was OFF");
	__POINTW1FN _0x0,291
_0xF8:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	CALL _printf
	ADIW R28,2
; 0000 02DB             delay_ms(90);
	LDI  R30,LOW(90)
	LDI  R31,HIGH(90)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02DC             putchar (26);
	LDI  R30,LOW(26)
	ST   -Y,R30
	RCALL _putchar
; 0000 02DD             delay_ms(200);
	LDI  R30,LOW(200)
	LDI  R31,HIGH(200)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02DE             securityMode[0] = 'O';
	MOVW R26,R8
	LDI  R30,LOW(79)
	ST   X,R30
; 0000 02DF             securityMode[1] = 'F';
	MOVW R30,R8
	ADIW R30,1
	LDI  R26,LOW(70)
	STD  Z+0,R26
; 0000 02E0             securityMode[2] = 'F';
	MOVW R30,R8
	ADIW R30,2
	STD  Z+0,R26
; 0000 02E1         break;
	RJMP _0x74
; 0000 02E2         case 7:
_0xA0:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0xA4
; 0000 02E3             delay_ms(2000);
	LDI  R30,LOW(2000)
	LDI  R31,HIGH(2000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02E4             getAntenna();
	RCALL _getAntenna
; 0000 02E5         break;
	RJMP _0x74
; 0000 02E6         default:
_0xA4:
; 0000 02E7             SendSMS("invalid command");
	__POINTW1MN _0x71,155
	ST   -Y,R31
	ST   -Y,R30
	RCALL _SendSMS
; 0000 02E8         break;
; 0000 02E9         }
_0x74:
; 0000 02EA 
; 0000 02EB }
_0x20A0004:
	CALL __LOADLOCR6
	ADIW R28,28
	RET

	.DSEG
_0x71:
	.BYTE 0xAB
;///////////////////////////////////////////////////////////////////////////////
;void process_data(void)
; 0000 02EE {

	.CSEG
_process_data:
; 0000 02EF     unsigned char ch1,ch2,ch3,ch4,ch5,ch6;
; 0000 02F0     unsigned char i=0,memory_index,temp,sms_ready=0;
; 0000 02F1     data_ready=0;
	SBIW R28,4
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
	STD  Y+2,R30
	STD  Y+3,R30
	CALL __SAVELOCR6
;	ch1 -> R17
;	ch2 -> R16
;	ch3 -> R19
;	ch4 -> R18
;	ch5 -> R21
;	ch6 -> R20
;	i -> Y+9
;	memory_index -> Y+8
;	temp -> Y+7
;	sms_ready -> Y+6
	CLT
	BLD  R2,0
; 0000 02F2     delay_ms(1000);
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 02F3 
; 0000 02F4 
; 0000 02F5     while (rx_counter0>0)
_0xA5:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0xA7
; 0000 02F6     {
; 0000 02F7         ch1=ch2;
	MOV  R17,R16
; 0000 02F8         ch2=ch3;
	MOV  R16,R19
; 0000 02F9         ch3=ch4;
	MOV  R19,R18
; 0000 02FA         ch4=ch5;
	MOV  R18,R21
; 0000 02FB         ch5=ch6;
	MOV  R21,R20
; 0000 02FC         ch6=getchar();
	CALL _getchar
	MOV  R20,R30
; 0000 02FD         //buzzer=1;delay_ms(50);
; 0000 02FE         //buzzer=0;delay_ms(50);
; 0000 02FF         if ((ch1=='+') && (ch2=='C') && (ch3=='M') && (ch4=='T') && (ch5=='I') && (ch6==':'))    {led_U=!led_U; delay_ms(100);sms_ready=1;break;}
	CPI  R17,43
	BRNE _0xA9
	CPI  R16,67
	BRNE _0xA9
	CPI  R19,77
	BRNE _0xA9
	CPI  R18,84
	BRNE _0xA9
	CPI  R21,73
	BRNE _0xA9
	CPI  R20,58
	BREQ _0xAA
_0xA9:
	RJMP _0xA8
_0xAA:
	SBIS 0x1B,2
	RJMP _0xAB
	CBI  0x1B,2
	RJMP _0xAC
_0xAB:
	SBI  0x1B,2
_0xAC:
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
	LDI  R30,LOW(1)
	STD  Y+6,R30
	RJMP _0xA7
; 0000 0300     }
_0xA8:
	RJMP _0xA5
_0xA7:
; 0000 0301     if (!sms_ready)    return;
	LDD  R30,Y+6
	CPI  R30,0
	BRNE _0xAD
	RJMP _0x20A0003
; 0000 0302 
; 0000 0303    delay_ms(1000);
_0xAD:
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0304 /*
; 0000 0305     while(getchar()!=',');
; 0000 0306     char1=getchar();
; 0000 0307     //char2=getchar();
; 0000 0308     //char3=getchar();
; 0000 0309 
; 0000 030A         puts("AT+CMGS=\"09384198683\" \r");
; 0000 030B         putchar (13);
; 0000 030C         putchar (10);
; 0000 030D         delay_ms(180);
; 0000 030E         putchar(char1);delay_ms(50);
; 0000 030F         //putchar(char2);delay_ms(50);
; 0000 0310         //putchar(char3);delay_ms(50);
; 0000 0311         putchar('.');delay_ms(50);
; 0000 0312         delay_ms(90);
; 0000 0313         putchar (26);
; 0000 0314         delay_ms(200);
; 0000 0315 
; 0000 0316         delay_ms(15000);
; 0000 0317         delay_ms(2000);
; 0000 0318 
; 0000 0319  */
; 0000 031A     while (rx_counter0>0)    getchar();
_0xAE:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0xB0
	CALL _getchar
	RJMP _0xAE
_0xB0:
; 0000 031C putchar('A');
	LDI  R30,LOW(65)
	ST   -Y,R30
	CALL _putchar
; 0000 031D     putchar('T');//delay_ms(50);
	LDI  R30,LOW(84)
	ST   -Y,R30
	CALL _putchar
; 0000 031E     putchar('+');//delay_ms(50);
	LDI  R30,LOW(43)
	ST   -Y,R30
	CALL _putchar
; 0000 031F     putchar('C');//delay_ms(50);
	LDI  R30,LOW(67)
	ST   -Y,R30
	CALL _putchar
; 0000 0320     putchar('M');//delay_ms(50);
	LDI  R30,LOW(77)
	ST   -Y,R30
	CALL _putchar
; 0000 0321     putchar('G');//delay_ms(50);
	LDI  R30,LOW(71)
	ST   -Y,R30
	CALL _putchar
; 0000 0322     putchar('R');//delay_ms(50);
	LDI  R30,LOW(82)
	ST   -Y,R30
	CALL _putchar
; 0000 0323     putchar('=');//delay_ms(50);
	LDI  R30,LOW(61)
	ST   -Y,R30
	CALL _putchar
; 0000 0324     putchar('1');//delay_ms(50);
	LDI  R30,LOW(49)
	ST   -Y,R30
	CALL _putchar
; 0000 0325     putchar(13);//delay_ms(50);
	LDI  R30,LOW(13)
	ST   -Y,R30
	CALL _putchar
; 0000 0326     putchar(10);//delay_ms(50);
	LDI  R30,LOW(10)
	ST   -Y,R30
	CALL _putchar
; 0000 0327     delay_ms(6000);
	LDI  R30,LOW(6000)
	LDI  R31,HIGH(6000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0328 
; 0000 0329     for (i=0;i<3;i++)    while(getchar()!='"');
	LDI  R30,LOW(0)
	STD  Y+9,R30
_0xB2:
	LDD  R26,Y+9
	CPI  R26,LOW(0x3)
	BRSH _0xB3
_0xB4:
	CALL _getchar
	CPI  R30,LOW(0x22)
	BRNE _0xB4
	LDD  R30,Y+9
	SUBI R30,-LOW(1)
	STD  Y+9,R30
	RJMP _0xB2
_0xB3:
; 0000 032A 
; 0000 032B //    alarm=1;delay_ms(1000);alarm=0;
; 0000 032C 
; 0000 032D 
; 0000 032E     for (i=0;i<20;i++) caller_id[i]=0;
	LDI  R30,LOW(0)
	STD  Y+9,R30
_0xB8:
	LDD  R26,Y+9
	CPI  R26,LOW(0x14)
	BRSH _0xB9
	LDD  R30,Y+9
	LDI  R31,0
	SUBI R30,LOW(-_caller_id)
	SBCI R31,HIGH(-_caller_id)
	LDI  R26,LOW(0)
	STD  Z+0,R26
	LDD  R30,Y+9
	SUBI R30,-LOW(1)
	STD  Y+9,R30
	RJMP _0xB8
_0xB9:
; 0000 032F for (i=1;i<20;i++)
	LDI  R30,LOW(1)
	STD  Y+9,R30
_0xBB:
	LDD  R26,Y+9
	CPI  R26,LOW(0x14)
	BRSH _0xBC
; 0000 0330     {
; 0000 0331         temp=getchar();
	CALL _getchar
	STD  Y+7,R30
; 0000 0332         if (temp=='"') break;
	LDD  R26,Y+7
	CPI  R26,LOW(0x22)
	BREQ _0xBC
; 0000 0333         caller_id[i]=temp;
	LDD  R30,Y+9
	LDI  R31,0
	SUBI R30,LOW(-_caller_id)
	SBCI R31,HIGH(-_caller_id)
	STD  Z+0,R26
; 0000 0334     }
	LDD  R30,Y+9
	SUBI R30,-LOW(1)
	STD  Y+9,R30
	RJMP _0xBB
_0xBC:
; 0000 0335     caller_id[0]=i-1;
	LDD  R30,Y+9
	LDI  R31,0
	SBIW R30,1
	STS  _caller_id,R30
; 0000 0336     delay_ms(1000);
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0337 
; 0000 0338     while (rx_counter0!=0)
_0xBE:
	TST  R13
	BREQ _0xC0
; 0000 0339     {
; 0000 033A         ch1=ch2;
	MOV  R17,R16
; 0000 033B         ch2=getchar();
	CALL _getchar
	MOV  R16,R30
; 0000 033C         if ((ch1==13)&&(ch2==10)) break;
	CPI  R17,13
	BRNE _0xC2
	CPI  R16,10
	BREQ _0xC3
_0xC2:
	RJMP _0xC1
_0xC3:
	RJMP _0xC0
; 0000 033D     }
_0xC1:
	RJMP _0xBE
_0xC0:
; 0000 033E 
; 0000 033F     i=0;
	LDI  R30,LOW(0)
	STD  Y+9,R30
; 0000 0340     while (1)
_0xC4:
; 0000 0341     {
; 0000 0342         ch1=ch2;
	MOV  R17,R16
; 0000 0343         ch2=getchar();
	CALL _getchar
	MOV  R16,R30
; 0000 0344         if ((ch1='O')&&(ch2=='K')) break;
	LDI  R30,LOW(79)
	MOV  R17,R30
	CPI  R30,0
	BREQ _0xC8
	CPI  R16,75
	BREQ _0xC9
_0xC8:
	RJMP _0xC7
_0xC9:
	RJMP _0xC6
; 0000 0345 
; 0000 0346         sms_in_e2prom[++i]=ch2;
_0xC7:
	LDD  R30,Y+9
	SUBI R30,-LOW(1)
	STD  Y+9,R30
	LDI  R31,0
	SUBI R30,LOW(-_sms_in_e2prom)
	SBCI R31,HIGH(-_sms_in_e2prom)
	MOVW R26,R30
	MOV  R30,R16
	CALL __EEPROMWRB
; 0000 0347     }
	RJMP _0xC4
_0xC6:
; 0000 0348     sms_in_e2prom[0]=i;
	LDD  R30,Y+9
	LDI  R26,LOW(_sms_in_e2prom)
	LDI  R27,HIGH(_sms_in_e2prom)
	CALL __EEPROMWRB
; 0000 0349     while (rx_counter0>0)    getchar();
_0xCA:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0xCC
	CALL _getchar
	RJMP _0xCA
_0xCC:
; 0000 034D puts("AT+CMGD=1 \r");delay_ms(1000);
	__POINTW1MN _0xCD,0
	ST   -Y,R31
	ST   -Y,R30
	RCALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 034E     puts("AT+CMGD=1 \r");delay_ms(1000);
	__POINTW1MN _0xCD,12
	ST   -Y,R31
	ST   -Y,R30
	RCALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 034F     puts("AT+CMGD=2 \r");delay_ms(1000);
	__POINTW1MN _0xCD,24
	ST   -Y,R31
	ST   -Y,R30
	RCALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0350     process_sms();
	RCALL _process_sms
; 0000 0351 
; 0000 0352 
; 0000 0353 }
_0x20A0003:
	CALL __LOADLOCR6
	ADIW R28,10
	RET

	.DSEG
_0xCD:
	.BYTE 0x24
;///////////////////////////////////////////////////////////////////////////////
;void echooff(void)
; 0000 0356 {

	.CSEG
_echooff:
	PUSH R15
; 0000 0357 bit flag=1;
; 0000 0358 char ch1,ch2;
; 0000 0359 while (flag)
	ST   -Y,R17
	ST   -Y,R16
;	flag -> R15.0
;	ch1 -> R17
;	ch2 -> R16
	LDI  R30,LOW(1)
	MOV  R15,R30
_0xCE:
	SBRS R15,0
	RJMP _0xD0
; 0000 035A     {
; 0000 035B     putchar ('A');delay_ms(50);
	LDI  R30,LOW(65)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 035C     putchar ('T');delay_ms(50);
	LDI  R30,LOW(84)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 035D     putchar ('E');delay_ms(50);
	LDI  R30,LOW(69)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 035E     putchar ('0');delay_ms(50);
	LDI  R30,LOW(48)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 035F     putchar (13);delay_ms(50);
	LDI  R30,LOW(13)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0360     putchar (10);delay_ms(50);
	LDI  R30,LOW(10)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0361     delay_ms(500);
	LDI  R30,LOW(500)
	LDI  R31,HIGH(500)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0362     while (rx_counter0>0)
_0xD1:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0xD3
; 0000 0363         {
; 0000 0364         ch1=ch2;
	MOV  R17,R16
; 0000 0365         ch2=getchar();
	CALL _getchar
	MOV  R16,R30
; 0000 0366         if ((ch1=='O') && (ch2=='K'))    {flag=0;break;}
	CPI  R17,79
	BRNE _0xD5
	CPI  R16,75
	BREQ _0xD6
_0xD5:
	RJMP _0xD4
_0xD6:
	CLT
	BLD  R15,0
	RJMP _0xD3
; 0000 0367         }
_0xD4:
	RJMP _0xD1
_0xD3:
; 0000 0368     while (rx_counter0>0)    getchar();
_0xD7:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0xD9
	CALL _getchar
	RJMP _0xD7
_0xD9:
; 0000 0369 }
	RJMP _0xCE
_0xD0:
; 0000 036A }
	LD   R16,Y+
	LD   R17,Y+
	POP  R15
	RET
;///////////////////////////////////////////////////////////////////////////////
;void poweron(void)
; 0000 036D {
_poweron:
	PUSH R15
; 0000 036E     unsigned char i,ch1,ch2;
; 0000 036F     bit flag=1;
; 0000 0370 
; 0000 0371     while (rx_counter0>0)    getchar();
	CALL __SAVELOCR4
;	i -> R17
;	ch1 -> R16
;	ch2 -> R19
;	flag -> R15.0
	LDI  R30,LOW(1)
	MOV  R15,R30
_0xDA:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0xDC
	CALL _getchar
	RJMP _0xDA
_0xDC:
; 0000 0373 while (flag)
_0xDD:
	SBRS R15,0
	RJMP _0xDF
; 0000 0374         {
; 0000 0375             putchar('A');delay_ms(50);
	LDI  R30,LOW(65)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0376             putchar('T');delay_ms(50);
	LDI  R30,LOW(84)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0377             putchar(13);delay_ms(50);
	LDI  R30,LOW(13)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0378             putchar (10);delay_ms(50);
	LDI  R30,LOW(10)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0379 
; 0000 037A             delay_ms(500);
	LDI  R30,LOW(500)
	LDI  R31,HIGH(500)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 037B             while (rx_counter0>0)
_0xE0:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0xE2
; 0000 037C             {
; 0000 037D                 ch1=ch2;
	MOV  R16,R19
; 0000 037E                 ch2=getchar();
	CALL _getchar
	MOV  R19,R30
; 0000 037F                 if ((ch1=='O') && (ch2=='K'))    {flag=0;break;}
	CPI  R16,79
	BRNE _0xE4
	CPI  R19,75
	BREQ _0xE5
_0xE4:
	RJMP _0xE3
_0xE5:
	CLT
	BLD  R15,0
	RJMP _0xE2
; 0000 0380 
; 0000 0381             }
_0xE3:
	RJMP _0xE0
_0xE2:
; 0000 0382             while (rx_counter0) getchar();
_0xE6:
	TST  R13
	BREQ _0xE8
	CALL _getchar
	RJMP _0xE6
_0xE8:
; 0000 0383 }
	RJMP _0xDD
_0xDF:
; 0000 0384 ///////////////////////////////////////////////////////////////
; 0000 0385 }
	CALL __LOADLOCR4
	ADIW R28,4
	POP  R15
	RET
;void Security(void)
; 0000 0387 {
_Security:
; 0000 0388 if((PINC.5==0 || PINC.6==0 ) && securityMode[1] == 'N')  ///////Dozdgir//////
	LDI  R26,0
	SBIC 0x13,5
	LDI  R26,1
	CPI  R26,LOW(0x0)
	BREQ _0xEA
	LDI  R26,0
	SBIC 0x13,6
	LDI  R26,1
	CPI  R26,LOW(0x0)
	BRNE _0xEC
_0xEA:
	MOVW R30,R8
	LDD  R26,Z+1
	CPI  R26,LOW(0x4E)
	BREQ _0xED
_0xEC:
	RJMP _0xE9
_0xED:
; 0000 0389  {
; 0000 038A   delay_ms(8000);
	LDI  R30,LOW(8000)
	LDI  R31,HIGH(8000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 038B   puts("AT+CMGS=\"09384198683\" \r");
	__POINTW1MN _0xEE,0
	ST   -Y,R31
	ST   -Y,R30
	RCALL _puts
; 0000 038C   putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	CALL _putchar
; 0000 038D   putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	CALL _putchar
; 0000 038E   delay_ms(180);
	LDI  R30,LOW(180)
	LDI  R31,HIGH(180)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 038F   printf("DozD!");
	__POINTW1FN _0x0,324
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	RCALL _printf
	ADIW R28,2
; 0000 0390   delay_ms(90);
	LDI  R30,LOW(90)
	LDI  R31,HIGH(90)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0391   putchar (26);
	LDI  R30,LOW(26)
	ST   -Y,R30
	CALL _putchar
; 0000 0392   delay_ms(200);
	LDI  R30,LOW(200)
	LDI  R31,HIGH(200)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0393  }
; 0000 0394 };
_0xE9:
	RET

	.DSEG
_0xEE:
	.BYTE 0x18
;void getAntenna()
; 0000 0396 {

	.CSEG
_getAntenna:
; 0000 0397     int index = 0;
; 0000 0398     unsigned char antenna [];
; 0000 0399     unsigned char ch1;
; 0000 039A 
; 0000 039B     while (rx_counter0>0)    getchar();
	CALL __SAVELOCR4
;	index -> R16,R17
;	antenna -> Y+4
;	ch1 -> R19
	__GETWRN 16,17,0
_0xEF:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0xF1
	CALL _getchar
	RJMP _0xEF
_0xF1:
; 0000 039C putchar('A');
	LDI  R30,LOW(65)
	ST   -Y,R30
	CALL _putchar
; 0000 039D     putchar('T');
	LDI  R30,LOW(84)
	ST   -Y,R30
	CALL _putchar
; 0000 039E     putchar('+');
	LDI  R30,LOW(43)
	ST   -Y,R30
	CALL _putchar
; 0000 039F     putchar('C');
	LDI  R30,LOW(67)
	ST   -Y,R30
	CALL _putchar
; 0000 03A0     putchar('S');
	LDI  R30,LOW(83)
	ST   -Y,R30
	CALL _putchar
; 0000 03A1     putchar('Q');
	LDI  R30,LOW(81)
	ST   -Y,R30
	CALL _putchar
; 0000 03A2     putchar(13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	CALL _putchar
; 0000 03A3     putchar(10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	CALL _putchar
; 0000 03A4     delay_ms(1000);
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 03A5 
; 0000 03A6     while (rx_counter0>0)
_0xF2:
	LDI  R30,LOW(0)
	CP   R30,R13
	BRSH _0xF4
; 0000 03A7     {
; 0000 03A8         ch1 = getchar();
	CALL _getchar
	MOV  R19,R30
; 0000 03A9         antenna[index] = ch1;
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,4
	ADD  R30,R26
	ADC  R31,R27
	ST   Z,R19
; 0000 03AA         index++;
	__ADDWRN 16,17,1
; 0000 03AB     }
	RJMP _0xF2
_0xF4:
; 0000 03AC 
; 0000 03AD     SendSMS(antenna);
	MOVW R30,R28
	ADIW R30,4
	ST   -Y,R31
	ST   -Y,R30
	RCALL _SendSMS
; 0000 03AE };
_0x20A0002:
	CALL __LOADLOCR4
	ADIW R28,4
	RET
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG
_puts:
	ST   -Y,R17
_0x2000003:
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	LD   R30,X+
	STD  Y+1,R26
	STD  Y+1+1,R27
	MOV  R17,R30
	CPI  R30,0
	BREQ _0x2000005
	ST   -Y,R17
	CALL _putchar
	RJMP _0x2000003
_0x2000005:
	LDI  R30,LOW(10)
	ST   -Y,R30
	CALL _putchar
	LDD  R17,Y+0
	RJMP _0x20A0001
_put_usart_G100:
	LDD  R30,Y+2
	ST   -Y,R30
	CALL _putchar
	LD   R26,Y
	LDD  R27,Y+1
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
_0x20A0001:
	ADIW R28,3
	RET
__print_G100:
	SBIW R28,6
	CALL __SAVELOCR6
	LDI  R17,0
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
_0x2000016:
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ADIW R30,1
	STD  Y+18,R30
	STD  Y+18+1,R31
	SBIW R30,1
	LPM  R30,Z
	MOV  R18,R30
	CPI  R30,0
	BRNE PC+3
	JMP _0x2000018
	MOV  R30,R17
	CPI  R30,0
	BRNE _0x200001C
	CPI  R18,37
	BRNE _0x200001D
	LDI  R17,LOW(1)
	RJMP _0x200001E
_0x200001D:
	ST   -Y,R18
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
_0x200001E:
	RJMP _0x200001B
_0x200001C:
	CPI  R30,LOW(0x1)
	BRNE _0x200001F
	CPI  R18,37
	BRNE _0x2000020
	ST   -Y,R18
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	RJMP _0x20000C9
_0x2000020:
	LDI  R17,LOW(2)
	LDI  R20,LOW(0)
	LDI  R16,LOW(0)
	CPI  R18,45
	BRNE _0x2000021
	LDI  R16,LOW(1)
	RJMP _0x200001B
_0x2000021:
	CPI  R18,43
	BRNE _0x2000022
	LDI  R20,LOW(43)
	RJMP _0x200001B
_0x2000022:
	CPI  R18,32
	BRNE _0x2000023
	LDI  R20,LOW(32)
	RJMP _0x200001B
_0x2000023:
	RJMP _0x2000024
_0x200001F:
	CPI  R30,LOW(0x2)
	BRNE _0x2000025
_0x2000024:
	LDI  R21,LOW(0)
	LDI  R17,LOW(3)
	CPI  R18,48
	BRNE _0x2000026
	ORI  R16,LOW(128)
	RJMP _0x200001B
_0x2000026:
	RJMP _0x2000027
_0x2000025:
	CPI  R30,LOW(0x3)
	BREQ PC+3
	JMP _0x200001B
_0x2000027:
	CPI  R18,48
	BRLO _0x200002A
	CPI  R18,58
	BRLO _0x200002B
_0x200002A:
	RJMP _0x2000029
_0x200002B:
	LDI  R26,LOW(10)
	MUL  R21,R26
	MOV  R21,R0
	MOV  R30,R18
	SUBI R30,LOW(48)
	ADD  R21,R30
	RJMP _0x200001B
_0x2000029:
	MOV  R30,R18
	CPI  R30,LOW(0x63)
	BRNE _0x200002F
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	SBIW R30,4
	STD  Y+16,R30
	STD  Y+16+1,R31
	LDD  R26,Z+4
	ST   -Y,R26
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	RJMP _0x2000030
_0x200002F:
	CPI  R30,LOW(0x73)
	BRNE _0x2000032
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	SBIW R30,4
	STD  Y+16,R30
	STD  Y+16+1,R31
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	CALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
	ST   -Y,R31
	ST   -Y,R30
	CALL _strlen
	MOV  R17,R30
	RJMP _0x2000033
_0x2000032:
	CPI  R30,LOW(0x70)
	BRNE _0x2000035
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	SBIW R30,4
	STD  Y+16,R30
	STD  Y+16+1,R31
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	CALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
	ST   -Y,R31
	ST   -Y,R30
	CALL _strlenf
	MOV  R17,R30
	ORI  R16,LOW(8)
_0x2000033:
	ORI  R16,LOW(2)
	ANDI R16,LOW(127)
	LDI  R19,LOW(0)
	RJMP _0x2000036
_0x2000035:
	CPI  R30,LOW(0x64)
	BREQ _0x2000039
	CPI  R30,LOW(0x69)
	BRNE _0x200003A
_0x2000039:
	ORI  R16,LOW(4)
	RJMP _0x200003B
_0x200003A:
	CPI  R30,LOW(0x75)
	BRNE _0x200003C
_0x200003B:
	LDI  R30,LOW(_tbl10_G100*2)
	LDI  R31,HIGH(_tbl10_G100*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R17,LOW(5)
	RJMP _0x200003D
_0x200003C:
	CPI  R30,LOW(0x58)
	BRNE _0x200003F
	ORI  R16,LOW(8)
	RJMP _0x2000040
_0x200003F:
	CPI  R30,LOW(0x78)
	BREQ PC+3
	JMP _0x2000071
_0x2000040:
	LDI  R30,LOW(_tbl16_G100*2)
	LDI  R31,HIGH(_tbl16_G100*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R17,LOW(4)
_0x200003D:
	SBRS R16,2
	RJMP _0x2000042
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	SBIW R30,4
	STD  Y+16,R30
	STD  Y+16+1,R31
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	CALL __GETW1P
	STD  Y+10,R30
	STD  Y+10+1,R31
	LDD  R26,Y+11
	TST  R26
	BRPL _0x2000043
	CALL __ANEGW1
	STD  Y+10,R30
	STD  Y+10+1,R31
	LDI  R20,LOW(45)
_0x2000043:
	CPI  R20,0
	BREQ _0x2000044
	SUBI R17,-LOW(1)
	RJMP _0x2000045
_0x2000044:
	ANDI R16,LOW(251)
_0x2000045:
	RJMP _0x2000046
_0x2000042:
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	SBIW R30,4
	STD  Y+16,R30
	STD  Y+16+1,R31
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	CALL __GETW1P
	STD  Y+10,R30
	STD  Y+10+1,R31
_0x2000046:
_0x2000036:
	SBRC R16,0
	RJMP _0x2000047
_0x2000048:
	CP   R17,R21
	BRSH _0x200004A
	SBRS R16,7
	RJMP _0x200004B
	SBRS R16,2
	RJMP _0x200004C
	ANDI R16,LOW(251)
	MOV  R18,R20
	SUBI R17,LOW(1)
	RJMP _0x200004D
_0x200004C:
	LDI  R18,LOW(48)
_0x200004D:
	RJMP _0x200004E
_0x200004B:
	LDI  R18,LOW(32)
_0x200004E:
	ST   -Y,R18
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	SUBI R21,LOW(1)
	RJMP _0x2000048
_0x200004A:
_0x2000047:
	MOV  R19,R17
	SBRS R16,1
	RJMP _0x200004F
_0x2000050:
	CPI  R19,0
	BREQ _0x2000052
	SBRS R16,3
	RJMP _0x2000053
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LPM  R18,Z+
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x2000054
_0x2000053:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R18,X+
	STD  Y+6,R26
	STD  Y+6+1,R27
_0x2000054:
	ST   -Y,R18
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	CPI  R21,0
	BREQ _0x2000055
	SUBI R21,LOW(1)
_0x2000055:
	SUBI R19,LOW(1)
	RJMP _0x2000050
_0x2000052:
	RJMP _0x2000056
_0x200004F:
_0x2000058:
	LDI  R18,LOW(48)
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __GETW1PF
	STD  Y+8,R30
	STD  Y+8+1,R31
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,2
	STD  Y+6,R30
	STD  Y+6+1,R31
_0x200005A:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CP   R26,R30
	CPC  R27,R31
	BRLO _0x200005C
	SUBI R18,-LOW(1)
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	SUB  R30,R26
	SBC  R31,R27
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0x200005A
_0x200005C:
	CPI  R18,58
	BRLO _0x200005D
	SBRS R16,3
	RJMP _0x200005E
	SUBI R18,-LOW(7)
	RJMP _0x200005F
_0x200005E:
	SUBI R18,-LOW(39)
_0x200005F:
_0x200005D:
	SBRC R16,4
	RJMP _0x2000061
	CPI  R18,49
	BRSH _0x2000063
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	SBIW R26,1
	BRNE _0x2000062
_0x2000063:
	RJMP _0x20000CA
_0x2000062:
	CP   R21,R19
	BRLO _0x2000067
	SBRS R16,0
	RJMP _0x2000068
_0x2000067:
	RJMP _0x2000066
_0x2000068:
	LDI  R18,LOW(32)
	SBRS R16,7
	RJMP _0x2000069
	LDI  R18,LOW(48)
_0x20000CA:
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x200006A
	ANDI R16,LOW(251)
	ST   -Y,R20
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	CPI  R21,0
	BREQ _0x200006B
	SUBI R21,LOW(1)
_0x200006B:
_0x200006A:
_0x2000069:
_0x2000061:
	ST   -Y,R18
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	CPI  R21,0
	BREQ _0x200006C
	SUBI R21,LOW(1)
_0x200006C:
_0x2000066:
	SUBI R19,LOW(1)
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	SBIW R26,2
	BRLO _0x2000059
	RJMP _0x2000058
_0x2000059:
_0x2000056:
	SBRS R16,0
	RJMP _0x200006D
_0x200006E:
	CPI  R21,0
	BREQ _0x2000070
	SUBI R21,LOW(1)
	LDI  R30,LOW(32)
	ST   -Y,R30
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	RJMP _0x200006E
_0x2000070:
_0x200006D:
_0x2000071:
_0x2000030:
_0x20000C9:
	LDI  R17,LOW(0)
_0x200001B:
	RJMP _0x2000016
_0x2000018:
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	CALL __GETW1P
	CALL __LOADLOCR6
	ADIW R28,20
	RET
_printf:
	PUSH R15
	MOV  R15,R24
	SBIW R28,6
	ST   -Y,R17
	ST   -Y,R16
	MOVW R26,R28
	ADIW R26,4
	CALL __ADDW2R15
	MOVW R16,R26
	LDI  R30,LOW(0)
	STD  Y+4,R30
	STD  Y+4+1,R30
	STD  Y+6,R30
	STD  Y+6+1,R30
	MOVW R26,R28
	ADIW R26,8
	CALL __ADDW2R15
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(_put_usart_G100)
	LDI  R31,HIGH(_put_usart_G100)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	RCALL __print_G100
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,8
	POP  R15
	RET

	.CSEG

	.DSEG

	.CSEG

	.CSEG
_strlen:
    ld   r26,y+
    ld   r27,y+
    clr  r30
    clr  r31
strlen0:
    ld   r22,x+
    tst  r22
    breq strlen1
    adiw r30,1
    rjmp strlen0
strlen1:
    ret
_strlenf:
    clr  r26
    clr  r27
    ld   r30,y+
    ld   r31,y+
strlenf0:
	lpm  r0,z+
    tst  r0
    breq strlenf1
    adiw r26,1
    rjmp strlenf0
strlenf1:
    movw r30,r26
    ret

	.CSEG

	.CSEG

	.DSEG
_caller_id:
	.BYTE 0x14

	.ESEG
_sms_in_e2prom:
	.BYTE 0x100
_gps_in_e2prom:
	.BYTE 0x100

	.DSEG
_rx_buffer0:
	.BYTE 0x50
_tx_buffer0:
	.BYTE 0x28
_tx_rd_index0:
	.BYTE 0x1
_tx_counter0:
	.BYTE 0x1
_rx_buffer1:
	.BYTE 0x64
_rx_wr_index1:
	.BYTE 0x1
_rx_rd_index1:
	.BYTE 0x1
_rx_counter1:
	.BYTE 0x1
__seed_G101:
	.BYTE 0x4

	.CSEG

	.CSEG
_delay_ms:
	ld   r30,y+
	ld   r31,y+
	adiw r30,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0x733
	wdr
	sbiw r30,1
	brne __delay_ms0
__delay_ms1:
	ret

__ADDW2R15:
	CLR  R0
	ADD  R26,R15
	ADC  R27,R0
	RET

__ANEGW1:
	NEG  R31
	NEG  R30
	SBCI R31,0
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__GETW1PF:
	LPM  R0,Z+
	LPM  R31,Z
	MOV  R30,R0
	RET

__EEPROMRDB:
	SBIC EECR,EEWE
	RJMP __EEPROMRDB
	PUSH R31
	IN   R31,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R30,EEDR
	OUT  SREG,R31
	POP  R31
	RET

__EEPROMWRB:
	SBIS EECR,EEWE
	RJMP __EEPROMWRB1
	WDR
	RJMP __EEPROMWRB
__EEPROMWRB1:
	IN   R25,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R24,EEDR
	CP   R30,R24
	BREQ __EEPROMWRB0
	OUT  EEDR,R30
	SBI  EECR,EEMWE
	SBI  EECR,EEWE
__EEPROMWRB0:
	OUT  SREG,R25
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

__INITLOCB:
__INITLOCW:
	ADD  R26,R28
	ADC  R27,R29
__INITLOC0:
	LPM  R0,Z+
	ST   X+,R0
	DEC  R24
	BRNE __INITLOC0
	RET

;END OF CODE MARKER
__END_OF_CODE:
