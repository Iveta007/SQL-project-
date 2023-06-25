
-- Mzdová část tabulky - příprava dat --

CREATE TABLE t_iveta_vamberska_vages AS  
SELECT
	cp.value_type_code AS kod_mzdy,
	cp.payroll_year AS rok_mzdy,
	cpib.name AS nazev_odvetvi, 
	ROUND(AVG(cp.value),0) AS rocni_prumerna_mzda
	FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code 
WHERE cp.value_type_code = '5958' AND cp.calculation_code ='100' AND cp. industry_branch_code IS NOT NULL 	 
GROUP BY cp.payroll_year,cpib.name;	

SELECT COUNT(1) 
FROM t_iveta_vamberska_vages;



-- Meziroční nárůst mezd z Mzdové tabulky--

CREATE TABLE t_iveta_vamberska_vages_narustvproc AS
(SELECT
	tivv.kod_mzdy,
	tivv.nazev_odvetvi,
	tivv.rok_mzdy,
	ROUND(tivv.rocni_prumerna_mzda,0) AS rocni_prumerna_mzda, 
	ROUND(((tivv.rocni_prumerna_mzda - tivv2.rocni_prumerna_mzda)/tivv2.rocni_prumerna_mzda)*100,2) AS mezirocni_narust_mezd_proc
FROM t_iveta_vamberska_vages tivv
LEFT JOIN t_iveta_vamberska_vages tivv2 ON tivv.nazev_odvetvi=tivv2.nazev_odvetvi 
AND tivv.rok_mzdy=tivv2.rok_mzdy + 1
GROUP BY nazev_odvetvi, rok_mzdy);

SELECT COUNT(1) 
FROM t_iveta_vamberska_vages_narustvproc;

SELECT *
FROM t_iveta_vamberska_vages_narustvproc;


-- Cenová část tabulky - příprava dat--

CREATE TABLE t_iveta_vamberska_prices AS 
SELECT 
	YEAR (cp2.date_from) AS rok_ceny,
	cpc.name AS nazev_potraviny,
	cp2.value AS cena_potraviny_v_CZK
FROM czechia_price cp2 
LEFT JOIN czechia_price_category cpc ON cp2.category_code = cpc.code 
WHERE region_code IS NULL;

SELECT COUNT(1)  
FROM t_iveta_vamberska_prices;



-- Meziroční nárůst cen z Cenové tabulky--

CREATE TABLE t_iveta_vamberska_prices_narustvproc AS
SELECT 
	tivp.nazev_potraviny,
	tivp.rok_ceny,
	tivp.cena_potraviny_v_CZK,
	ROUND(((tivp.cena_potraviny_v_czk - tivp2.cena_potraviny_v_czk)/tivp2.cena_potraviny_v_czk)*100,2) AS mezirocni_narust_ceny	
FROM t_iveta_vamberska_prices tivp
LEFT JOIN t_iveta_vamberska_prices tivp2 ON tivp.nazev_potraviny = tivp2.nazev_potraviny 
AND tivp.rok_ceny=tivp2.rok_ceny + 1
GROUP BY nazev_potraviny, rok_ceny ; 

SELECT *
FROM t_iveta_vamberska_prices_narustvproc;


-- Vytvoření t_iveta_vamberska_project_SQL_primary_final --

CREATE TABLE t_iveta_vamberska_project_SQL_primary_final AS 
SELECT *
FROM t_iveta_vamberska_vages_narustvproc tivvn
LEFT JOIN t_iveta_vamberska_prices_narustvproc tivpn ON tivvn.rok_mzdy = tivpn.rok_ceny;

SELECT*
FROM t_iveta_vamberska_project_SQL_primary_final;

-- jak zjistit první a poslední srovnatelný rok --

SELECT *
FROM t_iveta_vamberska_project_SQL_primary_final
WHERE rok_ceny IS NOT NULL  
ORDER BY rok_ceny ;


-- Otázka č. 1 --
-- ve kterých odvětvích v průběhu let průměrné mzdy klesaly? --


SELECT 
	nazev_odvetvi, 
	rok_mzdy,
	mezirocni_narust_mezd_proc 
FROM t_iveta_vamberska_vages_narustvproc
WHERE mezirocni_narust_mezd_proc < 0; 


-- Otázka č. 2 --
-- kolik l mléka a kolik kg chleba je možné si koupit v prvním a posledním srovnatelném roce?--
 
SELECT 
	tivpspf.nazev_odvetvi ,
	tivpspf.rok_mzdy, 
	tivpspf.nazev_potraviny,  
	ROUND ((tivpspf.rocni_prumerna_mzda/tivpspf.cena_potraviny_v_czk),0) AS mnozstvi_nakoupene_potraviny,
    CASE 
	    WHEN nazev_potraviny = 'Chléb konzumní kmínový' THEN 'kg' ELSE 'litr'
    END AS měrna_jednotka
FROM t_iveta_vamberska_project_SQL_primary_final tivpspf
WHERE nazev_potraviny IN ('Chléb konzumní kmínový','Mléko polotučné pasterované')
      AND rok_mzdy IN ('2006','2018');


-- Otázka č. 3 --
-- která potravina v letech 2006 - 2018 zdražila nejpomaleji --

SELECT 
   DISTINCT nazev_potraviny,
   AVG(mezirocni_narust_ceny) AS prumerny_narust_cen_2006_2018
   FROM t_iveta_vamberska_project_SQL_primary_final tivpspf
   GROUP BY nazev_potraviny
   ORDER BY prumerny_narust_cen_2006_2018;
  
  
