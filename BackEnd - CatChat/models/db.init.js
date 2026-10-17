// Penjelasan file dan tujuannya:
// Nama file: db.init.js
// Deskripsi: File konfigurasi atau koneksi database.
// Mengarahkan ke/Keterkaitan:
// - Digunakan oleh controller untuk terhubung ke MySQL.

const { createPoolWithoutDB } = require('../config/database');
require('dotenv').config();

const DB_NAME = process.env.DB_NAME || 'catchat';

const initializeDatabase = async () => {
  const tempPool = createPoolWithoutDB();

  try {
    // Create database if not exists
    await tempPool.query(`CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
    console.log(`✅ Database '${DB_NAME}' is ready`);

    // Use the database
    await tempPool.query(`USE \`${DB_NAME}\``);

    // Create users table
    await tempPool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        email_hash VARCHAR(64) NOT NULL UNIQUE,
        username VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        pin VARCHAR(255) DEFAULT NULL,
        avatar VARCHAR(50) DEFAULT 'pf1',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ Table "users" is ready');

    // Create stories table (Dinding Doa)
    await tempPool.query(`
      CREATE TABLE IF NOT EXISTS stories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        content TEXT NOT NULL,
        is_private TINYINT(1) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ Table "stories" is ready');

    // Create prayers table (Doa/Like)
    await tempPool.query(`
      CREATE TABLE IF NOT EXISTS prayers (
        id INT AUTO_INCREMENT PRIMARY KEY,
        story_id INT NOT NULL,
        user_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_prayer (story_id, user_id),
        FOREIGN KEY (story_id) REFERENCES stories(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ Table "prayers" is ready');

    // Create journals table
    await tempPool.query(`
      CREATE TABLE IF NOT EXISTS journals (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        title VARCHAR(255) DEFAULT NULL,
        content TEXT NOT NULL,
        mood VARCHAR(20) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ Table "journals" is ready');

    // Create chat_rooms table
    await tempPool.query(`
      CREATE TABLE IF NOT EXISTS chat_rooms (
        id VARCHAR(36) PRIMARY KEY,
        user1_id INT NOT NULL,
        user2_id INT NOT NULL,
        user1_alias VARCHAR(50),
        user2_alias VARCHAR(50),
        topic VARCHAR(50) DEFAULT 'bebas',
        status ENUM('active','ended','waiting') DEFAULT 'waiting',
        consent_status ENUM('none','pending_user1','pending_user2','accepted','rejected') DEFAULT 'none',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        ended_at TIMESTAMP NULL,
        FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ Table "chat_rooms" is ready');

    // Create peer_messages table
    await tempPool.query(`
      CREATE TABLE IF NOT EXISTS peer_messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        room_id VARCHAR(36) NOT NULL,
        sender_id INT NOT NULL,
        text TEXT NOT NULL,
        type ENUM('text','system','consent_request') DEFAULT 'text',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
        FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ Table "peer_messages" is ready');

    // Create reports table
    await tempPool.query(`
      CREATE TABLE IF NOT EXISTS reports (
        id INT AUTO_INCREMENT PRIMARY KEY,
        reporter_id INT,
        reported_id INT,
        room_id VARCHAR(36),
        reason VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (reported_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ Table "reports" is ready');

    // Create blocked_users table
    await tempPool.query(`
      CREATE TABLE IF NOT EXISTS blocked_users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        blocker_id INT,
        blocked_id INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_block (blocker_id, blocked_id),
        FOREIGN KEY (blocker_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (blocked_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ Table "blocked_users" is ready');

    console.log('🎉 All database tables initialized successfully!');
  } catch (error) {
    console.error('❌ Database initialization failed:', error.message);
    throw error;
  } finally {
    await tempPool.end();
  }
};

module.exports = { initializeDatabase };
