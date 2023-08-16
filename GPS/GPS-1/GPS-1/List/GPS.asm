
;CodeVisionAVR C Compiler V2.05.0 Advanced
;(C) Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type                : ATmega64
;Program type             : Application
;Clock frequency          : 8.000000 MHz
;Memory model             : Small
;Optimize for             : Size
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
	.DEF _setpoint=R5
	.DEF _Tocr=R6
	.DEF _rx_wr_index0=R4
	.DEF _rx_rd_index0=R9
	.DEF _rx_counter0=R8
	.DEF _tx_wr_index0=R11
	.DEF _tx_rd_index0=R10
	.DEF _tx_counter0=R13
	.DEF _rx_wr_index1=R12

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
	JMP  _usart1_tx_isr
	JMP  0x00
	JMP  0x00

_tbl10_G101:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G101:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

;REGISTER BIT VARIABLES INITIALIZATION
__REG_BIT_VARS:
	.DW  0x0000

_0x0:
	.DB  0x0,0x41,0x54,0x2B,0x43,0x4D,0x47,0x44
	.DB  0x3D,0x31,0x20,0xD,0x0,0x41,0x54,0x2B
	.DB  0x43,0x4D,0x47,0x44,0x3D,0x32,0x20,0xD
	.DB  0x0,0x41,0x54,0x2B,0x43,0x4D,0x47,0x44
	.DB  0x3D,0x33,0x20,0xD,0x0,0x41,0x54,0x2B
	.DB  0x43,0x4D,0x47,0x44,0x3D,0x34,0x20,0xD
	.DB  0x0,0x41,0x54,0x2B,0x43,0x4D,0x47,0x44
	.DB  0x3D,0x35,0x20,0xD,0x0,0x41,0x54,0x2B
	.DB  0x43,0x4D,0x47,0x44,0x3D,0x36,0x20,0xD
	.DB  0x0,0x41,0x54,0x2B,0x43,0x4D,0x47,0x44
	.DB  0x3D,0x37,0x20,0xD,0x0,0x41,0x54,0x2B
	.DB  0x43,0x4D,0x47,0x44,0x3D,0x38,0x20,0xD
	.DB  0x0,0x41,0x54,0x2B,0x43,0x4D,0x47,0x44
	.DB  0x3D,0x39,0x20,0xD,0x0,0x41,0x54,0x2B
	.DB  0x43,0x4D,0x47,0x44,0x3D,0x31,0x30,0x20
	.DB  0xD,0x0,0x41,0x54,0x2B,0x43,0x4D,0x47
	.DB  0x44,0x3D,0x31,0x31,0x20,0xD,0x0,0x41
	.DB  0x54,0x2B,0x43,0x4D,0x47,0x44,0x3D,0x31
	.DB  0x32,0x20,0xD,0x0,0x41,0x54,0x2B,0x43
	.DB  0x4D,0x47,0x44,0x3D,0x31,0x33,0x20,0xD
	.DB  0x0,0x41,0x54,0x2B,0x43,0x4D,0x47,0x44
	.DB  0x3D,0x31,0x34,0x20,0xD,0x0,0x41,0x54
	.DB  0x2B,0x43,0x4D,0x47,0x44,0x3D,0x31,0x35
	.DB  0x20,0xD,0x0,0x41,0x54,0x20,0xD,0x0
	.DB  0x41,0x54,0x2B,0x43,0x4D,0x47,0x46,0x3D
	.DB  0x31,0x20,0xD,0x0,0x41,0x54,0x2B,0x43
	.DB  0x4D,0x47,0x53,0x3D,0x22,0x30,0x39,0x33
	.DB  0x35,0x35,0x37,0x35,0x36,0x36,0x35,0x31
	.DB  0x22,0x20,0xD,0x0,0x41,0x54,0x44,0x20
	.DB  0x30,0x39,0x33,0x38,0x34,0x31,0x39,0x38
	.DB  0x36,0x38,0x33,0x20,0xD,0x0
_0x2040060:
	.DB  0x1
_0x2040000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x01
	.DW  0x02
	.DW  __REG_BIT_VARS*2

	.DW  0x01
	.DW  _0x3B
	.DW  _0x0*2

	.DW  0x01
	.DW  _0x43
	.DW  _0x0*2

	.DW  0x0C
	.DW  _0x4A
	.DW  _0x0*2+1

	.DW  0x0C
	.DW  _0x4A+12
	.DW  _0x0*2+13

	.DW  0x0C
	.DW  _0x4A+24
	.DW  _0x0*2+25

	.DW  0x0C
	.DW  _0x4A+36
	.DW  _0x0*2+37

	.DW  0x0C
	.DW  _0x4A+48
	.DW  _0x0*2+49

	.DW  0x0C
	.DW  _0x4A+60
	.DW  _0x0*2+61

	.DW  0x0C
	.DW  _0x4A+72
	.DW  _0x0*2+73

	.DW  0x0C
	.DW  _0x4A+84
	.DW  _0x0*2+85

	.DW  0x0C
	.DW  _0x4A+96
	.DW  _0x0*2+97

	.DW  0x0D
	.DW  _0x4A+108
	.DW  _0x0*2+109

	.DW  0x0D
	.DW  _0x4A+121
	.DW  _0x0*2+122

	.DW  0x0D
	.DW  _0x4A+134
	.DW  _0x0*2+135

	.DW  0x0D
	.DW  _0x4A+147
	.DW  _0x0*2+148

	.DW  0x0D
	.DW  _0x4A+160
	.DW  _0x0*2+161

	.DW  0x0D
	.DW  _0x4A+173
	.DW  _0x0*2+174

	.DW  0x05
	.DW  _0x7F
	.DW  _0x0*2+187

	.DW  0x0C
	.DW  _0x7F+5
	.DW  _0x0*2+192

	.DW  0x18
	.DW  _0x7F+17
	.DW  _0x0*2+204

	.DW  0x0C
	.DW  _0x7F+41
	.DW  _0x0*2+1

	.DW  0x0C
	.DW  _0x7F+53
	.DW  _0x0*2+13

	.DW  0x0C
	.DW  _0x7F+65
	.DW  _0x0*2+25

	.DW  0x0C
	.DW  _0x7F+77
	.DW  _0x0*2+37

	.DW  0x0C
	.DW  _0x7F+89
	.DW  _0x0*2+49

	.DW  0x0C
	.DW  _0x7F+101
	.DW  _0x0*2+61

	.DW  0x05
	.DW  _0x80
	.DW  _0x0*2+187

	.DW  0x0C
	.DW  _0x80+5
	.DW  _0x0*2+192

	.DW  0x0C
	.DW  _0x80+17
	.DW  _0x0*2+1

	.DW  0x0C
	.DW  _0x80+29
	.DW  _0x0*2+13

	.DW  0x0C
	.DW  _0x80+41
	.DW  _0x0*2+25

	.DW  0x0C
	.DW  _0x80+53
	.DW  _0x0*2+37

	.DW  0x0C
	.DW  _0x80+65
	.DW  _0x0*2+49

	.DW  0x0C
	.DW  _0x80+77
	.DW  _0x0*2+61

	.DW  0x12
	.DW  _0xC4
	.DW  _0x0*2+228

	.DW  0x01
	.DW  __seed_G102
	.DW  _0x2040060*2

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
;/*****************************************************
;This program was produced by the
;CodeWizardAVR V2.05.0 Advanced
;Automatic Program Generator
;© Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com
;
;Project :
;Version :
;Date    : 09/25/2011
;Author  : www.Eca.ir *** www.Webkade.ir
;Company :
;Comments:
;
;
;Chip type               : ATmega64
;Program type            : Application
;AVR Core Clock frequency: 8.000000 MHz
;Memory model            : Small
;External RAM size       : 0
;Data Stack size         : 1024
;*****************************************************/
;
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
;#include <string.h>
;#include <delay.h>
;#include <stdio.h>
;#include <stdlib.h>
;
;
;bit data_ready=0,trueData=0;
;unsigned char caller_id[20];
;float Kp,Ki,Kd,T,err,err1,err2,U,temperature;
;unsigned char setpoint;
;int Tocr;
;//------------------------------------------------------------------
;eeprom unsigned char sms_in_e2prom[256],setpoint_saved,gps_in_e2prom[256];
;
;
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
;#define RX_BUFFER_SIZE0 200
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
; 0000 0059 {

	.CSEG
_usart0_rx_isr:
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 005A char status,data;
; 0000 005B status=UCSR0A;
	ST   -Y,R17
	ST   -Y,R16
;	status -> R17
;	data -> R16
	IN   R17,11
; 0000 005C data=UDR0;
	IN   R16,12
; 0000 005D if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
	MOV  R30,R17
	ANDI R30,LOW(0x1C)
	BRNE _0x3
; 0000 005E    {
; 0000 005F    rx_buffer0[rx_wr_index0++]=data;
	MOV  R30,R4
	INC  R4
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	ST   Z,R16
; 0000 0060 #if RX_BUFFER_SIZE0 == 256
; 0000 0061    // special case for receiver buffer size=256
; 0000 0062    if (++rx_counter0 == 0)
; 0000 0063       {
; 0000 0064 #else
; 0000 0065    if (rx_wr_index0 == RX_BUFFER_SIZE0) rx_wr_index0=0;
	LDI  R30,LOW(200)
	CP   R30,R4
	BRNE _0x4
	CLR  R4
; 0000 0066    if (++rx_counter0 == RX_BUFFER_SIZE0)
_0x4:
	INC  R8
	LDI  R30,LOW(200)
	CP   R30,R8
	BRNE _0x5
; 0000 0067       {
; 0000 0068       rx_counter0=0;
	CLR  R8
; 0000 0069 #endif
; 0000 006A       rx_buffer_overflow0=1;
	SET
	BLD  R2,2
; 0000 006B       }
; 0000 006C    }
_0x5:
; 0000 006D }
_0x3:
	LD   R16,Y+
	LD   R17,Y+
	RJMP _0xD6
;
;#ifndef _DEBUG_TERMINAL_IO_
;// Get a character from the USART0 Receiver buffer
;#define _ALTERNATE_GETCHAR_
;#pragma used+
;char getchar(void)
; 0000 0074 {
_getchar:
; 0000 0075 char data;
; 0000 0076 while (rx_counter0==0);
	ST   -Y,R17
;	data -> R17
_0x6:
	TST  R8
	BREQ _0x6
; 0000 0077 data=rx_buffer0[rx_rd_index0++];
	MOV  R30,R9
	INC  R9
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	LD   R17,Z
; 0000 0078 #if RX_BUFFER_SIZE0 != 256
; 0000 0079 if (rx_rd_index0 == RX_BUFFER_SIZE0) rx_rd_index0=0;
	LDI  R30,LOW(200)
	CP   R30,R9
	BRNE _0x9
	CLR  R9
; 0000 007A #endif
; 0000 007B #asm("cli")
_0x9:
	cli
; 0000 007C --rx_counter0;
	DEC  R8
; 0000 007D #asm("sei")
	sei
	RJMP _0x20A0005
; 0000 007E return data;
; 0000 007F }
;#pragma used-
;#endif
;
;// USART0 Transmitter buffer
;#define TX_BUFFER_SIZE0 200
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
; 0000 008F {
_usart0_tx_isr:
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0090 if (tx_counter0)
	TST  R13
	BREQ _0xA
; 0000 0091    {
; 0000 0092    --tx_counter0;
	DEC  R13
; 0000 0093    UDR0=tx_buffer0[tx_rd_index0++];
	MOV  R30,R10
	INC  R10
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer0)
	SBCI R31,HIGH(-_tx_buffer0)
	LD   R30,Z
	OUT  0xC,R30
; 0000 0094 #if TX_BUFFER_SIZE0 != 256
; 0000 0095    if (tx_rd_index0 == TX_BUFFER_SIZE0) tx_rd_index0=0;
	LDI  R30,LOW(200)
	CP   R30,R10
	BRNE _0xB
	CLR  R10
; 0000 0096 #endif
; 0000 0097    }
_0xB:
; 0000 0098 }
_0xA:
_0xD6:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	RETI
;
;#ifndef _DEBUG_TERMINAL_IO_
;// Write a character to the USART0 Transmitter buffer
;#define _ALTERNATE_PUTCHAR_
;#pragma used+
;void putchar(char c)
; 0000 009F {
_putchar:
; 0000 00A0 while (tx_counter0 == TX_BUFFER_SIZE0);
;	c -> Y+0
_0xC:
	LDI  R30,LOW(200)
	CP   R30,R13
	BREQ _0xC
; 0000 00A1 #asm("cli")
	cli
; 0000 00A2 if (tx_counter0 || ((UCSR0A & DATA_REGISTER_EMPTY)==0))
	TST  R13
	BRNE _0x10
	SBIC 0xB,5
	RJMP _0xF
_0x10:
; 0000 00A3    {
; 0000 00A4    tx_buffer0[tx_wr_index0++]=c;
	MOV  R30,R11
	INC  R11
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer0)
	SBCI R31,HIGH(-_tx_buffer0)
	LD   R26,Y
	STD  Z+0,R26
; 0000 00A5 #if TX_BUFFER_SIZE0 != 256
; 0000 00A6    if (tx_wr_index0 == TX_BUFFER_SIZE0) tx_wr_index0=0;
	LDI  R30,LOW(200)
	CP   R30,R11
	BRNE _0x12
	CLR  R11
; 0000 00A7 #endif
; 0000 00A8    ++tx_counter0;
_0x12:
	INC  R13
; 0000 00A9    }
; 0000 00AA else
	RJMP _0x13
