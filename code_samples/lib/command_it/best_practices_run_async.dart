// ignore_for_file: unused_local_variable, unused_field
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region sequential
class OnboardingManager {
  late final createAccountCommand = Command.createAsync<AccountData, User>(
    (data) => api.createAccount(data),
    initialValue: User.empty(),
  );

  late final setupProfileCommand = Command.createAsyncNoResult<ProfileData>(
    (profile) => api.setupProfile(profile),
  );

  late final sendWelcomeEmailCommand = Command.createAsyncNoParamNoResult(
    () => api.sendWelcomeEmail(),
  );

  // Sequential execution: Each step depends on the previous
  Future<void> completeOnboarding(
      AccountData account, ProfileData profile) async {
    // Create account first
    final user = await createAccountCommand.runAsync(account);

    // Then setup profile (needs user ID from previous step)
    await setupProfileCommand.runAsync(profile.copyWith(userId: user.id));

    // Finally send email
    await sendWelcomeEmailCommand.runAsync();
  }
}
// #endregion sequential

// #region async_workflow
class PaymentManager {
  late final validatePaymentCommand = Command.createAsync<PaymentInfo, bool>(
    (info) => api.validatePayment(info),
    initialValue: false,
  );

  late final processPaymentCommand = Command.createAsync<PaymentInfo, Receipt>(
    (info) => api.processPayment(info),
    initialValue: Receipt.empty(),
  );

  // Complex async workflow
  Future<Receipt> completeCheckout(Cart cart, PaymentInfo payment) async {
    // Step 1: Validate inventory (not a command, just async call)
    final available = await api.checkInventory(cart.items);
    if (!available) throw InsufficientInventoryException();

    // Step 2: Validate payment (command)
    final isValid = await validatePaymentCommand.runAsync(payment);
    if (!isValid) throw InvalidPaymentException();

    // Step 3: Process payment (command)
    final receipt = await processPaymentCommand.runAsync(payment);

    // Step 4: Update inventory (not a command)
    await api.updateInventory(cart.items);

    return receipt;
  }
}
// #endregion async_workflow

// #region api_futures
class RefreshExample extends StatelessWidget {
  final Command<void, List<Data>> updateCommand;

  const RefreshExample({super.key, required this.updateCommand});

  @override
  Widget build(BuildContext context) {
    // RefreshIndicator requires Future<void>
    return RefreshIndicator(
      onRefresh: () => updateCommand.runAsync(),
      child: ListView(),
    );
  }
}
// #endregion api_futures

// #region dont_use_runasync
class BadExample extends StatelessWidget {
  final Command<void, List<Data>> loadDataCommand;

  const BadExample({super.key, required this.loadDataCommand});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ❌ BAD: Blocking UI thread waiting for result
        ElevatedButton(
          onPressed: () async {
            final result = await loadDataCommand.runAsync();
            // Do nothing with result - just waiting
          },
          child: Text('Load Bad'),
        ),

        // ✅ GOOD: Fire and forget, let UI observe
        ElevatedButton(
          onPressed: loadDataCommand.run,
          child: Text('Load Good'),
        ),
      ],
    );
  }
}
// #endregion dont_use_runasync

// Additional stubs
class AccountData {
  final String email;
  AccountData(this.email);
}

class ProfileData {
  final String? userId;
  final String name;
  ProfileData(this.name, [this.userId]);
  ProfileData copyWith({String? userId}) => ProfileData(name, userId);
}

class PaymentInfo {
  final double amount;
  PaymentInfo(this.amount);
}

class Receipt {
  final String id;
  Receipt(this.id);
  static Receipt empty() => Receipt('');
}

class Cart {
  final List<String> items;
  Cart(this.items);
}

class InsufficientInventoryException implements Exception {}

class InvalidPaymentException implements Exception {}

// API extensions
extension OnboardingApi on ApiClient {
  Future<User> createAccount(AccountData data) async {
    await simulateDelay();
    return User('1', data.email);
  }

  Future<void> setupProfile(ProfileData profile) async {
    await simulateDelay();
  }

  Future<void> sendWelcomeEmail() async {
    await simulateDelay();
  }

  Future<bool> validatePayment(PaymentInfo info) async {
    await simulateDelay();
    return true;
  }

  Future<Receipt> processPayment(PaymentInfo info) async {
    await simulateDelay();
    return Receipt('receipt-123');
  }

  Future<bool> checkInventory(List<String> items) async {
    await simulateDelay();
    return true;
  }

  Future<void> updateInventory(List<String> items) async {
    await simulateDelay();
  }
}

void main() {
  // Examples compile but don't run
}
