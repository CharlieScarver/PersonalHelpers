USE Diablo;
GO

-- Task 1	V

SELECT [Name]
FROM [Diablo].[dbo].[Characters]
ORDER BY Name

-- Task 2	V

SELECT TOP 50 
	[Name] [Username]	
    ,CAST([Start] AS date) [Start]
FROM [Diablo].[dbo].[Games]
WHERE YEAR([Start]) IN ('2011', '2012')
ORDER BY Start ASC, Name ASC

-- Task 3	V

SELECT 
	u.Username, 
	SUBSTRING(u.Email, CHARINDEX('@', u.Email, 2) + 1, 100) [Email Provider]
FROM Users u
ORDER BY [Email Provider] ASC, Username ASC

-- Task 4	V

SELECT u.Username, u.IpAddress [IP Address]
FROM Users u
WHERE u.IpAddress LIKE '___.1_%._%.___'
ORDER BY u.Username

-- Task	5	?

--Duration should be Extra Short (smaller or equal to 3), Short (between 4 and 6 including), Long (greater than 6) and Extra Long (without duration).

SELECT 
	g.Name, 
	(CASE
		WHEN g.Start IS NULL THEN NULL
		WHEN CAST(g.Start as time) >= CAST('00:00:00' as time) AND CAST(g.Start as time) < CAST('12:00:00' as time) THEN 'Morning' 
		WHEN CAST(g.Start as time) >= CAST('12:00:00' as time) AND CAST(g.Start as time) < CAST('18:00:00' as time) THEN 'Afternoon'
		WHEN CAST(g.Start as time) >= CAST('18:00:00' as time) AND CAST(g.Start as time) <= CAST('23:59:59' as time) THEN 'Evening'
		ELSE NULL
	END) [Part of the Day], 
	(CASE 
		WHEN g.Duration IS NULL THEN 'Extra Long'
		WHEN g.Duration <= 3 THEN 'Extra Short'
		WHEN g.Duration >= 4 AND g.Duration <= 6 THEN 'Short'
		WHEN g.Duration > 6 THEN 'Long'
	END)
FROM Games g

-- Task 6	V

SELECT 
	SUBSTRING(u.Email, CHARINDEX('@', u.Email, 2) + 1, 100) [Email Provider],
	COUNT(u.Username) [Number Of Users]
FROM Users u
GROUP BY SUBSTRING(u.Email, CHARINDEX('@', u.Email, 2) + 1, 100)
ORDER BY [Number Of Users] DESC, [Email Provider] ASC

-- Task 7	V

SELECT g.Name [Game], gt.Name [Game Type], u.Username, ug.Level, ug.Cash, c.Name [Character]
FROM Games g
INNER JOIN GameTypes gt
	ON gt.Id = g.GameTypeId
INNER JOIN UsersGames ug
	ON ug.GameId = g.Id
INNER JOIN Users u
	ON u.Id = ug.UserId
INNER JOIN Characters c
	ON c.Id = ug.CharacterId
ORDER BY ug.Level DESC, u.Username ASC, g.Name ASC

-- Task 8	V

SELECT u.Username, g.Name [Game], COUNT(i.Name) [Items Count], SUM(i.Price) [Items Price]
FROM Games g
INNER JOIN UsersGames ug
	ON ug.GameId = g.Id
INNER JOIN Users u
	ON u.Id = ug.UserId
INNER JOIN UserGameItems ui
	ON ui.UserGameId = ug.Id
INNER JOIN Items i
	ON i.Id = ui.ItemId
GROUP BY u.Username, g.Name
HAVING COUNT(i.Name) >= 10
ORDER BY [Items Count] DESC, [Items Price] DESC, u.Username ASC

-- Task 10	V

SELECT i.Name, i.Price, i.MinLevel, s.Strength, s.Defence, s.Speed, s.Luck, s.Mind
FROM Items i
LEFT JOIN dbo.[Statistics] s
	ON s.Id = i.StatisticId
WHERE 
	s.Mind > (SELECT AVG(Mind) FROM dbo.[Statistics])
	AND
	s.Luck > (SELECT AVG(Luck) FROM dbo.[Statistics])
	AND
	s.Speed > (SELECT AVG(Speed) FROM dbo.[Statistics])
ORDER BY i.Name ASC

-- Task 11	V

SELECT i.Name [Item], i.Price, i.MinLevel, t.Name [Forbidden Game Type]
FROM Items i
LEFT JOIN GameTypeForbiddenItems f
	ON f.ItemId = i.Id
