select *
from housingdatasample;
select count(*)
from housingdatasample

/*column saledate is in date and timestamp format, where time doesnt show relevant data
we should remove the time to standardize it*/
select saledate, convert(date, saledate) as  saledate_new
from housingdatasample

alter table housingdatasample add saledate_new date

update housingdatasample
set saledate_new = convert(date, saledate)

select saledate, saledate_new
from housingdatasample

/*ownername has null values, we have no way to retrieve it by just using this existing data*/
/*owneraddress column has null values but we can populate datas in it from propertyaddress
column*/
select propertyaddress
from housingdatasample
select count(distinct uniqueid)
from housingdatasample
select count(distinct parcelid)
from housingdatasample

select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from housingdatasample a
	join housingdatasample b
	on a.parcelID = b.parcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from housingdatasample a
	join housingdatasample b
	on a.parcelID = b.parcelID
	and a.[UniqueID ] <> b.[UniqueID ]

--breaking out address into individual columns (address, city, state)
--property address :
select substring(propertyaddress, 0 , charindex(',' ,propertyaddress)) as property_address,
	   substring(propertyaddress, charindex(',' ,propertyaddress) +1, len(propertyaddress)) as propert_city_address 
from housingdatasample

alter table housingdatasample
add Property_address char(50)
alter table housingdatasample
add Property_city_address char(50)

update housingdatasample
set Property_address = substring(propertyaddress, 0 , charindex(',' ,propertyaddress))
from housingdatasample

update housingdatasample
set Property_city_address = substring(propertyaddress, charindex(',' ,propertyaddress) +1, len(propertyaddress))
from housingdatasample


--owner address
select parsename(replace(owneraddress, ',','.'),3),
parsename(replace(owneraddress, ',','.'),2),
parsename(replace(owneraddress, ',','.'),1)
from housingdatasample


alter table housingdatasample
add owner_address char(50);
alter table housingdatasample
add owner_city_address char(50);
alter table housingdatasample
add owner_state_address char(50)

update housingdatasample
set owner_address = parsename(replace(owneraddress, ',','.'),3)
from housingdatasample

update housingdatasample
set owner_city_address = parsename(replace(owneraddress, ',','.'),2)
from housingdatasample

update housingdatasample
set owner_state_address = parsename(replace(owneraddress, ',','.'),1)
from housingdatasample



--remove duplicates
with rownumberCTE as (
select *,
	row_number() over (
	partition by parcelID,
				 landuse,
				 propertyaddress,
				 saledate,
				 saleprice,
				 legalreference,
				 soldasvacant,
				 ownername,
				 owneraddress,
				 acreage,
				 taxdistrict,
				 landvalue, 
				 buildingvalue,
				 totalvalue
				 order by uniqueID
				 ) row_num
from housingdatasample

)
select *
/*delete */
from rownumberCTE
where row_num > 1
-- this shows the duplicates


/*you can remove unnecessary columns but also you can just get the columns you want to export for the final
excel clean data*/
with housing_data_clean as (
select uniqueID, parcelID, landuse, property_address, property_city_address, saledate_new, saleprice, soldasvacant, owner_address, 
owner_city_address, owner_state_address, acreage, landvalue, buildingvalue, totalvalue, yearbuilt, bedrooms, fullbath, halfbath
from housingdatasample
)
select *
from housing_data_clean





