-- Exploratory Data Analysis
--  Exploring a Layoff.csv dataset
-- Recalling Layoff staging table
SELECT *
FROM layoffs_staging2;

-- Checking to see total and percentage layoffs
SELECT max(total_laid_off), max(percentage_laid_off)
FROM layoffs_staging2;

-- Checking for companies with 1 which is basically 100 percent of the company laid off;
-- ordering by funds_raised, we can see how big some of these companies were
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised desc;

-- Companies with the most single Layoff
SELECT company, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 desc;
-- industry with the most single Layoff
SELECT industry, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 desc;
-- Country with the most single Layoff
SELECT country, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 desc;
-- by stage
SELECT stage, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 desc;
-- by date, year precisely
SELECT YEAR(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY  YEAR(`date`)
ORDER BY 1 desc;

SELECT *
FROM layoffs_staging2;

SELECT company, sum(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 desc;
-- by month using a substring
SELECT substring(`date`, 1, 7) `Month` , sum(total_laid_off) total_laidoff
FROM layoffs_staging2
GROUP BY substring(`date`, 1, 7)
ORDER BY 1 desc;

-- Using CTE to check for the rolling total per month
WITH Rolling_total AS
(
SELECT substring(`date`, 1, 7) `Month` , sum(total_laid_off) total_laidoff
FROM layoffs_staging2
GROUP BY `Month`
ORDER BY 1 desc
)
SELECT `Month`, total_laidoff,
sum(total_laidoff) OVER(order by `Month`) rolling_date
FROM Rolling_total
;

-- Companies with most layoffs per year
SELECT company, YEAR (`date`), sum(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR (`date`)
ORDER BY 3 desc;

-- Using CTE to query for companies with most layoffs per year
-- Showing <=5 ranking to ascertain the highest 5 layoffs per year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR (`date`), sum(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR (`date`)
) ,
Company_Year_Rank AS
(
SELECT * ,
DENSE_RANK() OVER (PARTITION BY Years ORDER BY Total_laid_off desc) Ranking
FROM Company_Year
ORDER BY Ranking 
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;
