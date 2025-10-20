# Nashville Housing ETL & Standardization

This project focuses on cleaning, transforming, and standardizing a comprehensive housing dataset for Nashville properties. The main goal is to ensure data consistency, proper formatting, and readiness for advanced analytics and reporting.

The operations performed include:

- Converting `SaleDate` to proper SQL `DATE` type for accurate time-based analysis.
- Filling missing `PropertyAddress` values using matching `ParcelID` entries.
- Splitting combined address fields (`PropertyAddress` and `OwnerAddress`) into separate columns (street, city, state) for easier analysis.
- Standardizing categorical columns, e.g., converting `SoldAsVacant` from 'Y'/'N' to 'Yes'/'No'.
- Identifying and removing duplicate records to maintain data integrity.
- Dropping original redundant columns after splitting to maintain a clean table structure.

---

## Key Features

1. **Date Conversion**  
   Converts `SaleDate` to SQL `DATE` type and ensures accurate date calculations.

2. **Address Handling**  
   - Fills NULL `PropertyAddress` values using self-joins based on `ParcelID`.
   - Splits `PropertyAddress` into `PropertySplitAddress` and `PropertySplitCity`.
   - Splits `OwnerAddress` into `OwnerSplitAddress`, `OwnerSplitCity`, and `OwnerSplitState`.

3. **Data Standardization**  
   Standardizes `SoldAsVacant` column for clarity in reporting.

4. **Deduplication**  
   Uses `ROW_NUMBER()` to remove duplicate records based on key columns, keeping only unique entries.

5. **Table Cleanup**  
   Drops redundant columns (`PropertyAddress`, `OwnerAddress`, `TaxDistrict`) after transformation.

---

## Script Usage

1. Run the SQL script in a SQL Server environment where the `NashvilleHousing` table exists.
2. The script automatically performs all cleaning, transformation, and deduplication steps.
3. After execution, the table will be normalized and ready for analysis.

⚠️ **This script is designed for one-time execution** on the `NashvilleHousing` table.
- It performs irreversible operations, such as dropping and renaming columns.
- Running it multiple times without modifications may cause errors or data loss.

## Notes

- Ensure you have proper backups before running the script, as it drops and updates columns.
- Designed for SQL Server but can be adapted for other SQL-based systems with minor modifications.

---

## Outcome

After running this script, the `NashvilleHousing` table is:

- Consistent and cleaned.
- Free of duplicates.
- Ready for reporting and advanced data analytics.
- Optimized for querying with separate columns for addresses and standardized categorical values.

---



---


