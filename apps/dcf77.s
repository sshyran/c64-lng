;   dcf77 - Read German time signal from user port and write it to system clock
;   Copyright (C) 2000 Alexander Bluhm
;
;   This program is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation; either version 2 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program; if not, write to the Free Software
;   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;

; Alexander Bluhm <mam96ehy@studserv.uni-leipzig.de>

; The dcf-77 signal is broadcasting the official German time. 
; It is a serial protocol, sending one bit every second.
; If it is on for 100ms it is interpreted as 0 and with 200ms it is a 1.
; The 59th bit is missing, so you have a 2 seconds gap, marking the begin 
; of a minute. For details see:
; -  http://www.heret.de/funkuhr/index.htm	  (german)
; -  http://www.heret.de/radioclock/index.htm	  (english)
; The radio receiver is connected to one cia2 pin at the user port.
; To read the information this progamm hooks into the system interrupt,
; which occures every 1/64 seconds. It counts the interrupts between
; the changes of the cia port bit. Depending on this duration,
; the bit is recognized as 0 or 1. When the Interrupt handler has
; collected 59 bits, it wakes up the process. The process calculates
; the date and time from these bits and prints some debugging information.
; Then it transfers the date and time back to the interrupt handler.
; The interrupt handler waits for the next valid second
; and then writes the time to the cia1 time of day register. With 
; this procedure a better precision is archieved.

#include <stdio.h>
#include <cia.h>

; select cia port for radio receiver
; User port PB5 is not taken by manufacturer, but this is not used by rs232
; be carefull to connect the radio receiver only to a cia pin which is
; programmed for input. Anything else could destroy the cia or receiver.
; THERE IS NO WARRANTY, YOU HAVE BEEN WARNED
#define B_DCF	$20		; data bit cia2 port B, user port PB5

; show status on screen
#define BLINK_SCREEN
#ifdef BLINK_SCREEN
#  begindef BLINK_INIT
		lda	#"0"
		sta	$0427
		sta	$0426
		sta	$0425
#  enddef
#  begindef BLINK(num,onoff)
		lda	#"0"+(onoff)
		sta	$0427-(num)
#  enddef
#else
#  define BLINK_INIT
#  define BLINK(num,onoff)
#endif

; dcf timings in jiffies
#define TOLL	3		; tollerance, guess a good value
#define SEC	64		; 1 second
#define SET	13		; set bit 200 ms
#define CLEAR	7		; cleared bit 100 ms
#define GAP	128		; 2 seconds gap between second 58 and 0
#define SEC_MIN		(SEC-TOLL)
#define SEC_MAX		(SEC+TOLL)
#define SET_MIN		(SET-TOLL)
#define SET_MAX		(SET+TOLL)
#define CLEAR_MIN	(CLEAR-TOLL)
#define CLEAR_MAX	(CLEAR+TOLL)
#define GAP_MIN		(GAP-TOLL)
#define GAP_MAX		(GAP+TOLL)


start_of_code:
		.byte >LNG_MAGIC, <LNG_MAGIC
		.byte >LNG_VERSION, <LNG_VERSION
		.word 0

		jmp	initialize

;;; irq handler data--------------------------------------------------------

		.byte	$0c
		.word	+

dcfbits:	.byte	$40,0,0,0,0,0,0,0	; 8 bytes == 64 bits
	; byte 0 bit 7 means waiting for gap, 
	;        bit 6 means data invalid
	;        bit 5 means write date to cia next second
	; byte 0 bit 2 ... byte 7 raw dcf data bits
bytecount:	.byte	7
bitcount:	.byte	$01
duration:	.byte	0
sigstate:	.byte	0

dcfdata:	.buf	8

date:
weekday:	.byte	0	; range from 01 to 07
century:	.byte	$20	; FIXME: year 2100 problem :-)
year:		.byte	0	; range form 00 to 99
month:		.byte	1	; range form 01 to 12
day:		.byte	1	; range form 01 to 31
time:
hour:		.byte	0	; range from 00 to 23
minute:		.byte	0	; range from 00 to 59
second:		.byte	0	; range from 00 to 59
sec10:		.byte	$00
end_of_time:
zonehour:	.byte	1	; 1 CET/MEZ, 2 CEST/MESZ
zonemin:	.byte	$00
end_of_date:

