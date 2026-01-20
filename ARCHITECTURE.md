# Architecture Diagram - Liora App Data Flow

## Before (❌ Issues)
```
Home Screen              Calendar Screen           Setup Dialog
    ↓                        ↓                          ↓
Hardcoded               Hardcoded              Separate Firebase
algo values             values                 Save Logic
    ↓                        ↓                          ↓
Mismatched Data    ❌ Out of Sync          No Persistence Check
```

## After (✅ Fixed)
```
┌─────────────────────────────────────────────────────────┐
│                    Firestore Database                    │
│  (User Data: lastPeriodDate, cycleLength, periodDuration) │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ↓
         ┌─────────────────────────┐
         │  CycleDataService       │  ← Singleton
         │  (Central Hub)          │
         ├─────────────────────────┤
         │ • loadUserCycleData()   │
         │ • updateCycleData()     │
         │ • getDayType()          │
         │ • getNextPeriodDate()   │
         │ • getCurrentCycleDay()  │
         └────────┬────────────────┘
                  │
        ┌─────────┴─────────┐
        ↓                   ↓
    ┌──────────────┐  ┌──────────────┐
    │ HomeScreen   │  │ CalendarScreen│
    ├──────────────┤  ├──────────────┤
    │ • Calendar   │  │ • Month View │
    │ • Next Period│  │ • Day Colors │
    │ • Products   │  │ • Cycle Day  │
    │ • User Name  │  │ • Edit Btn   │
    │ • Edit Btn   │  └──────────────┘
    └──────┬───────┘
           │
           ↓
    ┌─────────────────────────────────┐
    │  FirstTimeSetup (Edit Dialog)    │
    │  ├─ Ask: Last Period Date        │
    │  ├─ Ask: Cycle Length            │
    │  ├─ Ask: Period Duration         │
    │  └─ Save via CycleDataService    │
    └─────────────────────────────────┘
```

---

## Data Flow for New Period Date

```
User Clicks "Edit"
    ↓
FirstTimeSetup Dialog Opens
    ↓
User Enters:
├─ Last Period Date: Jan 15, 2025
├─ Cycle Length: 28 days
└─ Period Duration: 5 days
    ↓
CycleDataService.updateCycleData()
    ↓
FirebaseFirestore Update
    ↓
All Screens Reload ← HomeScreen.setState()
    ↓
Calendar Now Shows:
├─ Period: Jan 15-19 (pink)
├─ Fertile: Jan 18-25 (teal)
├─ Ovulation: Jan 29 (purple)
└─ Next Period: Feb 12-16
```

---

## How Cycle Calculation Works

```
Last Period Date: Jan 15, 2025
Cycle Length: 28 days
Period Duration: 5 days

Today: Jan 20, 2025
Days Since Last Period: 5 days
Position in Current Cycle: 5 (Day 5)

✓ Currently in PERIOD (Days 0-4) → RED/PINK
✗ Not in Fertile Window yet (Days 9-18)
✗ Ovulation not yet (Day 14)

Next Period Start: Feb 12, 2025
Formula: Today + (28 - 5) = Jan 20 + 23 = Feb 12
```

---

## Widget Component Structure

```
HomeScreen
├─ Header Section
│  ├─ App Logo + Edit Button
│  ├─ User Greeting
│  └─ Today's Date
├─ Calendar Card
│  └─ TableCalendar (colors from CycleDataService)
├─ Next Period Card
│  └─ Dynamic date range (from CycleDataService)
├─ Recommended Products Section
│  └─ Product items (clickable → Shopping page)
└─ BottomNavigationBar

CalendarScreen
├─ AppBar
│  ├─ Close Button
│  ├─ Month/Year Toggle
│  └─ Focus controls
├─ TableCalendar (full view)
├─ Edit Period Button
└─ Bottom Card (cycle day info)
```

---

## Service Integration Points

```
CycleDataService
├─ Used by: HomeScreen
│  ├─ Initialize: initState()
│  ├─ Get data: cycleService.getDayType(date)
│  └─ Update: _showEditSetup()
│
├─ Used by: CalendarScreen
│  ├─ Initialize: initState()
│  └─ Get data: cycleService.getDayType(date)
│
└─ Used by: FirstTimeSetup
   ├─ Update data: cycleService.updateCycleData()
   └─ Trigger reload in calling screen
```

---

## Example: Updating Cycle Data

### Before (Old Code)
```dart
// ❌ Hardcoded - Not synced
final algo = CycleAlgorithm(
  lastPeriod: DateTime(2025, 1, 10),
  cycleLength: 28,
  periodLength: 5,
);
```

### After (New Code)
```dart
// ✅ Dynamic - Synced across app
late CycleDataService cycleService;

@override
void initState() {
  super.initState();
  cycleService = CycleDataService();
  cycleService.loadUserCycleData(); // Load from Firebase
}

// Use anywhere
DayType dayType = cycleService.getDayType(date);
```

---

## State Management Flow

```
User Action
    ↓
    ├─ Click Edit
    │  └─ _showEditSetup()
    │     └─ FirstTimeSetup Dialog
    │        └─ User saves data
    │           └─ cycleService.updateCycleData()
    │              └─ Firestore updated
    │                 └─ setState() in HomeScreen
    │                    └─ UI rebuilds with new colors
    │
    ├─ Navigate to Calendar
    │  └─ CalendarScreen loads
    │     └─ cycleService.loadUserCycleData()
    │        └─ Shows same data as HomeScreen
    │
    └─ Click Product
       └─ setState(() => index = 2)
          └─ Navigate to Shopping Page
```

---

## Key Improvements Summary

| Aspect | Before | After |
|--------|--------|-------|
| **Data Source** | Hardcoded | Firebase + Service |
| **Calculation** | Static | Dynamic, Real-time |
| **Sync** | Manual, Error-prone | Automatic across screens |
| **User Info** | None | Name + Date displayed |
| **Edit Flow** | No way to change | Full re-setup capability |
| **Calendar Accuracy** | ❌ Wrong dates | ✅ Correct predictions |
| **Navigation** | Products static | Products → Shopping |
| **Persistence** | Firebase only | Service + Firebase |

---

## Testing Quick Checklist

✅ Calendar colors match predicted cycle
✅ User name shows on home page  
✅ Today's date displays correctly
✅ "Next Period" card shows correct dates
✅ Products navigate to shopping page
✅ Edit button works and updates all screens
✅ Calendar screen shows same data
✅ No data loss on app restart
