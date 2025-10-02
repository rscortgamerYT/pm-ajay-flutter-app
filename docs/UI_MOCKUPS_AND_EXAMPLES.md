# PM-AJAY UI Mockups & Visual Examples
## Accessibility-Focused Design System

### BEFORE vs AFTER Comparisons

---

## 1. LOGIN PAGE TRANSFORMATION

### BEFORE (Current):
```
┌────────────────────────────────┐
│  [Small Logo]                  │
│  PM-AJAY                       │
│  Government Project...System   │
│                                │
│  Email: [____________]         │
│  Password: [____________]      │
│  [Forgot Password?]            │
│  [Login Button]                │
│  ────── OR ──────              │
│  [Sign in with Govt ID]        │
└────────────────────────────────┘
```

### AFTER (Recommended):
```
┌────────────────────────────────┐
│  🇮🇳 [LARGE Govt Emblem]        │
│                                │
│  PM-AJAY                       │
│  पीएम-अजय प्रोग्राम            │
│  [हिंदी ▼] [English ▼]         │
│                                │
│  ┌──────────────────────────┐  │
│  │ 📱 मोबाइल से लॉगिन करें  │  │
│  │    OTP भेजेंगे           │  │
│  │    [Large Button 56px]   │  │
│  └──────────────────────────┘  │
│                                │
│  ┌──────────────────────────┐  │
│  │ 🆔 आधार से लॉगिन करें    │  │
│  │    [Large Button 56px]   │  │
│  └──────────────────────────┘  │
│                                │
│  [▼ अन्य विकल्प] (Collapsed)  │
│                                │
│  📞 सहायता: 1800-XXX-XXXX      │
│  ✅ सरकार द्वारा प्रमाणित     │
└────────────────────────────────┘
```

**Key Changes:**
- Phone login as PRIMARY option
- Large, touchable buttons (56px height minimum)
- Bilingual text throughout
- Help number prominently displayed
- Government trust indicators
- Language selector at top

---

## 2. DASHBOARD SIMPLIFICATION

### BEFORE (Current):
```
┌────────────────────────────────┐
│ PM-AJAY Dashboard    🔔 👤    │
├────────────────────────────────┤
│ [Gradient Card with Animation] │
│ Welcome back, Admin!           │
│ Wednesday, October 02, 2025    │
│ 12 projects updated today      │
├────────────────────────────────┤
│ 🤖 AI Autonomous Governance    │
│ 📊 Infinite Scroll Dashboard   │
│ 💬 Collaboration Hub           │
│ [12 small cards in grid]       │
│ [Activity feed]                │
│ [Statistics with animations]   │
└────────────────────────────────┘
```

### AFTER (Recommended):
```
┌────────────────────────────────┐
│ 🏠 होम    [हिंदी ▼]    ❓ सहायता│
├────────────────────────────────┤
│ नमस्ते, राज कुमार जी! 👋        │
│ आप यहाँ हैं: प्रशासक           │
├────────────────────────────────┤
│ ┌──────────────┬──────────────┐│
│ │ 🏗️ मेरी       │ 💰 फंड       ││
│ │ परियोजनाएं    │              ││
│ │ [HUGE Icon]  │ [HUGE Icon]  ││
│ │ 12 सक्रिय    │ ₹2.5 करोड़   ││
│ │ [120px card] │ [120px card] ││
│ └──────────────┴──────────────┘│
│ ┌──────────────┬──────────────┐│
│ │ 📋 रिपोर्ट    │ 🏢 एजेंसी    ││
│ │ [HUGE Icon]  │ [HUGE Icon]  ││
│ │ सभी देखें    │ 45 सक्रिय    ││
│ │ [120px card] │ [120px card] ││
│ └──────────────┴──────────────┘│
├────────────────────────────────┤
│ 📞 मदद चाहिए?                 │
│ टोल फ्री: 1800-XXX-XXXX        │
│ WhatsApp: +91-XXXXX-XXXXX      │
└────────────────────────────────┘
```

**Key Changes:**
- Only 4 primary actions visible
- Much larger cards (120px height)
- Bilingual labels
- Help contact always visible
- Personal greeting in Hindi
- No complex animations

---

## 3. PROJECT LIST ENHANCEMENT

