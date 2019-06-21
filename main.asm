.model small
.stack 100h
.data
	QUADRADO 				EQU 254 ;codigo do QUADRADO
    nomeJogo1 				db "Batalha"
    nomeJogo2 				db "Naval"
	textAutores				db "Autores:"
    nomeAnderson 			db "Anderson Imperatori"    
    nomeEduardo 			db "Eduardo Menzen"
    opJogar 				db "Jogar"
    opSair 					db "Sair"	
	stringNumeros			db "0123456789"
	tituloMatrizNavios 		db "Matriz de Navios"
	tituloMatrizTiros 		db "Matriz de Tiros"
	textConfig 				db "Digite a posicao do"
	textVoce           		db "Voce"
	textTiros          		db "Tiros:"
	textAcertos        		db "Acertos:" 
	textAfundados      		db "Afundados:"
	textComputador     		db "Computador:"
	textUltimoTiro     		db "Ultimo Tiro:"
	textPosicao				db "Posicao:"
	textMensagens			db "Mensagens:"
	textFimdeJogo       	db "   FIM DE JOGO   "
	textVoceGanhou      	db "   VOCE GANHOU   "
	textPCGanhou        	db "COMPUTADOR GANHOU" 
	textNumJogadas      	db "   XX Jogadas    "
	textNovoJogo      		db "    Novo Jogo    "
    textReiniciar       	db "    Reiniciar    "
	textSuaVez				db "      SUA VEZ!       "
	textAguardando			db "AGUARDANDO ADVERSARIO"
	textAcertouAlgo			db "    ACERTOU ALGO!    "
	textAcertouVazio		db "  NAO ACERTOU NADA!  "
	textVoceVenceu			db "    VOCE VENCEU!     "
	textVocePerdeu			db "    VOCE PERDEU!     "
	textPosicaoJaInf		db "POSICAO JA INFORMADA "
	vet_nome_embarcacoes	db " Porta Avioes  "     
							db "Navio de Guerra"
							db "   Submarino   "
							db "   Destroyer   "
							db "Barco Patrulha "
	vet_tam_embarcacoes		db 05,04,03,03,02		;contém o tamanho de cada embarcação
	vet_Navios				db 'A','B','S','D','P'	;contém o nome de cada embarcação
	matrizNavios 			db 100 dup(?)
	matrizNaviosPC 			db 100 dup(?)
	matrizNaviosBackup 		db 100 dup(?)
	varDelay				dw   1 dup(?)
	;0=tiros, 1=acertos, 2=afundados (0:2 - Jogador):3=tiros, 4=acertos, 5=afundados 6=ultimo tiro(3:6 - Computador)	
	vet_Resultados			db   7 dup(?)
	vet_embarcacoes_jogador	db 05,04,03,03,02	;vetor com o tamanho das embarcações do jogador
	vet_embarcacoes_PC		db 05,04,03,03,02	;vetor com o tamanho das embarcações do computador
	
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

BUSCA_TICKS proc
    push CX
    push DX
	mov AH, 00H ;código da operação para ler o contador de clocks do sistema
	int 1AH     ;interupção que lê o número de clocks. CX:DX => número de pulsos de clock desde a meia-noite ]
				;CX fica a parte alta e DX a parte baixa
    mov AL, DL  ;utilizaremos a parte mais baixa do DX, pois se altera com mais frequência
    pop DX
    pop CX
    ret
endp

GERA_POSICAO proc	;para gerar numeros aleátorios de 0 a 99 e devolve em AH
    push BX
	push CX
    push DX
	
	call BUSCA_TICKS
	mov BL, 7	;multiplicador (0 < a < m)
	mul BL		;AX <- AL*BL
	mov BX, 1   ;incremento (0 <= c < m)
	add AX, BX
	mov BL, 100	;para gerar de 0 a 99 (0 a m-1)
	div BL		;AL:AH <- AX/BL (quociente:resto)
	
    pop DX
    pop CX
	pop BX
    ret
endp

GERA_DIRECAO proc	;para gerar direção aleátoria devolvento V ou H em AL
	push BX
    push CX
    push DX
	
	mov BH, AH	;salva valor de AH
	push BX
	call BUSCA_TICKS
	mov BL, 1	;multiplicador (0 < a < m)
	mul BL		;AX <- AL*BL
	mov BX, 1   ;incremento (0 <= c < m)
	add AX, BX
	mov BL, 2	;para gerar de 0 a 1 (0 a m-1)
	div BL		;AL:AH <- AX/BL (quociente:resto)
	
	cmp AH, 0
	JZ  DIR_HORIZONTAL
	mov AL, 'V'
	jmp FIM_GERA_DIRECAO
	
	DIR_HORIZONTAL:
	mov AL, 'H'
	
	FIM_GERA_DIRECAO:
	pop BX
	mov AH, BH	;retorna valor de AH
	
    pop DX
    pop CX
	pop BX
    ret
endp

