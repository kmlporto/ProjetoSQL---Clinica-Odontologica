-- FUNCOES DO PROJETO 


-- Funcao usando max,min,count,sum;


-- Funcao para localizar uma pessoa pelo telefone

CREATE OR REPLACE function cli.localizarPessoaFone (vtelefone int) 
returns int as 
$$
DECLARE 
vidpaciente cli.pessoa.idpessoa%type;
BEGIN
	select idpessoa into strict vidpaciente from cli.pessoa
	where vtelefone = telefone;
	return vidpaciente;
EXCEPTION
	when no_data_found then
		raise exception 'Pessoa não localizada!';
		return -1;
	when others then
		raise notice '% %', sqlerrm, sqlstate;
		return -1;
END;
$$ language 'plpgsql';

--SELECT cli.localizarPessoaFone(88904258);

-- funcao para agendar consulta

CREATE OR REPLACE function cli.AgendaConsulta (pTelefone int, dTelefone int, vdataconsulta date)
returns void as 
$$
DECLARE 
viddentista cli.pessoa.idpessoa%type;
vidpaciente cli.pessoa.idpessoa%type;
vmaxidconsulta cli.consulta.idconsulta%type;
BEGIN
	viddentista := (select cli.localizarPessoaFone(dTelefone));
	vidpaciente := (select cli.localizarpessoafone (ptelefone));
	if (select tipo from cli.pessoa where idpessoa=viddentista)!='D' then
		raise exception 'favor informar um numero de telefone de dentista valido';end if;
	if (select tipo from cli.pessoa where idpessoa=vidpaciente)!='P' then
		raise exception 'favor informar um numero de telefone de paciente valido';end if;	
	vmaxidconsulta := (select max(idconsulta) from cli.consulta);
	if vmaxidconsulta is null then
		vmaxidconsulta := 1;
	else
		vmaxidconsulta := vmaxidconsulta+1; end if;
	if vdataconsulta > current_date then
		insert into cli.consulta (idpaciente,iddentista,dataconsulta,idconsulta) 
		values (vidpaciente,viddentista,vdataconsulta,vmaxidconsulta);
	else
		raise exception 'Data inferior a data atual';end if;
EXCEPTION
	when others then
		raise notice '% %', sqlerrm, sqlstate;
END;
$$ language 'plpgsql';

select cli.AgendaConsulta (991550618,988690583,'2018-07-25');

select * from cli.consulta;
-- funcao para cadastro de pacientes rapidos

CREATE OR REPLACE function cli.cadastrorapidopaciente (
							pcpf cli.pessoa.cpf%type,
							pnome cli.pessoa.nome%type,
							ptelefone cli.pessoa.telefone%type
							)
RETURNS VOID AS
$$ 
DECLARE
pidpaciente int;
BEGIN 
	pidpaciente := (select max(idpessoa) from cli.pessoa);
	if pidpaciente is null then
		pidpaciente := 1;
	else
		pidpaciente := pidpaciente+1; end if;
	insert into cli.pacientes values (pidpaciente,pcpf,pnome,ptelefone,'P');
exception
	when others then
		raise notice '% %', sqlerrm, sqlstate;
end;
$$ language 'plpgsql';


-- Gerar um odontograma modelo, com a dentes deciduos ou permanentes

CREATE OR REPLACE FUNCTION cli.geraOdontogramaSimples (codigoConsulta integer, tipo VARCHAR(20)) RETURNS VOID
AS $$
DECLARE
	cursor_facedente CURSOR (inicio int, fim int) FOR SELECT * FROM cli.faceDente WHERE iddente > inicio and iddente <= fim;
	consultaRegistro cli.consulta%ROWTYPE;
	contadorOdontograma integer;
BEGIN
	SELECT * INTO consultaRegistro FROM cli.consulta WHERE codigoConsulta = idConsulta;
	IF (consultaRegistro.idodontograma IS NULL) THEN
		SELECT coalesce(MAX(idodontograma),0)+1 INTO contadorOdontograma FROM cli.odontograma;
		INSERT INTO cli.odontograma VALUES (contadorOdontograma);
		UPDATE cli.consulta SET idodontograma = contadorOdontograma WHERE idconsulta = codigoConsulta;
		consultaRegistro.idodontograma = contadorOdontograma;	
		IF (tipo = 'permanente') THEN
			FOR v IN cursor_facedente(11,49) LOOP
				INSERT INTO cli.rOdontogramaFaceDente VALUES (consultaRegistro.idodontograma, v.idtipoface, v.iddente);
			END LOOP;
		ELSE
			FOR v IN cursor_facedente(51,85) LOOP
				INSERT INTO cli.rOdontogramaFaceDente VALUES (consultaRegistro.idodontograma, v.idtipoface, v.iddente);
			END LOOP;
		END IF;
	ELSE
		RAISE NOTICE 'Já existe um odontograma vinculado ao paciente!';
	END IF;
END $$ language 'plpgsql';

-- Função criada para gerar Documento (declaração ou atestado), necessita de um trigger AFTER UPDATE no campo iddocumento na tabela Consulta

CREATE OR REPLACE FUNCTION cli.criarDocumento(idcon cli.consulta.idconsulta%TYPE, tip cli.documento.tipodocumento%TYPE, vdias INT DEFAULT 0) RETURNS void
AS $$
declare viddoc cli.documento.iddocumento%type;
BEGIN
	select coalesce (max(iddocumento),0)+1 into strict viddoc from cli.documento;
	INSERT INTO cli.documento(iddocumento, tipodocumento, dias) VALUES (viddoc,tip, vdias);
	UPDATE cli.consulta set iddocumento = viddoc where idconsulta = idcon; 
END;
$$ LANGUAGE 'plpgsql';


-- PROVENDO ACESSO AO USUARIO projetobdiiuser

-- GRANT SELECT ON cli.cadastrorapidopaciente to projetobdiiuser;