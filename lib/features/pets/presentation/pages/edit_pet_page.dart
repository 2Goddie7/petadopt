import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';
import '../../domain/entities/pet.dart';
import 'package:petadopt/features/pets/presentation/bloc/pet_form_bloc.dart';
import 'package:petadopt/features/pets/presentation/bloc/pet_form_event.dart';
import 'package:petadopt/features/pets/presentation/bloc/pet_form_state.dart';

class EditPetPage extends StatefulWidget {
  final Pet pet;
  
  const EditPetPage({super.key, required this.pet});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _breedController;
  late final TextEditingController _healthStatusController;
  
  late PetSpecies _selectedSpecies;
  late PetSize _selectedSize;
  late PetGender _selectedGender;
  late AdoptionStatus _selectedStatus;
  late int _ageYears;
  late int _ageMonths;
  
  final List<XFile> _newImages = [];
  final List<String> _imagesToDelete = [];
  final ImagePicker _picker = ImagePicker();
  
  late final PetFormBloc _petFormBloc;

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.pet.name);
    _descriptionController = TextEditingController(text: widget.pet.description);
    _breedController = TextEditingController(text: widget.pet.breed);
    _healthStatusController = TextEditingController(text: widget.pet.healthNotes ?? '');
    
    _selectedSpecies = widget.pet.species;
    _selectedSize = widget.pet.size;
    _selectedGender = widget.pet.gender;
    _selectedStatus = widget.pet.adoptionStatus;
    _ageYears = widget.pet.ageYears;
    _ageMonths = widget.pet.ageMonths;
    
    _petFormBloc = PetFormBloc(
      createPet: GetIt.instance(),
      updatePet: GetIt.instance(),
      uploadPetImages: GetIt.instance(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _breedController.dispose();
    _healthStatusController.dispose();
    _petFormBloc.close();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _newImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imágenes: $e')),
        );
      }
    }
  }

  void _removeExistingImage(String url) {
    setState(() {
      _imagesToDelete.add(url);
    });
  }

  void _restoreImage(String url) {
    setState(() {
      _imagesToDelete.remove(url);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final allCurrentUrls = [
        if (widget.pet.mainImageUrl.isNotEmpty) widget.pet.mainImageUrl,
        ...widget.pet.imagesUrls,
      ];
      
      final remainingImages = allCurrentUrls
          .where((url) => !_imagesToDelete.contains(url))
          .toList();
      
      if (remainingImages.isEmpty && _newImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La mascota debe tener al menos una imagen'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final updatedPet = widget.pet.copyWith(
        name: _nameController.text.trim(),
        species: _selectedSpecies,
        breed: _breedController.text.trim().isEmpty 
            ? 'Desconocida' 
            : _breedController.text.trim(),
        ageYears: _ageYears,
        ageMonths: _ageMonths,
        gender: _selectedGender,
        size: _selectedSize,
        description: _descriptionController.text.trim(),
        healthNotes: _healthStatusController.text.trim().isEmpty
            ? null
            : _healthStatusController.text.trim(),
        adoptionStatus: _selectedStatus,
        updatedAt: DateTime.now(),
      );

      _petFormBloc.add(UpdatePetEvent(
        pet: updatedPet,
        newImages: _newImages.isNotEmpty ? _newImages : null,
        deleteImageUrls: _imagesToDelete.isNotEmpty ? _imagesToDelete : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _petFormBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Mascota'),
        ),
        body: BlocConsumer<PetFormBloc, PetFormState>(
          listener: (context, state) {
            if (state is PetFormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop(true);
            } else if (state is PetFormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is PetFormUploading) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.message} ${(state.progress * 100).toInt()}%'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is PetFormLoading || state is PetFormUploading;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Images Section
                        const Text(
                          'Fotos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildImageEditor(),
                        const SizedBox(height: 24),

                        // Basic Info
                        const Text(
                          'Información Básica',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.pets),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, ingresa el nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<PetSpecies>(
                          value: _selectedSpecies,
                          decoration: const InputDecoration(
                            labelText: 'Especie *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: PetSpecies.values.map((species) {
                            return DropdownMenuItem(
                              value: species,
                              child: Text(species.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedSpecies = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _breedController,
                          decoration: const InputDecoration(
                            labelText: 'Raza (opcional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.label),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _ageYears,
                                decoration: const InputDecoration(
                                  labelText: 'Años',
                                  border: OutlineInputBorder(),
                                ),
                                items: List.generate(20, (index) => index)
                                    .map((age) => DropdownMenuItem(
                                          value: age,
                                          child: Text('$age años'),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _ageYears = value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _ageMonths,
                                decoration: const InputDecoration(
                                  labelText: 'Meses',
                                  border: OutlineInputBorder(),
                                ),
                                items: List.generate(12, (index) => index)
                                    .map((months) => DropdownMenuItem(
                                          value: months,
                                          child: Text('$months meses'),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _ageMonths = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<PetSize>(
                          value: _selectedSize,
                          decoration: const InputDecoration(
                            labelText: 'Tamaño *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.straighten),
                          ),
                          items: PetSize.values.map((size) {
                            return DropdownMenuItem(
                              value: size,
                              child: Text(size.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedSize = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<PetGender>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Género *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.male),
                          ),
                          items: PetGender.values.map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedGender = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<AdoptionStatus>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Estado de Adopción *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.info),
                          ),
                          items: AdoptionStatus.values.map((status) {
                            String label;
                            switch (status) {
                              case AdoptionStatus.available:
                                label = 'Disponible';
                                break;
                              case AdoptionStatus.pending:
                                label = 'Pendiente';
                                break;
                              case AdoptionStatus.adopted:
                                label = 'Adoptado';
                                break;
                            }
                            return DropdownMenuItem(
                              value: status,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedStatus = value);
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción *',
                            border: OutlineInputBorder(),
                            hintText: 'Cuéntanos sobre esta mascota...',
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, ingresa una descripción';
                            }
                            if (value.trim().length < 20) {
                              return 'La descripción debe tener al menos 20 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _healthStatusController,
                          decoration: const InputDecoration(
                            labelText: 'Estado de Salud (opcional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.medical_services),
                            hintText: 'Ej: Vacunas al día, esterilizado',
                          ),
                          maxLines: 3,
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
                        const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildImageEditor() {
    final allCurrentUrls = [
      if (widget.pet.mainImageUrl.isNotEmpty) widget.pet.mainImageUrl,
      ...widget.pet.imagesUrls,
    ];
    
    final existingImages = allCurrentUrls
        .where((url) => !_imagesToDelete.contains(url))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (existingImages.isEmpty && _newImages.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Toca para agregar fotos',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              if (existingImages.isNotEmpty) ...[
                const Text(
                  'Fotos actuales',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: existingImages.length,
                    itemBuilder: (context, index) {
                      final url = existingImages[index];
                      return Stack(
                        children: [
                          Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => _removeExistingImage(url),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_imagesToDelete.isNotEmpty) ...[
                const Text(
                  'Fotos a eliminar',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagesToDelete.length,
                    itemBuilder: (context, index) {
                      final url = _imagesToDelete[index];
                      return Stack(
                        children: [
                          Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  Colors.red.withOpacity(0.5),
                                  BlendMode.color,
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => _restoreImage(url),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.restore,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_newImages.isNotEmpty) ...[
                const Text(
                  'Nuevas fotos',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _newImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(File(_newImages[index].path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => _removeNewImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Agregar más fotos'),
              ),
            ],
          ),
      ],
    );
  }
}
