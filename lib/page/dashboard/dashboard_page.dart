import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_foodstore/bloc/auth_bloc.dart';
import 'package:flutter_foodstore/bloc/profile/profile_bloc.dart';
import 'package:flutter_foodstore/core/components/app_header.dart';
import 'package:flutter_foodstore/page/dashboard/home_page.dart' show AppColors;

class DashboardPage extends StatefulWidget {
  final Widget child;
  const DashboardPage({super.key, required this.child});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final tabs = [
    '/dashboard/home',
    '/dashboard/order',
    '/dashboard/cart',
    '/dashboard/profile',
  ];

  int currentIndex = 0;
  bool _profileRequested = false;

  final List<NavigationDestination> _appBarDestinations = const [
    NavigationDestination(
      selectedIcon: Icon(Icons.home, color: Colors.white),
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      selectedIcon: Icon(Icons.shopping_bag, color: Colors.white),
      icon: Icon(Icons.shopping_bag),
      label: 'My Orders',
    ),
    NavigationDestination(
      selectedIcon: Icon(Icons.shopping_cart, color: Colors.white),
      icon: Icon(Icons.shopping_cart),
      label: 'Cart',
    ),
    NavigationDestination(
      selectedIcon: Icon(Icons.person, color: Colors.white),
      icon: Icon(Icons.person),
      label: 'Account',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    final index = tabs.indexWhere((tab) => location.startsWith(tab));
    setState(() {
      currentIndex = index == -1 ? 0 : index;
    });

    // ✅ Ambil data profil sekali saja kalau user sudah login, biar nama
    // aslinya bisa langsung ditampilkan di header tanpa harus buka tab
    // Account dulu.
    final isLoggedIn = context.read<AuthBloc>().state is Authenticated;
    if (isLoggedIn && !_profileRequested) {
      _profileRequested = true;
      context.read<ProfileBloc>().add(const ProfileEvent.loadProfile());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthBloc>().state is Authenticated;
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final userName = profileState.maybeWhen(
          loadedProfile: (customer) => customer.name ?? 'User',
          orElse: () => isLoggedIn ? 'User' : 'Guest',
        );
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, isLoggedIn, userName),
          body: widget.child,
          extendBody: true,
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  /// ✅ Header custom (logo, search, notifikasi, profil) — sekarang pinned
  /// di atas (tidak ikut scroll), sesuai target desain.
  /// ⚠️ Nama user & jumlah notifikasi masih placeholder ("Guest" / 0).
  /// Ganti dengan data dari ProfileBloc begitu kamu tahu field-nya.
  PreferredSizeWidget _buildAppBar(
      BuildContext context, bool isLoggedIn, String userName) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(118),
      child: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 118,
        flexibleSpace: SafeArea(
          child: AppHeader(
            userName: userName,
            notificationCount: 0,
            onSearchSubmitted: (query) {
              if (query.isNotEmpty) {
                context.push('/search?query=$query');
              }
            },
            onNotificationTap: () {
              // TODO: sambungkan ke halaman notifikasi kalau sudah ada
            },
            onProfileTap: () {
              if (isLoggedIn) {
                context.go('/dashboard/profile');
              } else {
                context.go('/login');
              }
            },
            trailingAction: isLoggedIn ? _buildLogoutButton(context) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
        context.go('/login');
      },
      icon: const Icon(Icons.logout_rounded, size: 20),
      color: Colors.black54,
      tooltip: 'Logout',
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30.0,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.primary,
          ),
          child: NavigationBar(
            surfaceTintColor: Colors.white,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: currentIndex,
            backgroundColor: Colors.white,
            onDestinationSelected: (index) {
              setState(() => currentIndex = index);
              context.go(tabs[index]);
            },
            destinations: _appBarDestinations,
          ),
        ),
      ),
    );
  }
}