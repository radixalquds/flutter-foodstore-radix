
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransPaymentPage extends StatefulWidget {
  final String snapToken;

  const MidtransPaymentPage({
    super.key,
    required this.snapToken,
  });

  @override
  State<MidtransPaymentPage> createState() =>
      _MidtransPaymentPageState();
}

class _MidtransPaymentPageState
    extends State<MidtransPaymentPage> {
  WebViewController? _webViewController;
  bool _loading = true;
  bool _error = false;

  late final Uri _paymentUri;

  @override
  void initState() {
    super.initState();

    _paymentUri = Uri.parse(
      '${AppConfig.URL_PAYMENT}${widget.snapToken}',
    );

    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openPaymentInBrowser();
      });
    } else {
      _initializeWebView();
    }
  }

  Future<void> _openPaymentInBrowser() async {
    final result = await launchUrl(
      _paymentUri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _error = !result;
    });
  }

  void _initializeWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (!mounted) return;

            setState(() => _loading = false);

            if (url.contains('transaction_status=settlement') ||
                url.contains('/success')) {
              context.pop('success');
            } else if (url.contains('transaction_status=expire') ||
                url.contains('/failure')) {
              context.pop('failure');
            } else if (url.contains('transaction_status=cancel') ||
                url.contains('transaction_status=deny')) {
              context.pop('failure');
            }
          },
        ),
      )
      ..loadRequest(_paymentUri);

    _webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Midtrans Payment',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: kIsWeb
          ? Center(
              child: _error
                  ? const Text('Gagal membuka halaman pembayaran.')
                  : const Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Halaman pembayaran Midtrans dibuka di tab browser baru.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            )
          : Stack(
              children: [
                if (_webViewController != null)
                  WebViewWidget(
                    controller: _webViewController!,
                  ),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}
