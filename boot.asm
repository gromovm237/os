org 0x7c00
bits 16


jmp start


print_string_si:
    push ax
    mov ah, 0x0e
    call print_next_char
    pop ax
    ret
print_next_char:
    mov al, [si]
    cmp al, 0
    jz if_zero
    int 0x10
    inc si
    jmp print_next_char
if_zero:
    ret
    
    
    
compare_strs_si_bx:
    push si
    push bx
    push ax
comp:
    mov ah, [bx]
    cmp [si], ah 
    jne not_equal
    cmp byte [si], 0 
    je first_zero 
    inc si
    inc bx
    jmp comp
first_zero:
    cmp byte [bx], 0   
    jne not_equal  
    mov cx, 1         
    pop si 
    pop bx
    pop ax
    ret   
not_equal:
    mov cx, 0   
    pop si   
    pop bx
    pop ax
    ret    



clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

start:
    mov ax, 0  
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov sp, 0x7C00
    
    call clear_screen 
    mov ah, 0x0e
    mov al, '>'
    int 0x10             
    
    mov si, loading_text 
    call print_string_si
    
    
    mov si, greetings  
    call print_string_si
    
    jmp mainloop         
    


    
mainloop:
    mov si, prompt   
    call print_string_si
    call get_input        
    jmp mainloop       
    
       
get_input:
    mov bx, 0               


input_processing:
    mov ah, 0x0          
    int 0x16             
    cmp al, 0x0d           
    je check_the_input                    
    cmp al, 0x8               ; backspace
    je backspace_pressed
    cmp al, 0x3               ; ctrl+c
    je stop_cpu
    mov ah, 0x0e              
    int 0x10
    mov [input+bx], al       
    inc bx                   
    cmp bx, 64          
    je check_the_input     
    jmp input_processing   
    
    
stop_cpu:
    mov si, goodbye    
    call print_string_si
    jmp $                   

backspace_pressed:
    cmp bx, 0            
    je input_processing  
    mov ah, 0x0e  
    int 0x10       
    mov al, ' ' 
    int 0x10
    mov al, 0x8    
    int 0x10     
    dec bx
    mov byte [input+bx], 0  
    jmp input_processing 
    
check_the_input:
    inc bx
    mov byte [input+bx], 0                       
    mov si, new_line  
    call print_string_si    
    mov si, help_command  
    mov bx, input    
    call compare_strs_si_bx   
    cmp cx, 1                     
    je equal_help                                                          
    jmp equal_to_nothing 
    
equal_help:
    mov si, help_desc
    call print_string_si
    jmp done
    
    

    
equal_to_nothing:
    mov si, wrong_command
    call print_string_si
    jmp done


done:
    cmp bx, 0
    je exit
    dec bx
    mov byte [input+bx], 0
    jmp done

exit:
    ret
    
loading_text: db "Loading...", 0x0d, 0xa, 0
wrong_command: db "Wrong command!", 0x0d, 0xa, 0
greetings: db "The OS is on. Type 'help' for commands", 0x0d, 0xa, 0xa, 0
help_desc: db "help: the only one command that works now", 0x0d, 0xa, 0
goodbye: db 0x0d, 0xa, "Goodbye!", 0x0d, 0xa, 0
prompt: db ">", 0
new_line: db 0x0d, 0xa, 0
help_command: db "help", 0
gui_command: db "gui", 0


input: times 64 db 0      


times 510 - ($-$$) db 0
dw 0xaa55
