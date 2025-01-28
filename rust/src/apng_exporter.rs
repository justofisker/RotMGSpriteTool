use std::{fs::File, io::BufWriter};

use godot::{classes::Image, prelude::*};
use png::{AnimationControl, Encoder};

#[derive(GodotClass)]
#[class(no_init)]
struct ApngExporter {
    width: u32,
    height: u32,
    frames: Vec<Frame>,
}

struct Frame {
    image: Gd<Image>,
    timestamp_ms: u32,
}

#[godot_api]
impl ApngExporter {
    #[func]
    fn setup_with_size(width: u32, height: u32) -> Gd<Self> {
        Gd::from_object(Self {
            width,
            height,
            frames: Vec::new(),
        })
    }

    #[func]
    fn add_frame(&mut self, image: Gd<Image>, timestamp_ms: u32) {
        self.frames.push(Frame {
            image,
            timestamp_ms,
        });
    }

    fn internal_finalize_and_write(
        &self,
        file: File,
        final_timestamp_ms: u32,
    ) -> Result<(), png::EncodingError> {
        let ref mut w = BufWriter::new(file);

        let mut info = png::Info::default();
        info.color_type = png::ColorType::Rgba;
        info.bit_depth = png::BitDepth::Eight;
        info.width = self.width;
        info.height = self.height;
        info.animation_control = Some(AnimationControl {
            num_frames: self.frames.len() as u32,
            num_plays: 0,
        });

        let mut frame_times: Vec<u32> =
            self.frames.iter().map(|frame| frame.timestamp_ms).collect();
        frame_times.push(final_timestamp_ms);
        let mut frame_delays = Vec::<u32>::new();
        for i in 1..frame_times.len() {
            frame_delays.push(frame_times[i] - frame_times[i - 1]);
        }

        info.frame_control = Some(png::FrameControl {
            sequence_number: 0,
            width: self.width,
            height: self.height,
            x_offset: 0,
            y_offset: 0,
            delay_num: frame_delays[0] as u16,
            delay_den: 1000,
            dispose_op: png::DisposeOp::Background,
            blend_op: png::BlendOp::Source,
        });

        let encoder = Encoder::with_info(w, info)?;

        if let Ok(mut writer) = encoder.write_header() {
            for i in 0..self.frames.len() {
                writer.set_frame_delay(frame_delays[i] as u16, 1000)?;

                writer.write_image_data(self.frames[i].image.get_data().as_slice())?;
            }

            writer.finish()?
        };

        Ok(())
    }

    #[func]
    fn finalize_and_write(&self, final_timestamp_ms: u32, path: String) {
        match File::create(path) {
            Ok(file) => {
                if let Err(err) = self.internal_finalize_and_write(file, final_timestamp_ms) {
                    godot_error!("Failed encoding APNG: {}", err);
                }
            }
            Err(err) => {
                godot_error!("Failed opening file: {}", err);
            }
        }
    }
}
