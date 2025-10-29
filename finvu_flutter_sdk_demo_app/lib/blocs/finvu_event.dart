// Events
import 'package:equatable/equatable.dart';
import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';

abstract class FinvuEvent extends Equatable {
  const FinvuEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSDK extends FinvuEvent {
  final FinvuConfig config;

  const InitializeSDK(this.config);

  @override
  List<Object?> get props => [config];
}

class ConnectToService extends FinvuEvent {}

class DisconnectFromService extends FinvuEvent {}

class LoginWithCredentials extends FinvuEvent {
  final String userHandle;
  final String mobileNumber;
  final String consentHandleId;

  const LoginWithCredentials({
    required this.userHandle,
    required this.mobileNumber,
    required this.consentHandleId,
  });

  @override
  List<Object?> get props => [userHandle, mobileNumber, consentHandleId];
}

class VerifyOtp extends FinvuEvent {
  final String otp;
  final String otpReference;
  final String? consentHandleId;

  const VerifyOtp(
      {required this.otp, required this.otpReference, this.consentHandleId});

  @override
  List<Object?> get props => [otp, otpReference, consentHandleId];
}

class FetchLinkedAccounts extends FinvuEvent {}

class GetConsentDetails extends FinvuEvent {
  final String consentHandleId;

  const GetConsentDetails(this.consentHandleId);

  @override
  List<Object?> get props => [consentHandleId];
}

class ApproveConsent extends FinvuEvent {
  final FinvuConsentRequestDetailInfo consentDetail;
  final List<FinvuLinkedAccountDetailsInfo> accounts;

  const ApproveConsent({
    required this.consentDetail,
    required this.accounts,
  });

  @override
  List<Object?> get props => [consentDetail, accounts];
}

class DenyConsent extends FinvuEvent {
  final FinvuConsentRequestDetailInfo consentDetail;

  const DenyConsent(this.consentDetail);

  @override
  List<Object?> get props => [consentDetail];
}

class LogoutAndDisconect extends FinvuEvent {}

class UpdateUserData extends FinvuEvent {
  final String? mobileNumber;
  final String? userHandle;
  final String? consentHandleId;

  const UpdateUserData({
    this.mobileNumber,
    this.userHandle,
    this.consentHandleId,
  });

  @override
  List<Object?> get props => [mobileNumber, userHandle, consentHandleId];
}

// New events for FIP discovery and account linking
class FetchFipsList extends FinvuEvent {}

class DiscoverAccounts extends FinvuEvent {
  final String fipId;
  final List<String> fipFiTypes;
  final List<FinvuTypeIdentifierInfo> identifiers;

  const DiscoverAccounts({
    required this.fipId,
    required this.fipFiTypes,
    required this.identifiers,
  });

  @override
  List<Object?> get props => [fipId, fipFiTypes, identifiers];
}

class LinkAccounts extends FinvuEvent {
  final List<FinvuDiscoveredAccountInfo> accounts;
  final FinvuFIPDetails fipDetails;

  const LinkAccounts({
    required this.accounts,
    required this.fipDetails,
  });

  @override
  List<Object?> get props => [accounts, fipDetails];
}

class ConfirmAccountLinking extends FinvuEvent {
  final FinvuAccountLinkingRequestReference linkingReference;
  final String otp;

  const ConfirmAccountLinking({
    required this.linkingReference,
    required this.otp,
  });

  @override
  List<Object?> get props => [linkingReference, otp];
}

class ClearDiscoveredAccounts extends FinvuEvent {}
