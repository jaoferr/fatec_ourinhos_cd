-- Estudo de Caso - 2
-- Proposta do Segundo Estudo de Caso da Disciplina:
-- Forme seu grupo com 3 alunos. Escolha um dos DataSet e informe ao professor:
-- "NetFlix Prize Data".
-- "Hourly Energy Consumption".
-- "Daily Temperature of Major Cities".
-- "Udemy Courses".
-- "Food.com Recipes and Interactions".
-- "Goodreads Book Datasets with user rating 2M".
-- "Data Scientist Job MArket in the U.S.".
-- "Google-Landmarks DataSet".
-- "Spotify's Worldwide Daily Song Ranking"
-- 
-- NÃO é Permitido dois Grupos distintos trabalharem sobre o mesmo DataSet.
-- Escreva os comandos que criam as tabelas de uma base de dados para receber os dados.
-- Importe os dados dos arquivos do Dataset que vocês escolheram.
-- Faça uma análise e escreva uma sinopse interpretando o conteúdo da base de dados.
-- Escreva pelo menos 5 perguntas que explorem os dados desta base de dados.
-- Para cada pergunta escreva a AR e os correspondentes comandos SQL.
-- De modo complementar, para cada pergunta, escreva uma variação do comando SQL.

-- Teste seus comandos SQL no ambiente do pgAdmin 4.
-- Escreva TODO seu trabalho em um arquivo em formato .SQL como ESTE arquivo (apresentando o trabalho).
-- Neste arquivo devem constar os nomes e matrículas dos alunos que desenvolveram o trabalho, no cabeçalho do arquivo, seguindo o modelo:
-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Analise e desenvolvimento de Perguntas sobre DataSets.
-- Alunos:
-- Matrícula    | Nome
-- 211352013038 | Danielle Regina Bernardes
-- 211352013028 | Fernando Rafael Araujo
-- 211352013012 | Joao Fernando Vieira Franciscon
--
-- Dataset escolhido: "hourly_energy_consumption"
-- URL: https://www.kaggle.com/robikscube/hourly-energy-consumption?select=pjm_hourly_est.csv
--
-- --------------------------------------------------------------------------------------------------------------------
-- 1. Comandos de Criação e Importação das Tabelas:
-- --------------------------------------------------------------------------------------------------------------------
--
-- Tabela temporária para importação e limpeza dos dados antes de inserir no banco de maneira definitiva
CREATE TEMP TABLE IF NOT EXISTS hourly_energy_consumption_temp
(
	timestamp timestamp,
	AEP double precision,
	COMED double precision,
	DAYTON double precision,
	DEOK double precision,
	DOM double precision,
	DUQ double precision,
	EKPC double precision,
	FE double precision,
	NI double precision,
	PJME double precision,
	PJMW double precision,
	PJM_Load double precision

) TABLESPACE pg_default;

-- Importação do .csv
COPY hourly_energy_consumption_temp FROM 'C:\Users\jfvff\Desktop\facfldade\4sem\bancos de dados do joao\EC02\data\pjm_hourly_est.csv' DELIMITER ',' CSV HEADER;

-- Tabela definitiva
CREATE TABLE IF NOT EXISTS public.hourly_energy_consumption
(
	timestamp timestamp,
	region character varying(35) COLLATE pg_catalog."default",
	estimated_consumption double precision
) TABLESPACE pg_default;

-- Inserção de dados na tabela definitiva
INSERT INTO public.hourly_energy_consumption
	(
		SELECT  -- Transformação das colunas em linhas
			timestamp,
			UNNEST(ARRAY['AEP', 'COMED', 'DAYTON', 'DEOK', 'DOM', 'DUQ', 'EKPC', 'FE', 'NI', 'PJME', 'PJMW', 'PJM_Load']) AS key,
			UNNEST(ARRAY[AEP, COMED, DAYTON, DEOK, DOM, DUQ, EKPC, FE, NI, PJME, PJMW, PJM_Load]) as value
		FROM hourly_energy_consumption_temp
	);

-- Remoção tabela temporária
DROP TABLE hourly_energy_consumption_temp
--
--
-- --------------------------------------------------------------------------------------------------------------------
-- 3. Perguntas sobre as Tabelas da Base de Dados
-- --------------------------------------------------------------------------------------------------------------------    

