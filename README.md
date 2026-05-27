# Algoritmos em MIPS Assembly 💻⚙️

Este repositório contém uma coleção rigorosa de algoritmos implementados em linguagem Assembly MIPS (RISC de 32 bits). 

Desenvolvidos no contexto das disciplinas de Arquitetura de Computadores da Universidade Estadual de Londrina (UEL), estes projetos exploram a fundo a interação direta com o *hardware*, o controle estrito da memória e o mapeamento de estruturas de dados complexas para instruções de máquina elementares.

## 🔬 Abordagem Científica e Teórica

O foco destas implementações transcende a simples sintaxe da linguagem. Cada código foi estruturado e documentado tendo em conta propriedades fundamentais da **Teoria da Computação e Análise de Algoritmos**:
* **Decidibilidade e Máquinas de Estado:** Comportamento determinístico na manipulação de ciclos iterativos finitos e avaliação de matrizes.
* **Complexidade Temporal e Espacial:** Otimização do acesso à memória (localidade de referência) em tempo polinomial $O(n)$ e $O(n^2)$.
* **Manipulação e Segurança de Dados:** Processamento preciso ao nível do byte, alocação dinâmica no *heap* e operações com o Coprocessador 1 (Vírgula Flutuante) essenciais para o pré-processamento estrutural, simulação de autómatos e *parsing* de fluxos contínuos.

## 📂 Estrutura do Repositório

Os algoritmos estão organizados de forma evolutiva, desde as operações fundamentais em registos até ao processamento complexo de Entrada/Saída (I/O) no armazenamento secundário.

* 📁 **`01-lacos-e-condicionais/`**: Operações matemáticas básicas, séries finitas e teoria dos números.
* 📁 **`02-manipulacao-de-vetores/`**: Indexação sequencial, sub-rotinas e algoritmos como o *Bubble Sort* e arranjos combinatórios.
* 📁 **`03-operacoes-com-matrizes/`**: Mapeamento de tensores bidimensionais na memória estática (operações com diagonais, intersecções e transformações espaciais).
* 📁 **`04-manipulacao-de-strings/`**: *Parsing* de texto ao nível do byte, detetores de palíndromos e intersecção de carateres (`ASCII`).
* 📁 **`05-algoritmos-de-otimizacao/`**: Resolução de problemas clássicos como subsequência de soma máxima e permutações (complexidade $O(n!)$).
* 📁 **`06-validacao-e-processamento/`**: Algoritmos de sanitização de dados, extração de padrões e validadores formais (ex: Validador de CPF).
* 📁 **`07-ponto-flutuante-e-alocacao-dinamica/`**: Operações no Coprocessador 1 (FPU), alocação de matrizes no *heap* (`syscall 9`) e cálculo analítico (Série de Taylor).
* 📁 **`08-leitura-e-escrita-em-disco/`**: Manipulação de ficheiros `.txt`, transdutores de estado finito, persistência de dados e deteção de similaridade para *pattern matching*.
* 📁 **`docs/`**: Documentação e ficheiros de referência teórica dos exercícios propostos.

## 🚀 Destaques do Código

Alguns dos algoritmos mais desafiantes que demonstram conceitos avançados de arquitetura de baixo nível incluem:
- **Detetor de Similaridade Sequencial em Ficheiros:** Cruzamento e varredura de *buffers* em memória carregados a partir de ficheiros para identificação de padrões — a mesma lógica base empregue em Sistemas de Deteção de Intrusões (IDS) por assinatura.
- **Transdutor de Ofuscação de Texto:** Um exemplo prático de um autómato de Mealy a processar dados diretamente do disco.
- **Pipeline de Processamento Avançado:** Extração e normalização de características (*features*) estatísticas a partir de matrizes dinâmicas multidimensionais.

## 🛠️ Como Executar

Estes programas foram desenvolvidos e testados utilizando o simulador **MARS (MIPS Assembler and Runtime Simulator)**.

1. Faça o download do [MARS Simulator](https://computerscience.missouristate.edu/mars-mips-simulator.htm).
2. Garanta que possui o Java Runtime Environment (JRE) instalado na sua máquina.
3. Abra o MARS e carregue o ficheiro `.asm` que deseja testar (`File -> Open`).
4. Pressione `F3` (ou clique em **Assemble**) para compilar o código.
5. Pressione `F5` (ou clique no botão verde **Run**) para executar e visualizar o resultado na consola.
*(Nota: Para ficheiros do diretório `08-leitura-e-escrita-em-disco`, certifique-se de que os ficheiros `.txt` de entrada se encontram no mesmo diretório de execução ou ajuste os caminhos no código).*

## 👨‍💻 Autor
**Tomas Pagani Pires**
Investigação, Ciência da Computação e Arquitetura de Sistemas.# mips-assembly-projects