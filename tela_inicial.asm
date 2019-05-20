.model small

.stack 100H

.data   
    nomeJogo1 db "Batalha"
    nomeJogo2 db "Naval"
    nomeAnderson db "Anderson Imperatori"    
    nomeEduardo db "Eduardo Menzen"
    opJogar db "Jogar"
    opSair db "Sair"
    
    vetNumeros			db '0','1','2','3','4','5','6','7','8','9'
	tituloConfigIniciAL db "Matriz de Navios"
	textoConfig 		db "Digite a posicao do"

    CR EQU 13 ;ccdigo do espaco
    LF EQU 10 ;codigo do ENTER  
    
.code
EMPILHATUDO macro
    push AX
    push BX
    push CX
    push DX
    push SI
    push DI
    push BP
endm

DESEMPILHATUDO macro
    pop BP
    pop DI
    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
endm 

SAIR_JOGO proc ; sai do jogo     
   mov AL, 00  ; Codigo de retorno
   mov AH, 04CH; Servico de finalizar o programa
   int 21H
   ret      
endp    


LER_CHAR proc ; ler um caractere sem echo em AL
    mov AH, 7
    int 21H   
    ret       
  endp
  
LER_CHAR_SJ proc  ; le o valor do teclado em AX 
    ; posiciona o cursor
    add DH, 11  ; linha
    add DL, 30  ; coluna           
    mov BH, 1   ; pagina
    call MOV_CURSOR     
    
    push BX
    push CX
    push DX 
        
    xor AX, AX 
    xor CX, CX
    mov BX, 10
                    
LER_CHAR_SJ_SALVA:
    push AX    ; salvando o acumulador
         
LER_CHAR_SJ_LEITURA:       
    call LER_CHAR           ; ler o caractere
      
    ; !!! VERIFICACAO !!!                    
    cmp AL, 's'
    jz SAIR_JOGO      
     
    cmp AL, 'j'             ; verificar se eh valido
    jnz LER_CHAR_SJ_LEITURA 
     
      
    ;mov DL, AL              ; escrever o caractere
    ;call ESC_CHAR
   
     
    pop AX   ; restaurando o acumulador 
    pop DX
    pop CX
    pop BX  
    
    ret    
endp


MUDA_PAGINA proc ;muda para a pagina definida em AL
	push AX
	mov AH, 05h	;codigo da funcao: Selecione a pagina de exibição ativa
	int 10h
	pop AX
	ret
endp

MOV_CURSOR proc ; move o cursor DH = linha, DL = coluna, BH = página
	push AX
	mov AH, 02 ;codigo da funcao
	int 10h
	pop AX
	ret
endp

ESC_CHAR proc ; escreve um caractere em DL
   push AX    ; salva o reg AX
   mov AH, 2
   int 21H
   pop AX     ; restaura o reg AX
   ret  
endp 

ESC_CHAR_10 proc ;escreve caracter de AL, BL: cor, BH: número da página, CX: repetições
	push AX
	mov AH, 09h ; código da função
	int 10h
	pop AX
	ret
endp

ESC_STRING proc ;escreve string iniciada em ES:BP, comprimento CX, BH: número da página, DH: linha, DL: coluna, BL: cor
	push AX
	push BX
	push CX
	push DX
	mov AH, 13h ;código da função
	mov AL, 00h ;modo de gravação
	int 10h
	pop DX
	pop CX
	pop BX
	pop AX
	ret
endp

PRINT_LINHA_H proc	;escreve linha com tamanho CX
	push AX
	mov AL, 196 ;caracter -
	call ESC_CHAR_10
	add DL, CL	;encrementa coluna
	call MOV_CURSOR
	pop AX
	ret
endp

PRINT_BORDAS proc ;escreve as bordas laterais para uma linha da tabela
	push AX
	push CX
	mov CX, 1	;para escrever apenas 1 vez cada caracter
	mov AL, 179	;caracter |
	call MOV_CURSOR
	call ESC_CHAR_10
	sub DL, 23 ;move para escrever a borda na primeira coluna
	call MOV_CURSOR
	call ESC_CHAR_10
	pop CX
	pop AX
	ret
endp

