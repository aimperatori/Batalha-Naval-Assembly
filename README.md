# Batalha Naval em Assembly

## PROBLEMA 
Desenvolver um programa em Assembly do 8086 que realize o jogo Batalha Naval entre dois jogadores (o segundo jogador é o programa). Batalha Naval é um jogo para dois jogadores cujo objetivo é afundar os navios (de diferentes tamanhos) do adversário, os quais são dispostos em uma matriz (tipicamente 10 x 10). Cada linha da matriz é identificada por um número e cada coluna por uma letra. A cada jogada, uma coordenada é fornecida para o adversário a fim de que o mesmo verifique e diga se acertou algo. Ao jogador que enviou a coordenada registra esta informação em uma segunda matriz de tiros. O jogo termina quando um dos jogadores afunda todas as embarcações dos demais adversários.

## REQUISITOS

### Tela Inicial 
A tela inicial deve apresentar o nome Batalha Naval (utilizando 2 linhas) e os nomes dos autores. Além disso, deve apresentar as opções Jogar e Sair (uma após a outra, onde a primeira letra é a seleção). 

### Tela de Configuração 
A tela de configuração é mostrada quando o usuário seleciona a opção Jogar no menu inicial. O programa deve apresentar uma matriz de navios (10 x 10) centralizada na tela. A matriz deve possuir cada linha e coluna identificada por algarismos decimais. Note que molduras devem ser utilizadas para separar os elementos da tela. O programa deve requisitar o posicionamento de 5 tipos de embarcações através do teclado. Os tipos de embarcações, símbolo que será utilizado para marcar a sua localização e tamanho (comprimento em número de caracteres) são apresentados na tabela abaixo.

| Embarcação  | Símbolo  | Tamanho  |
|--|--|--|
| Porta Aviões | A | 5 |
| Navio de Guerra | B | 4 |
| Submarino | S | 3 |
| Destroyer  | D | 3 |
| Barco Patrulha | P | 2 |


O usuário deve fornecer três caracteres que representam a linha, coluna e direção (H para horizontal e V para vertical). O programa deve ler para todos os 5 tipos de embarcações (com mensagens apropriadas) sem que o usuário pressione o ENTER e garantir que o usuário somente digite algarismos decimais nas 2 primeiras posições e a letra H ou V maiúscula na terceira posição. Deve verificar se a embarcação está nos limites da matriz e não sobrepõe outra embarcação. Após a leitura, o programa deve ir para a tela do jogo. 
Após entrar as localizações de todas as embarcações, o programa deve gerar aleatoriamente as posições das embarcações do segundo jogador: o computador. 

### Tela do Jogo 
A tela deve possuir duas matrizes (10 x 10): navios e tiros. A matriz de tiro apresenta a situação dos tiros realizados pelo usuário. Cada posição da matriz de tiro deve ser preenchida pelo símbolo  (quadrado verde). Quando o tiro atingir parte da embarcação, a posição deve ser preenchida por o (letra “o” verde). No caso de o tiro não atingir embarcação alguma, a posição deve ser preenchida por x (letra “x” vermelha).
A matriz de navios mostra a situação da esquadra do usuário. Cada tiro do adversário que não atingir embarcação alguma deve ser representado na matriz pelo símbolo  (quadrado vermelho). Quando o tiro acertar em alguma embarcação, a letra do tipo da embarcação deve ser alterada para a cor vermelha. Um placar na lateral direita da tela deve ser mostrado para apresentar diversas informações do jogo. O placar é dividido em duas partes, Voce e Computador, com informações como número de tiros, acertos, navios afundados do jogador e do adversário.

### Jogo 
O programa deve requisitar a posição na caixa **Posição**. O usuário não deve pressionar ENTER para finalizar a edição. Deve sempre validar a entrada para que aceite somente dígitos. Na vez do jogador, deve ser mostrada a mensagem “SUA VEZ!”, enquanto para o adversário deve ser mostrada a mensagem “AGUARDANDO ADVERSARIO”. No caso do computador, devese aguardar 3 segundos antes de marcar a posição selecionada aleatoriamente. 
A cada jogada as matrizes devem ser atualizadas de acordo com o resultado do tiro. Além disso, o placar lateral deve ser atualizado com as devidas informações. 
Quando o tiro acertar algo, deve mostrar uma mensagem “ACERTOU ALGO!” (além de mostrar na matriz de tiro). Esta mensagem deve ser mostrada por 3 segundos. 
Quando alguém vencer, deve ser mostrada a mensagem “VOCE VENCEU!” para o ganhador e “VOCE PERDEU!” para o perdedor. Esta mensagem deve ser mostrada por 5 segundos e o programa deve ir para a tela do fim do jogo. 

### Tela do Fim do Jogo 
Deve mostrar a mensagem FIM DE JOGO, o vencedor e o número de jogadas. Isto acontece quando um jogador afundar todos os navios do outro jogador. O programa deve requisitar se deseja começar um novo jogo (vai para a tela inicial) ou reiniciar o jogo a partir da localização atual das embarcações (mas as localizações das embarcações do computador devem ser geradas novamente).


## GERAÇÃO DE NÚMEROS ALEATÓRIOS

Um dos geradores de números aleatórios mais conhecidos e antigo é baseado no chamado método das congruências lineares. Este método gera uma sequência de número pseudoaleatórios calculados com uma equação contínua por parte linear. Dado um valor inicial 𝑥0, conhecido como semente, o próximo número da sequência é dado por

> 𝑥1 = (𝑎𝑥 + 𝑐) % 𝑚

onde 𝑚 é o módulo (𝑚 > 0), 𝑎 é o multiplicador (0 < 𝑎 < 𝑚) e 𝑐 é o incremento (0 ≤ 𝑐 < 𝑚). Assim, o número pseudoaleatório gerado estará no intervalo entre 0 e 𝑚 - 1. De forma mais geral, a sequência de números aleatórios pode ser definida como 

> 𝑥𝑖+1 = (𝑎𝑥𝑖 + 𝑐) % 𝑚

Se a semente 𝑥0 for sempre a mesma, a mesma sequência será gerada. Para começar uma nova sequência, pode-se utilizar um valor que muda a todo momento (por exemplo, o número de ticks do processador).
