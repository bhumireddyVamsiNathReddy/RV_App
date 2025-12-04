const mongoose = require('mongoose');

const employeeSchema = new mongoose.Schema({
    name: { type: String, required: true },
    specialty: { type: String, default: 'General' },
    phone: String,
    active: { type: Boolean, default: true }
});

module.exports = mongoose.model('Employee', employeeSchema);