DELAY proc ;para gerar um delay de 1 segundo
    push AX
	push CX
	push DX	
	push SI
	
	mov AH, 00H		;retorna a contagem de clock CX:DX (parte alta : parte baixa)
	int	1AH
	mov SI, offset varDelay
	mov [SI], DX	
	LOOPDELAY:
		mov AH, 00H
		int	1AH
		sub DX, [SI]
		cmp DX,18
		ja FIM
	jmp LOOPDELAY
	FIM:
	
	pop SI	
	pop DX
	pop CX
    pop AX     ; restaura o reg AX
    ret  
endp

DELAY3 proc ;para gerar um delay de 3 segundos
    push AX
	push CX
	push DX	
	push SI
	
	mov AH, 00H		;retorna a contagem de clock CX:DX (parte alta : parte baixa)
	int	1AH
	mov SI, offset varDelay
	mov [SI], DX	
	LOOPDELAY3:
		mov AH, 00H
		int	1AH
		sub DX, [SI]
		cmp DX,54
		ja FIM3
	jmp LOOPDELAY3
	FIM3:
	
	pop SI	
	pop DX
	pop CX
    pop AX     ; restaura o reg AX
    ret  
endp

DELAY5 proc ;para gerar um delay de 3 segundos
    push AX
	push CX
	push DX	
	push SI
	
	mov AH, 00H		;retorna a contagem de clock CX:DX (parte alta : parte baixa)
	int	1AH
	mov SI, offset varDelay
	mov [SI], DX	
	LOOPDELAY5:
		mov AH, 00H
		int	1AH
		sub DX, [SI]
		cmp DX,90
		ja FIM5
	jmp LOOPDELAY5
	FIM5:
	
	pop SI	
	pop DX
	pop CX
    pop AX     ; restaura o reg AX
    ret  
endp

LER_CHAR proc ; ler um caractere sem echo em AL (nao mostra na tela)
    mov AH, 07H
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

DEFINE_MODO_VIDEO proc ;define o modo de video
	push AX
		mov AH, 00h ;Define um modo de vídeo
		mov AL, 03h ;código do modo desejado neste caso 80x25  8x8  texto 16 cores
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
	mov BP, offset textConfig
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
			mov AL, QUADRADO	;quadrado
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
	;TODO: ALTERA DEPOIS PARA A SITUAÇÃO ABAIXO*****
	PUSH DX
	MOV DH, 5
	MOV DL, 3
	mov SI, offset matrizNaviosPC
	call ESCREVE_MATRIZ_NAVIOS
	POP DX
	;TODO************
	;call PRINT_QUADRADOS_VERDES
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
	mov BP, offset textVoce
	call ESC_STRING
	
	add DH, 4	;linha
	dec DL  	;coluna
	call PRINT_LINHA_CENTRAL
	
	inc DH  	;linha
	inc DL  	;coluna
	mov CX, 11	;tamanho da string
	mov BP, offset textComputador
	call ESC_STRING	
	
	sub DH, 6    ;linha
	add DL, 3 	;coluna
	mov CX, 2	
	LACO:
		push CX
		add DH,2  	;linha
		mov CX, 6	;tamanho da string
		mov BP, offset textTiros
		call ESC_STRING
		inc DH  	;linha
		mov CX, 8	;tamanho da string
		mov BP, offset textAcertos
		call ESC_STRING
		inc DH  	;linha
		mov CX, 10	;tamanho da string
		mov BP, offset textAfundados
		call ESC_STRING
		inc DH
		pop CX
	loop LACO
	mov CX, 12	;tamanho da string
	mov BP, offset textUltimoTiro
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
    
	mov DH, 5	;linha
	mov DL, 27	;coluna
	mov SI, offset matrizNavios
	call ESCREVE_MATRIZ_NAVIOS
	call ATUALIZA_RESULTADOS	;escreve resultados na tela de placar
	
	DESEMPILHATUDO
	ret
endp

PRINT_TELA_FINAL proc     
    push AX
	push BX
	push CX
	push DX
	push SI
	push BP
	
	mov BH, 4	;define o numero da pagina
	mov DH, 1	;linha inicial
	mov DL, 28 	;coluna inicial
	mov BL, 7 	;cor: cinza claro
	mov CX, 14  ;altura da retângulo
	mov AX, 21  ;largura da retângulo
	call PRINT_RETANGULO 
		
	;texto Fim de Jogo 	
	inc DH   ;linha	
	add DL, 3   ;coluna
	mov CX, 17 	;tamanho da string
	mov BP, offset textFimdeJogo
	call ESC_STRING 
	
	;texto de quem ganhou passado pelo SI
	mov BL, 4   ;cor: vermelha
	add DH, 3	 ;linha
	mov BP, SI	
	call ESC_STRING 
	
	;texto Numero de Jogadas
	mov BL, 7 	;cor: cinza claro
	add DH, 3	;linha	
	mov BP, offset textNumJogadas
	call ESC_STRING 
	
	;texto Reinciar
	mov BL, 1   ;cor: azul
	add DH, 4	;linha
	mov BP, offset textReiniciar
	call ESC_STRING 	
	
	;texto Novo Jogo
	mov BL, 2   ;cor: verde
	add DH, 2	;linha	
	mov BP, offset textNovoJogo
	call ESC_STRING 
	
	pop BP
	pop SI
	pop DX
	pop CX
	pop BX
	pop AX
	ret 
