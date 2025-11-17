import 'package:finvu_flutter_sdk/finvu_event.dart';
import 'package:finvu_flutter_sdk/finvu_event_listener.dart';

/// Example event listener implementation for the demo app
class FinvuEventHandler implements FinvuEventListener {
  @override
  void onEvent(FinvuEvent event) {
    print('📊 Finvu Event: ${event.eventName}');
    print('   Category: ${event.eventCategory}');
    print('   Timestamp: ${event.timestamp}');
    print('   SDK Version: ${event.aaSdkVersion}');

    if (event.params.isNotEmpty) {
      print('   Params: ${event.params}');
    }

    // Handle specific events
    switch (event.eventName) {
      case 'WEBSOCKET_CONNECTED':
        print('✅ WebSocket connected successfully');
        break;

      case 'WEBSOCKET_DISCONNECTED':
        print('❌ WebSocket disconnected');
        break;

      case 'LOGIN_INITIATED':
        print('🔐 Login initiated');
        break;

      case 'LOGIN_OTP_GENERATED':
        print('📱 OTP generated');
        break;

      case 'LOGIN_OTP_VERIFIED':
        print('✅ Login OTP verified');
        break;

      case 'LOGIN_OTP_FAILED':
        print('❌ Login OTP failed');
        break;

      case 'DISCOVERY_INITIATED':
        print('🔍 Account discovery initiated');
        break;

      case 'ACCOUNTS_DISCOVERED':
        final count = event.getParam<int>('count');
        print('✅ Discovered $count accounts');
        break;

      case 'ACCOUNTS_NOT_DISCOVERED':
        print('⚠️ No accounts discovered');
        break;

      case 'LINKING_INITIATED':
        final fipId = event.getParam<String>('fipId');
        print('🔗 Account linking initiated for FIP: $fipId');
        break;

      case 'LINKING_SUCCESS':
        final count = event.getParam<int>('count');
        print('✅ Successfully linked $count accounts');
        break;

      case 'LINKING_FAILURE':
        print('❌ Account linking failed');
        break;

      case 'LINKED_ACCOUNTS_SUMMARY':
        final fips = event.getParam<List>('fips');
        final fiTypes = event.getParam<List>('fiTypes');
        final count = event.getParam<int>('count');
        print('📋 Linked Accounts Summary:');
        print('   Count: $count');
        print('   FIPs: $fips');
        print('   FI Types: $fiTypes');
        break;

      case 'CONSENT_APPROVED':
        print('✅ Consent approved by user');
        break;

      case 'CONSENT_DENIED':
        print('❌ Consent denied by user');
        break;

      case 'SESSION_ERROR':
        final error = event.getParam<String>('error');
        print('⚠️ Session error: $error');
        break;

      case 'SESSION_FAILURE':
        print('❌ Session failure');
        break;

      default:
        print('ℹ️ Other event: ${event.eventName}');
    }

    print(''); // Empty line for readability
  }
}