/* COMEÇA AQUI */
-- Faça uma análise e escreva uma sinopse interpretando o conteúdo da base de dados.
-- Dataset: "Hourly Energy Consumption"
-- O Dataset escolhido apresenta dados referentes ao consumo de energia registrado por 
-- operadoras de transmissão da região oriental dos Estados Unidos, composto por estados 
-- como Delaware, Illinois, Maryland, New Jersey e Pennsylvania.
-- Cada operadora representa uma subregião
-- exemplo: "DOM" = "Dominion Virginia Power", estado da virginia
--			"EKPC" = "East Kentucky Power Cooperative", leste do Kentucky
-- As operadoras "PJME", "PJMW" e "PJM_Load" tratam-se se agregações das outras operadoras.
-- O Dataset inclui dados de 01/04/1998 até 03/08/2018, contudo, informações individuais de cada operadora só estão disponíveis
-- a partir de 2004, até esta data, apenas agregações com todas as regiões estão disponíveis.
-- Iremos desconsiderar o terceiro trimestre de 2018, pois o mesmo encontra-se incompleto.

-- --------------------------------------------------------------------------------------------------------------------
-- 1.O consumo das operadoras mudou ao longo do período analisado? É possível identificar uma tendência?
-- --------------------------------------------------------------------------------------------------------------------
-- Resposta: Sim, o consumo de eletricidade aumentou mais de 300% ao longo do período.
-- Entre 1998 e 2005 a tendencia foi de aumento, indo de 119 milhões MW para 400 milhões MW.
-- Contudo, a partir de 2005 o consumo mostrou-se relativamente estavel, iniciando 2018 com 410 milhões MW.

--    AR:
-- H <- hourly_energy_consumption[["timestamp" < '2018-06-30']]
-- I <- H[[DATE_PART('year', H."timestamp") -> ano, 
--	   DATE_PART('quarter', H."timestamp") -> trimestre, 
--         SOMA(H.estimated_consumption) -> soma_consumo]]
--        {agrupa por ano, trimestre}

--    SQL:
SELECT
	DATE_PART('year', h."timestamp") AS ano,
	DATE_PART('quarter', h."timestamp") AS trimestre,
	SUM(h.estimated_consumption) AS soma_consumo
FROM
	public.hourly_energy_consumption h
WHERE
	h."timestamp" < '2018-06-30'  -- tudo antes do terceiro trimestre de 2018

GROUP BY
	DATE_PART('year', h."timestamp"),
	DATE_PART('quarter', h."timestamp");

--    SQL Melhorado:
-- Aqui podemos ver que a mudança anual entre 2005 e 2018 foi pequena, entre -5% e +5%.
-- O ano de 2018, por não estar completo, apresenta uma mudança enganosa.
SELECT
	q.ano,
	q.soma_consumo,
	ROUND(((q.soma_consumo - q.soma_ano_anterior)/q.soma_ano_anterior)*100) AS mudanca
FROM
	(
	SELECT
		DATE_PART('year', h."timestamp") AS ano,
		SUM(h.estimated_consumption) AS soma_consumo,
		LAG(SUM(h.estimated_consumption)) OVER (ORDER BY DATE_PART('year', h."timestamp")) AS soma_ano_anterior
	FROM
		public.hourly_energy_consumption h
	WHERE
		h."timestamp" < '2018-06-30'  -- tudo antes do terceiro trimestre de 2018
	GROUP BY
		DATE_PART('year', h."timestamp")
	) Q
ORDER BY
	q.ano;

-- --------------------------------------------------------------------------------------------------------------------
-- 2.Qual o impacto das estações do ano no consumo de energia? Qual estação apresenta menor consumo? E qual apresenta a maior?
-- --------------------------------------------------------------------------------------------------------------------
-- Resposta: O terceiro trimestre do ano, que corresponde ao período do verão, apresenta o maior consumo de energia agregado ao longo dos anos,
-- seguido pelo primeiro trimestre, correspondente ao inverno no hemisfério norte.
-- A estação com o menor consumo é o outono, presente no quarto trimestre do ano.
-- Este padrão de consumo nos leva a concluir que a região possui um verão relativamente mais forte do que os invernos.

--    AR:
-- H <- hourly_energy_consumption[["timestamp" < '2018-06-30']]
-- I <- H[[DATE_PART('quarter', H."timestamp") -> trimestre, 
--         SOMA(H.estimated_consumption) -> consumo]]
--        {agrupa por trimestre}{ordena por consumo DECRESCENTE}

--    SQL:
SELECT 
	DATE_PART('quarter', h."timestamp") as trimestre,
	SUM(h.estimated_consumption) as consumo
	
FROM
	public.hourly_energy_consumption h

WHERE
	h."timestamp" < '2018-06-30'  -- tudo antes do terceiro trimestre de 2018

GROUP BY
	DATE_PART('quarter', h."timestamp")
ORDER BY
	SUM(h.estimated_consumption) DESC;

