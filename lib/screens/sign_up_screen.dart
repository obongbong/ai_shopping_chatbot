import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _userType = '일반';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _passwordMessage = '';
  final Color _textColor = Colors.white;
  final Color _hintColor = Colors.white70;

  final _passwordReg = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]{6,}$');

  void _validatePasswords() {
    final pw = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (pw.isEmpty || confirm.isEmpty) {
      setState(() => _passwordMessage = '');
    } else if (pw != confirm) {
      setState(() => _passwordMessage = '비밀번호가 일치하지 않습니다.');
    } else {
      setState(() => _passwordMessage = '비밀번호가 일치합니다!');
    }
  }

  bool _validatePasswordFormat(String password) {
    return _passwordReg.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.04),
                Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 28,
                    color: _textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),

                _customTextField(
                  icon: Icons.person,
                  hint: '이름',
                  controller: _nameController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[가-힣ㄱ-ㅎㅏ-ㅣ\s]')),
                  ],
                ),
                SizedBox(height: screenHeight * 0.025),

                _customTextField(
                  icon: Icons.email,
                  hint: '이메일',
                  controller: _emailController,
                ),
                SizedBox(height: screenHeight * 0.025),

                _customTextField(
                  icon: Icons.lock,
                  hint: '비밀번호',
                  obscureText: true,
                  controller: _passwordController,
                  onChanged: (_) => _validatePasswords(),
                ),
                SizedBox(height: screenHeight * 0.025),

                _customTextField(
                  icon: Icons.lock_outline,
                  hint: '비밀번호 확인',
                  obscureText: true,
                  controller: _confirmPasswordController,
                  onChanged: (_) => _validatePasswords(),
                ),
                if (_passwordMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _passwordMessage,
                      style: TextStyle(
                        color:
                            _passwordMessage.contains('일치합니다')
                                ? Colors.greenAccent
                                : Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                SizedBox(height: screenHeight * 0.03),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '사용자 유형',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text(
                          '일반',
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: '일반',
                        groupValue: _userType,
                        activeColor: Colors.deepPurpleAccent,
                        onChanged:
                            (value) => setState(() => _userType = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text(
                          '저시력자',
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: '저시력자',
                        groupValue: _userType,
                        activeColor: Colors.deepPurpleAccent,
                        onChanged:
                            (value) => setState(() => _userType = value!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),

                ElevatedButton(
                  onPressed: () async {
                    final pwValid = _validatePasswordFormat(
                      _passwordController.text,
                    );
                    final pwMatch =
                        _passwordController.text ==
                        _confirmPasswordController.text;

                    if (!pwValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('비밀번호는 영문과 숫자를 포함하여 6자 이상이어야 합니다.'),
                        ),
                      );
                      return;
                    }

                    if (!pwMatch) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                      );
                      return;
                    }

                    // 🔥 회원가입 HTTP 요청 추가
                    final uri = Uri.parse('http://10.0.2.2:5000/signup');
                    final response = await http.post(
                      uri,
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'username': _nameController.text.trim(),
                        'email': _emailController.text.trim(),
                        'password': _passwordController.text,
                        'user_type': _userType,
                      }),
                    );

                    if (response.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('회원가입 성공! 로그인 화면으로 이동합니다.'),
                        ),
                      );
                      Navigator.pop(context); // 로그인 화면으로 돌아가기
                    } else {
                      try {
                        final decoded = jsonDecode(response.body);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(decoded['error'] ?? '회원가입 실패'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('서버 오류가 발생했습니다.')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.25,
                      vertical: screenHeight * 0.018,
                    ),
                  ),
                  child: const Text(
                    '가입하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required IconData icon,
    required String hint,
    bool obscureText = false,
    TextEditingController? controller,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: _textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      inputFormatters: inputFormatters ?? [], // 🔥 핵심 수정
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _textColor),
        hintText: hint,
        hintStyle: TextStyle(
          color: _hintColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