_0xF:
; 0000 00AB    UDR0=c;
	LD   R30,Y
	OUT  0xC,R30
; 0000 00AC #asm("sei")
_0x13:
	sei
; 0000 00AD }
	ADIW R28,1
	RET
;#pragma used-
;#endif
;
;// USART1 Receiver buffer
;#define RX_BUFFER_SIZE1 200
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
; 0000 00C0 {
_usart1_rx_isr:
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 00C1 char status,data;
; 0000 00C2 status=UCSR1A;
	ST   -Y,R17
	ST   -Y,R16
;	status -> R17
;	data -> R16
	LDS  R17,155
; 0000 00C3 data=UDR1;
	LDS  R16,156
; 0000 00C4 if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
	MOV  R30,R17
	ANDI R30,LOW(0x1C)
	BRNE _0x14
; 0000 00C5    {
; 0000 00C6    rx_buffer1[rx_wr_index1++]=data;
	MOV  R30,R12
	INC  R12
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer1)
	SBCI R31,HIGH(-_rx_buffer1)
	ST   Z,R16
; 0000 00C7 #if RX_BUFFER_SIZE1 == 256
; 0000 00C8    // special case for receiver buffer size=256
; 0000 00C9    if (++rx_counter1 == 0)
; 0000 00CA       {
; 0000 00CB #else
; 0000 00CC    if (rx_wr_index1 == RX_BUFFER_SIZE1) rx_wr_index1=0;
	LDI  R30,LOW(200)
	CP   R30,R12
	BRNE _0x15
	CLR  R12
; 0000 00CD    if (++rx_counter1 == RX_BUFFER_SIZE1)
_0x15:
	LDS  R26,_rx_counter1
	SUBI R26,-LOW(1)
	STS  _rx_counter1,R26
	CPI  R26,LOW(0xC8)
	BRNE _0x16
; 0000 00CE       {
; 0000 00CF       rx_counter1=0;
	LDI  R30,LOW(0)
	STS  _rx_counter1,R30
; 0000 00D0 #endif
; 0000 00D1       rx_buffer_overflow1=1;
	SET
	BLD  R2,3
; 0000 00D2       }
; 0000 00D3    }
_0x16:
; 0000 00D4 }
_0x14:
	LD   R16,Y+
	LD   R17,Y+
	RJMP _0xD5
;
;// Get a character from the USART1 Receiver buffer
;#pragma used+
;char getchar1(void)
; 0000 00D9 {
_getchar1:
; 0000 00DA char data;
; 0000 00DB while (rx_counter1==0);
	ST   -Y,R17
;	data -> R17
_0x17:
	LDS  R30,_rx_counter1
	CPI  R30,0
	BREQ _0x17
; 0000 00DC data=rx_buffer1[rx_rd_index1++];
	LDS  R30,_rx_rd_index1
	SUBI R30,-LOW(1)
	STS  _rx_rd_index1,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer1)
	SBCI R31,HIGH(-_rx_buffer1)
	LD   R17,Z
; 0000 00DD #if RX_BUFFER_SIZE1 != 256
; 0000 00DE if (rx_rd_index1 == RX_BUFFER_SIZE1) rx_rd_index1=0;
	LDS  R26,_rx_rd_index1
	CPI  R26,LOW(0xC8)
	BRNE _0x1A
	LDI  R30,LOW(0)
	STS  _rx_rd_index1,R30
; 0000 00DF #endif
; 0000 00E0 #asm("cli")
_0x1A:
	cli
; 0000 00E1 --rx_counter1;
	LDS  R30,_rx_counter1
	SUBI R30,LOW(1)
	STS  _rx_counter1,R30
; 0000 00E2 #asm("sei")
	sei
_0x20A0005:
; 0000 00E3 return data;
	MOV  R30,R17
	LD   R17,Y+
	RET
