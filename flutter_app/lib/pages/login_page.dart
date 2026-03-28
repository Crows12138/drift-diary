import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../widgets/ocean_background.dart';
import '../widgets/glass_card.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = '请填写用户名和密码');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final api = ApiService();
      if (_isRegister) {
        final nickname = _nicknameController.text.trim();
        await api.register(
          username: username,
          password: password,
          nickname: nickname.isNotEmpty ? nickname : null,
        );
      } else {
        await api.login(username: username, password: password);
      }
      ref.read(authProvider.notifier).onLoggedIn();
    } on DioException catch (e) {
      final detail = e.response?.data;
      if (detail is Map && detail['detail'] != null) {
        setState(() => _error = detail['detail'].toString());
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        setState(() => _error = '服务器正在唤醒，请再试一次（首次访问需要约30秒）');
      } else {
        setState(() => _error = '网络错误，请稍后重试');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDayMode = Theme.of(context).brightness == Brightness.light;
    final textColor = isDayMode ? const Color(0xFF1A3A4A) : Colors.white;

    return OceanBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sailing, size: 64, color: textColor.withOpacity(0.8)),
                const SizedBox(height: 12),
                Text(
                  '漂流日记',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  '用文字记录心情，让日记在陌生人之间漂流',
                  style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _tabButton('登录', !_isRegister, () => setState(() => _isRegister = false)),
                          const SizedBox(width: 16),
                          _tabButton('注册', _isRegister, () => setState(() => _isRegister = true)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: '用户名',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: textColor.withOpacity(0.05),
                        ),
                        style: TextStyle(color: textColor),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '密码',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: textColor.withOpacity(0.05),
                        ),
                        style: TextStyle(color: textColor),
                        onSubmitted: (_) => _submit(),
                      ),
                      if (_isRegister) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            hintText: '昵称（选填）',
                            prefixIcon: const Icon(Icons.face_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: textColor.withOpacity(0.05),
                          ),
                          style: TextStyle(color: textColor),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82C4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(_isRegister ? '注册' : '登录', style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? const Color(0xFF3B82C4) : Colors.grey,
        ),
      ),
    );
  }
}
