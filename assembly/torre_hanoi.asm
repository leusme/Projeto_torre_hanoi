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
    quant_disc resb 1 ; Contagem de discos 1 byte -> 1-99
    entrada resb 3  ; Buffer para a entrada 1/2 digitos/ newline
    len_buffer resb 2 ; Tamanho da string -> maior 2 bytes

section .text ;_start é o ponto inicial onde o sistema operacional começa a executar o programa.
    global _start

_start:
    start: ; Inicia a solicitação da entrada (usado para retornar caso não passe nas validações)
    mov ecx, pergunta 
    call printar_ecx_0 ; Exibe a pergunta, função de print/write
    
    mov ecx, entrada 
    call ler_entrada; Lê 2 bytes da entrada do usuário
    
    call avaliar_entrada ; função para validar a entrada

    mov ecx, start_msg
    call printar_ecx_0 ; printar mensagem de start -> "Algoritmo da torre de hanói... " 

    mov ecx, entrada
    call printar_ecx_0 ; printar entrada do usuário    

    mov ecx, discos_msg
    call printar_ecx_0 ; printar "discos"

    ; Adicionar uma quebra de linha após exibir tudo
    mov ecx, quebra_de_linha
    call printar_ecx               ; Exibe a quebra de linha

    call converter_string_int ; Converte a entrada para inteiro
    mov [quant_disc], edx ; Armazena o valor da quantidade de discos

    call torre_de_hanoi ; Chama a função da Torre de Hanoi
    
    mov ecx, concluido
    call printar_ecx_0 ; Exibe "Concluído!"
    
    ; Finaliza o programa
    mov eax, 1 ; 1 no eax -> valor para exit 
    xor ebx, ebx ; -> zera o ebx -> ebx 0 -> valor para código de saída/concluído sem erros
    int 0x80 ; -> instrução de interrupção com eax 1 e ebx 0 -> fim do programa
    
torre_de_hanoi: ; Algoritmo da Torre de Hanoi
    cmp byte [quant_disc], 1  ; compara a quantidade de discos com 1
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
        dec byte [quant_disc] ; decrecimento na quantidade de discos
        push word [quant_disc] ; coloca o valor da quantidade atual de discos na pilha
        push word [torre_origem] ; coloca o valor da torre origem na pilha
        push word [torre_auxiliar] ; coloca o valor da torre auxiliar na pilha
        push word [torre_destino] ; coloca o valor da torre destino na pilha
        
        ; Troca as Torres de origem e destino
        mov dx, [torre_auxiliar] 
        mov cx, [torre_destino]
        mov [torre_destino], dx
        mov [torre_auxiliar], cx
        
        call torre_de_hanoi ; Recursão
        
        ; Restaura as Torres e imprime movimento
        pop word [torre_destino] ; organiza o valor da torre destino
        pop word [torre_auxiliar] ; organiza o valor da torre auxiliar
        pop word [torre_origem] ; organiza o valor da torre origem
        pop word [quant_disc] ; modifica a pilha para 
        
        mov ecx, movimento1
        call printar_ecx_0

        inc byte [quant_disc] ; Aumenta para exibir o disco correto sem influência do decréssimo anterior
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
    mov edx, entrada[0] ;primeiro digito
    sub edx, '0'  ; subtrair do valor de 0 em ascii
    mov eax, entrada[1] ;segundo digito
    
    cmp eax, 0x0a ; ver se é nulo
    je um_num
    sub eax, '0' ; transformar em inteiro -> número
    imul edx, 10 ; multiplicar dezena por 10
    add edx, eax ;somar dezena e unidade
    
    um_num:
    ret

printar_ecx: ; Imprime a string
    mov eax, 4 ;chamada p imprimir
    mov ebx, 1 ;desc
    mov edx, 1 ;tamanho
    int 0x80 ;interromper sistema
    ret

printar_ecx_0: ; Imprime string até 0
    printar_loop:
        mov al, ecx[0] ;carregar caracter
        cmp al, 0 ; verificar se é o final da string
        je printar_exit ; se sim, termina a func
        call printar_ecx
        inc ecx ; mover p prox caracter
        jmp printar_loop ; repetir loop
    printar_exit: ;sair do loop
        ret
        
ler_entrada: ; Lê entrada do usuário
    mov eax, 3 ; leitura do sist
    mov ebx, 0 ; descrever tipo do arquivo -> entrada padrao(0)
    mov edx, 2 ; tamanho max entrada
    int 0x80 ; finalizar
    ret
    
avaliar_entrada: ; Verifica se a entrada é válida
    mov cl, entrada[2] ; analisar 3 dígito
    cmp cl, 0x0a   ;ver se é newline, vazio
    jle quantidade_caracteres_valida ; se sim
    jmp invalido ; se não -> invalido
    
    quantidade_caracteres_valida:
    mov al, entrada[0] 
    cmp al, 0x31 ;comparar com 1 para ver se é menor que 31 (somente 0)
    jl invalido
    cmp al, 0x39 ; comparar com 9 para ver se é maior que 39 (maior que 9)
    jg invalido
    
    mov dl, entrada[1] ; analisar 2 dígito
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
        call printar_ecx_0  ;mostrar erro entrada invalida
        mov ecx, quebra_de_linha
        call printar_ecx ; quebra linha 
        jmp start
        
    valido:
        ret

converter_int_string: ; Converte inteiro para string (ASCII)
    dec edi ; Reduz o valor no registrador EDI em 1, movendo o "ponteiro" para o próximo espaço no buffer de memória onde será armazenado o próximo caractere.
    xor edx, edx ; zerando o registrador EDX -> evitar restos indesejáveis
    mov ecx, 10 ;  Define o divisor como 10 para dividir o número decimal e extrair os dígitos (em base 10)
    div ecx ; divide edx e eax por 10. O quociente é armazenado em EAX, e o resto em EDX.
    add dl, '0' ; Converte o número do resto (DL) para o correspondente caractere ASCII.
    mov [edi], dl ; Armazena o caractere convertido no endereço de memória apontado por EDI
    test eax, eax ; Testa se o valor em EAX (quociente da divisão) é zero -> se for não precisa fazer novamente
    jnz converter_int_string ; Se não for zero, pula para a próxima iteração -> refaz p próx digito
    ret ; Retorno

printar_n_discos: ; Exibe a quantidade de discos
    movzx eax, byte [quant_disc] ; Move o valor da variável quant_disc para o registrador eax
    lea edi, [len_buffer + 2] ; Carrega em EDI o endereço onde a string convertida será armazenada, ajustando com um deslocamento de 2
    call converter_int_string
    mov eax, 4 ; Número da chamada de sistema para write.
    mov ebx, 1 ; Descritor de arquivo (stdout, saída padrão (1))
    lea ecx, [edi] ; ECX aponta para o endereço de memória apontado por EDI (Carrega o endereço da string convertida em ECX) 
    lea edx, [len_buffer + 2] ; Carrega o endereço de um buffer no registrador EDX -> LEA(Apenas calcula o endereço de memória e carrega o endereço resultante no registrador.) MOV(Acessa a memória e carrega o conteúdo de um endereço no registrador.)
    sub edx, ecx ; Calcula o comprimento da string subtraindo os endereços -> A operação edx - ecx calcula o comprimento da string, pois a diferença entre o início e o final indica quantos bytes estão ocupados pela string no buffer.
    int 0x80 ; Chamar interrupção do sistema
    ret
