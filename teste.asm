.model small
.stack 100h
.data
	vetNumeros			db '0','1','2','3','4','5','6','7','8','9'
	tituloConfigIniciAL db "Matriz de Navios"
	textoConfig 		db "Digite a posicao do"

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


; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
LER_COORD_CONF proc   
    
    ; posiciona o cursor
    add DH, 20  ; linha
    add DL, 30  ; coluna           
    mov BH, 2   ; pagina
    call MOV_CURSOR  
    
    call LER_UINT16  ; le valor x
    
    call LER_UINT16  ; le valor y
    
    call LER_CHAR_VH ; le V ou H e chama prog de insersao
    
    ret
endp   
  
  
LER_UINT16 proc  ; le o valor do teclado em AX        
    push BX
    push CX
    push DX 
    
    xor AX, AX 
    xor CX, CX
    mov BX, 10
                    
LER_UINT16_SALVA:
    push AX    ; salvando o acumulador
         
LER_UINT16_LEITURA:       
    call LER_CHAR           ; ler o caractere     
      
    cmp AL, '0'             ; verificar se eh valido
    jb LER_UINT16_LEITURA 
  
    cmp AL, '9'
    ja LER_UINT16_LEITURA 
  
    mov DL, AL              ; escrever o caractere
    call ESC_CHAR
  
    mov CL, AL              ; salvar e tranformar em valor
    sub CL, '0'
    
    pop AX                  ; restaurando o acumulador 
    
    mul BX
    add AX,CX      
     
    push AX

LER_UINT16_FIM: 
    pop AX                  ; restaurando o acumulador 

    pop DX
    pop CX
    pop BX
              
    ret
endp 
 
 
LER_CHAR_VH proc  ; le o valor do teclado em AX
    push AX
	push BX
    push DX 
            

LER_CHAR_VH_LEITURA:       
    call LER_CHAR	;ler o caractere

    ; !!! VERIFICACAO !!!        
                      
    cmp AL, 'V'
    jz INSERE_BARCO_VERTICAL   

    cmp AL, 'H'
    jnz LER_CHAR_VH_LEITURA  
      
      
    call INSERE_BARCO_HORIZONTAL  
    

    pop DX
    pop BX
	pop AX	
    ret    
endp


proc INSERE_BARCO_VERTICAL
        
    ret
endp  

proc INSERE_BARCO_HORIZONTAL
              
    
    ret
endp

; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
LER_CHAR proc ; ler um caractere sem echo em AL
    mov AH, 7
    int 21H   
    ret       
endp 
 
MUDA_PAGINA proc ;muda para a página definida em AL
	push AX
	mov AH, 05h	;código da função: Selecione a página de exibição ativa
	int 10h
	pop AX
	ret
endp

MOV_CURSOR proc ; move o cursor DH = linha, DL = coluna, BH = página
	push AX
	mov AH, 02 ;código da função
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

PRINT_TABELA1 proc ;escreve a TABELA1 tendo como posição incial a linha DH e a coluna DL
	EMPILHATUDO

	;mov BH, AL	;grava a página ativa
	;mov BL, 7 	;cor: cinza claro
	mov CX, 1 	;número de repeticoes
	mov AL, 218 ;canto superior esquerdo
	call MOV_CURSOR
	call ESC_CHAR_10
	inc DL		;incrementa coluna
	call MOV_CURSOR
	mov CX, 22 	;número de repeticoes (tamanho da linha)
	call PRINT_LINHA_H
	mov AL, 191 ;canto superior direito
	mov CX, 1 	;número de repeticoes
	call ESC_CHAR_10
	inc DH
	call PRINT_BORDAS
	inc DH
	mov AL, 195 ;canto central direito
	call MOV_CURSOR
	call ESC_CHAR_10
	inc DL		;incrementa coluna
	call MOV_CURSOR
	mov CX, 22 	;número de repeticoes (tamanho da linha)
	call PRINT_LINHA_H
	mov AL, 180 ;canto central esquerdo
	mov CX, 1 	;número de repeticoes
	call ESC_CHAR_10
	
	mov CX, 11
	BORDAS_CENTRO:
		inc DH
		call PRINT_BORDAS
		add DL, 23
	loop BORDAS_CENTRO
	
	mov CX, 1 	;número de repeticoes
	sub DL, 23 	;coluna de base
	inc DH
	mov AL, 192 ;canto inferior direito
	call MOV_CURSOR
	call ESC_CHAR_10
	inc DL		;incrementa coluna
	call MOV_CURSOR
	mov CX, 22 	;número de repeticoes (tamanho da linha)
	call PRINT_LINHA_H
	mov AL, 217 ;canto inferior esquerdo
	mov CX, 1 	;número de repeticoes
	call ESC_CHAR_10
	
	sub DH, 11	;linha
	sub DL, 20 	;coluna
	call MOV_CURSOR
	mov CX, 10
	mov SI,OFFSET vetNumeros	
	ESC_NUM_HOR:	;escreve números horizontais
		push CX
		mov CX, 1
        mov AL, [SI]
        call ESC_CHAR_10
		inc SI
		inc DL
		inc DL
		call MOV_CURSOR
		pop CX
	loop ESC_NUM_HOR
	
	inc DH		;linha
	sub DL, 22 	;coluna
	call MOV_CURSOR
	mov CX, 10
	mov SI,OFFSET vetNumeros	
	ESC_NUM_VER:	;escreve números verticais
		push CX
		mov CX, 1
        mov AL, [SI]
        call ESC_CHAR_10
		inc SI
		inc DH
		call MOV_CURSOR
		pop CX
	loop ESC_NUM_VER
	
	DESEMPILHATUDO
	ret
