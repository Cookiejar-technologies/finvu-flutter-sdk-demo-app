import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk_demo_app/blocs/finvu_event.dart'
    show
        ApproveConsent,
        ConnectToService,
        DenyConsent,
        FetchLinkedAccounts,
        GetConsentDetails,
        InitializeSDK,
        LoginWithCredentials,
        LogoutAndDisconect,
        UpdateUserData,
        VerifyOtp;
import 'package:finvu_flutter_sdk_demo_app/blocs/finvu_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/finvu_bloc.dart';
import '../constants/routes.dart';
import '../styles/shared_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _userHandleController = TextEditingController();
  final TextEditingController _consentHandleController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default values like React Native context
    _mobileNumberController.text = '8830751044';
    _userHandleController.text = '8830751044@finvu';
    _consentHandleController.text = '83bbf206-b82b-45a8-b1d3-b0f370bb094a';
  }

  @override
  void dispose() {
    _clearInputFields();
    _otpController.dispose();
    _mobileNumberController.dispose();
    _userHandleController.dispose();
    _consentHandleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finvu SDK Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<FinvuBloc, FinvuState>(
        listener: (context, state) {
          if (state is FinvuError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is FinvuInitial) {
            _clearInputFields();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: SharedStyles.containerPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_getStatusMessage(state), style: SharedStyles.titleStyle),
                const SizedBox(height: 16),

                // Loading Indicator
                if (state is FinvuLoading)
                  const Center(child: CircularProgressIndicator()),

                // Setup Section - Always show
                _buildSection(
                  'Setup',
                  [
                    ElevatedButton(
                      onPressed: state is FinvuLoading
                          ? null
                          : () {
                              final config = FinvuConfig(
                                  finvuEndpoint:
                                      'wss://webvwdev.finvu.in/consentapiv2',
                                  finvuSnaAuthConfig: FinvuSnaAuthConfig(
                                      environment: FinvuEnv.uat));
                              context
                                  .read<FinvuBloc>()
                                  .add(InitializeSDK(config));
                            },
                      child: const Text('Initialize SDK'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: (state is FinvuConnected &&
                                  state.isConnected) ||
                              state is FinvuLoading
                          ? null
                          : () {
                              context.read<FinvuBloc>().add(ConnectToService());
                            },
                      child: Text((state is FinvuConnected && state.isConnected)
                          ? 'Connected'
                          : 'Connect to Service'),
                    ),
                    if (state is FinvuConnected) ...[
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: !state.isConnected || state is FinvuLoading
                            ? null
                            : () {
                                context
                                    .read<FinvuBloc>()
                                    .add(LogoutAndDisconect());
                              },
                        child: const Text('Disconnect from Service'),
                      ),
                    ],
                  ],
                ),

                // Authentication Section - Always show
                _buildSection(
                  'Authentication',
                  [
                    // Input fields for login credentials
                    if ((state is FinvuConnected && state.isConnected) &&
                        !(state.isLoggedIn))
                      TextField(
                        controller: _mobileNumberController,
                        decoration: SharedStyles.inputDecoration.copyWith(
                          hintText: 'Mobile Number',
                        ),
                        enabled: !state.isLoading,
                        onChanged: (value) {
                          context
                              .read<FinvuBloc>()
                              .add(UpdateUserData(mobileNumber: value));
                        },
                      ),
                    if ((state is FinvuConnected && state.isConnected) &&
                        !(state.isLoggedIn))
                      const SizedBox(height: 8),
                    if ((state is FinvuConnected && state.isConnected) &&
                        !(state.isLoggedIn))
                      TextField(
                        controller: _userHandleController,
                        decoration: SharedStyles.inputDecoration.copyWith(
                          hintText: 'User Handle',
                        ),
                        enabled: !state.isLoading,
                        onChanged: (value) {
                          context
                              .read<FinvuBloc>()
                              .add(UpdateUserData(userHandle: value));
                        },
                      ),
                    if ((state is FinvuConnected && state.isConnected) &&
                        !(state.isLoggedIn))
                      const SizedBox(height: 8),
                    if ((state is FinvuConnected && state.isConnected) &&
                        !(state.isLoggedIn))
                      TextField(
                        controller: _consentHandleController,
                        decoration: SharedStyles.inputDecoration.copyWith(
                          hintText: 'Consent Handle ID',
                        ),
                        enabled: !state.isLoading,
                        onChanged: (value) {
                          context
                              .read<FinvuBloc>()
                              .add(UpdateUserData(consentHandleId: value));
                        },
                      ),
                    if ((state is FinvuConnected && state.isConnected) &&
                        !(state.isLoggedIn))
                      const SizedBox(height: 8),
                    if ((state is FinvuConnected && state.isConnected) &&
                        !(state.isLoggedIn))
                      ElevatedButton(
                        onPressed: (state.isConnected) &&
                                !(state.isLoggedIn) &&
                                state.isLoading
                            ? null
                            : () {
                                context
                                    .read<FinvuBloc>()
                                    .add(LoginWithCredentials(
                                      userHandle: _userHandleController.text,
                                      mobileNumber:
                                          _mobileNumberController.text,
                                      consentHandleId:
                                          _consentHandleController.text,
                                    ));
                              },
                        child: const Text('Login'),
                      ),
                    const SizedBox(height: 8),

                    // OTP Input (only shown when OTP reference is available and not logged in)
                    if (state is FinvuConnected &&
                        state.otpReference != null &&
                        !state.isLoggedIn) ...[
                      TextField(
                        controller: _otpController,
                        decoration: SharedStyles.inputDecoration.copyWith(
                          hintText: 'Enter Login OTP',
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !state.isLoading,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                context.read<FinvuBloc>().add(VerifyOtp(
                                      otp: _otpController.text,
                                      otpReference: state.otpReference!,
                                      consentHandleId: state.consentHandleId ??
                                          _consentHandleController.text,
                                      mobileNumber: state.mobileNumber ??
                                          _mobileNumberController.text,
                                    ));
                              },
                        child: const Text('Verify OTP'),
                      ),
                    ],

                    // User ID and Logout (only shown when logged in)
                    if (state is FinvuConnected && state.isLoggedIn) ...[
                      Text('User ID: ${state.userId}',
                          style: SharedStyles.infoTextStyle),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: state is FinvuLoading
                            ? null
                            : () {
                                context
                                    .read<FinvuBloc>()
                                    .add(LogoutAndDisconect());
                              },
                        child: const Text('Logout'),
                      ),
                    ],
                  ],
                ),

                // Account Management Section (only when logged in)
                if (state is FinvuConnected && state.isLoggedIn) ...[
                  _buildSection(
                    'Account Management',
                    [
                      ElevatedButton(
                        onPressed: state is FinvuLoading
                            ? null
                            : () {
                                context
                                    .read<FinvuBloc>()
                                    .add(FetchLinkedAccounts());
                              },
                        child: const Text('Fetch Linked Accounts'),
                      ),
                      if (state.linkedAccounts.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Linked Accounts: ${state.linkedAccounts.length}',
                          style: SharedStyles.infoTextStyle,
                        ),
                      ],
                    ],
                  ),

                  _buildSection(
                    'Account Management',
                    [
                      ElevatedButton(
                        onPressed: state is FinvuLoading
                            ? null
                            : () {
                                Navigator.pushNamed(
                                    context, Routes.linkedAccounts);
                              },
                        child: const Text('Link Accounts'),
                      ),
                    ],
                  ),

                  // Consent Management Section
                  _buildSection(
                    'Consent Management',
                    [
                      TextField(
                        controller: _consentHandleController,
                        decoration: SharedStyles.inputDecoration.copyWith(
                          hintText: 'Enter Consent Handle ID',
                        ),
                        enabled: !state.isLoading,
                        onChanged: (value) {
                          context
                              .read<FinvuBloc>()
                              .add(UpdateUserData(consentHandleId: value));
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<FinvuBloc>()
                              .add(GetConsentDetails(state.consentHandleId!));
                        },
                        child: const Text('Fetch Consent Details'),
                      ),
                      if (state.consentDetails != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Consent Purpose: ${state.consentDetails!.consentPurposeInfo.text}',
                          style: SharedStyles.infoTextStyle,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: state.linkedAccounts.isEmpty ||
                                        state is FinvuLoading
                                    ? null
                                    : () {
                                        context
                                            .read<FinvuBloc>()
                                            .add(ApproveConsent(
                                              consentDetail:
                                                  state.consentDetails!,
                                              accounts: state.linkedAccounts,
                                            ));
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Approve Consent'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: state is FinvuLoading
                                    ? null
                                    : () {
                                        context
                                            .read<FinvuBloc>()
                                            .add(DenyConsent(
                                              state.consentDetails!,
                                            ));
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Deny Consent'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getStatusMessage(FinvuState state) {
    if (state is FinvuLoading) {
      return state.message;
    } else if (state is FinvuConnected) {
      return state.message ?? 'Ready to initialize';
    } else if (state is FinvuSuccess) {
      return state.message;
    } else if (state is FinvuError) {
      return state.message;
    } else {
      return 'Ready to initialize';
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: SharedStyles.sectionPadding,
      decoration: SharedStyles.sectionDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: SharedStyles.sectionTitleStyle),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  void _clearInputFields() {
    _otpController.clear();
    _mobileNumberController.clear();
    _userHandleController.clear();
    _consentHandleController.clear();
  }
}
