import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/scam_check_result.dart';
import '../result/result_screen.dart';
import 'scam_check_provider.dart';

class ScamCheckScreen extends StatefulWidget {
  const ScamCheckScreen({super.key, required this.target});

  final CheckTarget target;

  @override
  State<ScamCheckScreen> createState() => _ScamCheckScreenState();
}

class _ScamCheckScreenState extends State<ScamCheckScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vui lòng nhập thông tin';
    switch (widget.target) {
      case CheckTarget.phone:
        if (!RegExp(r'^[\d+\-\s()]{6,20}$').hasMatch(v)) {
          return 'Số điện thoại không hợp lệ';
        }
        break;
      case CheckTarget.bankAccount:
        if (!RegExp(r'^[\d\-\s]{6,30}$').hasMatch(v)) {
          return 'Số tài khoản không hợp lệ';
        }
        break;
      case CheckTarget.url:
        if (!RegExp(r'\.[a-z]{2,}', caseSensitive: false).hasMatch(v)) {
          return 'Đường dẫn không hợp lệ';
        }
        break;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final provider = context.read<ScamCheckProvider>();
    final result = await provider.check(
      target: widget.target,
      input: _controller.text,
    );
    if (!mounted || result == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<ScamCheckProvider>().isLoading;
    final hint = switch (widget.target) {
      CheckTarget.phone => 'VD: 0987654321',
      CheckTarget.bankAccount => 'VD: 1903 5762 8810',
      CheckTarget.url => 'VD: https://example.com',
    };
    final keyboard = switch (widget.target) {
      CheckTarget.phone => TextInputType.phone,
      CheckTarget.bankAccount => TextInputType.number,
      CheckTarget.url => TextInputType.url,
    };

    return Scaffold(
      appBar: AppBar(title: Text('Kiểm tra ${widget.target.label.toLowerCase()}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nhập ${widget.target.label.toLowerCase()} cần kiểm tra',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controller,
                  keyboardType: keyboard,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) => _submit(),
                  validator: _validate,
                  inputFormatters: widget.target == CheckTarget.url
                      ? null
                      : [FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s()]'))],
                  decoration: InputDecoration(
                    hintText: hint,
                    prefixIcon: Icon(switch (widget.target) {
                      CheckTarget.phone => Icons.phone,
                      CheckTarget.bankAccount => Icons.account_balance,
                      CheckTarget.url => Icons.link,
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: loading ? null : _submit,
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.security),
                  label: Text(loading ? 'Đang phân tích…' : 'Kiểm tra'),
                ),
                const SizedBox(height: 16),
                const _Tip(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mẹo: Không vội cung cấp thông tin cá nhân hay chuyển tiền nếu bạn cảm thấy bị thúc ép.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
