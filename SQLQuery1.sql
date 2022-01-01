/* cleaning data

*/

SELECT * 
FROM NashvilleHousing
;

-- Fix up the date format

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM NashvilleHousing
;


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)
;

-- Populate Property Address Data

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID
;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
;

-- Split the address into separate colunms for address and city
SELECT PropertyAddress
FROM NashvilleHousing
;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing
;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))
;

Select 
Parsename(replace(OwnerAddress, ',', '.'), 3),
Parsename(replace(OwnerAddress, ',', '.'), 2),
Parsename(replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing
;

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = Parsename(replace(OwnerAddress, ',', '.'), 2)
;

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = Parsename(replace(OwnerAddress, ',', '.'), 1)
;

-- Clean up 'SoldAsVacant' field by changing Y to Yes and N to No
Select SoldAsVacant, 
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END
From NashvilleHousing
;

Update NashvilleHousing
Set SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END
;


--Remove Duplicates


WITH RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	Partition By 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
		) row_num
FROM NashvilleHousing
-- ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
Where row_num > 1
;


Select * FROM NashvilleHousing


--Delete Unused Columns

Select *
FROM NashvilleHousing

ALTER TABLE
NashvilleHousing
DROP COLUMN
OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE
NashvilleHousing
DROP COLUMN
SaleDate