class Services {
  late var routes;
  late String name;
  Services({required this.name, required this.routes});
  Services.fromJson(Map<String, dynamic> json) {
    routes = json['routes'];
    name = json['name'];
  }
}
