;// *** DO NOT EDIT THIS FILE ***
;// -rw-r--r--   1 poldi    users        1976 Okt 22 14:31 jumptab.s
#ifndef _JUMPTAB_H
#define _JUMPTAB_H
#include <system.h>
		.byte <lkf_set_zpsize
		.byte <lkf_get_moduleif
		.byte <lkf_fopen
		.byte <lkf_fopendir
		.byte <lkf_fclose
		.byte <lkf_fgetc
		.byte <lkf_fputc
		.byte <lkf_fcmd
		.byte <lkf_freaddir
		.byte <lkf_fgetdevice
		.byte <lkf_strout
		.byte <lkf_popen
		.byte <lkf_ufd_open
		.byte <lkf_fdup
		.byte <lkf_print_error
		.byte <lkf_suicerrout
		.byte <lkf_suicide
		.byte <lkf_palloc
		.byte <lkf_free
		.byte <lkf_force_taskswitch
		.byte <lkf_forkto
		.byte <lkf_getipid
		.byte <lkf_signal
		.byte <lkf_sendsignal
		.byte <lkf_wait
		.byte <lkf_sleep
		.byte <lkf_lock
		.byte <lkf_unlock
		.byte <lkf_suspend
		.byte <lkf_hook_alert
		.byte <lkf_hook_irq
		.byte <lkf_hook_nmi
		.byte <lkf_panic
		.byte <lkf_locktsw
		.byte <lkf_unlocktsw
		.byte <lkf_add_module
		.byte <lkf_fix_module
		.byte <lkf_mpalloc
		.byte <lkf_spalloc
		.byte <lkf_pfree
		.byte <lkf_mun_block
		.byte <lkf_catcherr
		.byte <lkf_printk
		.byte <lkf_hexout
		.byte <lkf_disable_nmi
		.byte <lkf_enable_nmi
		.byte <lkf_get_bitadr
		.byte <lkf_addtask
		.byte <lkf_get_smbptr
		.byte <lkf_smb_alloc
		.byte <lkf_smb_free
		.byte <lkf_alloc_pfd
		.byte <lkf_io_return
		.byte <lkf_io_return_error
		.byte <lkf_ref_increment
		.byte <lkf_p_insert
		.byte <lkf_p_remove
		.byte <lkf__raw_alloc
		.byte <lkf_exe_reloc
		.byte <lkf_exe_test
		.byte <lkf_init
		.byte <lkf_keyb_joy0
		.byte <lkf_keyb_joy1
		.byte <lkf_keyb_scan
		.byte <lkf_keyb_stat
#endif