PRINT_TABELA_INICIO_1 proc ;escreve a TABELA1 tendo como posição incial a linha DH e a coluna DL
	EMPILHATUDO

	;mov BH, AL	;grava a pagina ativa
	;mov BL, 7 	;cor: cinza claro
	mov CX, 1 	;numero de repeticoes
	mov AL, 218 ;canto superior esquerdo
	call MOV_CURSOR
	call ESC_CHAR_10
	inc DL		;incrementa coluna
	call MOV_CURSOR
	mov CX, 22 	;numero de repeticoes (tamanho da linha) 
	
	call PRINT_LINHA_H
	mov AL, 191 ;canto superior direito
	mov CX, 1 	;número de repeticoes
	call ESC_CHAR_10 
	       	
	mov CX, 11 ; numero de linhas
	BORDAS_CENTRO:
		inc DH
		call PRINT_BORDAS
		add DL, 23
	loop BORDAS_CENTRO
	
	mov CX, 1 	;numero de repeticoes
	sub DL, 23 	;coluna de base
	inc DH
	mov AL, 192 ;canto inferior direito
	call MOV_CURSOR
	call ESC_CHAR_10
	inc DL		;incrementa coluna
	call MOV_CURSOR
	mov CX, 22 	;numero de repeticoes (tamanho da linha)
	call PRINT_LINHA_H
	mov AL, 217 ;canto inferior esquerdo
	mov CX, 1 	;numero de repeticoes
	call ESC_CHAR_10 
	
	
	DESEMPILHATUDO
	ret
endp



PRINT_TELA_INICIO proc
	EMPILHATUDO
	mov BH, AL	;grava a pagina ativa
	mov DH, 1	;linha inicial
	mov DL, 28 	;coluna inicial
	mov BL, 7 	;cor: cinza claro
	call PRINT_TABELA_INICIO_1	
	add DH, 16	;linha inicial
	
	sub DH, 15	;linha inicial
	add DL, 9   ;coluna inicial
	mov CX, 7 	;tamanho da string
	mov BP, offset nomeJogo1 
	call ESC_STRING  
	
	add DH, 1	;linha inicial
	add DL, 1   ;coluna inicial
	mov CX, 5 	;tamanho da string
	mov BP, offset nomeJogo2 
	call ESC_STRING 
	        
	; MOSTRA NOME ANDERSON IMPERATORI        
	add DH, 2	;linha inicial 	
	sub DL, 8   ;coluna inicial
	mov CX, 19 	;tamanho da string
	mov BP, offset nomeAnderson  	   	
	call ESC_STRING 
	
  ; MOSTRA NOME EDUARNO MENZEL
	add DH, 1	;linha inicial
	mov CX, 14 	;tamanho da string
	mov BP, offset nomeeDUARDO  	   	
	call ESC_STRING  
	
	
	; MOSTRA AS OPCOES  
	;jogar
	add DH, 3	;linha inicial 	
	mov CX, 5 	;tamanho da string
	mov BP, offset opJogar  	   	
	call ESC_STRING  	
	; sair
	add DH, 1	;linha inicial   	
	mov CX, 4 	;tamanho da string
	mov BP, offset opSair  	   	
	call ESC_STRING  	
	
	DESEMPILHATUDO
	ret
endp 

; proc apenas para teste
PRINT_TESTE proc
	EMPILHATUDO
	mov BH, AL	;grava a pagina ativa
	mov DH, 1	;linha inicial
	mov DL, 28 	;coluna inicial
	mov BL, 7 	;cor: cinza claro
	;call PRINT_TABELA_INICIO_1	
	;add DH, 16	;linha inicial
	      	        
	; MOSTRA NOME ANDERSON IMPERATORI        
	add DH, 2	;linha inicial 	
	sub DL, 8   ;coluna inicial
	mov CX, 16 	;tamanho da string
	mov BP, offset tituloConfigIniciAL  	   	
	call ESC_STRING 
	ret
endp

INICIO:	
    mov AX, @data ; carrega valor inicial da stack
	mov DS, AX
	mov ES, AX	;para poder utilizar a função 13h da int 10H
	mov AH, 00h ;Define um modo de video
	mov AL, 03h ;codigo do modo desejado neste caso 80x25  8x8  texto 16 cores
  int 10h
	
	mov AL, 1	;define o numero da pagina
	call MUDA_PAGINA
	call PRINT_TELA_INICIO	   
	   
	; chama prog ler S ou J  
	call LER_CHAR_SJ	
  
	 
	; CHAMA A SEGUNDA TELA (MOSTRA AGORA TELA DE TESTE) 
	mov AL, 2        
  call MUDA_PAGINA
	call PRINT_TESTE 		
	
   call SAIR_JOGO ; finaliza o jogo     	
end INICIO 
