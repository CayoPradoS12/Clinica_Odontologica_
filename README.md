#  Sistema de Gestão de Clínica Odontológica
Repositório destinado ao projeto de Modelagem de Dados do curso de ADS (3º Semestre). O sistema visa gerenciar agendamentos, pacientes, dentistas, estoque e a parte financeira de uma clínica no Distrito Federal.

##  Tecnologias Utilizadas
* **Banco de Dados:** MySQL 8.0
* **Ferramenta de Modelagem:** MySQL Workbench
* **Linguagem SQL:** DDL (Criação) e DML (Povoamento e Testes)
* **Backend:** Python 3 + Flask
* **Frontend:** HTML5, CSS3 e JavaScript

##  Estrutura do Projeto
O projeto está dividido em três níveis de modelagem:
1. **Conceitual:** Abstração de alto nível das regras de negócio.
2. **Lógico:** Estrutura relacional com definição de chaves e normalização.
3. **Físico:** Implementação final em script SQL.

##  Como Executar o Projeto

### Banco de Dados
1. Certifique-se de ter o **MySQL Server** e o **Workbench** instalados.
2. Clone este repositório:
   `git clone https://github.com/CayoPradoS12/Clinica_Odontologica_`
3. Abra o ficheiro `database/clinica_odontologica.sql` no Workbench.
4. Execute o script (ícone do raio) para criar o banco de dados e popular as tabelas.

### Backend (API)
1. Certifique-se de ter o **Python 3** instalado.
2. Instale as dependências:
   `pip install -r backend/requirements.txt`
3. Execute a API:
   `python backend/app.py`
4. A API ficará disponível em `http://localhost:5000`

### Frontend
1. Com a API rodando, abra o arquivo `frontend/index.html` no navegador.
2. O sistema funciona também em **modo demonstração** sem conexão com o banco.

##  Integrantes do Grupo
* **Cayo Santos** - Modelagem Conceitual, SQL e Gestão do GitHub
* Antônio Joaquim - Modelagem Lógica e Modelagem Física
* Dankley Meireles - Documentação, Introdução e Escopo do Produto
* Felipe Lopes - Justificativa, Revisão Textual e Formatação

Confira as evidências de funcionamento do banco de dados na pasta [evidencias/](./evidencias).

*  [Documentação Completa (PDF)](./documentacao/Documentação_Clínica_Odontológica.pdf)
