import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../theme/app_colors.dart';
import '../../../models/car_category.dart';

class DelhiNCRBookingScreen extends StatefulWidget {
  const DelhiNCRBookingScreen({super.key});

  @override
  State<DelhiNCRBookingScreen> createState() => _DelhiNCRBookingScreenState();
}

class _DelhiNCRBookingScreenState extends State<DelhiNCRBookingScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();

  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  LatLng? _pickupLocation;
  LatLng? _dropLocation;

  bool _isSearchingDriver = false;
  bool _isDriverFound = false;
  bool _isRideStarted = false;
  bool _isRideCompleted = false;
  bool _showCarSelection = false;

  CarCategory? _selectedCategory;
  double _estimatedDistance = 8.5;
  int _duration = 30;

  final List<CarCategory> _carCategories = [
    CarCategory(
      id: 'mini',
      name: 'TaxiSure Mini',
      image: 'assets/images/wagonr.jpg',
      pricePerKm: 14.0,
      description: 'Affordable rides for daily commute',
      features: ['AC', 'Sanitized', '4 Seats'],
      seatingCapacity: 4,
      estimatedTime: 4,
    ),
    CarCategory(
      id: 'sedan',
      name: 'TaxiSure Sedan',
      image: 'assets/images/aura.jpg',
      pricePerKm: 18.0,
      description: 'Comfortable sedan for a premium experience',
      features: ['AC', 'Sanitized', '4 Seats', 'Extra Legroom'],
      seatingCapacity: 4,
      estimatedTime: 5,
    ),
    CarCategory(
      id: 'suv',
      name: 'TaxiSure SUV',
      image: 'assets/images/ertiga.jpg',
      pricePerKm: 20.0,
      description: 'Spacious SUV for group travel',
      features: ['AC', 'Sanitized', '6 Seats', 'Extra Luggage Space'],
      seatingCapacity: 6,
      estimatedTime: 6,
    ),
  ];

  final Driver _mockDriver = Driver(
    name: "Rajesh Kumar",
    phoneNumber: "+91 98765 43210",
    rating: 4.8,
    vehicleNumber: "DL 01 AB 1234",
    vehicleModel: "WagonR",
    image: "assets/images/wagonr.jpg",
    location: LatLng(28.6149, 77.2090),
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _pickupLocation = LatLng(position.latitude, position.longitude);
      _updateMarkers();
    });
    _getAddressFromLatLng(_pickupLocation!, _pickupController);
  }

  double _calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
            start.latitude, start.longitude, end.latitude, end.longitude) /
        1000; // Converted to kilometers
  }

  int _calculateEstimatedArrivalTime(double distance) {
    double averageSpeed = 30; // Average speed in km/h
    return ((distance / averageSpeed) * 60).round(); // Time in minutes
  }

  Future<void> _getAddressFromLatLng(
      LatLng location, TextEditingController controller) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      location.latitude,
      location.longitude,
    );
    Placemark place = placemarks[0];
    controller.text =
        "${place.street}, ${place.subLocality}, ${place.locality}";
  }

  void _updateMarkers() {
    _markers = {};
    if (_pickupLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    if (_dropLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId('drop'),
        position: _dropLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
    setState(() {});
  }

  double _calculateEstimatedPrice(CarCategory category) {
    final baseFare = 50.0;
    final distanceFare = _estimatedDistance * category.pricePerKm;
    final timeCharge = _duration * 2.0;
    final subtotal = baseFare + distanceFare + timeCharge;
    final platformFee = subtotal * 0.12;
    final gst = subtotal * 0.05;
    return subtotal + platformFee + gst;
  }

  Widget _buildCarCategoryCard(CarCategory category) {
    final isSelected = _selectedCategory?.id == category.id;
    final estimatedPrice = _calculateEstimatedPrice(category);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car image and name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      category.image,
                      width: 100,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Car details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car name
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Car description
                        Text(
                          category.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Features list
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: category.features.map((feature) {
                  return Chip(
                    avatar: Icon(
                      _getFeatureIconData(feature),
                      size: 14,
                      color: Colors.grey[800],
                    ),
                    label: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              // Estimated time, seats, and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time and seats info
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${category.estimatedTime} min away',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${category.seatingCapacity} seats',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  // Estimated price
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '₹${estimatedPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChips(List<String> features) {
    return Wrap(
      spacing: 4,
      children: features.map((feature) {
        return Chip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: Colors.grey[100],
          avatar: Icon(
            _getFeatureIconData(feature),
            size: 14,
            color: Colors.grey[800],
          ),
          label: Text(
            feature,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getFeatureIconData(String feature) {
    switch (feature.toLowerCase()) {
      case 'ac':
        return Icons.ac_unit;
      case 'sanitized':
        return Icons.cleaning_services;
      case 'extra legroom':
        return Icons.airline_seat_legroom_extra;
      case 'extra luggage space':
        return Icons.airport_shuttle;
      case '4 seats':
      case '6 seats':
        return Icons.event_seat;
      default:
        return Icons.check_circle;
    }
  }

  Widget _buildCarSelection() {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Select Car Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _carCategories.length,
                  itemBuilder: (context, index) {
                    return _buildCarCategoryCard(_carCategories[index]);
                  },
                ),
              ),
              if (_selectedCategory != null)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: _searchDriver,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.local_taxi_outlined),
                      label: Text(
                        'Book ${_selectedCategory?.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _searchDriver() async {
    setState(() {
      _isSearchingDriver = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isSearchingDriver = false;
      _isDriverFound = true;
    });
  }

  void _startRide() {
    setState(() {
      _isRideStarted = true;
    });
  }

  void _completeRide() {
    setState(() {
      _isRideStarted = false;
      _isRideCompleted = true;
    });
    _showBill();
  }

  void _showBill() {
    if (_selectedCategory == null) return;

    final estimatedPrice = _calculateEstimatedPrice(_selectedCategory!);
    final baseFare = 50.0;
    final distanceFare = _estimatedDistance * _selectedCategory!.pricePerKm;
    final timeCharge = _duration * 2.0;
    final subtotal = baseFare + distanceFare + timeCharge;
    final platformFee = subtotal * 0.12;
    final gst = subtotal * 0.05;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Ride Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(thickness: 1),
              _buildBillRow(
                  'Base Fare', '₹${baseFare.toStringAsFixed(2)}', Icons.flag),
              _buildBillRow(
                  'Distance Fare (${_estimatedDistance.toStringAsFixed(1)} km)',
                  '₹${distanceFare.toStringAsFixed(2)}',
                  Icons.directions_car),
              _buildBillRow('Time Charge (${_duration} mins)',
                  '₹${timeCharge.toStringAsFixed(2)}', Icons.access_time),
              _buildBillRow('Platform Fee (12%)',
                  '₹${platformFee.toStringAsFixed(2)}', Icons.receipt_long),
              _buildBillRow(
                  'GST (5%)', '₹${gst.toStringAsFixed(2)}', Icons.receipt),
              const Divider(thickness: 1),
              _buildBillRow('Total', '₹${estimatedPrice.toStringAsFixed(2)}',
                  Icons.attach_money,
                  isBold: true),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.payment),
                label: const Text(
                  'Pay Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String amount, IconData iconData,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(iconData, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInputs() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.my_location, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _pickupController,
                      decoration: const InputDecoration(
                        hintText: 'Pickup Location',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _dropController,
                      decoration: const InputDecoration(
                        hintText: 'Drop Location',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_isSearchingDriver && !_isDriverFound)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showCarSelection = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.search),
                  label: const Text(
                    'Find Rides',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingDriver() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Searching for nearby drivers...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverFound() {
    double distanceToUser = 0.0;
    int estimatedArrivalTime = 0;

    if (_currentPosition != null) {
      distanceToUser = _calculateDistance(_mockDriver.location,
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
      estimatedArrivalTime = _calculateEstimatedArrivalTime(distanceToUser);
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Driver Found!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(thickness: 1),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(_mockDriver.image),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _mockDriver.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_mockDriver.vehicleModel} - ${_mockDriver.vehicleNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            ' ${_mockDriver.rating}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Display arrival time and distance
                      Text(
                        'Arrival in $estimatedArrivalTime mins (${distanceToUser.toStringAsFixed(1)} km away)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Implement call functionality
                  },
                  icon: const Icon(Icons.phone, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _startRide,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.directions_car),
              label: const Text(
                'Start Ride',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // Implement cancel ride functionality
              },
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text(
                'Cancel Ride',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideStarted() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ride in Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(thickness: 1),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(_mockDriver.image),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _mockDriver.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_mockDriver.vehicleModel} - ${_mockDriver.vehicleNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Launch phone call
                  },
                  icon: const Icon(Icons.phone, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRideInfo(Icons.timeline, 'Distance',
                    '${_estimatedDistance.toStringAsFixed(1)} km'),
                _buildRideInfo(Icons.access_time, 'Time', '$_duration mins'),
                _buildRideInfo(Icons.speed, 'Status', 'On Time'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _completeRide,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check),
              label: const Text(
                'Complete Ride',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Delhi-NCR Ride'),
        backgroundColor: AppColors.primary,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(28.6139, 77.2090),
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (!_showCarSelection) _buildLocationInputs(),
          if (_showCarSelection) _buildCarSelection(),
          if (_isSearchingDriver) _buildSearchingDriver(),
          if (_isDriverFound && !_isRideStarted) _buildDriverFound(),
          if (_isRideStarted) _buildRideStarted(),
        ],
      ),
    );
  }
}

class Driver {
  final String name;
  final String phoneNumber;
  final double rating;
  final String vehicleNumber;
  final String vehicleModel;
  final String image;
  final LatLng location;

  Driver(
      {required this.name,
      required this.phoneNumber,
      required this.rating,
      required this.vehicleNumber,
      required this.vehicleModel,
      required this.image,
      required this.location});
}
