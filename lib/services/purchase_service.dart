import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/purchase.dart';

class PurchaseService {
  static const _purchasesKey = 'purchases';

  Future<Purchase> createPurchase({
    required String userId,
    required String courseId,
    required double amount,
  }) async {
    final now = DateTime.now();
    final purchase = Purchase(
      id: now.millisecondsSinceEpoch.toString(),
      userId: userId,
      courseId: courseId,
      amount: amount,
      status: PaymentStatus.pending,
      createdAt: now,
      updatedAt: now,
    );

    await _savePurchase(purchase);
    return purchase;
  }

  Future<void> updatePurchaseStatus({
    required String purchaseId,
    required PaymentStatus status,
    String? transactionId,
  }) async {
    final purchases = await _getAllPurchases();
    final index = purchases.indexWhere((p) => p.id == purchaseId);
    
    if (index == -1) return;

    final updatedPurchase = purchases[index].copyWith(
      status: status,
      transactionId: transactionId,
      updatedAt: DateTime.now(),
    );

    purchases[index] = updatedPurchase;
    
    final prefs = await SharedPreferences.getInstance();
    final purchasesJson = jsonEncode(purchases.map((p) => p.toJson()).toList());
    await prefs.setString(_purchasesKey, purchasesJson);
  }

  Future<List<Purchase>> getUserPurchases(String userId) async {
    final purchases = await _getAllPurchases();
    return purchases.where((p) => p.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Purchase?> getPurchaseById(String id) async {
    final purchases = await _getAllPurchases();
    try {
      return purchases.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasUserPurchasedCourse(String userId, String courseId) async {
    final purchases = await _getAllPurchases();
    return purchases.any(
      (p) => p.userId == userId && 
             p.courseId == courseId && 
             p.status == PaymentStatus.success,
    );
  }

  Future<List<Purchase>> _getAllPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasesJson = prefs.getString(_purchasesKey);
    if (purchasesJson == null) return [];

    try {
      final List<dynamic> purchasesList = jsonDecode(purchasesJson);
      return purchasesList.map((json) => Purchase.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _savePurchase(Purchase purchase) async {
    final purchases = await _getAllPurchases();
    purchases.add(purchase);
    
    final prefs = await SharedPreferences.getInstance();
    final purchasesJson = jsonEncode(purchases.map((p) => p.toJson()).toList());
    await prefs.setString(_purchasesKey, purchasesJson);
  }
}
