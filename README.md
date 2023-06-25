PRŮVODNÍ ZPRÁVA
Projekt ENGETO SQL , DATOVÁ AKADEMIE - studijní skupina  19.4.2023

OBSAH

I.	Příprava datového podkladu   t_iveta¬_vamberska_project_SQL_primary_final   
II.	Zodpovězení výzkumných otázek 1.-4.
III.	Příprava datového podkladu   t_iveta¬_vamberska_project_SQL_secondary_final   
IV.	Zodpovězení výzkumné otázky 5.


I.	Příprava datového podkladu   t_iveta¬_vamberska_project_SQL_primary_final   
Výzkumné otázky
1.	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Po prozkoumání Datových sad a v kontextu Výzkumných otázek 1. až 4. jsem učinila několik předpokladů a ověření, 
které mi umožnily zredukovat celkový objem dat která bude nutné zpracovat a uložit.
Datové sady jsem rozdělila do dvou oblastí:  
-	„mzdová“ data ( tabulky cp, cpc, cpib, cpu, cpvt)   a 
-	„cenová“ data (tabulka cp2, cpc). 
Eliminaci nadbytečných dat jsem provedla odděleně v rámci každé z těchto oblastí. 
Tímto postupem jsem získala dva mezivýsledky = dvě  zredukované tabulky  t_iveta_vamberska_vages (tivv) a t_iveta_vamberska_prices (tivp),
které jsem použila k získání t_iveta¬_vamberska_project_SQL_primary_final (tivpspf).



-- I.1 Mzdová část tabulky - příprava dat před spojením –

Předpoklad 1 - nebudu potřebovat informace / řádky obsahující počty zaměstnanců , pro výpočet průměrných mezd,  
protože tabulka czech_ payroll (cp) už obsahuje tyto průměrné hodnoty vypočtené.
Proto jsem všechny řádky s počty zaměstnanců eliminovala a ponechal jen řádky obsahující informace o průměrných mzdách. 
V tabulce czechia_payroll_value_type  jsem zjistila, že tomto parametru v tabulce cp odpovídá podmínka   value_type_code =´5958´.

Dál jsem ověřila ( řazením ASC a DESC podle unit_code) , že pokud je v tabulce cp ve sloupci value_type_code   hodnota 5958, 
pak ve sloupci   unit_code   je vždy hodnota 200, tj. Kč.

Předpoklad 2 –   v tabulce cp sice zůstaly jen informace o průměrných mzdách, ale ty byly stanoveny dvěma způsoby:      
 a) jednak z celkového počtu zaměstnanců a 
 b)  za druhé z přepočteného počtu zaměstnanců pracujících na HPP. 
Všechny záznamy  jsou v tabulce cp uvedeny společně ( tedy duplicitně) , tj. musíme se rozhodnout, buď pro záznamy získané způsobem  a) nebo způsobem b).
Předpokládám, že předmětem výzkumu není sledování vývoje průměrných mezd v rámci HPP (tak zadání dle mého názoru neznělo) 
ale cílem je sledování průměrné hrubé mzdy  za všechny zaměstnance, tj. způsob a). 
V tabulce  czechia_payroll_calculation  lze zjistit, že tomuto parametru v  tabulce cp  odpovídá calculation_ code = ´100´

Předpoklad 3 – řádky, které ve sl.   industry_branch_code    obsahují NULL nemají pro náš výzkum žádnou vypovídací schopnost, můžeme je tedy eliminovat


-- Meziroční nárůst mezd z Mzdové tabulky--

Výstupem I.1 je tabulka tivv, kterou před spojením s „cenovou“ částí tabulky využiju k vyčíslení meziročního nárůstu mezd v %. 
Takto jsem získala  tabulku t_iveta_vamberska_vages_narustvproc (tivvn).


-- I.2 Cenová část tabulky - příprava dat před spojením --

Předpoklad 4 - Tabulka  czechia_prices (cp2)  obsahuje jednak záznamy s informacemi o vývoji cen vybraných potravin podle CZ regionů 
a dále záznamy o vývoji průměrných cen vybraných potravin za celou republiku – ty mají ve sl. region_code hodnotu  ‚NULL‘  
Předmětem výzkumu není sledovat vývoj potravin  podle jednotlivých regionů. Proto záznamy, které obsahují kód regionu, můžeme z datového souboru eliminovat.   
Cílem výzkumu je mj. porovnávání vývoje mezd a cen sjednocených na totožné porovnatelné období,  proto další úprava dat v cp2 spočívá 
v úpravě formátu sl. date_from tak, aby byl shodný s formátem letopočtu  v   tivv   ve sl.  rok_mzdy   ( příprava na propojení tabulek ).

-- Meziroční nárůst cen z Cenové tabulky—

Výstupem I.2 je tabulka tivp, kterou před spojením s „mzdovou“ částí tabulky využiju k vyčíslení meziročního nárůstu mezd v %.  
Takto jsem získala tabulku t_iveta_vamberska_prices_narustvproc ( tivpn).


-- Vytvoření t_iveta_vamberska_project_SQL_primary_final tivpspf --

Finální datový podklad tivpspf  pro získání výzkumných otázek jsem získala spojením předem připravených „mzdových“ dat  a „cenových“ dat, 
tedy tabulek  tivvn  a  tivpn via sl. obsahující sledovaný rok.

-----------------------------------------------------------------------------------------------------------------

II.	Zodpovězení výzkumných otázek 1.-4.
Výzkumné otázky
1.	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