rtc_moddesc:
		.asc	"rtc"
		.byte	5
rtc_time_read:	jmp	lkf_suicide
rtc_time_write: jmp	lkf_suicide
rtc_date_read:	jmp	lkf_suicide
rtc_date_write: jmp	lkf_suicide
rtc_raw_write:	jmp	lkf_suicide

	+

;;; irq handler ------------------------------------------------------------

		bit	irq_handler
irq_handler:
		;; increment the jiffie conter
		inc	duration
		bne	+
		; the state has not changed for 256/64 == 4 seconds
		BLINK(1,0)
		dec	duration	; $ff has no valid interpretation
		lda	#$40		; invalid flag
		sta	dcfbits

		;; read signal and compare with previous
	+	lda	CIA2_PRB
		and	#B_DCF
		tax
		eor	sigstate
		beq	return		; nothing has changed, continue waiting

		;; the signal has changed
		txa			; set/clear zero flag
		sta	sigstate
		beq	sig_off

		; note that state of the led and the cia signal are inverted
sig_on:		;; the dcf-77 led was on and is now off
		BLINK(0,0)
		;; check for valid duration of led on
		lda	duration
		cmp	#SET_MAX
		bcs	mark_invalid
		cmp	#CLEAR_MIN
		bcc	mark_invalid
		bit	dcfbits
		bvc	+

		;; the data is invalid, check for correctness of bit before gap
		cmp	#SET_MIN
		bcs	mark_gap
		cmp	#CLEAR_MAX
		bcc	mark_gap
		bcs	mark_invalid	; always jump

		;; check the length of the signal to determine SET or CLEAR
	+	cmp	#SET_MIN
		bcs	set_bit
		cmp	#CLEAR_MAX
		bcc	clear_bit
		bcs	mark_invalid	; always jump

		;; write bit to bitfield
set_bit:	ldy	bytecount
		lda	bitcount
		ora	dcfbits,y
		bne	sta_dcfbits	; allways jump
clear_bit:	ldy	bytecount
		lda	bitcount
		eor	#$ff
		and	dcfbits,y
sta_dcfbits:	sta	dcfbits,y
		lda	bitcount
		asl	a
		bcs	dec_byte
		tax
		and	#$f8
		beq	stx_bit
		cpy	#0
		bne	stx_bit
		;; send dcfbits to application
		ldy	#7
	-	lda	dcfbits,y
		sta	dcfdata,y
		dey
		bpl	-
		lda	#$dc
		ldx	#$77
		jsr	lkf_mun_block	; may this be called from irq handler ?
mark_gap:	lda	#$80		; gap flag
		ora	dcfbits
		sta	dcfbits
		ldy	#8
dec_byte:	dey
		sty	bytecount
		ldx	#$01
stx_bit:	stx	bitcount
return:		rts
		
sig_off:	;; the dcf-77 led was off and is now on
		BLINK(0,1)
		;; check for valid duration of led on+off
		lda	duration
		ldx	#0
		stx	duration
		cmp	#GAP_MAX
		bcc	+

mark_invalid:	BLINK(1,0)
		lda	#$40		; invalid flag
		sta	dcfbits
		rts

	+	cmp	#GAP_MIN
		bcs	+
		cmp	#SEC_MAX
		bcs	mark_invalid
		cmp	#SEC_MIN
		bcc	mark_invalid

		;; one second found
		bit	dcfbits
		bmi	mark_invalid	; gap expected
		bvs	return
		lda	second
		sed
		clc
		adc	#$01
		cld
		cmp	#$59
		bcs	return		; should never happen
		sta	second

write_date:	;; write date and time to system clock
		lda	dcfbits
		and	#$20		; write flag
		beq	return
		lda	dcfbits
		and	#$df		; write flag
		sta	dcfbits
		BLINK(2,1)
		ldx	#<date
