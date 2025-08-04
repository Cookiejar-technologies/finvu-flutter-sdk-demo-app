import 'dart:async';
import '../models/identifier.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';

class AccountLinking {
  static List<Identifier> getRequiredFinvuTypeIdentifierInfoList(
    FinvuFIPDetails? fipDetails,
  ) {
    if (fipDetails?.typeIdentifiers == null) return [];

    final allIdentifiers = <Identifier>[];

    for (final typeIdentifier in fipDetails!.typeIdentifiers) {
      for (final identifier in typeIdentifier.identifiers) {
        allIdentifiers.add(Identifier(
          fiType: typeIdentifier.fiType,
          type: identifier.type,
          category: identifier.category,
        ));
      }
    }

    // Remove duplicates based on type
    final seenTypes = <String>{};
    final distinctIdentifiers = <Identifier>[];

    for (final identifier in allIdentifiers) {
      if (!seenTypes.contains(identifier.type)) {
        seenTypes.add(identifier.type);
        distinctIdentifiers.add(identifier);
      }
    }

    return distinctIdentifiers;
  }

  static Future<List<Identifier>> getIdentifiersWithUserInput({
    required FinvuFIPDetails fipDetails,
    required String mobileNumber,
    required Function(InputDialogResolver) showPanInputDialog,
    required Function(InputDialogResolver) showDobInputDialog,
  }) async {
    final requiredIdentifiers =
        getRequiredFinvuTypeIdentifierInfoList(fipDetails);
    final resolvedIdentifiers = <Identifier>[];

    for (final identifier in requiredIdentifiers) {
      final fiType = identifier.fiType;
      final type = identifier.type;
      final category = identifier.category;
      String? value;

      switch (type) {
        case 'MOBILE':
          value = mobileNumber;
          break;
        case 'PAN':
          value = await _showPanDialog(showPanInputDialog);
          break;
        case 'DOB':
          value = await _showDobDialog(showDobInputDialog);
          break;
        default:
          // Handle unsupported types
          value = null;
      }

      resolvedIdentifiers.add(Identifier(
        fiType: fiType,
        type: type,
        category: category,
        value: value,
      ));
    }

    return resolvedIdentifiers;
  }

  static Future<String> _showPanDialog(
    Function(InputDialogResolver) showPanInputDialog,
  ) async {
    final completer = Completer<String>();

    showPanInputDialog((value) {
      completer.complete(value);
    });

    return completer.future;
  }

  static Future<String> _showDobDialog(
    Function(InputDialogResolver) showDobInputDialog,
  ) async {
    final completer = Completer<String>();

    showDobInputDialog((value) {
      completer.complete(value);
    });

    return completer.future;
  }
}
