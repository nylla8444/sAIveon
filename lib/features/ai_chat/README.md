# AI Financial Advisor Feature

## Overview
This feature provides an AI-powered financial advisor that analyzes the user's actual financial data and provides personalized recommendations.

## Key Features

### 1. **Real Financial Data Integration**
- Accesses user's bank accounts and balances
- Analyzes transaction history (income, expenses, transfers)
- Reviews budget allocations and spending patterns
- Monitors scheduled payments
- Generates financial insights and trends

### 2. **Personalized Financial Advice**
The AI can:
- Alert users to overspending or budget issues
- Identify unusual spending patterns
- Suggest concrete actions based on spending habits
- Help set realistic financial goals
- Provide budget recommendations
- Explain financial concepts clearly

### 3. **Smart Context Management**
- Loads comprehensive financial summary on initialization
- Refresh button to update data in real-time
- System prompt includes current financial data
- AI references actual numbers when giving advice

## Architecture

### Components

#### 1. FinancialDataService (`domain/services/financial_data_service.dart`)
Gathers and formats financial data for AI consumption.

#### 2. NewChatPage (`presentation/pages/new_chat_page.dart`)
Main chat interface with financial data integration and real-time updates.

## Example Use Cases

**Budget Alerts**: "How am I doing this month?"
**Spending Analysis**: "Where is most of my money going?"
**Financial Goals**: "I want to save $500 next month"

## Dependencies
- `google_generative_ai: ^0.4.6` - Gemini AI integration
- `flutter_ai_toolkit: ^0.10.0` - Chat UI components
- `gpt_markdown: ^1.1.2` - Markdown rendering
