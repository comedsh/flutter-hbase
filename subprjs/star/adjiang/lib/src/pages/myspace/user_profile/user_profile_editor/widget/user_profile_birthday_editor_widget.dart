// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';


class AdJiangDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  const AdJiangDatePicker({super.key, this.initialDate});

  @override
  State<AdJiangDatePicker> createState() => _AdJiangDatePickerState();
}

class _AdJiangDatePickerState extends State<AdJiangDatePicker> {
  DateTime? selectedDate;
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      locale: const Locale.fromSubtags(languageCode: 'zh'),
      initialDate: widget.initialDate ?? DateTime.now(),
      firstDate: DateTime(1960),  // 设置能够选择的最小范围
      lastDate: DateTime.now(),   // 设置能够选择的最大值
    );
    setState(() {
      selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectDate,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            selectedDate != null
              ? DateFormat('yyyy-MM-dd', 'zh_CN').format(selectedDate!)
              : widget.initialDate != null
                ? DateFormat('yyyy-MM-dd', 'zh_CN').format(widget.initialDate!)
                : '请选择',
            style: Theme.of(context).textTheme.bodyLarge
          ),
          const SizedBox(width: 6),
          const Icon(Ionicons.create_outline, size: 20,)
        ],
      ),
    );
  }

}