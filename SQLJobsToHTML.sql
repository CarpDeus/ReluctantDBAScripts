SET NOCOUNT ON
GO
USE master
DECLARE @JOB_ID VARCHAR(200),
		@SCHED_ID VARCHAR(200),
		@FREQ_TYPE INT,
		@FREQ_INTERVAL INT,
		@FREQ_SUBDAY_TYPE INT,
		@FREQ_SUBDAY_INTERVAL INT,
		@FREQ_RELATIVE_INTERVAL INT,
		@FREQ_RECURRENCE_FACTOR INT,
		@ACTIVE_START_DATE INT,
		@SCHEDULE VARCHAR(1000),
		@SCHEDULE_DAY VARCHAR(200),
		@START_TIME VARCHAR(10),
		@END_TIME VARCHAR(10)

CREATE TABLE #SCHEDULES
	(JOB_ID VARCHAR(200),
	 SCHED_ID VARCHAR(200),
	 JOB_NAME SYSNAME,
	 [STATUS] INT,
	 SCHEDULED INT NULL,
	 schedule VARCHAR(1000) NULL,
	 FREQ_TYPE INT NULL,
	 FREQ_INTERVAL INT NULL,
	 FREQ_SUBDAY_TYPE INT NULL,
	 FREQ_SUBDAY_INTERVAL INT NULL,
	 FREQ_RELATIVE_INTERVAL INT NULL,
	 FREQ_RECURRENCE_FACTOR INT NULL,
	 ACTIVE_START_DATE INT NULL,
	 ACTIVE_END_DATE INT NULL,
	 ACTIVE_START_TIME INT NULL,
	 ACTIVE_END_TIME INT NULL,
	 DATE_CREATED DATETIME NULL)

INSERT INTO #SCHEDULES (
	 job_id,
	 sched_id ,
	 job_name ,
	 [status] ,
	 Scheduled ,
	 schedule ,
	 freq_type,
	 freq_interval,
	 freq_subday_type,
	 freq_subday_interval,
	 freq_relative_interval,
	 freq_recurrence_factor,
	 active_start_date,
	 active_end_date,
	 active_start_time,
	 active_end_time,
	 date_created)

SELECT j.job_id, sched.schedule_id, j.name , j.enabled, sched.enabled, NULL, sched.freq_type,
		sched.freq_interval, sched.freq_subday_type, sched.freq_subday_interval, sched.freq_relative_interval,
		sched.freq_recurrence_factor, sched.active_start_date, sched.active_end_date, sched.active_start_time,
		sched.active_end_time, j.date_created
FROM msdb.dbo.sysjobs j inner join msdb.dbo.sysjobschedules s ON j.job_id=s.job_id
INNER JOIN msdb.dbo.sysschedules sched ON s.schedule_id = sched.schedule_id

