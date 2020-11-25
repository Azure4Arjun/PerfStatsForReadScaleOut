SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON
GO
PRINT 'Starting SQL Azure Perf Stats Script...'
SET LANGUAGE us_english
PRINT '-- Script Source --'
SELECT 'SQL Azure Perf Stats Script' AS script_name, '$Revision: 12 $ ($Change: 3355 $)' AS revision
PRINT ''
PRINT '-- Script and Environment Details --'
PRINT 'Name                     Value'
PRINT '------------------------ ---------------------------------------------------'
PRINT 'SQL Server Name          ' + @@SERVERNAME
--PRINT 'Machine Name             ' + CONVERT (varchar, SERVERPROPERTY ('MachineName'))
PRINT 'SQL Version (SP)         ' + CONVERT (varchar, SERVERPROPERTY ('ProductVersion')) + ' (' + CONVERT (varchar, SERVERPROPERTY ('ProductLevel')) + ')'
PRINT 'Edition                  ' + CONVERT (varchar, SERVERPROPERTY ('Edition'))
--PRINT 'Script Name              SQL 11 Perf Stats Script'
--PRINT 'Script File Name         $File: SQL_11_Perf_Stats.sql $'
--PRINT 'Revision                 $Revision: 12 $ ($Change: 3355 $)'
--PRINT 'Last Modified            $Date: 2011/03/03 10:03:24 $'
PRINT 'Script Begin Time        ' + CONVERT (varchar(30), GETDATE(), 126) 
PRINT 'Current Database         ' + DB_NAME()
PRINT ''
GO

DECLARE @servermajorversion int
-- SERVERPROPERTY ('ProductVersion') returns e.g. "9.00.2198.00" --> 9
SET @servermajorversion = REPLACE (LEFT (CONVERT (varchar, SERVERPROPERTY ('ProductVersion')), 2), '.', '')
IF (@servermajorversion < 10)
  PRINT 'This script only runs on SQL Server 11 and later. Exiting.'
ELSE BEGIN
  -- Main loop
  DECLARE @i int
  DECLARE @msg varchar(100)
  DECLARE @runtime datetime
  SET @i = 0
  WHILE (1=1)
  BEGIN
    SET @runtime = GETDATE()
    SET @msg = 'Start time: ' + CONVERT (varchar(30), @runtime, 126)
    IF '%runmode%' = 'REALTIME' 
      INSERT INTO tbl_RUNTIMES (runtime, source_script) VALUES (@runtime, 'SQL Azure Perf Stats Script')
    PRINT ''
    RAISERROR (@msg, 0, 1) WITH NOWAIT
  
    -- Collect sp_perf_stats every 10 seconds
    EXEC sp_perf_stats_azure @appname = '%appname%', @runtime = @runtime

	/*Added 01/30 -Rohitna*/
	-- Collect sp_perf_stats_infrequent11 every minute
    IF @i = 0
      EXEC sp_perf_stats_azure_infrequent11 @runtime = @runtime, @firstrun = 1
    ELSE IF @i % 6 = 0
      EXEC sp_perf_stats_azure_infrequent11 @runtime = @runtime

  
    WAITFOR DELAY '$(delayvar)'
    SET @i = @i + 1
  END
END
GO

SET NOCOUNT OFF
SET QUOTED_IDENTIFIER OFF
GO

