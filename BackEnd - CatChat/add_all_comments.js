const fs = require('fs');
const path = require('path');
const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config({ path: 'd:/Kuliah/PUI/AnonHeart/anonheart - Copy1/BackEnd - CatChat/.env' });

const API_KEY = process.env.GEMINI_API_KEY;
if (!API_KEY) {
    console.error("GEMINI_API_KEY tidak ditemukan!");
    process.exit(1);
}

const genAI = new GoogleGenerativeAI(API_KEY);
const model = genAI.getGenerativeModel({ 
    model: "gemini-2.5-flash-lite", 
    systemInstruction: "Kamu adalah asisten programmer. Tugasmu HANYA menyisipkan komentar penjelasan berbahasa Indonesia (menggunakan //) pada kode yang diberikan. Jelaskan apa fungsi dari setiap blok kode, gunanya apa, dan akan mengarahkan/berhubungan ke mana. PENTING: KEMBALIKAN SELURUH KODE ASLI TANPA DIUBAH ATAU DIHAPUS SEDIKITPUN. HANYA TAMBAHKAN KOMENTAR PENJELASAN. JANGAN gunakan block markdown ``` di awal/akhir output. Jangan menghapus kode mati apapun, pertahankan 100% kode asli."
});

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const walkSync = (dir, filelist = []) => {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        if (file === 'node_modules' || file === '.git' || file === 'build' || file === '.dart_tool' || file === 'windows' || file === 'linux' || file === 'macos' || file === 'web' || file.startsWith('.')) continue;
        const filepath = path.join(dir, file);
        if (fs.statSync(filepath).isDirectory()) {
            filelist = walkSync(filepath, filelist);
        } else {
            if (filepath.endsWith('.js') || filepath.endsWith('.dart')) {
                if (!filepath.includes('add_all_comments.js') && !filepath.includes('test_gemini.js')) {
                    filelist.push(filepath);
                }
            }
        }
    }
    return filelist;
};

const allFiles = [
    ...walkSync('d:/Kuliah/PUI/AnonHeart/anonheart - Copy1/FrontEnd - CatChat/lib'),
    ...walkSync('d:/Kuliah/PUI/AnonHeart/anonheart - Copy1/BackEnd - CatChat/controllers'),
    ...walkSync('d:/Kuliah/PUI/AnonHeart/anonheart - Copy1/BackEnd - CatChat/routes')
];

async function processFiles() {
    console.log(`Ditemukan ${allFiles.length} file untuk diproses. Mulai...`);
    for (let i = 0; i < allFiles.length; i++) {
        const file = allFiles[i];
        console.log(`[${i+1}/${allFiles.length}] Memproses: ${file}`);
        try {
            const originalCode = fs.readFileSync(file, 'utf8');
            if (originalCode.trim() === '') continue;
            
            // Skip files that seem too long for safe processing to avoid truncation
            if (originalCode.length > 20000) {
                console.log(`⚠️ Skip karena file terlalu panjang: ${file}`);
                continue;
            }

            const prompt = `Tambahkan penjelasan singkat tentang codingannya, gunanya apa, dan akan mengarahkan/berhubungan ke mana. Sisipkan sebagai inline comment (//) di setiap baris/blok penting pada kode ini. JANGAN MENGHAPUS ATAU MENGUBAH KODE ASLI SEDIKITPUN!\n\nKode Asli:\n${originalCode}`;
            
            const result = await model.generateContent(prompt);
            let newCode = result.response.text().trim();
            newCode = newCode.replace(/^```[a-z]*\n/i, '').replace(/```$/i, '').trim();
            
            // Safety check: Ensure we didn't lose significant code
            if (newCode.length >= originalCode.length * 0.9) {
                fs.writeFileSync(file, newCode, 'utf8');
                console.log(`✅ Sukses: ${file}`);
            } else {
                console.log(`⚠️ Hasil terlalu pendek (potensi terpotong), skip: ${file}`);
            }
            
            // Wait 2 seconds between requests
            await sleep(2000);
        } catch (e) {
            console.error(`❌ Error pada ${file}: ${e.message}`);
            if (e.message.includes('429')) {
                console.log('Limit tercapai, menunggu 10 detik...');
                await sleep(10000);
                i--; // retry this file
            }
        }
    }
    console.log("🔥 PROSES SELESAI SEMUANYA!");
}

processFiles();
