# Quickshell Architecture Documentation

This document describes the architecture of the refactored Quickshell configuration.
The goal of this architecture is to separate **layout logic**, **UI modules**, and **system services** into independent layers.

The shell is designed to be **modular, composable, and layout-driven**, allowing layouts to be changed without modifying QML code.

---

# High-Level Architecture

The shell operates in four main layers:

```
Shell
 └ Engine
     ├ Layouts
     └ Modules
         └ Components
```

Each layer has a specific responsibility.

| Layer            | Responsibility                        |
| ---------------- | ------------------------------------- |
| Shell            | Entry point that initializes the UI   |
| Engine           | Loads layouts and modules dynamically |
| Layouts          | Define UI structure using data        |
| Modules          | Functional UI features                |
| Components       | Reusable UI primitives                |
| Globals / Shared | Global services and configuration     |

---

# Folder Documentation

---

# `/engine`

### Purpose

The **engine** is responsible for dynamically constructing the user interface.

Instead of writing the entire layout directly in QML, the engine reads layout definitions and loads the required modules.

### Responsibilities

* Load layout definitions
* Manage module registration
* Create layout slots
* Insert modules into slots

### Key Concepts

| Concept | Description                                     |
| ------- | ----------------------------------------------- |
| Module  | A functional UI unit (clock, media, workspaces) |
| Slot    | A container where modules are placed            |
| Layout  | A structure describing slot arrangement         |

### Example Flow

```
Layout JSON
    ↓
LayoutLoader
    ↓
SlotLayout
    ↓
BarSlots
    ↓
Modules
```

---

# `/layouts`

### Purpose

The **layouts** folder defines how modules are arranged in the interface.

Layouts are defined as **data**, not code.

This allows the shell to support multiple layouts without modifying QML files.

### Responsibilities

* Define UI structure
* Specify module placement
* Enable layout switching

### Example Layout

```json
{
  "left": ["workspaces"],
  "center": ["clock"],
  "right": ["media", "buttons"]
}
```

### Benefits

* Layout changes require no code modification
* Multiple layouts can coexist
* Easier experimentation

---

# `/modules`

### Purpose

Modules are **self-contained UI features**.

Each module represents a specific piece of functionality.

Examples:

* Workspaces
* Clock
* Media player
* System buttons

### Structure

Each module typically contains:

```
module-name/
 ├ Module.qml
 └ qmldir
```

### Responsibilities

* Provide UI functionality
* Connect to backend services
* Render content inside layout slots

Modules should avoid controlling layout themselves.

Instead, they should focus only on **displaying functionality**.

---

# `/components`

### Purpose

Components provide **reusable UI building blocks** used by modules.

They function as the shell's **UI toolkit**.

Examples include:

* Buttons
* Panels
* Toggles
* Animated elements
* Screen borders

### Responsibilities

* Provide reusable UI elements
* Encapsulate styling and behavior
* Reduce duplication across modules

### Design Principle

Components should be:

* Generic
* Reusable
* Independent of modules

---

# `/panels`

### Purpose

Panels are **larger UI surfaces** separate from the main bar.

Examples include:

* Dashboard
* Settings
* System tray panel

Panels typically appear as:

* Popups
* Sidebars
* Overlays

### Responsibilities

* Provide extended UI interfaces
* Display secondary information
* Handle interactive system controls

Panels may internally use modules or components.

---

# `/globals` (or `/shared`)

### Purpose

This folder contains **global services and configuration objects**.

These are typically implemented as **QML singletons**.

### Responsibilities

Provide shared functionality such as:

| Service    | Description                 |
| ---------- | --------------------------- |
| Colors     | Theme color definitions     |
| Config     | Global configuration values |
| Animations | Shared animation settings   |
| EventBus   | Cross-module communication  |
| Time       | Time utilities              |

These allow modules to remain decoupled while still sharing data.

---

# `/shell`

### Purpose

The shell folder contains the **main entry point of the UI**.

This file initializes the layout engine and global services.

### Responsibilities

* Start the shell
* Initialize services
* Load the active layout
* Render the root UI

---

# Design Principles

## Modularity

Modules should remain independent and reusable.

Modules should not depend on specific layouts.

---

## Layout/Data Separation

UI structure should be defined by **layout data**, not hardcoded UI logic.

---

## Composability

Modules should be small units that can be combined in different ways.

---

## Reusability

Components should be reusable across modules.

---

# Summary

This architecture converts the shell from a **static UI layout** into a **layout-driven UI system**.

Instead of writing a single UI structure, the shell now acts as a runtime that assembles the interface dynamically.

Benefits include:

* Flexible layouts
* Modular UI design
* Easier feature expansion
* Improved maintainability

---

# Conceptual Model

```
Quickshell
 ├ Engine
 │   ├ LayoutLoader
 │   ├ SlotLayout
 │   └ ModuleRegistry
 │
 ├ Layouts
 │   └ Layout definitions
 │
 ├ Modules
 │   └ Functional UI units
 │
 ├ Components
 │   └ Reusable UI primitives
 │
 └ Globals
     └ Shared services
```

This separation enables the shell to function as a **composable desktop UI system** rather than a fixed interface.
