// lib/screens/user/rides/ride_home_screen.dart
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

// Ride Model
class RideModel {
  final String id;
  final String service;
  final String car;
  final String driver;
  final String driverPhone;
  final String date;
  final String time;
  final String pickup;
  final String dropoff;
  final String fare;
  final String distance;
  final String status;
  final IconData icon;
  final String? notes;
  final String? otp;
  final bool isRoundTrip;
  final int? numberOfDays;

  RideModel({
    required this.id,
    required this.service,
    required this.car,
    required this.driver,
    required this.driverPhone,
    required this.date,
    required this.time,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.status,
    required this.icon,
    this.notes,
    this.otp,
    this.isRoundTrip = false,
    this.numberOfDays,
  });
}

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<RideModel> _allRides = [
    // Delhi-NCR Rides
    RideModel(
      id: '1001',
      service: 'Delhi-NCR',
      car: 'TaxiSure Sedan',
      driver: 'Rajesh Kumar',
      driverPhone: '+91 98765 43210',
      date: '15 Nov 2024',
      time: '10:30 AM',
      pickup: 'Connaught Place',
      dropoff: 'Noida Sector 62',
      fare: '₹749',
      distance: '28.5 km',
      status: 'Scheduled',
      icon: Icons.location_city,
      otp: '4582',
    ),

    // Hill Station Ride
    RideModel(
      id: '1002',
      service: 'Hill Station',
      car: 'TaxiSure Tempo (12 Seater)',
      driver: 'Amit Singh',
      driverPhone: '+91 98765 43211',
      date: '20 Nov 2024',
      time: '06:00 AM',
      pickup: 'Delhi',
      dropoff: 'Manali',
      fare: '₹12,499',
      distance: '538 km',
      status: 'Scheduled',
      icon: Icons.landscape,
      notes: 'Round trip - 4 days package',
      isRoundTrip: true,
      numberOfDays: 4,
    ),

    // Car Rental
    RideModel(
      id: '1003',
      service: 'Car Rental',
      car: 'TaxiSure SUV',
      driver: 'Suresh Patel',
      driverPhone: '+91 98765 43212',
      date: '10 Nov 2024',
      time: '09:00 AM',
      pickup: 'IGI Airport T3',
      dropoff: 'Same as pickup',
      fare: '₹2,499',
      distance: '80 km package',
      status: 'Completed',
      icon: Icons.car_rental,
      notes: '8 hours package',
      numberOfDays: 1,
    ),

    // Outstation
    RideModel(
      id: '1004',
      service: 'Outstation',
      car: 'TaxiSure Premium Sedan',
      driver: 'Manish Kumar',
      driverPhone: '+91 98765 43213',
      date: '5 Nov 2024',
      time: '07:00 AM',
      pickup: 'Delhi',
      dropoff: 'Agra',
      fare: '₹4,999',
      distance: '233 km',
      status: 'Cancelled',
      icon: Icons.route,
      notes: 'Cancellation reason: Bad weather',
    ),

    // Char Dham Yatra
    RideModel(
      id: '1005',
      service: 'Char Dham Yatra',
      car: 'TaxiSure Premium SUV',
      driver: 'Rakesh Singh',
      driverPhone: '+91 98765 43214',
      date: '1 Dec 2024',
      time: '04:00 AM',
      pickup: 'Delhi',
      dropoff: 'Char Dham Circuit',
      fare: '₹45,999',
      distance: '1,800 km',
      status: 'Scheduled',
      icon: Icons.temple_hindu,
      notes: '12 days package - All inclusive',
      isRoundTrip: true,
      numberOfDays: 12,
    ),
  ];

  List<RideModel> _getFilteredRides(
      {bool upcoming = false, bool completed = false, bool cancelled = false}) {
    return _allRides.where((ride) {
      if (upcoming) return ride.status == 'Scheduled';
      if (completed) return ride.status == 'Completed';
      if (cancelled) return ride.status == 'Cancelled';
      return false;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Rides',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.caption,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRidesList(upcoming: true),
          _buildRidesList(completed: true),
          _buildRidesList(cancelled: true),
        ],
      ),
    );
  }

  Widget _buildRidesList({
    bool upcoming = false,
    bool completed = false,
    bool cancelled = false,
  }) {
    final rides = _getFilteredRides(
      upcoming: upcoming,
      completed: completed,
      cancelled: cancelled,
    );

    return rides.isEmpty
        ? _buildEmptyState(upcoming, completed, cancelled)
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            itemBuilder: (context, index) =>
                _buildRideCard(rides[index], upcoming),
          );
  }

  Widget _buildEmptyState(bool upcoming, bool completed, bool cancelled) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: AppColors.caption.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${upcoming ? 'upcoming' : completed ? 'completed' : 'cancelled'} rides',
            style: TextStyle(
              color: AppColors.caption.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(RideModel ride, bool isUpcoming) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRideHeader(ride),
            const Divider(height: 24),
            _buildRideDetails(ride),
            if (ride.notes != null) ...[
              const SizedBox(height: 8),
              _buildRideDetail(Icons.note, ride.notes!),
            ],
            if (isUpcoming) ...[
              const SizedBox(height: 16),
              _buildActionButtons(ride),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRideHeader(RideModel ride) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(ride.icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ride.service,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ride.car,
                style: const TextStyle(color: AppColors.caption),
              ),
            ],
          ),
        ),
        _buildStatusBadge(ride.status),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRideDetails(RideModel ride) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRideDetail(
          Icons.calendar_today,
          '${ride.date} at ${ride.time}',
        ),
        const SizedBox(height: 8),
        _buildRideDetail(
          Icons.person,
          'Driver: ${ride.driver}',
        ),
        const SizedBox(height: 8),
        _buildRideDetail(
          Icons.phone,
          ride.driverPhone,
        ),
        const SizedBox(height: 8),
        _buildRideDetail(
          Icons.location_on,
          'From: ${ride.pickup}',
        ),
        const SizedBox(height: 8),
        _buildRideDetail(
          Icons.location_on,
          'To: ${ride.dropoff}',
        ),

        // Fare & Distance
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildRideDetail(
                Icons.money,
                'Fare: ${ride.fare}',
              ),
            ),
            Expanded(
              child: _buildRideDetail(
                Icons.directions,
                'Distance: ${ride.distance}',
              ),
            ),
          ],
        ),

        // OTP
        if (ride.otp != null) ...[
          const SizedBox(height: 8),
          _buildRideDetail(
            Icons.lock,
            'OTP: ${ride.otp}',
          ),
        ],

        // Round Trip
        if (ride.isRoundTrip) ...[
          const SizedBox(height: 8),
          _buildRideDetail(
            Icons.repeat,
            'Round Trip - ${ride.numberOfDays} days',
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return AppColors.primary;
      case 'Completed':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.caption;
    }
  }

  Widget _buildRideDetail(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.caption),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(RideModel ride) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Cancel ride
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Cancel Ride'),
        ),
      ],
    );
  }
}
