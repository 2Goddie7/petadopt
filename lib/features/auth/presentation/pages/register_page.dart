import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../features/auth/domain/entities/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  UserType _selectedUserType = UserType.adopter;
  bool _showLocationFields = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // Parsear latitud y longitud si están presentes
      double? latitude;
      double? longitude;
      
      if (_latitudeController.text.trim().isNotEmpty) {
        latitude = double.tryParse(_latitudeController.text.trim());
      }
      
      if (_longitudeController.text.trim().isNotEmpty) {
        longitude = double.tryParse(_longitudeController.text.trim());
      }
      
      context.read<AuthBloc>().add(
            SignUpEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _fullNameController.text.trim(),
              userType: _selectedUserType,
              phone: _phoneController.text.trim().isEmpty 
                  ? null 
                  : _phoneController.text.trim(),
              latitude: latitude,
              longitude: longitude,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is Authenticated) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Únete a PetAdopt',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu cuenta para adoptar o ayudar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Tipo de usuario
                    Text(
                      'Tipo de cuenta',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _UserTypeCard(
                            icon: Icons.person,
                            title: 'Adoptante',
                            subtitle: 'Quiero adoptar',
                            isSelected: _selectedUserType == UserType.adopter,
                            onTap: () {
                              setState(() {
                                _selectedUserType = UserType.adopter;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _UserTypeCard(
                            icon: Icons.home,
                            title: 'Refugio',
                            subtitle: 'Soy un refugio',
                            isSelected: _selectedUserType == UserType.shelter,
                            onTap: () {
                              setState(() {
                                _selectedUserType = UserType.shelter;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Nombre completo
                    CustomTextField(
                      label: 'Nombre completo',
                      hint: 'Juan Pérez',
                      controller: _fullNameController,
                      prefixIcon: Icons.person_outline,
                      validator: Validators.name,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Email
                    CustomTextField(
                      label: 'Email',
                      hint: 'tu@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.email,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Teléfono (opcional)
                    CustomTextField(
                      label: 'Teléfono (opcional)',
                      hint: '0987654321',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return Validators.phone(value);
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Toggle para ubicación (solo para refugios)
                    if (_selectedUserType == UserType.shelter)
                      CheckboxListTile(
                        title: const Text('Agregar ubicación personalizada'),
                        subtitle: const Text('Por defecto: Escuela Politécnica Nacional'),
                        value: _showLocationFields,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _showLocationFields = value ?? false;
                                  if (!_showLocationFields) {
                                    _latitudeController.clear();
                                    _longitudeController.clear();
                                  }
                                });
                              },
                        contentPadding: EdgeInsets.zero,
                      ),
                    
                    // Campos de ubicación (solo si está activado)
                    if (_showLocationFields && _selectedUserType == UserType.shelter) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Latitud',
                              hint: '-0.180653',
                              controller: _latitudeController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              prefixIcon: Icons.my_location,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final lat = double.tryParse(value);
                                  if (lat == null) {
                                    return 'Latitud inválida';
                                  }
                                  if (lat < -90 || lat > 90) {
                                    return 'Debe estar entre -90 y 90';
                                  }
                                }
                                return null;
                              },
                              enabled: !isLoading,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'Longitud',
                              hint: '-78.467834',
                              controller: _longitudeController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              prefixIcon: Icons.location_on,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final lng = double.tryParse(value);
                                  if (lng == null) {
                                    return 'Longitud inválida';
                                  }
                                  if (lng < -180 || lng > 180) {
                                    return 'Debe estar entre -180 y 180';
                                  }
                                }
                                return null;
                              },
                              enabled: !isLoading,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    
                    // Contraseña
                    CustomTextField(
                      label: 'Contraseña',
                      hint: '••••••••',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      validator: Validators.password,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Confirmar contraseña
                    CustomTextField(
                      label: 'Confirmar contraseña',
                      hint: '••••••••',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (value) {
                        return Validators.confirmPassword(
                          value,
                          _passwordController.text,
                        );
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),
                    
                    // Botón de registro
                    CustomButton(
                      text: 'Crear Cuenta',
                      onPressed: _handleRegister,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Link a login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                },
                          child: const Text('Inicia Sesión'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[800],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}