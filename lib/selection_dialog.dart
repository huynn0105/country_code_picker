import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'country_code.dart';

/// selection dialog used for selection of the country code
class SelectionDialog extends StatefulWidget {
  final List<CountryCode> elements;
  final String title;
  final String hintText;
  final String notFound;
  const SelectionDialog(
    this.elements, {
    Key? key,
    required this.title,
    required this.hintText,
    required this.notFound,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  late List<CountryCode> filteredElements;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(CupertinoIcons.search),
                  fillColor: Color(0xFFEFEEEE),
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: Color(0xFF),
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.all(5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _filterElements,
              ),
              Expanded(
                child: ListView(
                  children: [
                    if (filteredElements.isEmpty)
                      _buildEmptySearchWidget(context)
                    else
                      ...filteredElements.map(
                        (e) => _buildOption(e),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildOption(CountryCode e) {
    return InkWell(
      onTap: () => _selectItem(e),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Container(
                  clipBehavior: Clip.none,
                  child: Image.asset(
                      e.flagUri!,
                      width: 22.4.w,
                      package: 'country_code_picker',
                  ),
                ),
                SizedBox(width: 8.4.w),
                Expanded(
                  child: Text(
                    e.name!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
                  ),
                ),
                const Spacer(),
                Text(
                  e.dialCode!,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
                ),
              ],
            ),
            const Divider(
              thickness: 1,
              color: Color(0xFFEBEBEB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    return Center(
      child: Text(
        widget.notFound,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
      ),
    );
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = widget.elements
          .where((e) =>
              e.code!.contains(s) ||
              e.dialCode!.contains(s) ||
              e.name!.toUpperCase().contains(s))
          .toList();
    });
  }

  void _selectItem(CountryCode e) {
    Navigator.pop(context, e);
  }
}
