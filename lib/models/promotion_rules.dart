/// Base abstract class for all promotion rules
abstract class PromotionRule {
  /// Applies the promotion rule to the current price
  /// 
  /// [currentPrice] is the price after previous promotions
  /// [originalPrice] is the original price before any discounts
  /// Returns the new price after applying this promotion
  double apply(double currentPrice, double originalPrice);
}

/// Applies a percentage discount to the current price
class PercentDiscountRule extends PromotionRule {
  /// The percentage discount to apply (0-100)
  final double percentage;
  
  /// Creates a new percentage discount rule
  /// 
  /// [percentage] must be between 0 and 100
  PercentDiscountRule(this.percentage) {
    if (percentage < 0 || percentage > 100) {
      throw ArgumentError('Percentage must be between 0 and 100');
    }
  }
  
  @override
  double apply(double currentPrice, double originalPrice) {
    final double discount = currentPrice * (percentage / 100);
    return currentPrice - discount;
  }
}

/// Applies a fixed coupon discount if minimum purchase is met
class CouponRule extends PromotionRule {
  /// The fixed amount to discount
  final double couponValue;
  
  /// Optional minimum purchase required to use this coupon
  final double minimumPurchase;
  
  /// Creates a new coupon rule
  /// 
  /// [couponValue] is the fixed discount amount
  /// [minimumPurchase] is the minimum purchase required (defaults to 0)
  CouponRule(this.couponValue, {this.minimumPurchase = 0}) {
    if (couponValue < 0) {
      throw ArgumentError('Coupon value cannot be negative');
    }
    if (minimumPurchase < 0) {
      throw ArgumentError('Minimum purchase cannot be negative');
    }
  }
  
  @override
  double apply(double currentPrice, double originalPrice) {
    if (originalPrice >= minimumPurchase) {
      return currentPrice - couponValue > 0 ? currentPrice - couponValue : 0;
    }
    return currentPrice;
  }
}

/// Implements a "Buy X Get Y Free" promotion
class BuyXGetYRule extends PromotionRule {
  /// Number of items that must be purchased
  final int buyQuantity;
  
  /// Number of free items received
  final int getQuantity;
  
  /// Price per item
  final double itemPrice;
  
  /// Total number of items in cart
  final int currentQuantity;
  
  /// Creates a new Buy X Get Y promotion rule
  /// 
  /// All parameters must be positive numbers
  BuyXGetYRule(this.buyQuantity, this.getQuantity, this.itemPrice, this.currentQuantity) {
    if (buyQuantity <= 0 || getQuantity <= 0 || itemPrice <= 0 || currentQuantity < 0) {
      throw ArgumentError('Invalid parameters for Buy X Get Y rule');
    }
  }
  
  @override
  double apply(double currentPrice, double originalPrice) {
    if (currentQuantity >= buyQuantity) {
      final int applicableSets = currentQuantity ~/ (buyQuantity + getQuantity);
      final int freeItems = applicableSets * getQuantity;
      final double discount = freeItems * itemPrice;
      return currentPrice - discount > 0 ? currentPrice - discount : 0;
    }
    return currentPrice;
  }
}

/// Implements a "Spend X, Save Y" threshold promotion
class SpendSaveRule extends PromotionRule {
  /// Spending threshold that must be met
  final double spendThreshold;
  
  /// Amount saved when threshold is met
  final double saveAmount;
  
  /// Creates a new Spend & Save promotion rule
  /// 
  /// Both parameters must be positive numbers
  SpendSaveRule(this.spendThreshold, this.saveAmount) {
    if (spendThreshold <= 0 || saveAmount <= 0) {
      throw ArgumentError('Invalid parameters for Spend & Save rule');
    }
  }
  
  @override
  double apply(double currentPrice, double originalPrice) {
    if (originalPrice >= spendThreshold) {
      return currentPrice - saveAmount > 0 ? currentPrice - saveAmount : 0;
    }
    return currentPrice;
  }
}