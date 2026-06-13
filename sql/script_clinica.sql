drop database if exists clinica_odontologica;
create database clinica_odontologica;
use clinica_odontologica;

-- AUTO_INCREMENT justificado: id interno de controle, sem regra de negócio associada
create table grupos_usuarios (
    id int auto_increment primary key,
    nome_grupo varchar (50) not null unique,
    descricao varchar (255)
);

-- AUTO_INCREMENT justificado: id interno de controle, sem regra de negócio associada
create table usuarios
(
id_usuario int auto_increment primary key,
log_in varchar (50) not null unique,
senha varchar (255) not null,
nome varchar (255) not null,
data_nascimento date,
id_grupo int,
foreign key (id_grupo) references grupos_usuarios(id)
);


create table cliente
(
id_cliente int primary key,
historico_hospitalar varchar (255),
endereco varchar(255) not null,
foreign key (id_cliente) references usuarios(id_usuario) on delete cascade
);

-- AUTO_INCREMENT justificado: código sequencial para catálogo interno de procedimentos
create table procedimento
(
codigo int auto_increment primary key,
tipo_procedimento varchar (255) not null,
valor decimal (10,2) not null
);

create table dentista
(
id_dentista int primary key,
cro varchar (255) unique not null,
especializacao varchar (255) not null,
foreign key (id_dentista) references usuarios(id_usuario) on delete cascade
);

create table consulta
(
id_consulta varchar(20) primary key,
data_hora datetime not null,
tipo_consulta varchar (255) not null,
id_paciente int,
id_responsavel int,
status_consulta varchar (50) not null,
foreign key (id_paciente) references cliente(id_cliente),
foreign key (id_responsavel) references dentista(id_dentista)
);
-- AUTO_INCREMENT justificado: id interno de controle, sem regra de negócio associada
create table financeiro
(
id_financeiro int auto_increment primary key,
tipo enum('Receita', 'Despesa') not null,
valor decimal(10,2) not null,
data_pgto date,
data_vencimento date,
forma_pgto varchar (50),
status_pgto varchar (50),
descricao varchar (255) not null,
id_consulta varchar(20),
foreign key (id_consulta) references consulta(id_consulta) on delete set null
);

-- AUTO_INCREMENT justificado: id interno de controle, sem regra de negócio associada
create table estoque
(
id int auto_increment primary key,
tipo_equipamento varchar (50) not null,
quantidade int default 0,
finalidade varchar (255) not null,
validade date not null
);

create table procedimento_estoque
(
codigo_estoque int, 
codigo_servico int,
quantidade_utilizada int default 1,
primary key (codigo_estoque, codigo_servico),
foreign key (codigo_estoque) references estoque(id),
foreign key (codigo_servico) references procedimento(codigo)
);

create table consulta_procedimento
(
id_consulta varchar (20),
codigo_procedimento int,
valor_pago decimal(10,2),
primary key (id_consulta, codigo_procedimento),
foreign key (id_consulta) references consulta(id_consulta),
foreign key (codigo_procedimento) references procedimento(codigo)
);

-- Functions e procedures

delimiter $$

-- Gerador de ID crítico customizado para consultas
create function fn_gerar_id_consulta()
returns varchar (20)
deterministic 
begin
    declare novo_id varchar(20);
    declare total int;
    select count(*) into total from consulta where year(data_hora) = year (now());
    set novo_id = concat('CON', year(now()), '-', LPAD(total + 1, 5, '0'));
    return novo_id;
end$$

-- agendamento seguro de consulta utilizando o id customizado
create procedure sp_agendar_consulta(
    in p_data_hora datetime,
    in p_tipo varchar (255),
    in p_id_paciente int,
    in p_id_dentista int,
    in p_status varchar(50)
)
begin
declare v_id varchar(20);
set v_id = fn_gerar_id_consulta();
insert into consulta (id_consulta, data_hora, tipo_consulta, id_paciente, id_responsavel, status_consulta)
values (v_id, p_data_hora, p_tipo, p_id_paciente, p_id_dentista, p_status);
end$$

