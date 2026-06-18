// Penjelasan file dan tujuannya:
// Nama file: profile_pages.dart
// Deskripsi: File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.
// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.

import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import 'create_pin_page.dart';
import 'landing_page.dart';



// ==========================================
// Class ProfilePages
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class ProfilePages extends StatefulWidget {
  const ProfilePages({super.key});

  @override
  State<ProfilePages> createState() => _ProfilePagesState();
}

class _ProfilePagesState extends State<ProfilePages> {
  final ProfileController _controller = ProfileController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Color(0xFFFBF6F2),
          body: Stack(
            children: [
              const _ProfileBackdrop(),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    children: [
                      _ProfileTopBar(
                        onBack: () => Navigator.of(context).pop(),
                        onAvatarTap: _openAvatarSheet,
                      ),
                      SizedBox(height: 14),
                      Expanded(child: _buildContent()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Color(0xFFE8DCD4)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A5D4A45),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: ListView(
          padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
          children: [
            _ProfileHero(
              selectedAvatarAsset: ProfileController.avatarAssets[_controller.selectedAvatarIndex],
              username: _controller.username,
            ),
            SizedBox(height: 16),
            _AvatarEditorCard(
              selectedAvatarAsset: ProfileController.avatarAssets[_controller.selectedAvatarIndex],
              avatarAssets: ProfileController.avatarAssets,
              onAvatarSelected: (index) {
                _controller.selectAvatar(index);
              },
            ),
            SizedBox(height: 24),
            _AccountSecuritySection(
              onChangePIN: _changePIN,
              onLogout: _logout,
              onDeleteAccount: _deleteAccount,
            ),
          ],

        ),
      ),
    );
  }

  void _openAvatarSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _AvatarSheet(
          selectedIndex: _controller.selectedAvatarIndex,
          avatarAssets: ProfileController.avatarAssets,
          onSelected: (index) {
            _controller.selectAvatar(index);
          },
        );
      },
    );
  }

  void _changePIN() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePinPage(isChanging: true),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF3F3734),
          ),
        ),
        content: Text(
          'Kamu akan keluar dari akun. Sesi login akan dihapus dan kamu perlu login ulang.',
          style: TextStyle(color: Color(0xFF7B6F65), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Color(0xFF7B6F65))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF4B5A3),
              foregroundColor: Color(0xFF5D4A45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Ya, Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _controller.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (_) => false,
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFD64545), size: 24),
            SizedBox(width: 8),
            Text(
              'Hapus Akun',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFFD64545),
              ),
            ),
          ],
        ),
        content: Text(
          'Semua data akunmu akan dihapus permanen dari perangkat ini termasuk riwayat chat, jurnal, dan pengaturan. Tindakan ini tidak bisa dibatalkan.',
          style: TextStyle(color: Color(0xFF7B6F65), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Color(0xFF7B6F65))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD64545),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus Permanen'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _controller.deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (_) => false,
      );
    }
  }
}

// Removed unused ProfileInsightCard


// ==========================================
// Class _ProfileBackdrop
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop();

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          _BackdropBlob(
            alignment: Alignment.topLeft,
            color: Color(0x33F4B5A3),
            size: 220,
          ),
          _BackdropBlob(
            alignment: Alignment.topRight,
            color: Color(0x22D7B9A8),
            size: 180,
          ),
          _BackdropBlob(
            alignment: Alignment.bottomCenter,
            color: Color(0x22C9DDD3),
            size: 240,
          ),
        ],
      ),
    );
  }
}


// ==========================================
// Class _BackdropBlob
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _BackdropBlob extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double size;

  const _BackdropBlob({
    required this.alignment,
    required this.color,
    required this.size,
  });

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}


// ==========================================
// Class _ProfileTopBar
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _ProfileTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAvatarTap;

  const _ProfileTopBar({required this.onBack, required this.onAvatarTap});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE8DCD4)),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFF7F1EE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.arrow_back, color: Color(0xFF5D4A45)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil Saya',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3F3734),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Identitas aman, personal, dan tetap anonim.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF6D5650),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          _IconActionButton(icon: Icons.portrait_rounded, onTap: onAvatarTap),
        ],
      ),
    );
  }
}


// ==========================================
// Class _IconActionButton
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconActionButton({required this.icon, required this.onTap});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFFF7F1EE),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: Color(0xFF5D4A45)),
        ),
      ),
    );
  }
}


