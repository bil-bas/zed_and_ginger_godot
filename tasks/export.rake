require 'fileutils'

PLATFORMS = {
  linux: { name: "Linux X11", file: "zed_and_ginger_linux_x64.bin", exe: true },
  html5: { name: "HTML5", file: "zed_and_ginger.html" },
  windows: { name: "Windows Desktop", file: "zed_and_ginger_win_x64.exe" },
  osx: { name: "Mac OSX", file: "zed_and_ginger_osx_x64.zip" },  
  android: { name: "Android", file: "zed_and_ginger.apk" },
  ios: { name: "IOS", file: "zed_and_ginger.XXX" },
}

if /darwin/ =~ RUBY_PLATFORM
  EXECUTABLE = "../../GodotOSX32.app"
else
  PLATFORMS.delete :ios
  EXECUTABLE = "../../godot/bin/godot_server.server.tools.64"
end

namespace "export" do
  PLATFORMS.each_pair do |platform, data|
    desc "Build #{data[:name]}"
    task platform  do
      FileUtils.cd "assets" do
        puts "=" * 70
        puts
        puts "EXPORTING: #{platform}"
        puts
        puts "=" * 70
        puts
        output = "../export/#{data[:file]}"
        FileUtils.mkdir_p File.dirname(output)

        system "#{EXECUTABLE} -export '#{data[:name]}' #{output}"
        FileUtils.chmod "+x", output if data[:exe]
      end
    end   
  end

  desc "Build all releases"
  task :all do
    PLATFORMS.each_key do |platform|
      Rake::Task[platform].invoke
    end
  end
end