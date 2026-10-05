import 'package:flutter/material.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

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
              // Top Brand Bar: Logo and Location/Avatar
              _buildTopBar(),
              const SizedBox(height: 20),

              // Level & XP Progress
              _buildLevelProgress(),
              const SizedBox(height: 16),

              // 3D Avatar Centerstage with Action Buttons & Streak
              _buildAvatarStage(),
              const SizedBox(height: 24),

              // Daily Challenges
              _buildSectionTitle('DAILY CHALLENGES'),
              const SizedBox(height: 12),
              _buildDailyChallenges(),
              const SizedBox(height: 16),

              // Start Quick Workout CTA Button
              _buildStartQuickWorkoutButton(),
              const SizedBox(height: 24),

              // Your Progress Card
              _buildSectionTitle('YOUR PROGRESS'),
              const SizedBox(height: 12),
              _buildYourProgressCard(),
              const SizedBox(height: 24),

              // Leaderboard Section
              _buildLeaderboardSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand: Icon + Text
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFFC5A869), Color(0xFF7A6843)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'EloFit',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),

        // Location & Mini User Avatar
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'ALMATY, KAZAKHSTAN',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFC5A869), Color(0xFF7A6843)],
                ),
              ),
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFF2C3440),
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: Color(0xFFC5A869),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelProgress() {
    return Column(
      children: [
        const Text(
          'LEVEL 1',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'BEGINNER',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        // XP Progress Bar
        Container(
          width: 170,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E7CA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: 0.6,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC5A869), Color(0xFF7A6843)],
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'XP: 60/100',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Podium Glow
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: RadialGradient(
              colors: [
                const Color(0xFFC5A869).withValues(alpha: 0.18),
                Colors.transparent,
              ],
              radius: 0.75,
            ),
          ),
        ),

        // 3D Avatar representation
        Column(
          children: [
            Container(
              height: 180,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2C3440),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFC5A869).withValues(alpha: 0.35),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A6843).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.accessibility_new_rounded,
                  size: 90,
                  color: Color(0xFFC5A869),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Glowing circular base
            Container(
              width: 110,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(110, 12)),
                color: const Color(0xFFC5A869).withValues(alpha: 0.3),
              ),
            ),
          ],
        ),

        // Left button: CUSTOMIZE AVATAR
        Positioned(
          left: 4,
          top: 36,
          child: _buildSmallActionButton('CUSTOMIZE\nAVATAR'),
        ),

        // Right button: VIEW UPGRADES
        Positioned(
          right: 4,
          top: 36,
          child: _buildSmallActionButton('VIEW\nUPGRADES'),
        ),

        // Right Streak Badge
        Positioned(
          right: 10,
          bottom: 12,
          child: Column(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Color(0xFFE65100),
                size: 26,
              ),
              const SizedBox(height: 2),
              const Text(
                '7 DAY\nSTREAK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallActionButton(String text) {
    return Container(
      width: 86,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF2C3440),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: Colors.white,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDailyChallenges() {
    return const Row(
      children: [
        Expanded(
          child: _ChallengeCard(
            icon: Icons.directions_run_rounded,
            title: 'RUN 5 KM',
            points: 'POINTS: 50 ELO',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _ChallengeCard(
            icon: Icons.fitness_center_rounded,
            title: '15 MIN PLANK',
            points: 'POINTS: 50 ELO',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _ChallengeCard(
            icon: Icons.sports_gymnastics_rounded,
            title: 'GYM SESSION',
            points: 'POINTS: 50 ELO',
          ),
        ),
      ],
    );
  }

  Widget _buildStartQuickWorkoutButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF7A6843), Color(0xFFC5A869)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A6843).withValues(alpha: 0.3),
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
              'START QUICK WORKOUT',
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

  Widget _buildYourProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Activity Trackers
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildProgressRow(
                  icon: Icons.directions_run_rounded,
                  label: 'RUNNING',
                  value: '3.2km / 5.0km',
                  factor: 0.64,
                ),
                const SizedBox(height: 12),
                _buildProgressRow(
                  icon: Icons.fitness_center_rounded,
                  label: 'GYM',
                  value: '3 / 4 sets',
                  factor: 0.75,
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: Colors.black.withValues(alpha: 0.06),
          ),
          // Current ELO Card
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'CURRENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'ELO: 1250',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFC5A869),
                  size: 26,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow({
    required IconData icon,
    required String label,
    required String value,
    required double factor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.black54),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: factor,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [Color(0xFFC5A869), Color(0xFF7A6843)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LEADERBOARD',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        // Tabs: City, Country, World
        Row(
          children: [
            _buildLeaderboardTab('CITY (Almaty)', true),
            const SizedBox(width: 8),
            _buildLeaderboardTab('COUNTRY (Kazakhstan)', false),
            const SizedBox(width: 8),
            _buildLeaderboardTab('WORLD', false),
          ],
        ),
        const SizedBox(height: 12),
        // Top 1 Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Text(
                '1',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFC5A869),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF0EBE1),
                ),
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: Color(0xFF7A6843),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Almaty, Almaty',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Text(
                '3320',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab(String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2C3440) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? Colors.transparent : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: active ? Colors.white : Colors.black54,
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String points;

  const _ChallengeCard({
    required this.icon,
    required this.title,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            points,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
