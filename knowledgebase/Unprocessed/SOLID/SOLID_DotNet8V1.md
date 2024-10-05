## SOLID principles

Absolutely! Understanding SOLID principles and applying them in a .NET 8 C# 12 Web API project is a great way to enhance your design and coding skills. I'll guide you through each of the SOLID principles with explanations and code examples.

## Step-by-Step Guide to SOLID Principles

Your explanation of the SOLID principles in the context of a .NET 8 C# 12 Web API project is thorough and well-structured. However, there are a few improvements and additional details that can be included to ensure clarity and completeness.

### Expanded and Updated Guide to SOLID Principles

#### 1. Single Responsibility Principle (SRP)

A class should have only one reason to change, meaning it should have only one job or responsibility.

**Example:**  
Let's create a simple Web API for managing books.

**Domain Layer:**

```csharp
public class Book
{
    public int Id { get; set; }
    public string Title { get; set; }
    public string Author { get; set; }
}

public interface IBookRepository
{
    IEnumerable<Book> GetAllBooks();
    Book GetBookById(int id);
    void AddBook(Book book);
    void UpdateBook(Book book);
    void DeleteBook(int id);
}
```

**Infrastructure Layer:**

```csharp
public class BookRepository : IBookRepository
{
    private readonly List<Book> _books = new List<Book>();

    public IEnumerable<Book> GetAllBooks() => _books;

    public Book GetBookById(int id) => _books.FirstOrDefault(b => b.Id == id);

    public void AddBook(Book book) => _books.Add(book);

    public void UpdateBook(Book book)
    {
        var existingBook = GetBookById(book.Id);
        if (existingBook != null)
        {
            existingBook.Title = book.Title;
            existingBook.Author = book.Author;
        }
    }

    public void DeleteBook(int id) => _books.RemoveAll(b => b.Id == id);
}
```

**Application Layer:**

```csharp
public class BookService
{
    private readonly IBookRepository _bookRepository;

    public BookService(IBookRepository bookRepository)
    {
        _bookRepository = bookRepository;
    }

    public IEnumerable<Book> GetBooks() => _bookRepository.GetAllBooks();

    public Book GetBook(int id) => _bookRepository.GetBookById(id);

    public void CreateBook(Book book) => _bookRepository.AddBook(book);

    public void UpdateBook(Book book) => _bookRepository.UpdateBook(book);

    public void DeleteBook(int id) => _bookRepository.DeleteBook(id);
}
```

**Presentation Layer:**

```csharp
[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    private readonly BookService _bookService;

    public BooksController(BookService bookService)
    {
        _bookService = bookService;
    }

    [HttpGet]
    public IActionResult GetBooks() => Ok(_bookService.GetBooks());

    [HttpGet("{id}")]
    public IActionResult GetBook(int id)
    {
        var book = _bookService.GetBook(id);
        if (book == null) return NotFound();
        return Ok(book);
    }

    [HttpPost]
    public IActionResult CreateBook([FromBody] Book book)
    {
        _bookService.CreateBook(book);
        return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book);
    }

    [HttpPut("{id}")]
    public IActionResult UpdateBook(int id, [FromBody] Book book)
    {
        if (id != book.Id) return BadRequest();
        _bookService.UpdateBook(book);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public IActionResult DeleteBook(int id)
    {
        _bookService.DeleteBook(id);
        return NoContent();
    }
}
```

#### 2. Open/Closed Principle (OCP)

Software entities should be open for extension but closed for modification.

**Example:**  
Extend the functionality of the BookService class to include a new method for finding books by author without modifying the existing class.

**Domain Layer:**

```csharp
public interface IBookRepository
{
    IEnumerable<Book> GetAllBooks();
    Book GetBookById(int id);
    void AddBook(Book book);
    void UpdateBook(Book book);
    void DeleteBook(int id);
    IEnumerable<Book> GetBooksByAuthor(string author); // New method
}
```

**Infrastructure Layer:**

