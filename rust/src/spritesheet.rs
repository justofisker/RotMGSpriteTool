use godot::classes::{INode, Node};
use godot::engine::{AtlasTexture, FileAccess, Image, ImageTexture, Texture2D};
use godot::global::push_warning;
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
    map_objects: Option<Gd<Texture2D>>,
    ground_tiles: Option<Gd<Texture2D>>,
    characters: Option<Gd<Texture2D>>,
    sprite_sheets: Vec<SpriteSheet>,
    animated_sprites: Vec<AnimatedSprite>,

    base: Base<Node>,
}

#[godot_api]
impl INode for SpriteSheetDeserializer {
    fn init(base: Base<Node>) -> Self {
        Self {
            map_objects: None,
            ground_tiles: None,
            characters: None,
            sprite_sheets: vec![],
            animated_sprites: vec![],
            base,
        }
    }

    fn ready(&mut self) {
        if godot::classes::Os::singleton().has_feature("editor".into()) {
            self.map_objects = Some(load("res://assets/atlases/mapObjects.png"));
            self.ground_tiles = Some(load("res://assets/atlases/groundTiles.png"));
            self.characters = Some(load("res://assets/atlases/characters.png"));
        } else {
            fn load_img(file_path: &str) -> Option<Gd<Texture2D>> {
                if FileAccess::file_exists(file_path.into()) {
                    let mut img = Image::new_gd();
                    img.load(file_path.into());
                    Some(ImageTexture::create_from_image(img).unwrap().upcast())
                } else {
                    godot_error!("Failed to load image file: {}", file_path);
                    None
                }
            }

            self.map_objects = load_img("res://assets/atlases/mapObjects.png");
            self.ground_tiles = load_img("res://assets/atlases/groundTiles.png");
            self.characters = load_img("res://assets/atlases/characters.png");
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
    fn create_atlas_texture(&self, atlas_id: u64, region: &Position) -> Option<Gd<AtlasTexture>> {
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
                if let Some(ground_tiles) = self.ground_tiles.clone() {
                    atlas_texture.set_atlas(ground_tiles);
                } else {
                    return None;
                }
            }
            2 => {
                if let Some(characters) = self.characters.clone() {
                    atlas_texture.set_atlas(characters);
                } else {
                    return None;
                }
            }
            4 => {
                if let Some(map_objects) = self.map_objects.clone() {
                    atlas_texture.set_atlas(map_objects);
                } else {
                    return None;
                }
            }
            _ => {
                return None;
            }
        }
        Some(atlas_texture)
    }

    #[func]
    fn get_animated_textures(
        &self,
        &sprite_sheet: String,
        index: u16,
    ) -> Array<Gd<RotmgAnimatedTexture>> {
        let mut array = Array::new();

        for sprite in &self.animated_sprites {
            if sprite.sprite_sheet_name.eq_ignore_ascii_case(&sprite_sheet) && sprite.index == index {
                array.push(Gd::from_object(RotmgAnimatedTexture{
                    set: sprite.set,
                    direction: sprite.direction,
                    action: sprite.action,
                    texture: Some(Gd::from_object(RotmgTexture {
                        padding: sprite.sprite.padding,
                        texture: self.create_atlas_texture(sprite.sprite.a_id, &sprite.sprite.position),
                    })),
                }));
            }
        }

        array
    }

    #[func]
    fn get_texture(&self, sheet_name: String, index: u16) -> Option<Gd<RotmgTexture>> {
        for sheet in &self.sprite_sheets {
            if sheet.sprite_sheet_name.eq_ignore_ascii_case(&sheet_name) {
                for sprite in &sheet.sprites {
                    if sprite.index == index {
                        if let Some(tex) = self.create_atlas_texture(sprite.a_id, &sprite.position) {
                            return Some(Gd::from_object(RotmgTexture {
                                padding: sprite.padding,
                                texture: Some(tex)
                            }));
                        }
                        return None;
                    }
                }
                break;
            }
        }

        None
    }

    #[func]
    fn get_atlas_characters(&self) -> Option<Gd<Texture2D>> {
        return self.characters.clone();
    }

    #[func]
    fn get_atlas_map_objects(&mut self) -> Option<Gd<Texture2D>> {
        return self.map_objects.clone();
    }

    #[func]
    fn get_atlas_ground_tiles(&self) -> Option<Gd<Texture2D>> {
        return self.ground_tiles.clone();
    }
}

#[derive(GodotClass)]
#[class(no_init)]
struct RotmgAnimatedTexture {
    #[var]
    set: u16,
    #[var]
    direction: u16,
    #[var]
    action: u16,
    #[var]
    texture: Option<Gd<RotmgTexture>>,
}

#[derive(GodotClass)]
#[class(no_init)]
struct RotmgTexture {
    #[var]
    padding: u16,
    #[var]
    texture: Option<Gd<AtlasTexture>>,
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