endp


LER_DIRECAO proc ;realiza a leitura da direção devolvendo o valor em AL
    push CX
	push DX
	
	add DL,2	;coluna
	mov CH, AH	;salva o valor em CH
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
    ret
endp 


LER_POSICAO proc ;realiza a leitura da posição devolvendo o valor em AH
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
		
	mov AH, AL	;retorna o valor da posição em AH
			
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
	
	VALIDACOES:
		mov BL, 1			;seta posição como válida
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
	push DI
	
	xor CH, CH			;zera parte alta do CX, pois recebe o tamanho em CL
	xor BX, BX			;limpa BX
	mov BL, AH			;copia a posição para BX
	cmp AL, 'H'			;verifica se é horizontal
	jnz VERTICAL2		;se não é horizontal vai para a validação vertical
		HORIZONTAL:
			cmp byte ptr [DI+BX], 0	;define que deve ser trazido apenas 1 byte para a comparação
			jnz	POSICAO_OCUPADA
			inc BX
		loop HORIZONTAL
		jmp POSICAO_VALIDA	;se chegou aqui é pq a posição está livre
		
	VERTICAL2:
		cmp byte ptr [DI+BX], 0	;define que deve ser trazido apenas 1 byte para a comparação
		jnz	POSICAO_OCUPADA
		add BX,10
	loop VERTICAL2
	
	POSICAO_VALIDA:
		mov BL, 1		;a posição não está ocupada (pode inserir)
		jmp FIM_VALIDA_POS
	POSICAO_OCUPADA:
		xor BL, BL		;a posição está ocupada (não pode inserir)
	
	FIM_VALIDA_POS:
	
	pop DI
	pop CX
	pop AX
	ret
endp

ZERA_MATRIZ proc ;copia valor de AX para a "matriz" em DI
	push AX
	push CX
	push DI
	xor AX, AX	;zera AX
	mov CX, 50
	ZERA:
		stosw	;[ES:DI] <- AX add DI,2
		loop ZERA
	pop DI
	pop CX
	pop AX
	ret
endp

COPIA_MATRIZ proc ;copia a "matriz" em SI para outra "matriz" em DI
	push CX
	push SI
	push DI
	mov CX, 50
	COPIA:
		movsw	;[ES:DI] <- [DS:SI] add SI,2 e add DI,2
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

ESCREVE_MATRIZ_NAVIOS proc ;escreve matriz em SI na posição DH:DL linha:coluna
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

INSERE_BARCOS_JOGADOR proc ;insere os barcos na matriz de Navios e escreve na tela      
    push BP        
    push DX     
    push BX
	push SI
	push DI
    
    mov BH, 2		;pagina 
    mov BL, 7 	    ;cor: cinza claro 
	mov DH, 5		;linha
	mov DL, 30		;coluna
	mov DI, offset matrizNavios
	call ZERA_MATRIZ;zera a matriz no caso de um novo jogo
	mov SI, DI
	call ESCREVE_MATRIZ_NAVIOS	;para limpar a tela no caso de um novo jogo
    mov DH, 18      ;linha
    mov DL, 32      ;coluna           

    ;LE POSIÇÃO EMBARCAÇÕES
	mov CX, 5	;são 5 embarcações
	mov BP, offset vet_nome_embarcacoes
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
			call LER_POSICAO;devolve o valor da posição em AH
			call LER_DIRECAO;devolve a direção (V ou H) em AL
			call DELAY
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

INSERE_BARCOS_COMPUTADOR proc ;insere os barcos na matriz de Navios do Computador           
    push BP        
    push DX     
    push BX
	push SI
	push DI
    
	mov DI, offset matrizNaviosPC
	call ZERA_MATRIZ;zera a matriz no caso de um novo jogo

	mov CX, 5	;são 5 embarcações
	mov SI, offset vet_tam_embarcacoes
	mov BP, offset vet_Navios
	
	LER_EMBARCACOES2:
		push CX
		GERAR_NOVAMENTE:
			call GERA_POSICAO;devolve a posição em AH
			call GERA_DIRECAO;devolve a direção (V ou H) em AL
			mov CL, [SI]	;busca o tamanho da embarcação
				call VALIDA_LIMITE_MATRIZ ;verifica posição dentro dos limites da matriz devolvendo se é é valida (BL = 1) ou não (BL = 0)
				or BL, BL			;equivalente a comparar com zero (cmp BL, 0)
				jz FALHO_VALIDACAO2	;se a posição não é valida não realiza a segunda validação
				mov DI, offset matrizNaviosPC
				call VALIDA_POSICAO ;verifica se a posição já está ocupada
			or BL, BL			;equivalente a comparar com zero (cmp BL, 0)
			FALHO_VALIDACAO2:
			jz GERAR_NOVAMENTE	;se BL = 0, lê novamente
		
		;Se chegou aqui é pq embarcação pode ser inserida na matriz		
		push SI
		mov SI, offset matrizNaviosPC
		cmp AL, 'H'
		mov AL, DS:[BP]			;busca embarcação
		jnz INSERIR_VERTICAL2	;se AL != 'H', então insere verticalmente
			call GRAVA_EMB_HORIZONTAL	;grava embarcação em AL com tamanho CL na posição AH na matriz em SI
			jmp FIM_INSERIR2
		INSERIR_VERTICAL2:
			call GRAVA_EMB_VERTICAL		;grava embarcação em AL com tamanho CL na posição AH na matriz em SI
		FIM_INSERIR2:
		pop SI
		
		inc SI			;posiciona para pegar o tamanho da próxima embarcação
		inc BP			;posiciona para pegar a próxima embarcação
		pop CX
	loop LER_EMBARCACOES2
		
    pop DI
	pop SI 
    pop BX
    pop DX      
    pop BP
    ret
