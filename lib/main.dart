import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/login_provider.dart'; // Your shared provider

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
    return widget.child;
  }
}

// --- App Entry ---
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  // Now stateless—theme via provider
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(loginStateProvider);
    final isDarkMode = ref.watch(themeProvider); // Watch global theme

    return MaterialApp(
      title: 'DryV Flood Nav App',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode
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
      home: isLoggedIn
          ? const AuthWrapper(child: HomePage())
          : const LoginPage(),
    );
  }
}

// --- Login Page (Simplified—no callback pass) ---
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(loginStateProvider);

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
              ? null
              : () {
                  ref.read(loginStateProvider.notifier).state = true;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          const AuthWrapper(child: HomePage()),
                    ),
                  );
                },
          child: Text(isLoggedIn ? 'Already Logged In' : 'Login to DryV'),
        ),
      ),
    );
  }
}

// --- Home Page (No Callback Needed) ---
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
      final isLoggedIn = ref.read(loginStateProvider);
      if (!isLoggedIn) {
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
    final currentDark = ref.read(themeProvider);
    ref.read(themeProvider.notifier).state =
        !currentDark; // Global toggle via Riverpod
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(loginStateProvider);
    if (!isLoggedIn) return const LoginPage();

    final isDarkMode = ref.watch(themeProvider); // For icon

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(child: Image.asset('assets/images/dryv_logo.jpg')),
        ),
        title: Text(
          'DRYV FLOOD NAV APP',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.brightness_high : Icons.brightness_3,
            ), // Dynamic icon
            onPressed: _toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(loginStateProvider.notifier).state = false;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface, // High contrast fix
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
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant, // Better grey for both modes
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Day 2 Screens (Unchanged, but Wrapped for Protection) ---
class EmergencyHotlinesPage extends StatelessWidget {
  const EmergencyHotlinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Hotlines')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: emergencyHotlineCategories.length,
        itemBuilder: (context, index) {
          final category = emergencyHotlineCategories[index];
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AuthWrapper(child: HotlineListPage(category: category)),
                  ),
                );
              },
            ),
          );
        },
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
              title: Text(report.description),
              subtitle: Text(
                '${report.location} - ${report.timestamp.hour}:${report.timestamp.minute.toString().padLeft(2, '0')}',
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface, // High contrast: white in dark, black in light
                  fontWeight:
                      FontWeight.w500, // Optional: Bolder for readability
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
