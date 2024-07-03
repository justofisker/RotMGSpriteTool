use godot::prelude::*;

struct SpriteTools;

mod apng_exporter;
mod spritesheet;
mod webp_exporter;

#[gdextension]
unsafe impl ExtensionLibrary for SpriteTools {}
