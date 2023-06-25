import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';

class HabiticaData {
  late String user_id;
  late String api_key;
  late Uri api_url;
  late http.Client habitica_session;
  late List<List<dynamic>> csv_file;
  late Map<String, String> header;

  HabiticaData(this.user_id, this.api_key) {
    api_url = Uri.parse('https://habitica.com/api/v3');
    habitica_session = http.Client();
    header = {
      "x-api-user": user_id,
      "x-api-key": api_key,
      "Content-Type": "application/json"
    };
  }

  List<List<String>> convertToNestedList(String input) {
    List<List<String>> nestedList = [];
    List<String> lines =
        input.replaceAll('[', '').replaceAll(']', '').split('\n');

    for (int i = 0; i < lines.length; i++) {
      List<String> values = lines[i].split(', ');
      nestedList.add(values);
    }

    return nestedList;
  }

  Future<List<List<dynamic>>> getUserData() async {
    final response = await habitica_session.get(
        Uri.parse('https://habitica.com/export/history.csv'),
        headers: header);

    if (response.statusCode != 200) {
      throw Exception('Failed to load user data: ${response.statusCode}');
    }
    final csvData = response.body;
    List<List<dynamic>> csvFile = const CsvToListConverter().convert(csvData);
    csvFile = convertToNestedList(csvFile.toString());
    // Remove header row
    csvFile.removeAt(0);
    // Remove unwanted columns (Task ID, Task Type, Value)
    csvFile = csvFile.map((row) => [row[0], row[3]]).toList();

    //Sort by date in ascending order
    csvFile.sort((a, b) => DateTime.parse(a[1] as String)
        .compareTo(DateTime.parse(b[1] as String)));

    csv_file = csvFile;

    return csv_file;
  }

  List<List<dynamic>> getDate(String targetDate) {
    final filteredData = csv_file
        .where((row) => (row[1] as String).startsWith(targetDate))
        .toList();
    return filteredData;
  }

  List getPastDates(String targetDateString, int numDays) {
    final targetDate = DateFormat('yyyy-MM-dd').parse(targetDateString);
    final startDate = targetDate.subtract(Duration(days: numDays));

    final filteredData = csv_file.where((row) {
      final rowDate = DateFormat('yyyy-MM-dd').parse(row[1] as String);
      return rowDate.isAfter(startDate);
    }).toList();
    return filteredData;
  }

  Future<String> execute({String? target_date, int num_days = 5}) async {
    String result = '';
    target_date ??= DateFormat('yyyy-MM-dd').format(DateTime.now());
    await getUserData();
    final habiticaData = getPastDates(target_date, num_days);
    // Append the item to the result string
    for (var item in habiticaData) {
      result += '\n';
      for (var i in item) {
        result += i.toString();
        result += ' ';
      }
    }

    return result;
  }
}
// Example of how to use the habitica
// void main() async {
//   final user_id =
//       'USERID'; // Replace with your Habitica user ID
//   final api_key =
//       'APIKEY'; // Replace with your Habitica API key

//   final habiticaData = HabiticaData(user_id, api_key);
//   final habits = await habiticaData.execute();

//   print('Habits: $habits');
// }
