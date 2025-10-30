# Dark Mode Redesign - Cool & Professional

## Color Scheme
```dart
Primary: #00D9FF (Cyan Blue) - Main accent color
Primary Light: #4DE8FF (Light Cyan)
Primary Dark: #00A8CC (Deep Cyan)

Backgrounds:
- Background: #0A0E27 (Deep Navy) - Main app background
- Surface: #151932 (Dark Blue-Gray) - Cards, dialogs
- Surface Light: #1E2139 (Lighter surface for gradients)

Text:
- Primary: #E8EAF6 (Light Blue-White)
- Secondary: #9FA8DA (Muted Blue-Gray)

Status Colors (Vibrant):
- Success: #00E676 (Bright Green)
- Warning: #FFAB00 (Amber)
- Error: #FF5252 (Bright Red)
- Disabled: #424242 (Dark Gray)

Accents:
- Accent: #7C4DFF (Purple)
- Accent Secondary: #FF6E40 (Orange)
```

## Design Features

### Visual Effects
- **Gradients**: Subtle gradients on cards and headers
- **Glow Effects**: Cyan glow on primary elements
- **Shadows**: Colored shadows with primary color
- **Borders**: Semi-transparent cyan borders
- **Filled Inputs**: Dark surface backgrounds

### Typography
- Light weights (300-400) for modern look
- Increased letter spacing
- Cyan accent on headings
- High contrast text on dark backgrounds

### Components
- **Cards**: Gradient backgrounds with glowing borders
- **Buttons**: Cyan primary with hover effects
- **Icons**: Outlined with cyan color
- **Status Badges**: Vibrant colors with transparency
- **Inputs**: Filled dark with cyan focus

## Pages Updated
✓ AppColors utility (complete dark theme palette)
✓ Login Page (gradient icon container, glowing card)
✓ Dashboard (gradient drawer header, glowing stat cards)
⏳ Room List, History, Approval, Request Status, Manage Rooms

## Implementation Notes
- All colors use AppColors constants
- Gradients: topLeft to bottomRight
- Opacity: 0.1-0.3 for subtle effects
- Border radius: 12-20px for modern feel
- Elevation: 4-8 with colored shadows

## Next Steps
Apply dark theme to remaining pages:
- Room list with cyan time slots
- History with gradient cards
- Approval with glowing action buttons
- Request status with vibrant badges
- Manage rooms with dark inputs
