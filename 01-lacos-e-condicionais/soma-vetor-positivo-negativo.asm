# =======================================================================================
# Titulo: Particionamento e Soma de Inteiros em Vetor
# Descricao: Itera sobre um vetor de 8 posicoes predefinido em memoria, separando 
# e somando os valores positivos e negativos de forma independente.
# Analise de Computabilidade: O codigo atua como um Automato Finito Deterministico (AFD) 
# processando uma fita de entrada de tamanho fixo. A logica de decisao (bge) garante a 
# transicao correta entre os estados de soma, demonstrando a decidibilidade da 
# classificacao de conjuntos numericos finitos em tempo linear O(n).
# Aplicacao: Implementacao de baixo nivel util para pesquisa cientifica focada em 
# data stream mining e particionamento primario de dados.
# Referência na documentação: "atividade-mips-01.pdf"
# =======================================================================================

.data
    vetor: .word -2, 4, 7, -3, 0, -3, 5, 6  # Vetor.
    pos_som: .word 0                        # Variavel para guardar a soma dos positivos.
    neg_som: .word 0                        # Variavel para guardar a soma dos negativos.
    msg_pos: .asciiz "Soma dos positivos: " # Mensagem para a soma dos positivos.
    msg_neg: .asciiz "\nSoma dos negativos: " # Mensagem para a soma dos negativos.
	
.text
main:
    la $t0, vetor            # Carrega o endereco base do vetor.
    li $t1, 0                # indice do vetor, inicializa com 0.
    li $t2, 0                # Inicializa a soma dos positivos em $t2.
    li $t3, 0                # Inicializa a soma dos negativos em $t3.
    li $t4, 8                # Numero de elementos no vetor (8 elementos).

loop:
    # Carrega o valor do vetor:
    lw $t5, 0($t0)           # Carrega o valor atual do vetor em $t5.
    
    # Verifica se o valor eh positivo ou negativo.
    bge $t5, $zero, positivo # Verifica se $t5 >= 0, se sim, pula para 'positivo'.
    
    # Se negativo:
    add $t3, $t3, $t5        # Soma o valor a variavel de negativos.
    j end_if
    
positivo: 
    # Se positivo:
    add $t2, $t2, $t5        # Soma o valor a variavel de positivos.

end_if:
    # Incrementa o indice do vetor e ajusta o endereco.
    addi $t1, $t1, 1
    addi $t0, $t0, 4         # Move para o proximo elemento do vetor (4 bytes por elemento).
    
    blt $t1, $t4, loop       # Verifica se terminou de percorrer o vetor, se o indice < 8, volta para o inicio do loop.

    # Armazena os resultados finais:
    sw $t2, pos_som
    sw $t3, neg_som
    
    # Imprime os resultados:
    li $v0, 4		     # Codigo do syscall para imprimir string.
    la $a0, msg_pos	     # Carrega o endereco da mensagem de soma dos negativos.
    syscall		     # Chama syscall para imprimir a mensagem.
    
    li $v0, 1                # Codigo da syscall para imprimir um inteiro.
    lw $a0, pos_som          # Carrega o valor de pos_som em $a0.
    syscall                  # Chama a syscall para imprimir a soma dos positivos.

    li $v0, 4		     # Codigo do syscall para imprimir string.
    la $a0, msg_neg	     # Carrega o endereco da mensagem de soma dos negativos.
    syscall		     # Chama syscall para imprimir a mensagem.
    
    li $v0, 1                # Codigo da syscall para imprimir um inteiro.
    lw $a0, neg_som          # Carrega o valor de neg_som em $a0.
    syscall                  # Chama a syscall para imprimir a soma dos negativos.

    # Termina o programa:
    li $v0, 10               # Codigo para terminar o programa.
    syscall
