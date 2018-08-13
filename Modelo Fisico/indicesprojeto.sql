-- INDICES SUGERIDOS

-- INDICE NA COLUNA TELEFONE DE PESSOA
-- drop index telefonePessoa;

create index telefonePessoa on cli.pessoa(telefone);

-- justificativa: para facilitar a busca de um paciente pelo número do telefone, uma vez que todos os telofones sao distintos;

-- INDICE NA COLUNA DATA DA CONSULTA EM CONSULTA

-- drop index dataConsulta;

create index dataConsulta on cli.consulta (dataconsulta);

-- justificativa: coluna muito utilizada nas consultas e é um campo que é consultado em forma de intervalo

-- INDICE NA COLUNA TIPO DE PESSOA

-- drop index tipoPessoa;

create index tipoPessoa on cli.pessoa(tipo);

-- justificativa: coluna muito utilizada em consultas, where, join e tabela volumosa;