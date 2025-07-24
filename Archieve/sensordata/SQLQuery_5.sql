SELECT TOP (1000) [PartitionKey]
      ,[RowKey]
      ,[Timestamp]
      ,[Value]
  FROM [dbo].[VictronConsumption]
  where RowKey < 1705108834251