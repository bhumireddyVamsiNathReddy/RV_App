require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/rv_salon')
    .then(async () => {
        console.log('✅ Connected to MongoDB');

        // Drop legacy index if exists
        try {
            await User.collection.dropIndex('username_1');
            console.log('✅ Dropped legacy username index');
        } catch (e) {
            // Index might not exist, ignore
        }

        const adminExists = await User.findOne({ email: 'admin@rvsalon.com' });
        if (!adminExists) {
            await User.create({
                name: 'Admin User',
                email: 'admin@rvsalon.com',
                password: 'admin123', // In a real app, hash this!
                role: 'admin'
            });
            console.log('✅ Admin user created: admin@rvsalon.com / admin123');
        } else {
            console.log('ℹ️ Admin user already exists');
        }

        const receptionistExists = await User.findOne({ email: 'user@rvsalon.com' });
        if (!receptionistExists) {
            await User.create({
                name: 'Receptionist',
                email: 'user@rvsalon.com',
                password: 'user123',
                role: 'receptionist'
            });
            console.log('✅ Receptionist user created: user@rvsalon.com / user123');
        } else {
            console.log('ℹ️ Receptionist user already exists');
        }

        mongoose.connection.close();
    })
    .catch(err => {
        console.error('❌ Error:', err);
        process.exit(1);
    });
