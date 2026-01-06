import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/pet.dart';
import '../bloc/pets_bloc.dart';
import '../bloc/pets_event.dart';
import '../bloc/pets_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/animated_badge.dart';
import '../../../../shared/animations/slide_fade_transition.dart';
import '../../../../core/constants/app_colors.dart';

class PetsListPage extends StatefulWidget {
  const PetsListPage({super.key});

  @override
  State<PetsListPage> createState() => _PetsListPageState();
}

class _PetsListPageState extends State<PetsListPage> {
  PetSpecies? _selectedSpecies;
  PetSize? _selectedSize;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    // Cargar mascotas al iniciar
    context.read<PetsBloc>().add(LoadPetsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🐾 Encuentra tu compañero'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, size: 20),
            ),
            onPressed: () => _showFilterDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<PetsBloc, PetsState>(
        builder: (context, state) {
          if (state is PetsLoading) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const PetCardSkeleton(),
            );
          }

          if (state is PetsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Algo salió mal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PetsBloc>().add(LoadPetsEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is PetsLoaded) {
            final pets = state.pets;

            if (pets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No hay mascotas disponibles',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Intenta cambiar los filtros',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PetsBloc>().add(RefreshPetsEvent());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppColors.primary,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  return AnimatedListItem(
                    index: index,
                    child: _PetCard(pet: pets[index]),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! Authenticated) return const SizedBox();
          if (authState.user.userType != UserType.shelter)
            return const SizedBox();

          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/create-pet');
            },
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
            backgroundColor: AppColors.primary,
            elevation: 4,
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrar mascotas'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<PetSpecies>(
                  value: _selectedSpecies,
                  decoration: const InputDecoration(labelText: 'Especie'),
                  items: const [
                    DropdownMenuItem(
                      value: PetSpecies.dog,
                      child: Text('Perro'),
                    ),
                    DropdownMenuItem(
                      value: PetSpecies.cat,
                      child: Text('Gato'),
                    ),
                    DropdownMenuItem(
                      value: PetSpecies.other,
                      child: Text('Otro'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => _selectedSpecies = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PetSize>(
                  value: _selectedSize,
                  decoration: const InputDecoration(labelText: 'Tamaño'),
                  items: const [
                    DropdownMenuItem(
                      value: PetSize.small,
                      child: Text('Pequeño'),
                    ),
                    DropdownMenuItem(
                      value: PetSize.medium,
                      child: Text('Mediano'),
                    ),
                    DropdownMenuItem(
                      value: PetSize.large,
                      child: Text('Grande'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => _selectedSize = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    hintText: 'Ej: Quito',
                  ),
                  onChanged: (value) {
                    _selectedCity = value.isEmpty ? null : value;
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedSpecies = null;
                _selectedSize = null;
                _selectedCity = null;
              });
              context.read<PetsBloc>().add(LoadPetsEvent());
              Navigator.pop(dialogContext);
            },
            child: const Text('Limpiar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PetsBloc>().add(SearchPetsEvent(
                    species: _selectedSpecies,
                    size: _selectedSize,
                    city: _selectedCity,
                  ));
              Navigator.pop(dialogContext);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;

  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'pet-${pet.id}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/pet-detail',
              arguments: pet.id,
            );
          },
          child: Stack(
            children: [
              // Imagen de fondo
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: pet.mainImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryLight.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryLight.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.pets, size: 48, color: AppColors.primary),
                  ),
                ),
              ),
              // Gradiente overlay
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.darkOverlay,
                  ),
                ),
              ),
              // Contenido
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet.breed} • ${pet.displayAge}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pet.shelterCity ?? 'Ubicación no disponible',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Badge de estado
              Positioned(
                top: 12,
                right: 12,
                child: AnimatedBadge(
                  text: pet.adoptionStatus == AdoptionStatus.available
                      ? 'Disponible'
                      : 'Adoptado',
                  backgroundColor: pet.adoptionStatus == AdoptionStatus.available
                      ? AppColors.success
                      : AppColors.textSecondary,
                  icon: pet.adoptionStatus == AdoptionStatus.available
                      ? Icons.pets
                      : Icons.check_circle,
                ),
              ),
              // Badge de género
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: pet.gender == PetGender.male
                        ? Colors.blue.withOpacity(0.9)
                        : Colors.pink.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        pet.gender == PetGender.male ? Icons.male : Icons.female,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pet.gender == PetGender.male ? 'Macho' : 'Hembra',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
