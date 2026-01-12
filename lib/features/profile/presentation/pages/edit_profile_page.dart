import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../core/utils/location_helper.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes; // Cache para bytes de la imagen
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _locationController =
        TextEditingController(text: widget.profile.location ?? '');
    _latitudeController = TextEditingController(
        text: widget.profile.latitude != null
            ? widget.profile.latitude!.toStringAsFixed(6)
            : '');
    _longitudeController = TextEditingController(
        text: widget.profile.longitude != null
            ? widget.profile.longitude!.toStringAsFixed(6)
            : '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        // Pre-cargar los bytes en caché
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final position = await LocationHelper.getCurrentLocation();

      if (position != null) {
        setState(() {
          _latitudeController.text = position.latitude.toStringAsFixed(6);
          _longitudeController.text = position.longitude.toStringAsFixed(6);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Ubicación obtenida correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener la ubicación'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Upload image first if selected
      if (_selectedImage != null) {
        context.read<ProfileBloc>().add(
              UploadProfileImageEvent(
                imageFile: _selectedImage!,
              ),
            );
      }

      // Parsear coordenadas si están presentes (solo para shelters)
      double? latitude;
      double? longitude;

      if (_latitudeController.text.trim().isNotEmpty) {
        latitude = double.tryParse(_latitudeController.text.trim());
      }

      if (_longitudeController.text.trim().isNotEmpty) {
        longitude = double.tryParse(_longitudeController.text.trim());
      }

      // Update profile
      context.read<ProfileBloc>().add(
            UpdateProfileEvent(
              fullName: _fullNameController.text.trim(),
              phone: _phoneController.text.trim(),
              bio: _bioController.text.trim().isEmpty
                  ? null
                  : _bioController.text.trim(),
              location: _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
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
        title: const Text('Editar Perfil'),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileUpdating;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Image
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _selectedImageBytes != null
                                  ? MemoryImage(_selectedImageBytes!)
                                      as ImageProvider
                                  : widget.profile.avatarUrl != null
                                      ? CachedNetworkImageProvider(
                                              widget.profile.avatarUrl!)
                                          as ImageProvider
                                      : null,
                              child: _selectedImageBytes == null &&
                                      widget.profile.avatarUrl == null
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt,
                                      size: 20, color: Colors.white),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Full Name
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre Completo *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, ingresa tu teléfono';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Ubicación',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'Ciudad, País',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Geolocalización solo para refugios
                      if (widget.profile.userType == UserType.shelter) ...[
                        Card(
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.place,
                                        color: Colors.orange.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ubicación en mapa',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Actualiza tu ubicación para que las personas puedan encontrar tu refugio en el mapa.',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _latitudeController,
                                        decoration: InputDecoration(
                                          labelText: 'Latitud',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          prefixIcon: Icon(Icons.place,
                                              color: Colors.grey.shade600),
                                          isDense: true,
                                        ),
                                        style: TextStyle(
                                            color: Colors.grey.shade700),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        readOnly: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _longitudeController,
                                        decoration: InputDecoration(
                                          labelText: 'Longitud',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          prefixIcon: Icon(Icons.explore,
                                              color: Colors.grey.shade600),
                                          isDense: true,
                                        ),
                                        style: TextStyle(
                                            color: Colors.grey.shade700),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        readOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoadingLocation
                                        ? null
                                        : _getCurrentLocation,
                                    icon: _isLoadingLocation
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Icon(Icons.my_location),
                                    label: Text(
                                      _isLoadingLocation
                                          ? 'Obteniendo ubicación...'
                                          : 'Obtener ubicación GPS',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Bio
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Biografía',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info),
                          hintText: 'Cuéntanos sobre ti...',
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            isLoading ? 'Guardando...' : 'Guardar Cambios',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
