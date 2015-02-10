require 'zip'
require 'pp'
require 'json'
require 'chunky_png'

ATLAS_IN_DIR = 'raw/atlases'
ATLAS_OUT_DIR = 'assets/atlases'

desc 'Process atlasses (from .pyxel to .png + .json)'
task :atlases do
  Dir[File.join(ATLAS_IN_DIR, '*.pyxel')].each do |raw_file|
    Zip::File.open(raw_file) do |zip_file|
      name = File.basename(raw_file, ".pyxel")

      # Get metadata.
      metadata_file = zip_file.glob('docData.json').first
      metadata = JSON.load(metadata_file.get_input_stream.read)
      tile_position_to_id = metadata["canvas"]["layers"]["0"]["tileRefs"]

      animations = {}
      metadata["animations"].each_value do |anim|
        base = anim["baseTile"]
        animations[anim["name"]] = anim["frameDurationMultipliers"].map.with_index do |m, i|
          {
            tile: tile_position_to_id[(base + i).to_s]["index"],
            duration: m * anim["frameDuration"] / 100000.0
          }
        end
      end

      tile_width = metadata["canvas"]["tileWidth"]
      tile_height = metadata["canvas"]["tileHeight"]
      num_tiles = tile_position_to_id.map {|i, t| t["index"] }.max + 1

      data = {
        tile_size: [tile_width, tile_height],
        animations: animations,
      }

      metadata_filename = File.join(ATLAS_OUT_DIR, "#{name}.json")
      File.open(metadata_filename, "w") do |file|
        JSON.dump(data, file)
      end
      puts "Created: #{metadata_filename}"

      tiles_wide = 8

      sheet_width = tile_width * tiles_wide
      sheet_height = tile_height * (num_tiles / tiles_wide.to_f).ceil
      sheet = ChunkyPNG::Image.new(sheet_width, sheet_height, ChunkyPNG::Color::TRANSPARENT)

      zip_file.glob('tile*.png').each do |tile_file|
        tile_index = /tile(\d+)\.png\Z/.match(tile_file.name)[1].to_i
        image = ChunkyPNG::Image.from_blob(tile_file.get_input_stream.read)
        sheet = sheet.compose(image, 
                              tile_width * (tile_index % tiles_wide),
                              tile_height * (tile_index / tiles_wide))
      end
      image_filename = File.join(ATLAS_OUT_DIR, "#{name}.png")
      sheet.save(image_filename)
      puts "Created: #{image_filename}"
    end
  end
end
