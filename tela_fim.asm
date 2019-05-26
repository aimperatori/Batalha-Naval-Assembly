.model small
.stack 100h
.data
    nomeJogo1 		    db "Batalha"
    nomeJogo2 		    db "Naval"
	textAutores		    db "Autores:"
    nomeAnderson 		db "Anderson Imperatori"    
    nomeEduardo 		db "Eduardo Menzen"
    opJogar 		    db "Jogar" 
    
    ; !!!!!!!!!!!! ALTERACOES !!!!!!!!!!!!! 
    opNovoJogo          db "Novo Jogo"
    opNovamente         db " Novamente" 
    ; !!!!!!!!!!!! /ALTERACOES !!!!!!!!!!!!!
       
    opSair 			    db "Sair"	
	stringNumeros		db "0123456789"
	tituloMatrizNavios 	db "Matriz de Navios"
	tituloMatrizTiros 	db "Matriz de Tiros"
	texConfig 		    db "Digite a posicao do"
	texVoce           	db "Voce"
	texTiros          	db "Tiros:"
	texAcertos        	db "Acertos:" 
	texAfundados      	db "Afundados:"
	texComputador     	db "Computador:"
	texUltimoTiro     	db "Ultimo Tiro:"
	textPosicao		    db "Posicao:"
	textMensagens		db "Mensagens:" 
	
	; !!!!!!!!!!!! ALTERACOES !!!!!!!!!!!!!
	textFimdeJogo       db "Fim de Jogo"
	textVoceGanhou      db "VOCE GANHOU"
	textPCGanhou        db "COMPUTADOR GANHOU" 
	textNumJogadas      db "Numero de Jogadas:"
	; !!!!!!!!!!!! /ALTERACOES !!!!!!!!!!!!!
	
	vetquadrados        db 10 dup(254,' ')  ;quadrado + caractere nulo
    vetCoord            db 2 dup(?)   ;vetor com 2 elemento para as coordenadas
      
    porta_avioes db "Porta Avioes"     
    navio_de_guerra db "Navio de Guerra"
    submarino db "Submarino"
    destroyer db "Destroyer"
    barco_patrulha db "Barco Patrulha"
            
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
	mov al, 0
	call MUDA_PAGINA    
	mov AL, 00  ; Codigo de retorno
	mov AH, 04CH; Servico de finalizar o programa
	int 21H
	ret      
endp    


LER_CHAR proc ; ler um caractere sem echo em AL (nao mostra na tela)
    mov AH, 07H
    int 21H   
    ret       
  endp
  
LER_CHAR_SJ proc  ; le o valor do teclado em AX
    push AX
	push BX
    push DX 

    ; posiciona o cursor
    add DH, 11  ; linha
    add DL, 30  ; coluna           
    mov BH, 1   ; pagina
    call MOV_CURSOR     

LER_CHAR_SJ_LEITURA:       
    call LER_CHAR	;ler o caractere

    ; !!! VERIFICACAO !!!                    
    cmp AL, 's'
    jz SAIR_JOGO      

    cmp AL, 'j'
    jnz LER_CHAR_SJ_LEITURA

    pop DX
    pop BX
	pop AX	
    ret    
endp


; !!!!!!!!!!!! ALTERACOES !!!!!!!!!!!!! 
 
LER_CHAR_JN proc  ; le o valor do teclado em AX
    push AX
	push BX
    push DX       

LER_CHAR_JN_LEITURA:       
    call LER_CHAR	;ler o caractere
                             
    cmp AL, 'J'
    jz SAIR_JOGO    ;PROVISORIO (ira chamar prog pra repetir jogo)  

    cmp AL, 'N'
    jnz LER_CHAR_JN_LEITURA    
    
    pop DX
    pop BX
	pop AX
    
    ;comeca tudo de novo
    jmp INICIO  
    	
    ret    
endp

; !!!!!!!!!!!! /ALTERACOES !!!!!!!!!!!!!  


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
   
PRINT_BORDAS proc ;escreve as bordas laterais para uma linha da tabela com largura AL
	push AX
	push CX
	push DX
	
	push AX
	mov CX, 1	;para escrever apenas 1 vez cada caracter
	mov AL, 179	;caracter |
	call MOV_CURSOR
	call ESC_CHAR_10
	pop AX
	inc AL
	add DL, AL	;move para escrever a borda na segunda coluna
	call MOV_CURSOR
	mov AL, 179	;caracter |
	call ESC_CHAR_10
	
	pop DX
	pop CX
	pop AX
	ret
