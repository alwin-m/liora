# LIORA Design Principles 🌸

## Table of Contents
1. [Design Philosophy](#design-philosophy)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Spacing & Layout](#spacing--layout)
5. [Border Radius & Shapes](#border-radius--shapes)
6. [Shadows & Depth](#shadows--depth)
7. [Component Patterns](#component-patterns)
8. [Icons & Imagery](#icons--imagery)
9. [Animations & Transitions](#animations--transitions)
10. [Accessibility](#accessibility)
11. [Design Patterns & Examples](#design-patterns--examples)
12. [What to Avoid](#what-to-avoid)

---

## Design Philosophy

### Core Principles

LIORA's design is built on **emotional safety, comfort, and femininity**. Every design decision is intentional, with psychology at its core.

#### 1. **Psychological Comfort & Safety**
- Users are logging intimate, personal data about their bodies
- Design must feel non-judgmental, supportive, and nurturing
- Colors, shapes, and interactions should evoke calm confidence
- The app should feel like a trusted friend, not a clinical tool

#### 2. **Soft & Welcoming Aesthetics**
- **Rounded corners over sharp edges** — Psychology: Sharp angles trigger subconscious stress and danger signals. Rounded shapes feel safe, approachable, and human
- **Gradient flows** — Creates depth and visual flow without harshness
- **Generous spacing** — Breathing room reduces cognitive load and anxiety
- **Subtle shadows** — Provides depth hierarchy without creating visual weight

#### 3. **Privacy-First Mindset**
- All UI should communicate data safety
- No intrusive design elements
- Transparent data handling with clear messaging
- Minimalist approach to reduce tracking appearance

#### 4. **Feminine Energy (Not Restrictive)**
- Celebrates menstruation positively without stereotyping
- Uses soft, warm tones (not overly pink or cutesy)
- Empowers users with knowledge and tools
- Inclusive of all gender identities and menstrual experiences

---

## Color System

### Color Psychology in LIORA

LIORA's palette is carefully chosen to evoke specific emotional responses:

#### **Primary Colors**

```
Primary Pink: #FDE2EA
├─ Psychology: Soft, nurturing, non-clinical
├─ Usage: Backgrounds, secondary elements
└─ Association: Safety, compassion, gentle strength
```

```
Background White: #FFF6F9
├─ Psychology: Clean, professional, with warmth
├─ Usage: Main scaffold background
└─ Association: Clarity, purity, fresh start
```

```
Accent Rose: #F7B2C4
├─ Psychology: Warm, energetic, approachable
├─ Usage: Buttons, primary actions, highlights
└─ Association: Activity, confidence, femininity
```

```
Deep Rose: #E8849A
├─ Psychology: Deeper, more sophisticated warmth
├─ Usage: Secondary buttons, emphasis, borders
└─ Association: Trust, maturity, strength
```

#### **Semantic Colors** (Cycle-Related)

These colors convey biological meaning while remaining emotionally safe:

```
Period Day - Soft Rose: #FFB5C2
├─ Psychology: Warm, recognizable red-family
├─ Usage: Period phase days on calendar
├─ Medical Association: Menstruation
└─ Emotional Tone: Normal, natural, embraced

Fertile Window - Lavender: #E8D5F2
├─ Psychology: Cool, intellectual, mysterious
├─ Usage: Fertility window on calendar
├─ Medical Association: Conception possibility
└─ Emotional Tone: Informed, empowered

Predicted Period - Light Coral: #FFCDD2
├─ Psychology: Soft, predictable, gentle
├─ Usage: Predicted period dates
├─ Medical Association: Future menstruation
└─ Emotional Tone: Prepared, in control

Ovulation Day - Soft Purple: #D4B5FF
├─ Psychology: Regal, energetic, peak
├─ Usage: Ovulation day marker
├─ Medical Association: Peak fertility
└─ Emotional Tone: Power, clarity, potential
```

#### **Text Colors**

```
Primary Text: #2E2E2E (Charcoal)
└─ Usage: Main content, headings, actionable text

Secondary Text: #6B6B6B (Medium Gray)
└─ Usage: Subheadings, supporting information

Muted Text: #9E9E9E (Light Gray)
└─ Usage: Placeholder text, hints, disabled states

On-Pink Text: #5C4A50 (Dark Taupe)
└─ Usage: Text on soft pink backgrounds
```

#### **UI Element Colors**

```
Card Background: #FFFFFF (Pure White)
├─ Psychology: Clean, organized, content-focused
└─ Usage: Cards, sheets, elevated surfaces

Divider: #F5E6EA (Very Light Pink)
├─ Psychology: Soft separation without harshness
└─ Usage: Visual separation between sections

Input Background: #FFF0F3 (Pale Pink)
├─ Psychology: Indicates interactive areas subtly
└─ Usage: TextField backgrounds, input areas

Input Border: #FFD6E0 (Soft Rose Border)
├─ Psychology: Clear interactive boundaries
└─ Usage: TextInput borders (enabled state)
```

#### **Status Colors** (Gentle Palette)

```
Success: #A8E6CF (Soft Mint)
├─ Psychology: Calm affirmation, natural growth
├─ Usage: Successful actions, confirmations
└─ Why not bright green? Bright green feels clinical

Warning: #FFE0B2 (Soft Amber)
├─ Psychology: Alert without urgency/danger
├─ Usage: Informational alerts, cautions
└─ Why not orange? Orange is too energetic for warnings

Error: #FFCDD2 (Soft Red)
├─ Psychology: Warning that's compassionate
├─ Usage: Error states, required fields
└─ Why not bright red? Bright red triggers stress responses
```

### Color Usage Guidelines

#### ✅ **DO:**
- Use Primary Pink (#FDE2EA) for backgrounds and filters
- Use Accent Rose (#F7B2C4) for all primary actions (buttons, CTAs)
- Use Deep Rose (#E8849A) for secondary actions and emphasis
- Use semantic calendar colors consistently for cycle phases
- Layer colors with gradients for visual depth
- Apply colors with psychological intent

#### ❌ **AVOID:**
- Using harsh primary pink (#FF1493) or hot pink — too stimulating, clinical
- Using neon or bright colors — contradicts "safe space" feeling
- Mixing warm and cool colors heavily — creates visual discord
- Using pure black (#000000) — use textPrimary (#2E2E2E) instead for warmth
- Using pure grays without warmth — feels sterile and cold
- Bright red (#FF0000) for errors — use soft red (#FFCDD2) instead
- Clashing semantic colors — maintain calendar color consistency throughout app
- Overusing colors — maintain 60/30/10 rule: 60% background, 30% primary, 10% accent

### Gradient Usage

```dart
// Primary Gradient (Subtle page transitions)
LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [#FFF6F9, #FDE2EA],
);
// Psychology: Guides eye from cool to warm, creates peaceful downward flow

// Card Gradient (Subtle depth)
LinearGradient cardGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [#FFFFFF, #FFF8FA],
);
// Psychology: Barely perceptible, adds refinement without visual weight
```

---

## Typography

### Font Families

LIORA uses two carefully selected Google Fonts:

#### **Outfit (Headings & Labels)**
```
Weight: 700 (h1), 600 (h2, h3), 500 (labels)
Purpose: Modern, geometric, friendly
Psychology: Contemporary, professional, approachable
Usage: All headings, labels, button text
Characteristics: Open letterforms, slight geometric feel
```

#### **Inter (Body Text)**
```
Weight: 400 (regular), 500 (semi-bold)
Purpose: Maximum readability, neutral, clean
Psychology: Invisible—doesn't distract from content
Usage: All body text, descriptions, content
Characteristics: Perfect legibility at all sizes
```

### Typography Hierarchy

#### **Heading 1 (h1)**
```
Font: Outfit
Size: 32px
Weight: 700 (Bold)
Color: #2E2E2E (textPrimary)
Letter Spacing: -0.5px
Line Height: 1.2
Usage: Screen titles, major sections, onboarding steps
Psychology: Commanding, authoritative, creates visual anchors
Example Context: Onboarding screens, settings page titles
```

#### **Heading 2 (h2)**
```
Font: Outfit
Size: 24px
Weight: 600 (Semi-Bold)
Color: #2E2E2E (textPrimary)
Letter Spacing: -0.3px
Line Height: 1.3
Usage: Section headers, card titles, dialog titles
Psychology: Clear hierarchy without overwhelming
Example Context: "Track Your Cycle", "Symptoms", "Settings"
```

#### **Heading 3 (h3)**
```
Font: Outfit
Size: 20px
Weight: 600 (Semi-Bold)
Color: #2E2E2E (textPrimary)
Letter Spacing: 0px
Line Height: 1.4
Usage: Subsection headers, status labels, emphasis
Psychology: Friendly, accessible
Example Context: Phase names, card headers, action titles
```

#### **Body Large (bodyLarge)**
```
Font: Inter
Size: 16px
Weight: 400 (Regular)
Color: #2E2E2E (textPrimary)
Line Height: 1.5 (24px)
Usage: Primary content, long-form text, descriptions
Psychology: Optimal readability, comfortable reading speed
Example Context: Onboarding descriptions, cycle explanations, main content
```

#### **Body Medium (bodyMedium)**
```
Font: Inter
Size: 14px
Weight: 400 (Regular)
Color: #6B6B6B (textSecondary)
Line Height: 1.5 (21px)
Usage: Secondary content, metadata, supporting info
Psychology: Still readable, indicates "supporting" info
Example Context: Card descriptions, date information, helper text
```

#### **Body Small (bodySmall)**
```
Font: Inter
Size: 12px
Weight: 400 (Regular)
Color: #9E9E9E (textMuted)
Line Height: 1.4 (16.8px)
Usage: Tertiary info, timestamps, timestamps, captions
Psychology: Fine print, non-essential information
Example Context: Last updated, optional fields, fine print
```

#### **Label (label)**
```
Font: Outfit
Size: 14px
Weight: 500 (Medium)
Color: #2E2E2E (textPrimary)
Letter Spacing: +0.1px
Line Height: auto
Usage: Form labels, navigation labels, icon labels
Psychology: Clarity without weight
Example Context: "Email", "Password", tab labels, field names
```

#### **Label Small (labelSmall)**
```
Font: Outfit
Size: 12px
Weight: 500 (Medium)
Color: #6B6B6B (textSecondary)
Letter Spacing: +0.2px
Line Height: auto
Usage: Small labels, category tags, badges
Psychology: Organized, scannable
Example Context: Category badges, secondary labels, hints
```

#### **Button Text (button)**
```
Font: Outfit
Size: 16px
Weight: 600 (Semi-Bold)
Color: #2E2E2E (textPrimary)
Letter Spacing: +0.5px (allcaps feel)
Line Height: auto
Usage: All button labels
Psychology: Confident, clear call-to-action
Example Context: "Continue", "Log Period", "Settings"
```

#### **Calendar (calendarDay)**
```
Font: Outfit
Size: 14px
Weight: 500 (Medium)
Color: #2E2E2E (textPrimary)
Usage: Day numbers in calendar cells
Psychology: Clear, numbered, organized
```

#### **Calendar Header (calendarHeader)**
```
Font: Outfit
Size: 18px
Weight: 600 (Semi-Bold)
Color: #2E2E2E (textPrimary)
Usage: Month/year headers in calendar
Psychology: Clear temporal context
```

### Typography Psychology

**Why Outfit for headings:**
- Geometric letterforms feel modern and safe
- Open spacing feels welcoming, not confined
- Neutral gender expression (not overly stylized)
- Better at larger sizes for display

**Why Inter for body:**
- Invisibly readable (best for content)
- Designed for digital screens
- Neutral, professional, trustworthy
- Minimal cognitive load

### Typography Guidelines

#### ✅ **DO:**
- Use consistent font stack (always Outfit for headings, Inter for body)
- Follow size hierarchy strictly (use defined styles, don't create custom sizes)
- Use letter-spacing for clarity in headings
- Maintain 1.5+ line-height for readability
- Use weight strategically (bold = emphasis, medium = context, regular = content)
- Set color intentionally from defined palette

#### ❌ **AVOID:**
- Mixing fonts casually (stick to Outfit/Inter only)
- Using sizes between defined values
- Colors not in the LIORA palette
- All caps body text (reduces readability)
- Underlines (except for links)
- More than 2 font weights on one screen
- Serif fonts (feels old, not accessible digitally)

---

## Spacing & Layout

### Spacing Scale

LIORA uses a consistent 8px base unit spacing scale:

```
xs  = 4px   (half-increment, micro spacing)
sm  = 8px   (single increment, minimum breathing room)
md  = 16px  (double increment, default spacing)
lg  = 24px  (triple increment, generous padding)
xl  = 32px  (quadruple increment, section spacing)
xxl = 48px  (sextuple increment, major section spacing)
```

### Spacing Applications

#### **Padding (Internal spacing within containers)**

```
Component Padding:
├─ Buttons: 16px (vertical) × 32px (horizontal) = md × lg
│  Psychology: Comfortably tappable, 44px-48px min tap target
├─ Cards: 24px (all sides) = lg
│  Psychology: Generous breathing room, content prominence
├─ Forms / Input Fields: 16px × 20px = md × custom
│  Psychology: Spacious input areas feel less stressful
├─ Screen Edges: 24px (horizontal), 16px (top/bottom) = lg, md
│  Psychology: Safe zones, content doesn't touch edges
└─ Dialog Padding: 28px = custom (bridge between lg and xl)
   Psychology: Centered focus, emphasizes importance
```

#### **Margin (External spacing between elements)**

```
Component Margins:
├─ Between text blocks: 16px (md)
│  Psychology: Related but distinct content
├─ Between sections: 32px (xl) or 48px (xxl)
│  Psychology: Major visual break, new topic
├─ Between list items: 12px (md-small)
│  Psychology: Scannable, grouped
├─ At screen edges: 24px (lg)
│  Psychology: Content doesn't feel cramped
└─ Between cards: 16px (md)
   Psychology: Objects feel related but separate
```

### Layout Grid

LIORA uses a flexible 8px grid for alignment:

```
Screen Width Breakpoints:
├─ Mobile: 240-360px
├─ Tablet (not primary): 600px+
└─ Desktop (web): 1020px+

Column Layouts:
├─ Single column: Full width with 24px margins = 312px content (360px screen)
├─ Two column: 50/50 split for future web
└─ Three column: Luxury spacing for future tablet support
```

### Margin Psychology

- **Minimum spacing (4-8px):** Used for text relationships, light visual separation
- **Default spacing (16px):** Most frequent, represents "related" elements
- **Generous spacing (24-32px):** Indicates section boundaries, creates focus areas
- **Major spacing (48px):** Only for largest visual breaks, forces attention to new concepts

### Spacing Guidelines

#### ✅ **DO:**
- Use defined spacing scale exclusively
- Apply 16px (md) as default spacing between elements
- Use 24px (lg) for screen edge padding
- Increase spacing to 32px (xl) for major section breaks
- Use generous spacing (24-48px) around important content
- Match top/bottom and left/right padding (symmetry = safety)

#### ❌ **AVOID:**
- Custom spacing sizes not in scale
- Spacing under 8px except for fine-tuning
- Tight spacing that feels cramped (< 12px between components)
- Asymmetrical padding without intentional reason
- Inconsistent horizontal/vertical margins
- Spacing that pushes content to edges

---

## Border Radius & Shapes

### Border Radius Scale

LIORA uses strategic rounding to convey safety and comfort:

```
small  = 8px    (Minor elements, subtle rounding)
medium = 12px   (Input fields, small components)
large  = 16px   (Buttons, moderate containers)
xl     = 20px   (Cards, standard containers)
xxl    = 28px   (Large cards, dialogs, bottom sheets)
round  = 100px  (Pill shapes, circular buttons)
```

### The Psychology of Rounded Corners

**Why rounded over sharp:**
- Sharp corners (0°) → Signal danger, aggression, something to avoid (neurobiologically)
- Slight rounding (8-12°) → Natural, safe, slightly more interesting than perfect rectangles
- Generous rounding (20-28°) → Maximum comfort, welcoming, approachable
- Fully round (100°) → Special, premium, iconic

### Shape Applications

#### **Slight Rounding (8px - small)**
```
Usage: Input field borders, dividers, minor UI elements
Psychology: Professional, organized, subtle design
Example: Text input borders, small icon backgrounds
Angle: ~5-8 degrees feels naturally safe
```

#### **Moderate Rounding (12px - medium)**
```
Usage: Input fields (more forgiving), smaller buttons, tags
Psychology: Friendly, approachable, slightly rounded
Example: Search bars, category badges, small CTAs
Angle: ~10-15 degrees feels welcoming
```

#### **Standard Rounding (16px - large)**
```
Usage: Buttons, small cards, containers
Psychology: Confident, modern, friendly
Example: Primary action buttons, small card containers
Angle: ~15-20 degrees = sweet spot for UI
```

#### **Generous Rounding (20px - xl)**
```
Usage: Cards, dialogs, large containers
Psychology: Premium, safe, embracing
Example: Status cards, information cards, main content containers
Angle: ~20-25 degrees = maximum comfort
```

#### **Maximum Rounding (28px - xxl)**
```
Usage: Large cards, dialog boxes, bottom sheets, major surfaces
Psychology: Special attention, important content, sanctuary
Example: Main info cards, dialog modals, bottom sheet headers
Angle: ~25-30 degrees = highest visual comfort
```

#### **Pill Shapes (100px - round)**
```
Usage: Fully circular buttons, badge shapes, avatars
Psychology: Iconic, premium, complete
Example: Action buttons, user avatars, floating action buttons
```

### Shape Decision Matrix

```
Component                 | Radius  | Why
--------------------------|---------|--------------------------------------------------
Text Input Field          | 12px    | Welcoming, safe data entry zone
Search Bar                | 16px    | Accessible, slightly emphasized
Primary Button            | 16px    | Modern, tappable, primary action
Secondary Button          | 16px    | Matches primary for consistency
Status Card               | 20px    | Important content, generous comfort
Info Card                 | 20px    | Secondary info, still important
Dialog/Modal              | 28px    | Maximum importance, focused attention
Bottom Sheet              | 28px    | Significant action, prominent
Floating Action Button    | 100px   | Premium, iconic, special
User Avatar               | 100px   | Personal, iconic
Small Badge/Tag           | 8px     | Minimal, functional
Divider/Line              | 0px     | Invisible, just visual separation  
Floating Widget Shadow    | 20px    | Matches main cards
```

### Radius Psychology Guidelines

#### ✅ **DO:**
- Use consistent rounding in related components
- Increase rounding for increasingly important elements
- Use 16px for standard buttons/cards (comfort zone)
- Use 20-28px for dialogs and major surfaces
- Match radius across similar components for consistency
- Use 0px only for dividers and technical elements

#### ❌ **AVOID:**
- Sharp corners (0°) on interactive elements
- Inconsistent rounding on related components
- Overly generous rounding on small elements (looks strange)
- Radius larger than 28px for normal content (wastes space, less professional)
- Mixing multiple radius sizes without clear hierarchy

---

## Shadows & Depth

### Shadow System

LIORA uses subtle shadows to create depth hierarchy without visual heaviness:

#### **Soft Shadow (Minimal Elevation)**
```
Properties:
├─ Color: #000000 (opacity 8%)
├─ Blur Radius: 20px
├─ Offset: 0px vertical, 4px horizontal
└─ Spread: 0px

Psychology: Barely perceptible, adds refinement without weight
Usage: Hover states, slight elevation, supporting elements
Example Components: Form inputs on focus, interactive states
Feeling: Subtle confidence boost
```

#### **Medium Shadow (Balanced Elevation)**
```
Properties:
├─ Color: #000000 (opacity 10%)
├─ Blur Radius: 30px
├─ Offset: 0px vertical, 8px horizontal
└─ Spread: 0px

Psychology: Clear elevation, important for visual hierarchy
Usage: Floating cards, elevated buttons, prominent interfaces
Example Components: Status cards, action cards, bottom sheets
Feeling: Safe containment, organized hierarchy
```

#### **Card Shadow (Premium Elevation)**
```
Properties:
├─ Color: #F7B2C4 (Accent Rose, opacity 15%)
├─ Blur Radius: 24px
├─ Offset: 0px vertical, 6px horizontal
└─ Spread: 0px

Psychology: Warm elevation, branded confidence
Usage: Main content cards, important information, status indicators
Example Components: Cycle status card, main info cards, featured content
Feeling: Premium, elevated, supported, warm, trustworthy
Reason for Rose Tint: Rose adds warmth vs cold black, supports brand
```

### Shadow Psychology

**Why subtle shadows and not flat design:**
- Flat design (no shadows) → Modern but feels sterile, loses visual hierarchy
- Harsh shadows (too much blur) → Cinematic but overwhelming, not calming
- Subtle shadows (medium blur) → Readable hierarchy, professional, sophisticated

**Why rose-tinted shadows on cards:**
- Black shadows feel cold, technical, clinical (opposite of LIORA's goal)
- Rose-tinted shadows reinforce the brand warmth and emotional safety
- The rose color at low opacity creates subtle color grading without overwhelming

### Elevation Levels

```
Elevation 0 (No Shadow): Flat, not interactive
├─ Dividers, backgrounds, text-only areas
└─ Psychology: Base level, unified

Elevation 1 (Soft Shadow): Subtle interactivity
├─ Hover states, minimal elevation, supporting elements
└─ Psychology: Slightly elevated, paying attention

Elevation 2 (Medium Shadow): Content cards
├─ Info cards, small status updates, grouped content
└─ Psychology: Organized, contained, safe

Elevation 3 (Card Shadow): Major content
├─ Main status cards, featured content, important information
└─ Psychology: Premium, highlighted, important focus

Elevation 4 (Max Shadow): Modals & floating
├─ Dialogs, bottom sheets, floating elements (future)
└─ Psychology: Maximum attention, separated from base content
```

### Shadow Application Guidelines

#### ✅ **DO:**
- Use soft shadow (minimal) for hover and interactive states
- Use medium shadow for standard cards and containers
- Use card shadow (rose-tinted) for main content and status cards
- Increase shadow to indicate importance hierarchy
- Match shadow depth to component prominence
- Use shadows to create visual separation between layers

#### ❌ **AVOID:**
- Deep/harsh shadows (creates heavy feeling)
- Black shadows without transparency (feels ominous)
- Shadows on every element (loses visual hierarchy)
- Shadows on text-only areas (unnecessary)
- Multiple shadows on same element (confusing)
- Shadows without intentional elevation reason

---

## Component Patterns

### Button Design

#### **Primary Action Button**
```
States: Default, Hover, Pressed, Loading, Disabled

Default State:
├─ Background: #F7B2C4 (Accent Rose)
├─ Text Color: #2E2E2E (textPrimary)
├─ Text Style: button (16px, Outfit, 600)
├─ Padding: 16px vertical × 32px horizontal
├─ Border Radius: 16px (large)
├─ Shadow: Soft shadow
└─ Psychology: Confident, actionable, inviting

Hover State:
├─ Transform: Scale 1.02 (very subtle, 2% growth)
├─ Shadow: Medium shadow (elevated)
└─ Psychology: Responsive feedback, encouragement to tap

Pressed/Active State:
├─ Transform: Scale 0.96 (gentle press-in effect, 4% reduction)
├─ Duration: 150ms animation
└─ Psychology: Physical tactile feedback, sense of control

Loading State:
├─ Show spinner inside button
├─ Disable interactions
└─ Psychology: Transparency of action processing

Disabled State:
├─ Opacity: 50%
├─ Cursor: Not-allowed
└─ Psychology: Clear disabled state, no confusion
```

Example Implementation:
```dart
ElevatedButton(
  onPressed: onPressed,
  style: ElevatedButton.styleFrom(
    backgroundColor: LioraColors.accentRose,
    foregroundColor: LioraColors.textPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: LioraTextStyles.button,
  ),
  child: const Text('Continue'),
)
```

#### **Secondary Button (Outlined)**
```
Purpose: Less critical actions, alternatives, or lower priority

Default State:
├─ Background: Transparent
├─ Border: 1-2px #E8849A (Deep Rose)
├─ Text Color: #E8849A (Deep Rose)
├─ Padding: 16px vertical × 32px horizontal
├─ Border Radius: 16px (large)
└─ Shadow: None

Hover/Active State:
├─ Background: #FFF0F3 (input background, very light)
├─ Scale transform: 0.98
└─ Shadow: Soft shadow

Psychology: Less immediate, still important, more thoughtful
```

#### **Text Button / Link**
```
Purpose: Minimal actions, navigation, secondary options

Default State:
├─ Background: Transparent
├─ Text Color: #E8849A (Deep Rose)
├─ Text Style: label (14px, Outfit, 500)
├─ No padding or minimal
└─ Shadow: None

Hover State:
├─ Text Color: #F7B2C4 (slightly lighter)
├─ Underline: Optional (for links)
└─ Psychology: Light touch, non-threatening

Psychology: Minimal, optional, reversible actions
```

### Input Fields / Text Fields

```
Enabled State:
├─ Background: #FFF0F3 (inputBackground)
├─ Border: 1px #FFD6E0 (inputBorder)
├─ Border Radius: 16px (large)
├─ Text: bodyMedium (#2E2E2E)
├─ Label: label style (#2E2E2E)
├─ Padding: 20px horizontal × 16px vertical
└─ Shadow: None

Focused State:
├─ Border: 2px #F7B2C4 (Accent Rose)
├─ Shadow: Soft shadow
├─ Background: #FFFFFF (pure white)
└─ Psychology: Clear focus indication, encouraging input

Hint/Placeholder Text:
├─ Color: #9E9E9E (textMuted)
├─ Text Style: bodyMedium
└─ Psychology: Non-intrusive guide

Error State:
├─ Border: 1px #FFCDD2 (error color)
├─ Error text: bodySmall in error color
└─ Psychology: Gentle error message, not alarming

Disabled State:
├─ Background: #F5E6EA (divider color, very light)
├─ Color: #9E9E9E (textMuted)
├─ Opacity: 60%
└─ Psychology: Visually unavailable, no confusion
```

### Cards & Containers

#### **Standard Info Card**
```
Structure:
├─ Background: #FFFFFF (card background)
├─ Border: None (shadow provides elevation)
├─ Border Radius: 20px (xl)
├─ Padding: 24px (lg)
├─ Shadow: Medium shadow
└─ Content: Title (h3), description (bodyMedium), optional icon

Internal Spacing:
├─ Title to description: 8px (sm)
├─ Description to action: 16px (md)
└─ Multiple content blocks: 16px (md) between rows
```

#### **Status Card (Main Content)**
```
Structure:
├─ Background: Gradient from #FFFFFF to #FDE2EA
├─ Border: None
├─ Border Radius: 28px (xxl, generous!)
├─ Padding: 24px (lg)
├─ Shadow: Card shadow (rose-tinted)
├─ Content: Emoji indicator, title, status text, countdown

Psychology: Premium appearance, clearly important, emotionally warm gradient

Example: Cycle status card showing current phase, days remaining
```

#### **List Items**
```
Structure:
├─ Background: Transparent or subtle divider
├─ Border: None
├─ Padding: 16px (md) horizontal, 12px vertical
├─ Border Radius: 0px (no rounding for list items)
├─ Divider: 1px #F5E6EA below each item

Internal Layout:
├─ Icon/Avatar: 24-40px depending on importance
├─ Title (label): #2E2E2E
├─ Subtitle (bodySmall): #9E9E9E
└─ Spacing between: 8-12px (sm)

Psychology: Scannable, organized, clear visual rhythm
```

### Dialogs & Bottom Sheets

#### **Dialog (Modal Alert)**
```
Structure:
├─ Background: #FFFFFF (cardBackground)
├─ Border Radius: 28px (xxl)
├─ Padding: 28px (custom, spacious)
├─ Shadow: Elevation 4 (prominent)
├─ Overlay: Dark overlay (30% opacity) to focus attention

Content Layout:
├─ Icon (optional): Top center, 48px
├─ Title: h2 or h3, centered, 16px bottom margin
├─ Content: bodyMedium, 24px bottom margin
├─ Buttons: Two buttons for choice, or single confirm button
└─ Button spacing: 12px horizontal gap

Psychology: Elevated attention, important decision point, centered focus
```

#### **Bottom Sheet**
```
Structure:
├─ Background: #FFFFFF (cardBackground)
├─ Top Border Radius: 28px (xxl)
├─ Bottom Border Radius: 0px (matches screen bottom)
├─ Padding: 24px (lg), 28px if handle visible
├─ Drag Handle: Visible, color #F5E6EA
├─ Shadow: Elevation 4

Content Layout:
├─ Title: h2, 24px bottom margin (optional)
├─ Content: Scrollable vertical list
├─ Action buttons: Bottom, full or partial width
└─ Safe area padding: 16px from screen edge

Animation: Slide up from bottom, 300ms duration

Psychology: Secondary actions, doesn't block primary content, expandable
```

### Drawer / Side Navigation (Future)

```
Structure:
├─ Background: #FFFFFF (card background)
├─ Width: 80% of screen or 320px max
├─ Shadow: Elevation 3 (Card shadow)
├─ Safe area padding: 16px, respect notches

Header Section:
├─ Background: Gradient (primary gradient)
├─ Padding: 24px
├─ User avatar: 56px circular
├─ User name: h3
└─ Email: bodySmall in secondary color

Navigation Items:
├─ Height: 48-56px
├─ Padding: 16px horizontal
├─ Icon: 24px, 12px left margin
├─ Label: label style, 12px left margin
├─ Background on active: #FFF0F3
├─ Divider between sections: 8px spacing

Overlay: Dark overlay (40% opacity) behind drawer to indicate modal
```

---

## Icons & Imagery

### Icon System

#### **Icon Sizing**
```
Extra Small: 16px
├─ Usage: Inline indicators, very small badges
└─ Psychology: Minimal, supporting

Small: 20px
├─ Usage: Form state indicators, small buttons
└─ Psychology: Clear but not dominant

Medium: 24px
├─ Usage: Tab icons, standard navigation, list items
└─ Psychology: Balanced, primary icon size

Large: 32px
├─ Usage: Feature highlights, section headers
└─ Psychology: Attention-grabbing, important

Extra Large: 48px+
├─ Usage: Onboarding screens, cycle phase emojis, hero content
└─ Psychology: Immersive, welcoming, focus point
```

#### **Icon Style**
- Use emoji for cycle phases (🌱 🌸 🌕 🌙) — Universal, emotional, relatable
- Use outlined/stroke icons for navigation and actions (2px stroke weight)
- Icons from system fonts: Flutter's Cupertino Icons or Material Icons
- Color: Match text color hierarchy (#2E2E2E for primary actions, #6B6B6B for secondary)
- No rotation or unusual transformations (keep icons stable and clear)

#### **Icon Application Rules**
```
Navigation Icons: 24px, #6B6B6B (secondary gray)
├─ Active state: #F7B2C4 (Accent Rose)
└─ Psychology: Clear current location

Action Icons in Buttons: Match text size and color
├─ Inside buttons: Use semantic icon color
└─ Psychology: Unified action message

Status Indicators: 20px emoji or colored icon
├─ Period phase: Use semantic calendar cycle
└─ Psychology: Quick visual understanding

Section Icons: 32px+ emoji or icons
├─ Onboarding: Large welcoming emoji
└─ Psychology: Immersive, clear intent
```

### Imagery & Illustrations

#### **Style Guidelines**
- **Illustration Style**: Soft, rounded, hand-drawn feeling (NOT flat geometric)
- **Color Palette**: Use LIORA colors + soft pastels
- **Emotion**: Welcoming, supportive, positive, never clinical
- **Representation**: Diverse, inclusive, celebratory of menstruation

#### **Usage Contexts**
```
Onboarding Screens:
├─ Large illustrated headers (200px+)
├─ Soft, welcoming style
└─ Each screen has emotional narrative illustration

Empty States:
├─ Cute illustration + encouraging message
├─ 120px illustrations
└─ Invites user to take action

Error States:
├─ Reassuring illustration (not scary)
├─ ~100px size
└─ "Don't worry, here's how to fix it" tone

Success States:
├─ Celebratory, warm illustration
├─ ~100px size
└─ Positive reinforcement for user action
```

#### **What to Avoid**
- ❌ Clinical or medical illustrations (makes app feel like doctor's office)
- ❌ Anatomically explicit images (unnecessary, less accessible)
- ❌ Stereotypical "female" imagery (Pink everything, hyper-feminine)
- ❌ Dark or scary illustrations (contradicts safety mission)
- ❌ Crowded or busy illustrations (causes cognitive overload)
- ❌ Photos of real people in intimate contexts (privacy concern)

---

## Animations & Transitions

### Animation Principles

LIORA animations should feel **natural, purposeful, and calming** — not flashy.

#### **Animation Philosophy**
- **Duration**: 150-300ms for most interactions (quick but perceivable)
- **Curve**: Prefer `Curves.easeInOut` for symmetrical, natural feel
- **Purpose**: Every animation should communicate feedback or guide attention
- **Restraint**: Use motion sparingly; avoid animation fatigue

### Common Animation Patterns

#### **Button Press Animation**
```
Duration: 150ms
Curve: easeInOut
Transform: Scale 1.0 → 0.96 → 1.0 (press and release)
Psychology: Tactile feedback, user agency, immediate response
```

```dart
GestureDetector(
  onTapDown: (_) => _controller.forward(),
  onTapCancel: () => _controller.reverse(),
  onTapUp: (_) => _controller.reverse(),
  child: ScaleTransition(
    scale: Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    ),
    child: ChildWidget(),
  ),
)
```

#### **Page Transitions**
```
Duration: 300ms
Curve: easeInOut
Animation: Fade + Slide (slide from right, fade in)
Psychology: Smooth navigation, clear movement direction
Implementation: Uses Cupertino transitions (native-feeling)
```

#### **Fade In/Out**
```
Duration: 200ms
Curve: easeInOut
Usage: Content reveal, loading to content, state changes
Psychology: Gentle appearance/disappearance, not jarring
```

#### **Slide Animations**
```
Duration: 250-300ms
Curve: easeOutCubic (quick start, gentle end)
Usage: Bottom sheets, drawers, modals
Direction: Bottom-to-center for sheets
Psychology: Smooth entrance, controlled motion
```

#### **Size/Height Animations**
```
Duration: 250ms
Curve: easeInOut
Usage: Expanding cards, collapsing content, height changes
Psychology: Visual growth, controlled expansion
```

#### **Rotation Animations**
```
Duration: 250ms
Curve: easeInOut
Usage: Loading spinners, arrow indicators
Psychology: Activity indication, attention
```

### Animation Dos and Don'ts

#### ✅ **DO:**
- Animate for feedback (button press, state change)
- Use 150-300ms duration (perceivable but quick)
- Apply easeInOut curve for natural feel
- Purpose: Guide attention or show causality
- Test on low-end devices to ensure smoothness
- Use animations to clarify, not distract

#### ❌ **AVOID:**
- Animations over 500ms (feels slow, laggy)
- Simultaneous random animations (chaotic)
- Bouncy or elastic curves for calming content
- Animation for decorative purposes
- Animations on every interaction (overwhelming)
- Animations that block user interaction

---

## Accessibility

### Color Contrast

**WCAG AA Compliance (Minimum 4.5:1 for text):**

```
Primary Text (#2E2E2E) on Background (#FFF6F9): 14.2:1 ✓ Excellent
Primary Text (#2E2E2E) on Pink (#FDE2EA): 10.1:1 ✓ Excellent
Secondary Text (#6B6B6B) on Background (#FFF6F9): 5.2:1 ✓ Good
Accent Rose (#F7B2C4) on White: 3.8:1 ✗ Fails WCAG AA

Solutions:
├─ Don't use Accent Rose (#F7B2C4) as text color on white
├─ Use Deep Rose (#E8849A) for button text instead (5.6:1 ratio)
└─ Always test text contrast with color contrast checker
```

### Touch Targets

**Minimum 44x44px touch target size (iOS) / 48sp (Android):**

```
Buttons: 48px minimum height
├─ Padding creates natural 44px minimum
└─ Comfortable for all hand sizes

Tappable Text Links: 44px minimum clickable area
├─ Increase padding if needed
└─ Never rely on text alone

List Items: 48+ px height minimum
├─ Adequate spacing for touches
└─ Prevents accidental taps

Icon Buttons: 40-48px minimum
├─ Include padding in calculation
└─ Usually 24-32px icon + padding
```

### Readable Text

```
Minimum Font Size: 12px (labelSmall)
├─ Prefer 14px+ for standard content
└─ Never smaller than 11px for any content

Line Height: Minimum 1.4 (16.8px for 12px text)
├─ Preferred: 1.5 (24px for 16px body text)
└─ Better readability, less strain

Letter Spacing: Use defined system
├─ Headings: Tight (-0.3 to -0.5px)
├─ Body: Normal or slight (+0.1px)
└─ Add spacing if text feels cramped

Line Length: 60-80 characters ideal
├─ Prevent excessive line wrapping
└─ Multiple short lines = poor readability
```

### Dark Mode Considerations (Future)

When implementing dark mode:

```
Base Colors:
├─ Background: Very dark gray (#1A1A1A) not pure black
├─ Cards: Dark charcoal (#2A2A2A)
└─ Text: Very light gray (#F5F5F5)

Color Adjustments:
├─ Increase contrast between light colors
├─ Soften bright colors for reduced eye strain
├─ Maintain rose/pink accents (becomes more prominent)
└─ Test contrast ratios again (darker backgrounds may fail)
```

### Accessibility Best Practices

#### ✅ **DO:**
- Use semantic HTML/Flutter widgets
- Provide alt text for images and icons
- Ensure color contrast meets WCAG AA
- Make all interactive elements keyboard accessible
- Test with screen readers
- Use readable font sizes (14px minimum)
- Provide error messages clearly
- Test on actual devices (not just simulator)
- Follow Material 3 accessibility guidelines
- Announce state changes (loading, success, error)

#### ❌ **AVOID:**
- Color-only information (always pair with text/icon)
- Very small fonts (under 12px)
- Contrast ratio below 4.5:1 for text
- Interactions requiring precise targeting
- Ambiguous button labels
- Hidden navigation or unclear interactions
- Moving/flashing content without control
- Requiring hover states for information
- Very fast animations (can trigger seizures)

---

## Design Patterns & Examples

### Full Page Layout Pattern

**Suitable for all screens: Auth, Home, Settings, Onboarding**

```
Layout Structure:
┌─────────────────────────────┐
│  App Bar (Optional)         │ 56px height, transparent background
├─────────────────────────────┤
│                             │
│  Screen Content             │ 24px side margins (lg)
│  (Scrollable area)          │ 16px top margin (md)
│  - Cards                    │ Variable height
│  - Lists                    │
│  - Forms                    │
│                             │ 24px bottom margin (lg)
└─────────────────────────────┘
```

**Example: Home Screen**
```
AppBar: "Home" title, profile icon
├─ 400px content area (from 360px screen)
├─ No padding (extends to edges)
└─ Transparent background with subtle shadow below

Scroll Content:
├─ 24px horizontal margin
├─ Status Card (20px radius, rose shadow): 240px
├─ 16px bottom margin
├─ Calendar Widget: 240px height
├─ 24px bottom margin
├─ Quick Actions Section: h2 title, card list
└─ 24px bottom padding
```

### Card with Icon Pattern

**Used for: Status cards, info cards, action cards**

```
┌──────────────────────────────┐
│  Icon  Title          Action │  28px padding (xxl)
│  🌸    Current Phase    ›    │  20px radius corner
│                              │  Card shadow (rose)
│  Subtitle Text              │
│  • Small detail              │
│                              │
│  Days remaining: 8           │
└──────────────────────────────┘

Spacing Rules:
├─ Icon size: 28-32px
├─ Icon to title: 12px
├─ Title to subtitle: 8px
├─ Details padding: 16px top/bottom
└─ Total padding: 24px all sides
```

### Form Layout Pattern

**Used for: Login, signup, settings, preferences**

```
Screen Structure:
├─ Title (h2): Top, 32px bottom margin (xl)
├─ Subtitle (bodyMedium): 24px bottom margin (lg)
│
├─ Form Section 1:
│  ├─ Label (label style): 8px bottom margin
│  ├─ Input Field (16px radius): 12px bottom margin
│  └─ Helper text (bodySmall): 24px bottom margin to next input
│
├─ Form Section 2:
│  └─ (Same as above)
│
├─ Important Note (bodySmall, warning color): 24px bottom margin
│
├─ Primary Button (full width): 24px bottom margin
│
└─ Alternative Action (link or secondary):
   └─ Centered, 16px top margin
```

**Code Example:**
```dart
Column(
  children: [
    const Text('Sign Up', style: h2),
    const SizedBox(height: LioraSpacing.xl), // 32px
    
    const Text('Email', style: label),
    const SizedBox(height: LioraSpacing.sm), // 8px
    AuthTextField(...),
    const SizedBox(height: LioraSpacing.lg), // 24px
    
    const Text('Password', style: label),
    const SizedBox(height: LioraSpacing.sm),
    AuthTextField(...),
    const SizedBox(height: LioraSpacing.lg),
    
    AuthButton(label: 'Sign Up'),
    const SizedBox(height: LioraSpacing.lg),
    
    TextButton(
      onPressed: () => goToLogin(),
      child: const Text('Already have account?'),
    ),
  ],
)
```

### Bottom Sheet Action Pattern

**Used for: Cycle logging, symptom selection, date picking**

```
┌───────────────────────────────┐
│     ═══════════════════        │  Drag handle (centered)
│                               │  
│     Action Title (h2)         │  28px padding
│     Subtitle (bodyMedium)      │  
│                               │  
│  ☐ Option 1                   │  List items 48px height
│  ☐ Option 2                   │  16px padding each
│  ☐ Option 3                   │  8px divider
│  ☐ Option 4                   │  
│                               │  
│     [Cancel] [Confirm]        │  16px margin, 24px padding bottom
└───────────────────────────────┘
```

### Empty State Pattern

**Used for: No data, no logs, first time user**

```
┌─────────────────────────────┐
│                             │
│        🌱 (48px emoji)      │  32px top margin (xl)
│                             │  
│     No cycles logged        │  h2 title
│                             │  16px bottom margin
│   Start tracking your       │  bodyMedium, centered
│   menstrual cycle to get    │  
│   personalized predictions  │  24px bottom margin
│                             │  
│  [Log Your First Period]    │  Button, full width
│                             │  
└─────────────────────────────┘
```

### Success State Pattern

**Used for: After logging, after saving, after action**

```
Dialog Pattern:
┌─────────────────────────────┐
│          ✅ (48px emoji)    │  28px padding
│                             │  28px radius (xxl)
│   Period Logged!            │  
│                             │  8px bottom margin from icon
│  Your cycle tracking now    │  h3 title
│  includes this period      │  
│                             │  16px bottom margin
│       [Continue]            │  bodyMedium text
│                             │  24px bottom margin
│                             │  Full width button
└─────────────────────────────┘
```

### Navigation Patterns (Future)

**Bottom Navigation (Current)**
```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(icon: home, label: 'Home'),
    BottomNavigationBarItem(icon: track, label: 'Track'),
    BottomNavigationBarItem(icon: insights, label: 'Insights'),
    BottomNavigationBarItem(icon: profile, label: 'Profile'),
  ],
)
// 24px icon size
// 12px spacing from icon to label
// Active color: Accent Rose (#F7B2C4)
// Inactive color: textSecondary (#6B6B6B)
// Height: 56-64px
```

---

## What To Avoid

### Color Mistakes

```
Don't:
├─ ❌ Use pure black (#000000) for text — too harsh
│  └─ Use #2E2E2E (textPrimary) instead
├─ ❌ Use bright hot pink (#FF1493) — too clinical/alarming
│  └─ Use #F7B2C4 (Accent Rose) instead
├─ ❌ Use neon colors — contradicts safety mission
│  └─ Use soft palette colors only
├─ ❌ Use pure white (#FFFFFF) backgrounds without warmth
│  └─ Use #FFF6F9 (warmth) with subtle tint
├─ ❌ Use bright red (#FF0000) for errors
│  └─ Use #FFCDD2 (soft red) instead
├─ ❌ Mix warm and cool tones randomly
│  └─ Maintain warm palette consistency
└─ ❌ Over-saturate colors
   └─ All LIORA colors are naturally desaturated
```

### Typography Mistakes

```
Don't:
├─ ❌ Use multiple font families
│  └─ Stick to Outfit (headings) + Inter (body)
├─ ❌ Mix serif and sans-serif
│  └─ Both fonts are clean sans-serif
├─ ❌ Use all caps body text
│  └─ All caps only for button labels
├─ ❌ Use text smaller than 12px
│  └─ Minimum 12px (labelSmall)
├─ ❌ Apply colors not in LIORA palette
│  └─ Always use defined colors
├─ ❌ Mix too many font weights
│  └─ Limit to 2-3 weights per screen
├─ ❌ Ignore line-height (< 1.4)
│  └─ Always maintain 1.4+ line height
└─ ❌ Underline text (unless links)
   └─ Use color/bold for emphasis instead
```

### Shape Mistakes

```
Don't:
├─ ❌ Use sharp corners (#000000) on interactive elements
│  └─ Minimum 8px rounding on inputs
├─ ❌ Use inconsistent rounding on similar components
│  └─ Match radius across component families
├─ ❌ Use radius > 28px on normal content
│  └─ Maximum generosity is 28px
├─ ❌ Use different radius for left/right corners
│  └─ Symmetry = safety
└─ ❌ Over-round small elements
   └─ 8px rounding for small badges only
```

### Spacing Mistakes

```
Don't:
├─ ❌ Use spacing not in the 8px scale
│  └─ Stick to: 4, 8, 12, 16, 24, 32, 48px
├─ ❌ Crowd elements (< 8px between)
│  └─ Minimum 8px (sm) between elements
├─ ❌ Ignore screen edge padding
│  └─ Always 24px (lg) margin on sides
├─ ❌ Use inconsistent internal/external spacing
│  └─ Be intentional and consistent
├─ ❌ Asymmetrical padding without reason
│  └─ Usually top/bottom = left/right
└─ ❌ Waste space without purpose
   └─ More space = increased importance
```

### Component Mistakes

```
Don't:
├─ ❌ Use shadows on every element
│  └─ Reserve shadows for elevation
├─ ❌ Make shadows too harsh (black, no blur)
│  └─ Use soft, blurred shadows
├─ ❌ Use 0px radius on buttons
│  └─ Minimum 8px, preferred 16px
├─ ❌ Mix button styles on same screen
│  └─ Primary actions: Filled, Secondary: Outlined
├─ ❌ Disable buttons subtly
│  └─ Use clear disabled state (opacity 50%+)
└─ ❌ Hide required field indicators
   └─ Clearly mark required fields
```

### Animation Mistakes

```
Don't:
├─ ❌ Use animations > 500ms
│  └─ Keep animations 150-300ms
├─ ❌ Animate everything
│  └─ Purposeful animation only
├─ ❌ Use bouncy curves for calming content
│  └─ Use easeInOut for smooth feel
├─ ❌ Block user interaction during animation
│  └─ Let users act before animation completes
├─ ❌ Use excessive motion
│  └─ One animation type per screen ideally
└─ ❌ Animate text rotation or complex transforms
   └─ Reserve animations for scale, position, opacity
```

### Accessibility Mistakes

```
Don't:
├─ ❌ Use color alone to convey information
│  └─ Pair color with icon/text
├─ ❌ Make text smaller than 12px
│  └─ Minimum 12px, prefer 14px
├─ ❌ Use low contrast text
│  └─ Maintain 4.5:1 ratio minimum
├─ ❌ Require hover states for information
│  └─ All content accessible on tap
├─ ❌ Hide focus states on interactive elements
│  └─ Make focus clear (outline/color change)
├─ ❌ Use ambiguous button labels
│  └─ "Click here" → "Log Period"
└─ ❌ Forget about safe areas (notches)
   └─ Respect device safe areas always
```

---

## Implementation Quick Reference

### When Creating a New Screen

✅ Use this checklist:

```
Color & Theme:
├─ ☐ Background: #FFF6F9 (backgroundWhite)
├─ ☐ Cards: #FFFFFF (cardBackground) with card shadow
├─ ☐ Buttons: Primary = Accent Rose, Secondary = outlined
├─ ☐ Text: Use defined text styles only
└─ ☐ Accent elements: Deep Rose (#E8849A) for emphasis

Layout & Spacing:
├─ ☐ Screen margins: 24px (lg) horizontal
├─ ☐ Default element margin: 16px (md)
├─ ☐ Section spacing: 32px (xl) between major sections
├─ ☐ Padding in containers: 24px (lg)
└─ ☐ Card spacing between: 16px (md)

Typography:
├─ ☐ Page title: h2 (24px, Outfit, 600)
├─ ☐ Section headers: h3 (20px, Outfit, 600)
├─ ☐ Body content: bodyMedium (14px, Inter, 400)
├─ ☐ Labels/hints: label (14px, Outfit, 500)
└─ ☐ No custom sizes outside defined styles

Shapes & Elevation:
├─ ☐ Cards: 20px radius (xl)
├─ ☐ Buttons: 16px radius (large)
├─ ☐ Inputs: 16px radius (large), 12px for subtler components
├─ ☐ Dialogs: 28px radius (xxl)
├─ ☐ Card shadows: Use LioraShadows.card (rose-tinted)
└─ ☐ Button taps: 0.96 scale press animation

Interactions:
├─ ☐ All buttons have press state (scale 0.96)
├─ ☐ Form fields have focused border color
├─ ☐ Navigation has active state color
├─ ☐ Loading states are clear
└─ ☐ Error states are compassionate (not alarming)

Accessibility:
├─ ☐ Touch targets minimum 44px
├─ ☐ Text contrast 4.5:1 minimum
├─ ☐ Icons have semantic meaning or label
├─ ☐ Form fields have labels
└─ ☐ Error messages are clear and helpful
```

### When Creating a New Component

✅ Template:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/liora_theme.dart';

/// [ComponentName] - [Brief description]
///
/// Design Pattern: [Card/Button/Input/etc]
/// Psychology: [Why this design choice]
/// Usage: [When to use this component]
class MyComponent extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  
  const MyComponent({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LioraSpacing.lg), // 24px
      decoration: BoxDecoration(
        color: LioraColors.cardBackground,
        borderRadius: BorderRadius.circular(LioraRadius.xl), // 20px
        boxShadow: LioraShadows.card, // Card shadow pattern
      ),
      child: Column(
        children: [
          Text(label, style: LioraTextStyles.h3),
          const SizedBox(height: LioraSpacing.md), // 16px
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('Action'),
          ),
        ],
      ),
    );
  }
}
```

---

## Color Reference Quick Lookup

| Purpose | Color | Hex | Use Case |
|---------|-------|-----|----------|
| Primary Background | Primary Pink | #FDE2EA | Backgrounds, secondary elements |
| Main Background | Background White | #FFF6F9 | Screen scaffold |
| Primary Action | Accent Rose | #F7B2C4 | Buttons, primary CTAs |
| Secondary Action | Deep Rose | #E8849A | Secondary buttons, emphasis |
| Period Phase | Soft Rose | #FFB5C2 | Period days on calendar |
| Fertile Window | Lavender | #E8D5F2 | Fertile window indicator |
| Predicted Period | Light Coral | #FFCDD2 | Predicted period dates |
| Ovulation | Soft Purple | #D4B5FF | Ovulation day |
| Primary Text | Charcoal | #2E2E2E | All main text |
| Secondary Text | Medium Gray | #6B6B6B | Supporting text |
| Muted Text | Light Gray | #9E9E9E | Hints, disabled |
| Card Background | Pure White | #FFFFFF | Cards, surfaces |
| Input Background | Pale Pink | #FFF0F3 | Input fields |
| Input Border | Soft Rose | #FFD6E0 | Input borders |
| Divider | Very Light Pink | #F5E6EA | Visual separation |
| Success | Soft Mint | #A8E6CF | Confirmations |
| Warning | Soft Amber | #FFE0B2 | Alerts |
| Error | Soft Red | #FFCDD2 | Errors, warnings |
| Shadow | Black 8% | Color(0x14000000) | Soft elevation |

---

## Typography Quick Reference

| Style | Font | Size | Weight | Use |
|-------|------|------|--------|-----|
| h1 | Outfit | 32px | 700 | Screen titles |
| h2 | Outfit | 24px | 600 | Section headers |
| h3 | Outfit | 20px | 600 | Subsection headers |
| bodyLarge | Inter | 16px | 400 | Primary content |
| bodyMedium | Inter | 14px | 400 | Secondary content |
| bodySmall | Inter | 12px | 400 | Tertiary content |
| label | Outfit | 14px | 500 | Form labels |
| labelSmall | Outfit | 12px | 500 | Small labels |
| button | Outfit | 16px | 600 | Button text |
| calendarDay | Outfit | 14px | 500 | Calendar dates |
| calendarHeader | Outfit | 18px | 600 | Month/year headers |

---

## Spacing Quick Reference

| Name | Value | Usage |
|------|-------|-------|
| xs | 4px | Micro spacing, fine adjustments |
| sm | 8px | Minimum breathing room |
| md | 16px | Default spacing, most common |
| lg | 24px | Generous padding, screen edges |
| xl | 32px | Section breaks |
| xxl | 48px | Major section breaks |

---

## Border Radius Quick Reference

| Name | Value | Usage |
|------|-------|-------|
| small | 8px | Minor elements, inputs subtly |
| medium | 12px | Input fields |
| large | 16px | Buttons, standard containers |
| xl | 20px | Cards, main containers |
| xxl | 28px | Large cards, dialogs, sheets |
| round | 100px | Pill shapes, avatars, circles |

---

## Design System in Code

### Always Use These Constants

```dart
// Colors
LioraColors.accentRose        // Primary action color
LioraColors.backgroundWhite   // Main background
LioraColors.textPrimary       // All text color
LioraColors.cardBackground    // Card surfaces

// Text Styles
LioraTextStyles.h2            // Page titles
LioraTextStyles.h3            // Section headers
LioraTextStyles.bodyLarge     // Main content
LioraTextStyles.button        // Button text

// Spacing
LioraSpacing.md               // Default (16px)
LioraSpacing.lg               // Screen margins (24px)
LioraSpacing.xl               // Section breaks (32px)

// Radius
LioraRadius.large             // Buttons (16px)
LioraRadius.xl                // Cards (20px)
LioraRadius.xxl               // Dialogs (28px)

// Shadows
LioraShadows.soft             // Subtle elevation
LioraShadows.card             // Card shadow (rose-tinted)
```

### Never Hardcode

❌ Don't do this:
```dart
Text('Hello', style: TextStyle(fontSize: 16)),
padding: EdgeInsets.all(20),
borderRadius: BorderRadius.circular(15),
```

✅ Do this instead:
```dart
Text('Hello', style: LioraTextStyles.bodyLarge),
padding: const EdgeInsets.all(LioraSpacing.lg),
borderRadius: BorderRadius.circular(LioraRadius.xl),
```

---

## Summary: LIORA Design Principles

LIORA is designed from first principles around **emotional safety, psychological comfort, and feminism empowerment**.

**Core Tenets:**
1. **Psychology Override Style** — Every design choice serves the user's emotional state
2. **Rounded > Sharp** — Curved shapes signal safety; sharp shapes signal danger
3. **Warm > Cold** — Rose tones and gradients create emotional warmth
4. **Generous Spacing** — Breathing room reduces anxiety
5. **Semantic Colors** — Colors map to biological meaning (rose = period, purple = ovulation)
6. **Soft Shadows** — Depth without heaviness
7. **Clear Hierarchy** — Easy to scan, hard to miss
8. **Accessible to All** — No assumptions about ability
9. **Consistent System** — Developers can understand and extend the design
10. **Human Not Clinical** — Celebrates menstruation positively

When building new features or screens, ask:
- **"Does this feel safe and supportive?"**
- **"Would a user trust their intimate data here?"**
- **"Is this design consistent with the system?"**
- **"Can everyone access and understand this?"**

If you can answer "yes" to all four questions, you're following LIORA design principles.

---

**Last Updated:** February 2026
**Version:** 1.0
**Designer:** LIORA Design System
**Maintainer:** Development Team
