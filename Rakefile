require 'fileutils'

Dir["tasks/*.rake"].each { |t| load t }

desc "Edit project"
task :edit do
  system "../godot/bin/godot.x11.tools.64 -editor -path assets"
end

desc "Run project"
task :run do
  system "../godot/bin/godot.x11.tools.64 -path assets root.xscn"
end

desc "Run project fullscreen"
task :run_fs do
  system "../godot/bin/godot.x11.tools.64 -path assets -f root.xscn"
end
