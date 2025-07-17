import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String token;

  UserModel({required this.id, required this.name, required this.email, required this.password, required this.token});

  // SERIALIZACION PARA CONVERTIR FORMATO USER DE DART A JSON PARA QUE LA API PUEDA ENTENDERLO CUANDO SE LE ENVIE INFO----------------------------------------------------------------

  // Serialización: convertir el objeto User a map
  // Map: un mapa es una colección de pares clave-valor
  // Se debe convertir el objeto User a un map para poder serializarlo a JSON, esto para que se pueda recibir o enviar los datos en formato JSON a la API

  Map<String, dynamic> toMap(){   //todas las claves del Map deben ser String, y el valor de las claves puede ser dinamico, osea, puede ser boolean, int, double, string ....
    return <String, dynamic>{
      'id': id.isNotEmpty ? id : null,
      'name': name,
      'email': email,
      'password': password,
      'token': token
    };
  }

  // serialización: convertir MAP a JSON
  // Ahora se debe convertir el MAP a JSON, este metodo codifica directamente los datos de map en una cadena JSON

   String toJsonString() {
    return json.encode(toMap());
  }// convierte el map a un json

  // DESERIALIZACION PARA CONVERTIR EL JSON A USER PARA QUE CUANDO LA API ENVIE ALGO A LA APP FLUTTER ESTA LO PUEDA ENTENDER----------------------------------------------------------------

  // fromMap: este es un factory constructor que recibe un map y lo convierte a un objeto User
  // Deserialización: convertir un map a un objeto User
  // Factory constructor: este toma un map (usualmente este man viene de un JSON) y lo convierte en un objeto User. Si un campo no esta presente este por defecto lo llena con una cadena vacia

  // POR SI SLO NO HACE NADA, SE USA EN LA LINEA 58 PARA MANETENER EL ORDEN LOGICO DE JSON A MAP Y LUEGO DE MAP A USER
  factory UserModel.parseFromMap(Map<String, dynamic> map){
      return UserModel(
      id: map['_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      token: map['token']?.toString() ?? '',
    );
  }

  factory UserModel.parseFromJson(String source) =>
      UserModel.parseFromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, hasPassword: ${password.isNotEmpty}, hasToken: ${token.isNotEmpty})';
  }
}


