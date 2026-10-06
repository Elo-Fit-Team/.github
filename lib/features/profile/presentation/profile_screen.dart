import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Title
              const Text(
                'PROFILE & SETTINGS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // User Info Card
              _buildUserHeaderCard(),
              const SizedBox(height: 16),

              // Edit Profile Button
              _buildEditProfileButton(),
              const SizedBox(height: 28),

              // Section: Profile Settings
              _buildSectionHeader('PROFILE SETTINGS'),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _SettingsTileItem(
                  icon: Icons.person_outline,
                  title: 'Account',
                  onTap: () {},
                ),
                _SettingsTileItem(
                  icon: Icons.link,
                  title: 'Linked Apps',
                  subtitle: 'Apple Health/Google Fit',
                  onTap: () {},
                ),
                _SettingsTileItem(
                  icon: Icons.shield_outlined,
                  title: 'Security',
                  showDivider: false,
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),

              // Section: History & Achievements
              _buildSectionHeader('HISTORY & ACHIEVEMENTS'),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _SettingsTileItem(
                  icon: Icons.history,
                  title: 'Workout History',
                  onTap: () {},
                ),
                _SettingsTileItem(
                  icon: Icons.emoji_events_outlined,
                  title: 'Achievements earned',
                  showDivider: false,
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),

              // Section: My Avatar
              _buildSectionHeader('MY AVATAR'),
              const SizedBox(height: 12),
              _buildAvatarCard(),
              const SizedBox(height: 16),

              // Section: Upgrade Account
              _buildUpgradeCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with golden border
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFC5A869), Color(0xFF7A6843)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: const Color(0xFFE8E8EE),
              child: ClipOval(
                child: Container(
                  color: const Color(0xFF2C3440),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFFC5A869),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ALMATY, KAZAKHSTAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'LEVEL 1 BEGINNER',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFC5A869),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '1250',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ELO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF7A6843), Color(0xFFC5A869)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A6843).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: const Center(
            child: Text(
              'EDIT PROFILE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingsTileItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) => _buildSettingsTile(item)).toList(),
      ),
    );
  }

  Widget _buildSettingsTile(_SettingsTileItem item) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              color: Colors.black87,
              size: 20,
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: item.subtitle != null
              ? Text(
                  item.subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                )
              : null,
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.black26,
            size: 22,
          ),
          onTap: item.onTap,
        ),
        if (item.showDivider)
          Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: Colors.black.withOpacity(0.05),
          ),
      ],
    );
  }

  Widget _buildAvatarCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3440),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.accessibility_new_rounded,
                color: Color(0xFFC5A869),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Access to the same 3D model customization and upgrades',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                height: 1.35,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.black26,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFC5A869).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC5A869).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFC5A869).withOpacity(0.2),
              ),
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: Color(0xFF7A6843),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'UPGRADE ACCOUNT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.black26,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _SettingsTileItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool showDivider;
  final VoidCallback onTap;

  _SettingsTileItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.showDivider = true,
    required this.onTap,
  });
}