endp

DETERMINA_POSICAO proc ;recebe a posição em AH e retorna a linha em DH e a coluna em DL
	push AX
	push BX

	xor BX, BX
	mov AL, AH		;move a posição para AL
	xor AH, AH		;zera a parte alta de AX
	mov BL, 10		;divisor
	div BL			;AH:AL <- AX/BL (resto:divisão)
	mov DL, AH		;salva a coluna
	mov DH, AL		;salva a linha
	shl DL, 1		;equivalente a multiplicar por 2
	
	pop BX
	pop AX
	ret
endp

ESCREVE_MENSAGENS proc	;Escreve as mensagens durante o jogo, recebendo a cor em BL e o endereço da string em BP
	push BX
	push CX
	push DX
	push BP

	mov BH, 3	;seta página
	mov DH, 19	;linha
	mov DL, 36	;coluna
	mov CX, 21	;tamanho da string
	call ESC_STRING	;escreve string iniciada em ES:BP, comprimento CX, BH: número da página, DH: linha, DL: coluna, BL: cor
	
	pop BP
	pop DX
	pop CX
	pop BX	
	ret
endp

LIMPA_CURSOR_POSICAO proc	;para limpar os caracteres na digitação das posições
	push AX
	push BX
	push CX
	
	mov BH, 3	;seta página
	mov DH, 18	;linha
	mov DL, 11	;coluna
	call MOV_CURSOR
	mov CX, 3
	mov AL, 00		;para limpar o texto no cursor
	call ESC_CHAR_10	
	
	pop CX
	pop BX
	pop AX
	ret
endp

ESC_PLACAR proc	;escreve números no placar recebe valor em AL, linha em DH e coluna em DL
	push AX
	push BX
	push CX
	push DX
	
	xor BX, BX
	mov BL, 10	;seta divisor
	div BL		;AL:AH (quociente:resto)
	mov BH, 3	;define o numero da página
	mov BL, 7 	;cor: cinza claro
	call MOV_CURSOR
	mov CX, 1
	add AL, '0'	
	call ESC_CHAR_10	;escreve caracter de AL, BL: cor, BH: número da página, CX: repetições
	inc DL
	call MOV_CURSOR
	mov AL, AH
	add AL, '0'	
	call ESC_CHAR_10	;escreve caracter de AL, BL: cor, BH: número da página, CX: repetições
	
	pop DX
	pop CX
	pop BX
	pop AX
	ret
endp

ATUALIZA_RESULTADOS proc	;atualiza os resultados na tela de placar
	push AX
	push BX
	push CX
	push DX
	push SI
	
	mov SI, offset vet_Resultados
	xor AX, AX	;zera acumulador
	mov DH, 5	;linha inicial
	mov DL, 67 	;coluna inicial
	mov CX, 3
	ATU_LACO1:
		lodsb		;AL <- DS:SI e inc SI
		call ESC_PLACAR
		inc DH		;incremente linha
	loop ATU_LACO1
	
	add DH, 2
	mov CX, 4
	ATU_LACO2:
		lodsb		;AL <- DS:SI e inc SI
		call ESC_PLACAR
		inc DH		;incremente linha
	loop ATU_LACO2
	
	pop SI
	pop DX
	pop CX
	pop BX
	pop AX
	ret
endp