### BEFORE (Current):
```
┌────────────────────────────────┐
│ Projects              ⋮        │
├────────────────────────────────┤
│ [Search projects...]           │
│ [All][Adarsh][GIA][Hostel]    │
│ [All][InProgress][Completed]  │
├────────────────────────────────┤
│ ┌─────────────────────────────┐│
│ │ Project Name    [InProgress]││
│ │ [Cat][Location][Budget]     ││
│ │ ▬▬▬▬▬▬▬▬▬░░ 75%            ││
│ │ 01 Jan 2024 - 31 Dec 2026  ││
│ └─────────────────────────────┘│
└────────────────────────────────┘
```

### AFTER (Recommended):
```
┌────────────────────────────────┐
│ 🏗️ परियोजनाएं        ❓      │
├────────────────────────────────┤
│ [🎤 बोलकर खोजें] [खोजें...]   │
│                                │
│ दिखाएं: [सभी (156) ▼]         │
├────────────────────────────────┤
│ ┌─────────────────────────────┐│
│ │      [LARGE ICON 64px]      ││
│ │      🏘️ आदर्श ग्राम         ││
│ │                             ││
│ │  आदर्श ग्राम परियोजना - XYZ ││
│ │  (18sp font)                ││
│ │                             ││
│ │  ┌─────────────────────────┐││
│ │  │ ✅ चल रहा है           │││
│ │  │ 75% पूर्ण              │││
│ │  │ ▓▓▓▓▓▓▓▓░░░            │││
│ │  └─────────────────────────┘││
│ │                             ││
│ │  📍 महाराष्ट्र              ││
│ │  📅 मार्च 2026 तक          ││
│ │  💰 ₹5.2 करोड़              ││
│ │                             ││
│ │  [विवरण देखें - 56px btn]  ││
│ └─────────────────────────────┘│
└────────────────────────────────┘
```

**Key Changes:**
- Voice search button prominent
- Single filter dropdown instead of chips
- Much larger project cards
- Large project type icon
- Visual status with color coding
- Large "View Details" button
- All text in Hindi

---

## 4. COLOR CODING SYSTEM

### Status Colors (Consistent Throughout App):
```
✅ स्वीकृत (Approved)     → 🟢 Green #138808
⏳ लंबित (Pending)        → 🟡 Orange #FFB300
🏗️ चल रहा है (InProgress) → 🔵 Blue #1976D2
✔️ पूर्ण (Completed)      → 🟢 Dark Green #00600F
⚠️ विलंबित (Delayed)     → 🔴 Red #D32F2F
⏸️ रोका गया (On Hold)     → ⚫ Gray #757575
```

### Action Colors:
```
Primary Action   → 🔵 Navy #000080 (Ashoka Chakra blue)
Success Action   → 🟢 Green #138808 (Flag green)
Warning Action   → 🟡 Amber #FFB300
Critical Action  → 🔴 Red #D32F2F
Info Display     → 🔵 Light Blue #0288D1
```

### Government Branding:
```
Header Background → 🔵 Navy #000080
Accent Elements   → 🟠 Saffron #FF9933 (Flag saffron)
Success/Verified  → 🟢 Green #138808 (Flag green)
```

---

## 5. BUTTON & TOUCH TARGET SIZES

### Minimum Sizes (Accessibility Standard):
```
┌─────────────────────────────────┐
│ PRIMARY BUTTON                  │
│ Height: 56px (minimum)          │
│ Width: Full-width or 200px min  │
│ Font: 18sp                      │
│ [    लॉगिन करें (Login)    ]   │
└─────────────────────────────────┘

┌──────────────────┐
│ SECONDARY BUTTON │
│ Height: 48px     │
│ Font: 16sp       │
│ [  रद्द करें  ]  │
└──────────────────┘

┌───────┐
│ ICON  │
│ 48x48 │
│  ℹ️   │
└───────┘
```

**Touch Targets:**
- Minimum: 48x48 dp
- Comfortable: 56x56 dp
- Large (Primary): 64x64 dp
- Spacing between: 8dp minimum

---

## 6. TYPOGRAPHY SCALE

### Hindi & English Text:
```
┌───────────────────────────────┐
│ पृष्ठ शीर्षक / Page Title     │
│ 32sp, Bold, Navy              │
├───────────────────────────────┤
│ अनुभाग शीर्षक / Section Head │
│ 24sp, Semi-bold, Dark Gray    │
├───────────────────────────────┤
│ मुख्य पाठ / Body Text         │
│ 18sp, Regular, Black          │
├───────────────────────────────┤
│ द्वितीयक पाठ / Secondary     │
│ 16sp, Regular, Gray           │
├───────────────────────────────┤
│ कैप्शन / Caption              │
│ 14sp, Regular, Light Gray     │
└───────────────────────────────┘
```

