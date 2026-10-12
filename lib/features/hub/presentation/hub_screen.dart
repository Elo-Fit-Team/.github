import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/hub_provider.dart';
import '../../../providers/leaderboard_provider.dart';
import '../../../models/character_model.dart';
import '../../community/presentation/review_screen.dart';

class HubScreen extends StatefulWidget {
  final VoidCallback? onNavigateToWorkouts;
  const HubScreen({super.key, this.onNavigateToWorkouts});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  String _selectedScope = 'city'; // city, country, world

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hub = Provider.of<HubProvider>(context, listen: false);
      hub.loadInitial();
      final leaderboard = Provider.of<LeaderboardProvider>(context, listen: false);
      leaderboard.fetchLeaderboard();
    });
  }

  void _showCharacterSelectionSheet() {
    final hub = Provider.of<HubProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer<HubProvider>(
          builder: (context, hubState, _) {
            final myChars = hubState.myCharacters;
            final catalog = hubState.catalogCharacters;

            return SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ВАШИ ПЕРСОНАЖИ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Color(0xFF2C3440),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Прокачивается герой, выбранный при начале тренировки',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    if (myChars.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Пока нет открытых героев. Выберите бесплатного стартового ниже!',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: myChars.length,
                          itemBuilder: (context, index) {
                            final oc = myChars[index];
                            final isActive = hubState.hubData?.activeCharacter?.id == oc.id;
                            final specText = oc.character.specialty == 'strength' ? 'СИЛА' : 'ВЫНОСЛИВОСТЬ';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFFFDFBF7) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0xFFC5A869)
                                      : Colors.black.withValues(alpha: 0.08),
                                  width: isActive ? 2 : 1,
                                ),
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
                                    child: const Icon(
                                      Icons.shield_rounded,
                                      color: Color(0xFFC5A869),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          oc.character.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Ур. ${oc.progress.level} • $specText (+${oc.character.bonusPercent}%)',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          'Сила: ${oc.progress.strength} • Выносливость: ${oc.progress.endurance}',
                                          style: const TextStyle(fontSize: 10, color: Color(0xFF7A6843), fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC5A869),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'АКТИВЕН',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    )
                                  else
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2C3440),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      ),
                                      onPressed: () async {
                                        await hub.selectCharacter(oc.id);
                                        if (ctx.mounted) Navigator.pop(ctx);
                                      },
                                      child: const Text('ВЫБРАТЬ', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const Divider(),
                    const Text(
                      'КАТАЛОГ ГЕРОЕВ ДЛЯ ОТКРЫТИЯ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 115,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: catalog.length,
                        itemBuilder: (context, idx) {
                          final c = catalog[idx];
                          final isOwned = myChars.any((m) => m.character.id == c.id);

                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                ),
                                Text(
                                  c.isStarter ? 'Стартовый (Бесплатно)' : '${c.coinCost} монет',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF7A6843), fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                if (isOwned)
                                  const Text('В коллекции ✓', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))
                                else
                                  SizedBox(
                                    width: double.infinity,
                                    height: 28,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFC5A869),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () async {
                                        await hub.claimCharacter(c.id);
                                      },
                                      child: const Text('Открыть', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hub = Provider.of<HubProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final leaderboard = Provider.of<LeaderboardProvider>(context);

    final hubData = hub.hubData;
    final activeChar = hubData?.activeCharacter;
    final balances = hubData?.balances;
    final progress = activeChar?.progress;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFC5A869),
          onRefresh: () async {
            await hub.refreshHub();
            await leaderboard.fetchLeaderboard();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Brand Bar: Logo, Coins, ELO
                _buildTopBar(auth, balances),
                const SizedBox(height: 18),

                // Hero & Level Stage Card
                _buildHeroStageCard(activeChar, progress, balances),
                const SizedBox(height: 18),

                // Quick Workout CTA Button
                _buildStartQuickWorkoutButton(),
                const SizedBox(height: 14),

                // Peer Review Action Card
                _buildPeerReviewCard(),
                const SizedBox(height: 22),

                // Weekly Challenges
                _buildSectionTitle('ЕЖЕНЕДЕЛЬНЫЕ ЗАДАНИЯ'),
                const SizedBox(height: 12),
                _buildChallengesList(hub),
                const SizedBox(height: 22),

                // Stats & Progress Breakdown
                _buildSectionTitle('ХАРАКТЕРИСТИКИ ГЕРОЯ'),
                const SizedBox(height: 12),
                _buildAttributesCard(balances, progress),
                const SizedBox(height: 22),

                // Leaderboard Section
                _buildSectionTitle('ТАБЛИЦА ЛИДЕРОВ ПО АКТИВНОСТИ'),
                const SizedBox(height: 12),
                _buildLeaderboardSection(leaderboard),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AuthProvider auth, dynamic balances) {
    final coins = balances?.coins ?? 150;
    final elo = balances?.elo ?? 1200;
    final username = auth.currentUser?.displayName ?? 'Атлет';

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ELOFIT',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: Color(0xFF2C3440),
              ),
            ),
            Text(
              'Добро пожаловать, $username',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Coins Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_rounded, size: 16, color: Color(0xFFC5A869)),
              const SizedBox(width: 4),
              Text(
                '$coins',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // ELO Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3440),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFC5A869)),
              const SizedBox(width: 4),
              Text(
                'ELO $elo',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroStageCard(
    OwnedCharacterModel? activeChar,
    CharacterProgressModel? progress,
    dynamic balances,
  ) {
    final heroName = activeChar?.character.name ?? 'Каэл';
    final heroSpecialty = (activeChar?.character.specialty == 'endurance' ? 'ВЫНОСЛИВОСТЬ' : 'СИЛА');
    final level = progress?.level ?? 1;
    final xp = progress?.xp ?? 350;
    final nextXp = progress?.nextLevelXp ?? 600;
    final progressRatio = progress?.progressRatio ?? 0.58;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3440),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'УРОВЕНЬ $level',
                  style: const TextStyle(
                    color: Color(0xFFC5A869),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$xp / $nextXp XP',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black45),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: Color(0xFF7A6843)),
                label: const Text(
                  'Сменить героя',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF7A6843)),
                ),
                onPressed: _showCharacterSelectionSheet,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // XP Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 6,
              backgroundColor: const Color(0xFFF0EBE1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC5A869)),
            ),
          ),
          const SizedBox(height: 16),

          // Avatar & Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFDFBF7), Color(0xFFF0EBE1)],
                    ),
                    border: Border.all(color: const Color(0xFFC5A869), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC5A869).withValues(alpha: 0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_rounded,
                      size: 42,
                      color: Color(0xFF7A6843),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  heroName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFF2C3440),
                  ),
                ),
                Text(
                  'СПЕЦИАЛИЗАЦИЯ: $heroSpecialty (+10% К РАЗВИТИЮ)',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFFC5A869),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartQuickWorkoutButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3440), Color(0xFF1E242C)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (widget.onNavigateToWorkouts != null) {
              widget.onNavigateToWorkouts!();
            }
          },
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, color: Color(0xFFC5A869), size: 24),
                SizedBox(width: 8),
                Text(
                  'НАЧАТЬ ТРЕНИРОВКУ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeerReviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC5A869).withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC5A869).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReviewScreen()),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.how_to_vote_rounded, color: Color(0xFF7A6843), size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ПРОВЕРКА ТРЕНИРОВОК (PEER-REVIEW)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2C3440), letterSpacing: 0.5),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Голосуйте за честность тренировок атлетов сообщества',
                        style: TextStyle(fontSize: 10.5, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Color(0xFFC5A869)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildChallengesList(HubProvider hub) {
    final challenges = hub.challenges;
    if (challenges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: const Center(
          child: Text('Нет активных недельных заданий', style: TextStyle(fontSize: 12, color: Colors.black45)),
        ),
      );
    }

    return Column(
      children: challenges.take(3).map((c) {
        final completed = c.progress?.completedWorkouts ?? 2;
        final required = c.requiredWorkouts;
        final isClaimed = c.progress?.claimed ?? false;
        final canClaim = completed >= required && !isClaimed;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC5A869).withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.military_tech_rounded, color: Color(0xFF7A6843), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$completed из $required тренировок • +${c.coinReward} монет, +${c.xpReward} XP',
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (canClaim)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A869),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  onPressed: () => hub.claimWeekly(c.id),
                  child: const Text('ЗАБРАТЬ', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else if (isClaimed)
                const Text('ВЫПОЛНЕНО ✓', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900))
              else
                Text(
                  '${((completed / required) * 100).toInt()}%',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black45),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAttributesCard(dynamic balances, CharacterProgressModel? progress) {
    final str = balances?.strength ?? progress?.strength ?? 35;
    final end = balances?.endurance ?? progress?.endurance ?? 25;
    final flx = balances?.flexibility ?? progress?.flexibility ?? 15;
    final hp = progress?.health ?? 120;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAttrItem(Icons.favorite_rounded, 'HP (ЗДОРОВЬЕ)', '$hp', Colors.redAccent),
          _buildAttrItem(Icons.fitness_center_rounded, 'STR (СИЛА)', '$str', const Color(0xFF7A6843)),
          _buildAttrItem(Icons.directions_run_rounded, 'END (ВЫНОСЛ.)', '$end', Colors.blueGrey),
          _buildAttrItem(Icons.accessibility_new_rounded, 'FLX (ГИБКОСТЬ)', '$flx', Colors.teal),
        ],
      ),
    );
  }

  Widget _buildAttrItem(IconData icon, String label, String val, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black87)),
        Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Colors.black45)),
      ],
    );
  }

  Widget _buildLeaderboardSection(LeaderboardProvider leaderboard) {
    final rows = leaderboard.rows;

    return Column(
      children: [
        Row(
          children: [
            _buildTab('ГОРОД (Алматы)', _selectedScope == 'city', () {
              setState(() => _selectedScope = 'city');
              leaderboard.setScope('city');
            }),
            const SizedBox(width: 8),
            _buildTab('СТРАНА (Казахстан)', _selectedScope == 'country', () {
              setState(() => _selectedScope = 'country');
              leaderboard.setScope('country');
            }),
            const SizedBox(width: 8),
            _buildTab('МИР', _selectedScope == 'world', () {
              setState(() => _selectedScope = 'world');
              leaderboard.setScope('world');
            }),
          ],
        ),
        const SizedBox(height: 12),

        Column(
          children: rows.take(3).map((r) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Text(
                    '#${r.rank}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: r.rank == 1 ? const Color(0xFFC5A869) : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFFF0EBE1),
                    child: Text(
                      r.displayName[0],
                      style: const TextStyle(color: Color(0xFF7A6843), fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      r.displayName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                  ),
                  Text(
                    '${r.formattedScore} ELO',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2C3440) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? Colors.transparent : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}
