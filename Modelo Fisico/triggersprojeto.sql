-- Criação de TRIGGERS

-- Maneira simples de cadastrar a receita do paciente, utilizando a view cli.receitaPaciente

CREATE OR REPLACE FUNCTION cli.adicionaReceita () RETURNS TRIGGER
AS $$
DECLARE
	contadorReceita integer;
	contadorMedicamento integer;
BEGIN
	SELECT Coalesce(MAX(idreceita),0)+1 INTO contadorReceita FROM cli.receita;
	SELECT idmedicamento INTO STRICT contadorMedicamento FROM cli.medicamento WHERE nome = new.medicamento;
	INSERT INTO cli.receita VALUES (contadorReceita, new.consulta);
	INSERT INTO cli.rReceitaMedicamento VALUES (contadorReceita, contadorMedicamento, new.FormaDeUso);
	RETURN NEW;
	EXCEPTION
		WHEN no_data_found THEN
			SELECT Coalesce(MAX(idmedicamento),0)+1 INTO contadorMedicamento FROM cli.medicamento;
			INSERT INTO cli.medicamento VALUES (contadorMedicamento, new.medicamento);
			SELECT idmedicamento INTO STRICT contadorMedicamento FROM cli.medicamento WHERE nome = new.medicamento;
			INSERT INTO cli.receita VALUES (contadorReceita, new.consulta);
			INSERT INTO cli.rReceitaMedicamento VALUES (contadorReceita, contadorMedicamento, new.FormaDeUso);
			RETURN NEW;
		WHEN OTHERS THEN
			RAISE NOTICE 'Erro desconhecido!';
			RETURN NULL;
END $$ language 'plpgsql';


CREATE TRIGGER geraReceitaPaciente INSTEAD OF INSERT ON cli.receitaPaciente
FOR EACH ROW EXECUTE PROCEDURE cli.adicionaReceita();



-- 2º Trigger

CREATE TABLE cli.faceDenteVersao (
	idFaceDentePaciente INTEGER,
	idFaceVersao VARCHAR(1),
	idDenteVersao INTEGER,
	tipoProcedimento VARCHAR(50),
	descricaoProcedimento TEXT,
	diagnostico VARCHAR(50),
	dataConsulta DATE
);


CREATE OR REPLACE FUNCTION cli.geraVersaoOdontograma () RETURNS TRIGGER
AS $$
DECLARE
	registro cli.faceDenteVersao%ROWTYPE;
BEGIN	
	SELECT c.idpaciente, ofdp.idtipoface, ofdp.iddente, ofdp.observacao, p.descricao, d.descricao, c.dataconsulta
		INTO registro.idFaceDentePaciente, registro.idFaceVersao, registro.idDenteVersao, registro.descricaoProcedimento,
		registro.tipoProcedimento, registro.diagnostico, registro.dataConsulta FROM cli.rOdontogramaFaceDenteProcedimento ofdp
		JOIN cli.procedimento p ON p.idprocedimento = ofdp.idprocedimento
		JOIN cli.rOdontogramaFaceDente ofd ON ofd.idtipoface = ofdp.idtipoface AND ofd.iddente = ofdp.iddente AND ofd.idodontograma = ofdp.idodontograma
		JOIN cli.rOdontogramaFaceDenteDiagnostico ofdd ON ofd.idtipoface = ofdd.idtipoface AND ofd.iddente = ofdd.iddente AND ofd.idodontograma = ofdd.idodontograma
		JOIN cli.diagnostico d ON ofdd.iddiagnostico = d.iddiagnostico
		JOIN cli.odontograma o ON o.idodontograma = ofd.idodontograma
		JOIN cli.consulta c ON c.idodontograma = o.idodontograma
		WHERE new.idprocedimento = ofdp.idprocedimento and new.idtipoface = ofdp.idtipoface AND new.iddente = ofdp.iddente;	

	INSERT INTO cli.faceDenteVersao VALUES (registro.idFaceDentePaciente, registro.idFaceVersao, registro.idDenteVersao,
					registro.tipoProcedimento, registro.descricaoProcedimento,
					registro.diagnostico, registro.dataConsulta);
	RETURN NEW;
END $$ language 'plpgsql';

CREATE TRIGGER guardaVersaoFaceDenteProcedimento AFTER INSERT ON cli.rodontogramafacedenteprocedimento
FOR EACH ROW EXECUTE PROCEDURE cli.geraVersaoOdontograma();

-- 3º Trigger

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
	UPDATE cli.documento set texto = txt where new.iddocumento = iddocumento;
	return new;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER acionaTriggerCriaTexto AFTER UPDATE OF iddocumento ON cli.consulta 
FOR EACH ROW EXECUTE PROCEDURE cli.criarTextoDocumento();