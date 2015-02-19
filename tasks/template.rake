require 'fileutils'

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
            system "scons platform=#{platform} target=#{target_for_release(release)}"
          end
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
          
          system "scons platform=android target=#{target_for_release(release)}"

          FileUtils.mkdir_p "platform/android/java/libs/armeabi"
          FileUtils.cp "bin/libgodot.android.opt.#{release}.so", "platform/android/java/libs/armeabi/libgodot_android.so"
          FileUtils.cd "platform/android/java/" do
            system 'ant release'
          end
          FileUtils.cp "platform/android/java/bin/Godot-release-unsigned.apk", "bin/android_#{release}.apk"
        end
      end
    end
  end

  desc "Build all debug templates"
  task :debug => ["x11:debug", "android:debug"]

  desc "Build all release templates"
  task :release => ["x11:release", "android:release"]
end