--Cleaning Data in SQL
SELECT *
FROM Project..NashvilleHousing;

------------------------------------------------------------------
--Standardize Date Format
--change date format to standard date (mm/dd/yyyy)
SELECT
	SaleDate,
	SaleDateConverted,
	CONVERT(Date, SaleDate)
FROM Project..NashvilleHousing;

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------------------
--Populate Property Address data
--null 29rows
--i check propertyaddress null from parcelid because same parcelid = same propertyaddress
SELECT
	*
FROM Project..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

--use selfjoin for check parcelid is be the same propertyaddress
--use ISNULL() if a.PropertyAddress is null add b.PropertyAddress
--use a.[UniqueID ] <> b.[UniqueID ] to distinguish different values (parcelID is the same but it not the same row)
SELECT
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project..NashvilleHousing AS a
JOIN Project..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Update a and recheck
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project..NashvilleHousing AS a
JOIN Project..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

------------------------------------------------------------------
--Breaking out address into individual columns (address, city, state)
--PropertyAddress have comma after comma is city
SELECT
	PropertyAddress
FROM Project..NashvilleHousing

--separate city from address
--use substring and chareacter index to find words
--I got all the rows with comma and i fill -1 to remove comma
--use substring and chareacter index again to find word start with comma and use LEN() because each row of text has a different length
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM Project..NashvilleHousing

--create new table and update value
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM Project..NashvilleHousing

--separate city and state from OwnerAddress
SELECT
	OwnerAddress
FROM Project..NashvilleHousing;

--Using the PARSENAME function to split delimited data
--why use REPLACE function because i have to look for comma and dot in there and replace them
SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--recheck
SELECT *
FROM Project..NashvilleHousing

------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field
--use DISTINCT() and COUNT() to check value and group by
SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldASVacant)
FROM Project..NashvilleHousing
GROUP BY SoldASVacant
ORDER BY COUNT(SoldASVacant)

--use CASE Statement to Change Y to Yes and N to No
SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant END
FROM Project..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant END

------------------------------------------------------------------
--Remove Duplicates
--use window function to find duplicate rows from those columns
--use common table expression because window function can't use where clause
WITH RowNumCTE AS(
SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
	ORDER BY
		UniqueID) AS ROW_NUM
FROM Project..NashvilleHousing
--ORDER BY UniqueID
)
--i delete duplicates row and i select * again to recheck
DELETE
FROM RowNumCTE
WHERE ROW_NUM > 1
--ORDER BY PropertyAddress

------------------------------------------------------------------
--Delete Unused Columns
SELECT *
FROM Project..NashvilleHousing

ALTER TABLE Project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Project..NashvilleHousing
DROP COLUMN SaleDate

------------------------------------------------------------------
