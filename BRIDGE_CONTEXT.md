# Bridge — Living Context File

> **Read this before building anything in this project.**
> This is the single source of truth for design language, features, architecture rules, and screen inventory.

---

## 1. Product Identity

- **App name:** Bridge
- **Tagline:** "Bridge the distance. Send money home."
- **Purpose:** Help Canadians (primarily African diaspora) send money to home countries
- **Primary user:** Canadian resident (e.g. Montreal, QC) sending CAD to Africa
- **Primary corridor:** Canada → Kenya (CAD → KES), expanding to other African corridors
- **Inspiration:** Remitly UX/flow — but rebranded as Bridge with Prime membership added
- **Replace everywhere:** "Remitly" → "Bridge", "Remitly Business" → "Bridge Business"

---

## 2. Tech Stack

| Layer | Technology |
|---|---|
| Mobile framework | Flutter (Dart) — iOS + Android |
| Auth | Firebase Auth (phone OTP + email/password + biometrics) |
| Database | Cloud Firestore |
| Backend logic | Firebase Cloud Functions (TypeScript) |
| File storage | Firebase Storage (KYC docs) |
| Subscriptions | RevenueCat (Prime membership) |
| Local security | flutter_secure_storage |
| Biometrics | local_auth |
| Navigation | GoRouter |
| State management | Riverpod |
| Remote config | Firebase Remote Config (rates, flags, pricing) |

---

## 3. Color Palette

| Role | Hex |
|---|---|
| Primary CTA / Nav active / Send FAB | `#1B2B4B` dark navy |
| Background | `#FFFFFF` |
| Surface / secondary bg | `#F5F5F5` light gray |
| Info / promo card background | `#E8EEF8` soft blue |
| Success / Verified badge | `#2E7D32` green |
| Prime accent (gold) | `#F5A623` amber |
| Error / Sign out / Destructive | `#D32F2F` red |
| Body text | `#1A1A1A` near-black |
| Secondary / caption text | `#757575` gray |
| Dividers / borders | `#E0E0E0` |

---

## 4. Typography

System fonts only — SF Pro on iOS, Roboto on Android (Flutter default).

| Style | Weight | Size | Color |
|---|---|---|---|
| H1 / Screen title | Bold | 24px | `#1A1A1A` |
| H2 / Section heading | Bold | 20px | `#1A1A1A` |
| H3 / Subheading | SemiBold | 17px | `#1A1A1A` |
| Body | Regular | 15px | `#1A1A1A` |
| Body secondary | Regular | 15px | `#757575` |
| Caption | Regular | 13px | `#757575` |
| Amount (large) | Bold | 28-32px | `#1A1A1A` |
| Button label | SemiBold | 16px | white or `#1A1A1A` |

---

## 5. Component Library

### Buttons
- **Primary button:** Full-width, `#1B2B4B` background, white text, `BorderRadius.circular(28)` (pill), height 52px
- **Outlined button:** White bg, `#1B2B4B` border + text, same radius, height 52px
- **Destructive button:** Red text, no border (e.g. Sign out)

### Cards
- `BorderRadius.circular(12)`, white background
- Subtle shadow: `BoxShadow(color: black12, blurRadius: 4, offset: Offset(0,2))`
- OR thin border: `Border.all(color: #E0E0E0)`

### Info / Promo Cards
- `BorderRadius.circular(12)`, `#E8EEF8` background, no shadow
- Illustration or icon on the right side

### Contact Avatar
- Circle, initials (2 letters) in gray `#E0E0E0` background, dark text
- Country flag badge: 16×16px, bottom-right corner of avatar circle

### Status Pill
- Rounded pill: `BorderRadius.circular(20)`
- Delivered: green bg `#E8F5E9`, green text `#2E7D32`
- Processing: amber bg `#FFF8E1`, amber text `#F9A825`
- Failed: red bg `#FFEBEE`, red text `#D32F2F`
- Pending: gray bg `#F5F5F5`, gray text `#757575`

### List Row
- Icon (24px, gray) + title + optional subtitle + right chevron (`Icons.chevron_right`)
- Height: 56-64px, thin `Divider` between rows
- Tap highlights with `InkWell` ripple

### Send FAB (center tab)
- Raised `#1B2B4B` circle, 56×56px, white arrow-up-right icon
- Slightly elevated above the tab bar (negative margin or `notchedShape`)

### Payment Method Card
- Bordered card with radio button on right
- Icon (Interac logo, bank icon, card icon) + name + delivery time + exchange rate
- "BEST VALUE" badge: small green pill top-left of card
- "INSTANT" badge: small amber pill for Prime / card options

### Prime Badge
- Small amber `#F5A623` pill with crown icon + "PRIME"

---

## 6. Navigation Structure

```
Bottom Tab Bar (always visible after auth):
  [Home]  [Contacts]  [● SEND ●]  [Rewards]  [Manage]
```

