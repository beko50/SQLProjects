CREATE TABLE HousingData(
UniqueID BIGINT,
ParcelID VARCHAR(255),
LandUse	VARCHAR(255),
PropertyAddress	VARCHAR(255),
SaleDate DATE,
SalePrice	BIGINT,
LegalReference	VARCHAR(255),
SoldAsVacant VARCHAR(255),
OwnerName	VARCHAR(255),
OwnerAddress	VARCHAR(255),
Acreage	NUMERIC(10,3),
TaxDistrict	VARCHAR(255),
LandValue	BIGINT,
BuildingValue	BIGINT,
TotalValue	BIGINT,
YearBuilt	INTEGER,
Bedrooms	INTEGER,
FullBath	INTEGER,
HalfBath INTEGER
)

 SELECT * FROM HousingData
 --WHERE propertyaddress IS NULL
 ORDER BY ParcelID
 
 -- SELF-JOIN on the same table
 SELECT a.ownerName,a.ownerADDRESS,a.salePrice,b.yearbuilt,b.BuildingValue
 FROM HousingData a
 JOIN HousingData b
 ON a.ParcelID = b.ParcelID
 
 -- SPLITTING addresses into different columns
 SELECT propertyAddress,SUBSTRING (PropertyAddress,1,POSITION(',' IN PropertyAddress) - 1) as street_address, 
 SUBSTRING (PropertyAddress,POSITION(',' IN PropertyAddress) + 1) as town
 FROM HousingData
 
 -- ADDING street_address column
 ALTER TABLE HousingData 
 ADD COLUMN street_address VARCHAR(255)
 -- updating the table
 UPDATE HousingData
 SET street_address = SUBSTRING (PropertyAddress,1,POSITION(',' IN PropertyAddress) - 1)
 
 -- ADDING town column
 ALTER TABLE HousingData 
 ADD COLUMN town VARCHAR(255)
 -- updating the table
 UPDATE HousingData
 SET town = SUBSTRING (PropertyAddress,POSITION(',' IN PropertyAddress) + 1)
 
 
 -- CHECKING FOR MOST LANDUSE PURPOSES 
 SELECT landuse,COUNT(LandUse) AS landuse_frequency FROM HousingData
 GROUP BY landuse
 ORDER BY landuse_frequency DESC
 
 -- CHANGING Y / N to YES and NO USING CASE statements
     --SELECT DISTINCT (Soldasvacant) FROM HousingData             -- specifying the distinct values in the column
 SELECT Soldasvacant,
 	CASE 	
		WHEN SoldasVacant = 'Y' THEN 'Yes'
 		WHEN SoldasVacant = 'N' THEN 'No'
		ELSE SoldasVacant
	END
FROM HousingData