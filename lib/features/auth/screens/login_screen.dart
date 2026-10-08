import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../services/auth_service.dart';
import '../../onboarding/screens/setup_profile_screen.dart';
import '../../dashboard/screens/main_dashboard.dart';
import '../../../core/theme/app_colors.dart';
import 'splash_screen.dart'; // BlueprintGridPainter access karne ke liye

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true; 
  bool obscurePassword = true;        
  bool obscureConfirmPassword = true; 
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // 🧠 HARDWARE KEYBOARD FOCUS NODES
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passFocus = FocusNode();
  final FocusNode confirmFocus = FocusNode();
  
  final AuthService authService = AuthService();
  bool isLoading = false;

  void handleAuthAction(Future<User?> authMethod) async {
    setState(() => isLoading = true);
    final user = await authMethod;

    if (user != null && mounted) {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      if (!mounted) return;
      setState(() => isLoading = false);

      if (docSnapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SetupProfileScreen()),
        );
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  void submitForm() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ERR: INCOMPLETE DATA MATRIX'), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    if (isLogin) {
      handleAuthAction(authService.signInWithEmail(email, password, context));
    } else {
      if (password != confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ERR: CRYPTO_KEY MISMATCH'), backgroundColor: AppColors.errorRed),
        );
        return;
      }
      handleAuthAction(authService.signUpWithEmail(name, email, password, context));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    
    // Clean up focus nodes from memory pipeline
    nameFocus.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomPaint(
        painter: BlueprintGridPainter(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.fingerprint_rounded, size: 64, color: AppColors.primaryBlue),
                  const SizedBox(height: 24),
                  Text(
                    isLogin ? 'SECURE ACCESS PORTAL' : 'INITIALIZE REGISTRATION',
                    style: const TextStyle(
                      fontFamily: 'monospace', 
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1.2, 
                      color: AppColors.textPrimary
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLogin ? '// ENTER CREDENTIALS TO LOAD CORE' : '// DEPLOY NEW STUDENT IDENTITY PROFILE',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // 1. NAME NODE (Signup context only)
                  if (!isLogin) ...[
                    _buildTechInputField(
                      controller: nameController,
                      focusNode: nameFocus,
                      label: 'AGENT_FULL_NAME',
                      icon: Icons.person_outline,
                      isObscure: false,
                      inputAction: TextInputAction.next,
                      onSubmitted: (_) => emailFocus.requestFocus(), // Shifts directly down
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 2. EMAIL NODE
                  _buildTechInputField(
                    controller: emailController,
                    focusNode: emailFocus,
                    label: 'CORE_EMAIL_ADDRESS',
                    icon: Icons.alternate_email_rounded,
                    isObscure: false,
                    inputType: TextInputType.emailAddress,
                    inputAction: TextInputAction.next,
                    onSubmitted: (_) => passFocus.requestFocus(), // Shifts down to pass node
                  ),
                  const SizedBox(height: 16),
                  
                  // 3. PASSWORD NODE
                  _buildTechInputField(
                    controller: passwordController,
                    focusNode: passFocus,
                    label: 'ENCRYPTED_PASSWORD',
                    icon: Icons.lock_outline,
                    isObscure: obscurePassword,
                    inputAction: isLogin ? TextInputAction.done : TextInputAction.next,
                    onSubmitted: (_) {
                      if (isLogin) {
                        submitForm(); // Executes authentication vectors
                      } else {
                        confirmFocus.requestFocus(); // Jumps to confirmation field node
                      }
                    },
                    onToggleVisibility: () => setState(() => obscurePassword = !obscurePassword),
                  ),
                  
                  // 4. CONFIRM PASSWORD NODE
                  if (!isLogin) ...[
                    const SizedBox(height: 16),
                    _buildTechInputField(
                      controller: confirmPasswordController,
                      focusNode: confirmFocus,
                      label: 'CONFIRM_PASS_KEY',
                      icon: Icons.lock_reset_rounded,
                      isObscure: obscureConfirmPassword,
                      inputAction: TextInputAction.done,
                      onSubmitted: (_) => submitForm(), // Executes compilation process
                      onToggleVisibility: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                    ),
                  ],
                  
                  const SizedBox(height: 28),
                  
                  // Action Button
                  GestureDetector(
                    onTap: isLoading ? null : submitForm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary, 
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withValues(alpha: 0.15), 
                            blurRadius: 15, 
                            offset: const Offset(0, 5)
                          )
                        ],
                      ),
                      child: Center(
                        child: isLoading 
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 2)),
                                  SizedBox(width: 12),
                                  Text("DECRYPTING...", style: TextStyle(fontFamily: 'monospace', color: AppColors.surface, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                ],
                              )
                            : Text(
                                isLogin ? 'AUTHENTICATE' : 'GENERATE_CORE_KEY', 
                                style: const TextStyle(fontFamily: 'monospace', color: AppColors.surface, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                              ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        nameController.clear();
                        emailController.clear();
                        passwordController.clear();
                        confirmPasswordController.clear();
                      });
                    },
                    child: Text(
                      isLogin ? "[ REQUEST_NEW_ACCESS ]" : "[ EXISTING_ACCESS_PORTAL ]",
                      style: const TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('// EXTERNAL PROTOCOLS', style: TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontSize: 11)),
                      ),
                      Expanded(child: Divider(color: AppColors.divider)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(Icons.g_mobiledata, () {
                        handleAuthAction(authService.signInWithGoogle(context));
                      }),
                      const SizedBox(width: 24),
                      _buildSocialButton(Icons.terminal, () { 
                        handleAuthAction(authService.signInWithGitHub(context));
                      }),
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

  Widget _buildTechInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required bool isObscure,
    required TextInputAction inputAction,
    TextInputType inputType = TextInputType.text,
    Function(String)? onSubmitted,
    VoidCallback? onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode, // Attaches operational vector nodes safely
      obscureText: isObscure,
      keyboardType: inputType,
      textInputAction: inputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontFamily: 'monospace', color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontSize: 13, letterSpacing: 0.5),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 22),
        suffixIcon: onToggleVisibility != null 
            ? IconButton(
                icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
                onPressed: onToggleVisibility,
              ) 
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.15))
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 32, color: AppColors.textPrimary),
      ),
    );
  }
}