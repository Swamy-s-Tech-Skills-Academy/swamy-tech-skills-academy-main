# 07A_Design-Patterns-Part2A-Builder-Pattern-Fundamentals

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Factory Pattern fundamentals, SOLID Principles understanding  
**Estimated Time**: Part A of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Master the Builder Pattern for constructing complex objects step by step
- Implement fluent interfaces that make object creation readable and safe
- Apply method chaining techniques for intuitive object construction
- Design validation strategies within the builder pattern

## 📋 Content Sections (27-Minute Structure)

### Builder Pattern Overview (5 minutes)

**Builder Pattern Definition**: *"Separate the construction of a complex object from its representation so that the same construction process can create different representations."*

**Core Problem Solved**: Complex objects with many optional parameters lead to telescoping constructors and unclear object creation.

```text
❌ TELESCOPING CONSTRUCTOR PROBLEM
┌─────────────────────────────────────────────────────────────┐
│ EmailMessage(string to, string subject, string body)        │
│ EmailMessage(string to, string subject, string body,        │
│              string cc)                                     │
│ EmailMessage(string to, string subject, string body,        │
│              string cc, string bcc)                         │
│ EmailMessage(string to, string subject, string body,        │
│              string cc, string bcc, Priority priority)      │
│ EmailMessage(string to, string subject, string body,        │
│              string cc, string bcc, Priority priority,      │
│              List<Attachment> attachments)                  │
└─────────────────────────────────────────────────────────────┘

✅ BUILDER PATTERN SOLUTION
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ EmailMessage    │    │ EmailBuilder    │    │ Usage           │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ - to            │←───│ + SetTo()       │    │ var email =     │
│ - subject       │    │ + SetSubject()  │    │   EmailBuilder  │
│ - body          │    │ + SetBody()     │    │     .SetTo(...) │
│ - cc            │    │ + AddCC()       │    │     .SetSubject │
│ - bcc           │    │ + AddBCC()      │    │     .SetBody()  │
│ - attachments   │    │ + AddAttachment │    │     .AddCC()    │
│ - priority      │    │ + SetPriority() │    │     .Build()    │
└─────────────────┘    │ + Build()       │    └─────────────────┘
                       └─────────────────┘
```

**Builder Pattern Benefits**:

- **Readable Construction** - Method chaining creates fluent, self-documenting code
- **Parameter Validation** - Validate during building process, not after construction
- **Immutable Objects** - Build once, then object becomes immutable and thread-safe
- **Flexible Creation** - Same builder can create different object variations
- **Step-by-Step Building** - Complex construction broken into manageable steps

### Database Query Builder Implementation (15 minutes)

#### Complex Query Object Design

