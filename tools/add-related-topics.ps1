# Add Related Topics sections to OOP and SOLID files missing them
# This script systematically adds STSA-compliant Related Topics metadata

param(
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

# Define Related Topics templates for each file
$relatedTopicsMap = @{
    # OOP-fundamentals files
    "01_OOP-Classes-and-Objects-CONDENSED.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- Basic programming knowledge

### **Builds Upon**
- Universal design thinking
- Problem-solving approaches

### **Enables Next Steps**
- **Next**: [01_OOP-Core-Concepts-PartA.md](01_OOP-Core-Concepts-PartA.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**
- **UML Modeling**: [UML Documentation](../23_UML/)
- **Design Patterns**: [Design Patterns](../03_Design-Patterns/)
"@

    "01_OOP-Core-Concepts-PartB.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [01_OOP-Core-Concepts-PartA.md](01_OOP-Core-Concepts-PartA.md)

### **Builds Upon**
- OOP fundamentals and benefits
- Class structure basics

### **Enables Next Steps**
- **Next**: [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)
- **Future**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)

### **Cross-References**
- **Related Concepts**: [SOLID Principles](../02_SOLID-Principles/)
- **UML Modeling**: [UML Documentation](../23_UML/)
"@

    "01_OOP-Objects-Creation-PartA.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [01_OOP-Core-Concepts-PartA.md](01_OOP-Core-Concepts-PartA.md)
- [01_OOP-Core-Concepts-PartB.md](01_OOP-Core-Concepts-PartB.md)

### **Builds Upon**
- Class definition and structure
- OOP fundamentals

### **Enables Next Steps**
- **Next**: [01_OOP-Objects-Creation-PartB.md](01_OOP-Objects-Creation-PartB.md)
- **Future**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)

### **Cross-References**
- **Advanced Patterns**: [04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)
"@

    "01_OOP-Objects-Creation-PartB.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)

### **Builds Upon**
- Object instantiation basics
- Class interactions

### **Enables Next Steps**
- **Next**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
- **Future**: [03_OOP-Inheritance-Polymorphism.md](03_OOP-Inheritance-Polymorphism.md)

### **Cross-References**
- **Design Patterns**: [Design Patterns](../03_Design-Patterns/)
"@

    "05_OOP-Fundamentals-Comprehensive-Guide-PartA.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- Basic OOP understanding
- Completed Core Concepts series

### **Builds Upon**
- [01_OOP-Core-Concepts-PartA.md](01_OOP-Core-Concepts-PartA.md)
- [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)

### **Enables Next Steps**
- **Next**: [05_OOP-Fundamentals-Comprehensive-Guide-PartB.md](05_OOP-Fundamentals-Comprehensive-Guide-PartB.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**
- **Advanced Topics**: [04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)
"@

    "06_OOD-Learning-Plan-PartA.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- Completed OOP fundamentals
- Basic design thinking

### **Builds Upon**
- All OOP core concepts
- [03_OOP-Inheritance-Polymorphism.md](03_OOP-Inheritance-Polymorphism.md)

### **Enables Next Steps**
- **Next**: [06_OOD-Learning-Plan-PartB.md](06_OOD-Learning-Plan-PartB.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**
- **Design Patterns**: [Design Patterns](../03_Design-Patterns/)
- **UML**: [UML Documentation](../23_UML/)
"@

    "06_OOD-Learning-Plan-PartB.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [06_OOD-Learning-Plan-PartA.md](06_OOD-Learning-Plan-PartA.md)

### **Builds Upon**
- OOD principles Part A
- Design thinking fundamentals

### **Enables Next Steps**
- **Next**: [07_OOD-Basics-PartA.md](07_OOD-Basics-PartA.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**
- **Architecture**: [Architectural Patterns](../04_Architectural-Patterns/)
"@

    "07_OOD-Basics-PartA.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [06_OOD-Learning-Plan-PartB.md](06_OOD-Learning-Plan-PartB.md)
- Completed OOP fundamentals

### **Builds Upon**
- Object-oriented design principles
- UML basics

### **Enables Next Steps**
- **Next**: [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**
- **UML**: [UML Documentation](../23_UML/)
"@

    "07_OOD-Basics-PartB.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [07_OOD-Basics-PartA.md](07_OOD-Basics-PartA.md)

### **Builds Upon**
- OOD fundamentals Part A
- Class relationships

### **Enables Next Steps**
- **Next**: [07_OOD-Basics-PartC.md](07_OOD-Basics-PartC.md)
- **Future**: [Design Patterns](../03_Design-Patterns/)

### **Cross-References**
- **SOLID**: [SOLID Principles](../02_SOLID-Principles/)
"@

    "07_OOD-Basics-PartC.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)

### **Builds Upon**
- Complete OOD basics series
- Design pattern readiness

### **Enables Next Steps**
- **Next**: [08_OOP-Abstraction-Encapsulation-PartA.md](08_OOP-Abstraction-Encapsulation-PartA.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**
- **Patterns**: [Design Patterns](../03_Design-Patterns/)
"@

    "08_OOP-Abstraction-Encapsulation-PartA.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [07_OOD-Basics-PartC.md](07_OOD-Basics-PartC.md)
- Understanding of OOP pillars

### **Builds Upon**
- [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
- Design principles

### **Enables Next Steps**
- **Next**: [08_OOP-Abstraction-Encapsulation-PartB.md](08_OOP-Abstraction-Encapsulation-PartB.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**
- **Advanced**: [04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)
"@

    "08_OOP-Abstraction-Encapsulation-PartB.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [08_OOP-Abstraction-Encapsulation-PartA.md](08_OOP-Abstraction-Encapsulation-PartA.md)

### **Builds Upon**
- Abstraction fundamentals Part A
- Encapsulation patterns

### **Enables Next Steps**
- **Next**: [08_OOP-Abstraction-Encapsulation-PartC.md](08_OOP-Abstraction-Encapsulation-PartC.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**
- **Design Patterns**: [Design Patterns](../03_Design-Patterns/)
"@

    "08_OOP-Abstraction-Encapsulation-PartC.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [08_OOP-Abstraction-Encapsulation-PartB.md](08_OOP-Abstraction-Encapsulation-PartB.md)

### **Builds Upon**
- Complete abstraction/encapsulation series
- Advanced OOP patterns

### **Enables Next Steps**
- **Next**: [SOLID Principles](../02_SOLID-Principles/)
- **Future**: [Design Patterns](../03_Design-Patterns/)

### **Cross-References**
- **Architecture**: [Architectural Patterns](../04_Architectural-Patterns/)
"@

    # SOLID-Principles files
    "01_SOLID-Part1-Single-Responsibility-PartB.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [01_SOLID-Part1-Single-Responsibility-PartA.md](01_SOLID-Part1-Single-Responsibility-PartA.md)
- [OOP Fundamentals](../01_OOP-fundamentals/)

### **Builds Upon**
- Single Responsibility Principle fundamentals
- Class design basics

### **Enables Next Steps**
- **Next**: [01_SOLID-Part1-Single-Responsibility-PartC.md](01_SOLID-Part1-Single-Responsibility-PartC.md)
- **Future**: [02_SOLID-Part2-Open-Closed-Principle-PartA.md](02_SOLID-Part2-Open-Closed-Principle-PartA.md)

### **Cross-References**
- **Design Patterns**: [Design Patterns](../03_Design-Patterns/)
- **Testing**: Enterprise testing methodologies
"@

    # Add more SOLID files here
    "02_SOLID-Part2-Open-Closed-Principle-PartA.md" = @"

## 🔗 Related Topics

### **Prerequisites**
- [01_SOLID-Part1-Single-Responsibility-PartC.md](01_SOLID-Part1-Single-Responsibility-PartC.md)
- [OOP Fundamentals](../01_OOP-fundamentals/)

### **Builds Upon**
- Single Responsibility Principle
- Interface design

### **Enables Next Steps**
- **Next**: [02_SOLID-Part2-Open-Closed-Principle-PartB.md](02_SOLID-Part2-Open-Closed-Principle-PartB.md)
- **Future**: [03_SOLID-Part3-Liskov-Substitution-Principle-PartA.md](03_SOLID-Part3-Liskov-Substitution-Principle-PartA.md)

### **Cross-References**
- **Design Patterns**: [Strategy Pattern](../03_Design-Patterns/)
"@
}

# Base paths
$oopBase = "01_ReferenceLibrary\01_Development\01_software-design-principles\01_OOP-fundamentals"
$solidBase = "01_ReferenceLibrary\01_Development\01_software-design-principles\02_SOLID-Principles"

$filesProcessed = 0
$filesUpdated = 0

foreach ($filename in $relatedTopicsMap.Keys) {
    $filesProcessed++
    
    # Determine base path
    $basePath = if ($filename -like "01_SOLID-*" -or $filename -like "02_SOLID-*" -or $filename -like "03_SOLID-*" -or $filename -like "04_SOLID-*" -or $filename -like "05_SOLID-*") {
        $solidBase
    } else {
        $oopBase
    }
    
    $filePath = Join-Path $basePath $filename
    
    if (-not (Test-Path $filePath)) {
        Write-Host "⚠️  File not found: $filename" -ForegroundColor Yellow
        continue
    }
    
    $content = Get-Content -Path $filePath -Raw
    
    # Check if Related Topics already exists
    if ($content -match "##\s+🔗\s+Related Topics") {
        Write-Host "✓ $filename - Already has Related Topics" -ForegroundColor Green
        continue
    }
    
    # Append Related Topics at the end before any final markers
    $relatedTopicsContent = $relatedTopicsMap[$filename]
    
    if ($DryRun) {
        Write-Host "🔍 [DRY RUN] Would add Related Topics to: $filename" -ForegroundColor Cyan
    } else {
        $newContent = $content.TrimEnd() + "`n" + $relatedTopicsContent + "`n"
        Set-Content -Path $filePath -Value $newContent -NoNewline -Encoding UTF8
        Write-Host "✅ Added Related Topics to: $filename" -ForegroundColor Green
        $filesUpdated++
    }
}

Write-Host "`n📊 Summary:" -ForegroundColor Cyan
Write-Host "Files processed: $filesProcessed" -ForegroundColor White
Write-Host "Files updated: $filesUpdated" -ForegroundColor Green
Write-Host "Mode: $(if ($DryRun) { 'DRY RUN' } else { 'LIVE UPDATE' })" -ForegroundColor $(if ($DryRun) { 'Yellow' } else { 'Green' })
