# Editing the institute floors in Godot

The playable institute is `institute_layout.tscn`. Unlike the earlier prototype, its floor is now an actual instanced Godot scene visible in the 2D editor.

- `scenes/floors/floor_0.tscn`: wet laboratory (36 × 20 m), four reserved rooms, ground-floor garden.
- `scenes/floors/floor_1.tscn`: general and DNA labs (18 × 20 m each), reagents, freezers, field storage, bathroom, offices, and one reserved room.
- `scripts/institute_controller.gd`: changes the active PackedScene when using the stairs or elevator with **E**; chooses the lab-coat sprite by checking room metadata.

## Workflow
1. Open `institute_layout.tscn` to see and edit the ground floor before pressing F5.
2. Open `scenes/floors/floor_1.tscn` separately to edit the upper floor; the main editor scene displays floor 0 by default.
3. In each floor, expand **Rooms**. Each room is a regular editable `Node2D` containing its colored floor polygon, its label, and physical wall segments (`StaticBody2D` + `CollisionShape2D`). Doors are openings between wall segments.
4. To modify a room's size or position, update the floor polygon, the wall segments and their collision shapes together. Keep the `room_size` metadata in sync; it is used to detect whether the character is inside a laboratory.
5. To change whether a room requires a laboratory coat, update its `is_lab` metadata.
6. Press F5 to test transitions and collision. Do not change the scientist's `AnimatedSprite2D`, `player.gd` or sprite frame resources when editing architecture.

The earlier `lab.tscn` remains intact as a reference and comparison scene. The obsolete procedural `scripts/institute_layout.gd` is not used by the current main scene.
