/*
 * hello.S : Hello world for tt07_serv
 *
 * SPDX-FileCopyrightText: 2024 Olof Kindgren <olof@award-winning.me>
 * SPDX-License-Identifier: Apache-2.0
 */

/*
*
* Continuously read a string from memory and transmit each character (bitbang)
* like a UART over GPIO
*
*/
#define GPIO_ADDR 0x40000000

	/*
	x1 = GPIO address
	x2 = String address
	x3 = Character to write
	*/

.globl _start
_start:
	/* Load gpio address to x1 */
	li	x1, GPIO_ADDR

	/* Set GPIO high initially */
	addi	x3, zero, 1
	sb	x3, 0(x1)

loop:
	/* Load string address to x2 */
	la	x2, str

next_char:
	/* Read char from string */
	lbu	x3, 0(x2)

	/* If zero, we reached end of string and will reload first character */
	beqz	x3, loop

	/* Bitbanged UART loop */
	ori	x3, x3, 0x100
	slli	x3, x3, 1
1:	sb	x3, 0(x1)
	srli	x3, x3, 1

	/*
	 * Adding delay nops to achieve an approximate
	 * baud rate of 115200 at 100MHz
	*/
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bnez	x3, 1b

	/* Increase address to next char in string */
	addi	x2, x2, 1

	j	next_char

str:
	.section .data
	.string "SERV+Tinytapeout rocks!\n"