endp

PRINT_TABELA2 proc ;escreve a TABELA2 tendo como posição incial a linha DH e a coluna DL
	EMPILHATUDO
	
	;mov BH, AL	;grava a página ativa
	;mov BL, 7 	;cor: cinza claro
	mov CX, 1 	;número de repeticoes
	mov AL, 218 ;canto superior esquerdo
	call MOV_CURSOR
	call ESC_CHAR_10
	inc DL		;incrementa coluna
	call MOV_CURSOR
	mov CX, 22 	;número de repeticoes (tamanho da linha)
	call PRINT_LINHA_H
	mov AL, 191 ;canto superior direito
	mov CX, 1 	;número de repeticoes
	call ESC_CHAR_10
	mov CX, 19 	;tamanho da string
	inc DH
	mov BP, offset textoConfig 	
	sub DL, 21
	call ESC_STRING	
	add DL, 21
	mov CX, 1 	;número de repeticoes
	call PRINT_BORDAS
	add DL, 23
	inc DH
	call PRINT_BORDAS
	add DL, 23
	inc DH
	call PRINT_BORDAS
	inc DH
	mov AL, 192 ;canto inferior direito
	call MOV_CURSOR
	call ESC_CHAR_10
	inc DL		;incrementa coluna
	call MOV_CURSOR
	mov CX, 22 	;número de repeticoes (tamanho da linha)
	call PRINT_LINHA_H
	mov AL, 217 ;canto inferior esquerdo
	mov CX, 1 	;número de repeticoes
	call ESC_CHAR_10
	
	DESEMPILHATUDO
	ret
endp

PRINT_TELA_CONFIG proc
	EMPILHATUDO
	mov BH, AL	;grava a página ativa
	mov DH, 1	;linha inicial
	mov DL, 28 	;coluna inicial
	mov BL, 7 	;cor: cinza claro
	call PRINT_TABELA1	
	add DH, 16	;linha inicial
	call PRINT_TABELA2
	sub DH, 15	;linha inicial
	add DL, 4
	mov CX, 16 	;tamanho da string
	mov BP, offset tituloConfigIniciAL
	call ESC_STRING
	
	DESEMPILHATUDO
	ret
endp

INICIO:	mov AX, @data ; carrega valor inicial da stack
	mov DS, AX
	mov ES, AX	;para poder utilizar a função 13h da int 10H
	mov AH, 00h ;Define um modo de vídeo
	mov AL, 03h ;código do modo desejado neste caso 80x25  8x8  texto 16 cores
    int 10h
	
	mov AL, 2	;define o número da página
	call MUDA_PAGINA
	call PRINT_TELA_CONFIG
	
	
	
	call LER_COORD_CONF     ; chama a leitura das coordernadas de configuracao
	
   mov AL, 00  ; Codigo de retorno
   mov AH, 04CH; Servico de finalizar o programa
   int 21H	
end INICIO
