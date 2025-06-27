# CardSwiper Fix Documentation

## Issue Description
The app was crashing with the following error:
```
you must display at least one card, and no more than [cardsCount]
Failed assertion: line 162 pos 11: 'numberOfCardsDisplayed >= 1 && numberOfCardsDisplayed <= cardsCount'
```

This error occurred in the BarsScreen when the CardSwiper widget was initialized with an empty bars list.

## Root Cause
The CardSwiper widget in `bars_screen.dart` was configured with:
- `cardsCount: bars.length` (could be 0)
- `numberOfCardsDisplayed: 3` (fixed value)

When `bars.length` was 0, the assertion `numberOfCardsDisplayed <= cardsCount` failed because `3 <= 0` is false.

## Solution Applied

### 1. Added Empty List Check
```dart
Widget _buildBarsList(BuildContext context, List<Bar> bars) {
  // Handle empty bars list - should not happen due to upstream checks, but safety first
  if (bars.isEmpty) {
    return _buildEmptyState();
  }
  // ... rest of the method
}
```

### 2. Dynamic numberOfCardsDisplayed Calculation
```dart
// Calculate numberOfCardsDisplayed based on available bars
// Ensure it's at least 1 and no more than the number of bars available
final numberOfCardsDisplayed = math.min(3, bars.length).clamp(1, bars.length);
```

### 3. Added Required Import
```dart
import 'dart:math' as math;
```

## Comparison with HomeScreen
The `home_screen.dart` already handled this issue correctly by:
- Using `final count = hasUsers ? users.length : 1;` (always >= 1)
- Using `numberOfCardsDisplayed: math.min(3, count)`
- Showing a placeholder card when no users are available

## Files Modified
- `/lib/presentation/screens/bars_screen.dart`
  - Added `dart:math` import
  - Added empty list check in `_buildBarsList`
  - Made `numberOfCardsDisplayed` dynamic based on available bars

## Testing Status
- Code changes are syntactically correct
- Logic follows the same pattern as the working `home_screen.dart`
- Build testing blocked by Android minSdkVersion configuration issue (unrelated to this fix)

## Expected Result
The CardSwiper assertion error should no longer occur when the bars list is empty or has fewer than 3 items.