; 0000 00E4 }
;#pragma used-
;// USART1 Transmitter buffer
;#define TX_BUFFER_SIZE1 200
;char tx_buffer1[TX_BUFFER_SIZE1];
;
;#if TX_BUFFER_SIZE1 <= 256
;unsigned char tx_wr_index1,tx_rd_index1,tx_counter1;
;#else
;unsigned int tx_wr_index1,tx_rd_index1,tx_counter1;
;#endif
;
;// USART1 Transmitter interrupt service routine
;interrupt [USART1_TXC] void usart1_tx_isr(void)
; 0000 00F2 {
_usart1_tx_isr:
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 00F3 if (tx_counter1)
	LDS  R30,_tx_counter1
	CPI  R30,0
	BREQ _0x1B
; 0000 00F4    {
; 0000 00F5    --tx_counter1;
	SUBI R30,LOW(1)
	STS  _tx_counter1,R30
; 0000 00F6    UDR1=tx_buffer1[tx_rd_index1++];
	LDS  R30,_tx_rd_index1
	SUBI R30,-LOW(1)
	STS  _tx_rd_index1,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer1)
	SBCI R31,HIGH(-_tx_buffer1)
	LD   R30,Z
	STS  156,R30
; 0000 00F7 #if TX_BUFFER_SIZE1 != 256
; 0000 00F8    if (tx_rd_index1 == TX_BUFFER_SIZE1) tx_rd_index1=0;
	LDS  R26,_tx_rd_index1
	CPI  R26,LOW(0xC8)
	BRNE _0x1C
	LDI  R30,LOW(0)
	STS  _tx_rd_index1,R30
; 0000 00F9 #endif
; 0000 00FA    }
_0x1C:
; 0000 00FB }
_0x1B:
_0xD5:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
;
;// Write a character to the USART1 Transmitter buffer
;#pragma used+
;void putchar1(char c)
; 0000 0100 {
; 0000 0101 while (tx_counter1 == TX_BUFFER_SIZE1);
;	c -> Y+0
; 0000 0102 #asm("cli")
; 0000 0103 if (tx_counter1 || ((UCSR1A & DATA_REGISTER_EMPTY)==0))
; 0000 0104    {
; 0000 0105    tx_buffer1[tx_wr_index1++]=c;
; 0000 0106 #if TX_BUFFER_SIZE1 != 256
; 0000 0107    if (tx_wr_index1 == TX_BUFFER_SIZE1) tx_wr_index1=0;
; 0000 0108 #endif
; 0000 0109    ++tx_counter1;
; 0000 010A    }
; 0000 010B else
; 0000 010C    UDR1=c;
; 0000 010D #asm("sei")
; 0000 010E }
;#pragma used-
;
;// Standard Input/Output functions
;#include <stdio.h>
;
;// Declare your global variables here
;typedef char * CHAR;
;//*******************************************************************************************************
;//*******************************************************************************************************
;int GPSPosition(CHAR input)
; 0000 0119 {
_GPSPosition:
; 0000 011A     if ( strlen(input) >= 10 )
;	*input -> Y+0
	LD   R30,Y
	LDD  R31,Y+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _strlen
	SBIW R30,10
	BRLO _0x25
; 0000 011B     {
; 0000 011C         if (input[5] == 'C' || input[5] == 'c')
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,5
	LD   R26,X
	CPI  R26,LOW(0x43)
	BREQ _0x27
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,5
	LD   R26,X
	CPI  R26,LOW(0x63)
	BRNE _0x26
_0x27:
; 0000 011D             return 1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	RJMP _0x20A0003
; 0000 011E         else return 0;
_0x26:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	RJMP _0x20A0003
; 0000 011F     }
; 0000 0120 }
_0x25:
	RJMP _0x20A0003
;int GPSAnten(CHAR input)
; 0000 0122 {
; 0000 0123     if ( strlen(input) >= 10 )
;	*input -> Y+0
; 0000 0124     {
; 0000 0125         if (input[5] == 'A' || input[5] == 'a')
; 0000 0126             return 1;
; 0000 0127         else return 0;
; 0000 0128     }
; 0000 0129 }
;void process_gps()
; 0000 012B {
; 0000 012C     char GPSData[256];
; 0000 012D     unsigned char chread;
; 0000 012E     unsigned int  loopcount,index=0;
; 0000 012F     unsigned int  pkindex;
; 0000 0130     loopcount = 0;
;	GPSData -> Y+8
;	chread -> R17
;	loopcount -> R18,R19
;	index -> R20,R21
;	pkindex -> Y+6
; 0000 0131     pkindex = 0;
; 0000 0132     while (rx_counter1>0)
; 0000 0133 	{
; 0000 0134 	    chread=getchar();
; 0000 0135 	    if ((chread=='$'))
; 0000 0136         {
; 0000 0137             loopcount++;
; 0000 0138             if (loopcount == 2)
; 0000 0139             {
; 0000 013A                  if (GPSPosition(GPSData))
; 0000 013B                  {
; 0000 013C                     if (strlen(GPSData) > 10)
; 0000 013D                     {
; 0000 013E                         for (;pkindex >= index;index++)
; 0000 013F                             gps_in_e2prom[index]=GPSData[index];
; 0000 0140 trueData = 1;
; 0000 0141                     }
; 0000 0142                     else
; 0000 0143                     {
; 0000 0144                         trueData = 0;
; 0000 0145                     }
; 0000 0146                     break;
; 0000 0147                  }
; 0000 0148                  else
; 0000 0149                  {
; 0000 014A                         strcpy(GPSData,"");
; 0000 014B                         pkindex = 0;
; 0000 014C                  }
; 0000 014D             }
; 0000 014E             else
; 0000 014F             {
; 0000 0150                 GPSData[pkindex] = chread;
; 0000 0151             }
; 0000 0152 
; 0000 0153         }
; 0000 0154 	}
; 0000 0155 
; 0000 0156 }

	.DSEG
_0x3B:
	.BYTE 0x1
;
;
;CHAR Split (CHAR input, char tag, int Index)
; 0000 015A {

	.CSEG
; 0000 015B       CHAR tmpstr;
; 0000 015C       int  CountIndex = 0;
; 0000 015D       int Count;
; 0000 015E       for (Count = 0 ; Count < strlen (input); Count++)
;	*input -> Y+9
;	tag -> Y+8
;	Index -> Y+6
;	*tmpstr -> R16,R17
;	CountIndex -> R18,R19
;	Count -> R20,R21
; 0000 015F       {
; 0000 0160             if (input [Count] == tag)
; 0000 0161             {
; 0000 0162                if (CountIndex == Index)
; 0000 0163                {
; 0000 0164                     return tmpstr;
; 0000 0165                }
; 0000 0166                else
; 0000 0167                {
; 0000 0168                     strcpy (tmpstr,"");
; 0000 0169                     CountIndex++;
; 0000 016A                }
; 0000 016B             }
; 0000 016C             else
; 0000 016D             {
; 0000 016E                 strcat(tmpstr,(CHAR)(input[Count]));
; 0000 016F             }
; 0000 0170       }
; 0000 0171       return tmpstr;
; 0000 0172 }

	.DSEG
_0x43:
	.BYTE 0x1
;float GPSGetAntenQ (CHAR input)
; 0000 0174 {

	.CSEG
; 0000 0175     float Anten = 0.0;
; 0000 0176     if ( strlen(input) >= 10 )
;	*input -> Y+4
;	Anten -> Y+0
; 0000 0177     {
; 0000 0178         if (input[5] == 'A' || input[5] == 'a')
; 0000 0179         {
; 0000 017A                 Anten = atof(Split(input,',',9));
; 0000 017B         }
; 0000 017C         else
; 0000 017D         {
; 0000 017E                 Anten = 0.0;
; 0000 017F         }
; 0000 0180     }
; 0000 0181 }
;void CLSSMS ()
; 0000 0183 {
_CLSSMS:
; 0000 0184         puts("AT+CMGD=1 \r");
	__POINTW1MN _0x4A,0
	CALL SUBOPT_0x0
; 0000 0185         delay_ms(1000);
; 0000 0186         puts("AT+CMGD=2 \r");
	__POINTW1MN _0x4A,12
	CALL SUBOPT_0x0
; 0000 0187         delay_ms(1000);
; 0000 0188         puts("AT+CMGD=3 \r");
	__POINTW1MN _0x4A,24
	CALL SUBOPT_0x0
; 0000 0189         delay_ms(1000);
; 0000 018A 
; 0000 018B         puts("AT+CMGD=4 \r");
	__POINTW1MN _0x4A,36
	CALL SUBOPT_0x0
; 0000 018C         delay_ms(1000);
; 0000 018D 
; 0000 018E         puts("AT+CMGD=5 \r");
	__POINTW1MN _0x4A,48
	CALL SUBOPT_0x0
; 0000 018F         delay_ms(1000);
; 0000 0190 
; 0000 0191         puts("AT+CMGD=6 \r");
	__POINTW1MN _0x4A,60
	CALL SUBOPT_0x0
; 0000 0192         delay_ms(1000);
; 0000 0193 
; 0000 0194         puts("AT+CMGD=7 \r");
	__POINTW1MN _0x4A,72
	CALL SUBOPT_0x0
; 0000 0195         delay_ms(1000);
; 0000 0196 
; 0000 0197         puts("AT+CMGD=8 \r");
	__POINTW1MN _0x4A,84
	CALL SUBOPT_0x0
; 0000 0198         delay_ms(1000);
; 0000 0199 
; 0000 019A         puts("AT+CMGD=9 \r");
	__POINTW1MN _0x4A,96
	CALL SUBOPT_0x0
; 0000 019B         delay_ms(1000);
; 0000 019C 
; 0000 019D         puts("AT+CMGD=10 \r");
	__POINTW1MN _0x4A,108
	CALL SUBOPT_0x0
; 0000 019E         delay_ms(1000);
; 0000 019F 
; 0000 01A0         puts("AT+CMGD=11 \r");
	__POINTW1MN _0x4A,121
	CALL SUBOPT_0x0
; 0000 01A1         delay_ms(1000);
; 0000 01A2 
; 0000 01A3         puts("AT+CMGD=12 \r");
	__POINTW1MN _0x4A,134
	CALL SUBOPT_0x0
; 0000 01A4         delay_ms(1000);
; 0000 01A5 
; 0000 01A6         puts("AT+CMGD=13 \r");
	__POINTW1MN _0x4A,147
	CALL SUBOPT_0x0
; 0000 01A7         delay_ms(1000);
; 0000 01A8 
; 0000 01A9         puts("AT+CMGD=14 \r");
	__POINTW1MN _0x4A,160
	CALL SUBOPT_0x0
; 0000 01AA         delay_ms(1000);
; 0000 01AB 
; 0000 01AC         puts("AT+CMGD=15 \r");
	__POINTW1MN _0x4A,173
	CALL SUBOPT_0x0
; 0000 01AD         delay_ms(1000);
; 0000 01AE 
; 0000 01AF }
	RET

	.DSEG
