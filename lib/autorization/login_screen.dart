import 'package:flutter/material.dart';
import '/database.dart';

class LoginScreen extends StatefulWidget {
  final Function(int) onLogin;

  LoginScreen({required this.onLogin});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deleteEmailController = TextEditingController();
  final _resetEmailController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final user = await DatabaseHelper.getUserByEmail(email);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Користувача з такою електронною поштою не існує')),
      );
      return;
    }

    if (user['password'] == password) {
      widget.onLogin(user['id']);

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

  Future<void> _deleteAccount() async {
    final email = _deleteEmailController.text;

    final user = await DatabaseHelper.getUserByEmail(email);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Користувача з такою електронною поштою не існує')),
      );
      return;
    }

    await DatabaseHelper.deleteUserByEmail(email);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Акаунт успішно видалено')),
    );

    Navigator.pop(context);
  }

  Future<void> _resetPassword() async {
    final email = _resetEmailController.text;

    final user = await DatabaseHelper.getUserByEmail(email);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Користувача з такою електронною поштою не існує')),
      );
      return;
    }

    const newPassword = '123123';
    await DatabaseHelper.updatePassword(user['id'], newPassword);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Пароль відновлено. Новий пароль: $newPassword')),
    );

    Navigator.pop(context);
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Відновити пароль'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _resetEmailController,
                            decoration: InputDecoration(labelText: 'Електронна пошта'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Скасувати'),
                        ),
                        ElevatedButton(
                          onPressed: _resetPassword,
                          child: Text('Відновити'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Відновити пароль'),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Видалити акаунт'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _deleteEmailController,
                            decoration: InputDecoration(labelText: 'Електронна пошта'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Скасувати'),
                        ),
                        ElevatedButton(
                          onPressed: _deleteAccount,
                          child: Text('Видалити'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Видалити акаунт'),
            ),
          ],
        ),
      ),
    );
  }
}
