import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../pets/presentation/pages/create_pet_page.dart';
import '../../../pets/presentation/pages/edit_pet_page.dart';
import '../../../pets/presentation/bloc/pets_bloc.dart';
import '../../../pets/presentation/bloc/pets_event.dart';
import '../../../pets/presentation/bloc/pets_state.dart';
import '../../../pets/domain/entities/pet.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  AdoptionStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    context.read<PetsBloc>().add(LoadPetsEvent());
  }

  void _navigateToCreatePet() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreatePetPage()),
    );

    if (result == true && mounted) {
      context.read<PetsBloc>().add(RefreshPetsEvent());
    }
  }

  void _navigateToEditPet(Pet pet) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditPetPage(pet: pet)),
    );

    if (result == true && mounted) {
      context.read<PetsBloc>().add(RefreshPetsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mascotas'),
        actions: [
          PopupMenuButton<AdoptionStatus?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar por estado',
            onSelected: (value) {
              setState(() => _selectedStatusFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todos los estados'),
              ),
              const PopupMenuItem(
                value: AdoptionStatus.available,
                child: Text('Disponibles'),
              ),
              const PopupMenuItem(
                value: AdoptionStatus.pending,
                child: Text('En proceso'),
              ),
              const PopupMenuItem(
                value: AdoptionStatus.adopted,
                child: Text('Adoptados'),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<PetsBloc, PetsState>(
        builder: (context, state) {
          if (state is PetsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PetsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PetsBloc>().add(RefreshPetsEvent());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is PetsLoaded) {
            // Aplicar filtro de estado si está seleccionado
            final filteredPets = _selectedStatusFilter == null
                ? state.pets
                : state.pets
                    .where((pet) => pet.adoptionStatus == _selectedStatusFilter)
                    .toList();

            if (filteredPets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 100, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      _selectedStatusFilter == null
                          ? 'No tienes mascotas registradas'
                          : 'No hay mascotas con este estado',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    if (_selectedStatusFilter == null)
                      ElevatedButton.icon(
                        onPressed: _navigateToCreatePet,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Primera Mascota'),
                      ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPets.length,
              itemBuilder: (context, index) {
                final pet = filteredPets[index];
                return _buildPetCard(context, pet);
              },
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, Pet pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToEditPet(pet),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: pet.petImages.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: pet.petImages.first,
                        width: 80,
                        height: 80,
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
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.pets, size: 40),
                      ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.species.displayName} • ${pet.breed}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.ageDisplay}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusChip(pet.adoptionStatus),
                  ],
                ),
              ),

              // Edit icon
              Icon(Icons.edit, color: Colors.grey[600]),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