**Font Families:**
- Hindi: Noto Sans Devanagari
- English: Noto Sans
- Fallback: System default

---

## 7. ICON SYSTEM

### Large, Clear Icons (64x64 minimum):
```
🏗️  परियोजना (Project)
💰  फंड (Funds)
📋  रिपोर्ट (Report)
🏢  एजेंसी (Agency)
📱  मोबाइल (Mobile)
🆔  आधार (Aadhaar)
✅  पूर्ण (Complete)
⏳  लंबित (Pending)
📍  स्थान (Location)
📅  तारीख (Date)
👤  उपयोगकर्ता (User)
❓  सहायता (Help)
📞  कॉल करें (Call)
🎤  बोलें (Voice)
```

**Icon Guidelines:**
- Size: 48-64px for primary actions
- Color: Match action type
- Always paired with text label
- Use outline style for consistency
- High contrast against background

---

## 8. FORM FIELD DESIGN

### Text Input Field:
```
┌─────────────────────────────────┐
│ मोबाइल नंबर [?]                 │
│ ┌─────────────────────────────┐ │
│ │ 98XXXXXXXX (उदाहरण)         │ │
│ │ [___________________] [🎤]  │ │
│ └─────────────────────────────┘ │
│ ✓ सही नंबर (Green checkmark)   │
└─────────────────────────────────┘
```

**Components:**
- Label: 18sp, Bold, above field
- Help icon (?): Tooltip on tap
- Example text: Light gray placeholder
- Voice input button: Right side
- Validation: Green checkmark or red error
- Error message: Red text below, solution included

---

## 9. NAVIGATION BAR (Bottom)

```
┌─────────────────────────────────┐
│  🏠        📁        💰        ❓│
│  होम    परियोजना  फंड     मदद  │
│ (32px)   (32px)   (32px)  (32px)│
│ [Navy]  [Gray]   [Gray]  [Gray] │
└─────────────────────────────────┘
```

**Specifications:**
- Height: 72px (extra tall for visibility)
- Icons: 32px
- Labels: 14sp, always visible
- Active state: Navy color + bold text
- Inactive state: Gray
- Haptic feedback on tap

---

## 10. HELP BUTTON (Floating)

```
        ┌──────────────┐
        │      ❓      │
        │    सहायता    │
        │  [Green Btn] │
        │     56x56    │
        └──────────────┘
           ↑ Always visible
           ↓ Bottom-right corner
```

**Tap opens:**
```
┌─────────────────────────────────┐
│         मदद चाहिए?              │
├─────────────────────────────────┤
│ 📞 कॉल करें                     │
│    1800-XXX-XXXX                │
│    [48px button]                │
├─────────────────────────────────┤
│ 💬 WhatsApp                     │
│    +91-XXXXX-XXXXX              │
│    [48px button]                │
├─────────────────────────────────┤
│ 📖 गाइड देखें                   │
│    [48px button]                │
├─────────────────────────────────┤
│ 🎥 वीडियो ट्यूटोरियल           │
│    [48px button]                │
└─────────────────────────────────┘
```

---

## 11. NOTIFICATION DESIGN

### BEFORE:
```
Standard Android notification
```

### AFTER (Recommended):
```
┌─────────────────────────────────┐
│ 🔔 PM-AJAY                      │
│                                 │
│ ✅ परियोजना स्वीकृत!            │
│                                 │
│ आपकी "आदर्श ग्राम XYZ"         │
│ परियोजना स्वीकृत हो गई है।     │
│                                 │
│ [विवरण देखें]  [ठीक है]        │
└─────────────────────────────────┘
```

**Features:**
- Large emoji/icon for recognition
- Bilingual text
- Clear status indicator
- Large action buttons
- High-contrast colors

---

## 12. OFFLINE MODE INDICATOR

```
┌─────────────────────────────────┐
│ 🔴 आप ऑफलाइन हैं                │
│                                 │
│ कोई चिंता नहीं! आप अभी भी       │
│ डेटा देख सकते हैं और फॉर्म      │
│ भर सकते हैं।                    │
│                                 │
│ जब इंटरनेट आएगा, सब सेव हो     │
│ जाएगा।                          │
└─────────────────────────────────┘
```

**Persistent bar at top:**
```
[🔴 ऑफलाइन | 3 items queued]
```

---

## 13. LANGUAGE SELECTOR

