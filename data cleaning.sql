/*

Cleaning Data in SQL 

*/
SELECT *
FROM PortfolioProject.dbo.[Nashville Housing]

-----------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
ADD ConvertedSaleDate DATE;

UPDATE [Nashville Housing]
SET ConvertedSaleDate = CONVERT(Date,SaleDate)

SELECT ConvertedSaleDate
FROM PortfolioProject.dbo.[Nashville Housing]


--------------------------------------------------------------------------------------------

-- Populate Property Address Data And remove null values

SELECT *
FROM portfolioproject.dbo.[Nashville Housing]
--Where PropertyAddress is null
order by ParcelID

--SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
--FROM portfolioproject.dbo.[Nashville Housing] a
--JOIN portfolioproject.dbo.[Nashville Housing] b
--ON a.ParcelID = b.ParcelID
--AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.[Nashville Housing] a
JOIN portfolioproject.dbo.[Nashville Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;


-----------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM portfolioproject.dbo.[Nashville Housing]
--Where PropertyAddress is null
--order by ParcelID

--SELECT
--SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as Address
--, SUBSTRING(propertyaddress, CHARINDEX(',' , propertyaddress) +1 , LEN(propertyaddress)) as Address
--FROM PortfolioProject.dbo.[Nashville Housing];

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
ADD propertysplitaddress NVARCHAR(255);

UPDATE [Nashville Housing]
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
ADD propertysplitcity NVARCHAR(255);

UPDATE [Nashville Housing]
SET propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX(',' , propertyaddress) +1 , LEN(propertyaddress))

SELECT OwnerAddress
FROM portfolioproject.dbo.[Nashville Housing]

--SELECT 
--PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
--,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
--,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--FROM portfolioproject.dbo.[Nashville Housing]

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
ADD ownersplitaddress NVARCHAR(255);

UPDATE [Nashville Housing]
SET ownersplitaddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
ADD ownersplitcity NVARCHAR(255);

UPDATE [Nashville Housing]
SET ownersplitcity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
ADD ownersplitstate NVARCHAR(255);

UPDATE [Nashville Housing]
SET ownersplitstate = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


------------------------------------------------------------------------------------


--- Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject.dbo.[Nashville Housing]

UPDATE [Nashville Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				        END
FROM PortfolioProject.dbo.[Nashville Housing]



--------------------------------------------------------------------------------------

--REMOVE Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.[Nashville Housing]
--order by ParcelID
)
DELETE 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From PortfolioProject.dbo.[Nashville Housing]


-------------------------------------------------------------------------------


-- Delete Unused Columns



Select *
From PortfolioProject.dbo.[Nashville Housing]


ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

