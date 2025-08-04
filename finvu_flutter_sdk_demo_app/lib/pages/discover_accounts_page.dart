import 'dart:async';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:finvu_flutter_sdk_demo_app/services/finvu_aa_manager.dart'
    hide FinvuError;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import '../blocs/finvu_bloc.dart';
import '../blocs/finvu_event.dart';
import '../blocs/finvu_state.dart';
import '../constants/routes.dart';
import '../styles/shared_styles.dart';
import '../utils/account_linking_utils.dart';
import '../widgets/pan_input_dialog.dart';
import '../widgets/dob_input_dialog.dart';

class DiscoverAccountsPage extends StatefulWidget {
  const DiscoverAccountsPage({super.key});

  @override
  State<DiscoverAccountsPage> createState() => _DiscoverAccountsPageState();
}

class _DiscoverAccountsPageState extends State<DiscoverAccountsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showPanDialog = false;
  bool _showDobDialog = false;
  Completer<String>? _panCompleter;
  Completer<String>? _dobCompleter;
  late FinvuFIPInfo _currentFipInfo;
  bool _hasShownDialog = false; // Flag to prevent multiple dialogs
  late List<FinvuLinkedAccountDetailsInfo> _linkedAccounts;

  @override
  void initState() {
    super.initState();
    // Fetch FIPs list when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinvuBloc>().add(FetchFipsList());
    });
  }

  void _discoverAccounts(FinvuFIPInfo fipInfo) async {
    final state = context.read<FinvuBloc>().state;

    if (state is! FinvuConnected || !state.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    _currentFipInfo = fipInfo;
    _hasShownDialog = false; // Reset flag for new discovery

    try {
      // First, fetch FIP details using the manager
      final fipDetailsResult = await _fetchFipDetails(fipInfo.fipId);

      if (fipDetailsResult == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch FIP details')),
        );
        return;
      }

      // Get required identifiers with user input
      final requiredIdentifiers =
          await AccountLinking.getIdentifiersWithUserInput(
        fipDetails: fipDetailsResult!,
        mobileNumber: state.mobileNumber ?? 'mobile_number',
        showPanInputDialog: (resolver) {
          setState(() => _showPanDialog = true);
          _panCompleter = Completer<String>();
          _panCompleter!.future.then((value) {
            resolver(value);
          });
        },
        showDobInputDialog: (resolver) {
          setState(() => _showDobDialog = true);
          _dobCompleter = Completer<String>();
          _dobCompleter!.future.then((value) {
            resolver(value);
          });
        },
      );

      // Convert to SDK format
      final identifiers = requiredIdentifiers
          .map((id) => FinvuTypeIdentifierInfo(
                category: id.category,
                type: id.type,
                value: id.type == 'MOBILE'
                    ? state.mobileNumber ?? ''
                    : id.value ?? '',
              ))
          .toList();

      if (mounted) {
        context.read<FinvuBloc>().add(DiscoverAccounts(
              fipId: fipInfo.fipId,
              fipFiTypes: fipInfo.fipFitypes,
              identifiers: identifiers,
            ));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    }
  }

  Future<FinvuFIPDetails?> _fetchFipDetails(String fipId) async {
    try {
      final result = await FinvuAAManager().fetchFipDetails(fipId);

      if (result.isSuccess) {
        return result.data;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(result.error?.message ?? 'Error fetching FIP')),
          );
        }
        return null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error fetching FIP details: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  Future<bool?> _showConfirmationDialog(
      List<FinvuDiscoveredAccountInfo> discoveredAccounts, dynamic fipInfo) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accounts Discovered'),
        content:
            Text('Found ${discoveredAccounts.length} accounts. Link them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              // Clear discovered accounts from bloc state to prevent conflicts
              context.read<FinvuBloc>().add(ClearDiscoveredAccounts());
              Navigator.pushNamed(
                context,
                Routes.discoveredAccounts,
                arguments: {
                  'fipId': fipInfo.fipId,
                  'productName': fipInfo.productName ?? fipInfo.fipId,
                  'discoveredAccounts': discoveredAccounts
                      .where((account) => !_linkedAccounts.any(
                          (linkedAccount) =>
                              linkedAccount.maskedAccountNumber ==
                              account.maskedAccountNumber))
                      .toList(),
                },
              );
            },
            child: const Text('Link Accounts'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _linkedAccounts =
        args['linkedAccounts'] as List<FinvuLinkedAccountDetailsInfo>;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Accounts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<FinvuBloc, FinvuState>(
        listener: (context, state) async {
          if (state is FinvuError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is FinvuConnected &&
              state.discoveredAccounts.isNotEmpty &&
              !_hasShownDialog) {
            // Show confirmation dialog when accounts are discovered
            if (mounted) {
              _hasShownDialog = true; // Prevent multiple dialogs
              await _showConfirmationDialog(
                  state.discoveredAccounts, _currentFipInfo);
            }
          }
        },
        builder: (context, state) {
          List<FinvuFIPInfo> filteredFips = [];

          if (state is FinvuConnected) {
            filteredFips = state.allAvailableFips.where((fip) {
              final searchText = _searchController.text.toLowerCase();
              final productName = fip.productName?.toLowerCase() ?? '';
              return productName.contains(searchText);
            }).toList();
          }

          return Stack(
            children: [
              Padding(
                padding: SharedStyles.containerPadding,
                child: Column(
                  children: [
                    const Text(
                      'Discover Accounts',
                      style: SharedStyles.titleStyle,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: SharedStyles.inputDecoration.copyWith(
                        hintText: 'Search FIP by name...',
                      ),
                      onChanged: (value) {
                        setState(() {}); // Trigger rebuild for filtering
                      },
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
                          : filteredFips.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No FIPs found',
                                    style: SharedStyles.infoTextStyle,
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredFips.length,
                                  itemBuilder: (context, index) {
                                    final fip = filteredFips[index];
                                    return Container(
                                      margin: SharedStyles.buttonMargin,
                                      padding: SharedStyles.sectionPadding,
                                      decoration:
                                          SharedStyles.sectionDecoration,
                                      child: InkWell(
                                        onTap: () => _discoverAccounts(fip),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fip.productName ?? fip.fipId,
                                              style: SharedStyles
                                                  .sectionTitleStyle,
                                            ),
                                            Text(
                                              fip.productDesc ??
                                                  'No description available.',
                                              style: SharedStyles.infoTextStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
              if (_showPanDialog)
                PanInputDialog(
                  visible: _showPanDialog,
                  onClose: () {
                    setState(() => _showPanDialog = false);
                    if (_panCompleter?.isCompleted ?? false) {
                      return;
                    }
                    _panCompleter?.complete('');
                  },
                  onSubmit: (value) {
                    setState(() => _showPanDialog = false);
                    _panCompleter?.complete(value);
                  },
                ),
              if (_showDobDialog)
                DobInputDialog(
                  visible: _showDobDialog,
                  onClose: () {
                    setState(() => _showDobDialog = false);
                    if (_dobCompleter?.isCompleted ?? false) {
                      return;
                    }
                    _dobCompleter?.complete('');
                  },
                  onSubmit: (value) {
                    setState(() => _showDobDialog = false);
                    _dobCompleter?.complete(value);
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  String _getStatusMessage(FinvuState state) {
    if (state.isLoading) {
      return state is FinvuLoading ? state.message : 'Loading...';
    } else if (state is FinvuConnected) {
      if (state.allAvailableFips.isNotEmpty) {
        return 'Found ${state.allAvailableFips.length} FIPs';
      } else if (state.discoveredAccounts.isNotEmpty) {
        return 'Found ${state.discoveredAccounts.length} accounts';
      } else {
        return 'No FIPs found';
      }
    } else if (state is FinvuError) {
      return state.message;
    } else {
      return 'Ready to fetch FIPs';
    }
  }
}