```
┌─────────────────────────────────┐
│  भाषा चुनें / Choose Language   │
├─────────────────────────────────┤
│  [x] हिंदी                      │
│  [ ] English                    │
│  [ ] বাংলা (Bengali)            │
│  [ ] தமிழ் (Tamil)              │
│  [ ] తెలుగు (Telugu)            │
│  [ ] मराठी (Marathi)            │
│  [ ] ગુજરાતી (Gujarati)         │
│  [ ] ಕನ್ನಡ (Kannada)            │
│  ... (all 22 languages)         │
│                                 │
│  [सहेजें / Save - 56px btn]    │
└─────────────────────────────────┘
```

---

## 14. ACCESSIBILITY SETTINGS

```
┌─────────────────────────────────┐
│  सुविधाएं / Accessibility      │
├─────────────────────────────────┤
│  📏 टेक्स्ट का आकार             │
│     [छोटा] [मध्यम] [बड़ा]      │
│     [बहुत बड़ा]                 │
├─────────────────────────────────┤
│  🎨 हाई कॉन्ट्रास्ट मोड        │
│     [●---] Off/On               │
├─────────────────────────────────┤
│  🌙 डार्क मोड                   │
│     [●---] Off/On               │
├─────────────────────────────────┤
│  🎤 वॉयस इनपुट                  │
│     [●---] Off/On               │
├─────────────────────────────────┤
│  📢 टेक्स्ट टू स्पीच            │
│     [●---] Off/On               │
├─────────────────────────────────┤
│  💾 डेटा सेवर मोड               │
│     [●---] Off/On               │
└─────────────────────────────────┘
```

---

## 15. ONBOARDING SCREENS

### Screen 1:
```
┌─────────────────────────────────┐
│                                 │
│      [Large Illustration]       │
│      🇮🇳 Government Emblem       │
│                                 │
│   PM-AJAY में आपका स्वागत है    │
│                                 │
│   यह ऐप सरकारी परियोजनाओं       │
│   को ट्रैक करने में मदद करता है│
│                                 │
│         ● ○ ○ ○                 │
│                                 │
│   [आगे बढ़ें →]  [छोड़ें]       │
└─────────────────────────────────┘
```

### Screen 2:
```
┌─────────────────────────────────┐
│                                 │
│    [Illustration: Projects]     │
│         📁 🏗️ 📋               │
│                                 │
│    अपनी परियोजनाएं देखें        │
│                                 │
│   यहां आप सभी परियोजनाओं की     │
│   जानकारी पा सकते हैं।          │
│   प्रगति देख सकते हैं।           │
│                                 │
│         ○ ● ○ ○                 │
│                                 │
│   [आगे बढ़ें →]  [छोड़ें]       │
└─────────────────────────────────┘
```

---

## IMPLEMENTATION CHECKLIST

### Phase 1: Foundation (Week 1-2)
- [ ] Update theme colors to Government scheme
- [ ] Increase all font sizes (+2-4sp)
- [ ] Replace button heights to 56px minimum
- [ ] Add Hindi labels throughout
- [ ] Create language selector
- [ ] Implement bottom navigation

### Phase 2: Features (Week 3-4)
- [ ] Add phone + OTP login
- [ ] Redesign dashboard with 4 cards
- [ ] Enhance project cards with large icons
- [ ] Add voice search buttons
- [ ] Create help dialog system
- [ ] Implement offline mode

### Phase 3: Polish (Week 5-6)
- [ ] Add onboarding flow
- [ ] Create tutorial overlays
- [ ] Implement accessibility settings
- [ ] Add trust indicators
- [ ] Test with target users
- [ ] Iterate based on feedback

---

## TESTING PROTOCOL

### Usability Tests:
1. **Task: Find project status**
   - Time limit: 2 minutes
   - Success: User locates project < 2 min

2. **Task: Check fund amount**
   - Time limit: 1 minute
   - Success: User finds amount < 1 min

3. **Task: Get help**
   - Time limit: 30 seconds
   - Success: User finds help number

### Test with:
- 5 rural users (varied literacy)
- 3 elderly users (60+)
- 2 users with disabilities
- Different devices (low/high-end)

---

## CONCLUSION

These visual mockups demonstrate how the PM-AJAY app can be transformed into an **accessible, user-friendly government application** that serves marginalized communities effectively. Every design choice prioritizes:

✅ **Clarity over complexity**
✅ **Large, touchable elements**
✅ **Bilingual by default**
✅ **Visual communication**
✅ **Trust and support**
✅ **Offline capability**

The result is an app that a first-time smartphone user can navigate confidently within minutes.