import 'package:flutter/material.dart';
import '../models/price_calculator.dart';
import '../models/promotion_rules.dart';
import 'help_screen.dart';

/// Main screen for the price calculator application
class PriceCalculatorScreen extends StatefulWidget {
  /// Creates a price calculator screen
  const PriceCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<PriceCalculatorScreen> createState() => _PriceCalculatorScreenState();
}

class _PriceCalculatorScreenState extends State<PriceCalculatorScreen> {
  static const double _defaultPadding = 16.0;
  static const double _smallPadding = 12.0;
  static const double _mediumPadding = 24.0;
  static const double _borderRadius = 8.0;

  final _formKey = GlobalKey<FormState>();
  final _calculator = PriceCalculator();

  // Input controllers
  final _originalPriceController = TextEditingController();
  final _discountRateController = TextEditingController();
  final _shippingFeeController = TextEditingController();

  // Promotion states
  bool _useCoupon = false;
  double _couponValue = 0;
  bool _useBuyXGetY = false;
  int _buyQuantity = 0;
  int _getQuantity = 0;
  int _itemQuantity = 0;
  double _itemPrice = 0;
  bool _useSpendSave = false;
  double _spendThreshold = 0;
  double _saveAmount = 0;

  double _finalPrice = 0;
  String _errorMessage = '';

  @override
  void dispose() {
    _originalPriceController.dispose();
    _discountRateController.dispose();
    _shippingFeeController.dispose();
    super.dispose();
  }

