import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51JFH9zSGTdxZA1VVPlzCM1b4ztYvbz452v792r5iofLUkOdc15YdKHAv6VLSkt7qT5l643GIanpkbi8YCAQo47fm004YSyva3s';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Payment(),
    );
  }
}

class Payment extends StatefulWidget {
  const Payment({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Payment> {
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
      ),
      body: Center(
        child: TextButton(
          child: const Text('Make Payment'),
          onPressed: () async {
            await makePayment();
          },
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('10', 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: const SetupPaymentSheetParameters(
          paymentIntentClientSecret:
              'sk_test_51JFH9zSGTdxZA1VV3MtP5wDpatKDerB7R6gdV2Vk4h5Qs6AMpng9Yke15xZzDQveyqt8NFPQ36pAiEgAfn8x5nNh00i7PPFMej',
          googlePay: PaymentSheetGooglePay(
              testEnv: true, currencyCode: "USD", merchantCountryCode: "DE"),
          style: ThemeMode.dark,
          merchantDisplayName: 'anjali',
        ),
      );
      displayPaymentSheet();
    } catch (e) {
      if (kDebugMode) {
        if (e is StripeConfigException) {
          print("Stripe exception ${e.message}");
        } else {
          print("exception $e");
        }
      }
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      // showDialog(
      //   context: context,
      //   builder: (_) => const AlertDialog(
      //     content: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Row(
      //           children: [
      //             Icon(Icons.check_circle, color: Colors.green),
      //             Text("Payment Successful"),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
      paymentIntent = null;
    } on StripeException catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Cancelled"),
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var secretKey =
          "sk_test_51JFH9zSGTdxZA1VV3MtP5wDpatKDerB7R6gdV2Vk4h5Qs6AMpng9Yke15xZzDQveyqt8NFPQ36pAiEgAfn8x5nNh00i7PPFMej";
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print('Payment Intent Body: ${response.body.toString()}');
      return jsonDecode(response.body.toString());
    } catch (err) {
      print('Error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }
// Implement other methods here
}
