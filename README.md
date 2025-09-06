# Zentient.Metadata Monorepo

[![NuGet](https://img.shields.io/nuget/v/Zentient.Metadata.svg)](https://www.nuget.org/packages/Zentient.Metadata)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![.NET](https://img.shields.io/badge/.NET-8.0%20%7C%209.0-blue.svg)](https://dotnet.microsoft.com/)

Zentient.Metadata is a modern, extensible metadata platform for .NET, supporting attribute-based, code-based, and analyzer-driven metadata for frameworks, libraries, and applications. This monorepo contains all core packages:

- **Zentient.Metadata** (core engine)
- **Zentient.Metadata.Attributes** (attribute-based metadata discovery)
- **Zentient.Metadata.Abstractions** (interfaces and contracts)
- **Zentient.Metadata.Analyzers** (Roslyn analyzers for DX and validation)
- **Zentient.Metadata.Diagnostics** (diagnostic helpers and profiles)

---

## Packages Overview

### Zentient.Metadata

- Immutable, thread-safe metadata objects (`IMetadata`)
- Fluent builder pattern (`IMetadataBuilder`)
- Extension methods for querying, merging, and composing metadata
- Pluggable scanners for runtime and attribute-based discovery

### Zentient.Metadata.Attributes

- Attribute-based metadata discovery and conversion
- Supports `[BehaviorDefinition]`, `[CategoryDefinition]`, `[MetadataTag]`, and legacy attributes
- Custom attribute handler registry for extensibility
- Unified scanning APIs for types, members, assemblies

### Zentient.Metadata.Abstractions

- All core interfaces: `IMetadata`, `IMetadataBuilder`, `IMetadataScanner`, `IMetadataDefinition`, `IMetadataTag`, `IPresetKey`
- Designed for forward-compatibility and cross-package integration

### Zentient.Metadata.Analyzers

- Roslyn analyzers for attribute usage, DX, and best practices
- Detects duplicate/conflicting tags, missing docs, and more

### Zentient.Metadata.Diagnostics

- Diagnostic helpers, profiles, and DX utilities for metadata-driven systems

---

## Getting Started

Install the core package:

```sh
dotnet add package Zentient.Metadata
```

Add attribute-based discovery:

```sh
dotnet add package Zentient.Metadata.Attributes
```

---

## Educational Samples

All samples below are available in the [`Samples/`](Samples/) folder and compile/run as standalone console apps.

### 1. Building and Querying Metadata

`Samples/MetadataBuilderSample.cs`
```csharp
using System;
using Zentient.Metadata;
using Zentient.Abstractions.Metadata;

public class MetadataBuilderSample
{
    public static void Main()
    {
        // Build metadata using the fluent builder
        var metadata = Metadata.Create()
            .SetTag("Version", "1.0.0")
            .SetTag("Author", "Zentient Team")
            .Build();

        // Query metadata
        if (metadata.ContainsKey("Version"))
        {
            string version = metadata.GetValueOrDefault<string>("Version");
            Console.WriteLine($"Version: {version}");
        }
    }
}
```

### 2. Attribute-Based Metadata Discovery

`Samples/AttributeDiscoverySample.cs`
```csharp
using System;
using Zentient.Metadata.Attributes;
using Zentient.Abstractions.Metadata;

// Define a custom tag attribute
[AttributeUsage(AttributeTargets.Class)]
public class VersionTagAttribute : MetadataTagAttribute
{
    public VersionTagAttribute(string value) : base(typeof(VersionTagAttribute), value) { }
}

// Annotate your class
[VersionTag("2.1.0")]
public class MyService { }

public class AttributeDiscoverySample
{
    public static void Main()
    {
        // Discover metadata from attributes
        var metadata = MetadataAttributeReader.GetMetadata(typeof(MyService));
        var version = metadata.GetTagValue<VersionTagAttribute, string>();
        Console.WriteLine($"Discovered VersionTag: {version}"); // Output: 2.1.0
    }
}
```

### 3. Registering a Custom Attribute Handler

`Samples/CustomAttributeHandlerSample.cs`
```csharp
using System;
using Zentient.Metadata.Attributes;
using Zentient.Abstractions.Metadata;

// Define a custom attribute
public class PriorityAttribute : MetadataAttribute
{
    public int Level { get; }
    public PriorityAttribute(int level) => Level = level;
}

// Register a handler and use the attribute
[Priority(5)]
public class ImportantService { }

public class CustomAttributeHandlerSample
{
    public static void Main()
    {
        // Register a handler
        AttributeHandlerRegistry.Register<PriorityAttribute>((attr, ctx) =>
            ctx.Builder.SetTag("priority", attr.Level));

        // Discover and use the custom tag
        var metadata = MetadataAttributeReader.GetMetadata(typeof(ImportantService));
        int priority = metadata.GetValueOrDefault<int>("priority");
        Console.WriteLine($"Priority: {priority}"); // Output: 5
    }
}
```

### 4. Using the Abstractions Layer

`Samples/AbstractionsLayerSample.cs`
```csharp
using System;
using Zentient.Abstractions.Metadata;

public class AbstractionsLayerSample
{
    public static void PrintTags(IMetadata metadata)
    {
        foreach (var tag in metadata.Keys)
            Console.WriteLine($"{tag}: {metadata.GetValueOrDefault<object>(tag)}");
    }

    public static void Main()
    {
        var metadata = new Dictionary<string, object?>
        {
            ["Version"] = "3.0.0",
            ["Author"] = "Zentient Team"
        };
        var meta = Zentient.Metadata.Metadata.Create().AddTags(metadata).Build();
        PrintTags(meta);
    }
}
```

---

## Documentation

- [Attribute Specification](docs/Zentient_Metadata_Metadata-Attribute-Specification.md)
- [API Reference](https://ulfbou.github.io/Zentient.Metadata/)
- [CHANGELOG.md](CHANGELOG.md)

---
