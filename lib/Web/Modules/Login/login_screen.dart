import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myecommerce/Web/service/Firebase/firebase_auth.dart';
import 'package:myecommerce/Web/service/firestore_storefront_service.dart';
import 'package:myecommerce/Web/service/responsive_service.dart';
import 'package:myecommerce/Web/service/route_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _usePhone = false;
  bool _otpSent = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Sign in user with email and password.
  ///
  /// Validate form and show loading indicator.
  /// Try to sign in user with email and password.
  /// If sign in is successful, navigate to home screen.
  /// If sign in fails, show error message using SnackBar.
  /*******  6c41b2c2-0e37-4cca-9b82-c880d6c35b58  *******/
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_usePhone) {
        if (!_otpSent) {
          await _authService.sendOtp(phoneNumber: _phoneController.text);
          if (!mounted) return;
          setState(() => _otpSent = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent')),
          );
        } else {
          final result = await _authService.verifyOtp(smsCode: _otpController.text);
          final user = result?.user;
          if (user != null) {
            await FirestoreStorefrontService().upsertUserProfile(
              uid: user.uid,
              email: user.email ?? '',
              name: '',
            );
          }
          if (mounted) context.go(Routes.home);
        }
      } else {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        final results = await _authService.signInWithEmailPassword(
          email: email,
          password: password,
        );

        final user = results?.user;
        if (user != null) {
          await FirestoreStorefrontService().upsertUserProfile(
            uid: user.uid,
            email: user.email ?? email,
            name: '',
          );
        }

        if (mounted) context.go(Routes.home);
      }
    } catch (e) {
      debugPrint('Sign in error: $e'); // Add this line
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

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final cred = await _authService.signInWithGoogle();
      final user = cred?.user;
      if (user != null) {
        await FirestoreStorefrontService().upsertUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
        );
      }
      if (mounted) context.go(Routes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
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
          child: _buildSignInForm(context, deviceType),
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
                child: _buildSignInForm(context, deviceType),
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

  Widget _buildSignInForm(BuildContext context, DeviceType deviceType) {
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
            'Welcome back !!!',
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
            'Sign in',
            style: TextStyle(
              fontSize: ResponsiveService.getResponsiveFontSize(
                context,
                baseFontSize: 42.0,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Email'),
                  selected: !_usePhone,
                  onSelected: (v) => setState(() {
                    _usePhone = false;
                    _otpSent = false;
                    _otpController.clear();
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Mobile (OTP)'),
                  selected: _usePhone,
                  onSelected: (v) => setState(() {
                    _usePhone = true;
                    _otpSent = false;
                    _otpController.clear();
                  }),
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: 30.0,
              desktop: 40.0,
            ),
          ),

          if (!_usePhone) ...[
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
                if (_usePhone) return null;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                TextButton(
                  onPressed: _forgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password ?',
                    style: TextStyle(
                      fontSize: ResponsiveService.getResponsiveFontSize(
                        context,
                        baseFontSize: 12.0,
                      ),
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: (value) {
                if (_usePhone) return null;
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
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
          ] else ...[
            Text(
              'Mobile Number',
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
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (!_usePhone) return null;
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your mobile number';
                }
                final cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
                if (!cleaned.startsWith('+')) {
                  return 'Include country code (example: +919876543210)';
                }
                if (!RegExp(r'^\+\d{8,15}$').hasMatch(cleaned)) {
                  return 'Invalid phone format';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'e.g. +919876543210',
                filled: true,
                fillColor: const Color(0xFFFFF5F3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_otpSent) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _isLoading = true);
                            try {
                              await _authService.sendOtp(
                                phoneNumber: _phoneController.text,
                              );
                              if (!mounted) return;
                              _otpController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('OTP resent')),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              setState(() => _otpSent = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                    child: const Text('Resend OTP'),
                  ),
                ],
              ),
              Text(
                'OTP',
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
                controller: _otpController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!_usePhone) return null;
                  if (!_otpSent) return null;
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter OTP';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Enter OTP',
                  filled: true,
                  fillColor: const Color(0xFFFFF5F3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ],
          SizedBox(
            height: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: 20.0,
              desktop: 24.0,
            ),
          ),

          SizedBox(
            height: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: 30.0,
              desktop: 40.0,
            ),
          ),

          // Sign in button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
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
                          _usePhone
                              ? (_otpSent ? 'VERIFY OTP' : 'SEND OTP')
                              : 'SIGN IN',
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

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Continue with Google'),
            ),
          ),

          // Sign up link
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "I don't have an account ?",
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
                    context.go(Routes.signUp);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 4),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Sign up',
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
