-- Poznamka: Byly vytvoreny souhrnne tabulky t_michal_obdrzalek_project_SQL_primary_final a t_michal_obdrzalek_project_SQL_secondary_final. 
-- Dle zadani, jsou u prvni tabulky agregovana data dle spolecneho roku. V tabulce neni uveden tyden/mesic/ctvrtleti daneho udaje, jelikoz s temito udaji dale nepracuji.


-- UKOL 1: Rostou v prubehu let mzdy ve vsech odvetvich, nebo v nekterych klesaji?

-- Poznamky: za rok 2021 mame data pouze za prvni pololeti, ale vzhledem k tomu, ze 2021 patri do statisticky zajimaveho obdobi covidu, byla ponechana
-- U calculation_code jsem nechal pouze kod '200' = prepocteny, tzn. prepoctena data mezd tak, aby vice odrazely napriklad polovicni ci jinak zkracene uvazky


WITH Zmena_mzdy AS (
    SELECT
        Odvetvi,
        Rok,
        Mzda AS Prumerna_mzda_tento_rok,
        LAG(Mzda) OVER (PARTITION BY Odvetvi ORDER BY Rok) AS Prumerna_mzda_minuly_rok
    FROM t_michal_obdrzalek_project_SQL_primary_final
    WHERE Mzda IS NOT NULL
    GROUP BY Odvetvi, Rok
),
Zmena AS (
    SELECT
        Odvetvi,
        Rok,
        ROUND((Prumerna_mzda_tento_rok - Prumerna_mzda_minuly_rok) / Prumerna_mzda_minuly_rok * 100, 1) AS Zmena_prumerne_mzdy
    FROM Zmena_mzdy
    WHERE Rok > 2000
),
Poklesy AS (
    SELECT
        Odvetvi,
        COUNT(CASE WHEN Zmena_prumerne_mzdy < 0 THEN 1 END) AS Pocet_poklesu,
        COUNT(CASE WHEN Zmena_prumerne_mzdy >= 0 THEN 1 END) AS Pocet_rustu
    FROM Zmena
    GROUP BY Odvetvi
)
SELECT 
    Odvetvi,
    Pocet_poklesu,
    Pocet_rustu,
    SUM(CASE WHEN Pocet_poklesu > 0 THEN 1 ELSE 0 END) OVER () AS Celkovy_pocet_odvetvi_s_poklesem
FROM Poklesy
ORDER BY Pocet_poklesu DESC;


-- Detailni prehled odvetvi a roku, kde byly zaznamenany poklesy

WITH Zmena_mzdy AS (
    SELECT
        Odvetvi,
        Rok,
        Mzda AS Prumerna_mzda_tento_rok,
        LAG(Mzda) OVER (PARTITION BY Odvetvi ORDER BY Rok) AS Prumerna_mzda_minuly_rok
    FROM t_michal_obdrzalek_project_SQL_primary_final
    WHERE Mzda IS NOT NULL
    GROUP BY Odvetvi, Rok
)
SELECT *
FROM (
    SELECT
        Odvetvi,
        Rok,
        ROUND((Prumerna_mzda_tento_rok - Prumerna_mzda_minuly_rok) / Prumerna_mzda_minuly_rok * 100, 1) AS Zmena_prumerne_mzdy
    FROM Zmena_mzdy
    WHERE Rok > 2000
) t
WHERE Zmena_prumerne_mzdy < 0;


-- Souhrnny pocet poklesu, serazeno dle roku s nejvice poklesy

WITH Ciste_mzdy AS (
    SELECT DISTINCT Rok, Odvetvi, Mzda
    FROM t_michal_obdrzalek_project_SQL_primary_final
    WHERE Mzda IS NOT NULL
),
Prumery AS (
    SELECT
        Odvetvi,
        Rok,
        Mzda AS Prumerna_mzda
    FROM Ciste_mzdy
    GROUP BY Odvetvi, Rok
),
Zmeny AS (
    SELECT
        Odvetvi,
        Rok,
        Prumerna_mzda,
        LAG(Prumerna_mzda) OVER (PARTITION BY Odvetvi ORDER BY Rok) AS Predchozi_mzda
    FROM Prumery
)
SELECT 
    Rok AS Rok_poklesu,
    COUNT(CASE WHEN (Prumerna_mzda - Predchozi_mzda) / Predchozi_mzda * 100 < 0 THEN 1 END) AS Pocet_poklesu
FROM Zmeny
WHERE Predchozi_mzda IS NOT NULL
GROUP BY Rok
ORDER BY Pocet_poklesu DESC;


-- Odpoved: Ne, nerostou ve vsech odvetvich. Klesaly v 15 odvetvich z 19, nejvice v odvetvi tezby a dobyvani - 4x a nejcasteji pak v roce 2013 - 11x

-----------------------
-----------------------

