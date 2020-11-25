# SQL Azure Perf Stats
Follow the instructions below to collect Perf Stats script output from your Sql Azure database using your Read Scale database or readonly database

## Prerequisites
- Sql login that has access to both the user database and master database
- Name of your database server, provided without .database.windows.net to the script
- Verify your system has SQL Server tools installed. specifically sqlcmd.exe should be available. In the command line, type sqlcmd.exe. if it says "is not recognized as an internal or external command", you need to locate sqlcmd.exe and add it to path environement variable.
- Please, use the latest version of sqlcmd - https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver15

## To Use

1. Unzip sql-azure-perf-stats.zip

2. After unzipping the files, you should see the following files apart from this README
	- PerfStats.ps1
	- SQL_Azure_Perf_Stats.sql
	- SQL_Azure_Perf_Stats_Primary.sql
	- SQL_Azure_Perf_Stats_Snapshot.sql
	

3. Open PowerShell and cd to the directory you unzipped the files

4. So that you can run the script run and confirm the change
`Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted`

5. When issue occurs, run PerfStats.ps1 from PowerShell:
`.\PerfStats.ps1` and follow the prompts or:
`.\PerfStats.ps1 -ServerName <servername> -Database <databasename> -Username <username> -Password <password>`
Optionally you can use -DelayInSeconds <numberofseconds> to change how often the script gathers data and -AzureUSGov to run against the US National Cloud

6. Press Ctrl+C to end the data collection process

7. Afterwards you will have an output folder containing <servername>_SQL_Azure_Perf_Stats.txt
