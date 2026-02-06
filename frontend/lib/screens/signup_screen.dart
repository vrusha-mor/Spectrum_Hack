import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spectrum_flutter/services/auth_service.dart';
import 'package:spectrum_flutter/theme/app_colors.dart';
import 'package:spectrum_flutter/services/app_config_server.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  final _appConfig = AppConfigServer();

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await AuthService().signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _errorMessage = _appConfig.translate('error_email_in_use');
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _appConfig.translate('create_account_title'),
                    textAlign: TextAlign.left,
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _appConfig.translate('tagline_journey'),
                    textAlign: TextAlign.left,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildTextField(
                    controller: _nameController,
                    label: _appConfig.translate('name_label'),
                    icon: Icons.person_outline_rounded,
                    type: TextInputType.name,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: _appConfig.translate('email_address'),
                    icon: Icons.alternate_email_rounded,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: _appConfig.translate('password'),
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: _appConfig.translate('confirm_password'),
                    icon: Icons.verified_user_outlined,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.outfit(color: AppColors.fats, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  GestureDetector(
                    onTap: _isLoading ? null : _signup,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                           BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))
                        ]
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _appConfig.translate('create_account'),
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_appConfig.translate('already_have_account'), style: GoogleFonts.outfit(color: AppColors.grey)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          _appConfig.translate('sign_in'),
                          style: GoogleFonts.outfit(color: AppColors.accent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black)),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: type,
          style: GoogleFonts.outfit(color: AppColors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
            filled: true,
            fillColor: AppColors.lightGrey.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            hintText: '${_appConfig.translate('enter_your')} ${label.toLowerCase()}',
            hintStyle: GoogleFonts.outfit(color: AppColors.grey.withValues(alpha: 0.5), fontSize: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return _appConfig.translate('required');
            }
            if (isPassword && value.length < 6) {
              return _appConfig.translate('min_6_chars');
            }
            return null;
          },
        ),
      ],
    );
  }
}
