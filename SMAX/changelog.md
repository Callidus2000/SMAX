# Changelog

## 1.4.0 (2026-07-22)
 - New: Resolve-SMAXEntityInput prepares JSON strings, PSCustomObjects, dictionaries,
	 and pipeline input for SMAX entity operations.
 - New: Metadata-driven property canonicalization, root entity-link lookups, ENUM
	 canonicalization, and nested UserOptions lookup tokens.
 - Documentation: Added resolver guidance and expanded module about topics.
 - Fixed: Corrected the Add-SMAXAssociation bulk example to use ExecuteBulk.

## 1.2.0 (2025-05-28)
 - New: Added Remove-SMAXEntity for entity removal.
 - Changed: Reduced logging levels when no bulk data is available.

## 1.1.0 (2025-02-28)
 - New: Added attachment upload support, including multipart upload handling.
 - Documentation: Added comment-based help and module documentation.
 - Changed: Performed code cleanup and organization improvements.

## 1.0.0 (2024-11-15)
 - Fixed: Prevented errors when flattening a null result.
 - Fixed: Resolved PowerShell Universal integration issues.

## 0.1.1 (2024-06-20)
 - Fixed: Improved logging and documentation.
 - Fixed: Corrected bulk edit behavior.

## Pre-release history (2023-09-08 to 2023-09-29)
 - New: Added generic entity queries with paging and paging progress reporting.
 - New: Added entity type, property, and subtype tab completion.
 - New: Added entity association, comment, user option, and bulk create/update support.
 - New: Added empty entity object generation and serialized connection support.
 - Changed: Renamed the module to SMAX and standardized EntityType terminology.
 - Changed: Improved sorting, data enrichment, authentication cookie refresh, and
	 user option handling.
 - Documentation: Added comment-based help, README content, and logging strings.
 - Fixed: Corrected parameter and small runtime issues.