-- UKOL 2: Kolik je mozne si koupit litru mleka a kilogramu chleba za prvni a posledni srovnatelne obdobi v dostupnych datech cen a mezd?
-- Poznámka: Pracuji s roky 2006 a 2018 - rok 2006 ma zaznamy na tydenni bazi, 2018 na mesicni

WITH Mzdy AS (
    SELECT 
        Rok,
        AVG(Mzda) AS Prumerna_mzda
    FROM t_michal_obdrzalek_project_SQL_primary_final
    WHERE Mzda IS NOT NULL
    GROUP BY Rok
),
Ceny AS (
    SELECT 
        Rok,
        Potravina,
        Cena AS Prumerna_cena
    FROM t_michal_obdrzalek_project_SQL_primary_final
    WHERE Potravina IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
    AND Cena IS NOT NULL
    GROUP BY Rok, Potravina
),
Spojeno AS (
    SELECT 
        c.Potravina,
        c.Rok,
        m.Prumerna_mzda,
        c.Prumerna_cena
    FROM Ceny c
    JOIN Mzdy m ON c.Rok = m.Rok
    WHERE c.Rok IN (2006, 2018)
),
Rozdil AS (
    SELECT 
        Potravina,
        Rok,
        ROUND(Prumerna_mzda / Prumerna_cena, 0) AS Mnozstvi_polozek_za_mzdu,
        LAG(ROUND(Prumerna_mzda / Prumerna_cena, 0)) OVER (PARTITION BY Potravina ORDER BY Rok) AS Predchozi_mnozstvi
    FROM Spojeno
)
SELECT 
    Potravina,
    Rok,
    Mnozstvi_polozek_za_mzdu,
    ROUND(((Mnozstvi_polozek_za_mzdu - Predchozi_mnozstvi) / Predchozi_mnozstvi) * 100, 2) AS Procentualni_narust
FROM Rozdil
ORDER BY Potravina, Rok;


/* Odpoved: U konzumniho chleba slo zakoupit 1313 kusu v roce 2006 za prumernou hrubou mzdu a 1365 kusu v roce 2018, lze tedy rici, 
            ze prumerna kupni sila u teto polozky mirne vzrostla (4%) a u mleka slo zakoupit 1466 litru v roce 2006 a 1670 litru v roce 2018,
            prumerna kupni sila vzrostla o neco vyrazneji (14%). */

-----------------------
-----------------------


-- UKOL 3: Ktera kategorie potravin zdrazuje nejpomaleji (je u ni nejnizsi percentualni mezirocni narust)?

WITH Ceny AS (
    SELECT 
        Rok,
        Potravina,
        Cena AS Prumerna_cena
    FROM t_michal_obdrzalek_project_SQL_primary_final
    WHERE Cena IS NOT NULL
    GROUP BY Rok, Potravina
),
Zmeny AS (
    SELECT
        Potravina,
        Rok,
        Prumerna_cena,
        LAG(Prumerna_cena) OVER (PARTITION BY Potravina ORDER BY Rok) AS Predchozi_cena
    FROM Ceny
),
Procenta AS (
    SELECT
        Potravina,
        Rok,
        ((Prumerna_cena - Predchozi_cena) / Predchozi_cena * 100) AS Procentualni_zmena
    FROM Zmeny
    WHERE Predchozi_cena IS NOT NULL
)
SELECT 
    Potravina,
    ROUND(AVG(Procentualni_zmena), 1) AS Prumerna_rocni_zmena
FROM Procenta
GROUP BY Potravina
ORDER BY Prumerna_rocni_zmena;

/* 
	Odpoved: 2 polozky za sledovane obdobi zlevnili - cukr o 1,9% a rajska jablka o 0,7%. U rajskych jablek statisticky vliv vysoka cena z prvniho mereneho roku,
			 kdy u rajskych jablek spadla cena o 30%, bez ni by nebyl prumerny pokles 0,7%, ale narust 1,9%.
*/

-----------------------
-----------------------


-- UKOL 4 - Existuje rok, ve kterem byl mezirocni narust cen potravin vyrazne vyssi nez rust mezd (vetsi nez 10 %)?
-- Poznamka - vysledky zahrnuji roky 2006 az 2018, pro ktere existuji spolecna data mezd a cen