-- inserção automatizada de usuários com validação de senha simples 
create procedure sp_criar_usuario(
    in p_login varchar(50),
    in p_senha varchar(255),
    in p_nome varchar(255),
    in p_nascimento date,
    in p_grupo int
)
begin 
insert into usuarios (log_in, senha, nome, data_nascimento, id_grupo)
values (p_login, p_senha, p_nome, p_nascimento, p_grupo);
end$$

delimiter ;

-- triggers

delimiter $$

create trigger tr_baixa_estoque_automatica
after insert on consulta_procedimento
for each row
begin
    update estoque e
    join procedimento_estoque pe on e.id = pe.codigo_estoque
    set e.quantidade = e.quantidade - pe.quantidade_utilizada
    where pe.codigo_servico = new.codigo_procedimento;
end$$

create trigger tr_impedir_alteracao_cancelada
before update on consulta 
for each row
begin 
    if old.status_consulta = 'Cancelada' then
        signal sqlstate '45000'
        set message_text = 'Não é permitido alterar dados de uma consulta que foi cancelada.';
    end if;
end$$

delimiter ;

-- Inserindo Valores --

insert into grupos_usuarios (nome_grupo, descricao) values 
('Administrador', 'Acesso total ao sistema'),
('Dentista', 'Acesso a prontuários e agenda'),
('Recepcionista', 'Acesso a cadastros e agendamentos');


insert into usuarios (id_usuario, log_in, senha, nome, data_nascimento, id_grupo) values 
(1, 'cayo.santos', '1234', 'Cayo Santos', '2000-05-15', 2),
(2, 'antonio.j', '1234', 'Antônio Joaquim', '1985-10-20', 2),
(3, 'ana.o', '1234', 'Ana Oliveira', '1992-03-08', 3),
(4, 'ricardo.s', '1234', 'Ricardo Silva', '1978-12-12', 3),
(5, 'mariana.c', '1234', 'Mariana Costa', '1995-07-25', 3),
(6, 'lucas.p', '1234', 'Lucas Pereira', '1988-01-30', 3);

insert into dentista (id_dentista, cro, especializacao) values 
(1, 'CRO-DF 12345', 'Ortodontia'),
(2, 'CRO-DF 67890', 'Implantodontia');

insert into cliente (id_cliente, historico_hospitalar, endereco) values 
(3, 'Nenhuma alergia detectada', 'Taguatinga Norte, DF'),
(4, 'Hipertenso controlado', 'Ceilândia Centro, DF'),
(5, 'Alergia a dipirona', 'Águas Claras, DF'),
(6, 'Paciente sem restrições', 'Samambaia Sul, DF');

insert into estoque (tipo_equipamento, quantidade, finalidade, validade) values 
('Luvas de Látex', 100, 'Proteção Individual', '2027-12-31'),
('Máscara Descartável', 50, 'Proteção Individual', '2026-06-30'),
('Resina Composta', 20, 'Restauração', '2025-10-15'),
('Anestésico Local', 30, 'Cirurgia/Procedimento', '2025-05-20'),
('Agulhas Gengivais', 200, 'Aplicação de Anestesia', '2028-01-01');

insert into procedimento (codigo, tipo_procedimento, valor) values 
(1, 'Limpeza Completa', 150.00),
(2, 'Extração Simples', 250.00),
(3, 'Restauração de Resina', 180.00),
(4, 'Aplicação de Flúor', 90.00),
(5, 'Canal (Endodontia)', 850.00);


call sp_agendar_consulta('2026-04-20 09:00:00', 'Rotina', 3, 1, 'Agendada');
call sp_agendar_consulta('2026-04-20 10:30:00', 'Urgência', 4, 1, 'Confirmada');
call sp_agendar_consulta('2026-04-21 14:00:00', 'Retorno', 5, 2, 'Agendada');
call sp_agendar_consulta('2026-04-21 16:00:00', 'Avaliação', 6, 2, 'Cancelada');
call sp_agendar_consulta('2026-04-22 08:00:00', 'Cirurgia', 3, 1, 'Confirmada');

