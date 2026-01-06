import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../domain/entities/shelter.dart';
import '../widgets/shelter_marker.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  
  @override
  void initState() {
    super.initState();
    // Intentar obtener ubicación del usuario primero
    context.read<MapBloc>().add(const GetUserLocationEvent());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.map),
            SizedBox(width: 8),
            Text('Mapa de Refugios'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              context.read<MapBloc>().add(const GetUserLocationEvent());
            },
            tooltip: 'Mi ubicación',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MapBloc>().add(const LoadAllSheltersEvent());
            },
            tooltip: 'Recargar refugios',
          ),
        ],
      ),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is LocationUpdated) {
            // Centrar mapa en ubicación del usuario
            _mapController.move(
              LatLng(state.location.latitude, state.location.longitude),
              13.0,
            );
          }
        },
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MapLoaded) {
            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _getInitialCenter(state),
                    zoom: 13.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    interactiveFlags: InteractiveFlag.all,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.petadopt',
                      maxNativeZoom: 19,
                    ),
                    
                    // Marcador de ubicación del usuario
                    if (state.userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              state.userLocation!.latitude,
                              state.userLocation!.longitude,
                            ),
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.blue, width: 3),
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    
                    // Marcadores de refugios
                    MarkerLayer(
                      markers: state.shelters.map((shelter) {
                        final isSelected = state.selectedShelter?.id == shelter.id;
                        return Marker(
                          point: LatLng(shelter.latitude, shelter.longitude),
                          width: isSelected ? 48 : 40,
                          height: isSelected ? 48 : 40,
                          child: ShelterMarkerWidget(
                            isSelected: isSelected,
                            onTap: () {
                              context.read<MapBloc>().add(
                                    SelectShelterEvent(shelter: shelter),
                                  );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Bottom sheet con información del refugio seleccionado
                if (state.selectedShelter != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildShelterInfoCard(context, state.selectedShelter!),
                  ),

                // Botón flotante con contador de refugios
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pets, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          '${state.shelters.length} refugios',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Estado inicial
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Cargando mapa...'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    context.read<MapBloc>().add(const LoadAllSheltersEvent());
                  },
                  child: const Text('Cargar refugios'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  LatLng _getInitialCenter(MapLoaded state) {
    if (state.userLocation != null) {
      return LatLng(
        state.userLocation!.latitude,
        state.userLocation!.longitude,
      );
    }
    
    if (state.shelters.isNotEmpty) {
      return LatLng(
        state.shelters.first.latitude,
        state.shelters.first.longitude,
      );
    }
    
    // Centro de México como fallback
    return LatLng(19.4326, -99.1332);
  }

  Widget _buildShelterInfoCard(BuildContext context, Shelter shelter) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle para arrastrar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shelter.shelterName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${shelter.city}, ${shelter.country}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        context.read<MapBloc>().add(
                              const SelectShelterEvent(shelter: null),
                            );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.pets,
                      '${shelter.totalPets} mascotas',
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.favorite,
                      '${shelter.totalAdoptions} adopciones',
                      Colors.red,
                    ),
                  ],
                ),
                
                if (shelter.description != null && shelter.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    shelter.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    if (shelter.phone != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Llamar por teléfono
                          },
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Llamar'),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navegar a detalles del refugio
                        },
                        icon: const Icon(Icons.info, size: 18),
                        label: const Text('Ver más'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
