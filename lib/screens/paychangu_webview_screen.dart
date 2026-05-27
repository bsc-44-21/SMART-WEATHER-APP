import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class PaychanguWebViewScreen extends StatefulWidget {
  final String checkoutUrl;

  const PaychanguWebViewScreen({super.key, required this.checkoutUrl});

  @override
  State<PaychanguWebViewScreen> createState() => _PaychanguWebViewScreenState();
}

class _PaychanguWebViewScreenState extends State<PaychanguWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Mobile Safari/537.36")
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('[WebView] Error: ${error.description}');
            setState(() {
              _isLoading = false;
              _error = error.description;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('[WebView] Navigating to: $url');
            
            // Detect success return URL
            if (url.contains('smartweather.app/success')) {
              Navigator.pop(context, true); // Return true for potential success
              return NavigationDecision.prevent;
            }
            
            // Detect cancel/error if applicable
            if (url.contains('smartweather.app/cancel')) {
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Secure Checkout',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.black),
          onPressed: () => Navigator.pop(context, false),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _progress < 1.0
              ? LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey.shade100,
                  color: AppTheme.primaryAccent,
                  minHeight: 2,
                )
              : const SizedBox.shrink(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppTheme.primaryAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Payment Gateway...',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Connection Error',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _controller.reload(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}