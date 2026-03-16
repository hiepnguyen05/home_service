import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/utils/icon_helper.dart';
import 'package:mobile/features/services/data/models/service_model.dart';
import 'package:mobile/features/services/data/repositories/service_repository.dart';
import 'package:mobile/features/partner/data/models/partner_request_model.dart';

class AddServicePicker extends StatelessWidget {
  final List<PartnerServiceRequest> currentServices;
  final Function(PartnerServiceRequest) onServiceSelected;

  const AddServicePicker({
    super.key,
    required this.currentServices,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text('Chọn kỹ năng mới',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<ServiceModel>>(
              stream: ServiceRepository().getServices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allServices = snapshot.data!;
                final availableServices = allServices
                    .where((s) => !currentServices
                        .any((ts) => ts.serviceId == s.id))
                    .toList();

                if (availableServices.isEmpty) {
                  return const Center(child: Text('Không còn dịch vụ nào để thêm.'));
                }

                return ListView.builder(
                  itemCount: availableServices.length,
                  itemBuilder: (context, index) {
                    final s = availableServices[index];
                    return ListTile(
                      leading: Icon(IconHelper.getIcon(s.iconName),
                          color: AppColors.primary),
                      title: Text(s.name),
                      onTap: () {
                        onServiceSelected(PartnerServiceRequest(
                          serviceId: s.id,
                          serviceName: s.name,
                          price: '',
                          iconName: s.iconName,
                        ));
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