TIRO_JOGADOR proc	;realiza a leitura do tiro do jogador verificando o mesmo
    push BX
    push CX
    push DX
    push SI
    push DI
    push BP
	
	mov DI, offset vet_Resultados
		
	REINICIAR_JOGADA:
		mov BP, offset textSuaVez
		mov BL, 2	;cor: verde
		call ESCREVE_MENSAGENS	;Escreve as mensagens durante o jogo, recebendo a cor em BL e o endereço da string em BP
		
		mov BH, 3	;seta página
		mov BL, 7	;cor: cinza claro
		mov DH, 18	;linha
		mov DL, 11	;coluna
		call LER_POSICAO	;devolve a posição em AH
		call DELAY
	
		mov SI, offset matrizNaviosPC
		xor BX, BX
		mov BL, AH		;grava a posição em BL
		call DETERMINA_POSICAO	;recebe a posição em AH e retorna a linha em DH e a coluna em DL
		add DH, 5		;corrige linha
		add DL, 4 		;corrige coluna
		mov CX, 1		;para escrever apenas uma vez o caractere
		
		mov AL, [SI+BX]	;move o conteúdo da matriz para AL
		or AL, AL		;equivalente a compara com zero
		jz	ACERTOU_VAZIO
		cmp AL, 'A'
		jz	ACERTOU_PORTA_AVIOES
		cmp AL, 'B'
		jz	ACERTOU_NAVIO_GUERRA
		cmp AL, 'S'
		jz	ACERTOU_SUBMARINO
		cmp AL, 'D'
		jz	ACERTOU_DESTROYER
		cmp AL, 'P'
		jz	ACERTOU_BARCO_PATRULHA
		jmp MESMA_JOGADA
	
	ACERTOU_VAZIO:	
		jmp ESCREVE_X
	ACERTOU_PORTA_AVIOES:
		mov SI, offset vet_embarcacoes_PC
		dec byte ptr[SI]	;decrementa o tamanho da embarcação do computador para saber quando afundou
		jz  AFUNDOU_EMBARCACAO
		jmp ESCREVE_BOLINHA
	ACERTOU_NAVIO_GUERRA:
		mov SI, offset vet_embarcacoes_PC
		dec byte ptr[SI+1]
		jz  AFUNDOU_EMBARCACAO
		jmp ESCREVE_BOLINHA
	ACERTOU_SUBMARINO:
		mov SI, offset vet_embarcacoes_PC
		dec byte ptr[SI+2]
		jz  AFUNDOU_EMBARCACAO
		jmp ESCREVE_BOLINHA
	ACERTOU_DESTROYER:
		mov SI, offset vet_embarcacoes_PC
		dec byte ptr[SI+3]
		jz  AFUNDOU_EMBARCACAO
		jmp ESCREVE_BOLINHA
	ACERTOU_BARCO_PATRULHA:
		mov SI, offset vet_embarcacoes_PC
		dec byte ptr[SI+4]
		jz  AFUNDOU_EMBARCACAO
		
		
		
		jmp ESCREVE_BOLINHA
	MESMA_JOGADA:
		call LIMPA_CURSOR_POSICAO
		mov BP, offset textPosicaoJaInf
		mov BL, 4	;cor: vermelha
		call ESCREVE_MENSAGENS	;Escreve as mensagens durante o jogo, recebendo a cor em BL e o endereço da string em BP
		;call DELAY3
		jmp REINICIAR_JOGADA
	
	ESCREVE_X:
		mov SI, offset matrizNaviosPC
		mov AL, 'x'
		mov byte ptr[SI+BX], AL
		mov BH, 3	;página
		mov BL, 4	;cor: vermelha
		call MOV_CURSOR
		call ESC_CHAR_10
		call LIMPA_CURSOR_POSICAO
		mov BP, offset textAcertouVazio		
	jmp FIM_VERIFICA
		
	AFUNDOU_EMBARCACAO:
		inc byte ptr[DI+5]		;incrementa o número de embarcações afundadas do computador 
	ESCREVE_BOLINHA:
		mov SI, offset matrizNaviosPC
		mov AL, 'o'
		mov byte ptr[SI+BX], AL
		mov BH, 3	;página
		mov BL, 2	;cor: verde
		call MOV_CURSOR
		call ESC_CHAR_10
		call LIMPA_CURSOR_POSICAO
		mov BP, offset textAcertouAlgo
		inc byte ptr[DI+1]	;incrementa o número de acertos do jogador
	jmp FIM_VERIFICA	
		
	FIM_VERIFICA:
	inc byte ptr[DI]	;incrementa o número de tiros do jogador
	call ATUALIZA_RESULTADOS
	mov BL, 4		;cor: vermelha
	call ESCREVE_MENSAGENS	;Escreve as mensagens durante o jogo, recebendo a cor em BL e o endereço da string em BP
	;call DELAY3
	cmp byte ptr[DI+5], 5	;quando chegar a 5 é porque afundou todas as embarcações do computador
	jnz FIM_JOGADA_JOGADOR
	mov BP, offset textVoceVenceu
	call ESCREVE_MENSAGENS	;Escreve as mensagens durante o jogo, recebendo a cor em BL e o endereço da string em BP
	;call DELAY5
	jmp  FIM_JOGO
	
	
	FIM_JOGADA_JOGADOR:
	mov BP, offset textAguardando
	call ESCREVE_MENSAGENS	;Escreve as mensagens durante o jogo, recebendo a cor em BL e o endereço da string em BP
	;call DELAY3
	xor AX, AX	;zera AX, para indicar que o jogo não chegou ao fim
	jmp FINAL
	
	FIM_JOGO:
	mov AX, 1	;seta AX, para informar o fim do jogo
	FINAL:
	
	pop BP
    pop DI
    pop SI
    pop DX
    pop CX
    pop BX
	ret
endp

