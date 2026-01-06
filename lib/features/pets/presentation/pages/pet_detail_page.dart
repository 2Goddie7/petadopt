import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/pet_detail_bloc.dart';
import '../bloc/pet_detail_event.dart';
import '../bloc/pet_detail_state.dart';
import '../../domain/entities/pet.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import 'package:get_it/get_it.dart';

class PetDetailPage extends StatefulWidget {
  final String petId;
  
  const PetDetailPage({super.key, required this.petId});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  late final PetDetailBloc _petDetailBloc;

  @override
  void initState() {
    super.initState();
    _petDetailBloc = PetDetailBloc(
      getPetById: GetIt.instance(),
      incrementViews: GetIt.instance(),
    );
    _petDetailBloc.add(LoadPetDetailEvent(petId: widget.petId));
    
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
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                bool isFavorite = false;
                
                if (state is FavoritesLoaded) {
                  isFavorite = state.favoriteStatus[pet.id] ?? false;
                } else if (state is FavoriteToggled && state.petId == pet.id) {
                  isFavorite = state.isFavorite;
                }

                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    if (userId.isNotEmpty) {
                      context.read<FavoritesBloc>().add(
                            ToggleFavoriteEvent(
                              userId: userId,
                              petId: pet.id,
                            ),
                          );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Debes iniciar sesión para agregar favoritos'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Compartir
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
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                _buildInfoRow(Icons.cake, 'Edad', '${pet.ageYears} años, ${pet.ageMonths} meses'),
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
                                  child: CircularProgressIndicator(strokeWidth: 2),
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
                
                const SizedBox(height: 80),
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