WHILE 1=1
BEGIN
SET @SCHEDULE = ''
IF (SELECT COUNT(*) FROM #SCHEDULES WHERE scheduled=1 and schedule is null) = 0
BREAK
ELSE
BEGIN
SELECT @job_id=job_id, @sched_id=sched_id, @freq_type=freq_type, @Freq_Interval=freq_interval, 
		@freq_subday_type=freq_subday_type, @freq_subday_interval=freq_subday_interval,
		@freq_relative_interval=freq_relative_interval, @freq_recurrence_factor=freq_recurrence_factor, 
		@active_start_date = active_start_date, @start_time = CASE WHEN
			LEFT(active_start_time, 2) IN (22, 23) AND len(active_start_time) = 6 THEN
				convert(varchar(2), left(active_start_time, 2) - 12) + ':' + SUBSTRING(CAST(active_start_time AS CHAR),3, 2) + ' P.M'
			WHEN left(active_start_time, 2) = (12) AND len(active_start_time) = 6
				THEN cast(LEFT(active_start_time,2) as char(2)) + ':' + SUBSTRING(CAST(active_start_time AS CHAR),3, 2) + ' P.M.'
			WHEN left(active_start_time, 2) BETWEEN 13 AND 24 AND len(active_start_time) = 6
				THEN convert(varchar(2), left(active_start_time, 2) - 12) + ':' + SUBSTRING(CAST(active_start_time AS CHAR),3, 2) + ' P.M.'
			WHEN left(active_start_time, 2) IN (10, 11) AND len(active_start_time) = 6
				THEN cast(LEFT(active_start_time,2) as char(2)) + ':' + SUBSTRING(CAST(active_start_time AS CHAR),3, 2) + ' A.M.'
			WHEN active_start_time = 0
				THEN '12:00 A.M.'
			WHEN LEN(active_start_time) = 4
				THEN '12:' + convert(varchar(2), left(active_start_time, 2) ) + ' A.M.'
			WHEN LEN(active_start_time) = 3
				THEN '12:0' + convert(varchar(2), left(active_start_time, 1) ) + ' A.M.'
			WHEN LEN(active_start_time) = 2
				THEN '12:00:' + convert(varchar(2), left(active_start_time, 2) ) + ' A.M.'	
			WHEN LEN(active_start_time) = 1
				THEN '12:00:0' + convert(varchar(2), left(active_start_time, 2) ) + ' A.M.'
			ELSE cast(LEFT(active_start_time,1) as char(1)) + ':' + SUBSTRING(CAST(active_start_time AS CHAR),2, 2) + ' A.M.'
		END,
@END_TIME= CASE WHEN left(active_end_time, 2) IN (22, 23) AND len(active_end_time) = 6
			THEN convert(varchar(2), left(active_end_time, 2) - 12) + ':' + SUBSTRING(CAST(active_end_time AS CHAR),3, 2) + ' P.M'
		WHEN left(active_end_time, 2) = (12) AND len(active_end_time) = 6
			THEN cast(LEFT(active_end_time,2) as char(2)) + ':' + SUBSTRING(CAST(active_end_time AS CHAR),3, 2) + ' P.M.'
		WHEN left(active_end_time, 2) BETWEEN 13 AND 24 AND len(active_end_time) = 6
			THEN convert(varchar(2), left(active_end_time, 2) - 12) + ':' + SUBSTRING(CAST(active_end_time AS CHAR),3, 2) + ' P.M.'
		WHEN left(active_end_time, 2) IN (10, 11) AND len(active_end_time) = 6
			THEN cast(LEFT(active_end_time,2) as char(2)) + ':' + SUBSTRING(CAST(active_end_time AS CHAR),3, 2) + ' A.M.'
		WHEN active_end_time = 0
			THEN '12:00 A.M.'
		WHEN LEN(active_end_time) = 4
			THEN '12:' + convert(varchar(2), left(active_end_time, 2) ) + ' A.M.'
		WHEN LEN(active_end_time) = 3
			THEN '12:0' + convert(varchar(2), left(active_end_time, 1) ) + ' A.M.'
		WHEN LEN(active_end_time) = 2
			THEN '12:00:' + convert(varchar(2), left(active_end_time, 2) ) + ' A.M.'
		WHEN LEN(active_end_time) = 1
			THEN '12:00:0' + convert(varchar(2), left(active_end_time, 2) ) + ' A.M.'
		ELSE cast(LEFT(active_end_time,1) as char(1)) + ':' + SUBSTRING(CAST(active_end_time AS CHAR),2, 2) + ' A.M.'
END
FROM #SCHEDULES WHERE schedule is null AND scheduled=1
IF EXISTS(SELECT @freq_type WHERE @freq_type in (1,64))
BEGIN
SELECT @SCHEDULE = CASE @freq_type
WHEN 1 THEN 'Occurs Once, On '+cast(@active_start_date as varchar(8))+', At '+@start_time
WHEN 64 THEN 'Occurs When SQL Server Agent Starts'
END
END
ELSE
BEGIN
IF @freq_type=4
BEGIN
SELECT @SCHEDULE = 'Occurs Every '+cast(@freq_interval as varchar(10))+' Day(s)'
END
IF @freq_type=8
BEGIN
SELECT @SCHEDULE = 'Occurs Every '+cast(@freq_recurrence_factor as varchar(3))+' Week(s)'
SELECT @schedule_day=''
IF (SELECT (convert(int,(@freq_interval/1)) % 2)) = 1
select @schedule_day = @schedule_day+'Sun'
IF (SELECT (convert(int,(@freq_interval/2)) % 2)) = 1
select @schedule_day = @schedule_day+'Mon'
IF (SELECT (convert(int,(@freq_interval/4)) % 2)) = 1
select @schedule_day = @schedule_day+'Tue'
IF (SELECT (convert(int,(@freq_interval/8)) % 2)) = 1
select @schedule_day = @schedule_day+'Wed'
IF (SELECT (convert(int,(@freq_interval/16)) % 2)) = 1
select @schedule_day = @schedule_day+'Thu'
IF (SELECT (convert(int,(@freq_interval/32)) % 2)) = 1
select @schedule_day = @schedule_day+'Fri'
IF (SELECT (convert(int,(@freq_interval/64)) % 2)) = 1
select @schedule_day = @schedule_day+'Sat'
SELECT @SCHEDULE = @SCHEDULE+', On '+@schedule_day
END
IF @freq_type=16
BEGIN
SELECT @SCHEDULE = 'Occurs Every '+cast(@freq_recurrence_factor as varchar(3))+' Month(s) on Day '+cast(@freq_interval as varchar(3))+' of that Month'
END
IF @freq_type=32
BEGIN
SELECT @SCHEDULE = CASE @freq_relative_interval
WHEN 1 THEN 'First'
WHEN 2 THEN 'Second'
WHEN 4 THEN 'Third'
WHEN 8 THEN 'Fourth'
WHEN 16 THEN 'Last'
ELSE 'Not Applicable'
END
SELECT @SCHEDULE =
CASE @freq_interval
WHEN 1 THEN 'Occurs Every '+@SCHEDULE+' Sunday of the Month'
WHEN 2 THEN 'Occurs Every '+@SCHEDULE+' Monday of the Month'
WHEN 3 THEN 'Occurs Every '+@SCHEDULE+' Tueday of the Month'
WHEN 4 THEN 'Occurs Every '+@SCHEDULE+' Wednesday of the Month'
WHEN 5 THEN 'Occurs Every '+@SCHEDULE+' Thursday of the Month'
WHEN 6 THEN 'Occurs Every '+@SCHEDULE+' Friday of the Month'
WHEN 7 THEN 'Occurs Every '+@SCHEDULE+' Saturday of the Month'
WHEN 8 THEN 'Occurs Every '+@SCHEDULE+' Day of the Month'
WHEN 9 THEN 'Occurs Every '+@SCHEDULE+' Weekday of the Month'
WHEN 10 THEN 'Occurs Every '+@SCHEDULE+' Weekend Day of the Month'
END
END
SELECT @SCHEDULE =
CASE @freq_subday_type
WHEN 1 THEN @SCHEDULE+', At '+@start_time
WHEN 2 THEN @SCHEDULE+', every '+cast(@freq_subday_interval as varchar(3))+' Second(s) Between '+@start_time+' and '+@END_TIME
WHEN 4 THEN @SCHEDULE+', every '+cast(@freq_subday_interval as varchar(3))+' Minute(s) Between '+@start_time+' and '+@END_TIME
WHEN 8 THEN @SCHEDULE+', every '+cast(@freq_subday_interval as varchar(3))+' Hour(s) Between '+@start_time+' and '+@END_TIME
END
END
END
UPDATE #SCHEDULES
SET schedule=@SCHEDULE
WHERE job_id=@job_id
AND sched_id=@sched_Id
END




create table #DrivingData
(JobID uniqueidentifier not null primary key,
Enabled int,
JobName nvarchar(150),
JobDescription nvarchar(1024),
DateCreated datetime,
DateModified datetime,
VersionNumber int,
Processed int)

INSERT INTO #DrivingData
SELeCT job_id,
CAST(sv.enabled AS bit) AS [IsEnabled],
sv.name AS [Name], Description,
Date_Created, Date_Modified, version_number, 0
FROM
msdb.dbo.sysjobs_view AS sv
ORDER BY
[Name] ASC
set nocount on
while exists(select * from #DrivingData WHERE Processed = 0)
BEGIN
DECLARE @JobID char(36)
set @jobid = null
SELECT @JobID = JobID from #drivingdata where processed = 0 order by JobName desc


Declare @jobName nvarchar(100),
		@IsEnabled int,
		@JobDescription nvarchar(1024),
		@OwnerLoginName nvarchar(1024),
		@DateCreated datetime,
		@DateModified DateTime,
		@VersionNumber int,
		@LastRun datetime
SELECT @JobName = sv.name ,
@IsEnabled = CAST(sv.enabled AS bit) ,
@JobDescription = ISNULL(sv.description,N'') ,
--sv.start_step_id AS [StartStepID],
@OwnerLoginName = ISNULL(suser_sname(sv.owner_sid), N''),
--sv.notify_level_eventlog AS [EventLogLevel],
--sv.notify_level_email AS [EmailLevel],
--sv.notify_level_netsend AS [NetSendLevel],
--sv.notify_level_page AS [PageLevel],
--sv.delete_level AS [DeleteLevel],
@Datecreated = sv.date_created ,
@DateModified = sv.date_modified ,
@VersionNumber = sv.version_number ,
@LastRUn = null
FROM
msdb.dbo.sysjobs_view AS sv
WHERE (sv.Job_ID = @JobID)
print '<table border="1" cellpadding="1" cellspacing="1" width="600">'
print '<tr><td>Job Name:</td><td><b>' + @JobName
print '</b></td></tr><tr><td>Job ID:</td><td> ' + convert(char(36), @jobid)
print '</td></tr><tr><td>Description: </td><td>' + @JobDescription
print '</td></tr><tr><td>Owner: </td><td>' + @OwnerLoginName
print '</td></tr><tr><td>Created: </td><td>' + convert(nvarchar(200), @datecreated, 110)
print '</td></tr><tr><td>Modified: </td><td>' + convert(nvarchar(200), @datemodified, 110)
print '</td></tr><tr><td>Version: </td><td>' + convert(nvarchar(20), @versionnumber)
print '</td></tr><tr><td>Current State: </td><td>'
if @IsEnabled = 1 
print 'Job is currently enabled'
else
print 'Job is currently disabled'
print '</td></tr><tr><td colspan="2" align="center">Schedule information '

/*create table #tmp_sp_help_jobschedule
(schedule_id int null, schedule_name nvarchar(128) null, enabled int null, freq_type int null, freq_interval int null, freq_subday_type int null, freq_subday_interval int null, freq_relative_interval int null, 
freq_recurrence_factor int null, active_start_date int null, active_end_date int null, active_start_time int null, active_end_time int null, date_created datetime null, schedule_description nvarchar(4000) null, 
next_run_date int null, next_run_time int null, schedule_uid uniqueidentifier null,  job_count int null, job_id uniqueidentifier null)
select @jobid, * from #tmp_sp_help_jobschedule
	insert into #tmp_sp_help_jobschedule (schedule_id, schedule_name, enabled, freq_type, freq_interval, freq_subday_type, freq_subday_interval, freq_relative_interval, freq_recurrence_factor, active_start_date, 
active_end_date, active_start_time, active_end_time, date_created, schedule_description, next_run_date, next_run_time, schedule_uid, job_count) 
		exec msdb.dbo.sp_help_jobschedule @job_id = @job_id
	--update #tmp_sp_help_jobschedule set job_id = @job_id where job_id is null
select @jobid, * from #tmp_sp_help_jobschedule*/
	declare @scheduleid int
set @scheduleid = null
	select @scheduleid =  schedule_id from msdb.dbo.sysjobschedules WHERE Job_ID = @JobID

IF @ScheduleID IS NULL
print '</td></tr><tr><td colspan="2" align="center"><i>NO SCHEDULE INFORMATION EXISTS</i>'
ELSE
begin
	DECLARE @JOB_NAME SYSNAME,
	 @JobStatus nvarchar(64),
	 @scheduleFrequency VARCHAR(1000),
	 @schedule_start_date datetime,
	 @schedule_end_date datetime
	SELECT @JobName = Job_NAme, @JobStatus = CASE STATUS
		WHEN 1 THEN 'ENABLED'
		WHEN 0 THEN 'DISABLED'
		ELSE ' '
		END, @scheduleFrequency = Schedule, @schedule_start_date= convert(datetime, convert(varchar,active_start_date, 101)),
		 @schedule_end_date = convert(datetime, convert(varchar,active_end_date, 101)) 
	FROM #schedules WHERE SCHED_ID = @scheduleid
	PRINT '</td></tr><tr><td>Schedule Name: </td><td>' + @Job_Name
	PRINT '</td></tr><tr><td>Job is currently: </td><td>'  + @JobStatus
	print '</td></tr><tr><td>Schedule is: </td><td>' + @scheduleFrequency
    print '</td></tr><tr><td>Schedule runs from </td><td>' + convert(nvarchar(max), @schedule_start_date, 110) + ' to ' + 	convert(nvarchar(max), @schedule_end_date, 110)	
END
--drop table #tmp_sp_help_jobschedule



create table #tmp_sp_help_jobstep
(step_id int null, step_name nvarchar(128) null, subsystem nvarchar(128) null, command nvarchar(max) null, flags int null, cmdexec_success_code int null, on_success_action tinyint null, on_success_step_id int null, 
on_fail_action tinyint null, on_fail_step_id int null, server nvarchar(128) null, database_name sysname null, database_user_name sysname null, retry_attempts int null, retry_interval int null, os_run_priority int null, 
output_file_name nvarchar(300) null, last_run_outcome int null, last_run_duration int null, last_run_retries int null, last_run_date int null, last_run_time int null, proxy_id int null, job_id uniqueidentifier null)

insert into #tmp_sp_help_jobstep(step_id, step_name, subsystem, command, flags, cmdexec_success_code, on_success_action, on_success_step_id, on_fail_action, on_fail_step_id, server, database_name, 
database_user_name, retry_attempts, retry_interval, os_run_priority, output_file_name, last_run_outcome, last_run_duration, last_run_retries, last_run_date, last_run_time, proxy_id) 
		exec msdb.dbo.sp_help_jobstep @job_id = @jobid
	update #tmp_sp_help_jobstep set job_id = @jobid where job_id is null

declare @stepid int,
		@stepname nvarchar(1023),
		@subsystem nvarchar(100),
		@command nvarchar(max),
		@OnSuccessStepID int,
		@OnFailStepID int,
		@DatabaseName nvarchar(1023)
set @stepid = -9999

print '</td></tr><tr><td colspan="2" align="center">Job Steps:'
while exists(SELECT * FROM #tmp_sp_help_jobstep WHERE step_id > @stepid)
begin
	select @stepid = min(step_id) from #tmp_sp_help_jobstep where step_id > @stepid 
	select @stepname = step_name, @subsystem = subsystem, @command = command, @OnSuccessStepID = on_success_step_id,
		@onFailStepID = on_Fail_step_ID, @databasename = Database_Name FROM #tmp_sp_help_jobstep WHERE Step_ID = @StepID
	print '</td></tr><tr><td>Step ID: </td><td>' + convert(nvarchar(10), @StepID)
    print '</td></tr><tr><td>Step Name: </td><td>' + @StepName
	print '</td></tr><tr><td>On Success:</td><td>' + convert(nvarchar(10), @OnSuccessStepID)
	print '</td></tr><tr><td>On Failure:</td><td>' + convert(nvarchar(10), @OnFailStepID)
	print '</td></tr><tr><td>Subsystem: </td><td>' + @SubSystem
	print '</td></tr><tr><td>Database: </td><td>' + @databasename
	print '</td></tr><tr><td valign="top">Command: </td><td><pre>' 
	print @command
end
drop table #tmp_sp_help_jobstep



print '</pre></td></tr></table><br /><br />'

update #DrivingData set Processed = 1 where JobID = @Jobid
END
drop table #drivingdata

--SELECT job_name , [status] = CASE STATUS WHEN 1 THEN 'ENABLED' WHEN 0 THEN 'DISABLED' ELSE ' 'END,
--	scheduled= case scheduled when 1 then 'Yes' when 0 then 'No' else ' ' end,
--	schedule as 'Frequency' , convert(datetime, convert(varchar,active_start_date, 101)) AS schedule_start_date,
--	convert(datetime, convert(varchar,active_end_date, 101)) AS schedule_end_date,
--	date_created
--FROM #schedules WHERE scheduled=1 ORDER BY job_name
DROP TABLE #schedules

	

/*	


create table #tmp_sp_help_alert
(id int null, name nvarchar(128) null, event_source nvarchar(100) null, event_category_id int null, event_id int null, message_id int null, severity int null, enabled tinyint null, delay_between_responses int null, 
last_occurrence_date int null, last_occurrence_time int null, last_response_date int null, last_response_time int null, notification_message nvarchar(512) null, include_event_description tinyint null, database_name 
nvarchar(128) null, event_description_keyword nvarchar(100) null, occurrence_count int null, count_reset_date int null, count_reset_time int null, job_id uniqueidentifier null, job_name nvarchar(128) null, has_notification 
int null, flags int null, performance_condition nvarchar(512) null, category_name nvarchar(128) null, wmi_namespace nvarchar(max) null, wmi_query nvarchar(max) null, type int null)
insert into #tmp_sp_help_alert exec msdb.dbo.sp_help_alert
			


SELECT
tsha.id AS [ID],
tsha.name AS [Name],
ISNULL(tsha.event_source,N'') AS [EventSource],
tsha.message_id AS [MessageID],
tsha.severity AS [Severity],
CAST(tsha.enabled AS bit) AS [IsEnabled],
tsha.delay_between_responses AS [DelayBetweenResponses],
null AS [LastOccurrenceDate],
null AS [LastResponseDate],
ISNULL(tsha.notification_message,N'') AS [NotificationMessage],
tsha.include_event_description AS [IncludeEventDescription],
ISNULL(tsha.database_name,N'') AS [DatabaseName],
ISNULL(tsha.event_description_keyword,N'') AS [EventDescriptionKeyword],
tsha.occurrence_count AS [OccurrenceCount],
null AS [CountResetDate],
ISNULL(tsha.job_id, convert(uniqueidentifier, N'00000000-0000-0000-0000-000000000000')) AS [JobID],
ISNULL(tsha.job_name,N'') AS [JobName],
tsha.has_notification AS [HasNotification],
ISNULL(tsha.performance_condition,N'') AS [PerformanceCondition],
ISNULL(tsha.category_name,N'') AS [CategoryName],
ISNULL(tsha.wmi_namespace,N'') AS [WmiEventNamespace],
ISNULL(tsha.wmi_query,N'') AS [WmiEventQuery],
tsha.type AS [AlertType],
tsha.count_reset_date AS [CountResetDateInt],
tsha.count_reset_time AS [CountResetTimeInt],
tsha.last_occurrence_date AS [LastOccurrenceDateInt],
tsha.last_occurrence_time AS [LastOccurrenceTimeInt],
tsha.last_response_date AS [LastResponseDateInt],
tsha.last_response_time AS [LastResponseTimeInt]
FROM
#tmp_sp_help_alert AS tsha
WHERE
(tsha.name=N'IO Errors')

drop table #tmp_sp_help_alert
		

create table #tmp_sp_help_operator
(id int null, name nvarchar(128) null, enabled tinyint null, email_address nvarchar(100) null, last_email_date int null, last_email_time int null, pager_address nvarchar(100) null, last_pager_date int null, last_pager_time 
int null, weekday_pager_start_time int null, weekday_pager_end_time int null, saturday_pager_start_time int null, saturday_pager_end_time int null, sunday_pager_start_time int null, sunday_pager_end_time int null, 
pager_days tinyint null, netsend_address nvarchar(100) null, last_netsend_date int null, last_netsend_time int null, category_name nvarchar(128) null)
insert into #tmp_sp_help_operator exec msdb.dbo.sp_help_operator
		


SELECT
ISNULL(tsho_e.name,N'') AS [OperatorToEmail]
FROM
msdb.dbo.sysjobs_view AS sv
LEFT OUTER JOIN #tmp_sp_help_operator AS tsho_e ON tsho_e.id = sv.notify_email_operator_id
WHERE
(sv.name=N'CleanUp Stats Archive')

drop table #tmp_sp_help_operator
		
*/