import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';

/// Service to synchronize local data with remote backend
/// Implements offline-first pattern with pending operations queue
class SyncService {
  final AppDatabase _database;
  final ApiClient _apiClient;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService(this._database, this._apiClient);

  /// Initialize sync service and set up connectivity listener
  Future<void> initialize() async {
    print('    → Setting up connectivity listener...');
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final hasConnection = results.any(
        (result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet,
      );

      if (hasConnection && !_isSyncing) {
        // Trigger sync when connection is restored
        syncPendingOperations();
      }
    });
    print('    ✓ Connectivity listener active');

    // Note: Not performing initial sync on startup to avoid blocking
    // app initialization. Sync will happen automatically when:
    // 1. Connectivity changes to online
    // 2. User performs an operation that queues data
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Check if device is currently online
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );
  }

  /// Queue an operation to be synced when online
  Future<void> queueOperation({
    required String entityType,
    required int entityLocalId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await _database.insertPendingOperation(
      PendingOperationsCompanion.insert(
        entityType: entityType,
        entityLocalId: entityLocalId,
        operation: operation,
        payload: jsonEncode(payload),
      ),
    );

    // Try to sync immediately if online
    if (await isOnline()) {
      await syncPendingOperations();
    }
  }

  /// Sync all pending operations with the backend
  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      final operations = await _database.getAllPendingOperations();

      for (final operation in operations) {
        try {
          await _processPendingOperation(operation);
          // Remove operation from queue on success
          await _database.deletePendingOperation(operation.id);
        } catch (e) {
          // Increment retry count
          await _database.incrementRetryCount(operation.id);

          // Log error but continue processing other operations
          print('Failed to sync operation ${operation.id}: $e');

          // TODO: Implement exponential backoff or max retry limit
          // If retry count > threshold, mark as failed and notify user
        }
      }

      // After pushing pending operations, pull latest data
      await _pullLatestData();
    } finally {
      _isSyncing = false;
    }
  }

  /// Process a single pending operation
  Future<void> _processPendingOperation(PendingOperation operation) async {
    final payload = jsonDecode(operation.payload) as Map<String, dynamic>;

    switch (operation.entityType) {
      case 'bank':
        await _syncBank(operation.operation, payload);
        break;
      case 'expense':
        await _syncExpense(operation.operation, payload);
        break;
      case 'transaction':
        await _syncTransaction(operation.operation, payload);
        break;
      case 'budget':
        await _syncBudget(operation.operation, payload);
        break;
      case 'scheduled_payment':
        await _syncScheduledPayment(operation.operation, payload);
        break;
      case 'notification':
        await _syncNotification(operation.operation, payload);
        break;
      case 'chat_session':
        await _syncChatSession(operation.operation, payload);
        break;
      case 'chat_message':
        await _syncChatMessage(operation.operation, payload);
        break;
      default:
        print('Unknown entity type: ${operation.entityType}');
    }
  }

  // ============================================================================
  // Entity-specific sync methods (stubs for now - to be implemented with real API)
  // ============================================================================

  Future<void> _syncBank(String operation, Map<String, dynamic> payload) async {
    // TODO: Implement actual API calls
    // Example: await _apiClient.post('/banks', data: payload);
    print('Syncing bank: $operation - $payload');
  }

  Future<void> _syncExpense(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    // TODO: Implement actual API calls
    print('Syncing expense: $operation - $payload');
  }

  Future<void> _syncTransaction(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    // TODO: Implement actual API calls
    print('Syncing transaction: $operation - $payload');
  }

  Future<void> _syncBudget(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    // TODO: Implement actual API calls
    print('Syncing budget: $operation - $payload');
  }

  Future<void> _syncScheduledPayment(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    // TODO: Implement actual API calls
    print('Syncing scheduled payment: $operation - $payload');
  }

  Future<void> _syncNotification(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    // TODO: Implement actual API calls
    print('Syncing notification: $operation - $payload');
  }

  Future<void> _syncChatSession(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    // TODO: Implement actual API calls
    print('Syncing chat session: $operation - $payload');
  }

  Future<void> _syncChatMessage(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    // TODO: Implement actual API calls
    print('Syncing chat message: $operation - $payload');
  }

  /// Pull latest data from backend
  Future<void> _pullLatestData() async {
    try {
      // TODO: Implement pull logic for each entity type
      // This should fetch updates from backend and merge with local data
      // Use timestamps (updatedAt) to determine which version is newer
      // Implement conflict resolution strategy (e.g., last-write-wins, or user prompt)

      print('Pulling latest data from backend...');

      // Example structure:
      // final remoteBanks = await _apiClient.get('/banks/sync?since=$lastSyncTime');
      // await _mergeBanks(remoteBanks);
    } catch (e) {
      print('Failed to pull latest data: $e');
    }
  }

  /// Force a full sync (useful for manual refresh)
  Future<void> forceSyncAll() async {
    await syncPendingOperations();
  }

  /// Get sync status
  bool get isSyncing => _isSyncing;
}