WITH Ceny AS (
    SELECT 
        Rok,
        Potravina,
        Cena AS Prumerna_cena
    FROM t_michal_obdrzalek_project_SQL_primary_final
    WHERE Cena IS NOT NULL
    GROUP BY Rok, Potravina
),
Zmena_cen AS (
    SELECT 
        Rok,
        Potravina,
        Prumerna_cena,
        LAG(Prumerna_cena) OVER (PARTITION BY Potravina ORDER BY Rok) AS Predchozi_cena
    FROM Ceny
),
Procenta_cen AS (
    SELECT 
        Rok,
        ((Prumerna_cena - Predchozi_cena) / Predchozi_cena * 100) AS Procentualni_zmena_cen
    FROM Zmena_cen
    WHERE Predchozi_cena IS NOT NULL
),
Mzdy AS (
    SELECT 
        Rok,
        AVG(Mzda) AS Prumerna_mzda
    FROM t_michal_obdrzalek_project_SQL_primary_final
    WHERE Mzda IS NOT NULL
    GROUP BY Rok
),
Zmena_mezd AS (
    SELECT 
        Rok,
        Prumerna_mzda,
        LAG(Prumerna_mzda) OVER (ORDER BY Rok) AS Predchozi_mzda
    FROM Mzdy
),
Procenta_mezd AS (
    SELECT 
        Rok,
        ((Prumerna_mzda - Predchozi_mzda) / Predchozi_mzda * 100) AS Procentualni_zmena_mezd
    FROM Zmena_mezd
    WHERE Predchozi_mzda IS NOT NULL
),
Spojeno AS (
    SELECT 
        pc.Rok,
        ROUND(AVG(pc.Procentualni_zmena_cen), 2) AS Prumerna_zmena_cen,
        pm.Procentualni_zmena_mezd
    FROM Procenta_cen pc
    JOIN Procenta_mezd pm ON pc.Rok = pm.Rok
    GROUP BY pc.Rok, pm.Procentualni_zmena_mezd
)
SELECT 
    Rok,
    Prumerna_zmena_cen,
    ROUND(Procentualni_zmena_mezd, 2),
    ROUND((Prumerna_zmena_cen - Procentualni_zmena_mezd), 2) AS Rozdil,
    CASE WHEN (Prumerna_zmena_cen - Procentualni_zmena_mezd) > 10 THEN 'ANO' ELSE 'NE' END AS 'Rozdil_cen_a_mezd_>10_pct'
FROM Spojeno
ORDER BY Rok;

/* ODPOVED - Ne, rok kde by byl rozdil mezi rustem cen a mezd o vice nez 10 procentnich bodu v danem obdobi neevidujeme. 
			 Nejblize k tomu mel rok 2013 s narustem cen o 7,6% oproti mzdam.
*/

-----------------------
-----------------------


-- 	5. UKOL: Ma vyska HDP vliv na zmeny ve mzdach a cenach potravin? Neboli, pokud HDP vzroste vyrazneji v jednom roce, projevi se to na cenach 
-- 			 potravin ci mzdach ve stejnem nebo nasledujicim roce vyraznejsim rustem?	

WITH Mzdy_aggr AS (
    SELECT Rok, ROUND(AVG(Mzda), 2) AS Prumerna_mzda
    FROM t_michal_obdrzalek_project_SQL_primary_final
    WHERE Mzda IS NOT NULL
    GROUP BY Rok
),
Zmeny_mezd AS (
    SELECT 
        Rok,
        Prumerna_mzda,
        LAG(Prumerna_mzda) OVER (ORDER BY Rok) AS Predchozi_mzda
    FROM Mzdy_aggr
),
Mzdy_final AS (
    SELECT 
        Rok,
        ROUND(((Prumerna_mzda - Predchozi_mzda) / Predchozi_mzda) * 100, 2) AS Procentualni_zmena_mezd
    FROM Zmeny_mezd
    WHERE Predchozi_mzda IS NOT NULL
),
Ceny_aggr AS (
    SELECT Rok, Potravina, Cena AS Prumerna_cena
    FROM t_michal_obdrzalek_project_SQL_primary_final
    WHERE Cena IS NOT NULL
    GROUP BY Rok, Potravina
),
Zmeny_cen AS (
    SELECT Rok, Potravina, Prumerna_cena,
    LAG(Prumerna_cena) OVER (PARTITION BY Potravina ORDER BY Rok) AS Predchozi_cena
    FROM Ceny_aggr
),
Ceny_final AS (
    SELECT Rok, ROUND(AVG((Prumerna_cena - Predchozi_cena) / Predchozi_cena * 100), 2) AS Prumerna_zmena_cen
    FROM Zmeny_cen
    WHERE Predchozi_cena IS NOT NULL
    GROUP BY Rok
),
Rust_HDP AS (
    SELECT country, year AS Rok, GDP,
    LAG(GDP) OVER (PARTITION BY country ORDER BY year) AS GDP_previous_year
    FROM t_michal_obdrzalek_project_SQL_secondary_final
    WHERE country = 'Czech Republic' AND year BETWEEN 2006 AND 2018
)
SELECT 
    c.Rok,
    c.Prumerna_zmena_cen,
    m.Procentualni_zmena_mezd,
    ROUND((r.GDP - r.GDP_previous_year) / r.GDP_previous_year * 100, 2) AS Zmena_HDP
FROM Ceny_final c
JOIN Mzdy_final m ON c.Rok = m.Rok
JOIN Rust_HDP r ON c.Rok = r.Rok
WHERE r.GDP_previous_year IS NOT NULL
ORDER BY c.Rok;

-- Odpoved: Zmena HDP nema vyrazny vliv na rust mezd nebo cen ve stejnem nebo nasledujicim roce.