LEFT JOIN GameTypes t
	ON t.Id = f.GameTypeId
ORDER BY t.Name DESC, i.name ASC


-- Task 12	V

-- 1

SELECT u.Username, ug.Id [GameId], ug.UserId
FROM Users u
LEFT JOIN UsersGames ug
	ON ug.UserId = u.id
LEFT JOIN Games g
	ON g.Id = ug.GameId
WHERE g.Name = 'Edinburgh' AND u.Username = 'Alex'

INSERT INTO UserGameItems
SELECT i.Id, 235 [Alex's GameId]
FROM Items i
WHERE 
	i.Name IN (
		'Blackguard', 
		'Bottomless Potion of Amplification', 
		'Eye of Etlich (Diablo III)', 
		'Gem of Efficacious Toxin', 
		'Golden Gorget of Leoric',
		'Hellfire Amulet'
	)

SELECT i.Id, i.Price, 235 [Alex's GameId]
FROM Items i
WHERE 
	i.Name IN (
		'Blackguard', 
		'Bottomless Potion of Amplification', 
		'Eye of Etlich (Diablo III)', 
		'Gem of Efficacious Toxin', 
		'Golden Gorget of Leoric',
		'Hellfire Amulet'
	)

UPDATE UsersGames
SET Cash = Cash - (
	SELECT SUM(i.Price)
	FROM Items i
	WHERE 
		i.Name IN (
			'Blackguard', 
			'Bottomless Potion of Amplification', 
			'Eye of Etlich (Diablo III)', 
			'Gem of Efficacious Toxin', 
			'Golden Gorget of Leoric',
			'Hellfire Amulet'
		)
	)
WHERE UserId = (
	SELECT ug.UserId
	FROM Users u
	LEFT JOIN UsersGames ug
		ON ug.UserId = u.id
	LEFT JOIN Games g
		ON g.Id = ug.GameId
	WHERE g.Name = 'Edinburgh' AND u.Username = 'Alex'
)

-- 2
SELECT u.Username, g.Name, ug.Cash, i.Name [Item Name]
FROM Users u
LEFT JOIN UsersGames ug
	ON ug.UserId = u.id
LEFT JOIN Games g
	ON g.Id = ug.GameId
LEFT JOIN UserGameItems ui
	ON ui.UserGameId = ug.Id
LEFT JOIN Items i
	ON i.Id = ui.ItemId
WHERE g.Name = 'Edinburgh'
ORDER BY i.name ASC

-- Task 13	V

-- 1
-- Get users in Safflower and their [GameId]s
SELECT u.Username, ug.Id [GameId]
FROM Users u
LEFT JOIN UsersGames ug
	ON ug.UserId = u.id
LEFT JOIN Games g
	ON g.Id = ug.GameId
WHERE g.Name = 'Safflower'

-- Get [Id]s of items with the wanted levels
SELECT i.Id
FROM Items i
WHERE i.MinLevel BETWEEN 11 AND 12
ORDER BY i.MinLevel ASC

-- Get Price for all the wanted items
SELECT SUM(i.Price) [Sum]
FROM Items i
WHERE i.MinLevel BETWEEN 11 AND 12

-- 3
-- First Transaction (11,12)
BEGIN TRANSACTION
	
BEGIN TRY

	INSERT INTO UserGameItems
	SELECT i.Id, 110
	FROM Items i
	WHERE i.MinLevel BETWEEN 11 AND 12
	ORDER BY i.MinLevel ASC

	UPDATE UsersGames
	SET Cash = Cash - (
		SELECT SUM(i.Price) [Sum]
		FROM Items i
		WHERE i.MinLevel BETWEEN 11 AND 12
	)
	WHERE Id = 110

END TRY
BEGIN CATCH
	SELECT 
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
END CATCH

IF @@TRANCOUNT > 0
	COMMIT TRANSACTION

-- Second Transaction (19,20,21)
BEGIN TRANSACTION
	
BEGIN TRY

	INSERT INTO UserGameItems
	SELECT i.Id, 110
	FROM Items i
	WHERE i.MinLevel BETWEEN 19 AND 21
	ORDER BY i.MinLevel ASC

	UPDATE UsersGames
	SET Cash = Cash - (
		SELECT SUM(i.Price) [Sum]
		FROM Items i
		WHERE i.MinLevel BETWEEN 19 AND 21
	)
	WHERE Id = 110

END TRY
BEGIN CATCH
	SELECT 
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
END CATCH

IF @@TRANCOUNT > 0
	COMMIT TRANSACTION

-- 4
SELECT i.Name [Item Name]
FROM Users u
LEFT JOIN UsersGames ug
	ON ug.UserId = u.id
LEFT JOIN Games g
	ON g.Id = ug.GameId
LEFT JOIN UserGameItems ui
	ON ui.UserGameId = ug.Id
LEFT JOIN Items i
	ON i.Id = ui.ItemId
WHERE g.Name = 'Safflower'
ORDER BY i.Name ASC


-- Task 14	V

IF OBJECT_ID('fn_CashInUsersGames') IS NOT NULL
  DROP FUNCTION fn_CashInUsersGames
GO

CREATE  FUNCTION [dbo].[fn_CashInUsersGames](@gameName nvarchar(max))
RETURNS money
AS
BEGIN

	DECLARE cu CURSOR FOR
		SELECT ug.Cash
		FROM Games g
		LEFT JOIN UsersGames ug
			ON ug.GameId = g.Id
		LEFT JOIN Users u
			ON u.Id = ug.UserId
		WHERE g.Name = @gameName
		ORDER BY ug.Cash DESC

	DECLARE 
		@cash money,
		@sum money = 0

	OPEN cu

	FETCH NEXT FROM cu
	INTO @cash

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @sum = @sum + @cash

		FETCH NEXT FROM cu
		INTO @cash

		IF @@FETCH_STATUS = 0 
			FETCH NEXT FROM cu
			INTO @cash
	END

	RETURN @sum
END
GO


SELECT dbo.fn_CashInUsersGames('Bali') [SumCash]
UNION
SELECT dbo.fn_CashInUsersGames('Lily Stargazer') [SumCash]
UNION
SELECT dbo.fn_CashInUsersGames('Love in a mist') [SumCash]
UNION
SELECT dbo.fn_CashInUsersGames('Mimosa') [SumCash]
UNION
SELECT dbo.fn_CashInUsersGames('Ming fern') [SumCash]
ORDER BY SumCash ASC


-- Task 15	

CREATE TRIGGER [dbo].[tr_CheckUserItemLevelOnPurchase] 
ON [dbo].[UserGameItems]
INSTEAD OF INSERT 
AS
BEGIN

	DECLARE 
		@itemMinLvl int = (
			SELECT it.MinLevel
			FROM inserted i
			LEFT JOIN Items it
				ON it.Id = i.ItemId
		),
		@itemPrice money = (
			SELECT it.Price
			FROM inserted i
			LEFT JOIN Items it
				ON it.Id = i.ItemId
		),
		@userLvl int = (
			SELECT ug.Level
			FROM inserted i
			LEFT JOIN UsersGames ug
				ON ug.Id = i.UserGameId
		),
		@userId int = (
			SELECT ug.UserId
			FROM inserted i
			LEFT JOIN UsersGames ug
				ON ug.Id = i.UserGameId
		)
	
	IF @itemMinLvl > @userLvl
	BEGIN
		RAISERROR('Item level is higher than user level.', 16, 1)
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
		RETURN
	END
	ELSE
	BEGIN
		INSERT INTO UserGameItems
		SELECT i.ItemId, i.UserGameId
		FROM inserted i

		UPDATE UsersGames
		SET Cash = Cash - @itemPrice
		WHERE UserId = @userId
	END	
		
END
GO

UPDATE UsersGames
SET Cash = Cash + 50000
WHERE 
	UserId IN (
		SELECT Id 
		FROM Users 
		WHERE Username IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
	) AND 
	GameId = (
		SELECT Id
		FROM Games
		WHERE Name = 'Bali'
	)


-- 251 and 299 including
-- 501 and 539 including


SELECT i.Id [ItemId], 26 [UserGameId]
FROM Items i
WHERE 
	i.Id BETWEEN 251 AND 299
	OR
	i.Id BETWEEN 501 AND 539


SELECT Id
FROM UsersGames
WHERE 
	UserId IN (
		SELECT Id 
		FROM Users 
		WHERE Username IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
	) AND 
	GameId = (
		SELECT Id
		FROM Games
		WHERE Name = 'Bali'
	)


SELECT u.Username, g.Name, ug.Cash, i.Name [Item Name]
FROM UsersGames ug
LEFT JOIN Users u
	ON u.id = ug.UserId
LEFT JOIN Games g
	ON g.Id = ug.GameId
LEFT JOIN UserGameItems ui
	ON ui.UserGameId = ug.id
LEFT JOIN Items i
	ON i.Id = ui.ItemId
WHERE g.Name = 'Bali'
ORDER BY u.Username ASC, i.Name ASC


