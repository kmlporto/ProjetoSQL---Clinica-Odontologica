-- VISOES DO PROJETO

-- VISAO PARA INSERÇÃO E CONSULTA DE PACIENTES
CREATE OR REPLACE view cli.pacientes (codigo,cpf,nome,telefone, tipo) as 
	select idpessoa,cpf,nome, telefone, tipo from cli.pessoa where tipo = 'P';

/*INSERT INTO cli.pacientes VALUES(32,11529054652, 'Fabrício Liberato', 987150546, 'P')
Select * from cli.pacientes;*/

-- VISOES MAIS ROBUSTAS

-- comissao dentistas mes anterior;
CREATE OR REPLACE view cli.comissaoDentistas (dentista, valor) as
select pe.nome, 30*count(rofdp.idprocedimento) from cli.pessoa pe
JOIN cli.consulta c on pe.idpessoa = c.iddentista
join cli.rodontogramafacedente rofd on c.idodontograma = rofd.idodontograma
join cli.rodontogramafacedenteprocedimento rofdp on rofdp.iddente = rofd.iddente and rofdp.idtipoface = rofd.idtipoface and rofdp.idodontograma = rofd.idodontograma
join cli.procedimento p on p.idprocedimento = rofdp.idprocedimento
where rofdp.status = 'F'  and (extract (month from c.dataconsulta) = (extract (month from current_date)-1)) 
GROUP BY pe.nome
ORDER BY pe.nome;

-- select * from cli.comissaoDentistas;

-- relacao dos pacientes mais fieis do ultimo ano

CREATE OR REPLACE view cli.pacientesfieis (paciente, telefone, atendimentos) as
select p.nome, p.telefone, count(rofdp.idprocedimento) from cli.pessoa p
JOIN cli.consulta c on p.idpessoa = c.idpaciente
join cli.rodontogramafacedente rofd on c.idodontograma = rofd.idodontograma
join cli.rodontogramafacedenteprocedimento rofdp on rofdp.iddente = rofd.iddente and rofdp.idtipoface = rofd.idtipoface and rofdp.idodontograma = rofd.idodontograma
join cli.procedimento t on t.idprocedimento = rofdp.idprocedimento
where rofdp.status = 'F' and (current_date-c.dataconsulta<360)
GROUP BY p.nome, p.telefone
ORDER BY 3 desc;
-- select * from cli.pacientesfieis;

-- View utilizada para fazer a inserção com o Instead OF, criada para facilitar a consulta do medicamento prescrito pelo dentista

CREATE OR REPLACE VIEW cli.receitaPaciente (Consulta, Paciente, Medicamento, FormaDeUso)
AS SELECT c.idconsulta, p.nome, m.nome, rm.formauso FROM cli.Pessoa p
JOIN cli.consulta c ON c.idpaciente = p.idpessoa
JOIN cli.receita r ON r.idconsulta = c.idconsulta
JOIN cli.rReceitaMedicamento rm ON rm.idreceita = r.idreceita
JOIN cli.medicamento m ON m.idmedicamento = rm.idmedicamento;

/*INSERT INTO cli.receitaPaciente VALUES (5, 'Rita Lee', 'Amoxilina', '2x ao dia');
select * from cli.receitaPaciente
SELECT * FROM cli.rReceitaMedicamento*/

-- PERMISSAO PARA UM USUARIO
GRANT Select on cli.comissaodentistas to projetobdiiuser;	