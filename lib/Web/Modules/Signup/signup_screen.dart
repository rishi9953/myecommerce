import 'package:flutter/material.dart';
import 'package:myecommerce/Web/service/Firebase/firebase_auth.dart';
import 'package:myecommerce/Web/service/responsive_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signUpWithEmailPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        // Navigate to home screen after successful sign up
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ResponsiveBuilder(
        builder: (context, deviceType) {
          if (deviceType == DeviceType.mobile ||
              deviceType == DeviceType.tablet) {
            return _buildMobileLayout(context, deviceType);
          } else {
            return _buildDesktopLayout(context, deviceType);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DeviceType deviceType) {
    return Center(
      child: SingleChildScrollView(
        padding: ResponsiveService.getResponsivePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: double.infinity,
              tablet: 500.0,
            ),
          ),
          child: _buildSignUpForm(context, deviceType),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DeviceType deviceType) {
    return Row(
      children: [
        Expanded(
          flex: ResponsiveService.getResponsiveValue(
            context: context,
            mobile: 1,
            desktop: 5,
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveService.getResponsiveValue(
                  context: context,
                  mobile: 20.0,
                  desktop: 40.0,
                  largeDesktop: 80.0,
                ),
                vertical: 40.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: _buildSignUpForm(context, deviceType),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            color: const Color(0xFFFFF0EB),
            child: Center(child: _buildIllustration(context, deviceType)),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm(BuildContext context, DeviceType deviceType) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Logo Here',
            style: TextStyle(
              fontSize: ResponsiveService.getResponsiveFontSize(
                context,
                baseFontSize: 32.0,
              ),
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF7961),
            ),
          ),
          SizedBox(
            height: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: 40.0,
              tablet: 50.0,
              desktop: 60.0,
            ),
          ),

          Text(
            'Create an account',
            style: TextStyle(
              fontSize: ResponsiveService.getResponsiveFontSize(
                context,
                baseFontSize: 14.0,
              ),
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Sign up',
            style: TextStyle(
              fontSize: ResponsiveService.getResponsiveFontSize(
                context,
                baseFontSize: 42.0,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(
            height: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: 30.0,
              desktop: 40.0,
            ),
          ),

          // Name field
          Text(
            'Full Name',
            style: TextStyle(
              fontSize: ResponsiveService.getResponsiveFontSize(
                context,
                baseFontSize: 14.0,
              ),
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              filled: true,
              fillColor: const Color(0xFFFFF5F3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveService.getResponsiveValue(
                  context: context,
                  mobile: 14.0,
                  desktop: 16.0,
                ),
                vertical: 14.0,
              ),
            ),
          ),
          SizedBox(
            height: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: 20.0,
              desktop: 24.0,
            ),
          ),

          // Email field
          Text(
            'Email',
            style: TextStyle(
              fontSize: ResponsiveService.getResponsiveFontSize(
                context,
                baseFontSize: 14.0,
              ),
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter your email',
              filled: true,
              fillColor: const Color(0xFFFFF5F3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveService.getResponsiveValue(
                  context: context,
                  mobile: 14.0,
                  desktop: 16.0,
                ),
                vertical: 14.0,
              ),
            ),
          ),
          SizedBox(
            height: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: 20.0,
              desktop: 24.0,
            ),
          ),

          // Password field
          Text(
            'Password',
            style: TextStyle(
              fontSize: ResponsiveService.getResponsiveFontSize(
                context,
                baseFontSize: 14.0,
              ),
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: '••••••••••••',
              filled: true,
              fillColor: const Color(0xFFFFF5F3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveService.getResponsiveValue(
                  context: context,
                  mobile: 14.0,
                  desktop: 16.0,
                ),
                vertical: 14.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),
          SizedBox(
            height: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: 20.0,
              desktop: 24.0,
            ),
          ),

          // Confirm Password field
          Text(
            'Confirm Password',
            style: TextStyle(
              fontSize: ResponsiveService.getResponsiveFontSize(
                context,
                baseFontSize: 14.0,
              ),
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: '••••••••••••',
              filled: true,
              fillColor: const Color(0xFFFFF5F3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveService.getResponsiveValue(
                  context: context,
                  mobile: 14.0,
                  desktop: 16.0,
                ),
                vertical: 14.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: 30.0,
              desktop: 40.0,
            ),
          ),

          // Sign up button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7961),
                disabledBackgroundColor: const Color(
                  0xFFFF7961,
                ).withOpacity(0.6),
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveService.getResponsiveValue(
                    context: context,
                    mobile: 14.0,
                    desktop: 16.0,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: ResponsiveService.getResponsiveFontSize(
                              context,
                              baseFontSize: 14.0,
                            ),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),
          SizedBox(
            height: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: 20.0,
              desktop: 24.0,
            ),
          ),

          // Sign in link
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Already have an account ?',
                  style: TextStyle(
                    fontSize: ResponsiveService.getResponsiveFontSize(
                      context,
                      baseFontSize: 13.0,
                    ),
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 4),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: ResponsiveService.getResponsiveFontSize(
                        context,
                        baseFontSize: 13.0,
                      ),
                      color: const Color(0xFFFF7961),
                      fontWeight: FontWeight.w600,
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

  Widget _buildIllustration(BuildContext context, DeviceType deviceType) {
    final illustrationHeight = ResponsiveService.getResponsiveValue(
      context: context,
      mobile: 300.0,
      tablet: 350.0,
      desktop: 400.0,
      largeDesktop: 450.0,
    );

    return Image.asset(
      'assets/shopping_illustration.png',
      height: illustrationHeight,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: illustrationHeight * 0.3,
              color: const Color(0xFFFF7961).withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Shopping Illustration',
              style: TextStyle(
                fontSize: ResponsiveService.getResponsiveFontSize(
                  context,
                  baseFontSize: 18.0,
                ),
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      },
    );
  }
}
