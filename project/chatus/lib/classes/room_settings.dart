class RoomSettings {
  // 싱글톤 패턴으로 전역 접근 가능하게 함
  static final RoomSettings _instance = RoomSettings._internal();
  factory RoomSettings() => _instance;
  RoomSettings._internal();

  double myVolume = 1;
  double otherVolume = 1;
}
