import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../address/view/screens/address_list_screen.dart';
import '../../../../address/viewmodel/address_viewmodel.dart';
import '../../../../address/data/models/address_model.dart';
import 'address_list_item.dart';

class SavedAddressList extends StatelessWidget {
  final List<AddressModel> addresses;
  final String? selectedAddressId;
  final AddressViewModel addressVM;
  final Function(AddressModel) onAddressSelected;
  final VoidCallback onRefresh;

  const SavedAddressList({
    super.key,
    required this.addresses,
    required this.selectedAddressId,
    required this.addressVM,
    required this.onAddressSelected,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Địa chỉ đã lưu",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressListScreen(),
                  ),
                );
                onRefresh();
              },
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.primary),
            )
          ],
        ),
        const SizedBox(height: 8),
        if (addressVM.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (addresses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text("Bạn chưa lưu địa chỉ nào"),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return AddressListItem(
                addressModel: address,
                isSelected: selectedAddressId == address.id,
                onTap: () => onAddressSelected(address),
              );
            },
          ),
      ],
    );
  }
}