- Tab icons: outlined when inactive, filled when active
- Active: `#1B2B4B` icon + label
- Inactive: `#9E9E9E` icon, no label or gray label
- Send tab = raised FAB circle, no label, launches send flow as modal bottom sheet

### Route Map
```
/splash
/welcome
/onboarding
  /onboarding/phone
  /onboarding/verify-otp
  /onboarding/email-password
  /onboarding/personal-info
  /onboarding/address
  /onboarding/id-upload
  /onboarding/selfie
  /onboarding/pending
/login
  /login/biometric
  /login/password
/shell  (tab bar host)
  /home
  /contacts
  /rewards
  /manage
    /manage/profile
    /manage/settings
    /manage/payment-methods
    /manage/prime
/send  (modal sheet, owns its own sub-navigator)
  /send/recipient
  /send/amount
  /send/delivery-method
  /send/payment-method
  /send/confirm-payment
  /send/review
  /send/success
/transfer/:id  (detail)
```

---

## 7. Screen Inventory & Key Elements

### Splash
- Bridge logo centered, `#1B2B4B` background or white
- Auto-navigate: biometric prompt if returning device, else Welcome

### Welcome
- Logo + tagline
- "Get started" (primary button) → onboarding
- "Sign in" (outlined button) → login

### Onboarding (step-by-step)
- Top progress bar showing current step
- Back chevron on all steps except first
- Steps: Phone → OTP → Email+Password → Personal info → Address → ID upload → Selfie → Pending
- Pending screen: illustration + "We're verifying your identity" + estimated time

### Sign In
- Returning device: show biometric prompt immediately, "Use password instead" below
- New device: email + password form, "Forgot password" link

### Home
- Top: exchange rate banner "OUR BEST RATE: 1 CAD = XX.XX KES" + reward balance chip
- Quick send row: avatar chips (last 4 contacts) + "New contact"
- Prime upsell banner (for non-Prime users)
- Promo cards (Firebase Remote Config driven)
- Transfers section: paginated list with status badges

### Contacts
- "My contacts" heading + "Select favorites" top-right
- Search bar (rounded, gray bg)
- "Add new contact" row (blue avatar)
- List: avatar + name + delivery method (e.g. M-Pesa) + flag

### Send Flow (modal sheet)
- Top progress bar (6 steps)
- Step 1: Who to send to — New contact | Yourself | Recent list
- Step 2: Enter amount — CAD input, live KES preview, toggle direction
- Step 3: Delivery method — Mobile Money options + Bank
- Step 4: Payment method — INSTANT group (Prime first, then card) + BEST VALUE group (Interac, Bank)
- Step 5: Confirm payment method — masked details, exchange rate
- Step 6: Review — full summary, all sections editable, "Submit transfer" button

### Rewards
- Offers section (empty state or cards)
- "Redeem offer code" link
- Referrals: "Invite friends, get $20" card + "Invite friends" button
- Prime-exclusive section (for Prime members)

### Manage (hub)
- 2-up cards: "Refer friends" + "Help Center" (blue bg, icon, title, subtitle)
- Account details: country selector dropdown (flag + country name + chevron)
- Menu list: Profile (+ VERIFIED badge) | Settings | Payment methods | Redeem offer | Get Bridge Business (NEW badge)
- Footer links: Privacy | Legal | About
- Sign out (red)
- Version string

### Profile
- "Profile information" heading, back chevron
- Verification banner (green check when verified)
- Personal information: name (green check), DOB
- Contact information: address, phone, email, password — all with Edit chevrons

### Settings
- Language selector
- Destination country (flag + name)
- Profile activity: SMS toggle
- Marketing: App notifications toggle, Emails toggle
- Face ID / biometric toggle

### Payment Methods
- List of saved methods (card, bank, Interac email)
- "Add new card" row
- "Add bank account" row
- Default badge on primary method

### Prime Screen (upsell + management)
- Hero: Prime logo, price/month
- Feature comparison table (Standard vs Prime)
- "Subscribe" primary button or "Manage subscription" if already Prime
- FAQ section

---

## 8. Supported Corridors (MVP)

| Country | Currency | Delivery methods |
|---|---|---|
| Kenya | KES | M-Pesa, Bank |
| DR Congo | CDF | MTN Mobile Money, Airtel Money, Bank |
| Rwanda | RWF | MTN MoMo, Airtel Money, Bank |
| Nigeria | NGN | Bank, Mobile Money |
| Ghana | GHS | MTN MoMo, Vodafone Cash, Bank |
| Senegal | XOF | Orange Money, Bank |

---

## 9. Bridge Prime — Feature Summary

| Feature | Standard | Prime |
|---|---|---|
| Exchange rate | Standard rate | +0.5% better (server-configurable) |
| Interac e-Transfer delivery | ~9 hours | Instant |
| Transfer fee | Varies | $0.00 always |
| Monthly transfer limit | CAD 3,000 | CAD 10,000 |
| Priority support | No | Yes |
| Early corridor access | No | Yes |
| Prime badge in app | No | Yes (amber crown) |

