import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/leaderboard_provider.dart';

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeaderboardProvider>(context, listen: false).fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LeaderboardProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFC5A869),
          onRefresh: lp.fetchLeaderboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const Text(
                  'СОРЕВНОВАНИЯ И РЕЙТИНГ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Color(0xFF2C3440),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Рейтинг пересчитывается автоматически после подтверждения тренировок сообществом',
                  style: TextStyle(fontSize: 11, color: Colors.black45, height: 1.3),
                ),
                const SizedBox(height: 18),

                // Metric Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      _buildMetricTab('Активность ELO', lp.metric == 'elo', () => lp.setMetric('elo')),
                      _buildMetricTab('Абсолютная сила', lp.metric == 'absolute', () => lp.setMetric('absolute')),
                      _buildMetricTab('Относительная', lp.metric == 'relative', () => lp.setMetric('relative')),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Scope Selector: City / Country / World
                Row(
                  children: [
                    _buildScopePill('г. Алматы', lp.scope == 'city', () => lp.setScope('city')),
                    const SizedBox(width: 8),
                    _buildScopePill('Казахстан', lp.scope == 'country', () => lp.setScope('country')),
                    const SizedBox(width: 8),
                    _buildScopePill('Мировой зачёт', lp.scope == 'world', () => lp.setScope('world')),
                  ],
                ),
                const SizedBox(height: 20),

                // Rankings List
                if (lp.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFFC5A869))),
                  )
                else if (lp.rows.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: const Center(
                      child: Text('В данном зачёте пока нет участников.', style: TextStyle(color: Colors.black45)),
                    ),
                  )
                else
                  Column(
                    children: lp.rows.map((row) {
                      final isTop3 = row.rank <= 3;
                      Color badgeColor = Colors.black45;
                      if (row.rank == 1) badgeColor = const Color(0xFFC5A869);
                      if (row.rank == 2) badgeColor = Colors.blueGrey;
                      if (row.rank == 3) badgeColor = const Color(0xFFCD7F32);

                      String scoreUnit = 'ELO';
                      if (lp.metric == 'absolute') scoreUnit = 'кг';
                      if (lp.metric == 'relative') scoreUnit = 'коэф.';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isTop3 ? const Color(0xFFFDFBF7) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isTop3
                                ? const Color(0xFFC5A869).withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.05),
                            width: isTop3 ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Rank Number
                            Container(
                              width: 32,
                              alignment: Alignment.center,
                              child: Text(
                                '#${row.rank}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Avatar
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF2C3440),
                              child: Text(
                                row.displayName.isNotEmpty ? row.displayName[0].toUpperCase() : 'А',
                                style: const TextStyle(color: Color(0xFFC5A869), fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Name & Location
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    row.displayName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    row.city ?? 'Казахстан',
                                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                                  ),
                                ],
                              ),
                            ),
                            // Score
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  row.formattedScore,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2C3440),
                                  ),
                                ),
                                Text(
                                  scoreUnit,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFC5A869),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTab(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2C3440) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScopePill(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFC5A869) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? Colors.transparent : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}
