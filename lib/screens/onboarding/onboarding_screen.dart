
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/core/constants/app_departments.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  // Selection states
  String? _selectedRole;
  String? _selectedDept;

  final List<String> _roles = ['Student', 'Faculty', 'Department (HOD)', 'Parent'];
  final List<String> _departments = AppDepartments.list;

  void _onNext() {
    if (_currentPage < 4) {
      // Role Validation
      if (_currentPage == 1 && _selectedRole == null) {
        _showError('Please select a role to continue');
        return;
      }
      // Name Validation
      if (_currentPage == 2 && _nameController.text.trim().isEmpty) {
        _showError('Please enter your name to continue');
        return;
      }
      // Details Validation
      if (_currentPage == 3) {
        if (_idController.text.trim().isEmpty) {
          _showError('Please enter your ID to continue');
          return;
        }
        if (_selectedDept == null && _selectedRole != 'Parent') {
          _showError('Please select your department');
          return;
        }
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _completeOnboarding() {
    final name = _nameController.text.trim();
    final role = _selectedRole ?? 'Student';
    
    // Split name for signup prepopulation
    final nameParts = name.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    context.go(
      Uri(
        path: '/signup',
        queryParameters: {
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          'id': _idController.text.trim(),
          'department': _selectedDept ?? '',
        },
      ).toString(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                   _buildIntroPage(),
                  _buildRoleSelectionPage(),
                  _buildNameInputPage(),
                  _buildDetailsPage(),
                  _buildFinalPage(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'UNISPHERE',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          if (_currentPage < 4)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicators
          Row(
            children: List.generate(
              5,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                height: 6,
                width: _currentPage == index ? 20 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          // Next Button
          GestureDetector(
            onTap: _onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: _currentPage == 4 ? 32 : 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentPage == 4) ...[
                    const Text(
                      "Launch App",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroPage() {
    return Column(
      children: [
        Expanded(
          child: _buildPageLayout(
            title: 'Your Entire Campus,\nIn Your Pocket',
            subtitle: 'Effortlessly manage attendance, grades, and communication in one premium platform.',
            illustration: _buildIllustration(Icons.auto_awesome),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: TextButton(
            onPressed: () => context.go('/login'),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                children: [
                  const TextSpan(text: 'Already have an account? '),
                  TextSpan(
                    text: 'Login',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us who you are',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'We will tailor your experience based on your role.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                final role = _roles[index];
                final isSelected = _selectedRole == role;
                return _buildSelectionCard(
                  title: role,
                  icon: _getRoleIcon(role),
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedRole = role),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInputPage() {
    final roleText = _selectedRole?.toLowerCase() ?? 'user';
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your name?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'This is how other ${roleText}s will see you on Unisphere.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 48),
          _buildTextField(
            controller: _nameController,
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPage() {
    final idLabel = _selectedRole == 'Parent' ? 'Child\'s Student ID' : 'Campus / Employee ID';
    return Scrollbar(
      thumbVisibility: true,
      thickness: 6,
      radius: const Radius.circular(8),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 80.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'One last thing...',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Provide your academic details to link your account.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Text(
              idLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _idController,
              hint: 'e.g. UN-2024-001',
              icon: Icons.badge_outlined,
            ),
            if (_selectedRole != 'Parent') ...[
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Department',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Row(
                    children: [
                      Icon(Icons.swap_vert, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Scroll for more (${_departments.length})',
                        style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _departments.map((dept) {
                  final isSelected = _selectedDept == dept;
                  return ChoiceChip(
                    label: Text(dept),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedDept = val ? dept : null),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinalPage() {
    final name = _nameController.text.trim().split(' ').first;
    return _buildPageLayout(
      title: 'Welcome aboard, $name! 🚀',
      subtitle: 'Your workspace is being prepared. Get ready to experience UNISPHERE.',
      illustration: _buildIllustration(Icons.celebration, color: Colors.orange),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }

  Widget _buildPageLayout({
    required String title,
    required String subtitle,
    required Widget illustration,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          illustration,
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(IconData icon, {Color? color}) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 40,
            top: 40,
            child: Icon(Icons.circle, color: (color ?? AppColors.primary).withValues(alpha: 0.2), size: 24),
          ),
          Positioned(
            left: 60,
            bottom: 40,
            child: Icon(Icons.circle, color: (color ?? AppColors.primary).withValues(alpha: 0.1), size: 16),
          ),
          Icon(
            icon,
            size: 100,
            color: color ?? AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Student':
        return Icons.school_outlined;
      case 'Faculty':
        return Icons.psychology_outlined;
      case 'Parent':
        return Icons.family_restroom_outlined;
      default:
        return Icons.person_outline;
    }
  }
}