- Subscription handled by **RevenueCat** (iOS App Store + Google Play)
- RevenueCat webhook → Cloud Function → Firestore update (never direct client write)
- `isPrime` re-validated from Firestore on every app resume

---

## 10. Firestore Data Model

```
/users/{uid}
  firstName, lastName, dateOfBirth, email, phone
  address: { street, city, province, postalCode }
  kycStatus: "pending" | "verified" | "rejected"
  isPrime: bool
  primeExpiresAt: Timestamp | null
  preferredCountry: string  // "KE" | "CD" | "RW" etc.
  createdAt: Timestamp
  updatedAt: Timestamp

/users/{uid}/contacts/{contactId}
  name, phone, country, deliveryMethod, walletProvider
  transferCount: int          // denormalized for sort
  lastUsedAt: Timestamp

/users/{uid}/transfers/{transferId}
  status: "pending" | "processing" | "delivered" | "failed"
  amountCAD: number
  feeCAD: number
  totalCAD: number
  amountLocal: number
  currency: string
  exchangeRate: number
  deliveryMethod: string
  paymentMethod: string
  recipientSnapshot: { name, phone, country, wallet }  // snapshot at time of transfer
  createdAt: Timestamp
  completedAt: Timestamp | null

/users/{uid}/paymentMethods/{methodId}
  type: "interac" | "bank" | "card"
  last4: string | null
  bankName: string | null
  email: string | null        // for Interac
  isDefault: bool

/primeSubscriptions/{uid}
  status: "active" | "cancelled" | "expired"
  plan: "monthly" | "annual"
  startedAt: Timestamp
  renewsAt: Timestamp
  cancelledAt: Timestamp | null
  revenueCatCustomerId: string

/exchangeRates/{corridorId}   // e.g. "CAD_KES"
  rate: number                // current blended rate
  standardRate: number
  primeRate: number
  updatedAt: Timestamp        // written by scheduled Cloud Function only

/appConfig                    // single document
  transferLimits: { daily, monthly, perTransaction }
  primePriceCAD: number
  primeAnnualPriceCAD: number
  supportedCorridors: string[]
```

---

## 11. System Design Rules (Non-Negotiable)

1. **Financial writes via Cloud Functions only.** Clients NEVER write directly to `/transfers`, `/primeSubscriptions`, or `/exchangeRates`.
2. **Paginate everything.** All list queries use `startAfterDocument` cursors. No unbounded queries.
3. **Snapshot pattern for transfers.** Recipient data is embedded in the transfer document at creation time — never joined on read.
4. **Exchange rates are server-side.** Never calculate rates in the Flutter client. Read from Firestore only.
5. **`isPrime` validated on resume.** Re-fetch user document from Firestore whenever the app returns to foreground. Never rely on local state.
6. **Sensitive data in secure storage only.** Auth tokens, biometric-gated keys → `flutter_secure_storage`. Never in SharedPreferences or in-memory only.
7. **Biometric = local gate.** Biometrics authenticate the device, but the active session is always a Firebase ID token. Biometric failure falls back to password.
8. **Security rules enforce isolation.** Firestore rules: `request.auth.uid == resource.data.uid` or `request.auth.uid == userId` in path.
9. **Composite indexes pre-declared.** All queries using `orderBy` + `where` must have matching entries in `firestore.indexes.json`.
10. **No business logic in the Flutter client.** Fee calculation, rate selection, limit checking — all Cloud Functions.

---

## 12. Project Structure

```
lib/
  core/
    theme/           // BridgeTheme, colors, text styles
    router/          // GoRouter config + guards
    constants/       // corridors, currencies, delivery methods
    extensions/      // String, DateTime helpers
  features/
    auth/
      onboarding/
      login/
      biometric/
    home/
    contacts/
    send/            // multi-step flow
    rewards/
    manage/
      profile/
      settings/
      payment_methods/
      prime/
  shared/
    widgets/         // ContactAvatar, StatusBadge, PrimaryButton, PrimeTag, etc.
    models/          // User, Contact, Transfer, PaymentMethod, ExchangeRate
    providers/       // Riverpod providers
    services/        // FirestoreService, AuthService, BiometricService
```

---

## 13. Build Phases

| Phase | Scope | Status |
|---|---|---|
| 1 | Flutter setup, Firebase config, Auth, Onboarding, Biometric login, Nav shell | 🔄 In progress |
| 2 | Send flow (6 steps), Contacts CRUD, Cloud Function: initiateTransfer | ⬜ Planned |
| 3 | Home screen, transfer history, real-time rate display | ⬜ Planned |
| 4 | Bridge Prime (RevenueCat, subscription screen, Prime payment option) | ⬜ Planned |
| 5 | Rewards, full Manage section, Settings, Payment Methods | ⬜ Planned |
| 6 | Push notifications, offline mode, analytics, Crashlytics, store prep | ⬜ Planned |
