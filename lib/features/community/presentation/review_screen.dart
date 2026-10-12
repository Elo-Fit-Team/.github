import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // Demo mock review cards so the professor/user can test voting immediately!
  final List<Map<String, dynamic>> _demoReviews = [
    {
      'id': 'res-101',
      'athlete': 'Тимур Сабиров',
      'city': 'Алматы',
      'exercise': 'Жим штанги лёжа',
      'metrics': '100.00 кг • 5 повторений',
      'video_time': '00:00 - 00:45',
      'status': 'На проверке',
      'votes_count': 3,
      'min_votes': 5,
      'approval_percent': 100,
      'my_vote': null,
    },
    {
      'id': 'res-102',
      'athlete': 'Айдар Касымов',
      'city': 'Астана',
      'exercise': 'Присед со штангой',
      'metrics': '140.00 кг • 3 повторения',
      'video_time': '00:10 - 01:05',
      'status': 'На проверке',
      'votes_count': 4,
      'min_votes': 5,
      'approval_percent': 75,
      'my_vote': null,
    },
    {
      'id': 'res-103',
      'athlete': 'Диана Маликова',
      'city': 'Алматы',
      'exercise': 'Бег на дистанцию',
      'metrics': '5 000 м • 22:30 мин',
      'video_time': 'GPS-трек подтверждён',
      'status': 'На проверке',
      'votes_count': 2,
      'min_votes': 5,
      'approval_percent': 100,
      'my_vote': null,
    },
  ];

  void _castVote(int index, bool isApproved) {
    setState(() {
      final item = _demoReviews[index];
      item['votes_count'] = (item['votes_count'] as int) + 1;
      item['my_vote'] = isApproved;
      if (item['votes_count'] >= 5) {
        item['status'] = isApproved ? 'Подтверждено (+50 ELO)' : 'Отклонено';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2C3440),
        content: Text(
          isApproved
              ? 'Голос «Честно» принят! Атлету будет начислен рейтинг ELO.'
              : 'Голос «Отклонить» принят. Замечание отправлено автору.',
        ),
      ),
    );
  }

  void _showRejectDialog(int index) {
    String selectedReason = 'weight_not_visible';
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Причина отклонения', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'По правилам EloFit для отклонения результата требуется указать объективную причину и комментарий:',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedReason,
                decoration: const InputDecoration(labelText: 'Причина', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'weight_not_visible', child: Text('Не видна маркировка веса')),
                  DropdownMenuItem(value: 'incomplete', child: Text('Неполная амплитуда движения')),
                  DropdownMenuItem(value: 'edited_video', child: Text('Признаки видеомонтажа / склейки')),
                  DropdownMenuItem(value: 'wrong_metrics', child: Text('Несоответствие повторений')),
                  DropdownMenuItem(value: 'other', child: Text('Другое нарушение техники')),
                ],
                onChanged: (val) {
                  if (val != null) setDlgState(() => selectedReason = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Комментарий к видео',
                  hintText: 'Укажите таймкод или детали...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(ctx);
                _castVote(index, false);
              },
              child: const Text('Отклонить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: const Text(
          'ПРОВЕРКА ТРЕНИРОВОК (PEER-REVIEW)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: Color(0xFF2C3440)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Rule Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC5A869).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF7A6843), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Как работает честное подтверждение:',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF2C3440)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Для одобрения требуется 5 независимых голосов атлетов и минимум 80% подтверждений. Проверяющие получают монеты и репутацию.',
                          style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'ОЧЕРЕДЬ НА ПРОВЕРКУ:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: Colors.black54),
            ),
            const SizedBox(height: 12),

            ..._demoReviews.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final votes = item['votes_count'] as int;
              final minVotes = item['min_votes'] as int;
              final myVote = item['my_vote'] as bool?;
              final isDecided = votes >= minVotes;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Athlete Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF2C3440),
                          child: Text(
                            (item['athlete'] as String)[0],
                            style: const TextStyle(color: Color(0xFFC5A869), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['athlete'],
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black87),
                              ),
                              Text(
                                '${item['city']} • Видеозапись подхода',
                                style: const TextStyle(fontSize: 10, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDecided ? Colors.green.withValues(alpha: 0.15) : const Color(0xFFF0EBE1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['status'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDecided ? Colors.green : const Color(0xFF7A6843),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Exercise & Metrics
                    Text(
                      item['exercise'],
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF2C3440)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['metrics'],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFC5A869)),
                    ),
                    const SizedBox(height: 10),

                    // Mock Video Player Banner
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E242C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFC5A869), size: 48),
                          Positioned(
                            bottom: 8,
                            left: 10,
                            child: Text(
                              'Таймкод: ${item['video_time']}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Voting progress bar
                    Row(
                      children: [
                        Text('Голоса: $votes из $minVotes', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                        const Spacer(),
                        Text('Одобрение: ${item['approval_percent']}%', style: const TextStyle(fontSize: 11, color: Colors.black45)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (votes / minVotes).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF0EBE1),
                        valueColor: AlwaysStoppedAnimation<Color>(isDecided ? Colors.green : const Color(0xFFC5A869)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Action buttons
                    if (myVote != null)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          myVote ? 'Вы подтвердили эту тренировку ✓' : 'Вы отклонили этот подход ✕',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: myVote ? Colors.green : Colors.redAccent,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              icon: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
                              label: const Text('Отклонить', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () => _showRejectDialog(idx),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC5A869),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                              label: const Text('Подтвердить', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () => _castVote(idx, true),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
