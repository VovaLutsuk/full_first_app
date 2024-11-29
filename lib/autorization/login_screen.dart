import 'package:flutter/material.dart';
import '/database.dart';

class LoginScreen extends StatefulWidget {
  final Function(int) onLogin; // Додано onLogin

  LoginScreen({required this.onLogin});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final user = await DatabaseHelper.getUserByEmail(email);

    if (user == null) {
      // Якщо користувач не знайдений
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Користувача з такою електронною поштою не існує')),
      );
      return;
    }

    if (user['password'] == password) {
      widget.onLogin(user['id']); // Викликаємо onLogin

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Вхід успішний!')),
      );

      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: user['id'],
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Неправильний email або пароль')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вхід')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Електронна пошта'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('Увійти'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: Text('Зареєструватися'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/password_recovery');
              },
              child: Text('Відновити пароль'),
            ),
          ],
        ),
      ),
    );
  }
}
