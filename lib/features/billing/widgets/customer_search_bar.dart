import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/customer_model.dart';
import '../../customers/providers/customer_provider.dart';

class CustomerSearchBar extends ConsumerStatefulWidget {
  final Function(Customer) onCustomerSelected;
  final VoidCallback onAddNew;
  
  const CustomerSearchBar({
    super.key,
    required this.onCustomerSelected,
    required this.onAddNew,
  });

  @override
  ConsumerState<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends ConsumerState<CustomerSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width, 
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            child: Consumer(
              builder: (context, ref, child) {
                final customerState = ref.watch(customerProvider);
                
                if (customerState.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (customerState.searchResults.isEmpty) {
                  if (_controller.text.isNotEmpty) {
                     return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No customers found'),
                    );
                  }
                  return const SizedBox.shrink();
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: customerState.searchResults.length,
                    itemBuilder: (context, index) {
                      final customer = customerState.searchResults[index];
                      return ListTile(
                        title: Text(customer.name),
                        subtitle: Text(customer.mobile),
                        onTap: () {
                          widget.onCustomerSelected(customer);
                          _controller.text = customer.name;
                          _hideOverlay();
                          _focusNode.unfocus();
                          ref.read(customerProvider.notifier).clearSearch();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _onSearchChanged(String query) {
    ref.read(customerProvider.notifier).searchCustomers(query);
    if (_overlayEntry == null && query.isNotEmpty) {
      _showOverlay();
    }
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile *',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && mobileController.text.isNotEmpty) {
                final navigator = Navigator.of(context);
                final notifier = ref.read(customerProvider.notifier);
                
                final newCustomer = await notifier.addCustomer({
                  'name': nameController.text,
                  'mobile': mobileController.text,
                });

                if (newCustomer != null) {
                  widget.onCustomerSelected(newCustomer);
                  _controller.text = newCustomer.name;
                  navigator.pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Customer added successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to add customer'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        padding: const EdgeInsets.all(UIConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.grey300.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search customer by mobile...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            ref.read(customerProvider.notifier).clearSearch();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.grey100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            
            const SizedBox(width: UIConstants.paddingM),
            
            // Add New Customer button
            ElevatedButton.icon(
              onPressed: _showAddCustomerDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('New'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