endp


PRINT_LINHA_SUPERIOR proc	;escreve linha central da tabela na iniciando na posição DH: linha, DL: coluna, AX: largura da linha - 2(extremos) 
	push AX
	push CX
	push DX
	
	push AX		;salva largura da linha
	mov AL, 218 ;canto superior esquerdo
	mov CX, 1 	;número de repeticoes
	call MOV_CURSOR
	call ESC_CHAR_10
	inc DL
	call MOV_CURSOR
	pop AX		
	add DL, AL  ;seta a coluna para escrever o canto direito
	mov CX, AX	;número de repeticoes (largura da linha sem os extremos)
	mov AL, 196 ;caracter -
	call ESC_CHAR_10
	call MOV_CURSOR	;move para a posição setada anteriormente
	mov AL, 191 ;canto superior direito
	mov CX, 1 	;número de repeticoes
	call ESC_CHAR_10
	
	pop DX
	pop CX
	pop AX
	ret
endp

PRINT_LINHA_CENTRAL proc	;escreve linha central na tabela, iniciando na posição DH: linha, DL: coluna, AX: largura da linha - 2(extremos)  
	push AX
	push CX
	push DX
	
	push AX		;salva largura da linha
	mov AL, 195 ;canto central esquerdo
	mov CX, 1 	;número de repeticoes
	call MOV_CURSOR
	call ESC_CHAR_10
	inc DL
	call MOV_CURSOR
	pop AX		
	add DL, AL  ;seta a coluna para escrever o canto direito
	mov CX, AX	;número de repeticoes (largura da linha sem os extremos)
	mov AL, 196 ;caracter -
	call ESC_CHAR_10
	call MOV_CURSOR	;move para a posição setada anteriormente
	mov AL, 180 ;canto central direito
	mov CX, 1 	;número de repeticoes
	call ESC_CHAR_10
	
	pop DX
	pop CX
	pop AX
	ret
endp

PRINT_LINHA_INFERIOR proc	;escreve linha central da tabela na iniciando na posição DH: linha, DL: coluna, AX: largura da linha - 2(extremos) 
	push AX
	push CX
	push DX
	
	push AX		;salva largura da linha
	mov AL, 192 ;canto inferior esquerdo
	mov CX, 1 	;número de repeticoes
	call MOV_CURSOR
	call ESC_CHAR_10
	inc DL
	call MOV_CURSOR
	pop AX		
	add DL, AL  ;seta a coluna para escrever o canto direito
	mov CX, AX	;número de repeticoes (largura da linha sem os extremos)
	mov AL, 196 ;caracter -
	call ESC_CHAR_10
	call MOV_CURSOR
	mov AL, 217 ;canto inferior direito
	mov CX, 1 	;número de repeticoes
	call ESC_CHAR_10
	
	pop DX
	pop CX
	pop AX
	ret
endp

PRINT_RETANGULO proc ;escreve um retangulo de largura AX e altura CX, tendo como posição incial a linha DH e a coluna DL
	push AX
	push CX
	push DX
	
	call PRINT_LINHA_SUPERIOR
	BORDAS_CENTRO:
		inc DH
		call PRINT_BORDAS
	loop BORDAS_CENTRO
	call PRINT_LINHA_INFERIOR
	
	pop DX
	pop CX
	pop AX
	ret
endp

