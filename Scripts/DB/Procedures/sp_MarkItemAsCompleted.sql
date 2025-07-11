ALTER PROCEDURE sp_MarkItemAsCompleted
    @UserId BIGINT ,
    @ItemId BIGINT
    AS 
    BEGIN
    SET NOCOUNT ON;

    DECLARE @SP_Name VARCHAR(128) = 'sp_MarkItemAsCompleted';
    DECLARE @Success BIT = 1;
    DECLARE @ActionTaken NVARCHAR(500) = NULL;
    DECLARE @AffectedId INT = NULL;    
    
    BEGIN TRY
        BEGIN TRANSACTION;
		 SET NOCOUNT ON;
        UPDATE dbo.Items  
        SET IsCompleted = 1, 
            CompletedDate = GETDATE(),
            UpdatedBy = @UserId,
            UpdatedDate = GETDATE()
        WHERE ItemId = @ItemId
        AND AssignedToUserId = @UserId;
         -- Check if the update was successful
        IF @@ROWCOUNT = 0
        BEGIN
            SET @Success = 0;
            SET @ActionTaken = 'Item not found or you do not have permission to update it.';
        END
        ELSE
        BEGIN
        SET @AffectedId = @ItemId;
        SET @ActionTaken = 'Item updated successfully.';
        END
    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @Success = 0;
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

		SET @ActionTaken = ERROR_MESSAGE();        

    END CATCH;     

    SELECT
        CASE
            WHEN @AffectedId IS NOT NULL
                     AND @AffectedId > 0
                THEN @AffectedId
            ELSE @Success
            END as SuccessIndicator,
        @ActionTaken as Message;
END
GO