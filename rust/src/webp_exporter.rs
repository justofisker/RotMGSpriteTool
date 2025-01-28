use godot::{classes::Image, prelude::*};
use webp_animation::prelude::*;

#[derive(GodotClass)]
#[class(no_init)]
struct WebpExporter {
    encoder: Option<Encoder>,
}

#[godot_api]
impl WebpExporter {
    #[func]
    fn setup_with_size(width: u32, height: u32) -> Option<Gd<Self>> {
        match Encoder::new((width, height)) {
            Ok(encoder) => Some(Gd::from_object(Self {
                encoder: Some(encoder),
            })),
            Err(err) => {
                godot_error!("Error while setuping up webp exporter: {:?}", err);
                None
            }
        }
    }

    #[func]
    fn add_frame(&mut self, image: Gd<Image>, timestamp_ms: i32) {
        if let Some(encoder) = &mut self.encoder {
            if let Err(err) = encoder.add_frame(image.get_data().as_slice(), timestamp_ms) {
                godot_error!("Error while adding frame: {:?}", err);
            }
        } else {
            godot_error!("Attempting to add frame after finalize.");
        }
    }

    #[func]
    fn finalize_and_write(&mut self, final_timestamp_ms: i32, path: String) {
        if let Some(encoder) = self.encoder.take() {
            match encoder.finalize(final_timestamp_ms) {
                Ok(data) => {
                    if let Err(err) = std::fs::write(path, data) {
                        godot_error!("Error while writing webp to disk: {:?}", err);
                    }
                }
                Err(err) => {
                    godot_error!("Error while finalizing webp: {:?}", err);
                }
            }
        } else {
            godot_error!("Attempting to finalize after already finalized.");
        }
    }
}