_0x4A:
	.BYTE 0xBA
;void poweron(void)
; 0000 01B1 {

	.CSEG
_poweron:
; 0000 01B2     unsigned char i,ch1,ch2;
; 0000 01B3 
; 0000 01B4     while (rx_counter0>0)	getchar();
	CALL __SAVELOCR4
;	i -> R17
;	ch1 -> R16
;	ch2 -> R19
_0x4B:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0x4D
	RCALL _getchar
	RJMP _0x4B
_0x4D:
; 0000 01B5 while (1)
_0x4E:
; 0000 01B6 	{
; 0000 01B7 	    for (i=0;i<20;i++)
	LDI  R17,LOW(0)
_0x52:
	CPI  R17,20
	BRSH _0x53
; 0000 01B8 		{
; 0000 01B9 		    putchar('a');
	CALL SUBOPT_0x1
; 0000 01BA 		    putchar('t');
; 0000 01BB 		    putchar(13);
	CALL SUBOPT_0x2
; 0000 01BC 		    putchar (10);
; 0000 01BD 		    delay_ms(50);
; 0000 01BE 		}
	SUBI R17,-1
	RJMP _0x52
_0x53:
; 0000 01BF 	    while (rx_counter0>0)
_0x54:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0x56
; 0000 01C0 		{
; 0000 01C1 		    ch1=ch2;
	MOV  R16,R19
; 0000 01C2 		    ch2=getchar();
	RCALL _getchar
	MOV  R19,R30
; 0000 01C3 		    if ((ch1=='O') && (ch2=='K'))
	CPI  R16,79
	BRNE _0x58
	CPI  R19,75
	BREQ _0x59
_0x58:
	RJMP _0x57
_0x59:
; 0000 01C4 			{
; 0000 01C5 			    while (rx_counter0>0)	getchar();
_0x5A:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0x5C
	RCALL _getchar
	RJMP _0x5A
_0x5C:
; 0000 01C6 return;
	RJMP _0x20A0004
; 0000 01C7 			}
; 0000 01C8 		}
_0x57:
	RJMP _0x54
_0x56:
; 0000 01C9 	    PORTC.1=1;
	SBI  0x15,1
; 0000 01CA 	    delay_ms(2000);
	CALL SUBOPT_0x3
; 0000 01CB 	    PORTC.1=0;
	CBI  0x15,1
; 0000 01CC 	    delay_ms(100);
	CALL SUBOPT_0x4
; 0000 01CD 	}
	RJMP _0x4E
; 0000 01CE }
;void init(void)
; 0000 01D0 {
_init:
; 0000 01D1     unsigned char ch1,ch2,i,flag;
; 0000 01D2     delay_ms(100);
	CALL __SAVELOCR4
;	ch1 -> R17
;	ch2 -> R16
;	i -> R19
;	flag -> R18
	CALL SUBOPT_0x4
; 0000 01D3 
; 0000 01D4     poweron();
	RCALL _poweron
; 0000 01D5 
; 0000 01D6     flag=1;
	LDI  R18,LOW(1)
; 0000 01D7     while (flag)
_0x61:
	CPI  R18,0
	BREQ _0x63
; 0000 01D8 	{
; 0000 01D9 	    putchar ('A');
	CALL SUBOPT_0x5
; 0000 01DA 	    putchar ('T');
; 0000 01DB 	    putchar ('E');
	LDI  R30,LOW(69)
	ST   -Y,R30
	RCALL _putchar
; 0000 01DC 	    putchar ('0');
	LDI  R30,LOW(48)
	ST   -Y,R30
	RCALL _putchar
; 0000 01DD 	    putchar (13);
	CALL SUBOPT_0x2
; 0000 01DE 	    putchar (10);
; 0000 01DF 	    delay_ms(50);
; 0000 01E0 	    while (rx_counter0>0)
_0x64:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0x66
; 0000 01E1 		{
; 0000 01E2 		    ch1=ch2;
	MOV  R17,R16
; 0000 01E3 		    ch2=getchar();
	RCALL _getchar
	MOV  R16,R30
; 0000 01E4 		    if ((ch1=='O') && (ch2=='K'))	{flag=0;break;}
	CPI  R17,79
	BRNE _0x68
	CPI  R16,75
	BREQ _0x69
_0x68:
	RJMP _0x67
_0x69:
	LDI  R18,LOW(0)
	RJMP _0x66
; 0000 01E5 		}
_0x67:
	RJMP _0x64
_0x66:
; 0000 01E6 	    while (rx_counter0>0)	getchar();
_0x6A:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0x6C
	RCALL _getchar
	RJMP _0x6A
_0x6C:
; 0000 01E7 }
	RJMP _0x61
_0x63:
; 0000 01E8     flag=1;
	LDI  R18,LOW(1)
; 0000 01E9     while (flag)
_0x6D:
	CPI  R18,0
	BREQ _0x6F
; 0000 01EA 	{
; 0000 01EB 	    putchar ('A');
	CALL SUBOPT_0x5
; 0000 01EC 	    putchar ('T');
; 0000 01ED 	    putchar ('+');
	CALL SUBOPT_0x6
; 0000 01EE 	    putchar ('C');
; 0000 01EF 	    putchar ('M');
; 0000 01F0 	    putchar ('G');
; 0000 01F1 	    putchar ('F');
	LDI  R30,LOW(70)
	CALL SUBOPT_0x7
; 0000 01F2 	    putchar ('=');
; 0000 01F3 	    putchar ('1');
	CALL SUBOPT_0x8
; 0000 01F4 	    putchar (13);
; 0000 01F5 	    putchar (10);
; 0000 01F6 	    delay_ms(100);
	CALL SUBOPT_0x4
; 0000 01F7 	    while (rx_counter0>0)
_0x70:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0x72
; 0000 01F8 		{
; 0000 01F9 		    ch1=ch2;
	CALL SUBOPT_0x9
; 0000 01FA 		    ch2=getchar();
; 0000 01FB 		    if ((ch1=='O') && (ch2=='K'))	{flag=0;break;}
	CPI  R17,79
	BRNE _0x74
	CPI  R16,75
	BREQ _0x75
_0x74:
	RJMP _0x73
_0x75:
	LDI  R18,LOW(0)
	RJMP _0x72
; 0000 01FC 		}
_0x73:
	RJMP _0x70
_0x72:
; 0000 01FD 	    while (rx_counter0>0)	getchar();
_0x76:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0x78
	RCALL _getchar
	RJMP _0x76
_0x78:
; 0000 01FE }
	RJMP _0x6D
_0x6F:
; 0000 01FF     for (i=1;i<=9;i++)
	LDI  R19,LOW(1)
_0x7A:
	CPI  R19,10
	BRSH _0x7B
; 0000 0200 	{
; 0000 0201 	    putchar ('A');
	CALL SUBOPT_0x5
; 0000 0202 	    putchar ('T');
; 0000 0203 	    putchar ('+');
	CALL SUBOPT_0x6
; 0000 0204 	    putchar ('C');
; 0000 0205 	    putchar ('M');
; 0000 0206 	    putchar ('G');
; 0000 0207 	    putchar ('D');
	LDI  R30,LOW(68)
	CALL SUBOPT_0x7
; 0000 0208 	    putchar ('=');
; 0000 0209 	    putchar (i+48);
	MOV  R30,R19
	SUBI R30,-LOW(48)
	ST   -Y,R30
	RCALL _putchar
; 0000 020A 	    putchar (13);
	CALL SUBOPT_0x2
; 0000 020B 	    putchar (10);
; 0000 020C 	    delay_ms(50);
; 0000 020D 	}
	SUBI R19,-1
	RJMP _0x7A
_0x7B:
; 0000 020E 
; 0000 020F     while (rx_counter0>0)	getchar();
_0x7C:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0x7E
	RCALL _getchar
	RJMP _0x7C
_0x7E:
; 0000 0210 }
_0x20A0004:
	CALL __LOADLOCR4
	ADIW R28,4
	RET
