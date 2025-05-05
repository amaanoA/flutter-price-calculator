import 'promotion_rules.dart';

/// A calculator for determining the final price based on various inputs and promotions.
class PriceCalculator {
  // Constants for validation
  static const double minPrice = 0.0;
  static const double maxDiscountRate = 100.0;

  /// Calculate final price with all validations
  ///
  /// Takes [originalPrice], [discountRate], [shippingFee], and optional [promotions]
  /// Returns the calculated final price after applying all discounts and promotions
  double calculatePrice({
    required double originalPrice,
    required double discountRate,
    required double shippingFee,
    List<PromotionRule> promotions = const [],
  }) {
    // Validate inputs
    if (originalPrice < minPrice) {
      throw ArgumentError('Original price cannot be negative');
    }

    if (discountRate < minPrice || discountRate > maxDiscountRate) {
      throw ArgumentError('Discount rate must be between 0 and 100');
    }

    if (shippingFee < minPrice) {
      throw ArgumentError('Shipping fee cannot be negative');
    }

    // Calculate base discounted price
    final double discountAmount = originalPrice * discountRate / 100;
    final double discountedPrice = originalPrice - discountAmount;

    // Apply additional promotion rules
    double finalPrice = discountedPrice;
    for (final promotion in promotions) {
      finalPrice = promotion.apply(finalPrice, originalPrice);
    }

    // Add shipping fee
    finalPrice += shippingFee;

    // Ensure final price is not negative
    return finalPrice > 0 ? finalPrice : 0;
  }
}
