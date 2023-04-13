abstract class IElasticService {
  Future<List<Map<String, dynamic>>> searchData(String index, Map<String, dynamic> query);
  Future<bool> isUsernameExists(String username);
}