// Penjelasan file dan tujuannya:
// Nama file: alias-generator.js
// Deskripsi: Menghasilkan alias anonim acak untuk fitur Ruang Curhat.
// Mengarahkan ke/Keterkaitan:
// - Digunakan oleh socket handler untuk memberi nama sementara pada pengguna.

const generateAlias = () => {
  const adjectives = [
    'Biru', 'Putih', 'Ungu', 'Merah', 'Perak',
    'Hitam', 'Kuning', 'Hijau', 'Emas', 'Cokelat',
    'Ceria', 'Sedih', 'Berani', 'Misterius', 'Ramah'
  ];

  const nouns = [
    'Kucing', 'Awan', 'Bintang', 'Kelinci', 'Bulan',
    'Burung', 'Pohon', 'Gunung', 'Sungai', 'Angin',
    'Bunga', 'Harimau', 'Beruang', 'Serigala', 'Kupu-kupu'
  ];

  const randomAdjective = adjectives[Math.floor(Math.random() * adjectives.length)];
  const randomNoun = nouns[Math.floor(Math.random() * nouns.length)];

  return `${randomNoun} ${randomAdjective}`;
};

module.exports = { generateAlias };