```csharp
// Complex query object that needs step-by-step construction
public class DatabaseQuery
{
    public string TableName { get; }
    public List<string> SelectColumns { get; }
    public List<JoinClause> Joins { get; }
    public List<WhereCondition> WhereConditions { get; }
    public List<string> GroupByColumns { get; }
    public List<OrderByClause> OrderBy { get; }
    public int? Limit { get; }
    public int? Offset { get; }
    
    // Private constructor - only builder can create instances
    internal DatabaseQuery(
        string tableName,
        List<string> selectColumns,
        List<JoinClause> joins,
        List<WhereCondition> whereConditions,
        List<string> groupByColumns,
        List<OrderByClause> orderBy,
        int? limit,
        int? offset)
    {
        TableName = tableName ?? throw new ArgumentNullException(nameof(tableName));
        SelectColumns = selectColumns ?? throw new ArgumentNullException(nameof(selectColumns));
        Joins = joins ?? new List<JoinClause>();
        WhereConditions = whereConditions ?? new List<WhereCondition>();
        GroupByColumns = groupByColumns ?? new List<string>();
        OrderBy = orderBy ?? new List<OrderByClause>();
        Limit = limit;
        Offset = offset;
    }
    
    public string ToSql()
    {
        var sql = new StringBuilder();
        
        // SELECT clause
        sql.Append($"SELECT {string.Join(", ", SelectColumns)} FROM {TableName}");
        
        // JOIN clauses
        foreach (var join in Joins)
        {
            sql.Append($" {join.JoinType} JOIN {join.Table} ON {join.Condition}");
        }
        
        // WHERE clause
        if (WhereConditions.Any())
        {
            sql.Append($" WHERE {string.Join(" AND ", WhereConditions.Select(w => w.ToString()))}");
        }
        
        // GROUP BY clause
        if (GroupByColumns.Any())
        {
            sql.Append($" GROUP BY {string.Join(", ", GroupByColumns)}");
        }
        
        // ORDER BY clause
        if (OrderBy.Any())
        {
            sql.Append($" ORDER BY {string.Join(", ", OrderBy.Select(o => $"{o.Column} {o.Direction}"))}");
        }
        
        // LIMIT and OFFSET
        if (Limit.HasValue)
        {
            sql.Append($" LIMIT {Limit}");
        }
        
        if (Offset.HasValue)
        {
            sql.Append($" OFFSET {Offset}");
        }
        
        return sql.ToString();
    }
}

// Supporting data classes
public class JoinClause
{
    public string JoinType { get; set; }
    public string Table { get; set; }
    public string Condition { get; set; }
}

public class WhereCondition
{
    public string Column { get; }
    public string Operator { get; }
    public object Value { get; }
    
    public WhereCondition(string column, string operatorSymbol, object value)
    {
        Column = column ?? throw new ArgumentNullException(nameof(column));
        Operator = operatorSymbol ?? throw new ArgumentNullException(nameof(operatorSymbol));
        Value = value;
    }
    
    public override string ToString()
    {
        if (Value is string stringValue)
        {
            return $"{Column} {Operator} '{stringValue}'";
        }
        return $"{Column} {Operator} {Value}";
    }
}

public class OrderByClause
{
    public string Column { get; set; }
    public string Direction { get; set; }
}

public enum SortDirection
{
    Ascending,
    Descending
}
```

#### Fluent Builder with Method Chaining

