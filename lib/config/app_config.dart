class AppConfig {
  // MongoDB Atlas connection string with correct credentials
  static const String mongodbUri = 'mongodb://abbasahsan1:2103040@karvaanapp-shard-00-00.da1dd.mongodb.net:27017,karvaanapp-shard-00-01.da1dd.mongodb.net:27017,karvaanapp-shard-00-02.da1dd.mongodb.net:27017/karvaan?ssl=true&replicaSet=atlas-2xolaj-shard-0&authSource=admin&retryWrites=true&w=majority';
  
  // Other app configurations can go here
  static const String appName = 'Karvaan';
  static const String appVersion = '1.0.0';
}
