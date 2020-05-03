DROP TABLE IF EXISTS climbing_data_cleaning_1;
CREATE TABLE climbing_data_cleaning_1 AS 
SELECT   t1.id as ascent_id
		,t1.user_id
		,t1.rating
		,climb_try
		,UPPER(t3.country) as country
		,CAST(t3.sex as height) as sex
		,CAST(t3.weight as int ) as weight
		,CAST(t3.height as int) as height
		,2020 - t3.started as years_climbing
		,UPPER(t3.occupation) as occupation
		,CASE WHEN sponsor1 > '' OR sponsor2 > '' OR sponsor3 > '' then 1 else 0 end as sponsored
		,count(*) OVER(PARTITION BY user_id) AS number_of_logged_climbs
		,t2.fra_boulders as grade
		,t2.score as grade_number
		,MAX(t2.score) OVER(PARTITION BY user_id) AS max_grade_achieved 
		,t4.shorthand
		,CASE WHEN t2.id IS NULL then 1 else 0 end as failed_grade_join 
		,CASE WHEN t3.id IS NULL then 1 else 0 end as failed_user_join
		,CASE WHEN t4.id IS NULL then 1 else 0 end as failed_method_join 
FROM ascent t1 
LEFT JOIN grade t2 
ON t1.grade_id = t2.id
LEFT JOIN user t3
ON t1.user_id = t3.id
LEFT JOIN method t4
ON t1.method_id = t4.id
WHERE t4.shorthand != 'toprope';

DROP TABLE IF EXISTS climbing_data_cleaning_final_removed_nulls;
CREATE TABLE climbing_data_cleaning_final_removed_nulls AS 
SELECT   DISTINCT  user_id
		 ,country
		 ,sex
		 ,weight
		 ,height
		 ,years_climbing
		 ,occupation
		 ,sponsored
		 ,number_of_logged_climbs
		 ,max_grade_achieved AS max_climbing_grade
		 ,CASE WHEN max_grade_achieved BETWEEN 0 AND 450 THEN CAST(1 AS int)
			   WHEN max_grade_achieved BETWEEN 451 AND 750 THEN  CAST(2 AS int)
			   WHEN max_grade_achieved BETWEEN 751 AND 950 THEN CAST(3 AS int)
			   WHEN max_grade_achieved > 951 THEN CAST(4 AS int) END AS skill_level
FROM climbing_data_cleaning_1
WHERE occupation > '' 
AND height > 0
AND weight > 0;

DROP TABLE IF EXISTS climbing_data_cleaning_final_with_nulls;
CREATE TABLE climbing_data_cleaning_final_with_nulls AS 
SELECT   DISTINCT  user_id
		 ,country
		 ,sex
		 ,weight
		 ,height
		 ,years_climbing
		 ,occupation
		 ,sponsored
		 ,number_of_logged_climbs
		 ,max_grade_achieved AS max_climbing_grade
		 ,CASE WHEN max_grade_achieved BETWEEN 0 AND 450 THEN CAST(1 AS int)
			   WHEN max_grade_achieved BETWEEN 451 AND 750 THEN  CAST(2 AS int)
			   WHEN max_grade_achieved BETWEEN 751 AND 950 THEN CAST(3 AS int)
			   WHEN max_grade_achieved > 951 THEN CAST(4 AS int) END AS skill_level
FROM climbing_data_cleaning_1;




--SELECT COUNT(*) FROM climbing_data_cleaning_final;

--SELECT years_climbing, COUNT(*) FROM climbing_data_cleaning_1 GROUP BY 1;



--SELECT SUM(failed_grade_join) AS failed_grade_join
--	  ,SUM(failed_user_join) AS failed_user_join
--	  ,SUM(failed_method_join) AS failed_method_join
--FROM temp123 ;
