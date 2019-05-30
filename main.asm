.model small
.stack 100h
.data
    nomeJogo1 			db "Batalha"
    nomeJogo2 			db "Naval"
	textAutores			db "Autores:"
    nomeAnderson 		db "Anderson Imperatori"    
    nomeEduardo 		db "Eduardo Menzen"
    opJogar 			db "Jogar"
    opSair 				db "Sair"	
	stringNumeros		db "0123456789"
	tituloMatrizNavios 	db "Matriz de Navios"
	tituloMatrizTiros 	db "Matriz de Tiros"
	texConfig 			db "Digite a posicao do"
	texVoce           	db "Voce"
	texTiros          	db "Tiros:"
	texAcertos        	db "Acertos:" 
	texAfundados      	db "Afundados:"
	texComputador     	db "Computador:"
	texUltimoTiro     	db "Ultimo Tiro:"
	textPosicao			db "Posicao:"
	textMensagens		db "Mensagens:"
	vet_embarcacoes 	db " Porta Avioes  "     
						db "Navio de Guerra"
						db "   Submarino   "
						db "   Destroyer   "
						db "Barco Patrulha "
	vet_tam_embarcacoes	db 05,04,03,03,02
	vet_Navios			db 'A','B','S','D','P'
	matrizNavios 		db 100 dup(0)
	matrizNaviosBackup 	db 100 dup(?)
	
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
	LACO_QUADRADOS:
        push CX
		mov CX, 10
		LACO_QUADRADOS2:
			call MOV_CURSOR
			push CX
			mov CX, 1
			mov AL, 254	;quadrado
			call ESC_CHAR_10
			add DL, 2
			pop CX
		loop LACO_QUADRADOS2
    	inc DH
		sub DL, 20
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

LER_POSICAO proc ;realiza a leitura da posição devolvendo o valor em AH e a direção em AL
    push BX
    push CX
	push DX
	
	call MOV_CURSOR
	mov CX, 3
	mov AL, ' '		;para limpar o texto no cursor
	call ESC_CHAR_10
	
    xor AX, AX ;variavel aculumador	
	
	;leitura da posição
    mov CX, 2
	LER_CORRETO:
		push CX
		push AX
		
	LER_ALGARISMO:
		call MOV_CURSOR
		call LER_CHAR
		cmp AL, '0'
		jb LER_ALGARISMO
		cmp AL, '9'
		ja LER_ALGARISMO
		mov CX, 1
		call ESC_CHAR_10
		inc DL
		sub AL, '0' ;converte caractere para dígito
		mov CL, AL
		pop AX
		mov CH, 10 ;valor 10 da multiplicação
		mul CH  ;AX = AL * CH
		add AL, CL
		pop CX
	loop LER_CORRETO
		
	mov CH, AL	;salva o valor em CH
	call MOV_CURSOR
	;leitura da direção
	LER_CHAR_VH:
		call LER_CHAR
		;verifica se eh V                  
		cmp AL, 'V'
		jz ESCREVE_DIRECAO	;se AL = 'V', escre a direção
		;verifica se eh H
		cmp AL, 'H'
		jnz LER_CHAR_VH		;se AL != 'H', lê novamente		
	
	ESCREVE_DIRECAO:
	mov AH, CH	;retorna o valor da posição em AH
	mov CX, 1
	call ESC_CHAR_10	
			
    pop DX
    pop CX
    pop BX   
    ret
endp 

