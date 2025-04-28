Průvodní listina – SQL projekt: Analýza vývoje mezd, cen potravin a HDP

Autor: Michal Obdržálek

Databáze: engeto_local

Vytvořené tabulky:

t_michal_obdrzalek_project_SQL_primary_final – sjednocená data o mzdách a cenách potravin v ČR

t_michal_obdrzalek_project_SQL_secondary_final – data o HDP evropských zemí

Obecné poznámky: 
-	Data v tabulce primary_final byla sjednocena podle roku z tabulek czechia_payroll, czechia_price a příslušných číselníků. Informace o čtvrtletí/měsíci/týdnu byly záměrně vynechány.
-	Veškeré výpočty v rámci úkolů pracují s agregovanými hodnotami za jednotlivé kalendářní roky pomocí funkce AVG.
-	Mzdy jsou dostupné od roku 2000 do2021, ceny od roku 2006 do 2018, jejich průnik je mezi roky 2006–2018.
-	V ostatních letech se tím pádem některá data nevyskytují.
-	Postup výpočtů byl následující: AVG → LAG → změna %.

________________________________________

Úkoly a jejich výstupy:
________________________________________

Úkol 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Metoda: výpočet průměrné mzdy za každý rok a odvětví, výpočet meziroční změny (LAG).

Odpověď: Ne, nerostou ve vsech odvetvich. Klesaly v 15 odvetvich z 19, nejvice v odvetvi tezby a dobyvani - 4x a nejcasteji pak v roce 2013 - 11x

Poznámka: Rok 2021 byl ponechán pro zajímavost i přes to, že obsahuje pouze první dvě čtvrtletí – jde totiž o specifické období pandemie.
________________________________________

Úkol 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

Metoda: Výpočet průměrné mzdy a ceny, spočtení množství jednotek za mzdu pro roky 2006 a 2018.

Odpověď: U konzumního chleba šlo zakoupit 1313 kusů v roce 2006 za průměrnou hrubou mzdu a 1365 kusů v roce 2018, lze tedy říci,
že průměrná kupní síla u této položky mírně vzrostla (4 %) a u mléka šlo zakoupit 1466 litrů v roce 2006 a 1670 litrů v roce 2018,
průměrná kupní síla vzrostla o něco výrazněji (14 %).

Poznámka: Různá frekvence vstupních dat (týdně/měsíčně) byla vyrovnána průměrováním.
________________________________________

Úkol 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Metoda: Průměrné roční ceny, výpočet meziročních změn přes LAG, následně průměr těchto změn.

Odpověď: 2 položky za sledované období zlevnily – cukr o 1,9 % a rajská jablka o 0,7 %. U rajských jablek měl statistický vliv vysoká cena z prvního měřeného roku,
kdy u rajských jablek spadla cena o 30 %, bez ní by nebyl průměrný pokles 0,7 %, ale nárůst 1,9 %.
________________________________________

Úkol 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Metoda: Výpočet meziročních změn cen a mezd, porovnání rozdílu.

Odpověď: Ne, rok, kde by byl rozdíl mezi růstem cen a mezd o více než 10 procentních bodů v daném období, neevidujeme.
Nejblíže k tomu měl rok 2013 s nárůstem cen o 7,6 % oproti mzdám.
________________________________________

Úkol 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

Metoda: Výpočet meziroční změny HDP (LAG), posouzení korelací mezi HDP, cenami a mzdami.

Odpověď: Změna HDP nemá výrazný vliv na růst mezd nebo cen ve stejném nebo následujícím roce.

Poznámka: rozsah dat - 2006–2018 (pouze roky, pro které jsou kompletní data o HDP a zároveň mzdách a cenách).
________________________________________


