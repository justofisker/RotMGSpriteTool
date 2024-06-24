use std::ops::Deref;

use godot::classes::{AnimatedSprite2D, INode, Node};
use godot::engine::{AtlasTexture, FileAccess, Image, ImageTexture, SpriteFrames, Texture2D};
use godot::prelude::*;

extern crate flatbuffers;

#[allow(dead_code, unused_imports)]
#[path = "./spritesheetf_generated.rs"]
mod spritesheetf_generated;
use spritesheetf_generated as SpriteFile;
use spritesheetf_generated::root_as_sprite_sheet_root;

#[derive(GodotClass)]
#[class(base=Node)]
struct SpriteSheetDeserializer {
    map_objects: Gd<Texture2D>,
    ground_tiles: Gd<Texture2D>,
    characters: Gd<Texture2D>,
    sprite_sheets: Vec<SpriteSheet>,
    animated_sprites: Vec<AnimatedSprite>,

    base: Base<Node>,
}

#[godot_api]
impl INode for SpriteSheetDeserializer {
    fn init(base: Base<Node>) -> Self {
        Self {
            map_objects: Gd::default(),
            ground_tiles: Gd::default(),
            characters: Gd::default(),
            sprite_sheets: vec![],
            animated_sprites: vec![],
            base,
        }
    }

    fn ready(&mut self) {
        const MAP_OBJECT_PATH: &str = "res://assets/atlases/mapObjects.png";
        const GROUND_TILES_PATH: &str = "res://assets/atlases/groundTiles.png";
        const CHARACTERS_PATH: &str = "res://assets/atlases/characters.png";

        //self.map_objects = load(MAP_OBJECT_PATH);
        //self.ground_tiles = load(GROUND_TILES_PATH);
        //self.characters = load(CHARACTERS_PATH);

        if FileAccess::file_exists(MAP_OBJECT_PATH.into()) {
            let mut img = Image::new_gd();
            img.load(MAP_OBJECT_PATH.into());
            self.map_objects = ImageTexture::create_from_image(img).unwrap().upcast();
        }
        if FileAccess::file_exists(GROUND_TILES_PATH.into()) {
            let mut img = Image::new_gd();
            img.load(GROUND_TILES_PATH.into());
            self.ground_tiles = ImageTexture::create_from_image(img).unwrap().upcast();
        }
        if FileAccess::file_exists(CHARACTERS_PATH.into()) {
            let mut img = Image::new_gd();
            img.load(CHARACTERS_PATH.into());
            self.characters = ImageTexture::create_from_image(img).unwrap().upcast();
        }

        let spritesheef_path = "res://assets/atlases/spritesheetf";

        if FileAccess::file_exists(spritesheef_path.into()) {
            if let Ok(sprite_sheet_root) = root_as_sprite_sheet_root(
                FileAccess::get_file_as_bytes(spritesheef_path.into()).as_slice(),
            ) {
                for animated_sprite in sprite_sheet_root.animated_sprites().unwrap() {
                    self.animated_sprites
                        .push(AnimatedSprite::from_file(&animated_sprite))
                }
                for sprite_sheet in sprite_sheet_root.sprites().unwrap() {
                    self.sprite_sheets
                        .push(SpriteSheet::from_file(&sprite_sheet))
                }
            } else {
            }
        }
    }
}

#[godot_api]
impl SpriteSheetDeserializer {
    fn get_atlas_texture(&self, atlas_id: u64, region: &Position) -> Gd<AtlasTexture> {
        let mut atlas_texture = AtlasTexture::new_gd();
        atlas_texture.set_region(Rect2 {
            position: Vector2 {
                x: region.x,
                y: region.y,
            },
            size: Vector2 {
                x: region.w,
                y: region.h,
            },
        });
        match atlas_id {
            1 => {
                atlas_texture.set_atlas(self.ground_tiles.clone());
            }
            2 => {
                atlas_texture.set_atlas(self.characters.clone());
            }
            4 => {
                atlas_texture.set_atlas(self.map_objects.clone());
            }
            _ => {}
        }
        atlas_texture
    }

