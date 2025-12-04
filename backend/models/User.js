const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true }, // In prod, hash this!
    name: { type: String, required: true },
    role: { type: String, enum: ['admin', 'receptionist'], default: 'receptionist' }
});

module.exports = mongoose.model('User', userSchema);
