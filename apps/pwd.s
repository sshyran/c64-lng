		;; for emacs: -*- MODE: asm; tab-width: 4; -*-
		;; pwd - prints working directory (=drive)
		;; 2/1/2002 Groepaz/Hitmen

#include <system.h>
#include <stdio.h>
#include <kerrors.h>
#include <cstyle.h>
#include <ident.h>

		start_of_code equ $1000

		.org start_of_code

		.byte >LNG_MAGIC,   <LNG_MAGIC
		.byte >LNG_VERSION,	<LNG_VERSION
		.byte >(end_of_code-start_of_code+255)
		.byte >start_of_code

		;; (task is entered here)

		jsr  parse_commandline

		ldx  userzp+1			; address of commandline (hi byte)
		jsr  lkf_free			; free used memory
								; (commandline not needed any more)

		jmp  main_code


		;; print howto message and terminate with error (code 1)

howto:	ldx  #stdout
		bit  txt_howto
		jsr  lkf_strout
		exit(1)					; (exit() is a macro defined in
								;  include/cstyle.h)

		;; commandline
		;;  first argument is the command name itself
		;;  so userzp (argc = argument count) is at least 1
		;;  userzp+1 holds the hi-byte of the argument strings address

		;; format of the argument string:
		;;  "<command-name>",0,"<argument1>",0,...,"<last argument>",0 ,0

parse_commandline:
		;; check for correct number of arguments
		lda  userzp				; (number of given arguments)
		cmp  #1					; need no argument
		bne  howto				; (if argc != 1 goto howto)

		rts

		;; main programm code
main_code:
		set_zeropage_size(8)	; tell the system how many zeropage
								; bytes we need
								; (set_zeropage_size() is a macro defined
								; in include/cstyle.h)
		;;... code here

		;; now this might be dangerous hack
		;; we will take parent process environment page as our own
;;		lda  #4+4
;;		jsr  lkf_set_zpsize

		ldy  #tsp_ippid
		lda  (lk_tsp),y
		tay
		lda  lk_ttsp,y
		sta  userzp+3
		lda  #0
		sta  userzp+2
		ldy  #tsp_envpage
		lda  (userzp+2),y
		sta  (lk_tsp),y


		bit  txt_pwd
        ldy  *-1 ; #>txt_pwd
   		lda  #<txt_pwd

		jsr  lkf_getenv
		beq  varempty
		sta  varvalue+1
		sty  varvalue+2

		ldx  #stdout
varvalue:	bit  txt_howto
		jsr  lkf_strout

varempty:

;		ldx  #stdout
;		lda #"/"
;  		jsr	lkf_fputc
		ldx  #stdout
		lda #"\n"
   		jsr	lkf_fputc

		lda  #0					; (error code, 0 for "no error")
		rts						; return with no error
		;; or just
		;; exit(0)

		RELO_END ; no more code to relocate

		ident(pwd,0.0)

		;; help text to print on error

txt_howto:
		.text "Usage: pwd",$0a
		.text "  prints working directory (drive)",$0a,0
txt_pwd:
		.text "PWD",0

end_of_code:
