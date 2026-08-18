import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:unisphere/models/user_model.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/core/constants/app_colors.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool isInitialSignUp;
  final String? initialFirstName;
  final String? initialLastName;
  final String? initialRole;
  final String? initialId;
  final String? initialDepartment;
  
  const AuthScreen({
    super.key, 
    this.isInitialSignUp = false,
    this.initialFirstName,
    this.initialLastName,
    this.initialRole,
    this.initialId,
    this.initialDepartment,
  });

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  
  // Basic Controllers
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  
  // Signup Specific Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _regNoController;
  late final TextEditingController _deptController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _phoneController;
  
  final UserRole _selectedRole = UserRole.student;
  late bool _isSignUp;
  late final PageController _pageController;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isInitialSignUp;
    _pageController = PageController(initialPage: _isSignUp ? 1 : 0);
    _emailController = TextEditingController(text: _isSignUp ? '' : 'saravanapmvofficial@gmail.com');
    _passwordController = TextEditingController(text: _isSignUp ? '' : 'Sivamani9698pmv\$');
    _nameController = TextEditingController(
      text: widget.initialFirstName != null ? '${widget.initialFirstName} ${widget.initialLastName ?? ''}'.trim() : '',
    );
    _regNoController = TextEditingController(text: widget.initialId);
    _deptController = TextEditingController(text: widget.initialDepartment ?? 'Computer Science');
    _confirmPasswordController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _regNoController.dispose();
    _deptController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleAuthMode(bool isSignUp) {
    if (_isSignUp == isSignUp) return;
    setState(() => _isSignUp = isSignUp);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        isSignUp ? 1 : 0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _navigateToUserDashboard(UserModel user) {
    if (!mounted) return;
    switch (user.role) {
      case UserRole.admin:
        context.go('/admin');
        break;
      case UserRole.hod:
        context.go('/hod');
        break;
      case UserRole.student:
        context.go('/student');
        break;
      case UserRole.staff:
        context.go('/staff');
        break;
      case UserRole.parent:
        context.go('/parent');
        break;
      default:
        context.go('/student');
        break;
    }
  }

  Future<void> _handleSubmit() async {
    final activeFormKey = _isSignUp ? _signupFormKey : _loginFormKey;
    if (activeFormKey.currentState != null && !activeFormKey.currentState!.validate()) return;

    if (_isSignUp) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showSnackBar('Password and Confirm Password do not match', AppColors.error);
        return;
      }
    }

    setState(() => _isLoading = true);
    
    try {
      if (_isSignUp) {
        final name = _nameController.text.trim();
        await ref.read(authServiceProvider).registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          name.isNotEmpty ? name : 'New Student',
          _selectedRole,
          phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          metadata: {
            'fullName': name,
            'registerNumber': _regNoController.text.trim(),
            'department': _deptController.text.trim(),
            'collegeEmail': _emailController.text.trim(),
            'profileCompletionStatus': 'incomplete',
            'profileCompletionPercentage': 10,
          },
        );
      } else {
        await ref.read(authServiceProvider).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      final currentUser = ref.read(authServiceProvider).currentUser;
      if (currentUser != null && mounted) {
        _navigateToUserDashboard(currentUser);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Authentication Notice: ${e.toString()}', AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) {
        bool isResetting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter your registered email to receive a password reset link.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetEmailController,
                    decoration: InputDecoration(
                      hintText: 'example@unisphere.edu',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isResetting
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            _showSnackBar('Enter a valid email address', AppColors.error);
                            return;
                          }
                          setDialogState(() => isResetting = true);
                          try {
                            await ref.read(authServiceProvider).sendPasswordResetEmail(email);
                            if (context.mounted) {
                              Navigator.pop(context);
                              _showSnackBar('✅ Password reset email sent to $email', AppColors.success);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              _showSnackBar('Notice: ${e.toString()}', AppColors.error);
                            }
                          } finally {
                            if (context.mounted) setDialogState(() => isResetting = false);
                          }
                        },
                  child: isResetting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Send Reset Link'),
                ),
              ],
            );
          },
        );
      },
    );
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
                // Header Title (Clean FadeTransition - ZERO text overlap)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: KeyedSubtree(
                    key: ValueKey<bool>(_isSignUp),
                    child: Column(
                      children: [
                        Text(
                          _isSignUp ? 'Get Started Now' : 'Welcome Back',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp ? 'Create an account to explore UNISPHERE' : 'Login to access your account',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Tab Switcher (Sliding Pill Indicator)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildTabSwitcher(),
                ),
                const SizedBox(height: 24),
                // Form Content (PageView - Isolated pages with ZERO text overlap)
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (pageIndex) {
                      final isSignUpPage = pageIndex == 1;
                      if (_isSignUp != isSignUpPage) {
                        setState(() => _isSignUp = isSignUpPage);
                      }
                    },
                    children: [
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Form(
                          key: _loginFormKey,
                          child: _buildLoginForm(),
                        ),
                      ),
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Form(
                          key: _signupFormKey,
                          child: _buildSignupForm(),
                        ),
                      ),
                    ],
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
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text('Forgot password?', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSubmitButton('Log In'),
        const SizedBox(height: 20),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              GestureDetector(
                onTap: () => _toggleAuthMode(true),
                child: const Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _buildSocialLogins(),
        const SizedBox(height: 28),
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
              _demoChip('🏛️ Department (HOD)', 'hod.cse@unisphere.edu', 'HodPass123!'),
              _demoChip('👑 Admin', 'admin@unisphere.edu', 'AdminPass123!'),
              _demoChip('👨‍🏫 Staff', 'staff@unisphere.edu', 'StaffPass123!'),
              _demoChip('🎓 Student', 'saravanapmvofficial@gmail.com', 'Sivamani9698pmv\$'),
              _demoChip('👨‍👩‍👧 Parent', 'parent@unisphere.edu', 'ParentPass123!'),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _demoChip(String role, String email, String pass) {
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
                _toggleAuthMode(false);
                _emailController.text = email;
                _passwordController.text = pass;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Autofilled $role credentials! Tap Log In or tap Open ➔ to launch.'),
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
              onTap: () async {
                setState(() {
                  _isSignUp = false;
                  _emailController.text = email;
                  _passwordController.text = pass;
                  _isLoading = true;
                });
                try {
                  await ref.read(authServiceProvider).signInWithEmail(email, pass);
                } catch (e) {
                  if (mounted) _showSnackBar('Demo Login Notice: ${e.toString()}', AppColors.error);
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
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
        const Text('Student Full Name', style: _labelStyle),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _nameController,
          hint: 'e.g. Saravana Perumal S',
          icon: Icons.person_outline,
          validator: (val) => _isSignUp && (val == null || val.trim().isEmpty) ? 'Please enter student full name' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Register Number', style: _labelStyle),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _regNoController,
                    hint: 'e.g. 922523243100',
                    icon: Icons.badge_outlined,
                    validator: (val) => _isSignUp && (val == null || val.trim().isEmpty) ? 'Enter Reg No' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Department', style: _labelStyle),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _deptController,
                    hint: 'e.g. Computer Science',
                    icon: Icons.school_outlined,
                    validator: (val) => _isSignUp && (val == null || val.trim().isEmpty) ? 'Enter Department' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('College Email Address', style: _labelStyle),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          hint: 'student@vsbec.ac.in',
          icon: Icons.email_outlined,
          validator: (val) => _isSignUp && (val == null || !val.contains('@')) ? 'Valid college email required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Password', style: _labelStyle),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                    validator: (val) => _isSignUp && (val == null || val.length < 6) ? 'Min 6 characters' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Confirm Password', style: _labelStyle),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: '••••••••',
                    icon: Icons.lock_clock_outlined,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    validator: (val) => _isSignUp && (val == null || val.isEmpty) ? 'Confirm password' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSubmitButton('Create Account & Continue →'),
        const SizedBox(height: 20),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              GestureDetector(
                onTap: () => _toggleAuthMode(false),
                child: const Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
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



  Widget _buildSocialLogins() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.border)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Or continue with', style: TextStyle(color: Colors.grey, fontSize: 12))),
            Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildGoogleButton(
                () async {
                  setState(() => _isLoading = true);
                  try {
                    await ref.read(authServiceProvider).signInWithGoogle();
                    final user = ref.read(authServiceProvider).currentUser;
                    if (user != null && mounted) {
                      _navigateToUserDashboard(user);
                    }
                  } catch (e) {
                    if (mounted) _showSnackBar('Google Sign-In Notice: ${e.toString()}', AppColors.error);
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSocialButton(
                'Apple',
                Icons.apple_rounded,
                Colors.black,
                () async {
                  setState(() => _isLoading = true);
                  try {
                    await ref.read(authServiceProvider).signInWithApple();
                    final user = ref.read(authServiceProvider).currentUser;
                    if (user != null && mounted) {
                      _navigateToUserDashboard(user);
                    }
                  } catch (e) {
                    if (mounted) _showSnackBar('Apple Sign-In Notice: ${e.toString()}', AppColors.error);
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoogleButton(VoidCallback onTap) {
    return OutlinedButton(
      onPressed: _isLoading ? null : onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/google_logo.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          const Text('Google', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: _isLoading ? null : onTap,
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
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 8) / 2;
          return Stack(
            children: [
              // Sliding White Pill Indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                alignment: _isSignUp ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: tabWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab Text Touch Targets
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _toggleAuthMode(false),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: !_isSignUp ? FontWeight.bold : FontWeight.w600,
                            color: !_isSignUp ? AppColors.primary : AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _toggleAuthMode(true),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: _isSignUp ? FontWeight.bold : FontWeight.w600,
                            color: _isSignUp ? AppColors.primary : AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