;void SendSMS(CHAR Massage)
; 0000 0212 {
_SendSMS:
; 0000 0213      puts("AT \r");
;	*Massage -> Y+0
	__POINTW1MN _0x7F,0
	CALL SUBOPT_0xA
; 0000 0214      delay_ms(20);
; 0000 0215      puts("AT+CMGF=1 \r");
	__POINTW1MN _0x7F,5
	CALL SUBOPT_0xA
; 0000 0216      delay_ms(20);
; 0000 0217      puts("AT+CMGS=\"09355756651\" \r");
	__POINTW1MN _0x7F,17
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
; 0000 0218      delay_ms(300);
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	CALL SUBOPT_0xB
; 0000 0219      puts(Massage);
	LD   R30,Y
	LDD  R31,Y+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
; 0000 021A      putchar(0x1A);
	LDI  R30,LOW(26)
	ST   -Y,R30
	RCALL _putchar
; 0000 021B      delay_ms(20);
	LDI  R30,LOW(20)
	LDI  R31,HIGH(20)
	CALL SUBOPT_0xB
; 0000 021C      puts("AT+CMGD=1 \r");
	__POINTW1MN _0x7F,41
	CALL SUBOPT_0x0
; 0000 021D      delay_ms(1000);
; 0000 021E      puts("AT+CMGD=2 \r");
	__POINTW1MN _0x7F,53
	CALL SUBOPT_0x0
; 0000 021F      delay_ms(1000);
; 0000 0220      puts("AT+CMGD=3 \r");
	__POINTW1MN _0x7F,65
	CALL SUBOPT_0x0
; 0000 0221      delay_ms(1000);
; 0000 0222      puts("AT+CMGD=4 \r");
	__POINTW1MN _0x7F,77
	CALL SUBOPT_0x0
; 0000 0223      delay_ms(1000);
; 0000 0224      puts("AT+CMGD=5 \r");
	__POINTW1MN _0x7F,89
	CALL SUBOPT_0x0
; 0000 0225      delay_ms(1000);
; 0000 0226      puts("AT+CMGD=6 \r");
	__POINTW1MN _0x7F,101
	CALL SUBOPT_0x0
; 0000 0227      delay_ms(1000);
; 0000 0228 
; 0000 0229 }
_0x20A0003:
	ADIW R28,2
	RET

	.DSEG
_0x7F:
	.BYTE 0x71
;
;void SendSMSToNum(CHAR tel,CHAR Massage)
; 0000 022C {

	.CSEG
; 0000 022D      char tmp [];
; 0000 022E      puts("AT \r");
;	*tel -> Y+2
;	*Massage -> Y+0
;	tmp -> Y+0
; 0000 022F      delay_ms(20);
; 0000 0230      puts("AT+CMGF=1 \r");
; 0000 0231      delay_ms(20);
; 0000 0232      tmp[0] = 'A';
; 0000 0233      tmp[1] = 'T';
; 0000 0234      tmp[2] = '+';
; 0000 0235      tmp[3] = 'C';
; 0000 0236      tmp[4] = 'M';
; 0000 0237      tmp[5] = 'G';
; 0000 0238      tmp[6] = 'S';
; 0000 0239      tmp[7] = '=';
; 0000 023A      tmp[8] = '"';
; 0000 023B      tmp[9] = tel[0];
; 0000 023C      tmp[10] = tel[1];
; 0000 023D      tmp[11] = tel[2];
; 0000 023E      tmp[12] = tel[3];
; 0000 023F      tmp[13] = tel[4];
; 0000 0240      tmp[14] = tel[5];
; 0000 0241      tmp[15] = tel[6];
; 0000 0242      tmp[16] = tel[7];
; 0000 0243      tmp[17] = tel[8];
; 0000 0244      tmp[18] = tel[9];
; 0000 0245      tmp[19] = tel[10];
; 0000 0246      tmp[20] = '"';
; 0000 0247      tmp[21] = ' ';
; 0000 0248      tmp[22] = '\r';
; 0000 0249      puts(tmp);
; 0000 024A      delay_ms(300);
; 0000 024B      puts(Massage);
; 0000 024C      putchar(0x1A);
; 0000 024D      delay_ms(20);
; 0000 024E      puts("AT+CMGD=1 \r");
; 0000 024F      delay_ms(1000);
; 0000 0250      puts("AT+CMGD=2 \r");
; 0000 0251      delay_ms(1000);
; 0000 0252      puts("AT+CMGD=3 \r");
; 0000 0253      delay_ms(1000);
; 0000 0254      puts("AT+CMGD=4 \r");
; 0000 0255      delay_ms(1000);
; 0000 0256      puts("AT+CMGD=5 \r");
; 0000 0257      delay_ms(1000);
; 0000 0258      puts("AT+CMGD=6 \r");
; 0000 0259      delay_ms(1000);
; 0000 025A 
; 0000 025B }

	.DSEG
_0x80:
	.BYTE 0x59
;
;void process_sms(void)
; 0000 025E {

	.CSEG
_process_sms:
; 0000 025F     unsigned char tmp [];
; 0000 0260     unsigned char pos [];
; 0000 0261     unsigned char ch1,ch2,ch3,ch4,ch5;
; 0000 0262     unsigned char i,temp,sms_valid=0;
; 0000 0263     unsigned int data_length, index,tagpos;
; 0000 0264 
; 0000 0265     data_length=sms_in_e2prom[0];
	SBIW R28,8
	LDI  R30,LOW(0)
	STD  Y+6,R30
	CALL __SAVELOCR6
;	tmp -> Y+14
;	pos -> Y+14
;	ch1 -> R17
;	ch2 -> R16
;	ch3 -> R19
;	ch4 -> R18
;	ch5 -> R21
;	i -> R20
;	temp -> Y+13
;	sms_valid -> Y+12
;	data_length -> Y+10
;	index -> Y+8
;	tagpos -> Y+6
	CALL SUBOPT_0xC
; 0000 0266     if (data_length>16) data_length=10;
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	SBIW R26,17
	BRLO _0x81
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	STD  Y+10,R30
	STD  Y+10+1,R31
; 0000 0267     delay_ms(5000);
_0x81:
	LDI  R30,LOW(5000)
	LDI  R31,HIGH(5000)
	CALL SUBOPT_0xB
; 0000 0268     data_length=sms_in_e2prom[0];
	CALL SUBOPT_0xC
; 0000 0269     for (i=1;i<=data_length;i++)
	LDI  R20,LOW(1)
_0x83:
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	MOV  R26,R20
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BRLO _0x84
; 0000 026A 	{
; 0000 026B 	    ch1=ch2;
	MOV  R17,R16
; 0000 026C 	    ch2=ch3;
	MOV  R16,R19
; 0000 026D 	    ch3=ch4;
	MOV  R19,R18
; 0000 026E 	    ch4=ch5;
	MOV  R18,R21
; 0000 026F 	    ch5=sms_in_e2prom[i];
	MOV  R26,R20
	LDI  R27,0
	SUBI R26,LOW(-_sms_in_e2prom)
	SBCI R27,HIGH(-_sms_in_e2prom)
	CALL __EEPROMRDB
	MOV  R21,R30
; 0000 0270 
; 0000 0271 	    if ((ch1=='X') && (ch2=='1') && (ch3=='1') && (ch4=='0') && (ch5=='0'))	{sms_valid=1;break;}
	CPI  R17,88
	BRNE _0x86
	CPI  R16,49
	BRNE _0x86
	CPI  R19,49
	BRNE _0x86
	CPI  R18,48
	BRNE _0x86
	CPI  R21,48
	BREQ _0x87
_0x86:
	RJMP _0x85
_0x87:
	LDI  R30,LOW(1)
	STD  Y+12,R30
	RJMP _0x84
; 0000 0272 	}
_0x85:
	SUBI R20,-1
	RJMP _0x83
_0x84:
; 0000 0273 
; 0000 0274     if (!sms_valid)
	LDD  R30,Y+12
	CPI  R30,0
	BRNE _0x88
; 0000 0275     {
; 0000 0276         CLSSMS();
	CALL SUBOPT_0xD
; 0000 0277         delay_ms(1000);
; 0000 0278         return;
	RJMP _0x20A0002
; 0000 0279     }
; 0000 027A 
; 0000 027B     tmp [0]=sms_in_e2prom[i+1];
_0x88:
	CALL SUBOPT_0xE
	__ADDW1MN _sms_in_e2prom,1
	MOVW R26,R30
	CALL __EEPROMRDB
	STD  Y+14,R30
; 0000 027C     tmp [1]=sms_in_e2prom[i+2];
	CALL SUBOPT_0xE
	__ADDW1MN _sms_in_e2prom,2
	MOVW R26,R30
	CALL __EEPROMRDB
	STD  Y+15,R30
; 0000 027D     tmp [2]=sms_in_e2prom[i+3];
	CALL SUBOPT_0xE
	__ADDW1MN _sms_in_e2prom,3
	MOVW R26,R30
	CALL __EEPROMRDB
	STD  Y+16,R30
; 0000 027E     if (tmp[0] == 'p' && tmp[1] == 'o' && tmp[2] == 's')
	LDD  R26,Y+14
	CPI  R26,LOW(0x70)
	BRNE _0x8A
	LDD  R26,Y+15
	CPI  R26,LOW(0x6F)
	BRNE _0x8A
	LDD  R26,Y+16
	CPI  R26,LOW(0x73)
	BREQ _0x8B
_0x8A:
	RJMP _0x89
_0x8B:
; 0000 027F     {
; 0000 0280         index  = -1;
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 0281         tagpos = 0;
	LDI  R30,LOW(0)
	STD  Y+6,R30
	STD  Y+6+1,R30
; 0000 0282         while (1)
_0x8C:
; 0000 0283         {
; 0000 0284 
; 0000 0285             ch1 = getchar1();
	RCALL _getchar1
	MOV  R17,R30
; 0000 0286             if (ch1 == '$' && tagpos == 1)
	CPI  R17,36
	BRNE _0x90
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	SBIW R26,1
	BREQ _0x91
_0x90:
	RJMP _0x8F
_0x91:
; 0000 0287             {
; 0000 0288                     if(GPSPosition(pos))
	MOVW R30,R28
	ADIW R30,14
	ST   -Y,R31
	ST   -Y,R30
	RCALL _GPSPosition
	SBIW R30,0
	BRNE _0x8E
; 0000 0289                         break;
; 0000 028A                     else
; 0000 028B                     {
; 0000 028C                         index  = 0;
	LDI  R30,LOW(0)
	STD  Y+8,R30
	STD  Y+8+1,R30
; 0000 028D                         tagpos = 0;
	STD  Y+6,R30
	STD  Y+6+1,R30
; 0000 028E                     }
; 0000 028F             }
; 0000 0290             else if (ch1 == '$')
	RJMP _0x94
_0x8F:
	CPI  R17,36
	BRNE _0x95
; 0000 0291             {
; 0000 0292                 tagpos++;
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,1
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0293                 index = 0;
	LDI  R30,LOW(0)
	STD  Y+8,R30
	STD  Y+8+1,R30
; 0000 0294             }
; 0000 0295             else
	RJMP _0x96
_0x95:
; 0000 0296                 index++;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 0297             pos[index] = ch1;
_0x96:
_0x94:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	MOVW R26,R28
	ADIW R26,14
	ADD  R30,R26
	ADC  R31,R27
	ST   Z,R17
; 0000 0298         }
	RJMP _0x8C
_0x8E:
; 0000 0299             SendSMS(pos);
; 0000 029A             //SendSMSToNum(caller_id,pos);
; 0000 029B     }
; 0000 029C     else
_0x89:
; 0000 029D     {
; 0000 029E         SendSMS(tmp);
_0xD4:
	MOVW R30,R28
	ADIW R30,14
	ST   -Y,R31
	ST   -Y,R30
	RCALL _SendSMS
; 0000 029F     }
; 0000 02A0 
; 0000 02A1 }
_0x20A0002:
	CALL __LOADLOCR6
	ADIW R28,14
	RET
