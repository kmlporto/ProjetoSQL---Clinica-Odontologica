-- CRIACAO E RESTART DO PROJETO (RODAR NO DB POSTGRES)

-- -----------------------------------------------------
-- Restart projeto (executar apenas esses comandos);

-- executar apenas o comando drop database e depois os drop user;
-- 
-- DROP Database "ClinicaOdonto"; 

-- 
DROP user projetoBDIIowner;
DROP user projetoBDIIuser;

-- -----------------------------------------------------
-- Criacao de Usuarios (os comandos de criacao/drop database devem ser realizados isoladamente);
-- -- 
CREATE ROLE projetoBDIIowner LOGIN PASSWORD 'bd2'
 superuser VALID UNTIL 'infinity';

CREATE ROLE projetoBDIIuser LOGIN PASSWORD 'bd2';
-- 
-- -----------------------------------------------------
-- DataBase (os comandos database devem ser realizados isoladamente)
-- 
CREATE DATABASE "ClinicaOdonto"
  WITH OWNER = projetoBDIIowner
