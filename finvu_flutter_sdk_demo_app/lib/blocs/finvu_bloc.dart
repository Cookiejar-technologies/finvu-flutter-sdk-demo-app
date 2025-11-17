import 'dart:developer';

import 'package:finvu_flutter_sdk/finvu_event_definition.dart';
import 'package:finvu_flutter_sdk_demo_app/blocs/finvu_event.dart';
import 'package:finvu_flutter_sdk_demo_app/blocs/finvu_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/finvu_aa_manager.dart' hide FinvuError;
import 'package:finvu_flutter_sdk/finvu_event.dart' as sdk;
import 'package:finvu_flutter_sdk/finvu_event_listener.dart';

// Bloc
class FinvuBloc extends Bloc<FinvuEvent, FinvuState> {
  final FinvuAAManager _finvuAAManager = FinvuAAManager();
  final _SdkEventListener _sdkEventListener = _SdkEventListener();

  FinvuBloc() : super(FinvuInitial()) {
    // Set up SDK event listener
    _sdkEventListener._bloc = this;
    _finvuAAManager.addEventListener(_sdkEventListener);
    _finvuAAManager.setEventsEnabled(true);

    // Register custom events
    final customEvents = {
      'CUSTOM_BUTTON_CLICKED': FinvuEventDefinition(
        category: 'ui',
        stage: 'interaction',
      ),
      'CUSTOM_API_CALLED': FinvuEventDefinition(
        category: 'api',
        stage: 'request',
      ),
      'CUSTOM_FIP_SELECTED': FinvuEventDefinition(
        category: 'ui',
        fipId: 'FIP123',
        fips: ['FIP123', 'FIP456'],
        fiTypes: ['DEPOSIT', 'SAVINGS'],
      ),
    };

    _finvuAAManager.registerCustomEvents(customEvents);
    log('Custom events registered successfully');

    // Register aliases for standard events
    final aliases = {
      'LOGIN_OTP_GENERATED': 'otp_sent',
      'WEBSOCKET_CONNECTED': 'connection_established',
      'LOGIN_INITIATED': 'user_login_started',
      'LOGIN_OTP_FAILED': 'otp_verification_failed',
    };

    _finvuAAManager.registerAliases(aliases);
    log('Event aliases registered successfully');

    _finvuAAManager.track('CUSTOM_BUTTON_CLICKED', {
      'buttonId': 'submit_button',
      'action': 'submit_form',
    });

    on<InitializeSDK>(_onInitializeSDK);
    on<ConnectToService>(_onConnectToService);
    on<DisconnectFromService>(_onDisconnectFromService);
    on<LoginWithCredentials>(_onLoginWithCredentials);
    on<VerifyOtp>(_onVerifyOtp);
    on<FetchLinkedAccounts>(_onFetchLinkedAccounts);
    on<GetConsentDetails>(_onGetConsentDetails);
    on<ApproveConsent>(_onApproveConsent);
    on<DenyConsent>(_onDenyConsent);
    on<LogoutAndDisconect>(_onLogoutAndDisconnect);
    on<UpdateUserData>(_onUpdateUserData);
    // Add new event handlers for account linking
    on<FetchFipsList>(_onFetchFipsList);
    on<DiscoverAccounts>(_onDiscoverAccounts);
    on<LinkAccounts>(_onLinkAccounts);
    on<ConfirmAccountLinking>(_onConfirmAccountLinking);
    on<ClearDiscoveredAccounts>(_onClearDiscoveredAccounts);
  }

