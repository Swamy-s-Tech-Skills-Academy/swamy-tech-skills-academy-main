# Learning SOLID Priciples

Some description

The **SOLID principles** are design guidelines for building maintainable, scalable, and robust software systems. Here's a **crisp summary** tailored for C#:

---

### **1. Single Responsibility Principle (SRP)**

- **Definition:** A class should have only one reason to change.
- **Key Idea:** Each class should focus on a single responsibility or functionality.
- **Example:**

  ```csharp
  public class ReportGenerator {
      public string GenerateReport() {
          // Generate report logic
      }
  }

  public class ReportSaver {
      public void SaveReport(string report) {
          // Save report logic
      }
  }
  ```

  - **Why?** Separates concerns: generating the report and saving it.

---

### **2. Open/Closed Principle (OCP)**

- **Definition:** Classes should be open for extension but closed for modification.
- **Key Idea:** New functionality can be added without modifying existing code.
- **Example:**

  ```csharp
  public interface ILogger {
      void Log(string message);
  }

  public class FileLogger : ILogger {
      public void Log(string message) {
          // Log to file
      }
  }

  public class DatabaseLogger : ILogger {
      public void Log(string message) {
          // Log to database
      }
  }
  ```

  - **Why?** You can add new loggers without changing existing code.

---

### **3. Liskov Substitution Principle (LSP)**

- **Definition:** Subclasses should be replaceable by their base class without altering the correctness of the program.
- **Key Idea:** Derived classes must adhere to the behavior expected by the base class.
- **Example:**

  ```csharp
  public class Shape {
      public virtual double Area() => 0;
  }

  public class Rectangle : Shape {
      public double Width { get; set; }
      public double Height { get; set; }
      public override double Area() => Width * Height;
  }

  public class Circle : Shape {
      public double Radius { get; set; }
      public override double Area() => Math.PI * Radius * Radius;
  }
  ```

  - **Why?** Polymorphism works seamlessly when all shapes can calculate their area.

---

### **4. Interface Segregation Principle (ISP)**

- **Definition:** A class should not be forced to implement interfaces it does not use.
- **Key Idea:** Split large interfaces into smaller, more specific ones.
- **Example:**

  ```csharp
  public interface IPrinter {
      void Print();
  }

  public interface IScanner {
      void Scan();
  }

  public class MultiFunctionPrinter : IPrinter, IScanner {
      public void Print() {
          // Print logic
      }

      public void Scan() {
          // Scan logic
      }
  }

  public class SimplePrinter : IPrinter {
      public void Print() {
          // Print logic
      }
  }
  ```

  - **Why?** Simple printers don't need to implement scanning functionality.

---

### **5. Dependency Inversion Principle (DIP)**

- **Definition:** High-level modules should not depend on low-level modules. Both should depend on abstractions.
- **Key Idea:** Use interfaces or abstract classes to reduce coupling.
- **Example:**

  ```csharp
  public interface IMessageSender {
      void SendMessage(string message);
  }

  public class EmailSender : IMessageSender {
      public void SendMessage(string message) {
          // Send email logic
      }
  }

  public class NotificationService {
      private readonly IMessageSender _messageSender;

      public NotificationService(IMessageSender messageSender) {
          _messageSender = messageSender;
      }

      public void Notify(string message) {
          _messageSender.SendMessage(message);
      }
  }
  ```

  - **Why?** You can easily switch `EmailSender` with an `SMSSender` or any other sender without modifying `NotificationService`.

---

### **Key Benefits of SOLID in C#:**

1. **Maintainability:** Easier to update and refactor.
2. **Scalability:** New features can be added without breaking existing code.
3. **Testability:** Code is more modular and easier to unit test.
4. **Reusability:** Promotes modular and reusable components.

Would you like detailed examples or further explanations? Good luck with your interview! 🚀