    #[func]
    fn get_animated_sprite_textures(&self, sprite_sheet: String, index: u16) -> VariantArray {
        let mut array = VariantArray::new();

        for sprite in &self.animated_sprites {
            if sprite.sprite_sheet_name.eq_ignore_ascii_case(&sprite_sheet) && sprite.index == index
            {
                array.push(
                    self.get_atlas_texture(sprite.sprite.a_id, &sprite.sprite.position)
                        .to_variant(),
                );
            }
        }

        return array;
    }

    #[func]
    fn get_texture(&self, sheet_name: String, index: u16) -> Gd<AtlasTexture> {
        let atlas_texture = AtlasTexture::new_gd();

        for sheet in &self.sprite_sheets {
            if sheet.sprite_sheet_name.eq_ignore_ascii_case(&sheet_name) {
                for sprite in &sheet.sprites {
                    if sprite.index == index {
                        return self.get_atlas_texture(sprite.a_id, &sprite.position);
                    }
                }
                break;
            }
        }

        return atlas_texture;
    }
}

#[derive(Default)]
struct Position {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
}

impl Position {
    fn from_file(position: &SpriteFile::Position) -> Self {
        Self {
            x: position.x(),
            y: position.y(),
            w: position.w(),
            h: position.h(),
        }
    }
}

#[derive(Default)]
struct Color {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
}

impl Color {
    fn from_file(color: &SpriteFile::Color) -> Self {
        Self {
            r: color.r(),
            g: color.g(),
            b: color.b(),
            a: color.a(),
        }
    }
}

#[derive(Default)]
struct Sprite {
    position: Position,
    mask_position: Position,
    padding: u16,
    index: u16,
    most_common_color: Color,
    is_t: bool,
    sprite_sheet_name: String,
    a_id: u64,
}

impl Sprite {
    fn from_file(sprite: &SpriteFile::Sprite) -> Self {
        Self {
            position: Position::from_file(sprite.position().unwrap()),
            mask_position: Position::from_file(sprite.mask_position().unwrap()),
            padding: sprite.padding(),
            index: sprite.index(),
            most_common_color: Color::from_file(sprite.most_common_color().unwrap()),
            is_t: sprite.is_t(),
            sprite_sheet_name: sprite.sprite_sheet_name().unwrap().into(),
            a_id: sprite.a_id(),
        }
    }
}

#[derive(Default)]
struct SpriteSheet {
    sprite_sheet_name: String,
    atlas_id: u64,
    sprites: Vec<Sprite>,
}

impl SpriteSheet {
    fn from_file(sprite_sheet: &SpriteFile::SpriteSheet) -> Self {
        let mut out = Self {
            sprite_sheet_name: sprite_sheet.sprite_sheet_name().unwrap().into(),
            atlas_id: sprite_sheet.atlas_id(),
            sprites: vec![],
        };

        for sprite in sprite_sheet.sprites().unwrap() {
            out.sprites.push(Sprite::from_file(&sprite));
        }

        out
    }
}

#[derive(Default)]
struct AnimatedSprite {
    sprite_sheet_name: String,
    index: u16,
    set: u16,
    direction: u16,
    action: u16,
    sprite: Sprite,
}

impl AnimatedSprite {
    fn from_file(animated_sprite: &SpriteFile::AnimatedSprite) -> Self {
        Self {
            sprite_sheet_name: animated_sprite.sprite_sheet_name().unwrap().into(),
            index: animated_sprite.index(),
            set: animated_sprite.index(),
            direction: animated_sprite.direction(),
            action: animated_sprite.action(),
            sprite: Sprite::from_file(&animated_sprite.sprite().unwrap()),
        }
    }
}
