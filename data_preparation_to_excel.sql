-- 🔍 Purpose:
-- Perform IT job exploration focusing on 'Data Analysis'
-- category without modifying the original dataset.
-- This query also computes the average salary per job
-- and displays details like programming languages, tools,
-- and work mode.
-- ============================================================

-- ============================================================
-- 🧩 CTE #1: renamed
-- Create a new column 'unified_specialisation' to unify
-- different variations of "data analyst / analytics / analysis"
-- into one standardized label: "Data Analysis".
-- ============================================================
WITH renamed AS (
    SELECT
        *,
        CASE 
            WHEN tech_specialisation LIKE '%data analyst%' 
              OR tech_specialisation LIKE '%data analysis%' 
              OR tech_specialisation LIKE '%data analytics%' 
            THEN 'Data Analysis'
            ELSE tech_specialisation
        END AS unified_specialisation
    FROM itjob_header
),
-- select count(jobid) as total from renamed where avg_salary_usd is null and level = 'Junior';
-- ============================================================
-- 💰 CTE #2: salary_calc
-- Calculate the average salary for each job based on
-- salary_from and salary_to columns.
-- ============================================================
salary_calc AS (
    SELECT
        jobid,
        ROUND(AVG((salary_from + salary_to)/2), 2) AS avg_salary
    FROM itjob_header
    WHERE salary_from IS NOT NULL
    GROUP BY jobid
)

-- ============================================================
-- 🧮 Final SELECT:
-- Combine both CTEs to display job data along with
-- average salary, job type, location, and used
-- programming languages & tools.
-- ============================================================
SELECT 
    r.jobid,
    r.level,
    r.unified_specialisation AS data_specialisation,
    r.country,
    s.avg_salary,
    r.currency,
    r.avg_salary_usd,
    r.type AS type_employment,
    r.mode AS work_mode,
    m.source_classification AS job_classification,
    GROUP_CONCAT(DISTINCT p.prog_lang_text ORDER BY p.prog_lang_text SEPARATOR ', ') AS programming_languages,
    GROUP_CONCAT(DISTINCT t.tool_text ORDER BY t.tool_text SEPARATOR ', ') AS tools_used,
    r.education_level
FROM renamed r
LEFT JOIN itjob_main m ON r.jobid = m.jobid
LEFT JOIN itjob_prog_lang p ON r.jobid = p.jobid
LEFT JOIN itjob_tools t ON r.jobid = t.jobid
LEFT JOIN salary_calc s ON r.jobid = s.jobid
WHERE	r.avg_salary_usd IS NOT NULL
		AND r.avg_salary_usd > '0.00'
		AND r.level IS NOT NULL
        AND r.unified_specialisation IS NOT NULL
GROUP BY r.jobid, m.source_classification, r.level, r.unified_specialisation, r.country, s.avg_salary, 
         r.currency, r.avg_salary_usd, r.type, r.mode, r.education_level
ORDER BY s.avg_salary DESC;


-- Next, export to excel for exploratory and visualization
