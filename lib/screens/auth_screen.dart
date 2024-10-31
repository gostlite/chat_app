import 'dart:io';

import 'package:chat_app/screens/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  final _key = GlobalKey<FormState>();
  var _email = "";
  var _password = '';
  File? _selectedImage;
  var _username = '';
  var _isAuthenticating = false;

  void _submit() async {
    final isValid = _key.currentState!.validate();
    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }

    _key.currentState!.save();
    setState(() {
      _isAuthenticating = true;
    });
    try {
      if (!_isLogin) {
        final userCredential = await firebase.createUserWithEmailAndPassword(
            email: _email, password: _password);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_image")
            .child("${userCredential.user!.uid}.png");

        await storageRef.putFile(_selectedImage!);
        final downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          "username": _username,
          "email": _email,
          "image_url": downloadUrl
        });
        print(downloadUrl);
      } else {
        final userCredential = await firebase.signInWithEmailAndPassword(
            email: _email, password: _password);
        print(userCredential);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-already-in-use") {
        if (!context.mounted) {
          return;
        }
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Authentication failed"),
          duration: const Duration(seconds: 1),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login view"),
      ),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, right: 20, left: 20),
                child: Image.asset(
                  "assets/images/chat.png",
                  width: 200,
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _key,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(selectImage: (image) {
                              _selectedImage = image;
                            }),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text("Email address"),
                            ),
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@")) {
                                return "Kindly check your email";
                              }
                              return null;
                            },
                            onSaved: (newVal) {
                              _email = newVal!;
                              print(_email);
                            },
                          ),
                          TextFormField(
                              decoration: const InputDecoration(
                                label: Text("Password"),
                              ),
                              obscureText: true,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length < 6) {
                                  return "Kindly check your password";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _password = newValue!;
                                print(_password);
                              }),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text("Username"),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 4) {
                                  return "Check your username";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _username = newValue!;
                              },
                            ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isAuthenticating)
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              child: Text(
                                _isLogin ? "Login" : "Sign up",
                              ),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? "create an account"
                                    : "I already have an account"))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