;void process_data(void)
; 0000 02A3 {
_process_data:
; 0000 02A4     unsigned char ch1,ch2,ch3,ch4,ch5,ch6;
; 0000 02A5     unsigned char i=0,memory_index,temp,sms_ready=0;
; 0000 02A6 
; 0000 02A7     data_ready=0;
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
; 0000 02A8     delay_ms(1000);
	CALL SUBOPT_0xF
; 0000 02A9 
; 0000 02AA     while (rx_counter0>0)
_0x98:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0x9A
; 0000 02AB 	{
; 0000 02AC 	    ch1=ch2;
	MOV  R17,R16
; 0000 02AD 	    ch2=ch3;
	MOV  R16,R19
; 0000 02AE 	    ch3=ch4;
	MOV  R19,R18
; 0000 02AF 	    ch4=ch5;
	MOV  R18,R21
; 0000 02B0 	    ch5=ch6;
	MOV  R21,R20
; 0000 02B1 	    ch6=getchar();
	RCALL _getchar
	MOV  R20,R30
; 0000 02B2 	    if ((ch1=='+') && (ch2=='C') && (ch3=='M') && (ch4=='T') && (ch5=='I') && (ch6==':'))	{sms_ready=1;break;}
	CPI  R17,43
	BRNE _0x9C
	CPI  R16,67
	BRNE _0x9C
	CPI  R19,77
	BRNE _0x9C
	CPI  R18,84
	BRNE _0x9C
	CPI  R21,73
	BRNE _0x9C
	CPI  R20,58
	BREQ _0x9D
_0x9C:
	RJMP _0x9B
_0x9D:
	LDI  R30,LOW(1)
	STD  Y+6,R30
	RJMP _0x9A
; 0000 02B3 	}
_0x9B:
	RJMP _0x98
_0x9A:
; 0000 02B4     if (!sms_ready)	return;
	LDD  R30,Y+6
	CPI  R30,0
	BRNE _0x9E
	RJMP _0x20A0001
; 0000 02B5     delay_ms(1000);
_0x9E:
	CALL SUBOPT_0xF
; 0000 02B6     while (rx_counter0>0)	getchar();
_0x9F:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0xA1
	RCALL _getchar
	RJMP _0x9F
_0xA1:
; 0000 02B7 putchar('a');
	CALL SUBOPT_0x1
; 0000 02B8     putchar('t');
; 0000 02B9     putchar('+');
	CALL SUBOPT_0x10
; 0000 02BA     putchar('c');
; 0000 02BB     putchar('m');
; 0000 02BC     putchar('g');
; 0000 02BD     putchar('r');
	LDI  R30,LOW(114)
	CALL SUBOPT_0x7
; 0000 02BE     putchar('=');
; 0000 02BF     putchar('1');
	CALL SUBOPT_0x8
; 0000 02C0     putchar(13);
; 0000 02C1     putchar(10);
; 0000 02C2 
; 0000 02C3     for (i=0;i<3;i++)	while(getchar()!='"');
	LDI  R30,LOW(0)
	STD  Y+9,R30
_0xA3:
	LDD  R26,Y+9
	CPI  R26,LOW(0x3)
	BRSH _0xA4
_0xA5:
	RCALL _getchar
	CPI  R30,LOW(0x22)
	BRNE _0xA5
	LDD  R30,Y+9
	SUBI R30,-LOW(1)
	STD  Y+9,R30
	RJMP _0xA3
_0xA4:
; 0000 02C4     for (i=0;i<20;i++) caller_id[i]=0;
	LDI  R30,LOW(0)
	STD  Y+9,R30
_0xA9:
	LDD  R26,Y+9
	CPI  R26,LOW(0x14)
	BRSH _0xAA
	CALL SUBOPT_0x11
	LDI  R26,LOW(0)
	STD  Z+0,R26
	LDD  R30,Y+9
	SUBI R30,-LOW(1)
	STD  Y+9,R30
	RJMP _0xA9
_0xAA:
; 0000 02C5 for (i=1;i<20;i++)
	LDI  R30,LOW(1)
	STD  Y+9,R30
_0xAC:
	LDD  R26,Y+9
	CPI  R26,LOW(0x14)
	BRSH _0xAD
; 0000 02C6 	{
; 0000 02C7 	    temp=getchar();
	RCALL _getchar
	STD  Y+7,R30
; 0000 02C8 	    if (temp=='"') break;
	LDD  R26,Y+7
	CPI  R26,LOW(0x22)
	BREQ _0xAD
; 0000 02C9 	    caller_id[i]=temp;
	CALL SUBOPT_0x11
	LDD  R26,Y+7
	STD  Z+0,R26
; 0000 02CA 	}
	LDD  R30,Y+9
	SUBI R30,-LOW(1)
	STD  Y+9,R30
	RJMP _0xAC
_0xAD:
; 0000 02CB     caller_id[0]=i-1;
	LDD  R30,Y+9
	LDI  R31,0
	SBIW R30,1
	STS  _caller_id,R30
; 0000 02CC     delay_ms(1000);
	CALL SUBOPT_0xF
; 0000 02CD     while (rx_counter0!=0)
_0xAF:
	TST  R8
	BREQ _0xB1
; 0000 02CE 	{
; 0000 02CF 	    ch1=ch2;
	CALL SUBOPT_0x9
; 0000 02D0 	    ch2=getchar();
; 0000 02D1 	    if ((ch1==13)&&(ch2==10)) break;
	CPI  R17,13
	BRNE _0xB3
	CPI  R16,10
	BREQ _0xB4
_0xB3:
	RJMP _0xB2
_0xB4:
	RJMP _0xB1
; 0000 02D2 	}
_0xB2:
	RJMP _0xAF
_0xB1:
; 0000 02D3 
; 0000 02D4     i=0;
	LDI  R30,LOW(0)
	STD  Y+9,R30
; 0000 02D5     while (1)
_0xB5:
; 0000 02D6 	{
; 0000 02D7 	    ch1=ch2;
	CALL SUBOPT_0x9
; 0000 02D8 	    ch2=getchar();
; 0000 02D9 	    if ((ch1='O')&&(ch2=='K')) break;
	LDI  R30,LOW(79)
	MOV  R17,R30
	CPI  R30,0
	BREQ _0xB9
	CPI  R16,75
	BREQ _0xBA
_0xB9:
	RJMP _0xB8
_0xBA:
	RJMP _0xB7
; 0000 02DA 
; 0000 02DB 	    sms_in_e2prom[++i]=ch2;
_0xB8:
	LDD  R30,Y+9
	SUBI R30,-LOW(1)
	STD  Y+9,R30
	LDI  R31,0
	SUBI R30,LOW(-_sms_in_e2prom)
	SBCI R31,HIGH(-_sms_in_e2prom)
	MOVW R26,R30
	MOV  R30,R16
	CALL __EEPROMWRB
; 0000 02DC 	}
	RJMP _0xB5
_0xB7:
; 0000 02DD     sms_in_e2prom[0]=i;
	LDD  R30,Y+9
	LDI  R26,LOW(_sms_in_e2prom)
	LDI  R27,HIGH(_sms_in_e2prom)
	CALL __EEPROMWRB
; 0000 02DE     while (rx_counter0>0)	getchar();
_0xBB:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0xBD
	RCALL _getchar
	RJMP _0xBB
_0xBD:
; 0000 02E0 for (i=1;i<=9;i++)
	LDI  R30,LOW(1)
	STD  Y+9,R30
_0xBF:
	LDD  R26,Y+9
	CPI  R26,LOW(0xA)
	BRSH _0xC0
; 0000 02E1 	{
; 0000 02E2 	    putchar ('a');
	CALL SUBOPT_0x1
; 0000 02E3     	putchar ('t');
; 0000 02E4 	    putchar ('+');
	CALL SUBOPT_0x10
; 0000 02E5 	    putchar ('c');
; 0000 02E6 	    putchar ('m');
; 0000 02E7 	    putchar ('g');
; 0000 02E8 	    putchar ('d');
	LDI  R30,LOW(100)
	CALL SUBOPT_0x7
; 0000 02E9 	    putchar ('=');
; 0000 02EA 	    putchar (i+48);
	LDD  R30,Y+9
	SUBI R30,-LOW(48)
	ST   -Y,R30
	RCALL _putchar
; 0000 02EB 	    putchar (13);
	LDI  R30,LOW(13)
	ST   -Y,R30
	RCALL _putchar
; 0000 02EC 	    putchar (10);
	LDI  R30,LOW(10)
	ST   -Y,R30
	RCALL _putchar
; 0000 02ED 	}
	LDD  R30,Y+9
	SUBI R30,-LOW(1)
	STD  Y+9,R30
	RJMP _0xBF
_0xC0:
; 0000 02EE     delay_ms(200);
	LDI  R30,LOW(200)
	LDI  R31,HIGH(200)
	CALL SUBOPT_0xB
; 0000 02EF     while (rx_counter0>0)	getchar();
_0xC1:
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0xC3
	RCALL _getchar
	RJMP _0xC1
_0xC3:
; 0000 02F0 process_sms();
	RCALL _process_sms
; 0000 02F1 }
_0x20A0001:
	CALL __LOADLOCR6
	ADIW R28,10
	RET
