const fs = require('fs');
const path = require('path');

const walkSync = (dir, filelist = []) => {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        if (file === 'node_modules' || file === '.git' || file === 'build' || file === '.dart_tool' || file === 'windows' || file === 'linux' || file === 'macos' || file === 'web' || file.startsWith('.')) continue;
        const filepath = path.join(dir, file);
        if (fs.statSync(filepath).isDirectory()) {
            filelist = walkSync(filepath, filelist);
        } else {
            if (filepath.endsWith('.dart')) {
                filelist.push(filepath);
            }
        }
    }
    return filelist;
};

const allDartFiles = walkSync('d:/Kuliah/PUI/AnonHeart/anonheart - Copy1/FrontEnd - CatChat/lib/pages');

console.log(`Ditemukan ${allDartFiles.length} file Dart di folder pages. Mulai memberi komentar...`);

for (const file of allDartFiles) {
    let code = fs.readFileSync(file, 'utf8');
    let originalCode = code;

    // 1. Comment on Class definitions
    code = code.replace(/class\s+([A-Za-z0-9_]+)\s+extends\s+(StatelessWidget|StatefulWidget|GetxController)/g, 
        '\n// ==========================================\n// Class $1\n// Fungsi: Mendeklarasikan halaman/komponen visual ini.\n// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.\n// ==========================================\nclass $1 extends $2');

    // 2. Comment on build method
    code = code.replace(/Widget\s+build\(\s*BuildContext\s+context\s*\)\s*\{/g, 
        '\n  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.\n  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).\n  Widget build(BuildContext context) {');

    // 3. Comment on init method
    code = code.replace(/void\s+initState\(\)\s*\{/g, 
        '\n  // Fungsi initState: Dijalankan pertama kali saat halaman ini dibuka.\n  // Biasanya terhubung ke backend untuk mengambil data awal sebelum layar dimunculkan.\n  void initState() {');

    // 4. Comment on Get.to / Get.offAll (Routing)
    code = code.replace(/Get\.to\(\s*\(\)\s*=>\s*([A-Za-z0-9_]+)\(\)\s*\)/g, 
        '/* Navigasi: Mengarahkan pengguna pindah ke file layar $1 */ Get.to(() => $1())');
    
    code = code.replace(/Get\.offAll\(\s*\(\)\s*=>\s*([A-Za-z0-9_]+)\(\)\s*\)/g, 
        '/* Navigasi Reset: Menghapus riwayat layar dan pindah ke file layar $1 */ Get.offAll(() => $1())');

    // 5. Comment on Controller injection
    code = code.replace(/Get\.put\((.*?)\)/g, 
        '/* Inisialisasi: Menghubungkan file UI ini dengan logika di file Controller $1 */ Get.put($1)');
    
    code = code.replace(/Get\.find\((.*?)\)/g, 
        '/* Pencarian: Mencari Controller $1 yang sudah berjalan di memori */ Get.find($1)');

    // 6. Comment on API/HTTP calls if any
    code = code.replace(/http\.post\(/g, 
        '/* HTTP POST: Menghubungkan dan mengirim data dari layar ini ke file server/backend Node.js */ http.post(');
    code = code.replace(/http\.get\(/g, 
        '/* HTTP GET: Menghubungkan dan mengambil data dari file server/backend Node.js */ http.get(');

    if (code !== originalCode) {
        fs.writeFileSync(file, code, 'utf8');
        console.log(`✅ Sukses menambahkan komentar pada: ${path.basename(file)}`);
    } else {
        console.log(`⚠️ Tidak ada pola yang perlu diubah pada: ${path.basename(file)}`);
    }
}

console.log("SELESAI!");
