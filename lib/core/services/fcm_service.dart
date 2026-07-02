import 'package:supabase_flutter/supabase_flutter.dart';

// FCM Service - Stub for push token management
// TODO: Initialize Firebase and configure Firebase Messaging (FCM) when push notifications are fully implemented.
// TODO: Retrieve the actual FCM token from FirebaseMessaging.instance.getToken() and call saveToken().
class FcmService {
  static Future<void> saveToken(String fcmToken, String platform) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client.from('mobile_push_tokens').upsert({
      'user_id': userId,
      'fcm_token': fcmToken,
      'platform': platform,
    }, onConflict: 'user_id,fcm_token');
  }

  static Future<void> removeToken(String fcmToken) async {
    await Supabase.instance.client
        .from('mobile_push_tokens')
        .delete()
        .eq('fcm_token', fcmToken);
  }
}
