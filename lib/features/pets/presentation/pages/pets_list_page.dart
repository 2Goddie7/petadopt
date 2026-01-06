import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/pet.dart';
import '../bloc/pets_bloc.dart';
import '../bloc/pets_event.dart';
import '../bloc/pets_state.dart';

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
      appBar: AppBar(
        title: const Text('Mascotas en Adopción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PetsBloc>().add(LoadPetsEvent());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is PetsLoaded) {
            final pets = state.pets;

            if (pets.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No hay mascotas disponibles'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PetsBloc>().add(RefreshPetsEvent());
                // Esperar un momento para que se complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
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
                  return _PetCard(pet: pets[index]);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-pet');
        },
        child: const Icon(Icons.add),
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
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/pet-detail',
            arguments: pet.id,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: pet.mainImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.pets, size: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.breed} • ${pet.displayAge}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          pet.shelterCity ?? 'Ubicación no disponible',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
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
          ],
        ),
      ),
    );
  }
}