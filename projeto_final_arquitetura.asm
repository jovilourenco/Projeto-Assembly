; Eliane Santos Silva 20220155152
; João Victor Lourenço da Silva 20220005997

section .data
    caminho_de_entrada db 100    ; Reserva espaço para o nome do arquivo de entrada
    caminho_de_saida db 100   ; Reserva espaço para o nome do arquivo de saída
    mensagem_entrada db "Digite o nome do arquivo BMP de entrada: ", 0
    comprimento_mensagem_entrada equ $ - mensagem_entrada
    coordenadaX db "Digite a coordenada X: ", 0
    tamanho_coordenadaX equ $ - coordenadaX
    coordenadaY db "Digite a coordenada Y: ", 0
    tamanho_coordenadaY equ $ - coordenadaY
    largura db "Digite a largura: ", 0
    tamanho_largura equ $ - largura
    altura db "Digite a altura: ", 0
    tamanho_altura equ $ - altura
    mensagem_saida db "Digite o nome do arquivo BMP de saída: ", 0
    comprimento_mensagem_saida equ $ - mensagem_saida
    array_saida db 6480 dup(0)
    largura_lida dd 0
    altura_lida dd 0
    formato db "%d", 0H  

section .bss
    header resb 54
    valorCoordenadaX resd 1
    valorCoordenadaY resd 1
    valorLargura resd 1
    valorAltura resd 1
    contador1 resd 1
    contador2 resd 1
    arqEntrada resd 1
    arqSaida resd 1

section .text
global main

extern scanf

; Função que recebe o endereço da linha (array_saida), coordenada x inicial e largura da censura
censura_linha:
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8]  ; Endereço da linha de pixels
    mov edi, [ebp + 12] ; Coordenada X inicial
    mov ecx, [ebp + 16] ; Largura da censura

    mov ebx, ecx
    add ebx, edi

    mov DWORD [contador2], 0

censura_loop:
    ; Pula para o incrementa se o contador dos pixels for menor que a coordenada X inicial
    cmp dword [contador2], edi
    jl incrementa

    ; Pula para o censura se o contador dos pixels for menor que a Coordenada X + largura
    ; Essa parte faz com que a censura só seja feita até Coordenada X + largura - 1 
    cmp DWORD [contador2], ebx  
    jl censura

    ; Pula para o finaliza_censura se o contador dos pixels for maior ou igual que a Coordenada X + largura
    cmp DWORD [contador2], ebx
    jge finaliza_censura

; Responsável pela censura dos pixels
censura:
    mov byte [esi], 0  ; Azul (B)
    mov byte [esi + 1], 0  ; Verde (G)
    mov byte [esi + 2], 0  ; Vermelho (R)

    add esi, 3
    add DWORD [contador2], 1
    jmp censura_loop

incrementa:
    add esi, 3
    add DWORD [contador2], 1
    jmp censura_loop

; Finaliza a censura da linha atual
finaliza_censura:
    mov esp, ebp
    pop ebp
    ret 


