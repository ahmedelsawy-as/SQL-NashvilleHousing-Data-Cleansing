/*

Disclaimer:
This project intended to showcase my skills. 
As a data analyst, I wouldn't delete/alter raw data without prior approvals.

*/


--Exploring dataset:
	SELECT TOP 100 *
	FROM NashvilleHousing


-- Cleaning SaleDate column datatype:
	--Method 1
	--step 1
	ALTER TABLE NashvilleHousing ADD SaleDateClean date
	--step 2
	UPDATE NashvilleHousing SET SaleDateClean = SaleDate

	--Method 2
	ALTER TABLE NashvilleHousing ALTER COLUMN SaleDateClean date	

	--check for success
	select SaleDate, SaleDateClean
	from NashvilleHousing


-- Cleaning PropertyAddress column:
	-- PropertyAddress is unique for each ParcelID
	select 
		t1.UniqueID as t1_ID, 
		t2.UniqueID as t2_ID,
		t1.ParcelID as t1_p_id, 
		t2.ParcelID as t2_p_id, 
		t1.PropertyAddress as t1_p_address,
		t2.PropertyAddress as t2_p_address
	from NashvilleHousing t1
	join NashvilleHousing t2
		on t1.ParcelID = t2.ParcelID
		and t1.UniqueID != t2.UniqueID
	where t1.PropertyAddress is null 
	
	-- refilling nulls by correct data
	Update t1 set t1.PropertyAddress = isnull(t1.PropertyAddress,t2.PropertyAddress)	
	from NashvilleHousing t1
	join NashvilleHousing t2
		on t1.ParcelID = t2.ParcelID
		and t1.UniqueID != t2.UniqueID
	where t1.PropertyAddress is null 
	
	--check for success
	select PropertyAddress
	from NashvilleHousing
	where PropertyAddress is null


	-- separate address items address/city:
	--preview
	select
	PropertyAddress,
	LEFT(PropertyAddress, CHARINDEX(',',PropertyAddress)-1) as PropertyAddressClean,
	RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',',PropertyAddress)-1) as PropertyCity
	from NashvilleHousing
	
	--execute
	ALTER TABLE NashvilleHousing ADD PropertyAddressClean nvarchar(255), PropertyCity nvarchar(255);
	UPDATE NashvilleHousing SET PropertyAddressClean = LEFT(PropertyAddress, CHARINDEX(',',PropertyAddress)-1),
	PropertyCity = RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',',PropertyAddress)-1)
	
	--check for success
	select PropertyAddress, PropertyAddressClean, PropertyCity
	from NashvilleHousing


-- Cleaning OwnerAddress column:
	SELECT OwnerAddress
	FROM NashvilleHousing

	-- separate address items address/city/state:

	--preview
	select
	OwnerAddress,
	LEFT(OwnerAddress, CHARINDEX(',',OwnerAddress)-1) as OwnerAddressClean,
	RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',',OwnerAddress)-1) as OwnerCityState,
	LEFT(RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',',OwnerAddress)-1), CHARINDEX(',',RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',',OwnerAddress)-1))-1) as OwnerCity,
	RIGHT(RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',',OwnerAddress)-1), LEN(RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',',OwnerAddress)-1)) - CHARINDEX(',',RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',',OwnerAddress)-1))-1) as OwnerState
	from NashvilleHousing

	--another preview
	select
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) state,
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) city,
	PARSENAME(REPLACE(OwnerAddress,',','.'),3) address
	from NashvilleHousing

	--execute
	ALTER TABLE NashvilleHousing ADD OwnerAddressClean nvarchar(255), OwnerCity nvarchar(255),OwnerState nvarchar(255);
	UPDATE NashvilleHousing SET 
	OwnerAddressClean = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

	--check for success
	select OwnerAddress, OwnerAddressClean, OwnerCity, OwnerState
	from NashvilleHousing


-- Cleaning SoldAsVacant column:
	SELECT distinct  SoldAsVacant
	FROM NashvilleHousing

	-- Y=Yes& N=No
	select 
	SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes' 
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end as SoldAsVacantClean
	from NashvilleHousing

	--execute
	UPDATE NashvilleHousing SET SoldAsVacant = 
	case when SoldAsVacant = 'Y' then 'Yes' 
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end

	--check for success
	SELECT distinct  SoldAsVacant
	FROM NashvilleHousing


-- Remove 104 Duplicates:
	--preview
	with ranked as (
	select *,
	RANK() over (partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference,SoldAsVacant   order by UniqueID) as ranking
	from NashvilleHousing)
	select*
	from ranked
	where ranking>1
	order by ParcelID

	--excute
	with ranked as 
				(
				select *,
				RANK() over (partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference,SoldAsVacant   order by UniqueID) as ranking
				from NashvilleHousing
				)
	DELETE
	from ranked
	where ranking>1
	
	--check for success
	with ranked as 
				(
				select *,
				RANK() over (partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference,SoldAsVacant   order by UniqueID) as ranking
				from NashvilleHousing
				)
	select*
	from ranked
	where ranking>1
	order by ParcelID


-- Delete Some excess columns that we've used for cleaning
	--preview
	select 
	SaleDate, SaleDateClean,
	PropertyAddress, PropertyAddressClean, 
	OwnerAddress, OwnerAddressClean, OwnerCity, OwnerState	  
	from NashvilleHousing

	--execute
	ALTER TABLE NashvilleHousing
	DROP COLUMN SaleDate, PropertyAddress, OwnerAddress

	--check for success
	select SaleDate, PropertyAddress, OwnerAddress from NashvilleHousing

	SELECT TOP 100 * 
	FROM NashvilleHousing