```csharp
// Fluent builder with method chaining - each method returns 'this'
public class QueryBuilder
{
    private string _tableName;
    private readonly List<string> _selectColumns = new();
    private readonly List<JoinClause> _joins = new();
    private readonly List<WhereCondition> _whereConditions = new();
    private readonly List<string> _groupByColumns = new();
    private readonly List<OrderByClause> _orderBy = new();
    private int? _limit;
    private int? _offset;
    
    // Core table selection method
    public QueryBuilder From(string tableName)
    {
        _tableName = tableName ?? throw new ArgumentNullException(nameof(tableName));
        return this; // Return 'this' for method chaining
    }
    
    // Column selection methods
    public QueryBuilder Select(params string[] columns)
    {
        if (columns == null || columns.Length == 0)
            throw new ArgumentException("At least one column must be specified", nameof(columns));
            
        _selectColumns.AddRange(columns);
        return this;
    }
    
    public QueryBuilder SelectAll()
    {
        _selectColumns.Clear();
        _selectColumns.Add("*");
        return this;
    }
    
    // JOIN operation methods
    public QueryBuilder InnerJoin(string table, string condition)
    {
        if (string.IsNullOrEmpty(table))
            throw new ArgumentException("Table name cannot be null or empty", nameof(table));
        if (string.IsNullOrEmpty(condition))
            throw new ArgumentException("Join condition cannot be null or empty", nameof(condition));
            
        _joins.Add(new JoinClause { JoinType = "INNER", Table = table, Condition = condition });
        return this;
    }
    
    public QueryBuilder LeftJoin(string table, string condition)
    {
        if (string.IsNullOrEmpty(table))
            throw new ArgumentException("Table name cannot be null or empty", nameof(table));
        if (string.IsNullOrEmpty(condition))
            throw new ArgumentException("Join condition cannot be null or empty", nameof(condition));
            
        _joins.Add(new JoinClause { JoinType = "LEFT", Table = table, Condition = condition });
        return this;
    }
    
    public QueryBuilder RightJoin(string table, string condition)
    {
        if (string.IsNullOrEmpty(table))
            throw new ArgumentException("Table name cannot be null or empty", nameof(table));
        if (string.IsNullOrEmpty(condition))
            throw new ArgumentException("Join condition cannot be null or empty", nameof(condition));
            
        _joins.Add(new JoinClause { JoinType = "RIGHT", Table = table, Condition = condition });
        return this;
    }
    
    // WHERE condition methods
    public QueryBuilder Where(string column, string operatorSymbol, object value)
    {
        if (string.IsNullOrEmpty(column))
            throw new ArgumentException("Column name cannot be null or empty", nameof(column));
        if (string.IsNullOrEmpty(operatorSymbol))
            throw new ArgumentException("Operator cannot be null or empty", nameof(operatorSymbol));
            
        _whereConditions.Add(new WhereCondition(column, operatorSymbol, value));
        return this;
    }
    
    public QueryBuilder WhereEquals(string column, object value)
    {
        return Where(column, "=", value);
    }
    
    public QueryBuilder WhereNotEquals(string column, object value)
    {
        return Where(column, "!=", value);
    }
    
    public QueryBuilder WhereIn(string column, params object[] values)
    {
        if (values == null || values.Length == 0)
            throw new ArgumentException("At least one value must be provided for IN clause", nameof(values));
            
        var inValues = string.Join(", ", values.Select(v => $"'{v}'"));
        _whereConditions.Add(new WhereCondition(column, "IN", $"({inValues})"));
        return this;
    }
    
    public QueryBuilder WhereLike(string column, string pattern)
    {
        return Where(column, "LIKE", pattern);
    }
    
    // GROUP BY and ORDER BY methods
    public QueryBuilder GroupBy(params string[] columns)
    {
        if (columns == null || columns.Length == 0)
            throw new ArgumentException("At least one column must be specified for GROUP BY", nameof(columns));
            
        _groupByColumns.AddRange(columns);
        return this;
    }
    
    public QueryBuilder OrderBy(string column, SortDirection direction = SortDirection.Ascending)
    {
        if (string.IsNullOrEmpty(column))
            throw new ArgumentException("Column name cannot be null or empty", nameof(column));
            
        _orderBy.Add(new OrderByClause { Column = column, Direction = direction.ToString().ToUpper() });
        return this;
    }
    
    public QueryBuilder OrderByDescending(string column)
    {
        return OrderBy(column, SortDirection.Descending);
    }
    
    // Pagination methods
    public QueryBuilder Take(int limit)
    {
        if (limit <= 0)
            throw new ArgumentException("Limit must be positive", nameof(limit));
            
        _limit = limit;
        return this;
    }
    
    public QueryBuilder Skip(int offset)
    {
        if (offset < 0)
            throw new ArgumentException("Offset cannot be negative", nameof(offset));
            
        _offset = offset;
        return this;
    }
    
    // Build method validates and creates the final immutable object
    public DatabaseQuery Build()
    {
        // Comprehensive validation during build process
        if (string.IsNullOrEmpty(_tableName))
            throw new InvalidOperationException("Table name is required. Call From() method.");
            
        if (_selectColumns.Count == 0)
            throw new InvalidOperationException("At least one column must be selected. Call Select() or SelectAll().");
            
        if (_offset.HasValue && !_limit.HasValue)
            throw new InvalidOperationException("Cannot specify offset without limit. Call Take() method first.");
        
        // Create immutable copies of all collections
        return new DatabaseQuery(
            _tableName,
            new List<string>(_selectColumns),
            new List<JoinClause>(_joins),
            new List<WhereCondition>(_whereConditions),
            new List<string>(_groupByColumns),
            new List<OrderByClause>(_orderBy),
            _limit,
            _offset);
    }
    
    // Static factory method for fluent starting point
    public static QueryBuilder Create() => new QueryBuilder();
    
    // Reset method to reuse builder instance
    public QueryBuilder Reset()
    {
        _tableName = null;
        _selectColumns.Clear();
        _joins.Clear();
        _whereConditions.Clear();
        _groupByColumns.Clear();
        _orderBy.Clear();
        _limit = null;
        _offset = null;
        return this;
    }
}
```

### Practical Usage Examples (5 minutes)

