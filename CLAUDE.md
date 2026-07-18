# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A point-and-click adventure game built with **Godot 4.7** using **GDScript**. Resolution is 1920×1080 with canvas_items stretch mode. Physics uses Jolt Physics (3D engine, though the game is 2D-oriented).

## Running the Project

Open in Godot 4.7 editor or run from CLI:
```bash
# macOS (adjust path if Godot is installed elsewhere)
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

There are no tests or linting tools configured.

## Architecture

### Autoloads (Globals)

- **Transition** (`Scenes/UI/transition.tscn`) — full-screen fade overlay. Call `Transition.cover()` / `Transition.reveal()` (both async, must be awaited).
- **Managers** (`Scripts/Globals/managers.gd`) — singleton holding references to the active `LevelManager`, `RoomManager`, and `InventoryManager`. Scripts register themselves on `_ready()` via `Managers.xyz = self`.

### Navigation Hierarchy

The game uses a two-tier navigation system: **Levels → Rooms**.

- **LevelManager** owns an array of `Level` resources (name + PackedScene). It instantiates one level at a time, replacing the previous. The instantiated scene is always a `RoomManager`. On level change it sets `Managers.current_room_manager`.
- **RoomManager** is a scene with `Room` children. It handles transitions (fade, slide, slide-with-black) between rooms within a level. Rooms link to neighbors via `right_scene`/`left_scene` exports and `internal_scenes` for hotspot-triggered navigation. It maintains a navigation `_history` stack for back-navigation.
- **Room** is a simple Node with exported links to adjacent rooms and a `scene_name` identifier.

Levels and Rooms are registered via Godot global groups (`Rooms`, `Levels`).

### Component Pattern

Interactive objects use a **component-as-child-node** pattern. Components find sibling `Area2D` and `Sprite2D` nodes on the parent automatically:

- **DraggableComponent** — click-and-drag with z-index management.
- **NavHotspotComponent** — click to navigate. Uses `hotspot_type` (SCENE or LEVEL) to dispatch to `RoomManager.load_room_by_name()` or `LevelManager.load_level_by_name()`. Targets by name string (not direct reference) to avoid dependency cycles.
- **SelectableComponent** — click to add an `InventoryItem` to inventory.

The `Hotspot` and `SelectableItem` scene scripts are thin wrappers that forward their exports to the underlying component on `_ready()`.

### Inventory System

- **InventoryItem** — a Resource with `name` and `texture`.
- **InventoryManager** — loads all `.tres` files from `res://Resources/Inventory/` on startup into `all_items`. The `items` dict tracks currently held items. Supports select/add/delete by name or reference.

### Key Conventions

- All enums and shared constants live in `Scripts/Globals/constants.gd` (class_name `Constants`).
- Transition durations: `load_duration` (0.25s) for fades, `slide_duration` (0.4s) for slides.
- Scenes mirror the script folder structure: `Scenes/Rooms/`, `Scenes/Items/`, `Scenes/Levels/`, `Scenes/Interactive/`, `Scenes/UI/`.
- Inventory item resources go in `Resources/Inventory/` as `.tres` files.
