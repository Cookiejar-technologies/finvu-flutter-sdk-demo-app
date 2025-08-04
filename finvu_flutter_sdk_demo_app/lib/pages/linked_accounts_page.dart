import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/finvu_bloc.dart';
import '../blocs/finvu_event.dart';
import '../blocs/finvu_state.dart';
import '../constants/routes.dart';
import '../styles/shared_styles.dart';

class LinkedAccountsPage extends StatefulWidget {
  const LinkedAccountsPage({super.key});

  @override
  State<LinkedAccountsPage> createState() => _LinkedAccountsPageState();
}

class _LinkedAccountsPageState extends State<LinkedAccountsPage> {
  @override
  void initState() {
    super.initState();
    // Check if we need to fetch linked accounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<FinvuBloc>().state;
      if (state is FinvuConnected && state.linkedAccounts.isEmpty) {
        context.read<FinvuBloc>().add(FetchLinkedAccounts());
      }
    });
  }

  Widget _buildAccountItem(FinvuLinkedAccountDetailsInfo account) {
    return Container(
      margin: SharedStyles.buttonMargin,
      padding: SharedStyles.sectionPadding,
      decoration: SharedStyles.sectionDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FIP : ${account.fipName}',
            style: SharedStyles.infoTextStyle,
          ),
          const SizedBox(height: 4),
          Text(
            'Account Number: ${account.maskedAccountNumber}',
            style: SharedStyles.infoTextStyle,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Linked Accounts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<FinvuBloc, FinvuState>(
        listener: (context, state) {
          if (state is FinvuError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: SharedStyles.containerPadding,
            child: Column(
              children: [
                const Text('Linked Accounts', style: SharedStyles.titleStyle),
                const SizedBox(height: 16),
                Text(
                  _getStatusMessage(state),
                  style: SharedStyles.statusStyle,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: state is FinvuLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            Expanded(
                              child: state is FinvuConnected &&
                                      state.linkedAccounts.isNotEmpty
                                  ? ListView.builder(
                                      itemCount: state.linkedAccounts.length,
                                      itemBuilder: (context, index) {
                                        return _buildAccountItem(
                                            state.linkedAccounts[index]);
                                      },
                                    )
                                  : const Center(
                                      child: Text(
                                        'No linked accounts found',
                                        style: SharedStyles.infoTextStyle,
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: SharedStyles.buttonMargin,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.discoverAccounts,
                                      arguments: {
                                        'linkedAccounts':
                                            state is FinvuConnected
                                                ? state.linkedAccounts
                                                : [],
                                      },
                                    );
                                  },
                                  child: const Text('Discover New Accounts'),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
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
      if (state.linkedAccounts.isNotEmpty) {
        return 'Found ${state.linkedAccounts.length} linked accounts';
      } else {
        return 'No linked accounts found';
      }
    } else if (state is FinvuError) {
      return state.message;
    } else {
      return 'Ready to fetch linked accounts';
    }
  }
}
