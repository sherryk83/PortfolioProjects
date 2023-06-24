/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing

--Standarize Date Format

select SaleDate, CONVERT(Date,SaleDate) as SaledateUpdated
From PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = SaleDateUpdated

--Populate Property Address Data


Select * 
from PortfolioProject..NashvilleHousing
where PropertyAddress is Null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is Null


--Breaking out Addresses into Individual Columns (Address, City, State)

select PropertyAddress
From PortfolioProject..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

Alter TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

Alter TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

--We can us the above method to change the owner address or use an other method as below

Select OwnerAddress
From PortfolioProject..NashvilleHousing
where OwnerAddress is not null

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) 
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2) 
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1) 
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

Select *
From PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), COUNT(SoldASVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant =Case When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End

--Remove Duplicates


WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By 
					UniqueID
					) row_num	
From PortfolioProject..NashvilleHousing
)
DELETE
From RowNumCTE
where row_num > 1
--Order by PropertyAddress

-- Result shows 104 Duplicates. In case to delete those we will just replace select with DELETE

--Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

Alter TABLE PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress,SaleDate