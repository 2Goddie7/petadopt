import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../pets/presentation/pages/pets_list_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../ai_chat/presentation/pages/ai_chat_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../adoptions/presentation/pages/shelter_requests_page.dart';
import '../../../adoptions/presentation/pages/my_requests_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../../domain/entities/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserType? userType;

        if (state is Authenticated) {
          userType = state.user.userType;
        }

        // Páginas según el tipo de usuario
        final pages = _buildPages(userType);
        final navItems = _buildNavItems(userType);

        return Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: navItems,
          ),
        );
      },
    );
  }

  List<Widget> _buildPages(UserType? userType) {
    if (userType == UserType.shelter) {
      return [
        const PetsListPage(),
        const MapPage(),
        const ShelterRequestsPage(),
        const AiChatPage(),
        const ProfilePage(),
      ];
    } else {
      // Adopter o null
      return [
        const PetsListPage(),
        const MapPage(),
        const MyRequestsPage(),
        const AiChatPage(),
        const ProfilePage(),
      ];
    }
  }

  List<BottomNavigationBarItem> _buildNavItems(UserType? userType) {
    if (userType == UserType.shelter) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Mascotas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inbox),
          label: 'Solicitudes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Mascotas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Mis Solicitudes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ];
    }
  }
}
