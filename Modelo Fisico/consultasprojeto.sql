-- CONSULTA 1 - VER HISTORICO DE ANAMNESE DOS PACIENTES

SELECT p.nome, c.dataConsulta, a.diabetica, a.cardiaca, a.descAlergiaMed from cli.pessoa p 
JOIN cli.consulta c on p.idpessoa = c.idpaciente
join cli.anamnese a on a.idanamnese = c.idanamnese
ORDER BY p.nome;  

-- CONSULTA 2 - RELATORIO DE IMAGENS POR PACIENTE

SELECT p.nome, i.tipo, i.urlimagem from cli.pessoa p
join cli.imagem i on p.idpessoa = i.idpaciente
order by p.nome;

-- CONSULTA 3 - RELATORIO DE PROCEDIMENTOS "NAO FINALIZADOS" POR PACIENTES

SELECT p.nome, t.descricao, rofp.status,d.descricao,tf.descricao from cli.pessoa p 
JOIN cli.consulta c on p.idpessoa = c.idpaciente
join cli.rodontogramafacedente rofd on c.idodontograma = rofd.idodontograma
join cli.facedente fd on fd.iddente = rofd.iddente
join cli.dente d on d.iddente = fd.iddente
join cli.tipoface tf on tf.idtipoface = fd.idtipoface
join cli.rodontogramafacedenteprocedimento rofp on rofp.iddente = rofd.iddente
join cli.procedimento t on t.idprocedimento = rofp.idprocedimento
ORDER BY p.nome;

-- CONSULTA 4 - RELATORIO DOS FUNCIONARIOS CADASTRADOS

SELECT matricula, nome, dataAdmissao from cli.pessoa 
where tipo = 'F';

-- CONSULTA 5 - NUMERO DE ATENDIMENTOS POR DENTISTA

SELECT p.nome, count(c.idconsulta) from cli.pessoa p
join cli.consulta c on p.idpessoa = c.iddentista
where c.dataconsulta < current_date
group by p.nome
order by 2;

-- CONSULTA 6 - QUANTIDADE DE PACIENTES POR PLANOS E SEUS DESCONTOS

SELECT c.descconvenio,c.taxadesconto,count (p.idconvenio) from cli.convenio c
join cli.pessoa p on c.idconvenio = p.idconvenio
group by c.descconvenio,c.taxadesconto
order by 3 desc;

-- CONSULTA 7 - PROXIMAS CONSULTAS AGENDADAS DOS PROXIMOS 7 DIAS

SELECT c.dataconsulta, pac.nome, dent.nome from cli.consulta c
join cli.pessoa pac on c.idpaciente = pac.idpessoa
join cli.pessoa dent on c.iddentista = dent.idpessoa
where (c.dataconsulta > Current_date) and (c.dataconsulta < (current_date+interval '7 days'))
order by c.dataconsulta;

-- CONSULTA 8 - ANIVERSARIANTES DOs proximos 30 dias

SELECT p.nome, to_char(p.datan,'DD/MM'), p.telefone from cli.pessoa p
where (extract (month from age(current_date,p.datan)) = 11)
order by 2 DESC;

-- CONSULTA 9 - RELACAO DE PACIENTES COM DIAGNOSTICO DE DOENÇAS E SEM CONSULTAS AGENDADAS

SELECT p.nome, p.telefone,d.descricao,tf.descricao, diag.descricao FROM cli.pessoa p
JOIN cli.consulta c on p.idpessoa = c.idpaciente
join cli.rodontogramafacedente rofd on c.idodontograma = rofd.idodontograma
join cli.facedente fd on fd.iddente = rofd.iddente
join cli.dente d on d.iddente = fd.iddente
join cli.tipoface tf on tf.idtipoface = fd.idtipoface
join cli.rodontogramafacedentediagnostico rfdd on rfdd.iddente = fd.iddente
join cli.diagnostico diag on diag.iddiagnostico = rfdd.iddiagnostico
where c.idpaciente not in (SELECT c.idpaciente from cli.consulta c
				where c.dataconsulta > Current_date); 

-- CONSULTA 10 - RELACAO DE PACIENTES NAO ATENDIDOS A MAIS DE 6 MESES

SELECT p.nome, p.telefone,c.dataconsulta FROM cli.pessoa p
JOIN cli.consulta c on p.idpessoa = c.idpaciente
where c.idpaciente not in (SELECT c.idpaciente from cli.consulta c
				where c.dataconsulta > Current_date)
		   and (current_date-c.dataconsulta>180); 