hiaddr_date:	ldy	#>date		; will be relocated during init
#ifdef DEBUG
		jsr	rtc_date_write
#else
		jsr	rtc_raw_write
#endif
		rts

		;; gap found
	+	bit	dcfbits
		bpl	mark_invalid	; no gap expected
		BLINK(1,1)
		lda	#$00
		sta	second
		lda	#$3f		; valid, no gap
		and	dcfbits
		bit	dcfbits
		sta	dcfbits
		bvc	write_date+3	; dcfbits allready in A, ignore load
		BLINK(2,0)
		rts


;;; api --------------------------------------------------------------------

		;; dcf_read
		;; block untill dcf data is avalible
		;; < dcfdata contains bits, will stay valid for 1 minute
dcf_read:	lda	#$dc		; what values to choose ?
		ldx	#$77		; perhaps the ipid should be used
		jmp	lkf_suspend
		rts


		;; dcf_write
		;; write date and time at next second
		;; > date, must stay valid for 2 seconds
dcf_write:	sei
		lda	dcfbits
		and	#$40		; invalid flag
		bne	+
		lda	dcfbits
		ora	#$20		; write flag
		sta	dcfbits
	+	cli
		rts


;;; main data --------------------------------------------------------------

		.byte	$0c
		.word	+

byte_count:	.buf	1
bit_count:	.buf	1

flags:		.byte	0	; A2,Z2,Z1,A1,R

#ifdef DEBUG
seperator:	.text	" ",0,".. ::. ",0,$0a 
#endif

	+

;;; main -------------------------------------------------------------------

main:

main_loop:	;; main loop
		jsr	dcf_read

#ifdef DEBUG
		;; write bits to stdout
		ldx	#stdout
		ldy	#7
byte_loop:	sty	byte_count
		lda	#$01
bit_loop:	sta	bit_count

		lda	dcfdata,y
		bit	bit_count
		bne	+
		lda	#"0"
		bne	++		; allways jump
	+	lda	#"1"
	+	sec
		jsr	lkf_fputc
		nop

		lda	bit_count
		asl	a
		bcc	bit_loop
		ldy	byte_count
		cpy	#4
		bne	+
		lda	#$0a		; new line
		sec
		jsr	lkf_fputc
		nop
	+	lda	#" "
		sec
		jsr	lkf_fputc
		nop
		ldy	byte_count
		dey
		bpl	byte_loop
		lda	#$0a		; new line
		sec
		jsr	lkf_fputc
		nop
#endif

		;; interprete data 
		lda	dcfdata+7
		and	#$01		; M must be 0
		bne	_invalid_data

		;; get flags
		lda	dcfdata+6
		asl	a
		lda	dcfdata+5
		tax
		rol	a
		and	#$1f
		sta	flags
		txa
		eor	flags
		and	#$04		; either Z1 or Z2
		beq	_invalid_data

		;; set timezone
		ldy	#$01
		txa
		and	#$02		; Z1
		beq	+
		iny
	+	sty	zonehour

		txa
		and	#$10		; S must be 1
		beq	_invalid_data

		;; get minute
		ldx	#$00
		lda	dcfdata+4
		ldy	#5
		jsr	parity_low
		lda	dcfdata+5
		ldy	#3
		jsr	parity_high
		txa
		and	#$01
		bne	_invalid_data	; even parity
		lda	userzp
		and	#$7f
		sta	minute

		;; get hour
		ldx	#$00
		lda	dcfdata+3
		ldy	#4
		jsr	parity_low
		lda	dcfdata+4
		ldy	#3
		jsr	parity_high
		txa
		and	#$01
		beq	+		; even parity
