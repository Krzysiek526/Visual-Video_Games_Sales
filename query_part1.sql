--CREATE SCHEMA zaliczenie
/*
CREATE TABLE zaliczenie.[LandingTable]
(
[Name] VARCHAR(150),
[Platform] VARCHAR(50),
[Year] VARCHAR(50),
[Genre] VARCHAR(50),
[Publisher] VARCHAR(50),
[NA_Sales] VARCHAR(50),
[EU_Sales] VARCHAR(50),
[JP_Sales] VARCHAR(50),
[Other_Sales]VARCHAR(50),
[Global_Sales] VARCHAR(50),
[Rank] VARCHAR(50)
)
*/
SELECT * FROM zaliczenie.LandingTable
INSERT INTO zaliczenie.LandingTable
(
[Name]
)
Values
(1)

TRUNCATE TABLE zaliczenie.LandingTable

-- po data flow
SELECT * FROM zaliczenie.LandingTable
----------dotad dziala + laduje dane

--Tabela staging + procedura
CREATE TABLE zaliczenie.StagingTable
(
[Name] VARCHAR(150),
[Platform] VARCHAR(50),
[Year] VARCHAR(50),
[Genre] VARCHAR(50),
[Publisher] VARCHAR(50),
[NA_Sales] DECIMAL (6, 3),
[EU_Sales] DECIMAL (6, 3),
[JP_Sales] DECIMAL (6, 3),
[Other_Sales] DECIMAL (6, 3),
[Global_Sales] DECIMAL (6, 3),
[Rank] VARCHAR(50)
) ON [PRIMARY]
GO
DROP TABLE zaliczenie.StagingTable


SELECT * FROM zaliczenie.StagingTable
SELECT * FROM zaliczenie.LandingTable

CREATE OR ALTER PROCEDURE [zaliczenie].[LS_StagingTable] AS
BEGIN TRY
	BEGIN TRANSACTION
		TRUNCATE TABLE zaliczenie.StagingTable;
		INSERT INTO zaliczenie.StagingTable
		(
		  [Name]
		, [Platform]
		, [Year]
		, [Genre]
		, [Publisher]
		, [NA_Sales]
		, [EU_Sales]
		, [JP_Sales]
		, [Other_Sales]
		, [Global_Sales]
		, [Rank]
		)
		SELECT
		  CONCAT(CONCAT([Name],' ',[Platform]), ' ',ROW_NUMBER() OVER (Partition BY Name, Platform ORDER BY RANK)) AS Name
		  --[Name]
		, [Platform]
		, [Year]
		, [Genre]
		, [Publisher]
		, CAST([NA_Sales] AS DECIMAL (8, 2))
		, CAST([EU_Sales] AS DECIMAL (8, 2))
		, CAST([JP_Sales] AS DECIMAL (8, 2))
		, CAST([Other_Sales] AS DECIMAL (8, 2))
		, CAST([Global_Sales] AS DECIMAL (8, 2))
		, [Rank]
		FROM zaliczenie.LandingTable
		
	COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT ERROR_MESSAGE();
END CATCH

SELECT * FROM zaliczenie.StagingTable --pusta
SELECT * FROM zaliczenie.LandingTable

EXEC [zaliczenie].[LS_StagingTable] --odpalenie
/*

SELECT
		  [Name]
		, [Platform]
		, [Year]
		, [Genre]
		, [Publisher]
		, NA_Sales
		, ISNUMERIC(NA_Sales)
		--, CAST([NA_Sales] AS DECIMAL (8, 2))
		--, CAST([EU_Sales] AS DECIMAL (8, 2))
	--	, CAST([JP_Sales] AS DECIMAL (8, 2))
--		, CAST([Other_Sales] AS DECIMAL (8, 2))
	--	, CAST([Global_Sales] AS DECIMAL (8, 2))
		, [Rank]
		FROM zaliczenie.LandingTable

WHERE ISNUMERIC(NA_Sales) = 0

*/

