DROP TABLE zaliczenie.DimName

CREATE TABLE zaliczenie.DimName
(
	NameId INT IDENTITY(1,1),
	Name NVARCHAR(150),
	Year NVARCHAR(10), -- Du¿o N/A wystêpuje
	PlatformId INT FOREIGN KEY REFERENCES zaliczenie.DimPlatform(PlatformId),
	GenreId INT FOREIGN KEY REFERENCES zaliczenie.DimGenre(GenreId),
	PublisherId INT FOREIGN KEY REFERENCES zaliczenie.DimPublisher(PublisherId)

	CONSTRAINT PK_DimName_NameId PRIMARY KEY CLUSTERED
	(
	NameId ASC
	)
)

CREATE OR ALTER PROCEDURE zaliczenie.LD_DimName AS
BEGIN TRY
    BEGIN TRANSACTION
		DROP TABLE IF EXISTS #tmpDim 
		SELECT
			stg.Name,
			[stg].[Year],
			plat.PlatformId,
			genre.GenreId,
			publish.PublisherId
		INTO
			#tmpDim
		FROM
		zaliczenie.StagingTable stg
		JOIN
		zaliczenie.DimPlatform plat
		ON [stg].[Platform] = plat.PlatformName
		JOIN
		zaliczenie.DimGenre genre
		ON [stg].[Genre] = genre.GenreName
		JOIN
		zaliczenie.DimPublisher publish
		ON [stg].[Publisher] = publish.PublisherName

        INSERT INTO zaliczenie.DimName(Name, Year, PlatformId, GenreId, PublisherId)
		SELECT
			Name,
			Year,
			PlatformId,
			GenreId,
			PublisherId
		FROM
			#tmpDim
		EXCEPT
		SELECT
			Name,
			Year,
			PlatformId,
			GenreId,
			PublisherId
		FROM zaliczenie.DimName
		DROP TABLE #tmpDim
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT ERROR_MESSAGE();
END CATCH
----------------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC zaliczenie.LD_DimName


SELECT * FROM zaliczenie.StagingTable
SELECT COUNT(Distinct Name) FROM zaliczenie.DimName
SELECT * FROM zaliczenie.DimName


SELECT * FROM zaliczenie.DimName


---------------------------------------------------------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE zaliczenie.FactTable
-- Faktowa

CREATE TABLE zaliczenie.FactTable
(
	  Id INT IDENTITY(1,1)
	, NameId INT FOREIGN KEY REFERENCES zaliczenie.DimName(NameId)
	, [NA_Sales] DECIMAL (8,2)
    , [EU_Sales] DECIMAL (8,2) 
    , [JP_Sales] DECIMAL (8,2)
    , [Other_Sales] DECIMAL (8,2)
    , [Global_Sales] DECIMAL (8,2)
    , [Rank] INT
	, CONSTRAINT PK_FactTable_Id PRIMARY KEY CLUSTERED
	(
	Id ASC
	)
)


CREATE OR ALTER PROCEDURE zaliczenie.LF_FactTable
AS
BEGIN TRY
	BEGIN TRANSACTION
		TRUNCATE TABLE zaliczenie.FactTable
		INSERT INTO zaliczenie.FactTable
		(
			  [NameId]
			, [NA_Sales]
			, [EU_Sales]
			, [JP_Sales]
			, [Other_Sales]
			, [Global_Sales]
			, [Rank]
		)
		SELECT 
          dn.NameId
        , stg.[NA_Sales]
        , stg.[EU_Sales]
        , stg.[JP_Sales]
        , stg.[Other_Sales]
        , stg.[Global_Sales]
        , stg.[Rank]
        FROM
          zaliczenie.StagingTable stg
        JOIN
			zaliczenie.DimName dn
			ON dn.Name = stg.Name
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT ERROR_MESSAGE();
END CATCH

EXEC zaliczenie.LF_FactTable

--------------------------------------------------------------------------------------------------------


-- WIDOK

CREATE OR ALTER VIEW zaliczenie.vw_Fact AS
SELECT
	LEFT(name.Name,LEN(name.Name)-1) AS Name
	,plat.[PlatformName]
	,genre.[GenreName]
	,pub.[PublisherName]
	,fct.[NA_Sales]
    ,fct.[EU_Sales]
    ,fct.[JP_Sales]
    ,fct.[Other_Sales]
    ,fct.[Global_Sales]
    ,fct.[Rank]
FROM
	zaliczenie.FactTable fct
JOIN
	zaliczenie.DimName name
ON
	name.NameId = fct.NameId
JOIN
	zaliczenie.DimPlatform plat
ON
	plat.PlatformId = name.PlatformId
JOIN
	zaliczenie.DimGenre genre
ON
	genre.GenreId = name.GenreId
JOIN
	zaliczenie.DimPublisher pub
ON
	pub.PublisherId = name.PublisherId


SELECT * FROM zaliczenie.vw_Fact


SELECT
	LEFT(name.Name,LEN(name.Name)-1)
	FROM
	zaliczenie.FactTable fct
	JOIN
	zaliczenie.DimName name
ON
	name.NameId = fct.NameId