  // Example: Track custom events
  void trackCustomEvents() {
    // Track a custom event (must be registered first)
    _finvuAAManager.track('CUSTOM_BUTTON_CLICKED', {
      'buttonId': 'login_button',
      'screen': 'login_screen',
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Track another custom event
    _finvuAAManager.track('CUSTOM_API_CALLED', {
      'endpoint': '/api/consent',
      'method': 'POST',
      'status': 'success',
    });

    // Track a standard event with custom params
    _finvuAAManager.track('WEBSOCKET_CONNECTED', {
      'connectionTime': '150ms',
      'retryCount': 0,
    });

    print('Custom events tracked');
  }

  @override
  Future<void> close() {
    // Clean up event listener when bloc is closed
    _finvuAAManager.removeEventListener();
    _finvuAAManager.setEventsEnabled(false);
    return super.close();
  }

  Future<void> _onInitializeSDK(
      InitializeSDK event, Emitter<FinvuState> emit) async {
    emit(const FinvuLoading('Initializing SDK...', true));

    final result = await _finvuAAManager.initializeWith(event.config);

    if (result.isSuccess) {
      emit(FinvuConnected(
        isLoading: false,
        message: 'SDK initialized successfully',
        isConnected: false,
        isLoggedIn: false,
        mobileNumber: event.config.finvuEndpoint.contains('mobile') ? '' : null,
      ));
    } else {
      emit(FinvuError(result.error?.message ?? 'Initialization failed', false));
    }
  }

  Future<void> _onConnectToService(
      ConnectToService event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;

    emit(const FinvuLoading('Connecting to service...', true));

    final result = await _finvuAAManager.connect();

    if (result.isSuccess) {
      emit(const FinvuConnected(
          isLoading: false,
          isConnected: true,
          message: 'Connected to Finvu.',
          isLoggedIn: false));
    } else {
      emit(FinvuError(result.error?.message ?? 'Connection failed', false));
    }
  }

  Future<void> _onDisconnectFromService(
      DisconnectFromService event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;

    emit(const FinvuLoading('Disconnecting from service...', false));

    final result = await _finvuAAManager.disconnect();

    if (result.isSuccess) {
      final currentState = state as FinvuConnected;
      emit(currentState.copyWith(isLoading: false, isConnected: false));
    } else {
      emit(FinvuError(result.error?.message ?? 'Disconnection failed', false));
    }
  }

  Future<void> _onLoginWithCredentials(
      LoginWithCredentials event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;

    emit(const FinvuConnected(
        isLoading: true,
        message: 'Logging in...',
        isConnected: true,
        isLoggedIn: false));

    final result = await _finvuAAManager.loginWithUsernameOrMobileNumber(
      event.userHandle,
      event.mobileNumber,
      event.consentHandleId,
    );

    if (result.isSuccess) {
      if (result.data?.authType == "SNA") {
        add(VerifyOtp(
            mobileNumber: event.mobileNumber,
            otp: result.data?.snaToken ?? "",
            otpReference: result.data?.reference ?? "",
            consentHandleId: event.consentHandleId));
      } else {
        emit(FinvuConnected(
          isLoading: false,
          otpReference: result.data?.reference,
          mobileNumber: event.mobileNumber,
          userHandle: event.userHandle,
          consentHandleId: event.consentHandleId,
          message: 'Otp verification required',
          isConnected: true,
          isLoggedIn: false,
        ));
      }
    } else {
      emit(FinvuConnected(
        isLoading: false,
        otpReference: result.data?.reference,
        mobileNumber: event.mobileNumber,
        userHandle: event.userHandle,
        consentHandleId: event.consentHandleId,
        message: result.error?.message ?? 'Login failed, please retry',
        isConnected: true,
        isLoggedIn: false,
      ));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtp event, Emitter<FinvuState> emit) async {
    if (!(state as FinvuConnected).isConnected) return;

    final currentState = state as FinvuConnected;
    emit(currentState.copyWith(message: 'Verifying...', isLoading: true));

    final result =
        await _finvuAAManager.verifyLoginOtp(event.otp, event.otpReference);
    if (result.isSuccess) {
      emit(currentState.copyWith(
        isLoading: false,
        isLoggedIn: true,
        userId: result.data?.userId,
        message: 'Verified. User ID: ${result.data?.userId}',
        consentHandleId: event.consentHandleId,
        mobileNumber: event.mobileNumber,
      ));
    } else {
      emit(currentState.copyWith(
        isLoading: false,
        message: result.error?.message ?? 'OTP verification failed',
      ));
    }
  }

  Future<void> _onFetchLinkedAccounts(
      FetchLinkedAccounts event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;
    final currentState = state as FinvuConnected;

    emit(currentState.copyWith(
        message: 'Fetching linked accounts...', isLoading: true));

    final result = await _finvuAAManager.fetchLinkedAccounts();

    if (result.isSuccess) {
      final currentState = state as FinvuConnected;
      emit(currentState.copyWith(
        isLoading: false,
        linkedAccounts: result.data ?? [],
        message: 'Found ${result.data?.length ?? 0} linked accounts',
      ));
    } else {
      emit(FinvuError(
          result.error?.message ?? 'Failed to fetch linked accounts', false));
    }
  }

  Future<void> _onGetConsentDetails(
      GetConsentDetails event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;
    final currentState = state as FinvuConnected;

    emit(currentState.copyWith(
        message: 'Fetching consent details...', isLoading: true));

    final result =
        await _finvuAAManager.getConsentRequestDetails(event.consentHandleId);

    if (result.isSuccess) {
      final currentState = state as FinvuConnected;
      emit(
          currentState.copyWith(isLoading: false, consentDetails: result.data));
    } else {
      emit(FinvuError(
          result.error?.message ?? 'Failed to fetch consent details', false));
    }
  }

  Future<void> _onApproveConsent(
      ApproveConsent event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;
    final currentState = state as FinvuConnected;

    emit(currentState.copyWith(
        message: 'Approving consent...', isLoading: true));

    final result = await _finvuAAManager.approveConsentRequest(
      event.consentDetail,
      event.accounts,
    );

    if (result.isSuccess) {
      emit(const FinvuSuccess('Consent approved successfully', false));
      // Auto logout after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        add(LogoutAndDisconect());
      });
    } else {
      emit(FinvuError(
          result.error?.message ?? 'Consent approval failed', false));
    }
  }

  Future<void> _onDenyConsent(
      DenyConsent event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;
    final currentState = state as FinvuConnected;

    emit(currentState.copyWith(message: 'Denying consent...', isLoading: true));

    final result =
        await _finvuAAManager.denyConsentRequest(event.consentDetail);

    if (result.isSuccess) {
      emit(const FinvuSuccess('Consent denied successfully', false));
      // Auto logout after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        add(LogoutAndDisconect());
      });
    } else {
      emit(FinvuError(result.error?.message ?? 'Consent denial failed', false));
    }
  }

  Future<void> _onLogoutAndDisconnect(
      LogoutAndDisconect event, Emitter<FinvuState> emit) async {
    emit(const FinvuLoading('Logging out...', true));

    final result = await _finvuAAManager.logout();

    if (result.isSuccess) {
      emit(const FinvuConnected(
        isLoading: false,
        message: 'logged out.',
        isConnected: false,
        isLoggedIn: false,
      ));

      await Future.delayed(const Duration(seconds: 3));

      emit(FinvuInitial());
    } else {
      emit(FinvuError(result.error?.message ?? 'Logout failed', false));
    }
  }

  Future<void> _onUpdateUserData(
      UpdateUserData event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;

    final currentState = state as FinvuConnected;
    emit(currentState.copyWith(
      isLoading: false,
      mobileNumber: event.mobileNumber ?? currentState.mobileNumber,
      userHandle: event.userHandle ?? currentState.userHandle,
      consentHandleId: event.consentHandleId ?? currentState.consentHandleId,
    ));
  }

  // Account linking handlers
  Future<void> _onFetchFipsList(
      FetchFipsList event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;
    final currentState = state as FinvuConnected;

    emit(currentState.copyWith(
        message: 'Fetching FIPs list...', isLoading: true));

    final result = await _finvuAAManager.fipsAllFIPOptions();

    if (result.isSuccess) {
      final currentState = state as FinvuConnected;
      emit(currentState.copyWith(
        isLoading: false,
        allAvailableFips: result.data ?? [],
        message: 'Found ${result.data?.length ?? 0} FIPs',
      ));
    } else {
      emit(FinvuError(result.error?.message ?? 'Failed to fetch FIPs', false));
    }
  }

  Future<void> _onDiscoverAccounts(
      DiscoverAccounts event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;
    final currentState = state as FinvuConnected;

    emit(currentState.copyWith(
        message: 'Discovering accounts...', isLoading: true));

    // Discover accounts with the provided identifiers
    final result = await _finvuAAManager.discoverAccounts(
      event.fipId,
      event.fipFiTypes,
      event.identifiers,
    );

    if (result.isSuccess) {
      final currentState = state as FinvuConnected;
      emit(currentState.copyWith(
        isLoading: false,
        discoveredAccounts: result.data ?? [],
        message: 'Found ${result.data?.length ?? 0} accounts',
      ));
    } else {
      emit(FinvuError(
          result.error?.message ?? 'Failed to discover accounts', false));
    }
  }

  Future<void> _onLinkAccounts(
      LinkAccounts event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;

    final currentState = state as FinvuConnected;
    emit(
        currentState.copyWith(message: 'Linking accounts...', isLoading: true));

    final result = await _finvuAAManager.linkAccounts(
      event.accounts,
      event.fipDetails,
    );

    if (result.isSuccess) {
      final currentState = state as FinvuConnected;
      emit(currentState.copyWith(
        isLoading: false,
        linkingReference: result.data,
        message:
            'Account linking initiated. Reference: ${result.data?.referenceNumber}',
      ));
    } else {
      emit(FinvuError(
          result.error?.message ?? 'Failed to link accounts', false));
    }
  }

  Future<void> _onConfirmAccountLinking(
      ConfirmAccountLinking event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;

    final currentState = state as FinvuConnected;
    emit(currentState.copyWith(
        message: 'Confirming account linking...', isLoading: true));

    final result = await _finvuAAManager.confirmAccountLinking(
      event.linkingReference,
      event.otp,
    );

    if (result.isSuccess) {
      final currentState = state as FinvuConnected;
      emit(currentState.copyWith(
        isLoading: false,
        message: 'Acccont linked successfully.',
      ));
    } else {
      emit(FinvuError(
          result.error?.message ?? 'Failed to confirm account linking', false));
    }
  }

  Future<void> _onClearDiscoveredAccounts(
      ClearDiscoveredAccounts event, Emitter<FinvuState> emit) async {
    if (state is! FinvuConnected) return;

    final currentState = state as FinvuConnected;
    emit(currentState.copyWith(
        discoveredAccounts: [],
        message: 'Ready to discover accounts',
        isLoading: false));
  }

  // Internal method to handle SDK events and update state
  // Note: This is called from the event listener, so we need to use add() to dispatch events
  void _handleSdkEvent(sdk.FinvuEvent event) {
    // Log all SDK events
    // State updates will happen through normal BLoC event handlers
    // This method can be used to add custom BLoC events based on SDK events if needed

    switch (event.eventName) {
      case 'SESSION_ERROR':
      case 'SESSION_FAILURE':
        // For critical errors, we could add a custom BLoC event
        // For now, just log - the error will be caught by existing handlers
        final error = event.getParam<String>('error');
        print('Critical SDK Error: $error');
        break;

      default:
        // All other events are logged and handled by existing BLoC handlers
        break;
    }
  }
}

/// Internal SDK event listener that forwards events to the BLoC
class _SdkEventListener implements FinvuEventListener {
  FinvuBloc? _bloc;

  @override
  void onEvent(sdk.FinvuEvent event) {
    // Log the event
    print('SDK Event: ${event.eventName}');
    print('   Category: ${event.eventCategory}');
    print('   Timestamp: ${event.timestamp}');
    if (event.params.isNotEmpty) {
      print('   Params: ${event.params}');
    }

    // Forward to BLoC to update state if needed
    _bloc?._handleSdkEvent(event);
  }
}
