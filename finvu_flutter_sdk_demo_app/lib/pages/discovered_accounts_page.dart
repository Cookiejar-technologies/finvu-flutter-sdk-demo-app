import 'package:finvu_flutter_sdk_demo_app/services/finvu_aa_manager.dart'
    hide FinvuError;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import '../blocs/finvu_bloc.dart';
import '../blocs/finvu_event.dart';
import '../blocs/finvu_state.dart';
import '../constants/routes.dart';
import '../styles/shared_styles.dart';
import '../widgets/otp_input_dialog.dart';

class DiscoveredAccountsPage extends StatefulWidget {
  const DiscoveredAccountsPage({super.key});

  @override
  State<DiscoveredAccountsPage> createState() => _DiscoveredAccountsPageState();
}

class _DiscoveredAccountsPageState extends State<DiscoveredAccountsPage> {
  final List<String> _selectedAccounts = [];
  bool _showOtpDialog = false;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final fipId = args['fipId'] as String;
    final productName = args['productName'] as String;
    final discoveredAccounts =
        args['discoveredAccounts'] as List<FinvuDiscoveredAccountInfo>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Account to Link'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<FinvuBloc, FinvuState>(
        listener: (context, state) {
          if (state is FinvuError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is FinvuConnected &&
              state.linkingReference != null) {
            if (state.message == "Acccont linked successfully.") {
              // Navigate back to home after successful linking
              setState(() {
                _showOtpDialog = false;
              });
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.home,
                (route) => false,
              );
            } else {
              // Show OTP dialog when linking reference is available
              setState(() {
                _showOtpDialog = true;
              });
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: SharedStyles.containerPadding,
                child: Column(
                  children: [
                    const Text(
                      'Select account to link',
                      style: SharedStyles.titleStyle,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getStatusMessage(state),
                      style: SharedStyles.statusStyle,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: discoveredAccounts.length,
                              itemBuilder: (context, index) {
                                final account = discoveredAccounts[index];
                                final isSelected = _selectedAccounts
                                    .contains(account.maskedAccountNumber);

                                return Container(
                                  margin: SharedStyles.buttonMargin,
                                  padding: SharedStyles.sectionPadding,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.green
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedAccounts.remove(
                                              account.maskedAccountNumber);
                                        } else {
                                          _selectedAccounts
                                              .add(account.maskedAccountNumber);
                                        }
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName,
                                          style: SharedStyles.sectionTitleStyle,
                                        ),
                                        Text(
                                          account.maskedAccountNumber,
                                          style: SharedStyles.infoTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: SharedStyles.buttonMargin,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _selectedAccounts.isEmpty || state.isLoading
                                  ? null
                                  : () => _handleLinkAccounts(
                                      fipId, discoveredAccounts),
                          child: const Text('Link Accounts'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showOtpDialog)
                OtpInputDialog(
                  visible: _showOtpDialog,
                  onClose: () => setState(() => _showOtpDialog = false),
                  onSubmit: _handleOtpSubmit,
                ),
            ],
          );
        },
      ),
    );
  }

  void _handleLinkAccounts(
      String fipId, List<FinvuDiscoveredAccountInfo> discoveredAccounts) async {
    final accountsToLink = discoveredAccounts
        .where(
          (account) => _selectedAccounts.contains(account.maskedAccountNumber),
        )
        .toList();

    try {
      final result = await FinvuAAManager().fetchFipDetails(fipId);
      if (!result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    result.error?.message ?? 'Error fetching FIP details')),
          );
        }
        return;
      }
      if (mounted) {
        context.read<FinvuBloc>().add(LinkAccounts(
              accounts: accountsToLink,
              fipDetails: result.data!,
            ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error linking accounts: ${e.toString()}')),
        );
      }
    }
  }

  void _handleOtpSubmit(String otp) {
    final state = context.read<FinvuBloc>().state;
    if (state is FinvuConnected && state.linkingReference != null) {
      context.read<FinvuBloc>().add(ConfirmAccountLinking(
            linkingReference: state.linkingReference!,
            otp: otp,
          ));
    }
  }

  String _getStatusMessage(FinvuState state) {
    if (state.isLoading) {
      return state is FinvuLoading ? state.message : 'Loading...';
    } else if (state is FinvuConnected) {
      if (state.linkingReference != null) {
        return 'Account linking initiated. Reference: ${state.linkingReference}';
      } else if (state.message != null) {
        return state.message!;
      } else {
        return 'Select accounts to link';
      }
    } else if (state is FinvuError) {
      return state.message;
    } else {
      return 'Ready to link accounts';
    }
  }
}
