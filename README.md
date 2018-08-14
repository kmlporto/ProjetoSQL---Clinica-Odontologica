#Projeto NoSQL
---
## Descrição

Este projeto apresenta uma modelagem de banco de dados relacional usando SQL para um sistema de gerenciamento de clínica especializada odontologica. O sistema deverá realizar o controle dos atendimentos e agendamentos dos pacientes de uma clínica odontológica. </p> 

## Modelo Conceitual
![Modelo Conceitual](https://github.com/kmlporto/ProjetoSQL---Clinica-Odontologica/blob/master/Modelo%20Conceitual/Conceitual.png)


## Requisitos

### Privilégios e segurança:
-[x] Criação de 02 usuários – um será o owner do BD; o outro irá ter acesso a alguns objetos
-[x] Criação do BD e sua associação a um usuário (owner)
### Objetos básicos:
-[x] Tabelas e constraints (PK, FK, UNIQUE, campos que podem ter valores nulos, checks de validação) de acordo com projeto.
-[x] 10 consultas variadas de acordo com requisitos da aplicação, ou seja, com justificativa semântica.
### Visões:
-[x] 01 visão que permita inserção
-[x] 02 visões robustas (por exemplo, com vários joins) com justificativa semântica, de acordo com os requisitos da aplicação.	
-[x] Prover acesso a uma das visões para consulta (para usuário 02).
### Índices
-[x] 03 índices para campos indicados (além dos referentes às PKs) com justificativa.
### Funções:
-[x] 01 função que use SUM, MAX, MIN, AVG ou COUNT
-[x] Mais 03 funções com justificativa semântica, dentro dos requisitos da aplicação
-[x] Prover acesso de execução de uma das funções (para usuário 02)
### Triggers
-[x] 03 diferentes triggers com justificativa semântica, de acordo com os requisitos da aplicação.