```csharp
public class BookRepository : IBookRepository
{
    private readonly List<Book> _books = new List<Book>();

    public IEnumerable<Book> GetAllBooks() => _books;

    public Book GetBookById(int id) => _books.FirstOrDefault(b => b.Id == id);

    public void AddBook(Book book) => _books.Add(book);

    public void UpdateBook(Book book)
    {
        var existingBook = GetBookById(book.Id);
        if (existingBook != null)
        {
            existingBook.Title = book.Title;
            existingBook.Author = book.Author;
        }
    }

    public void DeleteBook(int id) => _books.RemoveAll(b => b.Id == id);

    public IEnumerable<Book> GetBooksByAuthor(string author) // New method implementation
    {
        return _books.Where(b => b.Author.Equals(author, StringComparison.OrdinalIgnoreCase));
    }
}
```

**Application Layer:**

```csharp
public class BookService
{
    private readonly IBookRepository _bookRepository;

    public BookService(IBookRepository bookRepository)
    {
        _bookRepository = bookRepository;
    }

    public IEnumerable<Book> GetBooks() => _bookRepository.GetAllBooks();

    public Book GetBook(int id) => _bookRepository.GetBookById(id);

    public void CreateBook(Book book) => _bookRepository.AddBook(book);

    public void UpdateBook(Book book) => _bookRepository.UpdateBook(book);

    public void DeleteBook(int id) => _bookRepository.DeleteBook(id);

    public IEnumerable<Book> GetBooksByAuthor(string author) => _bookRepository.GetBooksByAuthor(author); // New method
}
```

**Presentation Layer:**

```csharp
[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    private readonly BookService _bookService;

    public BooksController(BookService bookService)
    {
        _bookService = bookService;
    }

    [HttpGet]
    public IActionResult GetBooks() => Ok(_bookService.GetBooks());

    [HttpGet("{id}")]
    public IActionResult GetBook(int id)
    {
        var book = _bookService.GetBook(id);
        if (book == null) return NotFound();
        return Ok(book);
    }

    [HttpPost]
    public IActionResult CreateBook([FromBody] Book book)
    {
        _bookService.CreateBook(book);
        return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book);
    }

    [HttpPut("{id}")]
    public IActionResult UpdateBook(int id, [FromBody] Book book)
    {
        if (id != book.Id) return BadRequest();
        _bookService.UpdateBook(book);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public IActionResult DeleteBook(int id)
    {
        _bookService.DeleteBook(id);
        return NoContent();
    }

    [HttpGet("author/{author}")]
    public IActionResult GetBooksByAuthor(string author)
    {
        var books = _bookService.GetBooksByAuthor(author);
        return Ok(books);
    }
}
```

#### 3. Liskov Substitution Principle (LSP)

Objects of a superclass should be replaceable with objects of a subclass without affecting the correctness of the program.

**Example:**  
Assume we have a base class `Document` and a derived class `Book`. Both should be substitutable without breaking the application.

**Domain Layer:**

```csharp
public class Document
{
    public string Title { get; set; }
    public string Author { get; set; }

    public virtual string GetDescription()
    {
        return $"{Title} by {Author}";
    }
}

public class Book : Document
{
    public int PageCount { get; set; }

    public override string GetDescription()
    {
        return $"{Title} by {Author}, {PageCount} pages";
    }
}
```

**Presentation Layer:**

```csharp
[ApiController]
[Route("api/[controller]")]
public class DocumentsController : ControllerBase
{
    [HttpGet]
    public IActionResult GetDocumentDescriptions()
    {
        var documents = new List<Document>
        {
            new Document { Title = "Generic Document", Author = "Author A" },
            new Book { Title = "Specific Book", Author = "Author B", PageCount = 123 }
        };

        var descriptions = documents.Select(d => d.GetDescription()).ToList();
        return Ok(descriptions);
    }
}
```

#### 4. Interface Segregation Principle (ISP)

No client should be forced to depend on methods it does not use. Split large interfaces into smaller, more specific ones.

**Example:**  
We'll create separate interfaces for reading and writing books.

**Domain Layer:**

```csharp
public interface IBookReader
{
    IEnumerable<Book> GetAllBooks();
    Book GetBookById(int id);
}

public interface IBookWriter
{
    void AddBook(Book book);
    void UpdateBook(Book book);
    void DeleteBook(int id);
}
```

