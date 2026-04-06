🦷 Sistema de Gestão de Clínica Odontológica - Banco de Dados
Este repositório contém a modelagem e o script SQL para um sistema de gestão clínica focado em automação de processos, controle de estoque e fluxo financeiro.

📋 Contexto e Justificativa
O projeto nasceu da necessidade de centralizar as informações de uma clínica odontológica, substituindo processos manuais por uma estrutura de dados robusta. O sistema visa otimizar o agendamento de consultas, o controle de materiais (estoque) e a saúde financeira da clínica, permitindo uma análise precisa de lucros e despesas.

🛠️ Tecnologias Utilizadas
MySQL: Sistema de Gerenciamento de Banco de Dados (SGBD).

Modelagem Relacional: (DER/MER).

🗂️ Estrutura do Banco de Dados
Abaixo estão as principais entidades e suas funções no sistema:

Núcleo de Atendimento
Paciente: Cadastro completo com histórico hospitalar.

Dentista: Registro profissional (CRO) e especialidades.

Consulta: O centro do sistema, relacionando pacientes e dentistas com status de agendamento.

Procedimentos e Materiais
Procedimento: Catálogo de serviços prestados e valores base.

Estoque: Controle de insumos, quantidades e datas de validade.

Consulta_Procedimento: Tabela associativa que registra quais procedimentos foram realizados em cada consulta e o valor final pago.

Procedimento_Estoque: Relacionamento N:N que mapeia quais itens do estoque são consumidos por cada tipo de procedimento.

Gestão Financeira
Financeiro: Fluxo de caixa que registra Receitas e Despesas. Possui relacionamento opcional com a tabela de consultas, permitindo o registro de gastos fixos da clínica (aluguel, luz) e entradas diretas de pacientes.

🚀 Diferenciais Técnicos
Integridade Referencial: Uso de Chaves Estrangeiras (FK) para garantir que não haja dados órfãos.

Regra de Negócio no Banco: Implementação de on delete set null no financeiro para preservar o histórico de caixa mesmo se um agendamento for removido.

Padronização: Uso de ENUM para tipos de movimentação financeira e DECIMAL para precisão monetária.

⚙️ Como Executar
Certifique-se de ter o MySQL Server instalado e rodando.

Clone este repositório.

Importe o arquivo .sql no seu SGBD preferido (MySQL Workbench, DBeaver, etc.).

Execute o script para gerar o database clinica e todas as tabelas.
