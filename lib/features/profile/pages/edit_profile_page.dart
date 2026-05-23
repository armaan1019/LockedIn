import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/profile_repository.dart';
import '../../../core/services/session_manager.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  int selectedWeight = 170;
  int selectedFeet = 5;
  int selectedInches = 10;
  final bioController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileRepo = context.read<ProfileRepository?>();
    final session = context.read<SessionManager>();
    final user = session.currentUser;
    final newUsername = usernameController.text.trim();

    if (profileRepo == null || user == null) return;

    try {
      await profileRepo.updateUsername(
        oldUsername: user.username,
        newUsername: newUsername,
        email: user.email,
      );

      final updatedUser = user.copyWith(
        username: newUsername,
        weight: selectedWeight,
        feet: selectedFeet,
        inches: selectedInches,
        bio: bioController.text.trim(),
      );

      await profileRepo.updateProfile(updatedUser);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: selectedWeight.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  border: OutlineInputBorder(),
                  suffixText: 'lbs',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your weight';
                  }
                  return null;
                },
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    selectedWeight = parsed;
                  }
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: selectedFeet,

                      decoration: const InputDecoration(
                        labelText: 'Feet',
                        border: OutlineInputBorder(),
                      ),

                      items: List.generate(5, (index) {
                        final feet = index + 4;

                        return DropdownMenuItem(
                          value: feet,
                          child: Text('$feet ft'),
                        );
                      }),

                      onChanged: (value) {
                        setState(() {
                          selectedFeet = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: selectedInches,

                      decoration: const InputDecoration(
                        labelText: 'Inches',
                        border: OutlineInputBorder(),
                      ),

                      items: List.generate(12, (index) {
                        final inches = index;

                        return DropdownMenuItem(
                          value: inches,
                          child: Text('$inches in'),
                        );
                      }),

                      onChanged: (value) {
                        setState(() {
                          selectedInches = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: bioController,
                maxLines: 3,

                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              FilledButton(onPressed: _saveProfile, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
