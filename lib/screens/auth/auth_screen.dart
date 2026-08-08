import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clg_application/services/auth_service.dart';
import 'package:clg_application/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool isInitialSignUp;
  final String? initialFirstName;
  final String? initialLastName;
  final String? initialRole;
  
  const AuthScreen({
    super.key, 
    this.isInitialSignUp = false,
    this.initialFirstName,
    this.initialLastName,
    this.initialRole,
  });

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic Controllers
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  
  // Signup Specific Controllers
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  
  DateTime? _selectedDate;
  late bool _isSignUp;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isInitialSignUp;
    _emailController = TextEditingController(text: _isSignUp ? '' : 'saravanapmvofficial@gmail.com');
    _passwordController = TextEditingController(text: _isSignUp ? '' : 'Sivamani9698pmv\$');
    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isSignUp && _selectedDate == null) {
      _showSnackBar('Please select your birth date', AppColors.error);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      if (_isSignUp) {
        // Simulate Signup
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Notification sent to Admin'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          context.push('/request-submitted');
        }
      } else {
        await ref.read(authServiceProvider).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Failed: ${e.toString()}', AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Header (Page stable, only text changes)
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _isSignUp ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: Column(
                    children: [
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Login to access your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                  secondChild: Column(
                    children: [
                      Text(
                        'Get Started Now',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create an account to explore UNISPHERE',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Tab Switcher (Stable)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildTabSwitcher(),
                ),
                const SizedBox(height: 32),
                // Form Content (Animated)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _isSignUp ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        firstChild: _buildLoginForm(),
                        secondChild: _buildSignupForm(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email Address', style: _labelStyle),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _emailController,
          hint: 'example@unisphere.edu',
          icon: Icons.email_outlined,
          validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
        ),
        const SizedBox(height: 24),
        const Text('Password', style: _labelStyle),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _passwordController,
          hint: '*******',
          icon: Icons.lock_outline,
          isPassword: true,
          obscureText: _obscurePassword,
          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
          validator: (val) => val == null || val.length < 6 ? 'Password too short' : null,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _rememberMe = val ?? false),
                ),
                const Text('Remember me', style: TextStyle(fontSize: 13)),
              ],
            ),
            TextButton(onPressed: () {}, child: const Text('Forgot password?', style: TextStyle(fontSize: 13))),
          ],
        ),
        const SizedBox(height: 32),
        _buildSubmitButton('Log In'),
        const SizedBox(height: 32),
        _buildSocialLogins(),
        const SizedBox(height: 32),
        _buildDemoLogins(),
      ],
    );
  }

  Widget _buildDemoLogins() {
    return Center(
      child: Column(
        children: [
          const Text('⚡ Quick Demo Access & Autofill', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _demoChip('🏛️ Department (HOD)', 'hod.cse@unisphere.edu', 'HodPass123!', () => context.go('/hod')),
              _demoChip('👑 Admin', 'admin@unisphere.edu', 'AdminPass123!', () => context.go('/admin')),
              _demoChip('👨‍🏫 Staff', 'staff@unisphere.edu', 'StaffPass123!', () => context.go('/staff')),
              _demoChip('🎓 Student', 'saravanapmvofficial@gmail.com', 'Sivamani9698pmv\$', () => context.go('/student')),
              _demoChip('👨‍👩‍👧 Parent', 'parent@unisphere.edu', 'ParentPass123!', () => context.go('/parent')),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _demoChip(String role, String email, String pass, VoidCallback directAccess) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              onTap: () {
                setState(() {
                  _isSignUp = false; // Switch to Sign In mode
                  _emailController.text = email;
                  _passwordController.text = pass;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Autofilled $role credentials! Tap Log In or double tap to launch.'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(role, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
              onTap: directAccess,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                ),
                child: const Row(
                  children: [
                    Text('Open ➔', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Column(
      key: const ValueKey('signup_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('First Name', style: _labelStyle),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _firstNameController, hint: 'Raj'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Last Name', style: _labelStyle),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _lastNameController, hint: 'Sarkar'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Email Address', style: _labelStyle),
        const SizedBox(height: 8),
        _buildTextField(controller: _emailController, hint: 'example@unisphere.edu', icon: Icons.email_outlined),
        const SizedBox(height: 20),
        const Text('Birth of date', style: _labelStyle),
        const SizedBox(height: 8),
        _buildDatePicker(),
        const SizedBox(height: 20),
        const Text('Phone Number', style: _labelStyle),
        const SizedBox(height: 8),
        _buildTextField(controller: _phoneController, hint: '+91 98765 43210', icon: Icons.phone_outlined),
        const SizedBox(height: 20),
        const Text('Set Password', style: _labelStyle),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _passwordController,
          hint: '*******',
          icon: Icons.lock_outline,
          isPassword: true,
          obscureText: _obscurePassword,
          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 32),
        _buildSubmitButton('Sign Up'),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSubmitButton(String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading 
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null ? 'Select Date' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              style: TextStyle(color: _selectedDate == null ? AppColors.textTertiary : AppColors.textPrimary, fontSize: 16),
            ),
            const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLogins() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.border)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Or', style: TextStyle(color: Colors.grey, fontSize: 12))),
            Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildSocialButton('Google', Icons.g_mobiledata, Colors.red)),
            const SizedBox(width: 16),
            Expanded(child: _buildSocialButton('Facebook', Icons.facebook, Colors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _buildTab('Sign In', false),
          _buildTab('Sign Up', true),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSignUpTab) {
    final isSelected = _isSignUp == isSignUpTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isSignUp = isSignUpTab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))] : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.textPrimary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.primary, size: 20) : null,
        suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: onToggleVisibility) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary);
}
