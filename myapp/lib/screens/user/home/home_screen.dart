// lib/screens/user/home_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../theme/app_colors.dart';
import '../rides/ride_home_screen.dart';
import '../profile/profile_home_screen.dart';

// Define the ServiceCategory model
class ServiceCategory {
  final String id;
  final String title;
  final IconData icon;
  final String description;
  final Color color;

  ServiceCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
  });
}

// Define the CarCategory model
class CarCategory {
  final String name;
  final String image;
  final String price;
  final String description;
  final String estimatedTime;

  CarCategory({
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.estimatedTime,
  });
}

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const RidesScreen(),
    const WalletHomeScreen(), // Placeholder for Wallet screen
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.caption,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car_rounded),
          label: 'Rides',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_rounded),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

// Extracted Home Content into a separate widget
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Position? _currentPosition;
  String _currentAddress = "Getting location...";
  bool _isLoadingLocation = true;

  final List<ServiceCategory> _services = [
    ServiceCategory(
      id: 'delhi-ncr',
      title: 'Delhi-NCR',
      icon: Icons.location_city,
      description: 'Local city rides',
      color: AppColors.primary,
    ),
    ServiceCategory(
      id: 'rental',
      title: 'Car Rental',
      icon: Icons.car_rental,
      description: 'Rent by hour/day',
      color: AppColors.secondary,
    ),
    ServiceCategory(
      id: 'outstation',
      title: 'Outstation',
      icon: Icons.route,
      description: 'Intercity travel',
      color: AppColors.success,
    ),
    ServiceCategory(
      id: 'hill-station',
      title: 'Hill Station',
      icon: Icons.landscape,
      description: 'Mountain getaways',
      color: AppColors.warning,
    ),
    ServiceCategory(
      id: 'india-tour',
      title: 'All India Tour',
      icon: Icons.map,
      description: 'Cross-country travel',
      color: AppColors.error,
    ),
    ServiceCategory(
      id: 'char-dham',
      title: 'Char Dham Yatra',
      icon: Icons.temple_hindu,
      description: 'Religious pilgrimage',
      color: AppColors.inactive,
    ),
  ];

  final List<CarCategory> _carCategories = [
    CarCategory(
      name: 'TaxiSure Mini',
      image: 'assets/images/wagonr.jpg',
      price: '₹149',
      description: 'Affordable, economic rides',
      estimatedTime: '4 min',
    ),
    CarCategory(
      name: 'TaxiSure Sedan',
      image: 'assets/images/aura.jpg',
      price: '₹249',
      description: 'Premium sedan rides',
      estimatedTime: '3 min',
    ),
    CarCategory(
      name: 'TaxiSure Suv',
      image: 'assets/images/ertiga.jpg',
      price: '₹349',
      description: 'SUVs for group travel',
      estimatedTime: '5 min',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Location services are disabled. Please enable them.')));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied')));
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      setState(() {
        _currentAddress = "Location permission denied";
        _isLoadingLocation = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      await _getAddressFromLatLng();
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _currentAddress = "Error getting location";
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      if (_currentPosition != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              '${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _currentAddress = "Error getting address";
        _isLoadingLocation = false;
      });
    }
  }

  Widget _buildQuickAction(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(CarCategory car) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.divider.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image.asset(
                car.image,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          car.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          car.price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      car.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.caption,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: AppColors.caption),
                        const SizedBox(width: 4),
                        Text(
                          car.estimatedTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.caption,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _getCurrentLocation,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section with Profile and Location
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: TextStyle(
                              color: AppColors.caption,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Nikhil Sahni',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle profile tap
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.surface,
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Location Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap:
                      _getCurrentLocation, // Allow refreshing location on tap
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.divider.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Location',
                                  style: TextStyle(
                                    color: AppColors.caption,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _isLoadingLocation
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.primary),
                                        ),
                                      )
                                    : Text(
                                        _currentAddress,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_right,
                              color: AppColors.caption),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      Icons.history,
                      'Recent',
                      AppColors.primary,
                      onTap: () {
                        // Handle recent rides
                      },
                    ),
                    _buildQuickAction(
                      Icons.favorite,
                      'Saved',
                      AppColors.error,
                      onTap: () {
                        // Handle saved locations
                      },
                    ),
                    _buildQuickAction(
                      Icons.card_giftcard,
                      'Refer',
                      AppColors.success,
                      onTap: () {
                        Navigator.pushNamed(context, '/user-referral');
                      },
                    ),
                    _buildQuickAction(
                      Icons.support_agent,
                      'Support',
                      AppColors.warning,
                      onTap: () {
                        // Handle support
                      },
                    ),
                  ],
                ),
              ),

              // Car Categories
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Available Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _carCategories.length,
                itemBuilder: (context, index) {
                  return _buildCarCard(_carCategories[index]);
                },
              ),

              // Services Section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Our Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  return ServiceCard(service: _services[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder for Wallet screen
class WalletHomeScreen extends StatelessWidget {
  const WalletHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Wallet'),
      ),
      body: Center(
        child: Text(
          'Your wallet details will appear here.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

// ServiceCard widget
class ServiceCard extends StatelessWidget {
  final ServiceCategory service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle navigation based on service type
        if (service.id == 'delhi-ncr') {
          Navigator.pushNamed(context, '/delhi-ncr-booking');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.divider.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(service.icon, size: 32, color: service.color),
            const SizedBox(height: 8),
            Text(
              service.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
