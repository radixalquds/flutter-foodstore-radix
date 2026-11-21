class AppConfig {
  // Gunakan IP 127.0.0.1
  static const String BASE_URL = 'http://127.0.0.1:8000';

  static const String API_PATH = '$BASE_URL/api/';
  static const String STORAGE_PATH = '$BASE_URL/storage/';
  
  static const String STORAGE_IMAGE = STORAGE_PATH;
  // Arahkan STORAGE_PRODUCTS langsung ke STORAGE_PATH (Tanpa kata products/)
  static const String STORAGE_PRODUCTS = STORAGE_PATH; 
  static const String STORAGE_AVATAR = '${STORAGE_PATH}avatars/';
  
  static const String URL_PAYMENT =
      'https://app.sandbox.midtrans.com/snap/v2/vtweb/';
}