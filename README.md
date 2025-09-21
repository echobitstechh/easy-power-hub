# 📱 EasyPH Mobile App Documentation

## 1. Introduction
**App Name**: EasyPH  
**Platform**: Flutter (cross-platform: Android & iOS)  
**Purpose**: EasyPH is an e-commerce & services hub that allows users to purchase products (solar, electronics, lighting) and request services (installation, repairs, utility).

---

## 2. Core Features
### 🔐 User Authentication
- Email/phone + password login
- Social login (Google, Facebook)
- OTP verification

### 🏠 Dashboard
- Category grid (Products, Services)
- Carousel banners
- Featured products/services

### 🛒 Products Module
- Browse by category (Solar, Electronics, Lighting)
- Product detail view
- Add to cart / wishlist

### 🛠 Services Module
- Request utility personnel for installation/repair
- Booking & scheduling
- Service history tracking

### 💳 Cart & Checkout
- Flexible payment options: Paystack, Flutterwave, Wallet
- Pay on delivery, instant payment, installment plan
- Order summary and confirmation

### 👛 Wallet
- Fund wallet via card/bank transfer
- View transactions
- Refund/returns management

### 🔔 Notifications
- Push notifications for orders, promos, and system alerts
- In-app notification center

### 👤 Profile
- View & update user info
- Manage addresses
- Order & service history

---

## 3. Technical Architecture
- **Frontend**: Flutter (Stacked MVVM architecture)
- **Backend**: Node.js + Express (with Sequelize & PostgreSQL)
- **APIs**: REST APIs (JSON format)
- **State Management**: Stacked + Reactive Services
- **Payments**: Paystack & Flutterwave SDKs
- **Authentication**: Firebase Auth (email/OTP) + backend token sync
- **Notifications**: Firebase Cloud Messaging (FCM)

---

## 4. Navigation Flow
- Routing handled via `app.router.dart`
- Centralized navigation control

---

## 5. Data Models (Flutter)

### User
```dart
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String token;
}
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final Discount? discount;
}
class CartItem {
  final String id;
  final Product product;
  final int quantity;
}
class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
}
class Wallet {
  final String id;
  final double balance;
  final List<Transaction> transactions;
}
7. User Guide
Sign Up & Login

Open the app

Register with email/phone and password

Verify OTP to activate account

Browsing Products

Navigate to Products tab

Search, filter, or select categories

Placing an Order

Add item(s) to cart

Choose delivery or pickup option

Select payment method (wallet, card, pay on delivery)

Confirm order

Requesting a Service

Go to Services tab

Choose service type (installation, repair, etc.)

Book and confirm schedule

Track assigned technician

Managing Wallet

Fund wallet with card or bank transfer

View wallet balance

Review transaction history

Profile & Notifications

Update personal details

Manage addresses

Check alerts in notification center

8. Deployment & Configuration

Environment Variables

API URLs

Firebase configs

Paystack/Flutterwave keys

Staging vs Production

Different API base URLs

Store Deployment

Generate signed APK/IPA

Upload to Play Store / App Store

9. Maintenance & Support

Bug reporting process via GitHub Issues

Versioning: Semantic Versioning

Changelog maintained in /CHANGELOG.md

© 2025 EchobitsTech – All Rights Reserved.