#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint link_kit.podspec` to validate before publishing.
#

pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')

current_dir = Dir.pwd
calling_dir = File.dirname(__FILE__)
project_dir = calling_dir.slice(0..(calling_dir.index('/.symlinks')))
flutter_project_dir = calling_dir.slice(0..(calling_dir.index('/ios/.symlinks')))
cfg = YAML.load_file(File.join(flutter_project_dir, 'pubspec.yaml'))
if cfg['link_kit'] && cfg['link_kit']['deep_link']
    deep_link = cfg['link_kit']['deep_link']
    universal_link = nil
    if cfg['link_kit']['ios']
        universal_link = cfg['link_kit']['ios']['universal_link']
    end
    options = ""
    if universal_link
        options = "-u #{universal_link}"
    end
    system("ruby #{current_dir}/link_setup.rb -d #{deep_link} #{options} -p #{project_dir} -n Runner.xcodeproj")
end

Pod::Spec.new do |s|
  s.name             = 'link_kit'
  s.version          = library_version
  s.summary          = pubspec['description']
  s.description      = pubspec['description']
  s.homepage         = pubspec['homepage']
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # s.default_subspecs = :none
  s.default_subspec = 'vendor'

  s.subspec 'vendor' do |sp|
    definitions_options = ""
    if universal_link
        definitions_options = " LINK_KIT_UNIVERSAL_LINK=\\@\\\"#{universal_link.gsub('/', '\/')}\\\""
    end
    sp.pod_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => "LINK_KIT_DEEP_LINK_SCHEME=\\@\\\"#{URI.parse(deep_link).scheme}\\\"#{definitions_options}"
    }
  end

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
