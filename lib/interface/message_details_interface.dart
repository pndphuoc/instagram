abstract class IMessageDetailsService {
  Future<void> updateStatus({required String conversationId, required String senderId});
  Stream<String> getMessageStatus({required String conversationId, required String messageId});
}