-- Data Cleaning
select *
from layoffs;

-- Create Worksheet Table
create table layoffs_staging
like layoffs;

select *
from layoffs_staging;
insert into layoffs_staging
select *
from layoffs;

-- Remove Duplicates
-- I. Review staging table
SELECT *
FROM layoff_project.layoffs_staging
;
-- II. Ascertaining real duplicates existing in columns
SELECT * ,
	ROW_NUMBER() OVER (
	 PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM 
		layoff_project.layoffs_staging;
        
SELECT * ,
	ROW_NUMBER() OVER (
	 PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
	FROM 
		layoff_project.layoffs_staging;


WITH Duplicate_CTE AS (
	SELECT * , 
		ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
	FROM layoff_project.layoffs_staging
)
SELECT *
FROM Duplicate_CTE
WHERE row_num > 1;

-- III. 2 duplicates found and crosschecking them individually
SELECT *
FROM layoffs_staging
WHERE company = 'Beyond Meat';

SELECT *
FROM layoffs_staging
WHERE company = 'Cazoo';

-- IV. Delete duplicates
-- Creating another staging table; layoffs_staging2
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` double DEFAULT NULL,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2 ;

INSERT INTO layoffs_staging2
SELECT * , 
		ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
	FROM layoffs_staging;
SELECT *
FROM layoffs_staging2
WHERE row_num > 1 ;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1 ;

-- Standardizing the data
SELECT *
FROM layoffs_staging2 ;

SELECT company, trim(company)
FROM layoffs_staging2 ;

UPDATE layoffs_staging2 
SET company = trim(company);

SELECT distinct country
FROM layoffs_staging2 
ORDER BY 1;

SELECT `date`,
str_to_date(`date`, '%Y-%m-%d') fixed_date
FROM layoffs_staging2 ;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`,'%Y-%m-%d') ;

-- Changing 'text' datatype to 'date'
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` date ;

SELECT `date`
FROM layoffs_staging2 ;

-- Checking for null values or blanks
SELECT *
FROM layoffs_staging2 
WHERE percentage_laid_off = ' ' 
AND total_laid_off = ' ';

SELECT  *
FROM layoffs_staging2
WHERE industry = ' ';

SELECT *
FROM layoffs_staging2
WHERE company IS NULL
OR  company = ' ';

SELECT *
FROM layoffs_staging2;

-- Removing unnecessary column from table
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;