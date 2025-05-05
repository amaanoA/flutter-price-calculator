import 'package:flutter/material.dart';

/// Help screen that provides documentation about the app
class HelpScreen extends StatelessWidget {
  /// Creates a new help screen
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Calculator Help'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            title: 'Basic Fields',
            content: _buildBasicFieldsHelp(),
          ),
          const Divider(),
          _buildSection(
            title: 'Promotional Rules',
            content: _buildPromotionRulesHelp(),
          ),
          const Divider(),
          _buildSection(
            title: 'Calculation Logic',
            content: _buildCalculationLogicHelp(),
          ),
          const Divider(),
          _buildSection(
            title: 'Examples',
            content: _buildExamplesHelp(),
          ),
        ],
      ),
    );
  }

  /// Builds a section with a title and content
  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content,
        const SizedBox(height: 16),
      ],
    );
  }

  /// Help content for basic input fields
  Widget _buildBasicFieldsHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _HelpItem(
          title: 'Original Price (\$)',
          description:
              'The starting price of the item before any discounts or fees are applied. '
              'This value must be greater than or equal to zero.',
        ),
        _HelpItem(
          title: 'Discount Rate (%)',
          description:
              'The percentage discount to apply to the original price. '
              'This value must be between 0 and 100. '
              'For example, 20 means a 20% discount will be applied.',
        ),
        _HelpItem(
          title: 'Shipping Fee (\$)',
          description:
              'The cost of shipping that will be added to the final price. '
              'This value must be greater than or equal to zero.',
        ),
      ],
    );
  }

  /// Help content for promotion rules
  Widget _buildPromotionRulesHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _HelpItem(
          title: 'Coupon',
          description:
              'A fixed amount discount applied to the price after the percentage discount. '
              'Enter the coupon value in dollars. '
              'The coupon value will be subtracted from the discounted price.',
        ),
        _HelpItem(
          title: 'Buy X Get Y Promotion',
          description: 'A "Buy X, Get Y Free" promotion. '
              'For example, "Buy 3, Get 1 Free" means for every 3 items purchased, '
              'you get 1 additional item for free. '
              '• Buy Quantity (X): Number of items you need to buy\n'
              '• Get Free Quantity (Y): Number of free items you receive\n'
              '• Current Item Quantity: Total number of items in your cart\n'
              '• Item Price: The price per item',
        ),
        _HelpItem(
          title: 'Spend & Save Promotion',
          description:
              'A promotion that offers a fixed discount when you spend over a certain amount. '
              'For example, "Spend \$100, Save \$20" means if your original purchase is \$100 or more, '
              'you get a \$20 discount. '
              '• Spend Threshold: Minimum purchase amount required to qualify\n'
              '• Save Amount: The discount you receive when threshold is met',
        ),
      ],
    );
  }

  /// Help content for calculation logic
  Widget _buildCalculationLogicHelp() {
    return const Text(
      'The price is calculated in the following order:\n\n'
      '1. The percentage discount is applied to the original price\n'
      '2. Additional promotion rules are applied in the order:\n'
      '   • Coupon discount\n'
      '   • Buy X Get Y discount\n'
      '   • Spend & Save discount\n'
      '3. Shipping fee is added to the discounted price\n'
      '4. The final price is guaranteed to never be negative\n\n'
      'Note: Multiple promotions can stack, providing cumulative discounts.',
      style: TextStyle(fontSize: 16),
    );
  }

  /// Help content with examples
  Widget _buildExamplesHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _HelpItem(
          title: 'Basic Calculation',
          description: 'Original Price: \$100\n'
              'Discount Rate: 20%\n'
              'Shipping Fee: \$5\n\n'
              'Calculation: \$100 - (\$100 × 20%) + \$5 = \$100 - \$20 + \$5 = \$85',
        ),
        _HelpItem(
          title: 'With Coupon',
          description: 'Original Price: \$100\n'
              'Discount Rate: 10%\n'
              'Coupon: \$15\n'
              'Shipping Fee: \$5\n\n'
              'Calculation: \$100 - (\$100 × 10%) - \$15 + \$5 = \$100 - \$10 - \$15 + \$5 = \$80',
        ),
        _HelpItem(
          title: 'With Buy X Get Y',
          description: 'Original Price: \$80 (4 items at \$20 each)\n'
              'Discount Rate: 0%\n'
              'Buy 3 Get 1 Free\n'
              'Current Quantity: 4\n'
              'Item Price: \$20\n'
              'Shipping Fee: \$5\n\n'
              'Calculation: \$80 - \$20 (1 free item) + \$5 = \$65',
        ),
        _HelpItem(
          title: 'With Spend & Save',
          description: 'Original Price: \$120\n'
              'Discount Rate: 0%\n'
              'Spend \$100 Save \$15\n'
              'Shipping Fee: \$10\n\n'
              'Calculation: \$120 - \$15 + \$10 = \$115',
        ),
      ],
    );
  }
}

/// A reusable help item with a title and description
class _HelpItem extends StatelessWidget {
  /// The title of the help item
  final String title;

  /// The description text
  final String description;

  /// Creates a new help item
  const _HelpItem({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