PRINT_TELA_INICIO proc
	push AX
	push BX
	push CX
	push DX
	push BP
	
	mov BH, 1	;define o numero da página
	mov DH, 1	;linha inicial
	mov DL, 28 	;coluna inicial
	mov BL, 7 	;cor: cinza claro
	mov CX, 14  ;altura da retângulo
	mov AX, 21  ;largura da retângulo
	call PRINT_RETANGULO
	
	inc DH		;linha
	add DL, 7   ;coluna
	mov CX, 7 	;tamanho da string
	mov BP, offset nomeJogo1 
	call ESC_STRING  
	
	inc DH		;linha inicial
	inc DL		;coluna inicial
	mov CX, 5 	;tamanho da string
	mov BP, offset nomeJogo2 
	call ESC_STRING
        
	add DH, 3	;linha inicial 	
	sub DL, 6   ;coluna inicial
	mov CX, 8 	;tamanho da string
	mov BP, offset textAutores  	   	
	call ESC_STRING 	

	; MOSTRA NOME ANDERSON IMPERATORI        
	inc DH		;linha inicial 	
	mov CX, 19 	;tamanho da string
	mov BP, offset nomeAnderson  	   	
	call ESC_STRING 
	
	; MOSTRA NOME EDUARDO MENZEN
	inc DH		;linha inicial
	mov CX, 14 	;tamanho da string
	mov BP, offset nomeEduardo  	   	
	call ESC_STRING
	
	; MOSTRA AS OPCOES  
	;jogar
	add DH, 3	;linha inicial 	
	mov CX, 5 	;tamanho da string
	mov BP, offset opJogar  	   	
	call ESC_STRING  	
	; sair
	inc DH		;linha inicial   	
	mov CX, 4 	;tamanho da string
	mov BP, offset opSair  	   	
	call ESC_STRING 
	
	pop BP
	pop DX
	pop CX
	pop BX
	pop AX
	ret
endp

ESC_NUMEROS proc ;escreve os numeros tendo como posição incial a linha DH e a coluna DL
	push AX
	push CX
	push DX
	push SI
		
	add DH, 3	;ajusta linha
	add DL, 3 	;ajusta coluna
	call MOV_CURSOR
	mov CX, 10
	mov SI,OFFSET stringNumeros	
	ESC_NUM_HOR:	;escreve números horizontais
		push CX
		mov CX, 1
		lodsb
        call ESC_CHAR_10
		inc DL
		inc DL
		call MOV_CURSOR
		pop CX
	loop ESC_NUM_HOR
	
	inc DH		;linha
	sub DL, 22 	;coluna
	call MOV_CURSOR
	mov CX, 10
	mov SI,OFFSET stringNumeros	
	ESC_NUM_VER:	;escreve números verticais
		push CX
		mov CX, 1
        lodsb
        call ESC_CHAR_10
		inc DH
		call MOV_CURSOR
		pop CX
	loop ESC_NUM_VER
	
	pop SI
	pop DX
	pop CX
	pop AX
	ret
endp

PRINT_TELA_CONFIG proc
	push AX
	push BX
	push CX
	push DX
	push BP
	
	mov BH, 2	;define o numero da página
	mov DH, 1	;linha inicial
	mov DL, 28 	;coluna inicial
	mov BL, 7 	;cor: cinza claro
	mov CX, 14  ;altura da retângulo
	mov AX, 21  ;largura da retângulo
	call PRINT_RETANGULO
	call ESC_NUMEROS
	add DH, 2
	call PRINT_LINHA_CENTRAL
	dec DH	;linha
	add DL, 4
	mov CX, 16 	;tamanho da string
	mov BP, offset tituloMatrizNavios
	call ESC_STRING
	sub DL, 4
	add DH, 14	;linha
	mov CX, 4  ;altura da retângulo
	call PRINT_RETANGULO
	inc DH
	add DL, 2
	mov CX, 19 	;tamanho da string
	mov BP, offset texConfig
	call ESC_STRING
	
	pop BP
	pop DX
	pop CX
	pop BX
	pop AX
	ret
endp

PRINT_QUADRADOS_VERDES proc
	EMPILHATUDO 
	
    mov BL, 2 	;cor: verde
    add DH, 4   ;ajusta linha
    add DL, 3   ;ajusta coluna
    mov CX, 10
    mov BP, offset vetquadrados
	LACO_QUADRADOS:
        push CX
        call MOV_CURSOR
    	mov CX, 20
    	call ESC_STRING
    	inc DH
    	pop CX
	loop LACO_QUADRADOS
	
	DESEMPILHATUDO
	ret
endp