```csharp
// Comprehensive builder pattern usage examples
public class QueryBuilderExamples
{
    public void DemonstrateQueryBuilder()
    {
        Console.WriteLine("=== Query Builder Pattern Examples ===\n");

        // Simple query construction
        Console.WriteLine("--- Simple Query ---");
        var simpleQuery = QueryBuilder.Create()
            .From("Users")
            .SelectAll()
            .WhereEquals("IsActive", true)
            .OrderBy("LastName")
            .Build();
            
        Console.WriteLine($"SQL: {simpleQuery.ToSql()}");
        // Output: SELECT * FROM Users WHERE IsActive = 'True' ORDER BY LastName ASC

        // Complex query with joins and grouping
        Console.WriteLine("\n--- Complex Query with Joins ---");
        var complexQuery = QueryBuilder.Create()
            .From("Orders o")
            .Select("o.CustomerId", "COUNT(*) as OrderCount", "SUM(o.Total) as TotalAmount")
            .InnerJoin("Customers c", "o.CustomerId = c.Id")
            .LeftJoin("OrderItems oi", "o.Id = oi.OrderId")
            .Where("o.OrderDate", ">=", "2024-01-01")
            .WhereIn("o.Status", "Completed", "Shipped")
            .GroupBy("o.CustomerId", "c.Name")
            .OrderByDescending("TotalAmount")
            .Take(10)
            .Build();
            
        Console.WriteLine($"SQL: {complexQuery.ToSql()}");

        // Pagination example
        Console.WriteLine("\n--- Pagination Query ---");
        var paginatedQuery = QueryBuilder.Create()
            .From("Products")
            .Select("Id", "Name", "Price", "CategoryId")
            .WhereEquals("IsActive", true)
            .WhereLike("Name", "%laptop%")
            .OrderBy("Price")
            .Skip(20)
            .Take(10)
            .Build();
            
        Console.WriteLine($"SQL: {paginatedQuery.ToSql()}");

        // Demonstrate reusable builder
        Console.WriteLine("\n--- Reusable Builder ---");
        var reusableBuilder = QueryBuilder.Create();
        
        // First query
        var query1 = reusableBuilder
            .From("Employees")
            .Select("FirstName", "LastName", "Department")
            .WhereEquals("IsActive", true)
            .Build();
            
        Console.WriteLine($"Query 1: {query1.ToSql()}");
        
        // Reset and create different query
        var query2 = reusableBuilder
            .Reset()
            .From("Departments")
            .SelectAll()
            .OrderBy("Name")
            .Build();
            
        Console.WriteLine($"Query 2: {query2.ToSql()}");

        // Error handling demonstration
        Console.WriteLine("\n--- Error Handling ---");
        try
        {
            var invalidQuery = QueryBuilder.Create()
                .From("Users")
                // Missing Select() call
                .WhereEquals("IsActive", true)
                .Build(); // This will throw an exception
        }
        catch (InvalidOperationException ex)
        {
            Console.WriteLine($"Validation Error: {ex.Message}");
        }
    }
}
```

### Key Takeaways & Benefits (2 minutes)

**Builder Pattern Advantages**:

- **Fluent Interface** - Readable, self-documenting object construction
- **Immutable Results** - Objects created are thread-safe and cannot be modified
- **Validation Control** - Comprehensive validation during the build process
- **Complex Object Support** - Handles objects with many optional parameters elegantly
- **Method Chaining** - Intuitive, IDE-friendly construction syntax

**When to Use Builder Pattern**:

- Objects with 4+ constructor parameters
- Many optional parameters or configurations
- Need for immutable objects after construction
- Step-by-step construction process required
- Different representations of the same construction process

**Next in Series**:

- **[Part B - Director Pattern and Configuration](07B_Design-Patterns-Part2B-Builder-Pattern-Director.md)**
- **[Part C - Generic Builder System](07C_Design-Patterns-Part2C-Builder-Pattern-Generic.md)**
- **[Part D - Enterprise Builder Applications](07D_Design-Patterns-Part2D-Builder-Pattern-Enterprise.md)**

## 🔗 Related Topics

**Prerequisites**:

- Factory Pattern fundamentals for object creation patterns
- SOLID Principles understanding (especially Open/Closed)
- Method chaining and fluent interface concepts

**Builds Upon**:

- Immutable object design
- Parameter validation strategies
- Static factory methods

**Enables**:

- [Template Method Pattern](13A_Design-Patterns-Part8A-Template-Method-Fundamentals.md) for algorithmic structure
- [Command Pattern](12A_Design-Patterns-Part7A-Command-Pattern-Fundamentals.md) for request encapsulation
- Configuration management systems

**Next Patterns**:

- [Abstract Factory Pattern](06A_Design-Patterns-Part1A-Factory-Pattern-Fundamentals.md) for families of objects
- [Decorator Pattern](11A_Design-Patterns-Part6A-Decorator-Pattern-Fundamentals.md) for feature enhancement
