require 'fileutils'

NUM_CORES = 8

def target_for_release(release)
  release == :release ? "release" : "release_debug"
end

namespace :template do
  [:x11].each do |platform|
    namespace platform do
      [:release, :debug].each do |release|
        desc "Build #{platform} export template: #{release.upcase}"
        task release do
          FileUtils.cd "../godot" do
            system "scons --jobs=#{NUM_CORES} platform=#{platform} target=#{target_for_release(release)}"
            FileUtils.cp "bin/godot.x11.opt.tools.64", File.expand_path("~/.godot/templates/linux_64_#{release}")
          end
        end
      end
    end
  end

  namespace :javascript do
    [:release, :debug].each do |release|
      desc "Build HTML5 template: #{release.upcase}"
      task release do
        FileUtils.cd "../godot" do
          ENV["EMSCRIPTEN_ROOT"] = "/home/spooner/Documents/emsdk_portable/emscripten/master"
          system "scons --jobs=#{NUM_CORES} platform=javascript target=#{target_for_release(release)}"
          FileUtils.cp "bin/godot.javascript.opt.#{release}.html", "godot.html"
          FileUtils.cp "bin/godot.javascript.opt.#{release}.js", "godot.js"
          FileUtils.cp "tools/html_fs/filesystem.js", "."
          system "7z a javascript_#{release}.zip godot.html godot.js filesystem.js"
          FileUtils.mv "javascript_#{release}.zip", File.expand_path("~/.godot/templates/")
          FileUtils.rm "godot.js"
          FileUtils.rm "godot.html"
          FileUtils.rm "filesystem.js"
        end
      end
    end
  end

  namespace :android do
    [:release, :debug].each do |release|
      desc "Build Android export template: #{release.upcase}"
      task release do
        FileUtils.cd "../godot" do
          ENV["ANDROID_HOME"] = "/media/neckbeard/open-source/godot/android-sdk-linux"
          ENV["ANDROID_NDK_ROOT"] = "/media/neckbeard/open-source/godot/android-ndk-r10d"
          
          system "scons --jobs=#{NUM_CORES} platform=android target=#{target_for_release(release)}"

          FileUtils.mkdir_p "platform/android/java/libs/armeabi"
          FileUtils.cp "bin/libgodot.android.opt.#{release}.so", "platform/android/java/libs/armeabi/libgodot_android.so"
          FileUtils.cd "platform/android/java/" do
            system 'ant release'
          end
          FileUtils.cp "platform/android/java/bin/Godot-release-unsigned.apk", File.expand_path("~/.godot/templates/android_#{release}.apk")
        end
      end
    end
  end

  desc "Build all debug templates"
  task :debug => ["x11:debug", "android:debug", "javascript:debug"]

  desc "Build all release templates"
  task :release => ["x11:release", "android:release", "javascript:release"]
end