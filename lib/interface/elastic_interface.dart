abstract class IElasticService {
  Future<bool> addDataToIndex(String index, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> searchData(String index, Map<String, dynamic> query);
  Future<bool> isUsernameExists(String index, String username);
}