/* ======================================================================================
   NashvilleHousing Data Cleaning and Transformation 
   --------------------------------------------------------------------------------------
   Purpose:
	   This script performs essential data cleaning and transformation tasks on the 
	   NashvilleHousing table to ensure data consistency, proper formatting, and 
	   readiness for analysis.
	   Operations include:
			- Date conversions
			- Address parsing
			- Handling NULL values
			- Deduplication
			- Standardizing categorical columns

   ⚠️ WARNING:
	   This script is intended for one-time execution only.
	   It performs operations such as dropping and renaming columns, which are irreversible.
	   Running it multiple times without modification may result in errors or data loss.

   ====================================================================================== */


/* ======================================================================================
   Convert 'SaleDate' Column to DATE Type
   --------------------------------------------------------------------------------------
   Ensures the 'SaleDate' column is in proper SQL DATE format to enable accurate
   time-based calculations and analytics.
   ====================================================================================== */

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;
GO

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);
GO

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;
GO

EXEC sp_rename 'NashvilleHousing.SaleDateConverted', 'SaleDate', 'COLUMN';
GO

SELECT
	SaleDate
FROM NashvilleHousing

/* ======================================================================================
   Fill NULL PropertyAddress Values
   --------------------------------------------------------------------------------------
   Ensures that missing PropertyAddress values are filled using matching
   ParcelID entries. Uses a self-join to copy addresses from other rows
   where the same ParcelID exists.
   ====================================================================================== */

SELECT 
	ta.ParcelID,
	ta.PropertyAddress,
	tb.ParcelID,
	tb.PropertyAddress,
	ISNULL(ta.PropertyAddress, tb.PropertyAddress) AS PropertyAddressCopy
FROM NashvilleHousing ta
INNER JOIN NashvilleHousing tb
ON ta.ParcelID = tb.ParcelID
AND ta.UniqueID != tb.UniqueID
WHERE ta.PropertyAddress IS NULL;

UPDATE ta
SET PropertyAddress = ISNULL(ta.PropertyAddress, tb.PropertyAddress)
FROM NashvilleHousing ta
INNER JOIN NashvilleHousing tb
ON ta.ParcelID = tb.ParcelID
AND ta.UniqueID != tb.UniqueID
WHERE ta.PropertyAddress IS NULL;

/* ======================================================================================
   Split 'PropertyAddress' into Address and City
   --------------------------------------------------------------------------------------
   Extracts and stores street address and city in separate columns for easier analysis
   and reporting.
   ====================================================================================== */

SELECT
	PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress)) AS City
FROM NashvilleHousing;

SELECT
	MAX(PropertyAddressNameLen)
FROM
	(SELECT LEN(PropertyAddress) AS PropertyAddressNameLen
	FROM NashvilleHousing
	GROUP BY PropertyAddress) t;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(50),
    PropertySplitCity NVARCHAR(50);
GO

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity   = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress));
GO

SELECT
	PropertyAddress,
	PropertySplitAddress,
	PropertySplitCity
FROM NashvilleHousing;

/* ======================================================================================
   Split 'OwnerAddress' into Address, City, and State
   --------------------------------------------------------------------------------------
   Uses PARSENAME with string replacement to parse 'OwnerAddress' into individual
   components, for separate column storage.
   ====================================================================================== */

SELECT
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 1) AS State
FROM NashvilleHousing;

SELECT
	MAX(OwnerAddressNameLen)
FROM
	(SELECT LEN(OwnerAddress) AS OwnerAddressNameLen
	FROM NashvilleHousing
	GROUP BY OwnerAddress) t;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(50),
    OwnerSplitCity NVARCHAR(50),
    OwnerSplitState NVARCHAR(50);
GO

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 3),
    OwnerSplitCity   = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 2),
    OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 1);
GO

SELECT
	OwnerAddress,
	OwnerSplitAddress,
	OwnerSplitCity,
	OwnerSplitState
FROM NashvilleHousing;

/* ======================================================================================
   Standardize 'SoldAsVacant' Values
   --------------------------------------------------------------------------------------
   Converts categorical values 'Y'/'N' to 'Yes'/'No' for better readability
   and consistency in reporting and analysis.
   ====================================================================================== */

SELECT DISTINCT
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END AS SoldAsVacant
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                   END;

SELECT DISTINCT
	SoldAsVacant
FROM NashvilleHousing;

/* ======================================================================================
   Remove Duplicate Records
   --------------------------------------------------------------------------------------
   Uses ROW_NUMBER() to identify duplicates based on key columns and deletes duplicate
   occurrences, keeping only unique instances.
   ====================================================================================== */

WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY ParcelID) AS RowNum
	FROM NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE RowNum > 1;

SELECT *
FROM RowNumCTE
WHERE RowNum > 1;

/* ======================================================================================
   Drop Original Columns After Splitting
   --------------------------------------------------------------------------------------
   Removes redundant columns that have been split or replaced to maintain
   a clean and normalized table structure.
   ====================================================================================== */

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress,
			TaxDistrict,
			OwnerAddress;
			
SELECT *
FROM NashvilleHousing;
