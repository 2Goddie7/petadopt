import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../bloc/pet_detail_bloc.dart';
import '../bloc/pet_detail_event.dart';
import '../bloc/pet_detail_state.dart';
import '../../domain/entities/pet.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../../adoptions/presentation/bloc/adoptions_bloc.dart';
import '../../../adoptions/presentation/bloc/adoptions_event.dart';
import '../../../adoptions/presentation/bloc/adoptions_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user.dart';
import 'edit_pet_page.dart';
import 'package:get_it/get_it.dart';

class PetDetailPage extends StatefulWidget {
  final String petId;

  const PetDetailPage({super.key, required this.petId});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  late final PetDetailBloc _petDetailBloc;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _petDetailBloc = PetDetailBloc(
      getPetById: GetIt.instance(),
      incrementViews: GetIt.instance(),
      deletePet: GetIt.instance(),
    );
    _petDetailBloc.add(LoadPetDetailEvent(petId: widget.petId));
    _petDetailBloc.add(IncrementPetViewsEvent(petId: widget.petId));

    // Check if pet is favorite
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<FavoritesBloc>().add(
            CheckIsFavoriteEvent(userId: userId, petId: widget.petId),
          );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _petDetailBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _petDetailBloc,
      child: Scaffold(
        body: BlocConsumer<PetDetailBloc, PetDetailState>(
          listener: (context, state) {
            if (state is PetDetailError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is PetDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PetDetailLoaded) {
              return _buildPetDetail(context, state.pet);
            }

            if (state is PetDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar mascota',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _petDetailBloc.add(const RefreshPetDetailEvent());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
        bottomSheet: BlocBuilder<PetDetailBloc, PetDetailState>(
          builder: (context, petState) {
            if (petState is! PetDetailLoaded) return const SizedBox();
            return _buildAdoptionBottomSheet(context, petState.pet);
          },
        ),
      ),
    );
  }

  Widget _buildAdoptionBottomSheet(BuildContext context, Pet pet) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) return const SizedBox();

        // Solo mostrar para adoptantes
        if (authState.user.userType != UserType.adopter) {
          return const SizedBox();
        }

        // No mostrar si ya está adoptado
        if (pet.adoptionStatus == AdoptionStatus.adopted) {
          return Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                '🎉 Esta mascota ya fue adoptada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        return BlocConsumer<AdoptionsBloc, AdoptionsState>(
          listener: (context, adoptionState) {
            if (adoptionState is AdoptionCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Solicitud enviada correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (adoptionState is AdoptionsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(adoptionState.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, adoptionState) {
            final isLoading = adoptionState is AdoptionsLoading;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _showAdoptionRequestDialog(context, pet),
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.favorite),
                    label: Text(
                      isLoading ? 'Enviando...' : 'Solicitar Adopción',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Método helper para eliminar mascota
  Future<void> _deletePet(BuildContext context, String petId) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eliminando mascota...')),
      );

      await Supabase.instance.client.from('pets').delete().eq('id', petId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Mascota eliminada correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAdoptionRequestDialog(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Adoptar a ${pet.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Deseas solicitar la adopción de ${pet.name}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Mensaje para el refugio (opcional)',
                hintText: 'Cuéntanos por qué quieres adoptar...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _messageController.clear();
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              context.read<AdoptionsBloc>().add(
                    CreateAdoptionRequestEvent(
                      petId: pet.id,
                      message: _messageController.text.trim(),
                    ),
                  );
              _messageController.clear();
            },
            child: const Text('Enviar Solicitud'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Mascota'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${pet.name}? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deletePet(context, pet.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPetDetail(BuildContext context, Pet pet) {
    final imageUrl = pet.mainImageUrl.isNotEmpty ? pet.mainImageUrl : '';
    final hasGallery = pet.imagesUrls.isNotEmpty;
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.pets, size: 100),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.pets, size: 100),
                  ),
          ),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is! Authenticated) return const SizedBox();

                // Si es SHELTER → mostrar botones editar/eliminar
                if (authState.user.userType == UserType.shelter) {
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditPetPage(pet: pet),
                            ),
                          );
                          if (result == true && mounted) {
                            _petDetailBloc.add(
                              LoadPetDetailEvent(petId: widget.petId),
                            );
                          }
                        },
                        tooltip: 'Editar mascota',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, pet),
                        tooltip: 'Eliminar mascota',
                      ),
                    ],
                  );
                }

                // Si es ADOPTANTE → mostrar botón de favorito
                return BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, favState) {
                    final isFavorite =
                        favState is FavoriteToggled && favState.isFavorite;
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        context.read<FavoritesBloc>().add(
                              ToggleFavoriteEvent(
                                userId: authState.user.id,
                                petId: pet.id,
                              ),
                            );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre y estado
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pet.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    _buildStatusChip(pet.adoptionStatus),
                  ],
                ),
                const SizedBox(height: 8),

                // Ubicación
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pet.shelterCity ?? 'Ubicación no disponible',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                if (pet.shelterName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.home, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pet.shelterName!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Información
                Text(
                  'Información',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                _buildInfoRow(Icons.pets, 'Especie', pet.species.name),
                _buildInfoRow(Icons.cake, 'Edad',
                    '${pet.ageYears} años, ${pet.ageMonths} meses'),
                _buildInfoRow(Icons.straighten, 'Tamaño', pet.size.name),
                _buildInfoRow(Icons.male, 'Género', pet.gender.name),
                _buildInfoRow(Icons.label, 'Raza', pet.breed),
                _buildInfoRow(Icons.visibility, 'Vistas', '${pet.viewsCount}'),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Descripción
                Text(
                  'Descripción',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  pet.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),

                const SizedBox(height: 24),

                // Galería
                if (hasGallery) ...[
                  Text(
                    'Más fotos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pet.imagesUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: pet.imagesUrls[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.pets),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AdoptionStatus status) {
    Color color;
    String label;

    switch (status) {
      case AdoptionStatus.available:
        color = Colors.green;
        label = 'Disponible';
        break;
      case AdoptionStatus.pending:
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case AdoptionStatus.adopted:
        color = Colors.blue;
        label = 'Adoptado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