insert into financeiro (tipo, valor, data_pgto, data_vencimento, forma_pgto, status_pgto, descricao, id_consulta) values 
('Receita', 150.00, '2026-04-20', '2026-04-20', 'PIX', 'Pago', 'Pagamento Limpeza', 'CON2026-00001'),
('Receita', 250.00, null, '2026-04-25', 'Cartão de Crédito', 'Pendente', 'Pagamento Extração', 'CON2026-00002'),
('Despesa', 500.00, '2026-04-10', '2026-04-10', 'Boleto', 'Pago', 'Compra de Insumos Abril', null);

insert into procedimento_estoque (codigo_estoque, codigo_servico, quantidade_utilizada) values 
(1, 1, 2),
(2, 1, 1),
(4, 2, 1),
(3, 3, 1);

insert into consulta_procedimento (id_consulta, codigo_procedimento, valor_pago) values 
('CON2026-00001', 1, 150.00),
('CON2026-00002', 2, 250.00),
('CON2026-00005', 2, 250.00);

-- views

create or replace view vw_agenda_completa as
select
    c.id_consulta as 'id',
    u_pac.nome as 'paciente',
    u_den.nome as 'dentista',
    c.data_hora as 'data_hora',
    f.valor as 'valor',
    f.status_pgto as 'status_pagamento'
from consulta c
join usuarios u_pac on c.id_paciente = u_pac.id_usuario
join usuarios u_den on c.id_responsavel = u_den.id_usuario
left join financeiro f on c.id_consulta = f.id_consulta;

-- VIEW 2: Produtividade e Faturamento Líquido por Profissional
create or replace view vw_faturamento_dentistas as
select 
    u_den.nome as dentista,
    count(c.id_consulta) as total_atendimentos,
    sum(f.valor) as receita_gerada
from consulta c
join dentista d on c.id_responsavel = d.id_dentista
join usuarios u_den on d.id_dentista = u_den.id_usuario
join financeiro f on c.id_consulta = f.id_consulta
where f.status_pgto = 'Pago'
group by u_den.nome;

-- indices de performance 

-- Justificativa: Consultas de Agenda filtram massivamente por data_hora. O índice reduz de O(N) para O(log N).
create index idx_consulta_data on consulta(data_hora);

-- Justificativa: Otimiza os joins de relatórios financeiros e filtros por status de pagamento pendentes.
create index idx_financeiro_status on financeiro(status_pgto);

-- Usuários e segurança (nível completo — aplicação principal)
create user if not exists 'app_odontoped_user'@'localhost' identified by 'DevClinica2026!';
grant select, insert, update, delete on clinica_odontologica.* to 'app_odontoped_user'@'localhost';
grant select on clinica_odontologica.vw_agenda_completa to 'app_odontoped_user'@'localhost';

-- Usuário de leitura (nível restrito — painel front-end, acesso somente às views)
create user if not exists 'readonly_dashboard'@'localhost' identified by 'DashView2026!';
grant select on clinica_odontologica.vw_agenda_completa to 'readonly_dashboard'@'localhost';
grant select on clinica_odontologica.vw_faturamento_dentistas to 'readonly_dashboard'@'localhost';

flush privileges;

-- execução de queries

-- Query 1: Faturamento via View criada
select * from vw_faturamento_dentistas;

-- Query 2: Filtro Geográfico de Pacientes (Ajustado Joins de Herança)
select u.nome as Paciente, cl.endereco, cl.historico_hospitalar 
from cliente cl
join usuarios u on cl.id_cliente = u.id_usuario
where cl.endereco like '%Taguatinga%' or cl.endereco like '%Ceilândia%';

-- Query 3: Estoque Vencido
select tipo_equipamento, quantidade, validade from estoque where validade < '2026-06-01';

-- Query 4: Relatório Dinâmico Geral via View principal
select * from vw_agenda_completa order by data_hora desc;
