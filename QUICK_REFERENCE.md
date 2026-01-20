# Quick Reference - What Changed and Why

## Problem Solved ✅

| Issue | Solution |
|-------|----------|
| Hardcoded calendar dates | Now uses Firestore data with dynamic calculations |
| No user personalization | Shows user name & today's actual date on home page |
| Incorrect period predictions | Implements proper cycle algorithm based on last period date |
| Mismatched data across screens | Central CycleDataService ensures all screens use same data |
| Non-interactive products | Products now navigate to shopping page |
| No way to update cycle info | Added Edit button with re-setup flow |
| Static "Next Period" card | Now displays dynamic calculated dates |
| Calendar screen out of sync | Calendar screen now fetches real data from service |

---

## How It Works Now

### When App Starts
1. HomeScreen loads CycleDataService
2. Service fetches user data from Firestore
3. CycleAlgorithm calculates all dates based on last period + cycle length
4. UI renders with accurate data

### When User Clicks Edit
1. FirstTimeSetup dialog opens
2. User updates cycle information
3. CycleDataService saves to Firestore
4. All screens automatically update

### When User Navigates
- Calendar Screen: Shows same cycle data as Home Screen
- Shopping Page: Products are clickable (navigate via bottom nav)
- All changes persist across app sessions

---

## Key Functions You Should Know

### In HomeScreen
```dart
cycleService.getDayType(date)        // Returns: period/fertile/ovulation/normal
cycleService.getNextPeriodDateRange() // Returns: DateRange with formatted string
cycleService.getCurrentCycleDay()    // Returns: 1-28 (or based on cycle length)
```

### In CycleAlgorithm
```dart
algo.getType(date)        // Day type for any date
algo.getNextPeriodStart() // Next period start date
algo.getCurrentCycleDay() // Current day in cycle (1-indexed)
```

---

## Database Structure (Firestore)

Users collection expects these fields:
```json
{
  "name": "User's Name",
  "email": "user@example.com",
  "dateOfBirth": Timestamp,
  "lastPeriodDate": Timestamp,
  "cycleLength": 28,
  "periodDuration": 5,
  "setupCompleted": true,
  "setupDate": Timestamp
}
```

---

## Testing Quick Commands

### Check if data loads correctly
1. Go to home page → Should see user name and date
2. Check if "Your Next Period" shows a date range
3. Look at calendar → Colors should show period/fertile/ovulation

### Test edit functionality
1. Click Edit button on home page
2. Change cycle length or last period date
3. Submit and go to calendar → Should see updated colors

### Verify sync
1. Check home page calendar colors
2. Go to Tracker → Should show identical colors
3. Click on a date → Should show correct cycle day

---

## Common Issues & Solutions

| Issue | Check |
|-------|-------|
| Calendar shows no colors | Firestore data loaded? Check DevTools |
| User name shows "User" | User not saved to Firestore? |
| Edit button missing | setupCompleted = false in Firestore |
| Dates don't match | CycleDataService loaded correctly? |
| Products don't navigate | Make sure index state changes in TabBar |

---

## Files to Understand

1. **cycle_data_service.dart** - The brain of the app, manages all cycle calculations
2. **cycle_algorithm.dart** - Mathematical logic for period/fertile/ovulation days
3. **home_screen.dart** - Main UI using CycleDataService
4. **calendar_screen.dart** - Tracker using CycleDataService
5. **first_time_setup.dart** - Data collection and updates

---

## Next Time You Need to Change Something

If you need to modify cycle logic:
1. Edit `cycle_algorithm.dart` → CycleAlgorithm.getType()
2. Changes will automatically reflect everywhere

If you need to add new features using cycle data:
1. Import `cycle_data_service.dart`
2. Call `CycleDataService()` to get singleton instance
3. Use methods like `getDayType()`, `getNextPeriodDateRange()`, etc.

If you need to add new data fields:
1. Add field to Firestore
2. Update `loadUserCycleData()` method
3. Update `updateCycleData()` method
4. Use field in your widgets
