use godot::prelude::*;

struct SpriteTools;

mod spritesheet;
mod webp_exporter;

#[gdextension]
unsafe impl ExtensionLibrary for SpriteTools {}
