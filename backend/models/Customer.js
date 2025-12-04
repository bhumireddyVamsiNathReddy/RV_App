const mongoose = require('mongoose');

const customerSchema = new mongoose.Schema({
    name: { type: String, required: true },
    mobile: { type: String, required: true, unique: true },
    gender: { type: String, enum: ['Male', 'Female', 'Other'], default: 'Other' },
    email: String,
    lastVisit: Date,
    totalVisits: { type: Number, default: 0 },
    totalSpent: { type: Number, default: 0 }
});

module.exports = mongoose.model('Customer', customerSchema);
