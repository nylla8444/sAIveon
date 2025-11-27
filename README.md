# Personal Finance Manager 💰

A comprehensive offline-first personal finance management application built with Flutter, featuring an AI-powered financial advisor, multi-currency support, and intelligent budgeting tools.

## 📋 Table of Contents
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
- [Database Schema](#-database-schema)
- [Offline Capabilities](#-offline-capabilities)
- [AI Financial Advisor](#-ai-financial-advisor)
- [Multi-Currency Support](#-multi-currency-support)
- [Project Structure](#-project-structure)
- [Testing](#-testing)
- [Screenshots](#-screenshots)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### Core Financial Management
- **📊 Multi-Bank Management**: Track multiple bank accounts, e-wallets (GCash, Maya), and credit cards
- **💸 Transaction Tracking**: Record income, expenses, and transfers with detailed categorization
- **📈 Budget Management**: Set monthly budgets by category with visual progress tracking
- **🔔 Scheduled Payments**: Manage recurring bills and automatic payments
- **📅 Expense Analytics**: View spending trends across daily, weekly, monthly, and yearly periods
- **📊 Statistics Dashboard**: Comprehensive financial overview with charts and insights

### Advanced Features
- **🤖 AI Financial Advisor**: Powered by Google Gemini 2.0, provides personalized financial advice based on your actual data
- **💱 Multi-Currency Support**: Seamlessly switch between PHP (₱) and USD ($) throughout the app
- **📴 Offline-First Architecture**: Full functionality without internet connection (except AI features)
- **🔄 Real-Time Sync**: Queue operations for synchronization when connection is restored
- **💬 Chat History**: Save and revisit AI conversations about your finances
- **🎨 Modern Dark UI**: Beautiful, intuitive interface optimized for financial data visualization

## 🛠️ Tech Stack

### Frontend Framework
- **Flutter** 3.5.4+ - Cross-platform UI framework
- **Dart** 3.8.1+ - Programming language

### Core Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `drift` | 2.23.0 | Type-safe SQLite database ORM |
| `drift_flutter` | 0.2.0 | Flutter integration for Drift |
| `sqlite3_flutter_libs` | 0.5.0 | Native SQLite libraries |
| `google_generative_ai` | 0.4.6 | Gemini AI integration |
| `flutter_ai_toolkit` | 0.10.0 | Chat UI components |
| `gpt_markdown` | 1.1.2 | Markdown rendering for AI responses |
| `fl_chart` | 0.69.0 | Data visualization (charts, graphs) |
| `connectivity_plus` | 6.1.2 | Network status monitoring |
| `shared_preferences` | 2.3.3 | Local settings persistence |
| `flutter_secure_storage` | 9.2.2 | Secure credential storage |
| `path_provider` | 2.1.5 | File system access |
| `intl` | 0.19.0 | Internationalization and number formatting |
| `equatable` | 2.0.7 | Value equality comparisons |
| `dio` | 5.7.0 | HTTP client for API calls |
| `flutter_dotenv` | 5.1.0 | Environment variable management |

### Development Tools
- `flutter_lints` 5.0.0 - Lint rules and code analysis
- `drift_dev` 2.23.0 - Drift code generation
- `build_runner` 2.4.14 - Code generation runner

### Platform Support
- ✅ **Android** (minSdk 23 / Android 6.0+)
- ✅ **iOS** (12.0+)
- ✅ **Linux**
- ✅ **Web**

## 🏗️ Architecture

### Feature-First Clean Architecture

```
lib/
├── main.dart                    # App entry point
├── app/                         # App-level configurations
├── core/                        # Shared core functionality
│   ├── database/                # Drift database schema & migrations
│   ├── services/                # Global services (connectivity, currency, sync)
│   ├── di/                      # Dependency injection (ServiceLocator)
│   ├── network/                 # API client
│   ├── widgets/                 # Reusable UI components
│   ├── utils/                   # Utility functions
│   └── mixins/                  # Shared mixins
└── features/                    # Feature modules
    ├── banks/                   # Bank account management
    ├── transactions/            # Transaction CRUD
    ├── budgets/                 # Budget management
    ├── expenses/                # Expense tracking & analytics
    ├── statistics/              # Financial statistics & charts
    ├── ai_chat/                 # AI financial advisor
    ├── scheduled_payments/      # Recurring payment management
    ├── notifications/           # In-app notifications
    ├── home/                    # Home dashboard
    └── settings/                # App settings
```

### Key Design Patterns
- **ServiceLocator Pattern**: Centralized dependency injection
- **Repository Pattern**: Data access abstraction
- **Provider Pattern**: State management via InheritedWidget
- **Offline-First**: Local-first with eventual cloud sync
- **Clean Architecture**: Separation of presentation, domain, and data layers

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** 3.5.4 or higher
- **Dart SDK** 3.8.1 or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **Xcode** (for iOS development on macOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd appdev_finals
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   Create a `.env` file in the project root:
   ```env
   GEMINI_API_KEY=your_google_gemini_api_key_here
   ```
   
   To get a Gemini API key:
   - Visit [Google AI Studio](https://aistudio.google.com/api-keys)
   - Sign in with your Google account
   - Create a new API key
   - Copy and paste it into `.env`

4. **Generate Drift database code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Environment Configuration

The app uses environment variables for sensitive configuration:

| Variable | Description | Required |
|----------|-------------|----------|
| `GEMINI_API_KEY` | Google Gemini API key for AI features | Yes (for AI features) |

## 🗄️ Database Schema

The app uses **Drift** (SQLite) with 9 tables:

### Core Tables

**Banks** - User bank accounts and e-wallets
- `id`, `name`, `accountNumber`, `balance`, `color`, `logoPath`
- `serverId`, `createdAt`, `updatedAt`, `isDeleted`

**Transactions** - All financial transactions
- `id`, `bankId`, `toBankId`, `category`, `type` (send/receive/transfer)
- `amount`, `description`, `date`
- `serverId`, `createdAt`, `updatedAt`, `isDeleted`

**Budgets** - Monthly budget allocations
- `id`, `category`, `amount`, `period`
- `serverId`, `createdAt`, `updatedAt`, `isDeleted`

**Expenses** - Categorized expenses
- `id`, `category`, `amount`, `description`, `date`
- `serverId`, `createdAt`, `updatedAt`, `isDeleted`

**ScheduledPayments** - Recurring payments
- `id`, `name`, `amount`, `frequency`, `nextPaymentDate`, `category`
- `serverId`, `createdAt`, `updatedAt`, `isDeleted`

**Notifications** - In-app notifications
- `id`, `title`, `message`, `type`, `isRead`, `timestamp`
- `serverId`, `createdAt`, `updatedAt`, `isDeleted`

### AI Chat Tables

**ChatSessions** - AI conversation sessions
- `id`, `title`, `lastMessageTime`
- `createdAt`, `updatedAt`, `isDeleted`

**ChatMessages** - Individual messages in chat sessions
- `id`, `sessionId`, `content`, `isUser`, `timestamp`
- `createdAt`, `updatedAt`, `isDeleted`

### Sync Table

**PendingOperations** - Operations queued for cloud sync
- `id`, `tableName`, `operationType`, `recordId`, `data`, `timestamp`
- `createdAt`, `isDeleted`

### Migrations
- **Schema Version**: 4
- Includes migration paths from versions 1-3
- Handles schema evolution gracefully

## 📴 Offline Capabilities

### What Works Offline ✅
- ✅ View all banks and balances
- ✅ View transaction history (send, receive, transfer)
- ✅ Add, edit, delete transactions
- ✅ View and edit budgets
- ✅ Track expenses and view analytics
- ✅ Manage scheduled payments
- ✅ View notifications
- ✅ Navigate all pages
- ✅ Switch currencies
- ✅ View past AI chat history (read-only)

### Requires Internet ❌
- ❌ Start new AI chat
- ❌ Send messages to AI advisor
- ❌ Receive AI financial recommendations

### Offline Architecture
- **ConnectivityService**: Real-time network monitoring
- **SyncService**: Queues operations for later synchronization
- **Local-First**: All data stored in SQLite database
- **Graceful Degradation**: AI features disable automatically when offline
- **Visual Indicators**: Clear offline/online status in UI


## 🤖 AI Financial Advisor

Powered by **Google Gemini 2.0 Flash** model with personalized financial intelligence.

### Capabilities
- 📊 **Real-Time Data Analysis**: Accesses your actual banks, transactions, budgets, and expenses
- 💡 **Personalized Recommendations**: Provides advice based on your spending patterns
- 📈 **Financial Insights**: Identifies trends, overspending, and opportunities
- 💬 **Chat History**: Save and revisit conversations
- 🔄 **Context Awareness**: Maintains conversation context throughout session
- 🎯 **Goal Setting**: Helps set and track financial goals

### Example Queries
- "How am I doing this month?"
- "Where is most of my money going?"
- "Help me save $500 next month"
- "Am I overspending on food?"
- "What's my biggest expense category?"

### Data Privacy
- All financial data is processed locally
- Only anonymized summaries sent to Gemini API
- No personal identifiable information shared
- Chat history stored locally in encrypted database

## 💱 Multi-Currency Support

### Supported Currencies
- **PHP** - Philippine Peso (₱)
- **USD** - United States Dollar ($)

### Features
- 🔄 **Instant Switching**: Change currency in Settings
- 🎨 **Dynamic Formatting**: All amounts update automatically throughout the app
- 💾 **Persistent Preference**: Your choice is saved and restored
- 📊 **Chart Integration**: All graphs and visualizations use selected currency
- 🤖 **AI Integration**: Financial advisor uses your preferred currency

### Implementation
- **CurrencyService**: Global currency management with ChangeNotifier
- **Formatting Methods**:
  - `format(amount)` - With decimals (₱1,234.56)
  - `formatWhole(amount)` - Without decimals (₱1,235)
- **SharedPreferences**: Persists user preference
- **Automatic Updates**: UI rebuilds automatically on currency change

## 📁 Project Structure

### Feature Modules
Each feature follows consistent structure:

```
features/<feature>/
├── data/
│   └── repositories/         # Repository implementations
├── domain/
│   ├── entities/             # Business models
│   ├── repositories/         # Repository interfaces
│   └── services/             # Business logic services
└── presentation/
    ├── pages/                # Screen widgets
    └── widgets/              # Feature-specific components
```

### Core Services

**ServiceLocator** (`lib/core/di/service_locator.dart`)
- Initializes all services on app startup
- Provides dependency injection throughout app
- Manages service lifecycle and disposal

**CurrencyService** (`lib/core/services/currency_service.dart`)
- Global currency management
- Formats amounts with proper symbols and separators
- Notifies listeners on currency change

**ConnectivityService** (`lib/core/services/connectivity_service.dart`)
- Monitors network status in real-time
- Broadcasts connectivity changes
- Enables offline-first architecture

**SyncService** (`lib/core/sync/sync_service.dart`)
- Queues operations for cloud sync
- Handles eventual consistency
- Manages conflict resolution

## 🧪 Testing


### Test Scenarios
1. **Offline Mode Testing**
   - Disable network → Verify core features work
   - Attempt AI chat → Verify graceful error handling
   
2. **Currency Switching**
   - Change currency in Settings
   - Verify all pages update automatically
   
3. **Data Persistence**
   - Add transactions offline
   - Restart app → Verify data persists
   
4. **AI Chat**
   - Create new chat online
   - Verify financial data is included in context
   - Test chat history persistence


### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter_lints` for code analysis
- Format code with `dart format .`
- Add documentation comments for public APIs


## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **Drift Team** - For the powerful SQLite ORM
- **Google** - For Gemini AI API
- **FL Chart** - For beautiful chart visualizations
- **Open Source Community** - For all the amazing packages

---


For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
