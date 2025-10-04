import 'package:flutter/material.dart';

// The main entry point of the application
void main() {
  runApp(const MyApp());
}

// A simple data model for a user report
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

// This is the root widget of the application.
// It's a StatefulWidget because it needs to manage the theme state (dark/light mode).
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // A boolean to keep track of whether dark mode is enabled
  bool _isDarkMode = true;

  // This function is called to toggle the theme
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The title of the app (seen in the task manager)
      title: 'DryV Flood Nav App',
      // Removes the debug banner from the top-right corner
      debugShowCheckedModeBanner: false,
      // Define the theme for the app based on the _isDarkMode state
      // UPDATED: Themes now use colors from the logo
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueGrey, // Using the blue from the logo
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(
                0xFF121212,
              ), // Dark background
              cardColor: Colors.blueGrey[800], // A darker shade for cards
              // ADDED: Simplified page transitions for a lighter feel
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: <TargetPlatform, PageTransitionsBuilder>{
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
                },
              ),
            )
          : ThemeData.light().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.amber, // Using the yellow from the logo
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: Colors.grey[100], // Light background
              cardColor: Colors.white,
              // ADDED: Simplified page transitions for a lighter feel
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: <TargetPlatform, PageTransitionsBuilder>{
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
                },
              ),
            ),
      // The main screen of the app, passing the toggle function to it
      home: HomePage(onToggleTheme: _toggleTheme),
    );
  }
}

// The main home screen widget
class HomePage extends StatelessWidget {
  // A function passed from MyApp to allow this widget to trigger the theme change
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // UPDATED: Re-added ClipOval for a circular logo and updated image path
        leading: Padding(
          padding: const EdgeInsets.all(
            8.0,
          ), // Keeps some space around the logo
          child: ClipOval(child: Image.asset('assets/images/dryv_logo.jpg')),
        ),
        // The title displayed in the app bar
        title: const Text('DRYV FLOOD NAV APP'),
        // Actions are widgets displayed on the right side of the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6), // Icon for theme toggle
            onPressed: onToggleTheme, // Call the function to toggle the theme
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The Expanded widget makes the GridView take up all available space
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 columns in the grid
                crossAxisSpacing: 16, // Horizontal spacing
                mainAxisSpacing: 16, // Vertical spacing
                children: [
                  // Creating the 6 dashboard buttons
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
                    onPressed: () => _navigateToPage(
                      context,
                      const ComingSoonPage(featureName: 'Emergency Hotlines'),
                    ),
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
            // NEW: Wide button for Community Reports
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
                        const Text(
                          'Community Reports',
                          // FIXED: Changed 'bold' to FontWeight.bold
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // The text at the bottom of the screen
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text(
                'Last Updated: No Data',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to navigate to a new page
  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

// A reusable widget for the buttons on the dashboard
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// NEW: The Community Reports page
class CommunityReportsPage extends StatefulWidget {
  const CommunityReportsPage({super.key});

  @override
  State<CommunityReportsPage> createState() => _CommunityReportsPageState();
}

class _CommunityReportsPageState extends State<CommunityReportsPage> {
  // A list to hold the user reports. Initialized with some mock data.
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

  // Function to navigate to the Add Report page and get the result
  void _navigateAndAddReport() async {
    // Await the result from the AddReportPage
    final newReport = await Navigator.push<Report>(
      context,
      MaterialPageRoute(builder: (context) => const AddReportPage()),
    );

    // If a new report was returned, add it to the list and rebuild the UI
    if (newReport != null) {
      setState(() {
        _reports.insert(0, newReport); // Insert at the beginning of the list
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

// NEW: The page for adding a new report
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
        location: 'Arayat, Pampanga', // Hardcoded for this example
        timestamp: DateTime.now(),
      );
      // Pop the page and return the new report object
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

// A generic "Coming Soon" page for features that are not yet implemented
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

// The "Settings" page
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

// The "About & Help" page
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