// ==========================================
// Class _ProfileHero
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _ProfileHero extends StatelessWidget {
  final String selectedAvatarAsset;
  final String username;

  const _ProfileHero({
    required this.selectedAvatarAsset,
    required this.username,
  });

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDF7F3), Color(0xFFFFFBF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE8DCD4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF4B5A3),
                ),
                child: ClipOval(
                  child: Image.asset(selectedAvatarAsset, fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3F3734),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ini adalah ruang amanmu. Tidak ada identitas asli yang terhubung ke akun ini.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7B6F65),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ==========================================
// Class _AvatarEditorCard
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _AvatarEditorCard extends StatelessWidget {
  final String selectedAvatarAsset;
  final List<String> avatarAssets;
  final ValueChanged<int> onAvatarSelected;

  const _AvatarEditorCard({
    required this.selectedAvatarAsset,
    required this.avatarAssets,
    required this.onAvatarSelected,
  });

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F4F1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Color(0xFFE8DCD4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Avatar',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3F3734),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Pilih avatar dari aset pf untuk tetap anonim, tanpa unggah foto asli.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF7B6F65),
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFE6D8CF), width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(selectedAvatarAsset, fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Avatar yang dipilih hanya dari kumpulan gambar lokal pf1 sampai pf7. Ini menjaga identitas tetap konsisten dan tidak membuka data pribadi.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Color(0xFF6D5650),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(avatarAssets.length, (index) {
              final asset = avatarAssets[index];
              final isSelected = asset == selectedAvatarAsset;

              return GestureDetector(
                onTap: () => onAvatarSelected(index),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Color(0xFF5D4A45)
                          : Color(0xFFE6D8CF),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                  ),
                  child: ClipOval(child: Image.asset(asset, fit: BoxFit.cover)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}


// ==========================================
// Class _AvatarSheet
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _AvatarSheet extends StatelessWidget {
  final int selectedIndex;
  final List<String> avatarAssets;
  final ValueChanged<int> onSelected;

  const _AvatarSheet({
    required this.selectedIndex,
    required this.avatarAssets,
    required this.onSelected,
  });

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: Color(0xFFFBF6F2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Color(0xFFD9C8BE),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            SizedBox(height: 14),
            Text(
              'Pilih Avatar Anonim',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3F3734),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Avatar diambil dari asset lokal pf1 sampai pf7.',
              style: TextStyle(fontSize: 12, color: Color(0xFF7B6F65)),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: avatarAssets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () {
                    onSelected(index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Color(0xFF5D4A45)
                            : Color(0xFFE6D8CF),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        avatarAssets[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Removed unused classes

// ==========================================
// Class _AccountSecuritySection
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _AccountSecuritySection extends StatelessWidget {
  final VoidCallback onChangePIN;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const _AccountSecuritySection({
    required this.onChangePIN,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akun & Keamanan',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3F3734),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Kelola keamanan akun dan sesi login.',
          style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF7B6F65)),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8F4F1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Color(0xFFE8DCD4)),
          ),
          child: Column(children: [
            _AccountTile(icon: Icons.pin_rounded, iconBg: Color(0xFFF4B5A3), title: 'Ubah PIN', subtitle: 'Ganti PIN keamanan 6 digit', onTap: onChangePIN),
            const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE8DCD4)),
            _AccountTile(icon: Icons.logout_rounded, iconBg: Color(0xFFB0B8BE), title: 'Logout', subtitle: 'Keluar dari akun, sesi dihapus', onTap: onLogout),
            const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE8DCD4)),
            _AccountTile(icon: Icons.delete_forever_rounded, iconBg: Color(0xFFD64545), iconColor: Colors.white, title: 'Hapus Akun', subtitle: 'Hapus semua data secara permanen', titleColor: Color(0xFFD64545), onTap: onDeleteAccount),
          ]),
        ),
        SizedBox(height: 18),
      ],
    );
  }
}


// ==========================================
// Class _AccountTile
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _AccountTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _AccountTile({required this.icon, required this.iconBg, this.iconColor, required this.title, required this.subtitle, this.titleColor, required this.onTap});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: iconColor ?? Color(0xFF5D4A45)),
          ),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor ?? Color(0xFF3F3734))),
            SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Color(0xFF7B6F65))),
          ])),
          Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B8BE)),
        ]),
      ),
    );
  }
}
