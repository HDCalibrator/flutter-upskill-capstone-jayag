import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

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

class Report {
  final String description;
  final String location;
  final DateTime timestamp;
  Report({
    required this.description,
    required this.location,
    required this.timestamp,
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

// --- Splash Screen ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Random delay between 3-5 seconds
    final random = Random();
    final delay = Duration(
      seconds: 3 + random.nextInt(3),
    ); // 3, 4, or 5 seconds
    Timer(delay, () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ProviderScope(child: MyApp()),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (scale it up for splash)
            ClipOval(
              child: Image.asset(
                'assets/images/dryv_logo.jpg',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 32),
            // App name with animation (fade in)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(seconds: 1),
              child: Text(
                'DRYV',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Flood Nav App',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Auth Wrapper for Protection ---
class AuthWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const AuthWrapper({super.key, required this.child});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Guard: Redirect if not logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.value == null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// --- App Entry (Firebase Initialized) ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Optional: Uncomment for emulator testing
    // if (kDebugMode) {
    //   await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    // }
  } catch (e) {
    // Log error (replace with logger in production)
  }
  runApp(
    MaterialApp(home: const SplashScreen(), debugShowCheckedModeBanner: false),
  );
}

// --- Theme Provider ---
final themeProvider = StateProvider<bool>(
  (ref) => false,
); // Default to light mode

// --- MyApp (Updated: Watches real auth state) ---
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'DryV Flood Nav App',
      debugShowCheckedModeBanner: false,
      theme: ref.watch(themeProvider)
          ? ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueGrey,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: Colors.blueGrey[800],
              textTheme: GoogleFonts.poppinsTextTheme(),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                },
              ),
            )
          : ThemeData.light().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.amber,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: Colors.grey[100],
              cardColor: Colors.white,
              textTheme: GoogleFonts.poppinsTextTheme(),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                },
              ),
            ),
      home: authState.when(
        data: (user) => user != null
            ? const AuthWrapper(child: HomePage())
            : const LoginPage(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stackTrace) =>
            const LoginPage(), // Fixed to accept error and stackTrace
      ),
    );
  }
}

// --- Home Page (Updated with User Identifier) ---
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Extra guard for home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.value == null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AuthWrapper(child: page)),
    );
  }

  void _toggleTheme() {
    final currentDark = ref.read(themeProvider.notifier).state;
    ref.read(themeProvider.notifier).state = !currentDark;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState.value == null) return const LoginPage();

    final user = authState.value!;
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(child: Image.asset('assets/images/dryv_logo.jpg')),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DRYV FLOOD NAV APP',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              'Logged in as: ${user.email ?? "Unknown"}',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.brightness_high : Icons.brightness_3),
            onPressed: _toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (mounted) {
                // Use a separate function or immediate navigation to avoid async gap
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  }
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  DashboardButton(
                    icon: Icons.map,
                    label: 'Flood Map',
                    onPressed: () => _navigateToPage(
                      context,
                      const ComingSoonPage(featureName: 'Flood Map'),
                    ),
                  ),
                  DashboardButton(
                    icon: Icons.route,
                    label: 'Safe Routes',
                    onPressed: () => _navigateToPage(
                      context,
                      const ComingSoonPage(featureName: 'Safe Routes'),
                    ),
                  ),
                  DashboardButton(
                    icon: Icons.phone,
                    label: 'Emergency Hotlines',
                    onPressed: () =>
                        _navigateToPage(context, const EmergencyHotlinesPage()),
                  ),
                  DashboardButton(
                    icon: Icons.location_on,
                    label: 'Saved Locations',
                    onPressed: () => _navigateToPage(
                      context,
                      const ComingSoonPage(featureName: 'Saved Locations'),
                    ),
                  ),
                  DashboardButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    onPressed: () =>
                        _navigateToPage(context, const SettingsPage()),
                  ),
                  DashboardButton(
                    icon: Icons.info,
                    label: 'About & Help',
                    onPressed: () =>
                        _navigateToPage(context, const AboutPage()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () =>
                      _navigateToPage(context, const CommunityReportsPage()),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Community Reports',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Last Updated: No Data',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Day 2 Screens (unchanged)
class EmergencyHotlinesPage extends ConsumerWidget {
  const EmergencyHotlinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotlinesAsync = ref.watch(hotlineProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Hotlines')),
      body: hotlinesAsync.when(
        data: (categories) => ListView.builder(
          padding: const EdgeInsets.all(8.0), // Added padding for consistency
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  category.icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HotlineListPage(category: category),
                  ),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class HotlineListPage extends StatelessWidget {
  final HotlineCategory category;
  const HotlineListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: category.hotlines.length,
        itemBuilder: (context, index) {
          final hotline = category.hotlines[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.call),
              title: Text(hotline.name),
              subtitle: Text(hotline.number),
              onTap: () {}, // TODO: Dialer integration
            ),
          );
        },
      ),
    );
  }
}

class CommunityReportsPage extends StatefulWidget {
  const CommunityReportsPage({super.key});
  @override
  State<CommunityReportsPage> createState() => _CommunityReportsPageState();
}

class _CommunityReportsPageState extends State<CommunityReportsPage> {
  final List<Report> _reports = [
    Report(
      description: 'Gutter-deep flood on the main road. Traffic is slow.',
      location: 'Poblacion, Arayat',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    Report(
      description: 'Road is now passable to all types of vehicles.',
      location: 'San Nicolas, Arayat',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  void _navigateAndAddReport() async {
    final newReport = await Navigator.push<Report>(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthWrapper(child: AddReportPage()),
      ),
    );
    if (newReport != null) {
      setState(() {
        _reports.insert(0, newReport);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Reports')),
      body: ListView.builder(
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded),
              title: Text(
                report.description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                '${report.location} - ${report.timestamp.hour}:${report.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndAddReport,
        tooltip: 'Add Report',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});
  @override
  State<AddReportPage> createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final _textController = TextEditingController();

  void _submitReport() {
    if (_textController.text.isNotEmpty) {
      final newReport = Report(
        description: _textController.text,
        location: 'Arayat, Pampanga',
        timestamp: DateTime.now(),
      );
      Navigator.pop(context, newReport);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a New Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitReport,
            tooltip: 'Submit',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Describe the situation...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const DashboardButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ComingSoonPage extends StatelessWidget {
  final String featureName;
  const ComingSoonPage({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(featureName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$featureName Feature Coming Soon',
              style: const TextStyle(fontSize: 22, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About & Help')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DryV Flood Navigation App',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0 (Front-End Only)',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
