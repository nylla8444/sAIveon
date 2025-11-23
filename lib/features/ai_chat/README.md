# AI Financial Advisor Feature

## Overview
This feature provides an AI-powered financial advisor that analyzes the user's actual financial data and provides personalized recommendations with full chat history management.

## Key Features

### 1. **Real Financial Data Integration**
- Accesses user's bank accounts and balances
- Analyzes transaction history (income, expenses, transfers)
- Reviews budget allocations and spending patterns
- Monitors scheduled payments
- Generates financial insights and trends

### 2. **Chat History Management**
- **View Past Conversations**: Access all previous AI chat sessions
- **Delete Chats**: Remove unwanted chat history
- **Continue Conversations**: Resume past chats with context
- **Recent Chats Preview**: See last 3 chats on AI page
- **Time-based Sorting**: Most recent chats appear first

### 3. **Personalized Financial Advice**
The AI can:
- Alert users to overspending or budget issues
- Identify unusual spending patterns
- Suggest concrete actions based on spending habits
- Help set realistic financial goals
- Provide budget recommendations
- Explain financial concepts clearly

### 4. **Smart Context Management**
- Loads comprehensive financial summary on initialization
- Refresh button to update data in real-time
- System prompt includes current financial data
- AI references actual numbers when giving advice

## Architecture

### Components

#### 1. FinancialDataService (`domain/services/financial_data_service.dart`)
Gathers and formats financial data for AI consumption.

#### 2. NewChatPage (`presentation/pages/new_chat_page.dart`)
Main chat interface for starting new conversations with financial data integration.

#### 3. ChatHistoryPage (`presentation/pages/chat_history_page.dart`)
Displays all chat sessions with:
- Time-based sorting
- Delete functionality
- Empty state UI
- Navigation to individual chats

#### 4. ChatDetailPage (`presentation/pages/chat_detail_page.dart`)
View and continue specific chat sessions with full financial context.

#### 5. AIPage (`features/home/presentation/widgets/ai_page.dart`)
Home AI page showing:
- Recent chats preview (last 3)
- "View All Chats" button
- New chat creation

## Navigation Flow

```
AI Page
├── New Chat → NewChatPage
├── Recent Chat → ChatDetailPage (by sessionId)
└── View All Chats → ChatHistoryPage
    └── Chat Item → ChatDetailPage (by sessionId)
```

## Example Use Cases

**Budget Alerts**: "How am I doing this month?"
**Spending Analysis**: "Where is most of my money going?"
**Financial Goals**: "I want to save $500 next month"
**View History**: Access past financial advice
**Delete Old Chats**: Clean up conversation history

## Dependencies
- `google_generative_ai: ^0.4.6` - Gemini AI integration
- `flutter_ai_toolkit: ^0.10.0` - Chat UI components
- `gpt_markdown: ^1.1.2` - Markdown rendering
- `drift` - Database for chat persistence

## Database Schema

**ChatSessions Table**:
- `id` - Unique identifier
- `title` - Session title
- `lastMessageTime` - Last activity timestamp
- `isDeleted` - Soft delete flag

**ChatMessages Table**:
- `id` - Unique identifier
- `sessionId` - Reference to chat session
- `content` - Message text
- `isUser` - User vs AI message flag
- `timestamp` - Message timestamp
- `isDeleted` - Soft delete flag
