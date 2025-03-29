import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'change_password_screen.dart';
import 'delete_confirmation_dialog_screen.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  final double _maxContentWidth = 800.0;
  final double _mobileBreakpoint = 600.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialiser le mode sombre en fonction du thème actuel
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
      // Mettre à jour la barre de statut
      SystemChrome.setSystemUIOverlayStyle(
        _isDarkMode
            ? SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        )
            : SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.builder(
      breakpoints: [
        const Breakpoint(start: 0, end: 450, name: MOBILE),
        const Breakpoint(start: 451, end: 800, name: TABLET),
        const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
      ],
      child: OrientationBuilder(
        builder: (context, orientation) {
          return _buildScaffold(context, orientation);
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, Orientation orientation) {
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE);
    final paddingValue = isMobile ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 20 : 24,
          ),
        ),
        backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.white,
        elevation: 0,
        centerTitle: false,
        shape: Border(
          bottom: BorderSide(
            color: _isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: paddingValue,
                vertical: paddingValue,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - paddingValue * 2,
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: _maxContentWidth,
                      ),
                      child: _buildSettingsContent(context),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          color: _isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            child: Column(
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.lock_outlined,
                  title: 'Changer le mot de passe',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(
                        userId: userProvider.userId,
                      ),
                    ),
                  ),
                  iconColor: Colors.blueGrey,
                ),
                const Divider(height: 1),
                _buildSettingsTile(
                  context,
                  icon: Icons.security_outlined,
                  title: 'Termes et conditions',
                  onTap: () {
                    // Implement navigation
                  },
                  iconColor: Colors.greenAccent,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: _isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            child: Column(
              children: [
                _buildThemeSwitchTile(context),
                const Divider(height: 1),
                _buildSettingsTile(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Supprimer le compte',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteConfirmationDialogScreen(),
                    ),
                  ),
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (!isMobile) ...[
          Text(
            'Version 1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isDarkMode ? Colors.grey[500] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildThemeSwitchTile(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _toggleTheme(!_isDarkMode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.brightness_4_outlined, color: Colors.blueGrey),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Mode sombre',
                style: TextStyle(
                  fontSize: 16,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch.adaptive(
                value: _isDarkMode,
                onChanged: _toggleTheme,
                activeColor: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        required Color iconColor,
        Color? textColor,
      }) {
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE);
    final iconSize = isMobile ? 20.0 : 24.0;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      splashColor: iconColor.withOpacity(0.1),
      highlightColor: iconColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: iconSize * 1.8,
              height: iconSize * 1.8,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  color: textColor ?? (_isDarkMode ? Colors.white : Colors.black),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: iconSize,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}