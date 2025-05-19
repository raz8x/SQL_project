DROP TABLE IF EXISTS t_michal_obdrzalek_project_SQL_primary_final;

-- spojeni tabulek czechia_payroll a czechia_price s odpovidajicimi JOINy pomoci CTE na zaklade spolecnych roku, mzdy a ceny zaokrouhleny

CREATE TABLE t_michal_obdrzalek_project_SQL_primary_final 
WITH t_mzdy AS (
    SELECT     
        cpib.name AS Odvetvi,
        payroll_year AS Rok,
        ROUND(AVG(cp.value)) AS Mzda
    FROM czechia_payroll cp
    JOIN czechia_payroll_industry_branch cpib 
        ON cp.industry_branch_code = cpib.code
    JOIN czechia_payroll_value_type cpvt 
        ON cp.value_type_code = cpvt.code 
        AND cp.value_type_code = '5958'
    JOIN czechia_payroll_calculation cpc_calc 
        ON cp.calculation_code = cpc_calc.code 
        AND cp.calculation_code = '200'
    GROUP BY payroll_year, cpib.name
),
t_ceny AS (
    SELECT 
        YEAR(p.date_to) AS Rok,
        cpc.name AS Potravina,
        ROUND(AVG(p.value), 2) AS Cena
    FROM czechia_price p
    JOIN czechia_price_category cpc 
        ON p.category_code = cpc.code
    GROUP BY YEAR(p.date_to), cpc.name
)
SELECT 
    t_mzdy.Rok, 
    t_mzdy.Odvetvi,
    t_ceny.Potravina,
    t_mzdy.Mzda,
    t_ceny.Cena
FROM t_mzdy
LEFT JOIN t_ceny
    ON t_mzdy.Rok = t_ceny.Rok;    
