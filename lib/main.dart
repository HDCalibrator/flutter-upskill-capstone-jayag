// Updated lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/login_provider.dart'; // Import the shared provider (remove duplicate)

// --- Data Models ---
class Hotline {
  final String name;
  final String number;
  const Hotline({required this.name, required this.number});
}

class HotlineCategory {
  final String name;
  final IconData icon;
  final List<Hotline> hotlines;
  const HotlineCategory({
    required this.name,
    required this.icon,
    required this.hotlines,
  });
}

final List<HotlineCategory> emergencyHotlineCategories = [
  const HotlineCategory(
    name: 'National Hotlines',
    icon: Icons.public,
    hotlines: [
      Hotline(name: 'National Emergency Hotline', number: '911'),
      Hotline(name: 'NDRRMC', number: '(02) 8911-5061'),
      Hotline(name: 'Philippine Red Cross', number: '143'),
    ],
  ),
  const HotlineCategory(
    name: 'Local (Arayat) Hotlines',
    icon: Icons.location_city,
    hotlines: [
      Hotline(name: 'Arayat PNP', number: '0998-598-5920'),
      Hotline(name: 'Arayat MDRRMO', number: '0917-521-4410'),
    ],
  ),
  const HotlineCategory(
    name: 'Medical & Fire',
    icon: Icons.local_hospital,
    hotlines: [
      Hotline(name: 'Arayat Fire Station', number: '0998-598-5923'),
      Hotline(name: 'Arayat District Hospital', number: '(045) 885-0229'),
    ],
  ),
];

// --- App Entry ---
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(loginStateProvider);
    return MaterialApp(
      title: 'DryV Flood Nav App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}

// --- Login Page ---
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(loginStateProvider); // Watch for reactivity

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isLoggedIn
              ? null // Disable if already logged in
              : () {
                  // Update global state
                  ref.read(loginStateProvider.notifier).state = true;
                  // Navigate to home (ensures smooth switch)
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
          child: Text(isLoggedIn ? 'Already Logged In' : 'Login to DryV'),
        ),
      ),
    );
  }
}

// --- Home Page ---
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isDarkMode = false; // Start light; toggle as needed

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  void initState() {
    super.initState();
    // Protect: Auto-redirect if somehow loaded while logged out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isLoggedIn = ref.read(loginStateProvider);
      if (!isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(loginStateProvider); // Watch for reactivity

    // Early return if not logged in (extra safety)
    if (!isLoggedIn) {
      return const LoginPage();
    }

    // Apply theme dynamically (use InheritedWidget or Provider for global theme if needed later)
    final currentTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: currentTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(currentTheme.textTheme),
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipOval(child: Image.asset('assets/images/dryv_logo.jpg')),
          ),
          title: Text(
            'DRYV FLOOD NAV APP',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.brightness_high : Icons.brightness_3,
              ),
              onPressed: _toggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                // Update global state
                ref.read(loginStateProvider.notifier).state = false;
                // Navigate back to login (ensures smooth switch)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              DashboardButton(icon: Icons.map, label: 'Flood Map'),
              DashboardButton(icon: Icons.route, label: 'Safe Routes'),
              DashboardButton(icon: Icons.phone, label: 'Emergency Hotlines'),
              DashboardButton(
                icon: Icons.location_on,
                label: 'Saved Locations',
              ),
              DashboardButton(icon: Icons.settings, label: 'Settings'),
              DashboardButton(icon: Icons.info, label: 'About & Help'),
            ],
          ),
        ),
      ),
    );
  }
}

// --- DashboardButton widget ---
class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const DashboardButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // Add tap feedback
        onTap: () {
          // TODO: Navigate to respective screen (e.g., FloodMapPage)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Tapped: $label')));
        },
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
