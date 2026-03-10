import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FigmaFilterSelection {
  final String location;
  final String category;
  final String price;

  const FigmaFilterSelection({
    required this.location,
    required this.category,
    required this.price,
  });
}

Future<FigmaFilterSelection?> showFigmaFilterSheet(
  BuildContext context, {
  String selectedLocation = 'Area',
  String selectedCategory = 'Service',
  String selectedPrice = 'Rs',
  List<String> locationOptions = const ['Area', 'Block', 'Distance'],
  List<String> categoryOptions = const ['Service', 'Type', 'Brand'],
  List<String> priceOptions = const ['Rs', 'Rs+', 'Rs++'],
}) {
  return showModalBottomSheet<FigmaFilterSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FigmaFilterSheet(
      selectedLocation: selectedLocation,
      selectedCategory: selectedCategory,
      selectedPrice: selectedPrice,
      locationOptions: locationOptions,
      categoryOptions: categoryOptions,
      priceOptions: priceOptions,
    ),
  );
}

class _FigmaFilterSheet extends StatefulWidget {
  final String selectedLocation;
  final String selectedCategory;
  final String selectedPrice;
  final List<String> locationOptions;
  final List<String> categoryOptions;
  final List<String> priceOptions;

  const _FigmaFilterSheet({
    required this.selectedLocation,
    required this.selectedCategory,
    required this.selectedPrice,
    required this.locationOptions,
    required this.categoryOptions,
    required this.priceOptions,
  });

  @override
  State<_FigmaFilterSheet> createState() => _FigmaFilterSheetState();
}

class _FigmaFilterSheetState extends State<_FigmaFilterSheet> {
  late String _location;
  late String _category;
  late String _price;

  @override
  void initState() {
    super.initState();
    _location = widget.selectedLocation;
    _category = widget.selectedCategory;
    _price = widget.selectedPrice;
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Container(
      height: h * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(44),
                bottomRight: Radius.circular(44),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF3195AB),
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 36 / 1.8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 32),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SvgPicture.asset(
            'assets/icons/mdi_filter-outline.svg',
            width: 34,
            height: 34,
            colorFilter: const ColorFilter.mode(Color(0xFFF2C100), BlendMode.srcIn),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Location'),
                  ...widget.locationOptions.map(
                    (option) => _radioRow(
                      option,
                      _location == option,
                      () => setState(() => _location = option),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Category'),
                  ...widget.categoryOptions.map(
                    (option) => _radioRow(
                      option,
                      _category == option,
                      () => setState(() => _category = option),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Price'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.priceOptions.map((option) {
                      final selected = _price == option;
                      return GestureDetector(
                        onTap: () => setState(() => _price = option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF3195AB)
                                  : const Color(0xFFE6E6E6),
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? const Color(0xFF3195AB)
                                  : const Color(0xFF4F4F4F),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(
                    context,
                    FigmaFilterSelection(
                      location: _location,
                      category: _category,
                      price: _price,
                    ),
                  );
                },
                child: SvgPicture.asset(
                  'assets/icons/Button.svg',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 33 / 1.8,
          fontWeight: FontWeight.w700,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _radioRow(String title, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 25 / 1.8, color: Color(0xFF4A4A4A)),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: const Color(0xFF3195AB),
            ),
          ),
        ],
      ),
    );
  }
}