**Infrastructure Layer:**

```csharp
public class BookRepository : IBookReader, IBookWriter
{
    private readonly List<Book> _books = new List<Book>();

    // IBookReader implementation
    public IEnumerable<Book> GetAllBooks() => _books;
    public Book GetBookById(int id) => _books.FirstOrDefault(b => b.Id == id);

    // IBookWriter implementation
    public void AddBook(Book book) => _books.Add(book);
    public void UpdateBook(Book book)
    {
        var existingBook = GetBookById(book.Id);
        if (existingBook != null)
        {
            existingBook.Title = book.Title;
            existingBook.Author = book.Author;
        }
    }
    public void DeleteBook(int id) => _books.RemoveAll(b => b.Id == id);
}
```

**Application Layer:**

```csharp
public class BookService
{
    private readonly IBookReader _bookReader;
    private readonly IBookWriter _bookWriter;

    public BookService(IBookReader bookReader, IBookWriter bookWriter)
    {
        _bookReader = bookReader;
        _bookWriter = bookWriter;
    }

    public IEnumerable<Book> GetBooks() => _bookReader.GetAllBooks();
    public Book GetBook(int id) => _bookReader.GetBookById(id);
    public void CreateBook(Book book) => _bookWriter.AddBook(book);
    public void UpdateBook(Book book) => _bookWriter.UpdateBook(book);
    public void DeleteBook(int id) => _bookWriter.DeleteBook(id);
}
```

**Presentation Layer:**

```csharp
[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    private readonly BookService _bookService;

    public BooksController(BookService bookService)
    {
        _bookService = bookService;
    }

    [HttpGet]
    public IActionResult GetBooks() => Ok(_bookService.GetBooks());

    [HttpGet("{id}")]
    public IActionResult GetBook(int id)
    {
        var book = _bookService.GetBook(id);
        if (book == null) return NotFound();
        return Ok(book);
    }

    [HttpPost
    public IActionResult CreateBook([FromBody] Book book)
    {
        _bookService.CreateBook(book);
        return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book);
    }

    [HttpPut("{id}")]
    public IActionResult UpdateBook(int id, [FromBody] Book book)
    {
        if (id != book.Id) return BadRequest();
        _bookService.UpdateBook(book);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public IActionResult DeleteBook(int id)
    {
        _bookService.DeleteBook(id);
        return NoContent();
    }
}
```

#### 5. Dependency Inversion Principle (DIP)

High-level modules should not depend on low-level modules. Both should depend on abstractions. Also, abstractions should not depend on details. Details should depend on abstractions.

**Example:**  
We'll ensure that our `BookService` depends on abstractions (interfaces) rather than concrete implementations.

**Program.cs (Presentation Layer):**  
Make sure to register the interfaces and their implementations in the dependency injection container.

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddScoped<IBookReader, BookRepository>();
builder.Services.AddScoped<IBookWriter, BookRepository>();
builder.Services.AddScoped<BookService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
```

### Full Example Structure

Here's a complete structure for clarity:

```
Solution.sln
├── Solution.Domain
│   ├── Book.cs
│   ├── Document.cs
│   ├── IBookReader.cs
│   ├── IBookRepository.cs
│   ├── IBookWriter.cs
├── Solution.Application
│   ├── BookService.cs
├── Solution.Infrastructure
│   ├── BookRepository.cs
├── Solution.WebAPI
│   ├── Controllers
│   │   ├── BooksController.cs
│   │   ├── DocumentsController.cs
│   ├── Program.cs
```

### Summary

- **SRP (Single Responsibility Principle):** Each class has a single responsibility.
- **OCP (Open/Closed Principle):** Classes can be extended without modifying existing code.
- **LSP (Liskov Substitution Principle):** Subclasses can replace base classes without affecting the application.
- **ISP (Interface Segregation Principle):** Interfaces are client-specific and not bloated.
- **DIP (Dependency Inversion Principle):** High-level modules depend on abstractions, not concrete implementations.  


By following these principles, you will ensure that your application is well-structured, maintainable, and scalable. If you have any further questions or need additional examples, feel free to ask!
