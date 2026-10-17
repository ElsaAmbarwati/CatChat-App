import 'package:flutter/material.dart';
import '../pages/home_pages.dart';
import '../pages/chat_pages.dart';
import '../pages/dinding_doa_pages.dart';
import '../pages/journal_pages.dart';
import '../pages/mood_tracker.dart';
import '../pages/profile_pages.dart';
import '../pages/peer_chat_lobby_page.dart';

class NavigationSidebar extends StatelessWidget {
  final VoidCallback? onReturnFromDoa;
  final String selectedLabel;
  
  const NavigationSidebar({
    super.key, 
    this.onReturnFromDoa, 
    this.selectedLabel = 'Home',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7D8CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Catchat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3F3734),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE7D8CF), thickness: 1),
          const SizedBox(height: 16),
          _SidebarItem(
            label: 'Home', 
            selected: selectedLabel == 'Home',
            onTap: () {
               if (selectedLabel != 'Home') {
                 Navigator.of(context).pushAndRemoveUntil(
                   MaterialPageRoute(builder: (_) => const HomePages()),
                   (route) => false,
                 );
               }
            }
          ),
          _SidebarItem(
            label: 'Chat',
            selected: selectedLabel == 'Chat',
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    backgroundColor: const Color(0xFFFAF4F0),
                    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Pilih Tipe Chat',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF3F3734),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Kamu mau curhat ke siapa?',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7B6F65),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _ChatPickerOption(
                            icon: Icons.pets_rounded,
                            iconColor: const Color(0xFF5D4A45),
                            bgColor: const Color(0xFFE5D5CE),
                            title: 'Chat AI',
                            subtitle: 'Curhat ke teman AI yang selalu siap mendengarkan tanpa menghakimi.',
                            onTap: () {
                              Navigator.pop(context); // Tutup dialog
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChatPages()),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _ChatPickerOption(
                            icon: Icons.face_retouching_natural_rounded,
                            iconColor: const Color(0xFF5D4A45),
                            bgColor: const Color(0xFFF4B5A3),
                            title: 'Chat Anonim',
                            subtitle: 'Ngobrol anonim dengan pengguna lain secara acak.',
                            onTap: () {
                              Navigator.pop(context); // Tutup dialog
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PeerChatLobbyPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          _SidebarItem(
            label: 'Dinding Doa',
            selected: selectedLabel == 'Dinding Doa' || selectedLabel == 'Cerita Anonim',
            onTap: () async {
              if (selectedLabel == 'Dinding Doa' || selectedLabel == 'Cerita Anonim') return;
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DindingDoaPages()),
              );
              if (onReturnFromDoa != null) onReturnFromDoa!();
            },
          ),
          _SidebarItem(
            label: 'Statistik Mood',
            selected: selectedLabel == 'Statistik Mood' || selectedLabel == 'Mood Tracker',
            onTap: () {
              if (selectedLabel == 'Statistik Mood' || selectedLabel == 'Mood Tracker') return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MoodTracker()),
              );
            },
          ),
          _SidebarItem(
            label: 'Jurnal',
            selected: selectedLabel == 'Jurnal',
            onTap: () {
              if (selectedLabel == 'Jurnal') return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JournalPages()),
              );
            },
          ),
          _SidebarItem(
            label: 'Profil',
            selected: selectedLabel == 'Profil',
            onTap: () {
              if (selectedLabel == 'Profil') return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePages()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _SidebarItem({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF4B5A3) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF5D4A45) : const Color(0xFF7B6F65),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatPickerOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChatPickerOption({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE7D8CF)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F3734),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7B6F65),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF7B6F65)),
          ],
        ),
      ),
    );
  }
}
