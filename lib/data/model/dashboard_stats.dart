class DashboardStats {
  final int jamiYoshlar;
  final int ogilBolalar;
  final int qizBolalar;

  DashboardStats({
    required this.jamiYoshlar,
    required this.ogilBolalar,
    required this.qizBolalar,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      jamiYoshlar: json['jamiYoshlar'] ?? 0,
      ogilBolalar: json['ogilBolalar'] ?? 0,
      qizBolalar: json['qizBolalar'] ?? 0,
    );
  }
}
