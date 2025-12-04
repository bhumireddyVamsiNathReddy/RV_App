const mongoose = require('mongoose');

const billSchema = new mongoose.Schema({
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer' },
    customerName: String,
    customerMobile: String,
    items: [{
        type: { type: String, enum: ['service', 'product'] },
        id: String,
        name: String,
        price: Number,
        quantity: { type: Number, default: 1 },
        employeeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Employee' },
        employeeName: String
    }],
    subtotal: Number,
    discount: Number,
    tax: Number,
    totalAmount: Number,
    status: { type: String, enum: ['pending', 'completed'], default: 'completed' },
    paymentMethod: { type: String, enum: ['Cash', 'Card', 'UPI'], default: 'Cash' },
    createdAt: { type: Date, default: Date.now },
    completedAt: Date
});

module.exports = mongoose.model('Bill', billSchema);