-- Otázka č. 1 --
-- ve kterých odvětvích v průběhu let průměrné mzdy klesaly? --

Použila jsem tabulku tivvn, kde je možné řadit a filtrovat podle hodnot  ve sloupci obsahujícím meziroční nárůst mezd v %. Pokud je tato hodnota < 0, 
došlo v rámci daného odvětví a roku k poklesu průměrných mezd. 
Závěr: V některých odvětvích mzdy v průběhu let meziročně klesaly

-- Otázka č. 2 --
-- kolik l mléka a kolik kg chleba je možné si koupit v prvním a posledním    srovnatelném roce? --

Seřazením záznamů v  tivpspf  podle sl. rok_mzdy a sl. rok_ceny  jsem zjistila, které roky mzdové a cenové části tabulky se překrývají, 
tj. které roky tvoří porovnatelné období. 
První rok je  2006 a  poslední  2018.
Přidala jsem sloupec obsahující podíl průměrné roční mzdy a průměrné ceny sledované  potraviny za jednotlivá odvětví. 
Filtrováním  jsem získala množství vybrané potraviny (chléb, mléko), které bylo možné si v letech 2008 a 2016 koupit za průměrnou mzdu 
v  jednotlivých odvětvích = sloupec množství_nakoupene_potraviny .

-- Otázka č. 3 --
-- která potravina zdražuje nejpomaleji --

V tivpspf jsem upravila záznamy tak, aby se každá kombinace  názvu potraviny a roku vyskytovala v tabulce jen jednou. 
Pak jsem v rámci každé potraviny za období 2006-2018 vypočetla průměrnou hodnotu z meziročního % nárůstu. 
Seřazením záznamů podle tohoto parametru zjistíme, které potraviny v období mezi lety 2006 a 2018 zdražily nejméně ( cukr, banány) 
a které nejvíce (vejce, máslo, papriky). 
 
-- Otázka č. 4 --
-- meziroční nárůst cen vs meziroční nárůst mezd v letech 2006-2018 --

Před zodpovězením otázky č.4 jsem si připravila dvě pomocné tabulky 
-	tivrm, která obsahuje  sloupec s průměrnými hodnotami  meziročních % nárůstů mezd přes všechna odvětví společně za jednotlivé roky 2000 - 2021
-	tivrc, která obsahuje sloupec s průměrnými hodnotami meziročních % nárůstů cen potravin v rámci všech potravin společně za jednotlivé roky 2006 – 2018 

Po spojení tivrm a tivrc prostřednictvím sl. obsahujícím rok jsem vzájemným porovnáním  meziročního nárůstu cen s meziročním nárůstem mezd získala přehled, 
ve kterých letech byl meziroční nárůst cen potravin zřetelně vyšší než růst mezd. Největší disproporce - rozdíl  8,07% -  mezi růstem cen a  růstem mezd nastal v roce 2013.

-----------------------------------------------------------------------------------------------------------------

III.	Příprava datového podkladu   t_iveta¬_vamberska_project_SQL_secondary_final  

Datový podklad tivpssf jsem získala spojením tabulky countries a tabulky economies. 
-- průměrný meziroční nárůst mezd v ČR za všechna odvětví 2000-2021 --
Tento datový podklad tivpssf jsem použila k vyčíslení a doplnění sloupce s průměrným meziročním nárůstem GDP v % společně za všechna odvětví po jednotlivých letech. 
Výstupem je tabulka tivpv.

-----------------------------------------------------------------------------------------------------------------


IV.	Zodpovězení výzkumné otázky 5.
Výzkumná otázka
5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách 
ve stejném nebo následujícím roce výraznějším růstem?


-- Porovnání růstu GDP vs. průměrný růst mezd v ČR --

K zodpdpovězení otázky č. 5 potřebuji dále datový podklad obsahující informace  o průměrném %tickém meziročním nárůstu mezd v ČR  společně za všechna odvětví v průběhu sledovaných let. 
Za tím účelem jsem z tivvn vytvořila tabulku tivvpvz, kterou jsem dále doplnila o sloupec country = ‚Czech Republic‘, aby bylo možné prostřednictvím tohoto sloupce tabulku dále propojovat a filtrovat.
Spojením tivvpvz  a tivpv  prostřednictvím sl. rok jsem získala  datový podklad, který umožnil srovnání  meziročního nárůstu GDP s meziročním nárůstem průměrných mez za sledované období. 
Nebo jinak, jestli má změna GDP prokazatelný vliv na změnu mezd.
Z výsledného selectu lze konstatovat, že ve většině sledovaných letech rostly mzdy rychleji než HDP ( kromě roku 2005, 2006 2010 a 2013).
Obecně lze konstatovat, že existuje shodný trend (ve smyslu rostoucí či klesající) meziročních změn HDP a meziročních změn mezd ve stejném, případně následujícím roce. 
Tento trend ale nelze z dostupných dat exaktněji kvantfifikovat.  

-- Porovnání růstu GDP vs. průměrný růst cen potravin  v ČR  --

K zodpovězení této otázky jsem opět použila tabulky tivvpvz a tivpv. Tentokrát jsem porovnávala meziroční nárůst GDP s meziročním nárůstem průměrných mezd.
V tomto případě není možné spolehlivě vysledovat shodný trend u meziročních změn HDP a meziročních změn cen potravin. Obecně lze jen konstatovat, 
že ve většině sledovaných let rostly mzdy rychleji než HDP  ( kromě roku 2009, 2015, 2016 a 2018).




