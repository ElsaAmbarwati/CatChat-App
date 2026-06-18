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

const allDartFiles = walkSync('d:/Kuliah/PUI/AnonHeart/anonheart - Copy1/FrontEnd - CatChat/lib');

for (const file of allDartFiles) {
    let code = fs.readFileSync(file, 'utf8');
    const filename = path.basename(file);
    
    // Check if it already has the "Penjelasan file" header
    if (code.includes('Penjelasan file')) {
        continue;
    }
    
    let description = "Mengelola logika dan tampilan layar.";
    let connection = "Berhubungan dengan komponen atau controller lain dalam aplikasi.";
    
    if (file.includes('pages')) {
        description = "File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.";
        connection = "- Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.\n// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.";
    } else if (file.includes('controllers')) {
        description = "File ini adalah pengatur logika (otak) di balik layar UI.";
        connection = "- Mengarah ke Backend/Service: Memanggil API melalui jaringan untuk mengambil/menyimpan data.\n// - Berhubungan dengan Layar: Data dari sini akan ditampilkan ke layar UI (pages).";
    } else if (file.includes('services')) {
        description = "File ini mengatur komunikasi dengan pihak luar (seperti Backend Server atau memori HP lokal).";
        connection = "- Mengarah ke Backend: Mengirim HTTP Request ke Node.js.\n// - Berhubungan dengan Controller: Menyediakan data mentah yang akan diolah oleh file Controller.";
    } else if (file.includes('models')) {
        description = "File ini mengatur cetakan bentuk data (struktur data).";
        connection = "- Digunakan oleh Controller dan Service untuk membungkus data agar rapi.";
    }

    const header = `// Penjelasan file dan tujuannya:
// Nama file: ${filename}
// Deskripsi: ${description}
// Mengarahkan ke/Keterkaitan:
// ${connection}

`;

    // Strip out the generic /** @file ... */ if it exists
    code = code.replace(/\/\*\*\s*\n\s*\*\s*@file[\s\S]*?\*\/\n/m, '');
    
    // Prepend the header
    fs.writeFileSync(file, header + code, 'utf8');
    console.log(`✅ Header ditambahkan ke: ${filename}`);
}

console.log("Selesai menambahkan header di seluruh Frontend!");
