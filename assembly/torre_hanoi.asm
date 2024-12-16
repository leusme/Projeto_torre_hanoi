section .data
    pergunta db 'Digite a quantidade de discos desejada: ', 0
    start_msg db "Algoritmo da Torre de Hanoi com ", 0
    start_msg_len equ $ - start_msg
    discos_msg db "discos ", 0     ; Aqui está a string " discos"
    discos_msg_len equ $ - discos_msg
    quebra_de_linha db 10 ; Quebra de linha
    movimento1 db 'Mova o disco ', 0
    movimento3 db ' da Torre ', 0
    movimento2 db ' até a Torre ', 0
    concluido db 'Concluído! ', 0
    entrada_invalida db 'Digite entrada entre 1-99 ', 0
    torre_origem db 'A', 0
    torre_auxiliar db 'B', 0
    torre_destino db 'C', 0


section .bss
    quant_disc resb 1 ; Contagem de discos
    entrada resb 3  ; Buffer para a entrada
    len_buffer resb 2 ; Tamanho da string

section .text ;_start é o ponto inicial onde o sistema operacional começa a executar o programa.
    global _start

_start:
    start: ; Inicia a solicitação da entrada
    mov ecx, pergunta
    call printar_ecx_0 ; Exibe a pergunta
    
    mov ecx, entrada 
    call ler_entrada; Lê 2 bytes da entradas
    
    call avaliar_entrada ; Valida a entrada

    mov ecx, start_msg
    call printar_ecx_0 ; printar entrada  

    mov ecx, entrada
    call printar_ecx_0 ; printar entrada    

    mov ecx, discos_msg
    call printar_ecx_0 ; printar entrada  

    ; Adicionar uma quebra de linha após exibir tudo
    mov ecx, quebra_de_linha
    call printar_ecx               ; Exibe a quebra de linha

    call converter_string_int ; Converte a entrada para inteiro
    mov [quant_disc], edx ; Armazena o valor

    call torre_de_hanoi ; Chama a função da Torre de Hanoi
    
    mov ecx, concluido
    call printar_ecx_0 ; Exibe "Concluído!"
    
    ; Finaliza o programa
    mov eax, 1
    xor ebx, ebx
    int 0x80
    
torre_de_hanoi: ; Algoritmo da Torre de Hanoi
    cmp byte [quant_disc], 1
    je disco_unico ; Caso tenha 1 disco
    jmp mais_discos ; Caso tenha mais discos
    
    disco_unico: ; Caso tenha 1 disco
        mov ecx, movimento1
        call printar_ecx_0 ; Exibe "Mova o disco"
        
        call printar_n_discos ; Exibe o número do disco
        mov ecx, movimento3
        call printar_ecx_0 ; Exibe "da Torre"
        
        mov ecx, torre_origem
        call printar_ecx_0 ; Exibe origem
        
        mov ecx, movimento2
        call printar_ecx_0 ; Exibe "até a Torre"
        
        mov ecx, torre_destino
        call printar_ecx_0 ; Exibe destino
        
        mov ecx, quebra_de_linha
        call printar_ecx ; Quebra de linha
        
        jmp fim ; Finaliza
        
    mais_discos: ; Caso tenha mais discos
        dec byte [quant_disc]
        push word [quant_disc] ; Empilha valores
        push word [torre_origem]
        push word [torre_auxiliar]
        push word [torre_destino]
        
        ; Troca as Torres de origem e destino
        mov dx, [torre_auxiliar]
        mov cx, [torre_destino]
        mov [torre_destino], dx
        mov [torre_auxiliar], cx
        
        call torre_de_hanoi ; Recursão
        
        ; Restaura as Torres e imprime movimento
        pop word [torre_destino]
        pop word [torre_auxiliar]
        pop word [torre_origem]
        pop word [quant_disc]
        
        mov ecx, movimento1
        call printar_ecx_0
        inc byte [quant_disc] ; Aumenta para exibir o disco correto
        call printar_n_discos
        dec byte [quant_disc] ; Restaura valor original
        
        mov ecx, movimento3
        call printar_ecx_0
        mov ecx, torre_origem
        call printar_ecx_0
        mov ecx, movimento2
        call printar_ecx_0
        mov ecx, torre_destino
        call printar_ecx_0
        mov ecx, quebra_de_linha
        call printar_ecx
        
        ; Troca novamente as Torre
        mov dx, [torre_auxiliar]
        mov cx, [torre_origem]
        mov [torre_origem], dx
        mov [torre_auxiliar], cx
        call torre_de_hanoi ; Recursão
    
    fim: ; Final da função
        ret

