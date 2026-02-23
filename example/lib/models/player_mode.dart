enum PlayerMode { custom, bunnyBuiltIn }

extension PlayerModeExtension on PlayerMode {
  String get label {
    switch (this) {
      case PlayerMode.custom:
        return 'Custom Player';
      case PlayerMode.bunnyBuiltIn:
        return 'Bunny Built-in';
    }
  }
}
