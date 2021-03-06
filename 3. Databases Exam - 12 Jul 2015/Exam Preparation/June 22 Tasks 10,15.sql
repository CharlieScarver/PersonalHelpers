
-- Task 10	V

SELECT DISTINCT t.MatchDate [First Date], tm.MatchDate [Second Date]
FROM TeamMatches t, TeamMatches tm
WHERE 
	(CAST(t.MatchDate AS date) = CAST(tm.MatchDate AS date))
	AND
	(CAST(t.MatchDate AS time) < CAST(tm.MatchDate AS time))
ORDER BY [First Date] DESC, [Second Date] DESC


-- Task 15	V

IF OBJECT_ID('fn_TeamsJSON') IS NOT NULL
  DROP FUNCTION fn_TeamsJSON
GO

CREATE  FUNCTION [dbo].[fn_TeamsJSON]()
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE cu CURSOR FOR
		SELECT 
			t.TeamName [Team 1], 
			t2.TeamName [Team 2], 
			CONVERT(varchar(10), tm.MatchDate, 103) [Date], 
			tm.HomeGoals, 
			tm.AwayGoals, 
			(CASE t.Id WHEN tm.HomeTeamId THEN 1 ELSE 0 END) [IsTeam1Home]
		FROM Teams t
		LEFT JOIN TeamMatches tm
			ON tm.HomeTeamId = t.Id OR tm.AwayTeamId = t.Id
		LEFT JOIN Teams t2
			ON t2.Id = tm.AwayTeamId OR t2.Id = tm.HomeTeamId
		WHERE 
			t.CountryCode = 'BG' 
			AND 
			(t.Id <> t2.Id OR t2.Id IS NULL)
		ORDER BY t.TeamName ASC, tm.MatchDate DESC

	DECLARE 
		@output nvarchar(max) = '{"teams":[',
		@t1Name nvarchar(50), 
		@t2Name nvarchar(50),
		@date varchar(10),
		@homeScore int,
		@awayScore int,
		@isTeam1Home int,
		@lastTeam nvarchar(50) = '1',
		@temp nvarchar(50)

	OPEN cu

	FETCH NEXT FROM cu 
	INTO @t1Name, @t2Name, @date, @homeScore, @awayScore, @isTeam1Home

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--PRINT @output
		SET @temp = @t1Name

		IF @t2Name IS NOT NULL
		BEGIN
			
			IF @isTeam1Home = 0
			BEGIN
				SET @t1Name = @t2Name
				SET @t2Name = @temp
			END

			IF @temp = @lastTeam
			BEGIN
				SET @output = @output + ',{"' + @t1Name + '":' + CAST(@homeScore as varchar(2)) + ',"' + @t2Name + '":' + CAST(@awayScore as varchar(2)) + ',"date":' + @date + '}'
			END
			ELSE
			BEGIN
				IF @lastTeam = '1'
					SET @output = @output + '{"name":"' + @temp + '","matches":[{"' + @t1Name + '":' + CAST(@homeScore as varchar(2)) + ',"' + @t2Name + '":' + CAST(@awayScore as varchar(2)) + ',"date":' + @date + '}'
				ELSE
					SET @output = @output + ']},{"name":"' + @temp + '","matches":[{"' + @t1Name + '":' + CAST(@homeScore as varchar(2)) + ',"' + @t2Name + '":' + CAST(@awayScore as varchar(2)) + ',"date":' + @date + '}'
			END

		END
		ELSE
		BEGIN
			SET @output = @output + ']},{"name":"' + @temp + '","matches":['
		END
		
		SET @lastTeam = @temp
		
		FETCH NEXT FROM cu 
		INTO @t1Name, @t2Name, @date, @homeScore, @awayScore, @isTeam1Home
	END

	CLOSE cu
	DEALLOCATE cu

	SET @output = @output + ']}]}'
	--PRINT @output

	RETURN @output
END
GO



SELECT dbo.fn_TeamsJSON()



















