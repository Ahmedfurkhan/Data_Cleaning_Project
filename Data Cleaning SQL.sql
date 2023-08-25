/*

Cleaning Data in SQL Queries

*/


Select *
From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date, [Sale Date]) 
From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$


Update [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
SET [Sale Date] = CONVERT(Date,[Sale Date])

-- If it doesn't Update properly

ALTER TABLE [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
Add SaleDateConverted Date;

Update [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
SET SaleDateConverted = CONVERT(Date,[Sale Date])


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
--Where PropertyAddress is null
order by [Parcel ID]



Select a.[Parcel ID], a.[Property Address], b.[Parcel ID], b.[Property Address], ISNULL(a.[Property Address],b.[Property Address])
From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$ a
JOIN [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$ b
	on a.[Parcel ID] = b.[Parcel ID]
	AND a.[Unnamed: 0] <> b.[Unnamed: 0]
Where a.[Property Address] is null


UPDATE [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
SET [Property Address] = (
    SELECT TOP 1 b.[Property Address]
    FROM [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$ b
    WHERE a.[Parcel ID] = b.[Parcel ID]
      AND a.[Unnamed: 0] <> b.[Unnamed: 0]
      AND b.[Property Address] IS NOT NULL
)
FROM [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$ a
WHERE a.[Property Address] IS NULL;





--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select [Property Address]
From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
--Where [Property Address] is null
--order by [Parcel ID]

SELECT
    CASE
        WHEN CHARINDEX(',', [Property Address]) > 0
        THEN SUBSTRING([Property Address], 1, CHARINDEX(',', [Property Address]) - 1)
        ELSE [Property Address]
    END as AddressPart1,
    CASE
        WHEN CHARINDEX(',', [Property Address]) > 0
        THEN SUBSTRING([Property Address], CHARINDEX(',', [Property Address]) + 1, LEN([Property Address]))
        ELSE ''
    END as AddressPart2
FROM [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$;


ALTER TABLE [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
Add PropertySplitAddress Nvarchar(255);

UPDATE [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
SET PropertySplitAddress = 
    CASE
        WHEN CHARINDEX(',', [Property Address]) > 0
        THEN SUBSTRING([Property Address], 1, CHARINDEX(',', [Property Address]) - 1)
        ELSE [Property Address]
    END;



ALTER TABLE [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
Add PropertySplitCity Nvarchar(255);

UPDATE [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
SET PropertySplitCity = 
    CASE
        WHEN CHARINDEX(',', [PropertyAddress]) > 0
        THEN SUBSTRING([Property Address], CHARINDEX(',', [Property Address]) + 1, LEN([Property Address]))
        ELSE ''
    END;





Select *
From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$





Select [Address]
From  [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
where [Address] is not null

Select
PARSENAME(REPLACE([Address], ',', '.') , 3)
,PARSENAME(REPLACE([Address], ',', '.') , 2)
,PARSENAME(REPLACE([Address], ',', '.') , 1)
From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
where [Address] is not null



ALTER TABLE [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
Add OwnerSplitAddress Nvarchar(255);

Update [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
SET OwnerSplitAddress = PARSENAME(REPLACE([Address], ',', '.') , 3)


ALTER TABLE [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
Add OwnerSplitCity Nvarchar(255);

Update [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
SET OwnerSplitCity = PARSENAME(REPLACE([Address], ',', '.') , 2)



ALTER TABLE [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
Add OwnerSplitState Nvarchar(255);

Update [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
SET OwnerSplitState = PARSENAME(REPLACE([Address], ',', '.') , 1)



Select *
From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$






--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct([Sold As Vacant]), Count([Sold As Vacant])
From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
Group by [Sold As Vacant]
order by 2




Select [Sold As Vacant]
, CASE When [Sold As Vacant] = 'Y' THEN 'Yes'
	   When [Sold As Vacant] = 'N' THEN 'No'
	   ELSE [Sold As Vacant]
	   END
From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$


Update [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
SET [Sold As Vacant] = CASE When [Sold As Vacant] = 'Y' THEN 'Yes'
	   When [Sold As Vacant] = 'N' THEN 'No'
	   ELSE [Sold As Vacant]
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY [Parcel ID],
				 [Property Address],
				 [Sale Price],
				 [Sale Date],
				 [Legal Reference]
				 ORDER BY
					[Unnamed: 0]
					) row_num

From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by [Property Address]



Select *
From [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



SELECT *
FROM [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
WHERE 
    [OwnerSplitAddress] IS NOT NULL AND
    [OwnerSplitCity] IS NOT NULL AND
    -- Add similar conditions for all columns
    [PropertySplitCity] IS NOT NULL;


UPDATE [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
SET [OwnerSplitAddress] = [Address],
    [OwnerSplitCity] = [City],
    [PropertySplitCity] = [Property City];


ALTER TABLE [Ahmed data cleaning project].dbo.Nashville_housing_data_2013_201$
DROP COLUMN [Address],[City],[Property City],[Tax District];
