PRINT_TELA_JOGO proc
	EMPILHATUDO
	
	mov BH, 3
	mov DH, 1	;linha inicial
	mov DL, 1 	;coluna inicial
	mov BL, 7 	;cor: cinza claro 
	
	;desenhar tabela de tiros
	call PRINT_QUADRADOS_VERDES
	mov CX, 14  ;altura da retângulo
	mov AX, 21  ;largura da retângulo
	call PRINT_RETANGULO
	call ESC_NUMEROS
	
	;desenhar tabela de navios
	add DL, 24  ;coluna
	call PRINT_RETANGULO
	call ESC_NUMEROS
	inc DH
	sub DL, 20
	mov CX, 15 	;tamanho da string
	mov BP, offset tituloMatrizTiros
	call ESC_STRING
	inc DH
	sub DL, 4
	call PRINT_LINHA_CENTRAL
	add DL, 24
	call PRINT_LINHA_CENTRAL
	dec DH
	mov CX, 16	;tamanho da string
	add DL, 4
	mov BP, offset tituloMatrizNavios
	call ESC_STRING
	
	;desenhar tabela de resultados
	inc DH
	add DL, 21
	mov CX, 11  ;altura da retângulo
	mov AX, 18  ;largura da retângulo
	call PRINT_RETANGULO
	
	;escrever os textos dentro da tabela de resultados
	inc DH  	;linha
	inc DL  	;coluna
	mov CX, 4	;tamanho da string
	mov BP, offset texVoce
	call ESC_STRING
	
	add DH, 4	;linha
	dec DL  	;coluna
	call PRINT_LINHA_CENTRAL
	
	inc DH  	;linha
	inc DL  	;coluna
	mov CX, 11	;tamanho da string
	mov BP, offset texComputador
	call ESC_STRING	
	
	sub DH, 6    ;linha
	add DL, 3 	;coluna
	mov CX, 2	
	LACO:
		push CX
		add DH,2  	;linha
		mov CX, 6	;tamanho da string
		mov BP, offset texTiros
		call ESC_STRING
		inc DH  	;linha
		mov CX, 8	;tamanho da string
		mov BP, offset texAcertos
		call ESC_STRING
		inc DH  	;linha
		mov CX, 10	;tamanho da string
		mov BP, offset texAfundados
		call ESC_STRING
		inc DH
		pop CX
	loop LACO
	mov CX, 12	;tamanho da string
	mov BP, offset texUltimoTiro
	call ESC_STRING
    
    add DH, 4   ;linha
    mov DL, 1 	;coluna inicial
    mov CX, 3  	;altura da retângulo
	mov AX, 67  ;largura da retângulo
	call PRINT_RETANGULO
	
	inc DH		;linha
	inc DL      ;coluna
	mov CX, 8	;tamanho da string
	mov BP, offset textPosicao
	call ESC_STRING
	add DL, 22  ;coluna
	mov CX, 10	;tamanho da string
	mov BP, offset textMensagens
	call ESC_STRING
	
	dec DH      ;linha
	dec DL      ;coluna
	call MOV_CURSOR       
	mov AL, 194 ;caracter  _|_ invertido
	xor CX, CX
	inc CX
	call ESC_CHAR_10
	
	inc DH      ;linha
	call MOV_CURSOR
	mov AL, 179	;caracter |
	call ESC_CHAR_10
	inc DH      ;linha
	call MOV_CURSOR
	call ESC_CHAR_10	

	inc DH      ;linha
	call MOV_CURSOR
	mov AL, 193	;caracter _|_
	call ESC_CHAR_10	
    
	DESEMPILHATUDO
	ret
endp  

; !!!!!!!!!!!! ALTERACOES !!!!!!!!!!!!! 
 
PRINT_TELA_FINAL proc     
    push AX
	push BX
	push CX
	push DX
	push BP
	
	mov BH, 4	;define o numero da pagina
	mov DH, 1	;linha inicial
	mov DL, 28 	;coluna inicial
	mov BL, 7 	;cor: cinza claro
	mov CX, 14  ;altura da retângulo
	mov AX, 21  ;largura da retângulo
	call PRINT_RETANGULO 
	
	;texto Fim de Jogo 	
	add DH, 1	;linha	
	add DL, 6   ;coluna
	mov CX, 11 	;tamanho da string
	mov BP, offset textFimdeJogo
	call ESC_STRING 
	
	;texto VOCE GANHOU (PROVISORIO, varia quem ganhou)
	add DH, 3	 ;linha	
	mov CX, 11   ;tamanho da string
	mov BP, offset textVoceGanhou
	call ESC_STRING 
	
	;texto Numero de Jogadas
	add DH, 3	;linha	
	sub DL, 5   ;coluna
	mov CX, 18 	;tamanho da string
	mov BP, offset textNumJogadas
	call ESC_STRING 
	
	;linha central	
	add DH, 2	;linha	
	sub DL, 1   ;coluna
	mov AX, 21  ;tamanho da linha
	call PRINT_LINHA_CENTRAL
	
	;opcao Jogar
	add DH, 2	;linha	
	add DL, 2   ;coluna
	mov CX, 5 	;tamanho da string
	mov BP, offset opJogar
	call ESC_STRING 	
	
	;cancatena com jogar (Novamente)
	add DL, 5   ;coluna
	mov CX, 10 	;tamanho da string
	mov BP, offset opNovamente
	call ESC_STRING 	
	
	;texto Novo Jogo
	add DH, 1	;linha	
	sub DL, 5   ;coluna
	mov CX, 9 	;tamanho da string
	mov BP, offset opNovoJogo
	call ESC_STRING 
		
	
	pop BP
	pop DX
	pop CX
	pop BX
	pop AX
	ret 