VERIFICA_MESMA_LINHA_COLUNA proc ;recebe posição do último tiro em BH e verifica se a posição estratégica em AL está na mesma linha
	push AX				  ;devolve em BX, se pertence ou não pertence à mesma linha (BL=1 ou BL=0) e se pertence ou não pertence à mesma coluna (BH=1 ou BH=0)
	push DX
	mov BL, 10	;seta divisor
	xor AH, AH	;zera parte alta de AX
	div BL		;AL:AH <- AX/BL (quociente:resto)
	mov DX, AX	;salva resultado em DX (DL: linha e DH: coluna da posição estratégica)
	xor AX, AX
	mov AL, BH	;busca a posição do último tiro
	div BL		;AL:AH <- AX/BL (quociente:resto) (AL: linha e AH: coluna da posição do último tiro)
	
	xor BX, BX	;seta BX para informar que nao pertence a mesma linha ou coluna
	cmp AL, DL
	jnz TESTA_COLUNA
	mov BL, 1	
  TESTA_COLUNA:
	cmp AH, DH
	jnz FIM_TESTE
	mov BH, 1
	
	FIM_TESTE:
	
	pop DX
	pop AX
	ret
endp

GERA_POSICAO_ESTRATEGICA proc ;método para gerar posições estratégicamente para o computador
;devolve em AL: 0 se tem que gerar uma nova posição ou 1 se deve considerar a posição retornada em AH
	push BX
	push SI
	
	xor AX, AX
	mov AL, byte ptr[DI+6]	;busca a posição do último tiro
	mov BH, AL				;salva a posição do último tiro
	add SI, AX	;adiciona a posição do último tiro ao índice da matriz
	cmp byte ptr[SI], 'o';verifica se foi um tiro certeiro
	jz	VER_DIREITA
	jmp	VER_ESQUERDA_ERRO	;se não foi um tiro certeiro, acertou o vazio
	
	VER_DIREITA:		
		cmp byte ptr[SI+1], 'o';verifica se a posição à direita já foi atingida
		jz VER_ESQUERDA_ACERTO
		cmp byte ptr[SI+1], QUADRADO;verifica se a posição à direita já foi atingida
		jz VER_ESQUERDA
		inc AL
		call VERIFICA_MESMA_LINHA_COLUNA
		or BL, BL		;verifica se a nova posição está na mesma linha do último tiro
		jz GERA_NOVA	;se não estiver, deve gerar uma nova posição aleátoria
		jmp FIM_GERA
	
	VER_ESQUERDA_ERRO:
		dec AL	;se a posição à esquerda não foi atingida.. retorna a mesma para o próximo tiro
		dec SI
		cmp byte ptr[SI], 'o'		;verifica se a posição à esquerda já foi atingida
		jz VER_ESQUERDA_ACERTO
		jmp GERA_NOVA
	
	VER_ESQUERDA:
		dec AL	;se a posição à esquerda não foi atingida.. retorna a mesma para o próximo tiro
		dec SI
		cmp byte ptr[SI], 'o'		;verifica se a posição à esquerda já foi atingida
		jz VER_ESQUERDA_ACERTO
		cmp byte ptr[SI], QUADRADO	;verifica se a posição à esquerda já foi atingida numa posição vazia
		jz VER_ACIMA		;verifica na direção vertical
		call VERIFICA_MESMA_LINHA_COLUNA
		or BL, BL		;verifica se a nova posição está na mesma linha do último tiro
		jz GERA_NOVA	;se não estiver, deve gerar uma nova posição aleátoria
		jmp FIM_GERA
	
	VER_ESQUERDA_ACERTO:
		dec AL	;se a posição à esquerda não foi atingida.. retorna a mesma para o próximo tiro
		dec SI
		cmp byte ptr[SI], 'o'		;verifica se a posição à esquerda já foi atingida
		jz VER_ESQUERDA_ACERTO
		cmp byte ptr[SI], QUADRADO
		jz VER_ACIMA
		jmp FIM_GERA
		
	VER_ACIMA:		
		inc AL
		inc SI
	VER_ACIMA2:
		sub AL, 10
		sub SI, 10
		cmp byte ptr[SI], 'o'
		jz VER_ACIMA2
		cmp byte ptr[SI], QUADRADO
		jz VER_ABAIXO
		call VERIFICA_MESMA_LINHA_COLUNA
		or BH, BH		;verifica se a nova posição está na mesma coluna do último tiro
		jz GERA_NOVA	;se não estiver, deve gerar uma nova posição aleátoria
		jmp FIM_GERA
		
	VER_ABAIXO:
		add AL, 10
		add SI, 10
	VER_ABAIXO2:	
		add AL, 10
		add SI, 10
		cmp byte ptr[SI], 'o'
		jz VER_ABAIXO2
		cmp byte ptr[SI], QUADRADO
		jz GERA_NOVA
		call VERIFICA_MESMA_LINHA_COLUNA
		or BH, BH		;verifica se a nova posição está na mesma coluna do último tiro
		jz GERA_NOVA	;se não estiver, deve gerar uma nova posição aleátoria
		jmp FIM_GERA
		
	GERA_NOVA:
		xor AX, AX	;informa que deverá gerar uma nova posição aleátoria
		jmp FINAL_GERA
	FIM_GERA:	;verifica se a posição está dentro dos limites da matriz
		cmp AL, 0
		jl	GERA_NOVA	;salta se AL < 0 levando em consideração o sinal
		cmp AL, 99		
		ja  GERA_NOVA	;salta se AL > 99 sem levar em consideração o sinal
		mov AH, AL
		mov AL, 1
	FINAL_GERA:
	
	pop SI
	pop BX
	ret
