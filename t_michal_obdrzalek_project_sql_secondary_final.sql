DROP TABLE IF EXISTS t_michal_obdrzalek_project_SQL_secondary_final;

-- spojeni tabulek economies a countries na zaklade statu, predvybrany odpovidajici roky pro ukol c.5

CREATE TABLE t_michal_obdrzalek_project_SQL_secondary_final AS
SELECT e.country,
	e.year,
	e.GDP,
	e.population,
	e.gini
FROM economies e
JOIN countries c ON e.country = c.country
WHERE e.year BETWEEN 2006 AND 2018
  AND c.continent = 'Europe'
ORDER BY e.country, e.year;