converter_string_int: ; Converte string para inteiro
    mov edx, entrada[0] 
    sub edx, '0' 
    mov eax, entrada[1]
    
    cmp eax, 0x0a
    je um_num
    sub eax, '0'
    imul edx, 10
    add edx, eax
    
    um_num:
    ret

printar_ecx: ; Imprime a string
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80
    ret

printar_ecx_0: ; Imprime string até 0
    printar_loop:
        mov al, ecx[0]
        cmp al, 0
        je printar_exit
        call printar_ecx
        inc ecx
        jmp printar_loop
    printar_exit:
        ret
        
ler_entrada: ; Lê entrada do usuário
    mov eax, 3
    mov ebx, 0
    mov edx, 2
    int 0x80
    ret
    
avaliar_entrada: ; Verifica se a entrada é válida
    mov cl, entrada[2]
    cmp cl, 0x0a   ;ver se é newline, vazio
    jle quantidade_caracteres_valida
    jmp invalido
    
    quantidade_caracteres_valida:
    mov al, entrada[0] 
    cmp al, 0x31 ;comparar com 1 para ver se é menor que 31 (somente 0)
    jl invalido
    cmp al, 0x39 ; comparar com 9 para ver se é maior que 39 (maior que 9)
    jg invalido
    
    mov dl, entrada[1]
    cmp dl, 0x0a ; ver se é newline
    je validar
    
    cmp dl, 0x30 ;comparar com 0 para ver se é número (somente 0)
    jl invalido
    cmp dl, 0x39 ;comparar com 9 para ver se é maior que 39
    jg invalido
    
    validar:
    jmp valido
    
    invalido:
        mov ecx, entrada_invalida
        call printar_ecx_0
        mov ecx, quebra_de_linha
        call printar_ecx
        jmp start
        
    valido:
        ret

converter_int_string: ; Converte inteiro para string
    dec edi ; Decrementa o conteúdo do registrador EDI
    xor edx, edx ; zerando o registrador EDX
    mov ecx, 10 ;  Move o valor 10 para ecx
    div ecx ; divide edx e eax por 10. O quociente é armazenado em EAX, e o resto em EDX.
    add dl, '0' ; converte o dígito numérico para ASCII
    mov [edi], dl ; Armazena o caractere convertido no endereço de memória apontado por EDI
    test eax, eax ; Testa se o valor em EAX (quociente da divisão) é zero
    jnz converter_int_string ; Se não for zero, pula para a próxima iteração
    ret ; Retorno
printar_n_discos: ; Exibe a quantidade de discos
    movzx eax, byte [quant_disc] ; Move o valor da variável quant_disc para o registrador eax
    lea edi, [len_buffer + 2] ; Carrega o endereço de memória apontado por EDI, usando um offset de 2
    call converter_int_string
    mov eax, 4 ; Número da chamada de sistema para imprimir
    mov ebx, 1 ; Descritor de arquivo (stdout)
    lea ecx, [edi] ; ECX aponta para o endereço de memória apontado por EDI (Carrega o endereço da string convertida em ECX) 
    lea edx, [len_buffer + 2] ; Carrega o endereço de um buffer no registrador EDX
    sub edx, ecx ; Calcula o comprimento da string subtraindo os endereços
    int 0x80 ; Chamar interrupção do sistema
    ret
