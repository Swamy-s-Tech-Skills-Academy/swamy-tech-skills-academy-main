# EF Core

## Custom Schema

If you omit the line:

```csharp
modelBuilder.Entity<LeaveType>().ToTable("LeaveTypes");
```

from the `OnModelCreating` method, the behavior will depend on the default schema you've already configured. Here’s what happens:

### 1. **Without `ToTable("LeaveTypes")`**:

If you don't explicitly configure the `LeaveType` entity using `modelBuilder.Entity<LeaveType>().ToTable("LeaveTypes")`, Entity Framework will still create the table using the default schema (`prj1`), because you’ve set that default schema with:

```csharp
modelBuilder.HasDefaultSchema("prj1");
```

This means the table name will be inferred from the entity name (`LeaveTypes`), and it will automatically be created under the `prj1` schema. So, the result will be the same as if you had included the `ToTable` configuration.

**Table created**: `prj1.LeaveTypes`

### 2. **With `ToTable("LeaveTypes")`**:

If you include the `modelBuilder.Entity<LeaveType>().ToTable("LeaveTypes")` line, you're explicitly telling EF Core to use the table name `LeaveTypes`, but since you're not specifying a schema in this line, EF Core will still use the default schema (`prj1`) you set earlier.

**Table created**: `prj1.LeaveTypes`

### Key Difference

In this specific case, since the default schema is already set to `prj1`, **both cases will result in the same outcome**. The `LeaveTypes` table will be created in the `prj1` schema regardless of whether you use `.ToTable("LeaveTypes")` or not.

### When You Need `ToTable("LeaveTypes")`

You would need to use `ToTable("LeaveTypes")` if:

- You wanted to use a different table name than the default (`LeaveType`).
- You wanted to place the `LeaveType` entity in a different schema. For example, if you wanted to place `LeaveTypes` in a schema called `customSchema`, you would write:

  ```csharp
  modelBuilder.Entity<LeaveType>().ToTable("LeaveTypes", "customSchema");
  ```

  In this case, the table would be created as `customSchema.LeaveTypes` instead of `prj1.LeaveTypes`.

### Conclusion:

In your current code, omitting `modelBuilder.Entity<LeaveType>().ToTable("LeaveTypes")` will still create the `LeaveTypes` table in the `prj1` schema, because you've set the default schema. The line is not required unless you want to change the table name or schema for this specific entity.

## How to find how many schemas exists? Example: dbo. prj1 etc

To find the list of all schemas that exist in your SQL Server database, you can query the system catalog views. SQL Server stores schema information in the `sys.schemas` view, which provides details about all schemas in the database.

Here’s a SQL query you can run to list all the schemas in the current database:

```sql
SELECT name AS SchemaName
FROM sys.schemas;
```

### Output:

This will return the names of all the schemas in your database, such as:

- `dbo`
- `prj1`
- `customSchema`
- `etc`

### Example Breakdown:

- `sys.schemas` is a system view that contains a row for each schema in the database.
- The `name` column contains the name of each schema.

If you're using **SQL Server Management Studio (SSMS)** or another SQL client, simply run this query, and it will list all the schemas available in your database.