endp

TIRO_COMPUTADOR proc ;gera tiro computador e verifica o mesmo
    push BX
    push CX
    push DX
    push SI
    push DI
    push BP
	
	mov DI, offset vet_Resultados
	
	REINICIAR_JOGADA2:
		mov SI, offset matrizNavios
		call GERA_POSICAO_ESTRATEGICA
		or AL, AL
		jz GERAR_POS
		jmp CONTINUAR
		
		GERAR_POS:
		call GERA_POSICAO	;devolve a posição em AH
		CONTINUAR:
		xor BX, BX
		mov BL, AH			;grava a posição em BL para usar como base posteriormente
		mov [DI+6],	BL		;salva a posição do último tiro do computador
		call DETERMINA_POSICAO	;recebe a posição em AH e retorna a linha em DH e a coluna em DL
		add DH, 5		;corrige linha
		add DL, 28 		;corrige coluna
		mov CX, 1		;para escrever apenas uma vez o caractere
		
		mov AL, [SI+BX]	;move o conteúdo da matriz para AL
		or AL, AL		;equivalente a compara com zero
		jz	ACERTOU_VAZIO2
		cmp AL, 'A'
		jz	ACERTOU_PORTA_AVIOES2
		cmp AL, 'B'
		jz	ACERTOU_NAVIO_GUERRA2
		cmp AL, 'S'
		jz	ACERTOU_SUBMARINO2
		cmp AL, 'D'
		jz	ACERTOU_DESTROYER2
		cmp AL, 'P'
		jz	ACERTOU_BARCO_PATRULHA2
		jmp MESMA_JOGADA2
	
	ACERTOU_VAZIO2:	
		jmp ESCREVE_QUADRADO
	ACERTOU_PORTA_AVIOES2:
		mov AL, 'A'
		mov SI, offset vet_embarcacoes_jogador
		dec byte ptr[SI]	;decrementa o tamanho da embarcação do jogador para saber quando afundou
		jz  AFUNDOU_EMBARCACAO2
		jmp ESCREVE_LETRA
	ACERTOU_NAVIO_GUERRA2:
		mov AL, 'B'
		mov SI, offset vet_embarcacoes_jogador
		dec byte ptr[SI+1]	;decrementa o tamanho da embarcação do jogador para saber quando afundou
		jz  AFUNDOU_EMBARCACAO2
		jmp ESCREVE_LETRA
	ACERTOU_SUBMARINO2:
		mov AL, 'S'
		mov SI, offset vet_embarcacoes_jogador
		dec byte ptr[SI+2]	;decrementa o tamanho da embarcação do jogador para saber quando afundou
		jz  AFUNDOU_EMBARCACAO2
		jmp ESCREVE_LETRA
	ACERTOU_DESTROYER2:
		mov AL, 'D'
		mov SI, offset vet_embarcacoes_jogador
		dec byte ptr[SI+3]	;decrementa o tamanho da embarcação do jogador para saber quando afundou
		jz  AFUNDOU_EMBARCACAO2
		jmp ESCREVE_LETRA
	ACERTOU_BARCO_PATRULHA2:
		mov AL, 'P'
		mov SI, offset vet_embarcacoes_jogador
		dec byte ptr[SI+4]	;decrementa o tamanho da embarcação do jogador para saber quando afundou
		jz  AFUNDOU_EMBARCACAO2
		jmp ESCREVE_LETRA
	MESMA_JOGADA2:
		jmp REINICIAR_JOGADA2
	
	ESCREVE_QUADRADO:
		mov SI, offset matrizNavios
		mov AL, QUADRADO	;quadrado
		mov byte ptr[SI+BX], AL
		mov BH, 3	;página
		mov BL, 4	;cor: vermelha
		call MOV_CURSOR
		call ESC_CHAR_10
	jmp FIM_VERIFICA2
	
	AFUNDOU_EMBARCACAO2:
		inc byte ptr[DI+2]	;incrementa o número de embarcações afundadas do jogador
	ESCREVE_LETRA:
		mov SI, offset matrizNavios
		push BX		;salva a posição
		mov BH, 3	;página
		mov BL, 4	;cor: vermelha
		call MOV_CURSOR
		call ESC_CHAR_10
		pop BX
		mov AL, 'o'
		mov byte ptr[SI+BX], AL
		inc byte ptr[DI+4]	;incrementa o número de acertos do computador
	jmp FIM_VERIFICA2	
		
	FIM_VERIFICA2:
	inc byte ptr[DI+3]	;incrementa o número de tiros do computador
	call ATUALIZA_RESULTADOS
	cmp byte ptr[DI+2], 5	;quando chegar a 5 é porque afundou todas as embarcações do jogador
	jnz FIM_JOGADA_COMPUTADOR
	mov BP, offset textVocePerdeu
	call ESCREVE_MENSAGENS	;Escreve as mensagens durante o jogo, recebendo a cor em BL e o endereço da string em BP
	;call DELAY5
	jmp  FIM_JOGO2
	
	
	FIM_JOGADA_COMPUTADOR:
	xor AX, AX	;zera AX, para indicar que o jogo não chegou ao fim
	jmp FINAL2
	
	FIM_JOGO2:
	mov AX, 2	;seta AX, para informar o fim do jogo
	FINAL2:
		
	pop BP
    pop DI
    pop SI
    pop DX
    pop CX
    pop BX
	ret
