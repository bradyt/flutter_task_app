import 'dart:io';

class Size {
  Size(this.platform, this.filename, this.dimensions);

  String platform;
  String dimensions;
  String filename;
}

void main() {
  var sizes = [
    Size('ios', 'Icon-App-1024x1024@1x.png', '1024x1024'),
    Size('ios', 'Icon-App-20x20@1x.png', '20x20'),
    Size('ios', 'Icon-App-20x20@2x.png', '40x40'),
    Size('ios', 'Icon-App-20x20@3x.png', '60x60'),
    Size('ios', 'Icon-App-29x29@1x.png', '29x29'),
    Size('ios', 'Icon-App-29x29@2x.png', '58x58'),
    Size('ios', 'Icon-App-29x29@3x.png', '87x87'),
    Size('ios', 'Icon-App-40x40@1x.png', '40x40'),
    Size('ios', 'Icon-App-40x40@2x.png', '80x80'),
    Size('ios', 'Icon-App-40x40@3x.png', '120x120'),
    Size('ios', 'Icon-App-60x60@2x.png', '120x120'),
    Size('ios', 'Icon-App-60x60@3x.png', '180x180'),
    Size('ios', 'Icon-App-76x76@1x.png', '76x76'),
    Size('ios', 'Icon-App-76x76@2x.png', '152x152'),
    Size('ios', 'Icon-App-83.5x83.5@2x.png', '167x167'),
    Size('macos', 'app_icon_1024.png', '1024x1024'),
    Size('macos', 'app_icon_128.png', '128x128'),
    Size('macos', 'app_icon_16.png', '16x16'),
    Size('macos', 'app_icon_256.png', '256x256'),
    Size('macos', 'app_icon_32.png', '32x32'),
    Size('macos', 'app_icon_512.png', '512x512'),
    Size('macos', 'app_icon_64.png', '64x64'),
  ];

  <String, String>{
    '24x24': '../android/app/src/main/res/mipmap-hdpi/ic_launcher.png',
    '36x36': '../android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
    '48x48': '../android/app/src/main/res/mipmap-xhdpi/ic_launcher.png',
    '72x72': '../android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png',
    '96x96': '../android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
    // ignore: avoid_function_literals_in_foreach_calls
  }.entries.forEach((entry) => Process.run(
        'convert',
        [
          'noun_checkmark_1763484.svg',
          '-resize',
          entry.key,
          entry.value,
        ],
      ));

  for (var size in sizes) {
    Process.run(
      'convert',
      [
        'noun_checkmark_1763484.svg',
        '-resize',
        size.dimensions,
        '../${size.platform}/Runner/Assets.xcassets/AppIcon.appiconset/${size.filename}',
      ],
    );
  }
}