--    SQL Melhorado:
-- Na maioria dos anos, verão e inverno foram as estações com o maior consumo de energia.
SELECT 
	DATE_PART('year', h."timestamp"),
	SUM(CASE
		WHEN TO_CHAR(h."timestamp", 'MMDD') between '0321' and '0620' THEN h.estimated_consumption
		ELSE 0
	END) AS primavera,
	SUM(CASE
		WHEN TO_CHAR(h."timestamp", 'MMDD') between '0621' and '0922' THEN h.estimated_consumption
		ELSE 0
	END) AS verao,
	SUM(CASE
		WHEN TO_CHAR(h."timestamp", 'MMDD') between '0923' and '1220' THEN h.estimated_consumption
		ELSE 0
	END) AS outono,
	SUM(CASE
		WHEN TO_CHAR(h."timestamp", 'MMDD') between '0321' and '0620' THEN 0
		WHEN TO_CHAR(h."timestamp", 'MMDD') between '0621' and '0922' THEN 0
		WHEN TO_CHAR(h."timestamp", 'MMDD') between '0923' and '1220' THEN 0
		ELSE h.estimated_consumption
	END) AS inverno
	
FROM
	public.hourly_energy_consumption h
WHERE
	h."timestamp" < '2018-06-30'  -- tudo antes do terceiro trimestre de 2018
GROUP BY
	DATE_PART('year', h."timestamp");

-- --------------------------------------------------------------------------------------------------------------------
-- 3. Qual a operadora com o maior consumo de eletricidade agregado?
-- --------------------------------------------------------------------------------------------------------------------
-- Resposta: A AEP (American Electric Power) foi a maior consumidora de eletricidade, com 3,7 bilhões MW ao longo do tempo, 
-- seguida da DOM (Dominion Virginia Power) e da COMED (Commomwealth Edison), com 2,5 e 1,5 bilhões MW cada.

--    AR:
-- H <- hourly_energy_consumption[[h.region != 'PJME'  
--                                 E  h.region != 'PJMW'  
--                                 E  h.region != 'PJM_Load']]
-- I <- H[[H.region, SOMA(H.estimated_consumption) -> soma_consumo]]
--        {agrupa por H.region}{ordena por soma_consumo DECRESCENTE}

--    SQL:
SELECT
	h.region,
	SUM(h.estimated_consumption) as soma_consumo
FROM
	public.hourly_energy_consumption h
WHERE
	h.region NOT IN ('PJME', 'PJMW', 'PJM_Load')  -- ignorando as consolidações
GROUP BY
	h.region
ORDER BY
	SUM(h.estimated_consumption) DESC;

--    SQL Melhorado:
-- Podemos ver que, com exceção de 2004, a AEP foi a maior consumidora em todos os anos.
SELECT
	q.region,
	q.ano,
	q.soma_consumo

FROM(
	SELECT
		DATE_PART('year', h."timestamp") as ano,
		h.region,
		SUM(h.estimated_consumption) as soma_consumo,
		RANK() OVER (
			PARTITION BY DATE_PART('year', h."timestamp")
			ORDER BY SUM(h.estimated_consumption) DESC
		) AS rn

	FROM
		public.hourly_energy_consumption h
	WHERE
		h.region NOT IN ('PJME', 'PJMW', 'PJM_Load')  -- ignorando as consolidações
		AND h.estimated_consumption IS NOT NULL
	GROUP BY
		h.region,
		DATE_PART('year', h."timestamp")
) q

WHERE
	q.rn = 1

ORDER BY
	q.ano;

-- --------------------------------------------------------------------------------------------------------------------
-- 4. Qual a operadora com o consumo mais consistente (coeficiente de variação) ao longo do periodo?
-- --------------------------------------------------------------------------------------------------------------------
-- Resposta: A AEP é a operadora mais consistente, apresentando o menor coeficiente de variação (16,7),
-- seguida da FE (FirstEnergy), com 17.

--    AR:
-- H <- hourly_energy_consumption[[region != 'PJME'  
--                                 E  region != 'PJMW'  
--                                 E  region != 'PJM_Load'
--                                 E  estimated_consumption != NULL]]
-- I <- H[[H.region, MEDIA(H.estimated_consumption) -> media,
--         DESVIO_PADRAO(H.estimated_consumption) -> desvio_pad,
--         CALCULA(desvio_pad / media) -> coef_var]]
--        {agrupa por H.region}{ordena por coef_var}

--    SQL:
SELECT
	h.region,
	AVG(h.estimated_consumption) as media,
	STDDEV(h.estimated_consumption) as desvio_pad,
	(STDDEV(h.estimated_consumption) / AVG(h.estimated_consumption))*100 as coef_var

FROM
	public.hourly_energy_consumption h

WHERE
	h.region NOT IN ('PJME', 'PJMW', 'PJM_Load')  -- ignorando as consolidações
	AND h.estimated_consumption IS NOT NULL

GROUP BY
	h.region
	
