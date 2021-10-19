
/*

Cleaning data in sql

*/
-----------------------------------------------------------------------------------------------------------


--Standardize SaleDate format

select * from [Nashville Housing]

select SaleDate, convert(date,SaleDate) 
from dbo.[Nashville Housing]

update [Nashville Housing]
set SaleDate = convert(date,SaleDate) 


------------------------------------------------------------------------------------------------------
--populate property address data

select PropertyAddress 
from [Nashville Housing] 

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing] as a
join [Nashville Housing] as b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing] as a
join [Nashville Housing] as b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]

-------------------------------------------------------------------------------------------------------------

--Breaking out PropertyAddress into individual columns (Address, city, state)


select PropertyAddress 
from [Nashville Housing] 

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from [Nashville Housing]

Alter table [Nashville Housing] 
add PropertySplitAddress Nvarchar(255)

Alter table [Nashville Housing] 
add PropertySplitCity Nvarchar(255)

update [Nashville Housing]
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

update [Nashville Housing]
set Propertysplitcity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


-------------------------------------------------------------------------------------------------------

--Breaking out OwnerAddress into individual columns (Address, city, state)


select OwnerAddress
from [Nashville Housing]

select 
Parsename(Replace(OwnerAddress,',','.'),3) as OwnerSplitAddress,
Parsename(Replace(OwnerAddress,',','.'),2) as OwnerSplitCity,
Parsename(Replace(OwnerAddress,',','.'),1) as OwnerSplitState
from [Nashville Housing]

Alter table [Nashville Housing]
add 
OwnerSplitAddress Nvarchar(255),
OwnerSplitCity Nvarchar(255),
OwnerSplitState Nvarchar(255)

update [Nashville Housing]
set 
OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3),
Ownersplitcity = Parsename(Replace(OwnerAddress,',','.'),2),
Ownersplitstate = Parsename(Replace(OwnerAddress,',','.'),1)


----------------------------------------------------------------------------------------------------------

--change 'Y' and 'N' to 'Yes' and 'No' in the Soldasvacant field


select distinct soldAsVacant
from [Nashville Housing]

select 
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end as SoldasVacant
from [Nashville Housing]

update [Nashville Housing]
set SoldAsVacant = case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

-- Removing duplicates

with Row_NumberCTE AS (
select *, ROW_NUMBER () over(
partition by ParcelID,
            PropertyAddress,
			SaleDate,
			LegalReference
			Order by
			UniqueID
			) as row_num
from [Nashville Housing]
)
Delete from Row_NumberCTE
where row_num >1

----------------------------------------------------------------------------------------------

-- Delete Unused Columns


Alter Table [Nashville Housing]
drop column OwnerAddress,TaxDistrict, PropertyAddress, SaleDate