TRUNCATE TABLE zaliczenie.StagingTable

SELECT * FROM zaliczenie.StagingTable
-- dotad dziala



DROP Table zaliczenie.DimPlatform
-- TWORZENIE DIMA PLATFORM
CREATE TABLE zaliczenie.DimPlatform
(
	PlatformId INT IDENTITY(1,1),
	PlatformName NVARCHAR(50),
	CONSTRAINT PK_DimPlatform_PlatformId PRIMARY KEY CLUSTERED
	(
	PlatformId ASC
	),
	CONSTRAINT UK_DimPlatform_PlatformName UNIQUE
	(
	PlatformName
	)
)



CREATE OR ALTER PROCEDURE zaliczenie.LD_DimPlatform AS
BEGIN TRY
    BEGIN TRANSACTION
        SELECT DISTINCT
            [Platform]
        INTO 
			#tmpDim
        FROM
            zaliczenie.LandingTable
        INSERT INTO zaliczenie.DimPlatform (PlatformName)
        SELECT
            [Platform]
        FROM #tmpDim
        EXCEPT
        SELECT PlatformName
        FROM
        zaliczenie.DimPlatform
        DROP TABLE #tmpDim
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT ERROR_MESSAGE();
END CATCH

--ladowanie danych
EXEC zaliczenie.LD_DimPlatform

-- test
SELECT * FROM zaliczenie.DimPlatform
-- dodanie bloku SSIS

-- TWORZENIE DIMA GENRE
DROP Table zaliczenie.DimGenre


CREATE TABLE zaliczenie.DimGenre
(
	GenreId INT IDENTITY(1,1),
	GenreName NVARCHAR(50),
	CONSTRAINT PK_DimGenre_GenreId PRIMARY KEY CLUSTERED
	(
	GenreId ASC
	),
	CONSTRAINT UK_DimGenre_GenreName UNIQUE
	(
	GenreName
	)
)

CREATE OR ALTER PROCEDURE zaliczenie.LD_DimGenre AS
BEGIN TRY
    BEGIN TRANSACTION
        SELECT DISTINCT
            Genre
        INTO 
			#tmpDim
        FROM
            zaliczenie.LandingTable
        INSERT INTO zaliczenie.DimGenre (GenreName)
        SELECT
            Genre
        FROM #tmpDim
        EXCEPT
        SELECT GenreName
        FROM
        zaliczenie.DimGenre
        DROP TABLE #tmpDim
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT ERROR_MESSAGE();
END CATCH

EXEC zaliczenie.LD_DimGenre

-- test
SELECT * FROM zaliczenie.DimGenre
-- blok SSIS

DROP TABLE zaliczenie.DimPublisher
-- DIM PUBLISHER
CREATE TABLE zaliczenie.DimPublisher
(
	PublisherId INT IDENTITY(1,1),
	PublisherName NVARCHAR(50),
	CONSTRAINT PK_DimPublisher_PublisherId PRIMARY KEY CLUSTERED
	(
	PublisherId ASC
	),
	CONSTRAINT UK_DimPublisher_PublisherName UNIQUE
	(
	PublisherName
	)
)

CREATE OR ALTER PROCEDURE zaliczenie.LD_DimPublisher AS
BEGIN TRY
    BEGIN TRANSACTION
        SELECT DISTINCT
            Publisher
        INTO 
			#tmpDim
        FROM
            zaliczenie.LandingTable
        INSERT INTO zaliczenie.DimPublisher (PublisherName)
        SELECT
            Publisher
        FROM #tmpDim
        EXCEPT
        SELECT PublisherName
        FROM
        zaliczenie.DimPublisher
        DROP TABLE #tmpDim
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT ERROR_MESSAGE();
END CATCH


EXEC zaliczenie.LD_DimPublisher

-- test
SELECT * FROM zaliczenie.DimPublisher



















