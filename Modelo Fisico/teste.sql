CREATE OR REPLACE FUNCTION cli.criarTextoDocumento() RETURNS TRIGGER
AS $$
DECLARE
	nome_pessoa cli.pessoa.nome%type;
	cpf_pessoa cli.pessoa.cpf%type;
	logradouro_pessoa cli.pessoa.logradouro%type;
	bairro_pessoa cli.pessoa.bairro%type;
	
	nasc_pessoa cli.pessoa.datan%type;
	data_consulta cli.consulta.dataConsulta%type;
	tipo_documento cli.documento.tipodocumento%type;
	cro_dentista cli.pessoa.cro%type;
	nome_dent cli.pessoa.nome%type;
	dias_att cli.documento.dias%type;
	txt text;
	
BEGIN
	SELECT p1.nome, p1.cpf, p1.datan, p1.logradouro, p1.bairro, c.dataConsulta, d.tipodocumento, p2.nome, p2.cro, d.dias INTO nome_pessoa, cpf_pessoa, nasc_pessoa, logradouro_pessoa, bairro_pessoa, data_consulta, tipo_documento, nome_dent, cro_dentista, dias_att 
	FROM cli.pessoa p1 
	JOIN cli.consulta c ON p1.idpessoa = c.idpaciente
	JOIN cli.pessoa p2 ON p2.idpessoa = c.iddentista
	JOIN cli.documento d ON c.iddocumento = d.iddocumento
	WHERE d.iddocumento = new.iddocumento; 
	
	IF tipo_documento = 'A' THEN
		txt := 'ATESTADO MÉDICO, Atesto para os devidos fins, que o(a) senhor(a) ' || nome_pessoa || ', inscrito no CPF nº ' || coalesce(cpf_pessoa,'-') || ', residente no endereço '
		|| coalesce(logradouro_pessoa,'-') || ', no bairro ' || coalesce(bairro_pessoa,'-') ||', paciente sob os meus cuidados, foi atendido no dia ' || data_consulta || ' e necessita de'|| dias_att || 'dias de repouso. Assinatura:'
		|| nome_dent || ', cro n: ' || cro_dentista; 
	ELSE 
		txt = 'DECLARAÇÃO MÉDICA, Declaro para os devidos fins, que o(a) senhor(a) ' || nome_pessoa || ', inscrito no CPF nº ' || cpf_pessoa || ', residente no endereço '
		|| logradouro_pessoa || ', no bairro ' ||bairro_pessoa ||', paciente sob os meus cuidados, foi atendido no dia ' || data_consulta || nome_dent || ', cro n: ' || cro_dentista; 
	END IF;
	raise notice '%', txt;	
	UPDATE cli.documento set texto = txt where new.iddocumento = iddocumento;
	return new;
END;
$$ LANGUAGE 'plpgsql';





CREATE OR REPLACE FUNCTION cli.criarDocumento(idcon cli.consulta.idconsulta%TYPE, tip cli.documento.tipodocumento%TYPE, vdias INT DEFAULT 0) RETURNS void
AS $$
declare viddoc cli.documento.iddocumento%type;
BEGIN
	select coalesce (max(iddocumento),0)+1 into strict viddoc from cli.documento;
	INSERT INTO cli.documento(iddocumento, tipodocumento, dias) VALUES (viddoc,tip, vdias);
	UPDATE cli.consulta set iddocumento = viddoc where idconsulta = idcon; 
END;
$$ LANGUAGE 'plpgsql';




CREATE TRIGGER acionaTriggerCriaTexto AFTER UPDATE OF iddocumento ON cli.consulta 
FOR EACH ROW EXECUTE PROCEDURE cli.criarTextoDocumento();


