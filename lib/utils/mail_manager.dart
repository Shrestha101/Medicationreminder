/*import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_io.dart' as auth;

const String _gmailScope = gmail.GmailApi.GmailSendScope;

Future<void> sendEmail() async {
  final String clientId = 'your-client-id';
  final String clientSecret = 'your-client-secret';
  final String refreshToken = 'your-refresh-token';
  final String accessToken = 'your-access-token';
  final String userId = 'me';

  final auth.ClientId client = auth.ClientId(clientId, clientSecret);
  final auth.TokenRefreshClient tokenRefreshClient =
  auth.TokenRefreshClient(client, refreshToken, accessToken);
  final auth.AuthClient authClient =
  auth.authenticatedClient(client, tokenRefreshClient);
  final gmail.GmailApi gmailApi = gmail.GmailApi(authClient);

  final gmail.Message message = gmail.Message();
  message.raw = base64.urlSafeEncode(utf8.encode(
      'To: recipient@example.com\n'
          'Subject: Example Subject\n'
          '\n'
          'Example Body\n'));

  final gmail.Message response =
  await gmailApi.users.messages.send(message, userId);
  print('Email sent successfully: ${response.id}');
}
*/