;
;void CallTest ()
; 0000 02F4 {
; 0000 02F5     puts("ATD 09384198683 \r");
; 0000 02F6 }

	.DSEG
_0xC4:
	.BYTE 0x12
;
;void ClearBuffer ()
; 0000 02F9 {

	.CSEG
; 0000 02FA     int Count;
; 0000 02FB     for (Count = 0; Count < rx_counter0; Count++)
;	Count -> R16,R17
; 0000 02FC     {
; 0000 02FD         rx_buffer0[Count] = '';
; 0000 02FE     }
; 0000 02FF }
;//*******************************************************************************************************
;//*******************************************************************************************************
;int count;
;char chr;
;int len;
;char read[];
;char *tmp;
;void main(void)
; 0000 0308 {
_main:
; 0000 0309 // Declare your local variables here
; 0000 030A 
; 0000 030B // Input/Output Ports initialization
; 0000 030C // Port A initialization
; 0000 030D // Func7=In Func6=Out Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 030E // State7=T State6=0 State5=T State4=T State3=T State2=T State1=T State0=T
; 0000 030F PORTA=0x00;
	LDI  R30,LOW(0)
	OUT  0x1B,R30
; 0000 0310 DDRA=0x40;
	LDI  R30,LOW(64)
	OUT  0x1A,R30
; 0000 0311 
; 0000 0312 // Port B initialization
; 0000 0313 // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 0314 // State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T
; 0000 0315 PORTB=0x00;
	LDI  R30,LOW(0)
	OUT  0x18,R30
; 0000 0316 DDRB=0x00;
	OUT  0x17,R30
; 0000 0317 
; 0000 0318 // Port C initialization
; 0000 0319 // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=Out
; 0000 031A // State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=0
; 0000 031B PORTC=0x00;
	OUT  0x15,R30
; 0000 031C DDRC=0x01;
	LDI  R30,LOW(1)
	OUT  0x14,R30
; 0000 031D 
; 0000 031E // Port D initialization
; 0000 031F // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 0320 // State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T
; 0000 0321 PORTD=0x00;
	LDI  R30,LOW(0)
	OUT  0x12,R30
; 0000 0322 DDRD=0x00;
	OUT  0x11,R30
; 0000 0323 
; 0000 0324 // Port E initialization
; 0000 0325 // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 0326 // State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T
; 0000 0327 PORTE=0x00;
	OUT  0x3,R30
; 0000 0328 DDRE=0x00;
	OUT  0x2,R30
; 0000 0329 
; 0000 032A // Port F initialization
; 0000 032B // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 032C // State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T
; 0000 032D PORTF=0x00;
	STS  98,R30
; 0000 032E DDRF=0x00;
	STS  97,R30
; 0000 032F 
; 0000 0330 // Port G initialization
; 0000 0331 // Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 0332 // State4=T State3=T State2=T State1=T State0=T
; 0000 0333 PORTG=0x00;
	STS  101,R30
; 0000 0334 DDRG=0x00;
	STS  100,R30
; 0000 0335 
; 0000 0336 // Timer/Counter 0 initialization
; 0000 0337 // Clock source: System Clock
; 0000 0338 // Clock value: Timer 0 Stopped
; 0000 0339 // Mode: Normal top=0xFF
; 0000 033A // OC0 output: Disconnected
; 0000 033B ASSR=0x00;
	OUT  0x30,R30
; 0000 033C TCCR0=0x00;
	OUT  0x33,R30
; 0000 033D TCNT0=0x00;
	OUT  0x32,R30
; 0000 033E OCR0=0x00;
	OUT  0x31,R30
; 0000 033F 
; 0000 0340 // Timer/Counter 1 initialization
; 0000 0341 // Clock source: System Clock
; 0000 0342 // Clock value: Timer1 Stopped
; 0000 0343 // Mode: Normal top=0xFFFF
; 0000 0344 // OC1A output: Discon.
; 0000 0345 // OC1B output: Discon.
; 0000 0346 // OC1C output: Discon.
; 0000 0347 // Noise Canceler: Off
; 0000 0348 // Input Capture on Falling Edge
; 0000 0349 // Timer1 Overflow Interrupt: Off
; 0000 034A // Input Capture Interrupt: Off
; 0000 034B // Compare A Match Interrupt: Off
; 0000 034C // Compare B Match Interrupt: Off
; 0000 034D // Compare C Match Interrupt: Off
; 0000 034E TCCR1A=0x00;
	OUT  0x2F,R30
; 0000 034F TCCR1B=0x00;
	OUT  0x2E,R30
; 0000 0350 TCNT1H=0x00;
	OUT  0x2D,R30
; 0000 0351 TCNT1L=0x00;
	OUT  0x2C,R30
; 0000 0352 ICR1H=0x00;
	OUT  0x27,R30
; 0000 0353 ICR1L=0x00;
	OUT  0x26,R30
; 0000 0354 OCR1AH=0x00;
	OUT  0x2B,R30
; 0000 0355 OCR1AL=0x00;
	OUT  0x2A,R30
; 0000 0356 OCR1BH=0x00;
	OUT  0x29,R30
; 0000 0357 OCR1BL=0x00;
	OUT  0x28,R30
; 0000 0358 OCR1CH=0x00;
	STS  121,R30
; 0000 0359 OCR1CL=0x00;
	STS  120,R30
; 0000 035A 
; 0000 035B // Timer/Counter 2 initialization
; 0000 035C // Clock source: System Clock
; 0000 035D // Clock value: Timer2 Stopped
; 0000 035E // Mode: Normal top=0xFF
; 0000 035F // OC2 output: Disconnected
; 0000 0360 TCCR2=0x00;
	OUT  0x25,R30
; 0000 0361 TCNT2=0x00;
	OUT  0x24,R30
; 0000 0362 OCR2=0x00;
	OUT  0x23,R30
; 0000 0363 
; 0000 0364 // Timer/Counter 3 initialization
; 0000 0365 // Clock source: System Clock
; 0000 0366 // Clock value: Timer3 Stopped
; 0000 0367 // Mode: Normal top=0xFFFF
; 0000 0368 // OC3A output: Discon.
; 0000 0369 // OC3B output: Discon.
; 0000 036A // OC3C output: Discon.
; 0000 036B // Noise Canceler: Off
; 0000 036C // Input Capture on Falling Edge
; 0000 036D // Timer3 Overflow Interrupt: Off
; 0000 036E // Input Capture Interrupt: Off
; 0000 036F // Compare A Match Interrupt: Off
; 0000 0370 // Compare B Match Interrupt: Off
; 0000 0371 // Compare C Match Interrupt: Off
; 0000 0372 TCCR3A=0x00;
	STS  139,R30
; 0000 0373 TCCR3B=0x00;
	STS  138,R30
; 0000 0374 TCNT3H=0x00;
	STS  137,R30
; 0000 0375 TCNT3L=0x00;
	STS  136,R30
; 0000 0376 ICR3H=0x00;
	STS  129,R30
; 0000 0377 ICR3L=0x00;
	STS  128,R30
; 0000 0378 OCR3AH=0x00;
	STS  135,R30
; 0000 0379 OCR3AL=0x00;
	STS  134,R30
; 0000 037A OCR3BH=0x00;
	STS  133,R30
; 0000 037B OCR3BL=0x00;
	STS  132,R30
; 0000 037C OCR3CH=0x00;
	STS  131,R30
; 0000 037D OCR3CL=0x00;
	STS  130,R30
; 0000 037E 
; 0000 037F // External Interrupt(s) initialization
; 0000 0380 // INT0: Off
; 0000 0381 // INT1: Off
; 0000 0382 // INT2: Off
; 0000 0383 // INT3: Off
; 0000 0384 // INT4: Off
; 0000 0385 // INT5: Off
; 0000 0386 // INT6: Off
; 0000 0387 // INT7: Off
; 0000 0388 EICRA=0x00;
	STS  106,R30
; 0000 0389 EICRB=0x00;
	OUT  0x3A,R30
; 0000 038A EIMSK=0x00;
	OUT  0x39,R30
; 0000 038B 
; 0000 038C // Timer(s)/Counter(s) Interrupt(s) initialization
; 0000 038D TIMSK=0x00;
	OUT  0x37,R30
; 0000 038E 
; 0000 038F ETIMSK=0x00;
	STS  125,R30
; 0000 0390 
; 0000 0391 // USART0 initialization
; 0000 0392 // Communication Parameters: 8 Data, 1 Stop, No Parity
; 0000 0393 // USART0 Receiver: On
; 0000 0394 // USART0 Transmitter: On
; 0000 0395 // USART0 Mode: Asynchronous
; 0000 0396 // USART0 Baud Rate: 9600 (Double Speed Mode)
; 0000 0397 UCSR0A=0x02;
	LDI  R30,LOW(2)
	OUT  0xB,R30
; 0000 0398 UCSR0B=0xD8;
	LDI  R30,LOW(216)
	OUT  0xA,R30
; 0000 0399 UCSR0C=0x06;
	LDI  R30,LOW(6)
	STS  149,R30
; 0000 039A UBRR0H=0x00;
	LDI  R30,LOW(0)
	STS  144,R30
; 0000 039B UBRR0L=0x67;
	LDI  R30,LOW(103)
	OUT  0x9,R30
; 0000 039C 
; 0000 039D // USART1 initialization
; 0000 039E // Communication Parameters: 8 Data, 1 Stop, No Parity
; 0000 039F // USART1 Receiver: On
; 0000 03A0 // USART1 Transmitter: On
; 0000 03A1 // USART1 Mode: Asynchronous
; 0000 03A2 // USART1 Baud Rate: 4800 (Double Speed Mode)
; 0000 03A3 UCSR1A=0x02;
	LDI  R30,LOW(2)
	STS  155,R30
; 0000 03A4 UCSR1B=0xD8;
	LDI  R30,LOW(216)
	STS  154,R30
; 0000 03A5 UCSR1C=0x06;
	LDI  R30,LOW(6)
	STS  157,R30
; 0000 03A6 UBRR1H=0x00;
	LDI  R30,LOW(0)
	STS  152,R30
; 0000 03A7 UBRR1L=0xCF;
	LDI  R30,LOW(207)
	STS  153,R30
; 0000 03A8 
; 0000 03A9 // Analog Comparator initialization
; 0000 03AA // Analog Comparator: Off
; 0000 03AB // Analog Comparator Input Capture by Timer/Counter 1: Off
; 0000 03AC ACSR=0x80;
	LDI  R30,LOW(128)
	OUT  0x8,R30
; 0000 03AD SFIOR=0x00;
	LDI  R30,LOW(0)
	OUT  0x20,R30
; 0000 03AE 
; 0000 03AF // ADC initialization
; 0000 03B0 // ADC disabled
; 0000 03B1 ADCSRA=0x00;
	OUT  0x6,R30
; 0000 03B2 
; 0000 03B3 // SPI initialization
; 0000 03B4 // SPI disabled
; 0000 03B5 SPCR=0x00;
	OUT  0xD,R30
; 0000 03B6 
; 0000 03B7 // TWI initialization
; 0000 03B8 // TWI disabled
; 0000 03B9 TWCR=0x00;
	STS  116,R30
; 0000 03BA 
; 0000 03BB // Global enable interrupts
; 0000 03BC #asm("sei")
	sei
; 0000 03BD PORTA.6=0;
	CBI  0x1B,6
; 0000 03BE delay_ms(2000);
	CALL SUBOPT_0x3
; 0000 03BF PORTA.6=1;
	SBI  0x1B,6
; 0000 03C0 delay_ms(20000);
	LDI  R30,LOW(20000)
	LDI  R31,HIGH(20000)
	CALL SUBOPT_0xB
; 0000 03C1 count =0;
	LDI  R30,LOW(0)
	STS  _count,R30
	STS  _count+1,R30
; 0000 03C2 len = 0;
	STS  _len,R30
	STS  _len+1,R30
; 0000 03C3 
; 0000 03C4 init();
	RCALL _init
; 0000 03C5 CLSSMS();
	CALL SUBOPT_0xD
; 0000 03C6 
; 0000 03C7 delay_ms(1000);
; 0000 03C8 
; 0000 03C9 while (1)
_0xCC:
; 0000 03CA       {
; 0000 03CB             PORTC.1=1;
	SBI  0x15,1
; 0000 03CC             if (rx_counter0)
	TST  R8
	BREQ _0xD1
; 0000 03CD 		    {
; 0000 03CE 		        TCCR1A=0x03;
	LDI  R30,LOW(3)
	OUT  0x2F,R30
; 0000 03CF 		        delay_ms(2000);
	CALL SUBOPT_0x3
; 0000 03D0 		        process_data();
	RCALL _process_data
; 0000 03D1 		        TCCR1A=0x83;
	LDI  R30,LOW(131)
	OUT  0x2F,R30
; 0000 03D2 		    }
; 0000 03D3             //if (rx_counter1)
; 0000 03D4             //{
; 0000 03D5             //    process_gps();
; 0000 03D6             //}
; 0000 03D7 
; 0000 03D8 
; 0000 03D9       }
_0xD1:
	RJMP _0xCC
; 0000 03DA }
_0xD2:
	RJMP _0xD2

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
_0x2020003:
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	LD   R30,X+
	STD  Y+1,R26
	STD  Y+1+1,R27
	MOV  R17,R30
	CPI  R30,0
	BREQ _0x2020005
	ST   -Y,R17
	CALL _putchar
	RJMP _0x2020003
