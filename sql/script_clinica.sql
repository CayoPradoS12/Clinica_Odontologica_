drop database if exists clinica_odontologica;
create database clinica_odontologica;
use clinica_odontologica;

create table usuario
(
id_usuario int auto_increment primary key,
nome varchar (255) not null,
data_nascimento date not null
);


create table cliente
(
id_cliente int primary key,
historico_hospitalar varchar (255),
endereco varchar(255) not null,
foreign key (id_cliente) references Usuario(id_usuario)
);

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
foreign key (id_dentista) references Usuario(id_usuario)
);

create table consulta
(
id_consulta int auto_increment primary key,
data_hora datetime not null,
tipo_consulta varchar (255) not null,
id_paciente int,
id_responsavel int,
status_consulta varchar (50) not null,
foreign key (id_paciente) references Cliente(id_cliente),
foreign key (id_responsavel) references Dentista(id_dentista)
);

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
id_consulta int,
foreign key (id_consulta) references consulta(id_consulta)
	on delete set null
);

create table estoque
(
id int auto_increment primary key,
tipo_equipamento varchar (50) not null,
quantidade int,
finalidade varchar (255) not null,
validade date not null
);
create table procedimento_estoque
(
codigo_estoque int, 
codigo_servico int,
primary key (codigo_estoque, codigo_servico),
foreign key (codigo_estoque) references Estoque(id),
foreign key (codigo_servico) references Procedimento(codigo)
);

create table consulta_procedimento
(
id_consulta int,
codigo_procedimento int,
valor_pago decimal(10,2),
primary key (id_consulta, codigo_procedimento),
foreign key (id_consulta) references Consulta(id_consulta),
foreign key (codigo_procedimento) references Procedimento(codigo)
);

-- Inserindo Valores --

insert into Usuario (nome, data_nascimento) values 
('Cayo Santos', '2000-05-15'),
('Antônio Joaquim', '1985-10-20'),
('Ana Oliveira', '1992-03-08'),
('Ricardo Silva', '1978-12-12'),
('Mariana Costa', '1995-07-25'),
('Lucas Pereira', '1988-01-30');

insert into Dentista (id_dentista, cro, especializacao) values 
(1, 'CRO-DF 12345', 'Ortodontia'),
(2, 'CRO-DF 67890', 'Implantodontia');

insert into Cliente (id_cliente, historico_hospitalar, endereco) values 
(3, 'Nenhuma alergia detectada', 'Taguatinga Norte, DF'),
(4, 'Hipertenso controlado', 'Ceilândia Centro, DF'),
(5, 'Alergia a dipirona', 'Águas Claras, DF'),
(6, 'Paciente sem restrições', 'Samambaia Sul, DF');

insert into Estoque (tipo_equipamento, quantidade, finalidade, validade) values 
('Luvas de Látex', 100, 'Proteção Individual', '2027-12-31'),
('Máscara Descartável', 50, 'Proteção Individual', '2026-06-30'),
('Resina Composta', 20, 'Restauração', '2025-10-15'),
('Anestésico Local', 30, 'Cirurgia/Procedimento', '2025-05-20'),
('Agulhas Gengivais', 200, 'Aplicação de Anestesia', '2028-01-01');

insert into Procedimento (tipo_procedimento, valor) values 
('Limpeza Completa', 150.00),
('Extração Simples', 250.00),
('Restauração de Resina', 180.00),
('Aplicação de Flúor', 90.00),
('Canal (Endodontia)', 850.00);

insert into Consulta (data_hora, tipo_consulta, id_paciente, id_responsavel, status_consulta) values 
('2026-04-20 09:00:00', 'Rotina', 3, 1, 'Agendada'),
('2026-04-20 10:30:00', 'Urgência', 4, 1, 'Confirmada'),
('2026-04-21 14:00:00', 'Retorno', 5, 2, 'Agendada'),
('2026-04-21 16:00:00', 'Avaliação', 6, 2, 'Cancelada'),
('2026-04-22 08:00:00', 'Cirurgia', 3, 1, 'Confirmada');

insert into Financeiro (tipo, valor, data_pgto, data_vencimento, forma_pgto, status_pgto, descricao, id_consulta) values 
('Receita', 150.00, '2026-04-20', '2026-04-20', 'PIX', 'Pago', 'Pagamento Limpeza', 1),
('Receita', 250.00, null, '2026-04-25', 'Cartão de Crédito', 'Pendente', 'Pagamento Extração', 2),
('Despesa', 500.00, '2026-04-10', '2026-04-10', 'Boleto', 'Pago', 'Compra de Insumos Abril', null);

insert into procedimento_estoque (codigo_estoque, codigo_servico) values 
(1, 1),
(2, 1),
(4, 2),
(3, 3);

insert into consulta_procedimento (id_consulta, codigo_procedimento, valor_pago) values 
(1, 1, 150.00),
(2, 2, 250.00),
(5, 2, 250.00);

-- Selecionando e atuailizando valores

select u_den.nome as Dentista,count(c.id_consulta) as Total_Atendimentos,sum(f.valor) as Receita_Gerada
from Consulta c
join Dentista d on c.id_responsavel = d.id_dentista
join Usuario u_den on d.id_dentista = u_den.id_usuario
join Financeiro f on c.id_consulta = f.id_consulta
where f.status_pgto = 'Pago'
group by u_den.nome;

select u.nome as Paciente, c.endereco, c.historico_hospitalar 
from Cliente c
join Usuario u on c.id_cliente = u.id_usuario
where c.endereco like '%Taguatinga%' or c.endereco like '%Ceilândia%';

select tipo_equipamento, quantidade, validade
from estoque
where validade < '2026-01-01'
order by validade asc;

update consulta 
set status_consulta = 'Finalizada' 
where id_consulta = 1;

update cliente 
set historico_hospitalar = concat(historico_hospitalar, ' | Nova consulta: Paciente estável') 
where id_cliente = 3;

select * from usuario;

select
    c.id_consulta as 'ID',
    u_pac.nome as 'Paciente',
    u_den.nome as 'Dentista',
    c.data_hora as 'Data/Hora',
    f.valor as 'Valor da Consulta',
    f.status_pgto as 'Status Pagamento'
from Consulta c
join Usuario u_pac on c.id_paciente = u_pac.id_usuario
join Usuario u_den on c.id_responsavel = u_den.id_usuario
join Financeiro f on c.id_consulta = f.id_consulta
order by c.data_hora desc;
