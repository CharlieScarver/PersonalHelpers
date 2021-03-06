-- Problem 1.	Create a database with two tables
-- Persons (id (PK), first name, last name, SSN) and 
-- Accounts (id (PK), person id (FK), balance). Insert few records for testing. 
-- Write a stored procedure that selects the full names of all persons.

--- Persons (id (PK), first name, last name, SSN)

CREATE TABLE Persons
(
	ID			int PRIMARY KEY IDENTITY NOT NULL,
	FirstName	nvarchar(50) NOT NULL,
	LastName	nvarchar(50) NOT NULL,
	SSN			nchar(11) NULL	
)
GO

--- Accounts (id (PK), person id (FK), balance)

CREATE TABLE Accounts
(
	ID			int PRIMARY KEY IDENTITY NOT NULL,
	PersonID	int FOREIGN KEY REFERENCES Persons(ID) ON DELETE CASCADE NOT NULL,
	Balance		money NOT NULL
)
GO

--- Inserts

INSERT INTO Persons
VALUES
	('Guy',	'Gilbert', '422-98-4235'),
	('Kevin', 'Brown', '943-84-2465'),
	('Roberto', 'Tamburello', '423-65-9842'),
	('Rob', 'Walters', '894-93-7416'),
	('Thierry',	'D''Hers', '249-78-9318'),
	('David', 'Bradley', '984-32-1655'),
	('JoLynn', 'Dobney', '789-22-4797')
GO

INSERT INTO Accounts
VALUES
	(5, 9460.50),
	(2, 350.00),
	(7, 15765.50),
	(4, 5350.00),
	(6, 44050.00)
GO

--- Stored Procedure

CREATE PROC usp_SelectPersonsFullNames
AS
	SELECT (p.FirstName + ' ' + p.LastName) [FullName]
	FROM Persons p
GO

EXEC usp_SelectPersonsFullNames



-- Problem 2.	Create a stored procedure
-- Your task is to create a stored procedure that accepts a number as a 
-- parameter and returns all persons who have more money in their accounts 
-- than the supplied number.


CREATE PROC usp_ShowAccountsWithMoreThan(@balance money = 0.00)
AS
	SELECT p.FirstName + ' ' + p.LastName [Person], a.Balance
	FROM Persons p
	JOIN Accounts a
		ON a.PersonID = p.ID
	WHERE a.Balance > @balance

GO

EXEC usp_ShowAccountsWithMoreThan 6000.00

EXEC usp_ShowAccountsWithMoreThan



-- Problem 3.	Create a function with parameters
-- Your task is to create a function that accepts as parameters – 
-- sum, yearly interest rate and number of months. It should calculate 
-- and return the new sum. Write a SELECT to test whether the function 
-- works as expected.

--- sum, yearly interest rate and number of months

CREATE FUNCTION ufn_CalculateSum(@sum money, @yearlyInterest float, @months int) 
RETURNS money
AS
BEGIN

	RETURN @sum + (@sum * (@yearlyInterest / 100 / 12) * @months)

END

--- Test Function

SELECT 
	5000 [OldSum], 
	[dbo].[ufn_CalculateSum] (5000, 5, 24) [NewSum]
GO

-- Problem 4.	Create a stored procedure that uses the function 
-- from the previous example.
-- Your task is to create a stored procedure that uses the function 
-- from the previous example to give an interest to a person's account 
-- for one month. It should take the AccountId and the interest rate 
-- as parameters.

CREATE PROC usp_GiveInterest(@accID int, @monthlyInterest float)
AS
BEGIN
	UPDATE Accounts
	SET Balance = [dbo].[ufn_CalculateSum](Balance, @monthlyInterest * 12, 1)
	WHERE ID = @accID
END

EXEC usp_GiveInterest 
	@accID= 2, 
	@monthlyInterest = 2.5


-- Problem 5.	Add two more stored procedures WithdrawMoney and DepositMoney.
-- Add two more stored procedures WithdrawMoney (AccountId, money) and 
-- DepositMoney (AccountId, money) that operate in transactions.

--- WithdrawMoney (AccountId, money) 

CREATE PROC usp_WithdrawMoney(@accID int, @money money)
AS
BEGIN
	BEGIN TRANSACTION
	
	BEGIN TRY
		UPDATE Accounts
		SET Balance = Balance - @money
		WHERE ID = @accID
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

END

EXEC usp_WithdrawMoney
	@accID = 5, 
	@money = 3000

--- DepositMoney (AccountId, money)

CREATE PROC usp_DepositMoney(@accID int, @money money)
AS
BEGIN
	BEGIN TRANSACTION
	
	BEGIN TRY
		UPDATE Accounts
		SET Balance = Balance + @money
		WHERE ID = @accID
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

END

EXEC usp_DepositMoney
	@accID = 2, 
	@money = 1000



-- Problem 6.	Create table Logs.
-- Create another table – Logs (LogID, AccountID, OldSum, NewSum). 
-- Add a trigger to the Accounts table that enters a new entry into 
-- the Logs table every time the sum on an account changes.

--- Logs (LogID, AccountID, OldSum, NewSum). 

CREATE TABLE Logs
(
	ID			int PRIMARY KEY IDENTITY NOT NULL,
	AccountID	int FOREIGN KEY REFERENCES Accounts(ID) NOT NULL,
	OldSum		money NOT NULL,
	NewSum		money NOT NULL
)
GO

--- Create Trigger

CREATE TRIGGER tr_AccountsForUpdate ON Accounts FOR UPDATE
AS
	DECLARE @AccountID int, @NewSum money, @OldSum money

	SET @AccountID = (SELECT ID FROM inserted)
	SET @NewSum = (SELECT Balance FROM inserted)
	SET @OldSum = (SELECT Balance FROM deleted)

	INSERT INTO Logs(AccountID, OldSum, NewSum)
	VALUES (@AccountID, @OldSum, @NewSum)

GO

--- Test Trigger

UPDATE Accounts
SET Balance = Balance * 0.85
WHERE ID = 4


SELECT * 
FROM Logs

