# =======================================================================================
# Titulo: Rotacao Circular de Vetor a Direita
# Descricao: Desloca os elementos de um vetor k posicoes para a direita, utilizando 
# aritmetica modular e um vetor temporario em memoria para evitar sobrescrita de dados.
# Analise de Computabilidade: A operacao de rotacao circular simula o comportamento de 
# buffers circulares (ring buffers). O uso do operador modulo (rem) garante que o 
# calculo dos novos indices permaneca estritamente dentro dos limites do conjunto 
# (decidibilidade do espaco de enderecamento), executando a transformacao em tempo O(n).
# Aplicacao: Implementacao de buffers circulares para analise continua de fluxos de dados 
# (stream mining) e processamento sequencial temporario.
# Referência na documentação: "atividade-mips-04.pdf"
# =======================================================================================

.data
    prompt_n:       .asciiz "Digite o tamanho do vetor (n): "
    prompt_elem:    .asciiz "Digite o elemento do vetor: "
    prompt_k:       .asciiz "Digite o valor de k (numero de posicoes para rotacionar): "
    resultado_msg:     .asciiz "Vetor rotacionado: "
    vetor:          .space  100 # Espaco para ate 25 inteiros (4 bytes cada)
    temp_vetor:     .space  100 # Espaco para um vetor temporario
    newline:        .asciiz "\n"

.text
    .globl main

main:
    # Leitura do valor de n
    li      $v0, 4              # Syscall para imprimir string
    la      $a0, prompt_n       # Carrega o endereco do prompt
    syscall                     
    
    li      $v0, 5              # Syscall para ler inteiro
    syscall                     # Le valor de n
    move    $t0, $v0            # Armazena n em $t0

    # Leitura dos elementos do vetor
    li      $t1, 0              

ler_vetor:
    bge     $t1, $t0, ler_k    # Se i >= n, pula pra leitura do k

    li      $v0, 4            
    la      $a0, prompt_elem    
    syscall                     

    li      $v0, 5              
    syscall                     # Le elemento do vetor
    sll     $t2, $t1, 2         #  t2 = i * 4
    la      $t3, vetor          # Carrega o endereco do vetor
    add     $t3, $t3, $t2       # Calcula o endereco do elemento
    sw      $v0, 0($t3)         # Armazena o valor no vetor

    addi    $t1, $t1, 1         # (i++)
    j       ler_vetor        

# Leitura do valor de k
ler_k:
    li      $v0, 4              # Syscall para imprimir string
    la      $a0, prompt_k       
    syscall                     

    li      $v0, 5              # Syscall para ler inteiro
    syscall                     
    move    $t4, $v0            # Armazena k em $t4

    
    rem     $t4, $t4, $t0       # k = k % n 

    # Copiar o vetor original pra um vetor temporario
    li      $t1, 0              # indice para percorrer o vetor original

copia_vetor:
    bge     $t1, $t0, rotaciona_vetor  # Se i >= n, pula pra rotacao

    sll     $t2, $t1, 2         # t2 = i * 4
    la      $t3, vetor          # Endereco do vetor original
    add     $t3, $t3, $t2   
    lw      $t5, 0($t3)         # Le o elemento original

    la      $t6, temp_vetor     # Endereco do vetor temporario
    add     $t6, $t6, $t2 
    sw      $t5, 0($t6)         # Armazena o elemento no vetor temporario

    addi    $t1, $t1, 1         # i++
    j       copia_vetor         


rotaciona_vetor:
    li      $t1, 0              # indice pro vetor original

rotacao_loop:
    bge     $t1, $t0, print_vetor  # Se i >= n, imprime o vetor

    sll     $t2, $t1, 2         # t2 = i * 4
    la      $t3, temp_vetor     # Endereco do vetor temporario

    # Calcula a nova posicao apos a rotacao
    add     $t5, $t1, $t4       # Posicao rotacionada = i + k
    rem     $t5, $t5, $t0       # Posicao rotacionada = (i + k) % n

    sll     $t5, $t5, 2         # t5 = (posicao rotacionada) * 4
    add     $t3, $t3, $t5       
    lw      $t6, 0($t3)         # Le o valor do vetor temporario

    la      $t7, vetor          # Endereco do vetor original
    add     $t7, $t7, $t2       
    sw      $t6, 0($t7)         # Armazena o valor rotacionado no vetor original

    addi    $t1, $t1, 1         # i++
    j       rotacao_loop         


print_vetor:
    li      $v0, 4              
    la      $a0, resultado_msg     
    syscall                    

    li      $t1, 0              

print_loop:
    bge     $t1, $t0, exit      # Se i >= n, termina o programa

    sll     $t2, $t1, 2         
    la      $t3, vetor          
    add     $t3, $t3, $t2
    lw      $a0, 0($t3)         # Le o valor do elemento
    li      $v0, 1              # Syscall para imprimir inteiro
    syscall                     

    li      $v0, 4              # Syscall para imprimir nova linha
    la      $a0, newline        
    syscall                     

    addi    $t1, $t1, 1         #i++
    j       print_loop          

exit:
    li      $v0, 10             # Syscall para encerrar o programa
    syscall
