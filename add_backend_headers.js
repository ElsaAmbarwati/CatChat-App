const fs = require('fs');
const path = require('path');

const walkSync = (dir, filelist = []) => {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        if (file === 'node_modules' || file === '.git' || file === 'build' || file === 'windows' || file === 'linux' || file === 'macos' || file === 'web' || file.startsWith('.')) continue;
        const filepath = path.join(dir, file);
        if (fs.statSync(filepath).isDirectory()) {
            filelist = walkSync(filepath, filelist);
        } else {
            if (filepath.endsWith('.js')) {
                // Skip the add_comments scripts to avoid touching them
                if (!filepath.includes('add_all_comments.js') && !filepath.includes('test_gemini.js')) {
                    filelist.push(filepath);
                }
            }
        }
    }
    return filelist;
};

const allJsFiles = walkSync('d:/Kuliah/PUI/AnonHeart/anonheart - Copy1/BackEnd - CatChat');

for (const file of allJsFiles) {
    let code = fs.readFileSync(file, 'utf8');
    const filename = path.basename(file);
    
    // Check if it already has the "Penjelasan file" header
    if (code.includes('Penjelasan file')) {
        continue;
    }
    
    let description = "Mengatur logika server backend.";
    let connection = "Berhubungan dengan komponen backend lainnya.";
    
    if (file.includes('controllers')) {
        description = "File ini adalah pengatur logika utama (otak) untuk fitur tertentu di sisi server.";
        connection = "- Mengarah ke Frontend: Menerima data (Request) dari HP pengguna dan mengirimkan balasan (Response).\n// - Berhubungan dengan Database: Membaca atau menyimpan data ke MySQL.\n// - Berhubungan dengan Routes: Dipanggil oleh rute yang sesuai.";
    } else if (file.includes('routes')) {
        description = "File ini bertugas sebagai 'pintu masuk' atau pengatur lalu lintas (router) URL API.";
        connection = "- Menerima permintaan dari Frontend.\n// - Mengarahkan (memanggil) fungsi spesifik yang ada di dalam folder controllers.";
    } else if (file.includes('server.js')) {
        description = "File utama yang menjalankan seluruh server Node.js.";
        connection = "- Menjalankan server di port tertentu.\n// - Menghubungkan seluruh folder routes agar bisa diakses oleh aplikasi Frontend.";
    } else if (file.includes('config') || file.includes('db')) {
        description = "File konfigurasi atau koneksi database.";
        connection = "- Digunakan oleh controller untuk terhubung ke MySQL.";
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

console.log("Selesai menambahkan header di seluruh Backend!");
