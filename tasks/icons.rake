require 'zip'
require 'pp'
require 'json'
require 'chunky_png'

IN_DIR = 'raw/icons'
OUT_DIR = 'assets/icons'

BUTTON_NAMES = %w[start previous next back settings editor quit]

desc 'Process icons (from .pyxel to .png)'
task :icons do
  FileUtils.mkdir_p OUT_DIR

  buttons = size = nil

  Zip::File.open(File.join(IN_DIR, "buttons.pyxel")) do |zip_file|
    layer = zip_file.entries.find {|e| e.name == 'layer0.png' }
    buttons = ChunkyPNG::Image.from_blob(layer.get_input_stream.read)
    size = buttons.height
    buttons = 4.times.map {|i| buttons.crop(i * size, 0, size, size) }
  end

  Zip::File.open(File.join(IN_DIR, "button_icons.pyxel")) do |zip_file|
    layer = zip_file.entries.find {|e| e.name == 'layer0.png' }
    icons = ChunkyPNG::Image.from_blob(layer.get_input_stream.read)
    icons = BUTTON_NAMES.size.times.map {|i| icons.crop(0, i * size, size, size) }

    BUTTON_NAMES.each.with_index do |name, i|
      buttons.each.with_index do |button, j|
        icon = button.compose(icons[i], 0, 0)
        image_filename = File.join(OUT_DIR, "#{name}_#{j}.png")
        icon.save(image_filename)
        puts "Created: #{image_filename}"
      end
    end
  end

  Zip::File.open(File.join(IN_DIR, "play.pyxel")) do |zip_file|
    layer = zip_file.entries.find {|e| e.name == 'layer0.png' }
    buttons = ChunkyPNG::Image.from_blob(layer.get_input_stream.read)
    width = buttons.width / 4
    height = buttons.height
    4.times do |i|
      button = buttons.crop(i * width, 0, width, height)
      image_filename = File.join(OUT_DIR, "play_#{i}.png")
      button.save(image_filename)
      puts "Created: #{image_filename}"
    end
  end
end
