/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(divide_fault, T_DIVIDE)
TRAPHANDLER_NOEC(debug_fault, T_DEBUG)
TRAPHANDLER_NOEC(nmi_itr, T_NMI)
TRAPHANDLER_NOEC(breakpoint_trap, T_BRKPT)
TRAPHANDLER_NOEC(overflow_trap, T_OFLOW)
TRAPHANDLER_NOEC(bound_fault, T_BOUND)
TRAPHANDLER_NOEC(invalid_fault, T_ILLOP)
TRAPHANDLER_NOEC(dna_fault, T_DEVICE)
TRAPHANDLER(double_fault_abort, T_DBLFLT)
//TRAPHANDLER_NOEC(cso_abort, 9)
TRAPHANDLER(invalid_tss_fault, T_TSS)
TRAPHANDLER(seg_not_present_fault, T_SEGNP)
TRAPHANDLER(segment_fault, T_STACK)
TRAPHANDLER(general_protection_fault, T_GPFLT)
TRAPHANDLER(page_fault, T_PGFLT)
TRAPHANDLER_NOEC(fpu_fault, T_FPERR)
TRAPHANDLER(align_check_fault, T_ALIGN)
TRAPHANDLER_NOEC(machine_check_abort, T_MCHK)
TRAPHANDLER_NOEC(simd_fp_fault, T_SIMDERR)

/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds;
	pushl %es;
	pushal;
	
	movw $GD_KD, %ax;
	mov %ax, %ds;
	mov %ax, %es;

	pushl %esp;
	call trap;

