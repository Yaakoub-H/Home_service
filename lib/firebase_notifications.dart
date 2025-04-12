import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class MyFireBaseCloudMessaging {
  static Future<String> getAccessToken() async {
    final serverToken = {
      "type": "service_account",
      "project_id": "homeservices-3e4ec",
      "private_key_id": "9e73f6ce430613e4ea9130000b11aec55a19f9c1",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDwCcYTxkUk6WSk\nMSMppNsT7g0LQPPsC3ENJj7+R94IaP4zEs9sxIqCi6jrFNA4RcblQGQUCLWMRbwy\nPqWXMZ7w991Bm3xIymYN9CXGyS79pC41ytEdhWPJJu3/wmfUla3mD2ezRFrprWAR\nCWyk48cfcSjuKrBFwZKcktqHlZjDgG7KggfS+jTihnlDqi/8IjqIzVbXlkEEYuvD\n3urNvmM6gz833nOdthYzFwwvinYQCT8ySgvbHsScRAnFxcnGR3c4hqfZlCEfkRvI\njOvBHPIiacE4yhrhmrjFls0Fh/QCxPMXPLLmXEqCFlj98Ln2lZdVKKze2wGb9DsX\nDBA8KiFpAgMBAAECggEAAwFG/DMOVvxmyM6KAUN1TG8EtXPNYQuOSlBL0LMeg5OM\n6ViMt1RQVdBEcYlnY7CDDAgd40lt9UuYaxpjATJwf2PFpcSdbiS+ElP7PfnWyhff\no1WlxsKcvExfk7bDVDikXnTxIvVjqmsD5GuY5QlU9bfOuLOuVM2sA8Dkq3a/h0hW\nHmQcj2OaSDwoorsNDlOwSEjDtVB4qfU5XmpRlWve82ARM9HhGiQnAHGF2s8EqTcO\n1O2XulFExnEN+Vhs63q7cC2Pos5iyF+56YoR+T5lVioE/o6rgt+u4ZAtWWuWgNOV\nlSQQM/zi7zAJkJp1NIf88OEPAYH6JElKpaGfKVXcYQKBgQD87MrOMti5u7x0yglk\n2UEez3O3nItwqgvuaHsdsBday0r3mldk4i0gr3DgseOiJ1JXrB/V6lGRHOmn0X6n\nkHw8Em8XTL5MH0ULtRPPOnUP2WCW6rByUUXDVyuyB4+fVWo/WLYhvghCoJiPolok\nffFfkAo6ht3+H+330am8kkFVmwKBgQDy9N9aXua2+PUDb1MzRQoJSc2ysLlY4udJ\nU5UrxoZT1VDsQvrX8sDn4GZarTko/BQU4E/dffFDZa5uPbjWGv+2OBX1ZK5eH/cI\neEwxZzMBUCuubJNTxAhqXT0gUXBzMhyEFwsj3Pae4NdqTUwao/PqHfFF/3t1dxH3\nnIdiReF3SwKBgQCbOUP6KpCB5KrzTi9XulHR8+WD0UpumZ368hplDPY4Xb2jmhB6\ntKiXf7SZ4fLfSJyre9KJ+WWX1pO7z8GYWv8z6uhM92du1l4MolQHAUxorrMty9kA\nP8q96NjDSQqm8cfkGrCkorj1ExSuSihibvzc9kygwLarSLNGPWGbfnMkcwKBgQCo\nVcHre5WfcR9SIfAjtdIeXWSISqohTBW0WJUin4qyyzomeMIUnb3K60//w8W2//Fq\nBYFQldJ0QB97gohu0IYcWv/b5sZpsPwYgkFIeZh9cG7Ti6cIgurRx4hyu/qN1kqr\nusudLZwyuNaIcMYqLy7xJ43kUf/Yg4ePaITlMkXlwQKBgQCvaMcNYY7GzKRQbokZ\nY7hdj95nO/KgjCr2a39AdkZR6FeuAjG5c3o/DwCvCzfS9hSE5QneADCpiOBMaFay\nZpYZiFvl8R+IAiFytN6S4u+e83PFVK0Qv4n6/TA/ng12cRiAN0XJRuOiGCWQXCAL\nv7lotApc70lVkPDcqdI8qWe6+w==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-fbsvc@homeservices-3e4ec.iam.gserviceaccount.com",
      "client_id": "105582216871402236873",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40homeservices-3e4ec.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com",
    };

    List<String> scopes = [
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    // Get access token
    auth.AccessCredentials credentials = await auth
        .obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serverToken),
          scopes,
          http.Client(),
        );
    return credentials.accessToken.data;
  }

  static Future<void> sendNotificationToUser(
    String deviceToken,
    String receiverUid,
    BuildContext context,
    String title,
    String description,
    String notificationID,
  ) async {
    final String serverKey = await getAccessToken();
    final postUrl =
        'https://fcm.googleapis.com/v1/projects/homeservices-3e4ec/messages:send';

    final Map<String, dynamic> message = {
      "message": {
        "token": deviceToken,
        "notification": {"title": title, "body": description},
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
          "notificationID": notificationID,
        },
      },
    };

    final response = await http.post(
      Uri.parse(postUrl),
      body: jsonEncode(message),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
    );

    if (response.statusCode == 200) {
      print('Notification sent');

      // Store the notification in Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'userUid': receiverUid,
        'title': title,
        'description': description,
        'notificationID': notificationID,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      print('Notification not sent');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
