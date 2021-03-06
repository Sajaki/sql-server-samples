-- Run data simulation to populate the database.
-- Runtime: ~40 minutes

USE WideWorldImporters;
GO

SET NOCOUNT ON;

DECLARE @BeginDate DATETIME
DECLARE @EndDate DATETIME
DECLARE @BatchDaySize INT

SET @BeginDate = '20130101'
SET @EndDate = '20160531'
-- To control the size of batch for each commit
-- size 10 is the optimized value in my test 
SET @BatchDaySize = 10

DECLARE @BatchBeginDate DATETIME
DECLARE @BatchEndDate DATETIME
SET @BatchBeginDate = @BeginDate

EXEC DataLoadSimulation.Configuration_ApplyDataLoadSimulationProcedures;

WHILE(@BatchBeginDate<=@EndDate)
BEGIN
	SET @BatchEndDate =DATEADD(d,@BatchDaySize-1,@BatchBeginDate)
	IF(@BatchEndDate>@EndDate) SET @BatchEndDate = @EndDate

	BEGIN TRANSACTION;
	GO

	EXEC DataLoadSimulation.DailyProcessToCreateHistory 
		@StartDate = @BatchBeginDate,
		@EndDate = @BatchEndDate,
		@AverageNumberOfCustomerOrdersPerDay = 60,
		@SaturdayPercentageOfNormalWorkDay = 50,
		@SundayPercentageOfNormalWorkDay = 0,
		@UpdateCustomFields = 1,
		@IsSilentMode = 1,
		@AreDatesPrinted = 1;

	COMMIT TRANSACTION;  
	GO

	SET @BatchBeginDate=DATEADD(d,1,@BatchEndDate)
END

EXEC WideWorldImporters.DataLoadSimulation.Configuration_RemoveDataLoadSimulationProcedures;
