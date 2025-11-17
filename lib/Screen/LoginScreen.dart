import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:stock_massas/controller/authController.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final AuthController _auth = Get.put(AuthController());
  bool _obscure = true;
  bool isSignUp = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'informe o email';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
    if (!ok) return 'email inválido';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'informe a senha';
    if (value.length < 6) return 'senha muito curta';
    return null;
  }

  String? _validateName(String? v) {
    if (!isSignUp) return null;
    final value = v?.trim() ?? '';
    if (value.length < 2) return 'Informe seu nome';
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();

    if (isSignUp) {
      await _auth.registerEmail(_emailCtrl.text.trim(), _passCtrl.text);
    } else {
      await _auth.loginEmail(_emailCtrl.text.trim(), _passCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.green[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Card(
                elevation: 8,
                margin: EdgeInsets.symmetric(horizontal: w < 450 ? 8 : 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: Colors.green.shade700, width: 0.8),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 40,
                  ),
                  child: Obx(
                    () => Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isSignUp ? 'criar nova conta' : 'entrar',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.green.shade700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isSignUp
                                ? 'preencha seus dados'
                                : 'Acesse sua conta',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 32),

                          if (_auth.errorMessage.value != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.red.shade300,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red.shade700,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _auth.errorMessage.value!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (isSignUp) ...[
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(
                                labelText: 'Nome completo',
                                hintText: 'Seu nome',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: Colors.green.shade700,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.green.shade400,
                                    width: 2,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.green.shade700,
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.green.shade300,
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: _validateName,
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextFormField(
                            controller: _emailCtrl,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'seuemail@email.com',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.green.shade700,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.green.shade200,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.green.shade400,
                                  width: 2,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.green.shade700,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.green.shade300,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'senha',
                              hintText: 'Mínimo 6 caracteres',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.green.shade700,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.green.shade700,
                                ),
                                tooltip: _obscure
                                    ? 'mostrar senha'
                                    : 'ocultar senha',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.green.shade200,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.green.shade400,
                                  width: 2,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.green.shade700,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.green.shade300,
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _auth.isLoading.value ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green.shade700, //cor do botao
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                foregroundColor: Colors.white, //cor do texto
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'montserrat',
                                ),
                              ),
                              child: _auth.isLoading.value
                                  ? SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(isSignUp ? 'Criar Conta' : 'Entrar'),
                            ),
                          ),
                          const SizedBox(height: 20),

                          TextButton(
                            onPressed: _auth.isLoading.value
                                ? null
                                : () => setState(() => isSignUp = !isSignUp),
                            child: Text(
                              isSignUp
                                  ? 'já possui uma conta? entre'
                                  : 'não possui conta? crie uma',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1.2,
                                  color: Colors.green.shade200,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  "ou via",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1.2,
                                  color: Colors.green.shade200,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton.icon(
                              onPressed: _auth.isLoading.value
                                  ? null
                                  : _auth.loginGoogle,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.green.shade700,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'montserrat',
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              icon: SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.asset(
                                  'assets/pngoogle.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.account_circle,
                                        size: 24,
                                      ),
                                ),
                              ),
                              label: const Text('entrar com Google'),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
