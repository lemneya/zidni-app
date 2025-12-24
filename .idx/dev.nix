{ pkgs, ... }: {
  channel = "unstable";

  packages = [
    pkgs.flutter
    pkgs.git
  ];

  idx.extensions = [
    "Dart-Code.dart-code"
    "Dart-Code.flutter"
  ];
}