VALIDA_LIMITE_MATRIZ proc	;recebe posição em AH, direção (V ou H) em AL e tamanho da embarcação em CL
	push AX					;devolvendo se é valida (BL = 1) ou não (BL = 0)
	
	cmp AL, 'H'			;verifica se é horizontal
	jnz VERTICAL		;se não é horizontal vai para as validações verticais
		mov AL, AH		;salva posição em AL
		xor AH, AH		;zera AH
		mov BL, 10		;valor para divisão
		div BL			;AL:AH <- AX/BL (quociente:resto) -> AH recebe o valor da coluna
		jmp VALIDACOES
	VERTICAL:
		mov AL, AH		;salva posição em AL
		xor AH, AH		;zera AH
		mov BL, 10		;valor para divisão
		div BL			;AL:AH <- AX/BL (quociente:resto) -> AL recebe o valor da linha
		mov AH, AL		;move o valor da linha para AH
	
	mov BL, 1			;seta posição como válida
	VALIDACOES:
		cmp AH, 9		;nenhuma embarcação pode ser inserida na posição 9
		jb CONTINUA1	;AH < 9
		xor BL, BL		;posição não é válida (BL = 0)
		jmp FIM_VALIDA
		CONTINUA1:
		cmp AH, 6		;qualquer embarcação pode ser inserida nas posições 0,1,2,3,4 e 5
		jb FIM_VALIDA	;AH < 6
		cmp CL, 2		;embarcação com tamanho 2
		jnz CONTINUA2	;se CL != 2
		cmp AH, 8
		jbe FIM_VALIDA	;se AH <= 8, a posição é válida
		xor BL, BL		;posição não é válida (BL = 0)
		jmp FIM_VALIDA		
		CONTINUA2:
		cmp CL, 3		;embarcação com tamanho 3
		jnz CONTINUA3	;se CL != 3
		cmp AH, 7
		jbe FIM_VALIDA	;se AH <= 7, a posição é válida
		xor BL, BL		;posição não é válida (BL = 0)
		jmp FIM_VALIDA		
		CONTINUA3:
		cmp CL, 4		;embarcação com tamanho 4
		jnz CONTINUA4	;se CL != 4
		cmp AH, 6
		jbe FIM_VALIDA	;se AH <= 6, a posição é válida
		xor BL, BL		;posição não é válida (BL = 0)
		jmp FIM_VALIDA		
		CONTINUA4:			
		xor BL, BL		;embarcação com tamanho 5 está numa posição não válida (BL = 0)
				
	FIM_VALIDA:
	
	pop AX
	ret
endp

VALIDA_POSICAO proc	;recebe posição em AH, direção em AL, tamanho da embarcação em CL e a matriz em DI
	push AX				;verifica se a posição está livre retornando e é valida (BL = 1) ou não (BL = 0)
	push CX
	
	xor CH, CH			;zera parte alta do CX, pois recebe o tamanho em CL
	xor BX, BX			;limpa BX
	mov BL, AH			;copia a posição para BX
	cmp AL, 'H'			;verifica se é horizontal
	jnz VERTICAL2		;se não é horizontal vai para a validação vertical
		HORIZONTAL:
			mov AL, [DI+BX]	;tenho que trazer apenas 1 byte
			or AL, AL		;verifica se a posição está livre
			jnz	POSICAO_OCUPADA
			inc BX
		loop HORIZONTAL
		jmp POSICAO_VALIDA	;se chegou aqui é pq a posição está livre
		
	VERTICAL2:
		mov AL, [DI+BX]
		or AL, AL	;verifica se a posição está livre
		jnz	POSICAO_OCUPADA
		add BX,10
	loop VERTICAL2
	
	POSICAO_VALIDA:
		mov BL, 1		;a posição não está ocupada (pode inserir)
		jmp FIM_VALIDA_POS
	POSICAO_OCUPADA:
		xor BL, BL		;a posição está ocupada (não pode inserir)
	
	FIM_VALIDA_POS:
	
	pop CX
	pop AX
	ret
endp

COPIA_MATRIZ proc ;copia a "matriz" em SI para outra "matriz" em DI
	push CX
	push SI
	push DI
	mov CX, 100
	COPIA:
		movsb	;[ES:DI] <- [DS:SI] inc SI e DI
		loop COPIA
	pop DI
	pop SI
	pop CX
	ret
endp

GRAVA_EMB_HORIZONTAL proc ;grava embarcação em AL com tamanho CL na posição AH na matriz em SI
	push BX
	push CX
	push SI
	
	xor BX, BX	;limpa BX
	xor CH, CH	;limpa parte alta do CX
	mov BL, AH
	GRAVAH:
		mov [SI+BX], AL
		inc BX
		loop GRAVAH
	pop SI
	pop CX
	pop BX
	ret
endp

GRAVA_EMB_VERTICAL proc ;grava embarcação em AL com tamanho CL na posição AH na matriz em SI
	push BX
	push CX
	push SI
	
	xor BX, BX	;limpa BX
	xor CH, CH	;limpa parte alta do CX
	mov BL, AH
	GRAVAV:
		mov [SI+BX], AL
		add BX, 10
		loop GRAVAV
	pop SI
	pop CX
	pop BX
	ret
endp

ESCREVE_MATRIZ_NAVIOS proc ;escreve de Navios em SI na posição DH:DL linha:coluna
	push AX
	push BX
	push CX
	push DX
	push SI
	
	mov CX, 10
	ESCREVE1:
		push CX
		mov CX, 10
	    ESCREVE2:
	        push CX
			call MOV_CURSOR
			mov AL, ' '	;espaço
			call ESC_CHAR_10
			inc DL		;coluna			
			lodsb		;AL <- [DS:SI] e inc SI
			mov CX, 1   ;escreve uma vez o caracter
			call MOV_CURSOR
			call ESC_CHAR_10
			inc DL		;coluna
			pop CX
			loop ESCREVE2
		sub DL, 20	;coluna
		inc DH	;linha
		call MOV_CURSOR
		pop CX
		loop ESCREVE1
	pop SI
	pop DX
	pop CX
	pop BX
	pop AX
	ret
