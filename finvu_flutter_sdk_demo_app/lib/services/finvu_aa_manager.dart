import 'dart:async';

import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_handle_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';

class FinvuResult<T> {
  final bool isSuccess;
  final T? data;
  final FinvuError? error;

  const FinvuResult({
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory FinvuResult.success(T data) {
    return FinvuResult(isSuccess: true, data: data);
  }

  factory FinvuResult.failure(FinvuError error) {
    return FinvuResult(isSuccess: false, error: error);
  }
}

class FinvuError {
  final String message;
  final String? code;

  const FinvuError({required this.message, this.code});
}

class FinvuEvent {
  final String type;
  final Map<String, dynamic> data;

  const FinvuEvent({required this.type, required this.data});
}

class FinvuAAManager {
  static final FinvuAAManager _instance = FinvuAAManager._internal();
  factory FinvuAAManager() => _instance;
  FinvuAAManager._internal();
  final FinvuManager _finvuManager = FinvuManager();

  bool _isInitialized = false;
  bool _isConnected = false;

  // Initialize SDK
  Future<FinvuResult<String>> initializeWith(FinvuConfig config) async {
    try {
      final finvuAAConfig = FinvuConfig(
          finvuEndpoint: config.finvuEndpoint,
          certificatePins: config.certificatePins,
          finvuSnaAuthConfig: config.finvuSnaAuthConfig);
      _finvuManager.initialize(finvuAAConfig);
      _isInitialized = true;
      return FinvuResult.success('Initialized successfully');
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Connect to service
  Future<FinvuResult<String>> connect() async {
    try {
      if (!_isInitialized) {
        return FinvuResult.failure(
            const FinvuError(message: 'SDK not initialized'));
      }

      await _finvuManager.connect();

      _isConnected = true;

      return FinvuResult.success('Connected successfully');
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Disconnect from service
  Future<FinvuResult<String>> disconnect() async {
    try {
      _finvuManager.disconnect();
      _isConnected = false;
      return FinvuResult.success('Disconnected successfully');
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Check connection status
  Future<FinvuResult<bool>> isConnected() async {
    try {
      _isConnected = await _finvuManager.isConnected();
      return FinvuResult.success(_isConnected);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Check session status
  Future<FinvuResult<bool>> hasSession() async {
    try {
      final isAAsessionActive = await _finvuManager.hasSession();
      return FinvuResult.success(isAAsessionActive);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Login with username or mobile number
  Future<FinvuResult<FinvuLoginOtpReference>> loginWithUsernameOrMobileNumber(
    String userHandle,
    String mobileNumber,
    String consentHandleId,
  ) async {
    try {
      if (!_isConnected) {
        return FinvuResult.failure(
            const FinvuError(message: 'Not connected to service'));
      }

      final FinvuLoginOtpReference result =
          await _finvuManager.loginWithUsernameOrMobileNumberAndConsentHandle(
        userHandle,
        mobileNumber,
        consentHandleId,
      );

      return FinvuResult.success(result);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Verify login OTP
  Future<FinvuResult<FinvuHandleInfo>> verifyLoginOtp(
    String otp,
    String otpReference,
  ) async {
    try {
      final FinvuHandleInfo result =
          await _finvuManager.verifyLoginOtp(otp, otpReference);
      return FinvuResult.success(result);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Fetch linked accounts
  Future<FinvuResult<List<FinvuLinkedAccountDetailsInfo>>>
      fetchLinkedAccounts() async {
    try {
      final result = await _finvuManager.fetchLinkedAccounts();

      return FinvuResult.success(result);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Get consent request details
  Future<FinvuResult<FinvuConsentRequestDetailInfo>> getConsentRequestDetails(
    String consentHandleId,
  ) async {
    try {
      final result =
          await _finvuManager.getConsentRequestDetails(consentHandleId);

      return FinvuResult.success(result);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Approve consent request
  Future<FinvuResult<FinvuProcessConsentRequestResponse>> approveConsentRequest(
    FinvuConsentRequestDetailInfo consentDetail,
    List<FinvuLinkedAccountDetailsInfo> accounts,
  ) async {
    try {
      final result =
          await _finvuManager.approveConsentRequest(consentDetail, accounts);

      return FinvuResult.success(result);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Deny consent request
  Future<FinvuResult<FinvuProcessConsentRequestResponse>> denyConsentRequest(
    FinvuConsentRequestDetailInfo consentDetail,
  ) async {
    try {
      final result = await _finvuManager.denyConsentRequest(consentDetail);

      return FinvuResult.success(result);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Logout
  Future<FinvuResult<String>> logout() async {
    try {
      await _finvuManager.logout();
      return FinvuResult.success('Logged out successfully');
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  // Account linking methods
  Future<FinvuResult<List<FinvuFIPInfo>>> fipsAllFIPOptions() async {
    try {
      final result = await _finvuManager.fipsAllFIPOptions();
      return FinvuResult.success(result);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  Future<FinvuResult<FinvuFIPDetails>> fetchFipDetails(
    String fipId,
  ) async {
    try {
      final result = await _finvuManager.fetchFIPDetails(fipId);

      return FinvuResult.success(result);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  Future<FinvuResult<List<FinvuDiscoveredAccountInfo>>> discoverAccounts(
    String fipId,
    List<String> fipFiTypes,
    List<FinvuTypeIdentifierInfo> identifiers,
  ) async {
    try {
      final result =
          await _finvuManager.discoverAccounts(fipId, fipFiTypes, identifiers);

      return FinvuResult.success(result);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  Future<FinvuResult<FinvuAccountLinkingRequestReference>> linkAccounts(
    List<FinvuDiscoveredAccountInfo> accounts,
    FinvuFIPDetails fipDetails,
  ) async {
    try {
      final result = await _finvuManager.linkAccounts(
        fipDetails,
        accounts,
      );
      return FinvuResult.success(result);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }

  Future<FinvuResult<FinvuConfirmAccountLinkingInfo>> confirmAccountLinking(
    FinvuAccountLinkingRequestReference referenceNumber,
    String otp,
  ) async {
    try {
      final result =
          await _finvuManager.confirmAccountLinking(referenceNumber, otp);

      return FinvuResult.success(result);
    } catch (error) {
      return FinvuResult.failure(FinvuError(message: error.toString()));
    }
  }
}
