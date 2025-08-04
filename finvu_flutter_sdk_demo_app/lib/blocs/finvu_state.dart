import 'package:equatable/equatable.dart';
import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';

abstract class FinvuState extends Equatable {
  const FinvuState();

  @override
  List<Object?> get props => [];

  bool get isLoading => false;
}

class FinvuInitial extends FinvuState {}

class FinvuLoading extends FinvuState {
  @override
  final bool isLoading;
  final String message;

  const FinvuLoading(this.message, this.isLoading);

  @override
  List<Object?> get props => [message, isLoading];
}

class FinvuSuccess extends FinvuState {
  @override
  final bool isLoading;
  final String message;
  final Map<String, dynamic>? data;

  const FinvuSuccess(this.message, this.isLoading, {this.data});

  @override
  List<Object?> get props => [message, data, isLoading];
}

class FinvuError extends FinvuState {
  @override
  final bool isLoading;
  final String message;

  const FinvuError(this.message, this.isLoading);

  @override
  List<Object?> get props => [message, isLoading];
}

class FinvuConnected extends FinvuState {
  @override
  final bool isLoading;
  final String? message;
  final bool isConnected;
  final bool isLoggedIn;
  final String? userId;
  final String? mobileNumber;
  final String? userHandle;
  final String? consentHandleId;
  final List<FinvuLinkedAccountDetailsInfo> linkedAccounts;
  final List<FinvuDiscoveredAccountInfo> discoveredAccounts;
  final List<FinvuFIPInfo> allAvailableFips;
  final FinvuConsentRequestDetailInfo? consentDetails;
  final String? otpReference;
  final FinvuAccountLinkingRequestReference? linkingReference;

  const FinvuConnected({
    required this.isLoading,
    required this.message,
    required this.isConnected,
    required this.isLoggedIn,
    this.userId,
    this.mobileNumber,
    this.userHandle,
    this.consentHandleId,
    this.linkedAccounts = const [],
    this.discoveredAccounts = const [],
    this.allAvailableFips = const [],
    this.consentDetails,
    this.otpReference,
    this.linkingReference,
  });

  @override
  List<Object?> get props => [
        isLoading,
        message,
        isConnected,
        isLoggedIn,
        userId,
        mobileNumber,
        userHandle,
        consentHandleId,
        linkedAccounts,
        discoveredAccounts,
        allAvailableFips,
        consentDetails,
        otpReference,
        linkingReference,
      ];

  FinvuConnected copyWith({
    required bool isLoading,
    String? message,
    bool? isConnected,
    bool? isLoggedIn,
    String? userId,
    String? mobileNumber,
    String? userHandle,
    String? consentHandleId,
    List<FinvuLinkedAccountDetailsInfo>? linkedAccounts,
    List<FinvuDiscoveredAccountInfo>? discoveredAccounts,
    List<FinvuFIPInfo>? allAvailableFips,
    FinvuConsentRequestDetailInfo? consentDetails,
    String? otpReference,
    FinvuAccountLinkingRequestReference? linkingReference,
  }) {
    return FinvuConnected(
      isLoading: isLoading,
      message: message ?? this.message,
      isConnected: isConnected ?? this.isConnected,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      userHandle: userHandle ?? this.userHandle,
      consentHandleId: consentHandleId ?? this.consentHandleId,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
      discoveredAccounts: discoveredAccounts ?? this.discoveredAccounts,
      consentDetails: consentDetails ?? this.consentDetails,
      otpReference: otpReference ?? this.otpReference,
      linkingReference: linkingReference ?? this.linkingReference,
      allAvailableFips: allAvailableFips ?? this.allAvailableFips,
    );
  }
}
