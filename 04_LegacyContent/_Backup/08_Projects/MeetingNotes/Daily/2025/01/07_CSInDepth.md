```csharp
using Ch02.Interfaces;
using System.Collections.Generic; // For List<T>
using System.Collections;
using static System.Console; // Static using for Console members

namespace Ch02.Interfaces;

public interface IDemoProgram
{
    string Title { get; } // Add a Title property
    void Run();
}

namespace Ch02.Demos;

internal class NamesWithArrayDemo : IDemoProgram
{
    public string Title => "Names with Array";

    private static string[] GenerateNames() => ["Gamma", "Vlissides", "Johnson", "Helm"]; // Expression body

    private static void PrintNames(string[] names)
    {
        foreach (string name in names)
        {
            WriteLine(name);
        }
    }

    public void Run()
    {
        string[] names = GenerateNames();
        PrintNames(names);
    }
}

public class NamesWithListDemo : IDemoProgram // Use List<T>
{
    public string Title => "Names with List<string>";

    private static List<string> GenerateNames() => ["Gamma", "Vlissides", "Johnson", "Helm"];

    private static void PrintNames(List<string> names)
    {
        foreach (string name in names)
        {
            WriteLine(name);
        }
    }

    public void Run()
    {
        List<string> names = GenerateNames();
        PrintNames(names);
    }
}

public class NamesWithArrayListDemo : IDemoProgram
{
    public string Title => "Names with ArrayList (Avoid using ArrayList in new code)";

    private static ArrayList GenerateNames() => ["Gamma", "Vlissides", "Johnson", "Helm"];

    private static void PrintNames(ArrayList names)
    {
        foreach (string name in names)
        {
            WriteLine(name);
        }
    }

    public void Run()
    {
        ArrayList names = GenerateNames();
        PrintNames(names);
    }
}

// Top-level statements
ForegroundColor = ConsoleColor.DarkCyan;

// Use a list to store and run the demos
List<IDemoProgram> demos = [
    new NamesWithArrayDemo(),
    new NamesWithListDemo(),
    new NamesWithArrayListDemo()
];

foreach (IDemoProgram demo in demos)
{
    WriteLine($"Running: {demo.Title}"); // Display the title
    demo.Run();
    WriteLine(); // Add a separator
}

ResetColor();

WriteLine("\nPress any key to exit...");
ReadKey(true);
```

**Key Improvements:**

- **`List<T>` Instead of `ArrayList`:** The most important change is replacing `ArrayList` with `List<string>`. `ArrayList` is a non-generic collection, which means it stores objects of type `object`. This leads to boxing/unboxing overhead and a lack of type safety. `List<string>` is a generic collection that stores only strings, providing better performance and type safety. I kept the `ArrayList` version but marked it as something to avoid.
- **`Title` Property in `IDemoProgram`:** Added a `Title` property to the `IDemoProgram` interface to provide a descriptive name for each demo. This makes the output more informative.
- **Static Using for `Console`:** Added `using static System.Console;` to avoid writing `Console.` repeatedly.
- **Expression Bodies:** Used expression bodies (`=>`) for concise method definitions.
- **Demo Execution Loop:** Created a `List<IDemoProgram>` to store the demo instances and iterated through it to run each demo and display its title. This makes it easy to add more demos in the future.
- **Clearer Output:** Added separators between demos and displayed the title of each demo before running it.
- **Private Methods:** Changed `GenerateNames` and `PrintNames` to `private static` as they are helper methods and should not be accessible from outside the class.
- **Naming Consistency:** Renamed `NamesWithArrayList` to `NamesWithArrayListDemo` and added `NamesWithListDemo` for the new `List<T>` implementation for consistency.

This revised code is much improved in terms of performance, type safety, readability, and maintainability. It also demonstrates better C# coding practices. The use of `List<T>` instead of `ArrayList` is a significant improvement. The added `Title` property and the demo execution loop make the code more organized and extensible.
