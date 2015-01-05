require 'fileutils'

GODOT_LINUX = "../linux_server-1.0stable.64"
GODOT_OSX = "../GodotOSX32.app"

PLATFORMS = {
  linux: { name: "Linux X11", file: "zed_and_ginger_linux_x64.bin", exe: true },
  html5: { name: "HTML5", file: "zed_and_ginger.html" },
  windows: { name: "Windows Desktop", file: "zed_and_ginger_win_x64.exe" },
  osx: { name: "Mac OSX", file: "zed_and_ginger_osx_x64.zip" },  
  android: { name: "Android", file: "zed_and_ginger.apk" },
  ios: { name: "IOS", file: "zed_and_ginger.XXX" },
}

PLATFORMS.delete :ios unless /darwin/ =~ RUBY_PLATFORM

PLATFORMS.each_pair do |platform, data|
  desc "Build #{data[:name]}"
  task platform do
    executable = GODOT_LINUX
    output = "../export/#{data[:file]}"
    system "#{executable} -export '#{data[:name]}' #{output}"
    FileUtils.chmod "+x", output if data[:exe]
  end   
end

task :default do
  PLATFORMS.each_key do |platform|
    Rake::Task[platform].invoke
  end
end