endp

INSERE_BARCOS proc ;insere os barcos na matriz de Navios e escreve na tela      
    push BP        
    push DX     
    push BX
	push SI
	push DI
    
    ;SETA LINHA, COLUNA, PAGINA E COR 
    mov DH, 18       ;linha
    mov DL, 32       ;coluna           
    mov BH, 2        ;pagina 
    mov BL, 7 	     ;cor: cinza claro 
    
    ;LE PORTA EMBARCAÇÕES
	mov CX, 5	;são 5 embarcações
	mov BP, offset vet_embarcacoes
	mov SI, offset vet_tam_embarcacoes
	mov DI, offset vet_Navios
	
	LER_EMBARCACOES:
		push CX
		mov CX, 15	    ;tamanho da string
		call MOV_CURSOR	  
		call ESC_STRING
		add BP, CX		;já posiciona para pegar o nome da próxima embarcação
		inc DH			;avança uma linha
		add DL, 6		;avança colunas
	
		LER_NOVAMENTE:
			call LER_POSICAO;devolve o valor da posição em AH e direção (V ou H) em AL
			mov CL, [SI]	;busca o tamanho da embarcação
			push BX			;BX possui o contexto de página e cor
				call VALIDA_LIMITE_MATRIZ ;verifica posição dentro dos limites da matriz devolvendo se é é valida (BL = 1) ou não (BL = 0)
				or BL, BL			;equivalente a comparar com zero (cmp BL, 0)
				jz FALHO_VALIDACAO	;se a posição não é valida não realiza a segunda validação
				push DI
				mov DI, offset matrizNavios
				call VALIDA_POSICAO ;verifica se a posição já está ocupada
				pop DI
			or BL, BL			;equivalente a comparar com zero (cmp BL, 0)
			FALHO_VALIDACAO:
			pop BX				;BX possui o contexto de página e cor
			jz LER_NOVAMENTE	;se BL = 0, lê novamente
		
		
		
		;Se chegou aqui é pq embarcação pode ser inserida na matriz
		push SI
		push BX
		push DX
		mov SI, offset matrizNavios
		cmp AL, 'H'
		mov AL, [DI]			;busca embarcação
		jnz INSERIR_VERTICAL	;se AL != 'H', então insere verticalmente
			call GRAVA_EMB_HORIZONTAL	;grava embarcação em AL com tamanho CL na posição AH na matriz em SI
			jmp FIM_INSERIR
		INSERIR_VERTICAL:
			call GRAVA_EMB_VERTICAL		;grava embarcação em AL com tamanho CL na posição AH na matriz em SI
		FIM_INSERIR:
			mov DH, 5	;linha
			mov DL, 30	;coluna
			call ESCREVE_MATRIZ_NAVIOS
		pop DX
		pop BX
		pop SI
		
		dec DH			;retorna uma linha
		sub DL, 6		;retornar colunas
		inc SI			;posiciona para pegar o tamanho da próxima embarcação
		inc DI			;posiciona para pegar a próxima embarcação
		pop CX
	loop LER_EMBARCACOES
	
	;Faz o backup da matriz, caso o jogador deseja reiniciar o jogo com a mesma configuração
	mov SI, offset matrizNavios
	mov DI, offset matrizNaviosBackup
	call COPIA_MATRIZ	;copia a "matriz" em SI para a matriz em DI
	
    pop DI
	pop SI 
    pop BX
    pop DX      
    pop BP
    ret
endp 


INICIO:	mov AX, @data ; carrega valor inicial da stack
	mov DS, AX
	mov ES, AX	;para poder utilizar a função 13h da int 10H
	mov AH, 00h ;Define um modo de vídeo
	mov AL, 03h ;código do modo desejado neste caso 80x25  8x8  texto 16 cores
    int 10h
	
	;mov AL, 1	;define o número da página
	;call MUDA_PAGINA
	;call PRINT_TELA_INICIO
	
	; chama prog ler S ou J  
	;call LER_CHAR_SJ
	
	mov AL, 2	;define o número da página
	call MUDA_PAGINA
	call PRINT_TELA_CONFIG
	call INSERE_BARCOS

	
	;mov AL, 3	;define o número da página
	;call MUDA_PAGINA
	;call PRINT_TELA_JOGO
	
	
	call LER_CHAR
	
	call SAIR_JOGO ; finaliza o jogo
end INICIO