_0x2020005:
	LDI  R30,LOW(10)
	ST   -Y,R30
	CALL _putchar
	LDD  R17,Y+0
	ADIW R28,3
	RET

	.CSEG

	.DSEG

	.CSEG

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
	.BYTE 0xC8
_tx_buffer0:
	.BYTE 0xC8
_rx_buffer1:
	.BYTE 0xC8
_rx_rd_index1:
	.BYTE 0x1
_rx_counter1:
	.BYTE 0x1
_tx_buffer1:
	.BYTE 0xC8
_tx_wr_index1:
	.BYTE 0x1
_tx_rd_index1:
	.BYTE 0x1
_tx_counter1:
	.BYTE 0x1
_count:
	.BYTE 0x2
_len:
	.BYTE 0x2
__seed_G102:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 21 TIMES, CODE SIZE REDUCTION:157 WORDS
SUBOPT_0x0:
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x1:
	LDI  R30,LOW(97)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(116)
	ST   -Y,R30
	JMP  _putchar

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x2:
	LDI  R30,LOW(13)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(10)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x3:
	LDI  R30,LOW(2000)
	LDI  R31,HIGH(2000)
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x4:
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x5:
	LDI  R30,LOW(65)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(84)
	ST   -Y,R30
	JMP  _putchar

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x6:
	LDI  R30,LOW(43)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(67)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(77)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(71)
	ST   -Y,R30
	JMP  _putchar

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x7:
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(61)
	ST   -Y,R30
	JMP  _putchar

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x8:
	LDI  R30,LOW(49)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(13)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(10)
	ST   -Y,R30
	JMP  _putchar

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x9:
	MOV  R17,R16
	CALL _getchar
	MOV  R16,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0xA:
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts
	LDI  R30,LOW(20)
	LDI  R31,HIGH(20)
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 10 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0xB:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0xC:
	LDI  R26,LOW(_sms_in_e2prom)
	LDI  R27,HIGH(_sms_in_e2prom)
	CALL __EEPROMRDB
	LDI  R31,0
	STD  Y+10,R30
	STD  Y+10+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xD:
	CALL _CLSSMS
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	RJMP SUBOPT_0xB

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xE:
	MOV  R30,R20
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xF:
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	RJMP SUBOPT_0xB

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x10:
	LDI  R30,LOW(43)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(99)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(109)
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(103)
	ST   -Y,R30
	JMP  _putchar

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x11:
	LDD  R30,Y+9
	LDI  R31,0
	SUBI R30,LOW(-_caller_id)
	SBCI R31,HIGH(-_caller_id)
	RET


	.CSEG
_delay_ms:
	ld   r30,y+
	ld   r31,y+
	adiw r30,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0x7D0
	wdr
	sbiw r30,1
	brne __delay_ms0
__delay_ms1:
	ret

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

;END OF CODE MARKER
__END_OF_CODE:
