import 'package:weatherappfrontend/bar%20graph/individual_bar.dart';

class BarData {
  final double minTemp;
  final double maxTemp;
  final double avgTemp;

  BarData(this.minTemp, this.maxTemp, this.avgTemp) {
    // Ensure values are not negative
    if (minTemp < 0 || maxTemp < 0 || avgTemp < 0) {
      throw Exception("Temperature values cannot be negative.");
    }
  }

  List<IndividualBar> barData = [];
  
  void initializeBarData() {
    barData = [
      IndividualBar(0, minTemp),
      IndividualBar(1, maxTemp),
      IndividualBar(2, avgTemp),
    ];
  }
}
