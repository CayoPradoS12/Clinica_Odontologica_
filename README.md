# Sistema de Gestão de Clínica Odontológica

Repositório destinado ao projeto de Modelagem de Dados do curso de ADS (3º Semestre). O sistema visa gerenciar agendamentos, pacientes, dentistas, estoque e a parte financeira de uma clínica no Distrito Federal.

## Tecnologias Utilizadas

* **Banco de Dados:** MySQL 8.0
* **Ferramenta de Modelagem:** MySQL Workbench
* **Linguagem SQL:** DDL (Criação) e DML (Povoamento e Testes)
* **Backend:** Node.js + Express + mysql2
* **Frontend:** HTML5, CSS3 e JavaScript

## Estrutura do Projeto

O projeto está dividido em três níveis de modelagem:

1. **Conceitual:** Abstração de alto nível das regras de negócio.
2. **Lógico:** Estrutura relacional com definição de chaves e normalização.
3. **Físico:** Implementação final em script SQL.

## Como Executar o Projeto

### Banco de Dados

1. Certifique-se de ter o **MySQL Server** e o **Workbench** instalados.
2. Clone este repositório:
   `git clone https://github.com/CayoPradoS12/Clinica_Odontologica_`
3. Abra o arquivo `sql/clinica_odontologica.sql` no Workbench.
4. Execute o script (ícone do raio) para criar o banco de dados e popular as tabelas.

### Backend (API)

1. Certifique-se de ter o **Node.js** instalado.
2. Instale as dependências:
   `cd backend && npm install`
3. Copie `backend/.env.example` para `backend/.env` e preencha as variáveis de ambiente.
4. Execute a API:
   `cd backend && node server.js`
5. A API ficará disponível em `http://localhost:3000`

> Caso não utilize MongoDB local ou Atlas, o backend ainda funciona para as rotas MySQL (`/api/agenda`, `/api/faturamento`, `/api/estoque-vencido`). A seção de Prontuários no frontend exibirá mensagem de offline e permite salvar rascunhos locais.

### Frontend

1. Com a API rodando, abra o arquivo `frontend/index.html` no navegador.
2. Caso necessário, ajuste a URL da API no campo exibido no topo do painel.

## Integrantes do Grupo

* **Cayo Santos** - Modelagem Conceitual, SQL e Gestão do GitHub
* Antônio Joaquim - Modelagem Lógica e Modelagem Física
* Dankley Meireles - Documentação, Introdução e Escopo do Produto
* Felipe Lopes - Justificativa, Revisão Textual e Formatação

Confira as evidências de funcionamento do banco de dados na pasta [evidencias/](./evidencias).

* [Documentação Completa (PDF)](./documentacao/artigo_clinica_odontologica.pdf)