main:
    mov eax, 4           
    mov ebx, 1           
    mov ecx, mensagem_entrada
    mov edx, comprimento_mensagem_entrada
    int 80h

    mov eax, 3           
    mov ebx, 0           
    mov ecx, caminho_de_entrada  
    mov edx, 100         ; Tamanho máximo do nome do arquivo de entrada
    int 80h

    mov edi, 0
    remove_nova_linha:
        mov al, byte [caminho_de_entrada + edi]
        cmp al, 0xA
        je encontra_nova_linha
        inc edi
        jmp remove_nova_linha
    encontra_nova_linha:
        mov byte [caminho_de_entrada + edi], 0

    mov eax, 5          
    mov ebx, caminho_de_entrada  
    mov ecx, 0          
    int 80h

    mov [arqEntrada], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, coordenadaX
    mov edx, tamanho_coordenadaX
    int 80h

    ; Usando scanf para ler coordenada X
    push dword valorCoordenadaX
    push dword formato
    call scanf
    add esp, 8  

    mov eax, 4
    mov ebx, 1
    mov ecx, coordenadaY
    mov edx, tamanho_coordenadaY
    int 80h

    ; Usando scanf para ler coordenada Y
    push dword valorCoordenadaY
    push dword formato
    call scanf
    add esp, 8 

    mov eax, 4
    mov ebx, 1
    mov ecx, largura
    mov edx, tamanho_largura
    int 80h

    ; Usando scanf para ler largura
    push dword valorLargura
    push dword formato
    call scanf
    add esp, 8  

    mov eax, 4
    mov ebx, 1
    mov ecx, altura
    mov edx, tamanho_altura
    int 80h

    ; Usando scanf para ler altura
    push dword valorAltura
    push dword formato
    call scanf
    add esp, 8  

    mov eax, 4
    mov ebx, 1
    mov ecx, mensagem_saida
    mov edx, comprimento_mensagem_saida
    int 80h

    mov eax, 3
    mov ebx, 0
    mov ecx, caminho_de_saida
    mov edx, 100        ; Tamanho máximo do nome do arquivo de saída
    int 80h

    mov edi, 0
    remove_nova_linha_saida:
        mov al, byte [caminho_de_saida + edi]
        cmp al, 0xA
        je encontra_nova_linha_saida
        inc edi
        jmp remove_nova_linha_saida
    encontra_nova_linha_saida:
        mov byte [caminho_de_saida + edi], 0

    mov eax, 8
    mov ebx, caminho_de_saida
    mov ecx, 0o777
    int 80h

    mov [arqSaida], eax

    mov eax, 3
    mov ebx, [arqEntrada]
    mov ecx, header
    mov edx, 18
    int 80h

    mov eax, 4
    mov ebx, [arqSaida]
    mov ecx, header
    mov edx, 18
    int 80h

    mov eax, 3
    mov ebx, [arqEntrada]
    mov ecx, largura_lida
    mov edx, 4
    int 80h

    mov eax, 4
    mov ebx, [arqSaida]
    mov ecx, largura_lida
    mov edx, 4
    int 80h
 
    mov eax, 3
    mov ebx, [arqEntrada]
    mov ecx, altura_lida
    mov edx, 4
    int 80h

    mov eax, 4
    mov ebx, [arqSaida]
    mov ecx, altura_lida
    mov edx, 4
    int 80h

    mov eax, 3
    mov ebx, [arqEntrada]
    mov ecx, header
    mov edx, 28
    int 80h

    mov eax, 4
    mov ebx, [arqSaida]
    mov ecx, header
    mov edx, 28
    int 80h

    mov DWORD [contador1], 0
    
; Laço que ler linha por linha do arquivo de entrada
loop_leitura:
    mov eax, 3
    mov ebx, [arqEntrada]
    mov ecx, array_saida
    imul edx, dword [largura_lida], 3
    int 80h

    ; Pula para o fim se o contador das linhas for igual a altura da imagem (em pixel)
    mov eax, dword [altura_lida] 
    cmp dword [contador1], eax
    je fim

    ; Pula para a escrita se o contador das linhas for menor que o valor da coordenada Y
    mov ebx, dword [valorCoordenadaY] 
    cmp dword [contador1], ebx
    jl escrita

    ; Pula para o processo se o contador das linhas for menor que a Coordenada Y + altura da censura
    ; Essa parte parte faz com que a censura só seja feita até Coordenada Y + altura - 1
    mov ebx, dword [valorCoordenadaY]  
    add ebx, dword [valorAltura] 
    cmp dword [contador1], ebx
    jl processo

; Essa parte é responsável por escrever no arquivo de saída
escrita:
    mov eax, 4
    mov ebx, [arqSaida]
    mov ecx, array_saida
    imul edx, dword [largura_lida], 3
    int 80h
    add DWORD [contador1], 1
    jmp loop_leitura

; Essa parte realiza a chamada da função censura_linha
processo:
    push dword [valorLargura]      ; Largura da censura
    push dword [valorCoordenadaX]  ; Coordenada X inicialal
    push array_saida
    call censura_linha
    jmp escrita
    

; Essa parte é responsável por fechar os arquivos de entrada/saída e finalizar a execução do programa
fim:
    mov eax, 6
    mov ebx, [arqEntrada]
    int 80h

    mov ebx, [arqSaida]
    int 80h

    mov eax, 1
    xor ebx, ebx
    int 80h