endp
      
; !!!!!!!!!!!! /ALTERACOES !!!!!!!!!!!!! 

 
LIMPA_ESC proc ; CX: tamanho da linha, DH: posicao linha, DL: posicao coluna e BL: pagina
    PUSH AX
    push CX       
    push DX 
     
    LACO_LIMPA:   
        inc DL              ;coluna
	    call MOV_CURSOR
        mov AL, ' '         ;caracter espaco para limpar 
        call ESC_CHAR_10         
    loop LACO_LIMPA
     
    pop DX  
    pop CX
    pop AX    
    ret
endp    


INSERE_BARCOS proc       
    ;EMPILHA GERAL
    push BP        
    push DX     
    push BX
    
    ;SETA LINHA, COLUNA, PAGINA E COR 
    mov DH, 18       ;linha
    mov DL, 33       ;coluna           
    mov BH, 2        ;pagina 
    mov BL, 7 	     ;cor: cinza claro 
    
    
    ;LE PORTA AVIOES        
    push CX           
	mov CX, 12	     ;tamanho da string
	mov BP, offset porta_avioes 	   
    call MOV_CURSOR	  
	call ESC_STRING     
     
    ;PASSAR TAM BARCO 
    call LER_COORD_CONF    ;le coordenada
     
    push DX    
    mov DL, 28       ;coluna       
	mov CX, 20	     ;tamanho da string 
    call LIMPA_ESC   ;limpa nome do barco
    inc DH           ;avaca uma linha
	call LIMPA_ESC	 ;limpa entrada	
    pop DX     
    pop CX
         
    
    ;LE NAVIO DE GUERA    
    push CX       
    dec DL           ;coluna     
	mov CX, 15	     ;tamanho da string
	mov BP, offset navio_de_guerra        
    call MOV_CURSOR	  
	call ESC_STRING    
         
    ; PASSA TAM BARCO 
    call LER_COORD_CONF    ;le coordenada
    
    push DX
    mov DL, 28       ;coluna       
	mov CX, 20	     ;tamanho da string 
    call LIMPA_ESC   ;limpa nome do barco
    inc DH           ;avaca uma linha
	call LIMPA_ESC   ;limpa entrada
	pop DX	  
    pop CX      
             
    
    ;LE SUBMARINO      
    push CX  
    add DL, 2        ;coluna  
	mov CX, 9	     ;tamanho da string
	mov BP, offset submarino        
    call MOV_CURSOR	  
	call ESC_STRING    
         
    ; PASSA TAM BARCO 
    call LER_COORD_CONF    ;le coordenada
    
    push DX
    mov DL, 28       ;coluna       
	mov CX, 20	     ;tamanho da string 
    call LIMPA_ESC   ;limpa nome do barco
    inc DH           ;avaca uma linha
	call LIMPA_ESC   ;limpa entrada
    pop DX    
    pop CX      
           
    
    ;LE DESTROYER   
    push CX          
	mov CX, 9	     ;tamanho da string
	mov BP, offset destroyer       
    call MOV_CURSOR	  
	call ESC_STRING    
         
    ;PASSA TAM BARCO 
    call LER_COORD_CONF    ;le coordenada
     
    push DX 
    mov DL, 28       ;coluna       
	mov CX, 20	     ;tamanho da string 
    call LIMPA_ESC   ;limpa nome do barco
    inc DH           ;avaca uma linha
	call LIMPA_ESC	 ;limpa entrada
    pop DX     
    pop CX    
    
    ;LE BARCO PATRULA   
    push CX  
    sub DL, 2        ;coluna               
	mov CX, 14	     ;tamanho da string
	mov BP, offset barco_patrulha        
    call MOV_CURSOR	  
	call ESC_STRING    
         
    ; PASSA TAM BARCO 
    call LER_COORD_CONF    ;le coordenada
    
    push DX
    mov DL, 28       ;coluna       
	mov CX, 20	     ;tamanho da string 
    call LIMPA_ESC   ;limpa nome do barco
    inc DH           ;avaca uma linha
	call LIMPA_ESC	 ;limpa entrada
    pop DX     
   
    
    ;DESEMPILHA GERAL
    pop DX
    pop CX      
    pop BX 
    pop BP
    
    ret
