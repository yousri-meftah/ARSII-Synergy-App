import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/models/enums.dart';
import 'package:arsii_mvp/state/auth_state.dart';
import 'package:arsii_mvp/screens/dashboard_screen.dart';
import 'package:arsii_mvp/screens/tasks_screen.dart';
import 'package:arsii_mvp/screens/notifications_screen.dart';
import 'package:arsii_mvp/screens/projects_screen.dart';
import 'package:arsii_mvp/screens/teams_screen.dart';
import 'package:arsii_mvp/screens/workload_screen.dart';
import 'package:arsii_mvp/screens/profile_screen.dart';
import 'package:arsii_mvp/screens/settings_screen.dart';
import 'package:arsii_mvp/state/ws_state.dart';
import 'package:arsii_mvp/state/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final role = auth.user?.role ?? Role.user;

    ref.listen(wsEventsProvider, (_, __) {
      ref.invalidate(tasksProvider(const TaskFilter()));
      ref.invalidate(dashboardProvider);
      ref.invalidate(notificationsProvider);
    });

    final tabs = _tabsForRole(role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ARSII-Sfax'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.blur_on),
          ),
        ],
      ),
      body: tabs[_index].screen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        destinations: [
          for (final tab in tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }

  List<_HomeTab> _tabsForRole(Role role) {
    switch (role) {
      case Role.lead:
        return [
          _HomeTab('Dashboard', Icons.dashboard, const DashboardScreen()),
          _HomeTab('Team Tasks', Icons.list_alt, const TasksScreen(scope: TaskScope.team)),
          _HomeTab('Workload', Icons.stacked_bar_chart, const WorkloadScreen()),
          _HomeTab('Alerts', Icons.notifications, const NotificationsScreen()),
          _HomeTab('Profile', Icons.person, const ProfileScreen()),
        ];
      case Role.manager:
      case Role.admin:
        return [
          _HomeTab('Dashboard', Icons.dashboard, const DashboardScreen()),
          _HomeTab('Projects', Icons.folder, const ProjectsScreen()),
          _HomeTab('Teams', Icons.group, const TeamsScreen()),
          _HomeTab('Settings', Icons.settings, const SettingsScreen()),
          _HomeTab('Alerts', Icons.notifications, const NotificationsScreen()),
          _HomeTab('Profile', Icons.person, const ProfileScreen()),
        ];
      case Role.user:
      default:
        return [
          _HomeTab('Dashboard', Icons.dashboard, const DashboardScreen()),
          _HomeTab('My Tasks', Icons.checklist, const TasksScreen(scope: TaskScope.mine)),
          _HomeTab('Alerts', Icons.notifications, const NotificationsScreen()),
          _HomeTab('Profile', Icons.person, const ProfileScreen()),
        ];
    }
  }
}

class _HomeTab {
  final String label;
  final IconData icon;
  final Widget screen;

  _HomeTab(this.label, this.icon, this.screen);
}
