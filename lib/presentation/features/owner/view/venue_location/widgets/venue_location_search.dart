import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class VenueLocationSearch extends StatelessWidget {
  const VenueLocationSearch({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.message,
    required this.isSuccess,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isSearching;
  final String message;
  final bool isSuccess;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              decoration: InputDecoration(
                hintText: 'Tìm theo địa chỉ venue',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Tìm địa chỉ',
                  onPressed: isSearching ? null : onSearch,
                  icon: isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isSuccess ? Icons.location_on_outlined : Icons.info_outline,
                    size: 18,
                    color:
                        isSuccess ? AppColors.primary : Colors.orange.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
