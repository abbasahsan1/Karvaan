import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:karvaan/models/service_location_model.dart';
import 'package:karvaan/services/service_location_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/glass_container.dart';
import 'package:latlong2/latlong.dart';

class ServiceLocatorMapScreen extends StatefulWidget {
  const ServiceLocatorMapScreen({super.key});

  @override
  State<ServiceLocatorMapScreen> createState() => _ServiceLocatorMapScreenState();
}

class _ServiceLocatorMapScreenState extends State<ServiceLocatorMapScreen> {
  static const LatLng _defaultCenter = LatLng(33.6844, 73.0479); // Islamabad default
  static const double _defaultZoom = 12.5;
  static const double _savedMatchThresholdMeters = 50;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ServiceLocationService _locationService = ServiceLocationService.instance;
  final Distance _distance = const Distance();

  LatLng _cameraCenter = _defaultCenter;
  LatLng? _currentLocation;

  bool _isLoadingLocation = false;
  bool _isSearching = false;
  bool _isFetchingFuel = false;
  bool _isRouting = false;

  List<ServiceLocationModel> _savedLocations = [];
  List<_MapPlace> _searchPlaces = [];
  List<_MapPlace> _fuelPlaces = [];
  _MapPlace? _selectedPlace;
  List<LatLng> _routePoints = [];
  String? _routeSummary;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadSavedLocations();
    await _resolveCurrentLocation();
  }

  Future<void> _loadSavedLocations() async {
    try {
      final locations = await _locationService.getSavedLocations();
      if (!mounted) return;
      setState(() {
        _savedLocations = locations;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to load saved locations: ${e.toString()}');
    }
  }

  Future<void> _resolveCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        if (!mounted) return;
        setState(() {
          _isLoadingLocation = false;
        });
        _showSnackBar('Location permission denied. Enable it to use GPS features.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;

      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = latLng;
        _cameraCenter = latLng;
        _isLoadingLocation = false;
      });
      _mapController.move(latLng, 14.5);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
      });
      _showSnackBar('Unable to get current location: ${e.toString()}');
    }
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled. Please enable them.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions are permanently denied. Update them in settings.');
      return false;
    }

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), _searchPlacesByQuery);
  }

  Future<void> _searchPlacesByQuery() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchPlaces = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final encoded = Uri.encodeComponent(query);
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$encoded&format=json&addressdetails=1&limit=8');
      final response = await http.get(
        url,
        headers: const {
          'User-Agent': 'KarvaanApp/1.0 (support@karvaan.app)',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Search failed (code ${response.statusCode})');
      }

      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      final results = data.map<_MapPlace>((item) {
        final lat = double.parse(item['lat'] as String);
        final lon = double.parse(item['lon'] as String);
        final name = (item['display_name'] as String?)?.split(',').first.trim();
        return _MapPlace(
          id: 'search_${item['osm_id']}',
          name: name?.isNotEmpty == true ? name! : (item['display_name'] as String? ?? 'Location'),
          category: item['type']?.toString() ?? 'search',
          address: item['display_name'] as String?,
          position: LatLng(lat, lon),
          source: _PlaceSource.search,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _searchPlaces = results;
        _isSearching = false;
      });

      if (results.isNotEmpty) {
        _mapController.move(results.first.position, 14.0);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
      _showSnackBar('Search failed: ${e.toString()}');
    }
  }

  Future<void> _fetchNearbyFuelStations() async {
    if (_currentLocation == null) {
      _showSnackBar('Current location required to search nearby stations.');
      await _resolveCurrentLocation();
      if (_currentLocation == null) return;
    }

    setState(() {
      _isFetchingFuel = true;
    });

    final lat = _currentLocation!.latitude;
    final lon = _currentLocation!.longitude;
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="fuel"](around:6000,$lat,$lon);
  node["amenity"="charging_station"](around:6000,$lat,$lon);
  node["amenity"="fuel"]["fuel:cng"="yes"](around:6000,$lat,$lon);
);
out body;
>;
out skel qt;
''';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: const {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'KarvaanApp/1.0 (support@karvaan.app)',
        },
        body: 'data=$query',
      );

      if (response.statusCode != 200) {
        throw Exception('Overpass error ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final elements = (data['elements'] as List<dynamic>?) ?? [];

      final results = <_MapPlace>[];
      for (final element in elements) {
        if (element is! Map<String, dynamic>) continue;
        if (element['lat'] == null || element['lon'] == null) continue;
        final tags = (element['tags'] as Map?)?.cast<String, dynamic>() ?? {};
        final position = LatLng(
          (element['lat'] as num).toDouble(),
          (element['lon'] as num).toDouble(),
        );
        final savedMatch = _matchSavedLocation(position);
        results.add(_MapPlace(
          id: 'fuel_${element['id']}',
          name: (tags['name'] as String?) ?? 'Fuel Station',
          category: tags['amenity']?.toString() ?? 'fuel',
          address: _composeAddress(tags),
          position: position,
          isSaved: savedMatch != null,
          savedLocation: savedMatch,
          source: _PlaceSource.fuel,
        ));
      }

      if (!mounted) return;
      setState(() {
        _fuelPlaces = results;
        _isFetchingFuel = false;
      });

      if (results.isNotEmpty) {
        _mapController.move(results.first.position, 13.8);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingFuel = false;
      });
      _showSnackBar('Failed to fetch nearby stations: ${e.toString()}');
    }
  }

  String? _composeAddress(Map<String, dynamic> tags) {
    final name = tags['name'] as String?;
    final street = tags['addr:street'] as String?;
    final city = tags['addr:city'] as String? ?? tags['addr:town'] as String?;
    final state = tags['addr:state'] as String?;
    final parts = [name, street, city, state].where((part) => part != null && part!.isNotEmpty).cast<String>().toList();
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  ServiceLocationModel? _matchSavedLocation(LatLng position) {
    for (final location in _savedLocations) {
      final distanceMeters = _distance(
        position,
        LatLng(location.latitude, location.longitude),
      );
      if (distanceMeters <= _savedMatchThresholdMeters) {
        return location;
      }
    }
    return null;
  }

  List<_MapPlace> _visiblePlaces() {
    final Map<String, _MapPlace> places = {};

    for (final place in _fuelPlaces) {
      final saved = _matchSavedLocation(place.position);
    places[place.id] = saved != null
      ? place.copyWith(isSaved: true, savedLocation: saved)
      : place;
    }

    for (final place in _searchPlaces) {
      final saved = _matchSavedLocation(place.position);
    places[place.id] = saved != null
      ? place.copyWith(isSaved: true, savedLocation: saved)
      : place;
    }

    for (final saved in _savedLocations) {
      final savedPlace = _MapPlace.fromModel(saved);
      places[savedPlace.id] = savedPlace;
    }

    if (_selectedPlace != null) {
      places[_selectedPlace!.id] = _selectedPlace!;
    }

    return places.values.toList();
  }

  void _onSelectPlace(_MapPlace place) {
    setState(() {
      _selectedPlace = place;
      _routePoints = [];
      _routeSummary = null;
    });
    _mapController.move(place.position, 15.2);
  }

  Future<void> _onAddCustomLocation(LatLng position) async {
    final result = await showModalBottomSheet<_MapPlace>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddLocationSheet(initialPosition: position),
    );

    if (result == null) return;

    await _saveLocation(
      name: result.name,
      category: result.category,
      address: result.address,
      position: result.position,
    );
  }

  Future<void> _saveLocation({
    required String name,
    required String category,
    String? address,
    required LatLng position,
  }) async {
    try {
      final saved = await _locationService.saveLocation(
        name: name,
        category: category,
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _savedLocations.add(saved);
        _selectedPlace = _MapPlace.fromModel(saved);
      });
      _showSnackBar('Location saved to your garage.');
    } catch (e) {
      _showSnackBar('Failed to save location: ${e.toString()}');
    }
  }

  Future<void> _saveSelectedPlace() async {
    final place = _selectedPlace;
    if (place == null) return;
    await _saveLocation(
      name: place.name,
      category: place.category,
      address: place.address,
      position: place.position,
    );
  }

  Future<void> _buildRouteToSelected() async {
    final place = _selectedPlace;
    if (place == null) return;

    if (_currentLocation == null) {
      await _resolveCurrentLocation();
      if (_currentLocation == null) {
        _showSnackBar('Current location is required to build a route.');
        return;
      }
    }

    setState(() {
      _isRouting = true;
    });

    final start = _currentLocation!;
    final dest = place.position;
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${dest.longitude},${dest.latitude}?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Routing failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = (data['routes'] as List<dynamic>?);
      if (routes == null || routes.isEmpty) {
        throw Exception('No route found.');
      }

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = (geometry['coordinates'] as List<dynamic>).cast<List<dynamic>>();
      final points = coordinates
          .map((pair) => LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble()))
          .toList();

      final distanceKm = ((route['distance'] as num).toDouble()) / 1000.0;
      final durationMinutes = ((route['duration'] as num).toDouble()) / 60.0;

      if (!mounted) return;
      setState(() {
        _routePoints = points;
        _routeSummary = '${distanceKm.toStringAsFixed(1)} km • ${durationMinutes.toStringAsFixed(0)} min';
        _isRouting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRouting = false;
      });
      _showSnackBar('Failed to build route: ${e.toString()}');
    }
  }

  void _clearRoute() {
    setState(() {
      _routePoints = [];
      _routeSummary = null;
      _isRouting = false;
    });
  }

  Future<void> _showSavedLocationsSheet() async {
    if (_savedLocations.isEmpty) {
      _showSnackBar('No saved locations yet. Tap and hold on the map to add one.');
      return;
    }

    final selected = await showModalBottomSheet<ServiceLocationModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: GlassContainer(
            borderRadius: 28,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Saved service spots',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _savedLocations.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white24),
                    itemBuilder: (context, index) {
                      final location = _savedLocations[index];
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(location),
                        title: Text(
                          location.name,
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                        ),
                        subtitle: location.address != null
                            ? Text(
                                location.address!,
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                              )
                            : null,
                        trailing: Text(
                          location.category,
                          style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.accentColorLight),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      final place = _MapPlace.fromModel(selected);
      _onSelectPlace(place);
    }
  }

  void _centerOnUser() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    } else {
      _resolveCurrentLocation();
    }
  }

  void _clearSearchResults() {
    setState(() {
      _searchPlaces = [];
    });
  }

  Color _markerColor(_MapPlace place) {
    if (_selectedPlace?.id == place.id) {
      return AppTheme.accentColor;
    }

    switch (place.source) {
      case _PlaceSource.saved:
        return AppTheme.primaryColor;
      case _PlaceSource.fuel:
        return Colors.orangeAccent;
      case _PlaceSource.custom:
        return Colors.pinkAccent;
      case _PlaceSource.search:
      default:
        return Colors.deepPurpleAccent;
    }
  }

  IconData _markerIcon(_MapPlace place) {
    switch (place.category.toLowerCase()) {
      case 'fuel':
      case 'cng':
      case 'charging_station':
        return Icons.local_gas_station_rounded;
      case 'mechanic':
      case 'garage':
        return Icons.miscellaneous_services_rounded;
      default:
        switch (place.source) {
          case _PlaceSource.fuel:
            return Icons.local_gas_station_rounded;
          case _PlaceSource.saved:
            return Icons.push_pin_rounded;
          default:
            return Icons.place_rounded;
        }
    }
  }

  List<Marker> _buildMarkers() {
    final places = _visiblePlaces();
    return places
        .map(
          (place) => Marker(
            point: place.position,
            width: _selectedPlace?.id == place.id ? 60 : 44,
            height: _selectedPlace?.id == place.id ? 56 : 44,
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () => _onSelectPlace(place),
              child: SizedBox(
                height: _selectedPlace?.id == place.id ? 56 : 44,
                width: _selectedPlace?.id == place.id ? 60 : 44,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _selectedPlace?.id == place.id ? 46 : 36,
                        height: _selectedPlace?.id == place.id ? 46 : 36,
                        decoration: BoxDecoration(
                          color: _markerColor(place).withOpacity(0.88),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.85),
                            width: _selectedPlace?.id == place.id ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _markerColor(place).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          _markerIcon(place),
                          size: _selectedPlace?.id == place.id ? 22 : 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (place.isSaved)
                      Positioned(
                        bottom: _selectedPlace?.id == place.id ? 6 : 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Icon(
                              Icons.bookmark,
                              size: 10,
                              color: AppTheme.accentColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return KarvaanScaffoldShell(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Service Locator',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_isLoadingLocation) ...[
                    const SizedBox(width: 12),
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _cameraCenter,
                initialZoom: _defaultZoom,
                onLongPress: (_, point) => _onAddCustomLocation(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.karvaan.app',
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: AppTheme.accentColor.withOpacity(0.85),
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                if (_currentLocation != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _currentLocation!,
                        radius: 10,
                        color: AppTheme.primaryColor.withOpacity(0.6),
                        borderStrokeWidth: 3,
                        borderColor: Colors.white,
                      ),
                    ],
                  ),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.32),
                          Colors.black.withOpacity(0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 82, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search services, petrol pumps, mechanics...',
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                border: InputBorder.none,
                              ),
                              onChanged: _onSearchChanged,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _searchPlacesByQuery(),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              splashRadius: 20,
                              icon: const Icon(Icons.clear_rounded, color: Colors.white70),
                              onPressed: () {
                                _searchController.clear();
                                _clearSearchResults();
                              },
                            ),
                          IconButton(
                            splashRadius: 20,
                            icon: _isSearching
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.search_rounded, color: Colors.white),
                            onPressed: _isSearching ? null : _searchPlacesByQuery,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _QuickActionChip(
                            label: 'Nearby fuel & CNG',
                            icon: Icons.local_gas_station_rounded,
                            onPressed: _isFetchingFuel ? null : _fetchNearbyFuelStations,
                            isLoading: _isFetchingFuel,
                          ),
                          const SizedBox(width: 10),
                          _QuickActionChip(
                            label: 'Saved spots',
                            icon: Icons.bookmark_rounded,
                            onPressed: _showSavedLocationsSheet,
                          ),
                          const SizedBox(width: 10),
                          _QuickActionChip(
                            label: 'Clear route',
                            icon: Icons.route_rounded,
                            onPressed: _routePoints.isEmpty ? null : _clearRoute,
                          ),
                          const SizedBox(width: 10),
                          _QuickActionChip(
                            label: 'Use GPS',
                            icon: Icons.my_location_rounded,
                            onPressed: _centerOnUser,
                          ),
                        ],
                      ),
                    ),
                    if (_searchPlaces.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: GlassContainer(
                          borderRadius: 22,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _searchPlaces.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white24),
                            itemBuilder: (context, index) {
                              final place = _searchPlaces[index];
                              return ListTile(
                                leading: Icon(_markerIcon(place), color: Colors.white),
                                title: Text(
                                  place.name,
                                  style: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
                                ),
                                subtitle: place.address != null
                                    ? Text(
                                        place.address!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                      )
                                    : null,
                                trailing: place.isSaved
                                    ? Icon(Icons.bookmark, color: AppTheme.accentColorLight)
                                    : null,
                                onTap: () {
                                  _searchFocusNode.unfocus();
                                  _onSelectPlace(place);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: (_selectedPlace != null ? 170 : 32) + bottomInset,
              child: FloatingActionButton.small(
                heroTag: 'center_user',
                onPressed: _centerOnUser,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.my_location_rounded, color: Colors.black),
              ),
            ),
            if (_selectedPlace != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24 + bottomInset,
                child: GlassContainer(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedPlace!.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (_selectedPlace!.address != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      _selectedPlace!.address!,
                                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Text(
                                _selectedPlace!.category,
                                style: theme.textTheme.labelMedium?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_routeSummary != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _routeSummary!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: _isRouting ? null : _buildRouteToSelected,
                            icon: _isRouting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.route_rounded),
                            label: Text(_isRouting ? 'Routing…' : 'Route'),
                          ),
                          if (!_selectedPlace!.isSaved)
                            OutlinedButton.icon(
                              onPressed: _saveSelectedPlace,
                              icon: const Icon(Icons.bookmark_add_outlined),
                              label: const Text('Save location'),
                            ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedPlace = null;
                                _routePoints = [];
                                _routeSummary = null;
                              });
                            },
                            icon: const Icon(Icons.close_rounded, color: Colors.white70),
                            label: const Text('Dismiss'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _PlaceSource { saved, search, fuel, custom }

class _MapPlace {
  const _MapPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.position,
    this.address,
    this.isSaved = false,
    this.source = _PlaceSource.search,
    this.savedLocation,
  });

  final String id;
  final String name;
  final String category;
  final LatLng position;
  final String? address;
  final bool isSaved;
  final _PlaceSource source;
  final ServiceLocationModel? savedLocation;

  _MapPlace copyWith({
    bool? isSaved,
    _PlaceSource? source,
    ServiceLocationModel? savedLocation,
  }) {
    return _MapPlace(
      id: id,
      name: name,
      category: category,
      position: position,
      address: address,
      isSaved: isSaved ?? this.isSaved,
      source: source ?? this.source,
      savedLocation: savedLocation ?? this.savedLocation,
    );
  }

  factory _MapPlace.fromModel(ServiceLocationModel model) {
    return _MapPlace(
      id: model.id?.toHexString() ?? 'saved_${model.latitude}_${model.longitude}',
      name: model.name,
      category: model.category,
      address: model.address,
      position: LatLng(model.latitude, model.longitude),
      isSaved: true,
      source: _PlaceSource.saved,
      savedLocation: model,
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool enabled = onPressed != null;

    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(icon, size: 18),
      label: Text(label, style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.08),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}

class _AddLocationSheet extends StatefulWidget {
  const _AddLocationSheet({required this.initialPosition});

  final LatLng initialPosition;

  @override
  State<_AddLocationSheet> createState() => _AddLocationSheetState();
}

class _AddLocationSheetState extends State<_AddLocationSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _category = 'mechanic';

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      _MapPlace(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        category: _category,
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        position: widget.initialPosition,
        source: _PlaceSource.custom,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add custom service spot',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Location name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'mechanic', child: Text('Mechanic')), 
                  DropdownMenuItem(value: 'fuel', child: Text('Fuel / Station')),
                  DropdownMenuItem(value: 'garage', child: Text('Garage / Workshop')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Notes / Address (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save spot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