  /// Open the help screen
  void _openHelpScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HelpScreen()),
    );
  }

  /// Calculate the final price based on inputs and selected promotions
  void _calculatePrice() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = '';

      try {
        final originalPrice = double.parse(_originalPriceController.text);
        final discountRate = double.parse(_discountRateController.text);
        final shippingFee = double.parse(_shippingFeeController.text);

        // Create promotion rules based on selected options
        final List<PromotionRule> promotions = [];

        if (_useCoupon) {
          promotions.add(CouponRule(_couponValue));
        }

        if (_useBuyXGetY) {
          promotions.add(BuyXGetYRule(
              _buyQuantity, _getQuantity, _itemPrice, _itemQuantity));
        }

        if (_useSpendSave && originalPrice >= _spendThreshold) {
          promotions.add(SpendSaveRule(_spendThreshold, _saveAmount));
        }

        _finalPrice = _calculator.calculatePrice(
          originalPrice: originalPrice,
          discountRate: discountRate,
          shippingFee: shippingFee,
          promotions: promotions,
        );
      } catch (e) {
        _errorMessage = 'Error: ${e.toString()}';
        _finalPrice = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Calculator'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(_defaultPadding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Base inputs
              _buildInputField(
                controller: _originalPriceController,
                label: 'Original Price (\$)',
                validator: _validatePrice,
              ),
              const SizedBox(height: _smallPadding),
              _buildInputField(
                controller: _discountRateController,
                label: 'Discount Rate (%)',
                validator: _validateDiscountRate,
              ),
              const SizedBox(height: _smallPadding),
              _buildInputField(
                controller: _shippingFeeController,
                label: 'Shipping Fee (\$)',
                validator: _validateShippingFee,
              ),

              const SizedBox(height: _mediumPadding),
              Text('Promotional Rules', style: theme.textTheme.titleLarge),

              // Coupon section
              _buildPromotionToggle(
                title: 'Apply Coupon',
                value: _useCoupon,
                onChanged: (value) {
                  setState(() {
                    _useCoupon = value ?? false;
                  });
                },
              ),
              if (_useCoupon) _buildCouponSection(),

              // Buy X Get Y section
              _buildPromotionToggle(
                title: 'Buy X Get Y Promotion',
                value: _useBuyXGetY,
                onChanged: (value) {
                  setState(() {
                    _useBuyXGetY = value ?? false;
                  });
                },
              ),
              if (_useBuyXGetY) _buildBuyXGetYSection(),

              // Spend & Save section
              _buildPromotionToggle(
                title: 'Spend & Save Promotion',
                value: _useSpendSave,
                onChanged: (value) {
                  setState(() {
                    _useSpendSave = value ?? false;
                  });
                },
              ),
              if (_useSpendSave) _buildSpendSaveSection(),

              const SizedBox(height: _mediumPadding),
              _buildCalculateButton(),

              // Results section
              const SizedBox(height: _mediumPadding),
              if (_errorMessage.isNotEmpty) _buildErrorMessage(),

              const SizedBox(height: _smallPadding),
              _buildResultCard(theme),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openHelpScreen,
        tooltip: 'Help',
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        child: const Icon(Icons.help_outline),
      ),
    );
  }

  /// Build a text form field with consistent styling
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
    );
  }

  /// Build a promotion toggle switch
  Widget _buildPromotionToggle({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Build the coupon input section
  Widget _buildCouponSection() {
    return Padding(
      padding: const EdgeInsets.only(left: _defaultPadding),
      child: TextFormField(
        // Remove initialValue and use controller instead
        controller: TextEditingController(text: _couponValue.toString()),
        decoration: const InputDecoration(
          labelText: 'Coupon Value (\$)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
          ),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) {
          setState(() {
            _couponValue = double.tryParse(value) ?? 0;
          });
        },
      ),
    );
  }

  /// Build the Buy X Get Y input section
  Widget _buildBuyXGetYSection() {
    return Padding(
      padding: const EdgeInsets.only(left: _defaultPadding),
      child: Column(
        children: [
          TextFormField(
            // Fix for all other TextFormFields with initialValue
            controller: TextEditingController(text: _buyQuantity.toString()),
            decoration: const InputDecoration(
              labelText: 'Buy Quantity (X)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _buyQuantity = int.tryParse(value) ?? 0;
              });
            },
          ),
          const SizedBox(height: _smallPadding),
          TextFormField(
            controller: TextEditingController(text: _getQuantity.toString()),
            decoration: const InputDecoration(
              labelText: 'Get Free Quantity (Y)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _getQuantity = int.tryParse(value) ?? 0;
              });
            },
          ),
          const SizedBox(height: _smallPadding),
          TextFormField(
            controller: TextEditingController(text: _itemQuantity.toString()),
            decoration: const InputDecoration(
              labelText: 'Current Item Quantity',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _itemQuantity = int.tryParse(value) ?? 0;
              });
            },
          ),
          const SizedBox(height: _smallPadding),
          TextFormField(
            controller: TextEditingController(text: _itemPrice.toString()),
            decoration: const InputDecoration(
              labelText: 'Item Price (\$)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {
                _itemPrice = double.tryParse(value) ?? 0;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Build the Spend & Save input section
  Widget _buildSpendSaveSection() {
    return Padding(
      padding: const EdgeInsets.only(left: _defaultPadding),
      child: Column(
        children: [
          TextFormField(
            controller: TextEditingController(text: _spendThreshold.toString()),
            decoration: const InputDecoration(
              labelText: 'Spend Threshold (\$)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {
                _spendThreshold = double.tryParse(value) ?? 0;
              });
            },
          ),
          const SizedBox(height: _smallPadding),
          TextFormField(
            controller: TextEditingController(text: _saveAmount.toString()),
            decoration: const InputDecoration(
              labelText: 'Save Amount (\$)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {
                _saveAmount = double.tryParse(value) ?? 0;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Build the calculate button
  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _calculatePrice,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        'Calculate Price',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Build the error message display
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(_smallPadding),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Text(
        _errorMessage,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  /// Build the result card with final price
  Widget _buildResultCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Final Price:', style: theme.textTheme.titleMedium),
            const SizedBox(height: _smallPadding),
            Text(
              '\$${_finalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Validate the price input
  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the original price';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    if (double.parse(value) < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  /// Validate the discount rate input
  String? _validateDiscountRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the discount rate';
    }
    final doubleValue = double.tryParse(value);
    if (doubleValue == null) {
      return 'Please enter a valid number';
    }
    if (doubleValue < 0 || doubleValue > 100) {
      return 'Discount must be between 0 and 100';
    }
    return null;
  }

  /// Validate the shipping fee input
  String? _validateShippingFee(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the shipping fee';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    if (double.parse(value) < 0) {
      return 'Shipping fee cannot be negative';
    }
    return null;
  }
}
