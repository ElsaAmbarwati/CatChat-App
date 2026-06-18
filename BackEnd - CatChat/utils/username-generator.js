// Penjelasan file dan tujuannya:
// Nama file: username-generator.js
// Deskripsi: Mengatur logika server backend.
// Mengarahkan ke/Keterkaitan:
// Berhubungan dengan komponen backend lainnya.

/**
 * Random anonymous username generator
 * Ported from Flutter AuthService.generateAnonUsername()
 * Generates names like "Sophelia427", "Hiroshi831"
 */

const uniqueNames = [
  // Greek-inspired
  'Athenaïs', 'Calliope', 'Demetria', 'Elyssia', 'Phaedra',
  'Seraphina', 'Thalassa', 'Zephyrine', 'Lysandra', 'Nephele',
  'Ariadne', 'Cressida', 'Diantha', 'Eudora', 'Galatea',
  // Japanese-inspired
  'Haruki', 'Sakurako', 'Kazehana', 'Mizuki', 'Aozora',
  'Hikari', 'Tsubasa', 'Setsuna', 'Kaname', 'Ren',
  'Akira', 'Hinata', 'Kokoro', 'Yuuki', 'Sorata',
  // Korean-inspired
  'Chaewon', 'Dohyun', 'Eunji', 'Hajoon', 'Iseul',
  'Jiyeon', 'Minhee', 'Naeun', 'Seojin', 'Yeonwoo',
  'Dahlia', 'Haneul', 'Jiho', 'Mirae', 'Sora',
  // Nature/Mystical
  'Lumière', 'Celestine', 'Aurélien', 'Solène', 'Isolde',
  'Elowen', 'Orion', 'Cassius', 'Thalion', 'Silvaine',
];

/**
 * Generate a random anonymous username
 * @returns {string} - A random username like "Sophelia427"
 */
const generateUsername = () => {
  const name = uniqueNames[Math.floor(Math.random() * uniqueNames.length)];
  const number = Math.floor(Math.random() * 900) + 100; // 100-999
  return `${name}${number}`;
};

module.exports = { generateUsername };