ORDER BY
	(STDDEV(h.estimated_consumption) / AVG(h.estimated_consumption))*100;

--    SQL Melhorado:
-- Quando analisado ano a ano, a AEP aparece como operadora mais consiste na maioria dos anos,
-- exceto em:
-- 2009: onde a DUQ (Duquesne Light Co.) foi a mais consistente
-- 2011: onde a NI (Northern Illinois Hub) foi a mais consistente
-- 2014, 2015 e 2018: onde a FE foi a mais consistente.

SELECT
	q.ano,
	q.region,
	q.coef_var
FROM(
	SELECT
		DATE_PART('year', h."timestamp") as ano,
		h.region,
		AVG(h.estimated_consumption) as media,
		STDDEV(h.estimated_consumption) as desvio_pad,
		(STDDEV(h.estimated_consumption) / AVG(h.estimated_consumption))*100 as coef_var,
		RANK() OVER (
			PARTITION BY DATE_PART('year', h."timestamp")
			ORDER BY (STDDEV(h.estimated_consumption) / AVG(h.estimated_consumption))*100 ASC
		) AS rn
	
	FROM
		public.hourly_energy_consumption h

	WHERE
		h.region NOT IN ('PJME', 'PJMW', 'PJM_Load')  -- ignorando as consolidações
		AND h.estimated_consumption IS NOT NULL

	GROUP BY
		h.region,
		DATE_PART('year', h."timestamp")
) q

WHERE
	q.rn = 1;

-- --------------------------------------------------------------------------------------------------------------------
-- 5. Quais os horarios de pico, ou seja, com maior consumo de eletricidade?
-- --------------------------------------------------------------------------------------------------------------------
-- Resposta: Os horarios com maior consumo de eletricidade foram, em ordem decrescente, 19, 18 e 20 horas.
-- Os horarios com menor consumo de eletricidade foram, em ordem decrescente, 3, 5 e 4 horas.
-- Todos os horarios do dia mostraram uma consistencia parecida, com um coeficiente de variação entre 72 e 74.

--    AR:
-- H <- hourly_energy_consumption[[region != 'PJME'  
--                                 E  region != 'PJMW'  
--                                 E  region != 'PJM_Load'
--                                 E  estimated_consumption != NULL]]
-- I <- H[[DATE_PART('hour', H."timestamp") -> hora,
--         MEDIA(H.estimated_consumption) -> media,
--         SOMA(H.estimated_consumption) -> soma
--         DESVIO_PADRAO(H.estimated_consumption) -> desvio_pad,
--         CALCULA(desvio_pad / media) -> coef_var]]
--        {agrupa por hora}{ordena por media DECRESCENTE}

--    SQL:
SELECT
	DATE_PART('hour', h."timestamp") as hora,
	AVG(h.estimated_consumption) as media,
	SUM(h.estimated_consumption) as soma,
	STDDEV(h.estimated_consumption) as desvio_pad,
	(STDDEV(h.estimated_consumption) / AVG(h.estimated_consumption))*100 as coef_var

FROM
	public.hourly_energy_consumption h

WHERE
	h.region NOT IN ('PJME', 'PJMW', 'PJM_Load')  -- ignorando as consolidações
	AND h.estimated_consumption IS NOT NULL

GROUP BY
	DATE_PART('hour', h."timestamp")

ORDER BY
	AVG(h.estimated_consumption) DESC;

--    SQL Melhorado:
-- Ao longo dos trimestres, a hora de maior consumo muda: 
-- No terceiro e no segundo trimestre, correspondentes ao verão e a primavera, o pico é as 17 horas.
-- No primeiro e no quarto trimestre, correspondentes ao inverno e ao outono, o pico muda para as 20 horas.
-- É interessante notar que nenhum dos dois picos corresponde ao pico geral, que é as 19 horas.
SELECT
	q.trimestre,
	q.hora,
	q.media

FROM(
	SELECT
		DATE_PART('hour', h."timestamp") as hora,
		DATE_PART('quarter', h."timestamp") as trimestre,
		AVG(h.estimated_consumption) as media,
		RANK() OVER (
			PARTITION BY DATE_PART('quarter', h."timestamp"), DATE_PART('quarter', h."timestamp")
			ORDER BY AVG(h.estimated_consumption) DESC
		) AS rn

	FROM
		public.hourly_energy_consumption h

	WHERE
		h.region NOT IN ('PJME', 'PJMW', 'PJM_Load')  -- ignorando as consolidações
		AND h.estimated_consumption IS NOT NULL

	GROUP BY
		DATE_PART('hour', h."timestamp"),
		DATE_PART('quarter', h."timestamp")
) q

WHERE
	q.rn = 1

ORDER BY
	q.media DESC;

-- FIM --------------------------------------------------------------------------------------------------------------------