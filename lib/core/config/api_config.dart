class ApiConfig {
  static const String baseUrl = bool.fromEnvironment('dart.vm.product') 
      ? 'https://rv-salon-backend.vercel.app/api' // TODO: Update with your actual Vercel URL
      : 'http://localhost:3000/api';
}
