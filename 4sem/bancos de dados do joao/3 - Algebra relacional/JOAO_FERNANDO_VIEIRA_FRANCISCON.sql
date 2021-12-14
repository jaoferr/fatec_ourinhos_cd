-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- Seleção
   -- AR: Destino <-  tab[[condição]]
   -- SQL
   select * from funcionarios where txprenomes like '%JO%';
   -- combinando com o CREATE TABLE...
   create temporary table r as (select * from funcionarios where txprenomes like '%JO%');
   select * from r where 1=1; -- este comando lê os dados de TODA a Tabela (pois, em todas as linhas o 1=1)
   select * from r; -- aqui foi omitido o subcommando where... portanto TODAS as linhas tem o verdadeiro como resposta.
   drop table r; -- removendo a tabela r (mesmo que seja temporária)
   -- outro exemplo usando o where 1=1
   select * from funcionarios where 1=1;
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- Projeção
   -- AR: Destino <- tab[[lista de campos]] 
   -- SQL
   select 
   	a.pkareaestudo,
   	a.dtcadareaestudo,
	a.txdescricaoarea,
	a.txnomearea
	
   from
   	areaestudo a;
   -- criando a tabela temporaria r (novamente, pois foi 'dropada' anteriormente
   create temporary table r as (   
	   select 
	   	a.pkareaestudo,
   		a.dtcadareaestudo,
		a.txdescricaoarea,
		a.txnomearea
	   from
	   	areaestudo a
   	);
   select * from r;
   drop table r;
   -- -----------------------------------------------------------------------------------------------------------------
   -- No SQL podemos 'combinar comandos' escritos em operações separadas da AR.
   -- exemplo:
   -- r<- funcionarios[[fkfuncao dentre '10','7']]
      create temporary table r as (   
	   	select 
	   		a.pkareaestudo,
   			a.dtcadareaestudo,
			a.txdescricaoarea,
			a.txnomearea
	   	from
	   		areaestudo a
  	    where
		    a.pkareaestudo BETWEEN 10 and 30);
   -- r[[pkfuncionario, txprenomes, txsobrenome]]
   select * from r;
   drop table r;
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- Produto Cartesiano
   -- AR: R <- A X B
   -- SQL: select * from A, B -- SQL:1987
   --      select * from A CROSS JOIN B -- SQL:1992
   -- Exemplo:
   select * from areaestudo, areaestudocursos; -- SQL:1987
   -- combinando projeção e produto cartesiano
   select *
          from areaestudo cross join areaestudodisciplinas; -- SQL:1992
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- Junção Natural (fechada)
   -- AR: r <- a[[condição]]b
   -- SQL: select * from tab1, tab2 where tab1.campo=tab2.campo; -- SQL:1987
   --      select * from tab1 INNER JOIN tab2 on tab1.campo=tab2.campo; -- SQL:1982
   -- Exemplo: Já combinados os de exemplo com a operação de projeção
   
   select 
   		b.txnomebairro,
		cd.txnomecidade,
		cd.fkestadodopais
   from 
   		bairros as b, 
		cidades as cd
   where 
   		b.fkcidade = cd.pkcidade; -- SQL:1987
   
   select 
   		b.*,
		cd.txnomecidade
   from 
   		cidades as cd
		inner join bairros as b ON cd.pkcidade = b.fkcidade; -- SQL:1992
		
   -- --------------------------------------------------------------------------------------------------------------------
   -- É possível realizar a junção de três tabelas (com ambas as sintaxes de SQL)
   -- para responder: quais são os nomes de gerentes e seus subalternos para
   -- os departamentos com código do gerente entre os valores 230, 260 ou 290?
   -- AR: T1 <- funcionarios->f1[[pkfuncionario dentre '230','260','290']]
   --     T2 <- T1[[T1.pkfuncionario=d.fkfuncionariogerente]]departamentos -> d
   --     T3 <- T2[[T2.pkdepto=f2.fkdepto]]funcionarios ->  f2
   --     T3[[f1.pkfuncionario,f1.txprenomes, f1.txsobrenome,d.txnomedepto,f2.txprenomes, f2.txsobrenome]]
   --       {ordenado por f1.pkfuncionario}
   -- Como exercício, traduza os comandos de AR para SQL.
   -- Em SQL podemos escrever:
   select
   		d.txnomedepto,
   		concat(f.txprenomes, ' ', f.txsobrenome) as gerente,
		concat(f2.txprenomes, ' ', f2.txsobrenome) as subalterno

   from
   		funcionarios f
		inner join departamentos d on f.pkfuncionario = d.fkfuncionariogerente  -- gerente do departamento
		left join funcionarios f2 on d.pkdepto = f2.fkdepto  -- subalterno, mesmo aqueles deptos que nao tem
		
   where
   		d.fkfuncionariogerente in ('230', '260', '290')
   order by
   		f.pkfuncionario
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- Junção Aberta pela Esquerda
   -- AR: R <- A][condição]]B
   -- SQL: select * from tab1 LEFT JOIN tab2 ON <cindição>
   -- Exemplo:
   -- junção aberta pela ESQUERDA (combinado com projeção de campo do conjunto montado)
   select 
   		c.txnomecliente,
		c.nucep,
		c.txcomplemento,
		l.fkbairro,
		l.txnomelogradouro
   from clientes as c 
   LEFT join logradouros as l on c.fklogradouro = l.pklogradouro  -- todas as linhas da tabela da esquerda, clientes
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- Junção Aberta pela Direita
   -- AR: R <- A[[condição][B
   -- SQL: select * from tab1 RIGHT JOIN tab2 ON <cindição>
   -- Exemplo:
   -- junção aberta pela DIREITA (combinado com projeção de campo do conjunto montado)
   select 
   		c.txnomecliente,
		c.nucep,
		c.txcomplemento,
		l.fkbairro,
		l.txnomelogradouro
   from clientes as c 
   RIGHT join logradouros as l on c.fklogradouro = l.pklogradouro  -- todas as linhas da tabela da direita,  logradouro
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------
-- Junção Completa (Aberta pela Esq<->Dir)
   -- AR: R <- A][condição][B
   -- SQL: select * from tab1 FULL OUTER JOIN tab2 ON <cindição>
   -- Exemplo:
   -- Junção Completa (Aberta pelos DOIS Lados) (combinado com projeção de campo do conjunto montado)
   select 
   		c.txnomecliente,
		c.nucep,
		c.txcomplemento,
		l.fkbairro,
		l.txnomelogradouro
   from clientes as c 
   FULL outer join logradouros as l on c.fklogradouro = l.pklogradouro   -- todas as linhas de ambas as tabelas
