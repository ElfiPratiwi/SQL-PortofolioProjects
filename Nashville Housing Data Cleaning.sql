-- DATA CLEANING IN SQL

-- CHANGE THE DATA TYPE FROM TEXT TO DATE
select SaleDate
from housing;

update
	housing
set 
	SaleDate = str_to_date(SaleDate, '%M %d, %Y');
    
-- CHANGE THE DATA TYPE USING NEW FIELD
UPDATE housing
SET SaleDate = STR_TO_DATE(SaleDate, '%Y %M %d');

alter table housing
add dateconverted date;

update housing
set dateconverted = convert(SaleDate, date);

UPDATE housing
SET SaleDate = STR_TO_DATE(SaleDate, '%Y %M %d');

-- TIDY UP ADDRESS DATA
-- 1.fill the blank with nul
update housing
set PropertyAddress = null
where PropertyAddress = '';

-- 2.looking for a suitable address to enter into null data based in parcel id
select 
	a.ParcelID, 
    a.PropertyAddress, 
    b.ParcelID, 
    b.PropertyAddress, 
    ifnull(a.PropertyAddress, b.PropertyAddress) as mergedpropertyaddress
from housing a
join housing b
	on a.ParcelID = b.ParcelID
where 
	a.UniqueID != b.UniqueID 
    and a.PropertyAddress is null;

-- 3.fill in the empty address with the address table that has been created
UPDATE housing a
JOIN housing b ON a.ParcelID = b.ParcelID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.UniqueID != b.UniqueID AND a.PropertyAddress IS NULL;

-- 4.Check whether there is still null address data
select PropertyAddress
from housing
where PropertyAddress is null;

-- BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS (address, city, state)
select PropertyAddress
from housing;

select
	substring_index(PropertyAddress, ',', 1) as Address,
    substring_index(PropertyAddress, ',', -1) as City
from
	 housing;

-- CREATE A NEW COLUMN AND ADD ADDRESS AND CITY DATA IN IT
alter table housing
add PropertySplitAddress varchar(250);

update housing
set PropertySplitAddress = substring_index(PropertyAddress, ',', 1);

alter table housing
add PropertySplitCity varchar(250);

update housing
set PropertySplitCity = substring_index(PropertyAddress, ',', -1);

-- BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS (address, city, state)
alter table housing
add column OwnerSplitAddres varchar(255),
add column OwnerSplitCity varchar(255),
add column OwnerSplitCountry varchar(255);

update housing
set 
	OwnerSplitAddres = substring_index(substring_index(OwnerAddress, ',', 1), ',', -1),
    OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1),
	OwnerSplitCountry = substring_index(OwnerAddress, ',', -1);

-- NOTE : WE CAN ALSO USE PARSENAME TO SEPARATE DATA IN A FIELD, BUT MYSQL DOES NOT SUPPORT THIS COMMAND

-- CHANGE Y AND N TO YES AND NO IN THE SoldAsVacant COLUMN
update housing
set SoldAsVacant = 'No'
where SoldAsVacant = 'N';

update housing
set SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y';

select distinct SoldAsVacant from housing;

-- REMOVE DUPLICATES
with RowNumCTE as(
SELECT *,
	row_number() over (
    partition by ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
	order by UniqueID
				) row_num
FROM housing
-- order by ParcelID;
)
select *
from RowNumCTE
where row_num > 1;

DELETE FROM housing
WHERE UniqueID NOT IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID,
                                PropertyAddress,
                                SalePrice,
                                SaleDate,
                                LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM housing
    ) AS RowNumCTE
    WHERE row_num = 1
);

-- DELETE UNNECCESSARY COLUMNS
alter table housing
drop column OwnerAddress, 
drop column TaxDistrict, 
drop column PropertyAddress;

-- IMPORTANT NOTE :
-- 1. NEVER DELETE OR CHANGE DATA DIRECTLY FROM THE DATABASE
-- 2. CREATE A NEW TABLE IF YOU WANT TO CHANGE DATA IN A COLUMN
