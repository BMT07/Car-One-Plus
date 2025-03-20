import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/api_service.dart';

class StripePaymentScreen extends StatefulWidget {
  final int reservationId;
  final double amount;
  //final String token;
  final Function(bool success) onPaymentComplete;

 const StripePaymentScreen({
    Key? key,
    required this.reservationId,
    required this.amount,
    //required this.token,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  _StripePaymentScreenState createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _checkoutUrl;
  late final WebViewController _controller;
  final String _baseApiUrl = 'http://192.168.42.156:5000'; // Changez ceci avec votre URL réelle
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _createCheckoutSession();

    // Initialisation du controller WebView avec la nouvelle API
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkPaymentCompletion(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement Stripe'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onPaymentComplete(false);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _checkoutUrl == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initialisation du paiement...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  widget.onPaymentComplete(false);
                  Navigator.of(context).pop();
                },
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    // Si l'URL est prête, charger la page et afficher la WebView
    if (_checkoutUrl != null) {
      _controller.loadRequest(Uri.parse(_checkoutUrl!));
    }

    // Retourner le widget WebView avec la nouvelle API
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  void _checkPaymentCompletion(String url) {
    // Vérifiez si l'URL correspond à vos URLs de succès ou d'échec
    if (url.contains('/payments/success')) {
      // Paiement réussi
      _handlePaymentSuccess();
    } else if (url.contains('/payments/cancel')) {
      // Paiement annulé
      _handlePaymentCancel();
    }
  }

  void _handlePaymentSuccess() {
    // Attendre un peu pour afficher la page de succès, puis fermer
    Future.delayed(const Duration(seconds: 2), () {
      widget.onPaymentComplete(true);
      Navigator.of(context).pop();
    });
  }

  void _handlePaymentCancel() {
    // Fermer immédiatement ou afficher un message
    widget.onPaymentComplete(false);
    Navigator.of(context).pop();
  }

  Future<void> _createCheckoutSession() async {
    try {
      final url = Uri.parse('$_baseApiUrl/payments/create-session');
      final token = await apiService.getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reservation_id': widget.reservationId,
          'amount': widget.amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _checkoutUrl = data['checkout_url'];
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur serveur: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de connexion: ${e.toString()}';
      });
    }
  }
}

class ReservationDetailScreen extends StatefulWidget {
  final int reservationId;
  final double amount;
  final String vehicleTitle;
  final String vehicleDescription;

  const ReservationDetailScreen({
    Key? key,
    required this.reservationId,
    required this.amount,
    required this.vehicleTitle,
    required this.vehicleDescription,
  }) : super(key: key);

  @override
  _ReservationDetailsScreenState createState() => _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailScreen> {
  bool _paymentComplete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la réservation'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600, // Limite la largeur maximale de la carte
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre de la réservation
                    Text(
                      'Réservation #${widget.reservationId}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),

                    // Détails du véhicule
                    Text(
                      'Véhicule',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.vehicleTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.vehicleDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Détails financiers
                    Text(
                      'Détails financiers',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Montant total:'),
                        Text(
                          '${widget.amount.toStringAsFixed(2)} €',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Statut du paiement
                    if (_paymentComplete)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade400),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Paiement effectué',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Bouton de paiement
                    if (!_paymentComplete)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _startPaymentProcess(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Payer ${widget.amount.toStringAsFixed(2)} €',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startPaymentProcess(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StripePaymentScreen(
          reservationId: widget.reservationId,
          amount: widget.amount,
          onPaymentComplete: (bool success) {
            setState(() {
              _paymentComplete = success;
            });

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paiement effectué avec succès!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}