endp

REINICIAR_CONTADORES proc	;zera contadores no caso de reinicio ou novo jogo
	push AX
	push CX
	push DI
	
	mov DI, offset vet_Resultados
	mov CX, 7
	mov AL, 0
	ZERA_VET:	;para zerar o vetor de resultados
		stosb	;ES:DI <- AL e decrementa DI
	loop ZERA_VET
	
	mov SI, offset vet_tam_embarcacoes
	mov DI, offset vet_embarcacoes_jogador
	mov CX, 5
	ZERA_VET2:	;reconfigura o tamanho das embarcações do jogador para saber quando afundam
		movsb	;ES:DI <- DS:SI e inc SI e DI
	loop ZERA_VET2

	mov SI, offset vet_tam_embarcacoes
	mov DI, offset vet_embarcacoes_PC
	mov CX, 5
	ZERA_VET3:	;reconfigura o tamanho das embarcações do computador para saber quando afundam
		movsb	;ES:DI <- DS:SI e inc SI e DI
	loop ZERA_VET3	
	
	pop DI
	pop CX
	pop AX
	ret
endp

MENSAGENS_TELA_FIM proc	;recebe quem ganhou em AX, devolve em SI a mensagem certa
	push AX
	push BX
	push DI
	
	xor BX, BX
	mov BX, 10	;seta divisor
	mov SI, offset vet_Resultados	;busca o offset do vetor de resultados
	mov DI, offset textNumJogadas	;busca o offset do texto de jogadas
	
	cmp AX, 1			;se o valor de AX for 1 é pq o jogador ganhou senão será o computador
	jz JOGADOR_GANHOU
	xor AX, AX
	mov AL, [SI+3]		;busca número de jogadas do computador
	mov SI, offset textPCGanhou
	jmp FIM_MENSAGEM
	
  JOGADOR_GANHOU:
	xor AX, AX
	mov AL, [SI]		;busca número de jogadas do jogador	
	mov SI, offset textVoceGanhou
	
  FIM_MENSAGEM:
	div BL	;AL:AH <- AX/BL (quociente:resto)
	add AL, '0'	;transforma em char
	add AH, '0'	;transforma em char
	mov byte ptr[DI+3], AL
	mov byte ptr[DI+4], AH
  
	pop DI
	pop BX
	pop AX
	ret
endp

INICIO:	mov AX, @data ; carrega valor inicial da stack
	mov DS, AX
	mov ES, AX	;para poder utilizar a função 13h da int 10H
	
	call DEFINE_MODO_VIDEO
	NOVO_JOGO:
	mov AL, 1	;define o número da página
	call MUDA_PAGINA
	call PRINT_TELA_INICIO
    
	LER_OPCAO_INICIO:
		call LER_CHAR
		cmp AL, 'S'
		jz SAIR      
		cmp AL, 'J'
    jnz LER_OPCAO_INICIO
	
	mov AL, 2	;define o número da página
	call MUDA_PAGINA
	call PRINT_TELA_CONFIG
	call INSERE_BARCOS_JOGADOR
	jmp NOVA_JOGADA		;neste caso esta iniciando uma nova partida

	REINICIAR:			;neste caso o jogador mantem a sua configuração inicial
	mov SI, offset matrizNaviosBackup
	mov DI, offset matrizNavios
	call COPIA_MATRIZ	;copia a "matriz" em SI para a matriz em DI

	NOVA_JOGADA:
	mov AL, 0	;define o número da página
	call MUDA_PAGINA
	call DEFINE_MODO_VIDEO	;ao definir um novo modo de video, limpa as telas	
	
	mov AL, 3	;define o número da página
	call MUDA_PAGINA
	call INSERE_BARCOS_COMPUTADOR	;gera posições das embarcações do computador
	call REINICIAR_CONTADORES
	
	;mov BH, 3	;seta página
	;mov BL, 7	;cor: cinza claro
	call PRINT_TELA_JOGO
	EVOLUCAO_JOGO:
		xor AX, AX		;zera AX
		call TIRO_JOGADOR
		or AX, AX		;testa se já terminou o jogo
		jnz TELA_FIM		
		call TIRO_COMPUTADOR
		or AX, AX		;testa se já terminou o jogo
		jnz TELA_FIM	
	jmp EVOLUCAO_JOGO

	TELA_FIM:
	call MENSAGENS_TELA_FIM
	mov AL, 4				;define o número da página
	call MUDA_PAGINA                
	call PRINT_TELA_FINAL
	LER_OPCAO_FIM:
		call LER_CHAR
		cmp AL, 'R'
		jz REINICIAR      
		cmp AL, 'N'
		jz NOVO_JOGO		;vai para  tela inicial
    jnz LER_OPCAO_FIM
	
	SAIR:
	call SAIR_JOGO ; finaliza o jogo
end INICIO
