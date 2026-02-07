import 'package:flutter/material.dart';

class AddressSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const AddressSearchBar({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD6E1D6),
            )),
        child: Row(
          children: [
            Expanded(
                child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                  hintText: "Tìm kiếm Tỉnh/Thành phố, Quận/Huyện...",
                  hintStyle: TextStyle(color: Colors.grey),
                  suffix: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
            ))
          ],
        ));
  }
}
