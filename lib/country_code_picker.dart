library country_code_picker;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_code_picker/country_code.dart';
import 'package:country_code_picker/selection_dialog.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'country_codes.dart';

export 'country_code.dart';

class CountryCodePicker extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<CountryCode?>? onInit;
  final String? initialSelection;

  /// used to customize the country list
  final List<String>? countryFilter;

  /// Use this property to change the order of the options
  final Comparator<CountryCode>? comparator;

  final List<Map<String, String>> countryList;

  const CountryCodePicker({
    this.onChanged,
    this.onInit,
    this.initialSelection,
    this.comparator,
    this.countryFilter,
    this.countryList = codes,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    List<Map<String, String>> jsonList = countryList;

    List<CountryCode> elements =
        jsonList.map((json) => CountryCode.fromJson(json)).toList();

    if (comparator != null) {
      elements.sort((a, b) => a.name!.compareTo(b.name!));
    }

    if (countryFilter != null && countryFilter!.isNotEmpty) {
      final uppercaseCustomList =
          countryFilter!.map((c) => c.toUpperCase()).toList();
      elements = elements
          .where((c) =>
              uppercaseCustomList.contains(c.code) ||
              uppercaseCustomList.contains(c.name) ||
              uppercaseCustomList.contains(c.dialCode))
          .toList();
    }

    return CountryCodePickerState(elements);
  }
}

class CountryCodePickerState extends State<CountryCodePicker> {
  CountryCode? selectedItem;
  List<CountryCode> elements = [];

  CountryCodePickerState(this.elements);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: showCountryCodePickerDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
              color: const Color.fromRGBO(18, 18, 18, 0.38),
              width: 0.75.w,
              style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/${selectedItem!.flagUri!}',
              height: 12.h,
              width: 18.h,
            ),
            SizedBox(width: 7.h),
            Text(
              selectedItem!.dialCode!,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(18, 18, 18, 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _onInit(selectedItem);
  }

  @override
  void didUpdateWidget(CountryCodePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialSelection != widget.initialSelection) {
      if (widget.initialSelection != null) {
        selectedItem = elements.firstWhere(
            (e) =>
                (e.code!.toUpperCase() ==
                    widget.initialSelection!.toUpperCase()) ||
                (e.dialCode == widget.initialSelection) ||
                (e.name!.toUpperCase() ==
                    widget.initialSelection!.toUpperCase()),
            orElse: () => elements[0]);
      } else {
        selectedItem = elements[0];
      }
      _onInit(selectedItem);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialSelection != null) {
      selectedItem = elements.firstWhere(
          (e) =>
              (e.code!.toUpperCase() ==
                  widget.initialSelection!.toUpperCase()) ||
              (e.dialCode == widget.initialSelection) ||
              (e.name!.toUpperCase() == widget.initialSelection!.toUpperCase()),
          orElse: () => elements[0]);
    } else {
      selectedItem = elements[0];
    }
  }

  void showCountryCodePickerDialog() {
    showMaterialModalBottomSheet(
      barrierColor: Colors.grey.withOpacity(0.5),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => SelectionDialog(
        elements,
      ),
    ).then((e) {
      if (e != null) {
        setState(() {
          selectedItem = e;
        });

        _publishSelection(e);
      }
    });
  }

  void _publishSelection(CountryCode e) {
    if (widget.onChanged != null) {
      widget.onChanged!(e.dialCode!);
    }
  }

  void _onInit(CountryCode? e) {
    if (widget.onInit != null) {
      widget.onInit!(e);
    }
  }
}
