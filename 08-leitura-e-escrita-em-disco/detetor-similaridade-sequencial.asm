# =======================================================================================
# Titulo: Deteccao de Similaridade e Pesquisa de Padroes em Ficheiros
# Descricao: Compara dois buffers de memoria carregados a partir de ficheiros distintos 
# para identificar a existencia de uma sequencia comum de 5 ou mais palavras consecutivas.
# Analise de Computabilidade: O algoritmo executa uma pesquisa de padroes (pattern 
# matching) bidimensional, cruzando duas fitas finitas. A complexidade de pior caso e 
# polinomial O(N*M), garantindo a decidibilidade do problema de intersecão de cadeias 
# de forma finita e sem sobrecarga do espaco de memoria alocado.
# Aplicacao: Algoritmo central na deteccao de intrusoes (IDS) baseada em assinaturas, 
# identificando cargas uteis (payloads) anomalas e rastreio de similaridade lexica.
# Referência na documentação: "atividade-mips-11.pdf"
# =======================================================================================

.data
file1:      .asciiz "7.5_1.txt"    # Nome do primeiro arquivo
file2:      .asciiz "7.5_2.txt"    # Nome do segundo arquivo
buffer1:    .space 4096               # Buffer para o conteudo do arquivo 1
buffer2:    .space 4096               # Buffer para o conteudo do arquivo 2
words1:     .space 1024               # Array para armazenar palavras do arquivo 1 (cada palavra ocupa 64 bytes)
words2:     .space 1024               # Array para armazenar palavras do arquivo 2
count1:     .word 0                   # Contador de palavras no arquivo 1
count2:     .word 0                   # Contador de palavras no arquivo 2
msg_sim:    .asciiz "Existe sequencia comum de 5 ou mais palavras.\n"
msg_nao:    .asciiz "Nao existe sequencia comum de 5 ou mais palavras.\n"
space:      .asciiz " "
newline:    .asciiz "\n"

.text
.globl main

main:
    # Carregar arquivo 1
    la $a0, file1
    la $a1, buffer1
    jal read_file
    sw $v0, count1

    # Carregar arquivo 2
    la $a0, file2
    la $a1, buffer2
    jal read_file
    sw $v0, count2

    # Verificar se ambos tem pelo menos 5 palavras
    lw $t0, count1
    lw $t1, count2
    blt $t0, 5, nao_existe
    blt $t1, 5, nao_existe

    # Procurar sequencias comuns
    la $a0, words1
    lw $a1, count1
    la $a2, words2
    lw $a3, count2
    jal find_sequence

    beqz $v0, nao_existe

    # Se encontrou sequencia
    li $v0, 4
    la $a0, msg_sim
    syscall
    j exit

nao_existe:
    li $v0, 4
    la $a0, msg_nao
    syscall

exit:
    li $v0, 10
    syscall

# Funcao para ler arquivo e extrair palavras
# Argumentos: $a0 = nome do arquivo, $a1 = buffer
# Retorna: $v0 = numero de palavras
read_file:
    # Abrir arquivo
    li $v0, 13
    li $a1, 0
    li $a2, 0
    syscall
    move $t0, $v0

    # Ler conteudo
    li $v0, 14
    move $a0, $t0
    move $a1, $a1
    li $a2, 4096
    syscall

    # Fechar arquivo
    li $v0, 16
    move $a0, $t0
    syscall

    # Processar palavras
    move $a0, $a1
    la $a1, words1
    jal split_words
    jr $ra

# Funcao para dividir texto em palavras
# Argumentos: $a0 = buffer de texto, $a1 = array de palavras
# Retorna: $v0 = numero de palavras
split_words:
    li $t0, 0           # Contador de palavras
    li $t1, 0           # Estado (0 = espaco, 1 = palavra)

loop_split:
    lb $t2, ($a0)
    beqz $t2, end_split

    # Verificar se eh espaco
    li $t3, 32
    beq $t2, $t3, is_space
    li $t3, 10
    beq $t2, $t3, is_space
    li $t3, 13
    beq $t2, $t3, is_space
    li $t3, 9
    beq $t2, $t3, is_space

    # eh caractere de palavra
    beqz $t1, new_word
    j next_char

is_space:
    li $t1, 0
    j next_char

new_word:
    li $t1, 1
    sw $a0, ($a1)       # Armazenar endereco da palavra
    addi $a1, $a1, 4
    addi $t0, $t0, 1

next_char:
    addi $a0, $a0, 1
    j loop_split

end_split:
    move $v0, $t0
    jr $ra

# Funcao para encontrar sequencia comum
# Argumentos: $a0 = array1, $a1 = count1, $a2 = array2, $a3 = count2
# Retorna: $v0 = 1 se encontrou, 0 caso contrario
find_sequence:
    addi $t0, $a1, -4   # Limite superior para array1
    addi $t1, $a3, -4   # Limite superior para array2
    li $t2, 0           # i (array1)

loop_i:
    bgt $t2, $t0, no_sequence
    li $t3, 0           # j (array2)

loop_j:
    bgt $t3, $t1, next_i

    # Verificar sequencia de 5 palavras
    move $a0, $t2
    move $a1, $t3
    li $a2, 5
    jal compare_sequence

    beq $v0, 1, found_sequence

    addi $t3, $t3, 1
    j loop_j

next_i:
    addi $t2, $t2, 1
    j loop_i

no_sequence:
    li $v0, 0
    jr $ra

found_sequence:
    li $v0, 1
    jr $ra

# Funcao para comparar sequencias
# Argumentos: $a0 = start1, $a1 = start2, $a2 = length
# Retorna: $v0 = 1 se igual, 0 caso contrario
compare_sequence:
    li $t4, 0

compare_loop:
    beq $t4, $a2, equal
    lw $t5, words1($a0)
    lw $t6, words2($a1)

    # Comparar strings
    move $a0, $t5
    move $a1, $t6
    jal strcmp
    bnez $v0, not_equal

    addi $a0, $a0, 4
    addi $a1, $a1, 4
    addi $t4, $t4, 1
    j compare_loop

equal:
    li $v0, 1
    jr $ra

not_equal:
    li $v0, 0
    jr $ra

# Funcao para comparar strings
# Argumentos: $a0 = str1, $a1 = str2
# Retorna: $v0 = 0 se iguais, 1 se diferentes
strcmp:
strcmp_loop:
    lb $t0, ($a0)
    lb $t1, ($a1)
    bne $t0, $t1, str_diff
    beqz $t0, str_eq
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    j strcmp_loop

str_eq:
    li $v0, 0
    jr $ra

str_diff:
    li $v0, 1
    jr $ra