%include "macros.inc"

section .bss
	name: resb 32
	input: resb 64
	temp: resb 1
	riverside: resb 1
	chicken: resb 1
	fox: resb 1
	seeds: resb 1

section .text
	global _start

putc:
	push rbp
	mov rbp, rsp
	mov rsi, rbp
	add rsi, 16
	mov rax, WRITE
	mov rdi, STDOUT
	mov rdx, 1
	syscall
	mov rsp, rbp
	pop rbp
	ret

puts:
	push rbp
	mov rbp, rsp
	mov rsi, [rbp+16]
	puts_loop:
		cmp BYTE [rsi], 0
		je puts_return
 		mov rax, WRITE
		mov rdi, STDOUT
		mov rdx, 1
		syscall
		inc rsi
  		jmp puts_loop
	puts_return:
		mov rsp, rbp
		pop rbp
		ret

print_num:
	push rbp
	mov rbp, rsp
	mov rax, [rbp+16]
	push WORD 0x0
	mov rbx, 10
	print_num_push_loop:
		mov dx, 0
		div rbx
		add dx, 48
		push dx
		cmp rax, 0
		jne print_num_push_loop
	print_num_pop_loop:
		pop ax
		cmp ax, 0x0
		je print_num_return
		mov rsi, rsp
		sub rsi, 2
		mov rax, WRITE
		mov rdi, STDOUT
		mov rdx, 1
		syscall
		jmp print_num_pop_loop
	print_num_return:
		mov rsp, rbp
		pop rbp
		ret

getc:
	push WORD 0
	mov rax, READ
	mov rdi, STDIN
	mov rsi, rsp
	mov rdx, 1
	syscall
	mov ax, [rsp]
	add rsp, 2
	ret

gets:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rsi, [rbp+24]
	mov rdi, STDIN
	mov rdx, 1
	gets_loop:
 		cmp rbx, 0
		je gets_return
		dec rbx
		mov rax, READ
		syscall
		cmp BYTE [rsi], 10
		je gets_return
		inc rsi
		jmp gets_loop
	gets_return:
		mov BYTE [rsi], 0
		mov rsp, rbp
		pop rbp
		ret

_start:
	push msg_welcome
	call puts
	add rsp, 8

	push name
	push 32
	call gets
 	add rsp, 16

	push msg_greeting
	call puts
	add rsp, 8

	push name
	call puts
	add rsp, 8

	push 10
	call putc
	add rsp, 8

	push msg_description
	call puts
	add rsp, 8

	restart:
		push msg_current_state
		call puts
		add rsp, 8

		push name
		call puts
		add rsp, 8

		push msg_colon_space
		call puts
		add rsp, 8

 		mov bl, BYTE [riverside]
		and rbx, 0x1
		push QWORD [compass_array+(rbx*8)]
		call puts
		add rsp, 8

		push msg_seeds
		call puts
		add rsp, 8

 		mov bl, BYTE [seeds]
		and rbx, 0x1
		push QWORD [compass_array+(rbx*8)]
		call puts
		add rsp, 8

		push msg_chicken
		call puts
		add rsp, 8

 		mov bl, BYTE [chicken]
		and rbx, 0x1
		push QWORD [compass_array+(rbx*8)]
		call puts
		add rsp, 8

		push msg_fox
		call puts
		add rsp, 8

 		mov bl, BYTE [fox]
		and rbx, 0x1
		push QWORD [compass_array+(rbx*8)]
		call puts
		add rsp, 8

		push 10
		call putc
		add rsp, 8

		push msg_options
		call puts
		add rsp, 8
	
		push input
		push 64
		call gets
		add rsp, 16
	
		cmp BYTE [input], '1'
		jne not_one
		mov al, [chicken]
		cmp al, BYTE [riverside]
		jne invalid_action
		not BYTE [chicken]
		not BYTE [riverside]
		jmp check
	not_one:
		cmp BYTE [input], '2'
		jne not_two
		mov al, [fox]
		cmp al, BYTE [riverside]
		jne invalid_action
		not BYTE [fox]
		not BYTE [riverside]
		jmp check
	not_two:
		cmp BYTE [input], '3'
		jne not_three
		mov al, [seeds]
		cmp al, BYTE [riverside]
		jne invalid_action
		not BYTE [seeds]
		not BYTE [riverside]
		jmp check
	not_three:
		cmp BYTE [input], '4'
		jne you_cannot
		not BYTE [riverside]
		jmp check
	you_cannot:
		push msg_you_cannot
		call puts
		add rsp, 8
		push input
		call puts
		add rsp, 8
		push msg_quote_newline
		call puts
		add rsp, 8
	invalid_action:
		push msg_invalid_action
		call puts
		add rsp, 8
		jmp restart
	check:
		mov al, [chicken]
		xor al, [fox]
		mov [temp], al
		not BYTE [temp]
		mov al, [fox]
		xor al, [riverside]
		and al, [temp]
		cmp al, 0
		jne lose
		mov al, [seeds]
		xor al, [chicken]
		mov [temp], al
		not BYTE [temp]
		mov al, [chicken]
		xor al, [riverside]
		and al, [temp]
		cmp al, 0
		jne lose
		mov al, [chicken]
		and al, [fox]
		and al, [seeds]
		and al, [riverside]
		cmp al, 0
		jne win
		jmp restart
	
	lose:
		push name
		call puts
		add rsp, 8
		push msg_lose
		call puts
		add rsp, 8
		jmp exit

	win:
		push name
		call puts
		add rsp, 8
		push msg_win
		call puts
		add rsp, 8
		jmp exit

	exit:
 		mov rax, EXIT
  		mov rdi, 0
   		syscall

section .rodata
	msg_welcome: db "Welcome to a text adventure", 10, "What's your name?: ", 0
	msg_greeting: db "Greetings, ", 0
	msg_description: db "You are on a riverside. You have a boat, a chicken, a fox and a bag of seeds", 10, "Your goal is to bring all three objects over to the north side of the river without any getting eaten.", 10, "Your are currently on the south side of the river", 10, 0
	msg_options: db "Here are your options:", 10, 9, "1) Bring the chicken over", 10, 9, "2) Bring the fox over", 10, 9, "3) Bring the bag of seeds over", 10, 9, "4) Bring nothing over", 10, "What would you like to do?: ", 0
	msg_lose: db ", YOU LOSE!", 10, 0
	msg_win: db ", YOU WIN!", 10, 0
	msg_invalid_action: db "Invalid Action!", 10, 0
	msg_you_cannot: db "You cannot ", 34, 0
	msg_quote_newline: db 34, 10, 0
	msg_current_state: db "Current State:", 10, 0
	south: db "South", 0
	north: db "North", 0
	compass_array: dq south, north
	msg_colon_space: db ": ", 0
	msg_seeds: db ", Seeds: ", 0
	msg_chicken: db ", Chicken: ", 0
	msg_fox: db ", Fox: ", 0