-- Otázka č. 4 --
-- meziroční nárůst cen vs meziroční nárůst mezd v porovnatelných letech 2006-2018 --

CREATE TABLE t_iveta_vamberska_rocninarustmezd AS 
SELECT
	rok_mzdy,
	ROUND(AVG(mezirocni_narust_mezd_proc),2) AS prum_rocninarustmezd_vsechnaodvetvi
FROM t_iveta_vamberska_project_SQL_primary_final tivpspf
GROUP BY rok_mzdy;

CREATE TABLE t_iveta_vamberska_rocninarustcen AS
SELECT 
	DISTINCT rok_ceny,
	ROUND(AVG(mezirocni_narust_ceny),2) AS  prum_rocninarustcen_vsechnypotraviny
FROM t_iveta_vamberska_project_SQL_primary_final tivpspf
GROUP BY rok_ceny;



SELECT 
	tivrm.rok_mzdy,
	tivrm.prum_rocninarustmezd_vsechnaodvetvi,
	tivrc.rok_ceny,
	tivrc.prum_rocninarustcen_vsechnypotraviny,
	(prum_rocninarustcen_vsechnypotraviny-prum_rocninarustmezd_vsechnaodvetvi) AS porovnani_narustu
FROM t_iveta_vamberska_rocninarustmezd tivrm
LEFT JOIN t_iveta_vamberska_rocninarustcen tivrc ON tivrm.rok_mzdy=tivrc.rok_ceny
WHERE tivrc.prum_rocninarustcen_vsechnypotraviny IS NOT NULL
ORDER BY porovnani_narustu DESC ; 


--  Otázka č. 5 --
-- výška HDP vs.růst cen potravin / růst mezd --


-- -- Vytvoření t_iveta_vamberska_project_SQL_secondary_final --
	
CREATE TABLE t_iveta_vamberska_project_SQL_secondary_final AS
SELECT
	c.country,
	c.continent,
	e.year,
	e.GDP
FROM countries c
JOIN economies e ON c.country = e.country
WHERE c.continent = 'Europe' AND e.year >=2000 AND e.year <=2021
ORDER BY c.country , year;


SELECT*
FROM t_iveta_vamberska_project_SQL_secondary_final;


  -- Otázka č. 5 --
-- výška HDP vs. meziroční růst mezd in Czech Republic --

-- průměrný meziroční nárůst mezd v ČR za všechna odvětví 2000-2021 --
CREATE TABLE t_iveta_vamberska_vages_prumrocnarustvproc_vCR_zavsechnaodv
SELECT 
    rok_mzdy,
	ROUND(AVG(mezirocni_narust_mezd_proc),2) AS prum_rocninarmezd_cz_vsechnaodvetvi
FROM t_iveta_vamberska_vages_narustvproc
GROUP BY rok_mzdy; 

ALTER TABLE t_iveta_vamberska_vages_prumrocnarustvproc_vCR_zavsechnaodv
	ADD COLUMN country varchar(255);
UPDATE t_iveta_vamberska_vages_prumrocnarustvproc_vCR_zavsechnaodv
	SET country ='Czech Republic';

SELECT*
FROM t_iveta_vamberska_vages_prumrocnarustvproc_vCR_zavsechnaodv;



-- průměrný meziroční nárůst HDP v ČR v letech 2000-2021 --

CREATE TABLE t_iveta_vamberska_prumnarustGDPvproc_vCR 
SELECT
		tivpssf.`year`, 
		(tivpssf.GDP -tivpssf2 .GDP) AS GDP_narust,
		ROUND(((tivpssf.GDP-tivpssf2.GDP)/tivpssf2.GDP*100),2) AS GDP_rocniprumnarustvproc
FROM t_iveta_vamberska_project_SQL_secondary_final tivpssf
LEFT JOIN t_iveta_vamberska_project_SQL_secondary_final tivpssf2 ON tivpssf.country=tivpssf2.country 
AND tivpssf.year = tivpssf2.year +1
WHERE tivpssf .country ='Czech Republic'
GROUP BY tivpssf.year;


-- Porovnání růstu GDP vs. průměrný růst mezd v ČR --

SELECT 
	tivvpvz.rok_mzdy,
	tivvpvz.prum_rocninarmezd_cz_vsechnaodvetvi,
	tivpv.GDP_rocniprumnarustvproc,
	(tivpv.GDP_rocniprumnarustvproc-tivvpvz.prum_rocninarmezd_cz_vsechnaodvetvi) AS rustGDPvs_rustmzdy
FROM t_iveta_vamberska_vages_prumrocnarustvproc_vCR_zavsechnaodv tivvpvz 
JOIN t_iveta_vamberska_prumnarustGDPvproc_vCR tivpv ON tivvpvz.rok_mzdy=tivpv.year
ORDER BY tivvpvz.rok_mzdy;



-- Porovnání růstu GDP vs. průměrný růst cen potravin v ČR  --

SELECT
	tivr.rok_ceny,
	tivr.prum_rocninarustcen_vsechnypotraviny,
	tivpv.GDP_rocniprumnarustvproc,
	(tivpv.GDP_rocniprumnarustvproc - tivr.prum_rocninarustcen_vsechnypotraviny) AS rustGDPvs_rustceny
FROM t_iveta_vamberska_rocninarustcen tivr
JOIN t_iveta_vamberska_prumnarustGDPvproc_vCR tivpv ON tivr.rok_ceny=tivpv.year
ORDER BY tivr.rok_ceny;



	