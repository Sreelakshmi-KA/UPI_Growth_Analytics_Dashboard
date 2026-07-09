create database upi_analysis;
use upi_analysis;

CREATE TABLE upi_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Month DATE,
    Banks_Live INT,
    Volume_Mn DECIMAL(10,2),
    Value_Cr DECIMAL(15,2),
    Year INT,
    Month_Num INT,
    Month_Name VARCHAR(20),
    Quarter INT,
    Financial_Year VARCHAR(15));
    
    select * from upi_transactions limit 10;
    
    select count(*) as Total_Rows
    from upi_transactions;

    
##  Total Overview ##    
SELECT 
    COUNT(*) AS Total_Months,
    ROUND(SUM(Volume_Mn), 2) AS Total_Volume_Mn,
    ROUND(SUM(Value_Cr), 2) AS Total_Value_Cr,
    MAX(Banks_Live) AS Max_Banks,
    MIN(Banks_Live) AS Min_Banks
FROM upi_transactions;


## Yearly Growth ##
select
	year,
    round(sum(volume_Mn),2) as Yearly_Volume,
    round(sum(Value_Cr),2) as Yearly_Value,
    max(Banks_live) as Banks_live
    from upi_transactions
    group by year
    order by year;
    
## Financial year ##
    Select 
        Financial_Year,
        round(sum(volume_Mn),2) as FY_Volume,
        round(sum(Value_Cr),2) as FY_Value
    from upi_transactions
    group by Financial_Year
    order by Financial_Year;
    
## Quarter-wise Analysis ##
    select
        Year,
        Quarter,
        round(sum(Volume_Mn),2) as Quarterly_Volume,
        round(sum(value_Cr),2) as Quarterly_Value
        From upi_transactions
        group by Year ,Quarter
        order by Year,Quarter;
        
## Top 10 Month By Volume ##
select
	Month,
	Month_Name,
	Year,
	Volume_Mn,
	Value_Cr
from upi_transactions
order by Volume_Mn
limit 10;

## Covid Impact Analysis ##
select
   year,
   round(sum(Volume_Mn),2) as Volume,
   round(sum(Value_Cr),2) as Value
   from upi_transactions
   where year in (2019,2020,2021)
group by year
order by year;

## YOY Growth % ##
SELECT 
    Year,
    ROUND(SUM(Volume_Mn), 2) AS Volume,
    ROUND((SUM(Volume_Mn) - LAG(SUM(Volume_Mn)) 
        OVER (ORDER BY Year)) / 
        LAG(SUM(Volume_Mn)) OVER (ORDER BY Year) * 100, 2) 
        AS Volume_Growth_Pct
FROM upi_transactions
GROUP BY Year
ORDER BY Year;


## Best Month every Year ##
Select    
     Year,
     Month_Name,
     Volume_Mn,
     Value_Cr
From upi_transactions ut1
where Volume_Mn =( 
        SELECT MAX(Volume_Mn) 
    FROM upi_transactions ut2 
    WHERE ut2.Year = ut1.Year)
ORDER BY Year;


## Creating View ##

create view vw_upi_analysis as
select
     id,
     Month,
     Banks_Live,
     Volume_Mn,
     Value_Cr,
     Year,
     Month_Num,
     Month_Name,
     Quarter,
     Financial_Year
From upi_transactions
order by Month;

    
	
            
   
    