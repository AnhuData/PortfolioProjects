USE [HousingData]
GO

SELECT [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [dbo].[NashvilleHousingData]

GO


-- Data Cleaning

SELECT *
FROM NashvilleHousingData

-- Populate Property Address Data

SELECT *
FROM NashvilleHousingData
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

-- Break the Property Address into Individual Columns

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS PropertyLocation
FROM NashvilleHousingData

SELECT
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS PropertyCity
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousingData
Add PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousingData

-- Similarly let's break down the owner address

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Remove Duplicates

WITH RowNumberCTE AS
(SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM NashvilleHousingData
)
--SELECT *
--FROM RowNumberCTE
DELETE
FROM RowNumberCTE
WHERE row_num > 1

-- Delete Unused Columns

ALTER TABLE NashvilleHousingData
DROP COLUMN PropertyAddress, OwnerAddress

SELECT *
FROM NashvilleHousingData

-- Change 0 and 1 into Yes and No in SoldAsVacant

SELECT
CASE WHEN SoldAsVacant = 1 THEN 'YES'
	 ELSE 'NO'
END AS SoldAsVacantUpdated
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add SoldAsVacantUpdated Nvarchar(255)

UPDATE NashvilleHousingData
SET SoldAsVacantUpdated = CASE WHEN SoldAsVacant = 1 THEN 'YES'
	 ELSE 'NO'
END

ALTER TABLE NashvilleHousingData
DROP COLUMN SoldAsVacant

SELECT *
FROM NashvilleHousingData