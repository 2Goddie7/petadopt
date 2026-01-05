import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Features - Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/is_signed_in.dart';

// Features - Pets
import '../../features/pets/data/datasources/pets_remote_data_source.dart';
import '../../features/pets/data/repositories/pets_repository_impl.dart';
import '../../features/pets/domain/repositories/pets_repository.dart';
import '../../features/pets/domain/usecases/get_all_pets.dart';
import '../../features/pets/domain/usecases/get_pet_by_id.dart';
import '../../features/pets/domain/usecases/get_pet_by_shelter.dart';
import '../../features/pets/domain/usecases/create_pet.dart';
import '../../features/pets/domain/usecases/update_pet.dart';
import '../../features/pets/domain/usecases/delete_pet.dart';
import '../../features/pets/domain/usecases/search_pets.dart';
import '../../features/pets/domain/usecases/upload_pet_images.dart';
import '../../features/pets/domain/usecases/increment_views.dart';
import '../../features/pets/domain/usecases/update_adoption_status.dart';

// Features - Adoptions
import '../../features/adoptions/data/datasources/adoptions_remote_data_source.dart';
import '../../features/adoptions/data/repositories/adoptions_repository_impl.dart';
import '../../features/adoptions/domain/repositories/adoptions_repository.dart';
import '../../features/adoptions/domain/usecases/create_adoption_request.dart';
import '../../features/adoptions/domain/usecases/get_user_requests.dart';
import '../../features/adoptions/domain/usecases/get_shelter_requests.dart';
import '../../features/adoptions/domain/usecases/get_request_by_id.dart';
import '../../features/adoptions/domain/usecases/approve_request.dart';
import '../../features/adoptions/domain/usecases/reject_request.dart';
import '../../features/adoptions/domain/usecases/cancel_request.dart';
import '../../features/adoptions/domain/usecases/has_active_pet_request.dart';

// Features - AI Chat
import '../../features/ai_chat/data/datasources/gemini_remote_data_source.dart';
import '../../features/ai_chat/data/repositories/ai_chat_repository_impl.dart';
import '../../features/ai_chat/domain/repositories/ai_chat_repository.dart';
import '../../features/ai_chat/domain/usecases/send_message.dart';
import '../../features/ai_chat/domain/usecases/get_chat_history.dart';
import '../../features/ai_chat/domain/usecases/clear_chat_history.dart';

// Features - Map
import '../../features/map/data/datasources/shelters_remote_data_source.dart';
import '../../features/map/data/repositories/map_repository_impl.dart';
import '../../features/map/domain/repositories/map_repository.dart';
import '../../features/map/domain/usecases/get_all_shelters.dart';
import '../../features/map/domain/usecases/get_shelter_by_id.dart';
import '../../features/map/domain/usecases/get_shelter_by_profile_id.dart';
import '../../features/map/domain/usecases/get_nearby_shelters.dart';
import '../../features/map/domain/usecases/calculate_distance.dart';
import '../../features/map/domain/usecases/get_user_location.dart';
import '../../features/map/domain/usecases/create_shelter.dart';
import '../../features/map/domain/usecases/update_shelter.dart';

// Features - Profile
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/domain/usecases/upload_profile_image.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============================================
  // EXTERNAL
  // ============================================
  
  // Supabase Client (singleton)
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // ============================================
  // FEATURES - AUTH
  // ============================================
  
  // Use Cases
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => IsSignedIn(sl()));
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabase: sl()),
  );

  // ============================================
  // FEATURES - PETS
  // ============================================
  
  // Use Cases
  sl.registerLazySingleton(() => GetAllPets(sl()));
  sl.registerLazySingleton(() => GetPetById(sl()));
  sl.registerLazySingleton(() => GetPetsByShelter(sl()));
  sl.registerLazySingleton(() => CreatePet(sl()));
  sl.registerLazySingleton(() => UpdatePet(sl()));
  sl.registerLazySingleton(() => DeletePet(sl()));
  sl.registerLazySingleton(() => SearchPets(sl()));
  sl.registerLazySingleton(() => UploadPetImages(sl()));
  sl.registerLazySingleton(() => IncrementPetViews(sl()));
  sl.registerLazySingleton(() => UpdateAdoptionStatus(sl()));
  
  // Repository
  sl.registerLazySingleton<PetsRepository>(
    () => PetsRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Data Source
  sl.registerLazySingleton<PetsRemoteDataSource>(
    () => PetsRemoteDataSourceImpl(supabase: sl()),
  );

  // ============================================
  // FEATURES - ADOPTIONS
  // ============================================
  
  // Use Cases
  sl.registerLazySingleton(() => CreateAdoptionRequest(sl()));
  sl.registerLazySingleton(() => GetUserRequests(sl()));
  sl.registerLazySingleton(() => GetShelterRequests(sl()));
  sl.registerLazySingleton(() => GetRequestById(sl()));
  sl.registerLazySingleton(() => ApproveRequest(sl()));
  sl.registerLazySingleton(() => RejectRequest(sl()));
  sl.registerLazySingleton(() => CancelRequest(sl()));
  sl.registerLazySingleton(() => HasActivePetRequest(sl()));
  
  // Repository
  sl.registerLazySingleton<AdoptionsRepository>(
    () => AdoptionsRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Data Source
  sl.registerLazySingleton<AdoptionsRemoteDataSource>(
    () => AdoptionsRemoteDataSourceImpl(supabase: sl()),
  );

  // ============================================
  // FEATURES - AI CHAT
  // ============================================
  
  // Use Cases
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => GetChatHistory(sl()));
  sl.registerLazySingleton(() => ClearChatHistory(sl()));
  
  // Repository
  sl.registerLazySingleton<AiChatRepository>(
    () => AiChatRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Data Source
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(supabase: sl()),
  );

  // ============================================
  // FEATURES - MAP
  // ============================================
  
  // Use Cases
  sl.registerLazySingleton(() => GetAllShelters(sl()));
  sl.registerLazySingleton(() => GetShelterById(sl()));
  sl.registerLazySingleton(() => GetShelterByProfileId(sl()));
  sl.registerLazySingleton(() => GetNearbyShelters(sl()));
  sl.registerLazySingleton(() => CalculateDistance(sl()));
  sl.registerLazySingleton(() => GetUserLocation(sl()));
  sl.registerLazySingleton(() => CreateShelter(sl()));
  sl.registerLazySingleton(() => UpdateShelter(sl()));
  
  // Repository
  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Data Source
  sl.registerLazySingleton<SheltersRemoteDataSource>(
    () => SheltersRemoteDataSourceImpl(supabase: sl()),
  );

  // ============================================
  // FEATURES - PROFILE ⭐ NUEVO
  // ============================================
  
  // Use Cases
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => UploadProfileImage(sl()));
  
  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Data Source
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(supabase: sl()),
  );
}