endp 
   
                                       
LER_COORD_CONF proc   
    push BX
    push CX
    push DX     
     
    ;posiciona o cursor
    mov DH, 19  ; linha    
    mov DL, 37  ; coluna           
    mov BH, 2   ; pagina 
    mov BL, 7 	;cor: cinza claro
    mov CX, 1 
    call MOV_CURSOR    
    
    
    push DI
    mov DI, offset vetCoord ; BX = endereco de vetor    
	mov CX, 2 	 ; qtd de iteracoes
	             
	cld  ; seta flag de direcaol             
	             
	LACO_LEITURA: 
	    call LER_UINT16    
	    stosb	 ; move a leitura para o vetor   
	loop LACO_LEITURA
	pop DI
    
    call LER_CHAR_VH ; le V ou H e chama proc de insersao
     
    pop DX 
    pop CX   
    pop BX 
     
     
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
     
    
    ;mov DH, 19       ;linha
    ;mov DL, 37       ;coluna           
    ;mov BH, 2        ;pagina 
    ;mov BL, 7 	     ;cor: cinza claro     
   	;mov CX, 1   
    ;call MOV_CURSOR	   
;escreve caracter de AL, BL: cor, BH: número da página, CX: repetições     
    
    ;call ESC_CHAR_10 
    
    
    
  
    mov CL, AL              ; salvar e tranformar em valor
    sub CL, '0'
    
    pop AX                  ; restaurando o acumulador 
    
    mul BX
    add AX,CX      
     
    ;push AX

LER_UINT16_FIM: 
    ;pop AX                  ; restaurando o acumulador 

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
           
    ;verifica se eh V                  
    cmp AL, 'V'
    jz INSERE_BARCO_VERTICAL   
    ;verifica se eh H
    cmp AL, 'H'
    jnz LER_CHAR_VH_LEITURA  
                            
    mov DL, AL            ; escrever o caracter
    call ESC_CHAR
           
               
    call INSERE_BARCO_HORIZONTAL  
      
    FINAL_LEITURA:  
       
       
    pop DX
    pop BX
	pop AX	
    ret    
endp


proc INSERE_BARCO_VERTICAL
    mov DL, AL            ; escrever o caracter
    call ESC_CHAR
    
    
       
        
    jmp FINAL_LEITURA    
        
    ret
endp  

proc INSERE_BARCO_HORIZONTAL     
              
    
    ret
endp
 

INICIO:	mov AX, @data ; carrega valor inicial da stack
	mov DS, AX
	mov ES, AX	;para poder utilizar a função 13h da int 10H
	mov AH, 00h ;Define um modo de vídeo
	mov AL, 03h ;código do modo desejado neste caso 80x25  8x8  texto 16 cores
    int 10h
	
	mov AL, 1	;define o número da página
	call MUDA_PAGINA
	call PRINT_TELA_INICIO
	
	; chama prog ler S ou J  
	call LER_CHAR_SJ
	
	;mov AL, 2	;define o número da página
	;call MUDA_PAGINA
	;call PRINT_TELA_CONFIG	
	
	
	 ;call LER_CHAR	  
	  
	;call INSERE_BARCOS     ;mecanismo de leitura e insersao na matriz
	  	   	
	;mov AL, 3	;define o número da página
    ;call MUDA_PAGINA
	;call PRINT_TELA_JOGO 
	
	
	
	; !!!!!!!!!!!! ALTERACOES !!!!!!!!!!!!!
	mov AL, 4	;define o número da página
	call MUDA_PAGINA                
	call PRINT_TELA_FINAL
	
	call LER_CHAR_JN  
	
	
	; !!!!!!!!!!!! /ALTERACOES !!!!!!!!!!!!!
	
	
	call LER_CHAR
	
	call SAIR_JOGO ; finaliza o jogo
end INICIO