_invalid_data:	jmp	invalid_data	; relative jump out of range
	+	lda	userzp
		and	#$3f
		sta	hour

		ldx	#$00
		;; get day
		lda	dcfdata+2
		ldy	#2
		jsr	parity_low
		lda	dcfdata+3
		ldy	#4
		jsr	parity_high
		lda	userzp
		and	#$3f
		sta	day

		;; get weekday
		lda	dcfdata+2
		and	#$1f
		ldy	#6
		jsr	parity_high
		lda	userzp
		and	#$07
		sta	weekday

		;; get month
		lda	dcfdata+1
		ldy	#2
		jsr	parity_low
		lda	dcfdata+2
		ldy	#3
		jsr	parity_high
		lda	userzp
		and	#$1f
		sta	month

		;; get year
		lda	dcfdata+0
		ldy	#3
		jsr	parity_low
		lda	dcfdata+1
		ldy	#6
		jsr	parity_high
		lda	userzp
		sta	year

		;; parity for day, weekday, month, year
		txa
		and	#$01
		bne	_invalid_data	; even parity

#ifdef DEBUG
		;; print date and time to stdout
		ldy	#second-date
		sty	userzp
		lda	#0
		jsr	print_date

		ldy	#zonehour-date
		sty	userzp
		pha
		tax
		lda	date,x		; second
		sed	
		clc
		adc	#$01	; date will be written next second
		cld
		cmp	#$59
		bcc	+
		lda	#$00
	+	jsr	print_hex8
		nop
		pla
		jsr	print_seperator

		pha
		bit	zonehour
		bmi	+
		lda	#"+"
		bne	++		; allways jump
	+	lda	#"-"
	+	ldx	#stdout
		sec
		jsr	lkf_fputc
		nop
		pla

		ldy	#end_of_date-date
		sty	userzp
		pha
		tax
		lda	date,x		; zonehour
		and	#$7f
		jsr	print_hex8
		nop
		pla
		jsr	print_seperator
#endif

		;; write date to system clock
valid_data:	jsr	dcf_write
		jmp	main_loop
		
invalid_data:	BLINK(2,0)
		jmp	main_loop


parity_low:	;; copy A to userzp and parity of lower Y bits to X
		sta	userzp
	-	lsr	a
		bcc	+
		inx
	+	dey
		bne	-
		rts

parity_high:	;; shift higher Y bits of A to userzp and parity to X
	-	asl	a
		bcc	+
		inx
	+	rol	userzp
		dey
		bne	-
		rts

#ifdef DEBUG
		;; print date and seperators
print_date:	
		pha
		tax
		lda	date,x
		jsr	print_hex8
		nop
		pla
print_seperator:
		pha
		tax
		lda	seperator,x
		beq	+
		ldx	#stdout
		sec
		jsr	lkf_fputc
		nop
	+	pla
		clc
		adc	#1
		cmp	userzp
		bcc	print_date
		rts
#endif

end_of_permanent_code:
;;; initialisation data ----------------------------------------------------

		.byte	$0c
		.word	+

howto_txt:	.text	"usage: dcf77",$0a,0

	+

;;; initialisation ---------------------------------------------------------
		
initialize:
		;; parse commandline
		ldx	userzp
		cpx	#1
		beq	normal_mode
		
HowTo:		ldx	#stdout
		bit	howto_txt
		jsr	lkf_strout
		lda	#1
		rts
		
normal_mode:
		;; free memory used for commandline arguments
		ldx	userzp+1
		jsr	lkf_free	
		nop

		;; put cia into input mode
		lda	CIA1_DDRB
		and	#~B_DCF
		sta	CIA1_DDRB

		BLINK_INIT

		;; relocate in irq handler
	-	bit	date
		lda	- +2
		sta	hiaddr_date +1

		;; get rtc module
	-	bit	rtc_moddesc
		lda	#1
		ldx	#<rtc_moddesc
		ldy	- +2
		jsr	lkf_get_moduleif
		nop

		;; need userzp in main programm
		lda	#1
		jsr	lkf_set_zpsize
		nop

		;; install irq handler
		ldx	#<irq_handler
		ldy	irq_handler-1	      ; #>irq_handler
		jsr	lkf_hook_irq
		nop

		jmp	main

end_of_code: