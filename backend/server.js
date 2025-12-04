require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/rv_salon')
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => console.error('❌ MongoDB Connection Error:', err));

// --- MODELS ---
const User = require('./models/User');
const Customer = require('./models/Customer');
const Service = require('./models/Service');
const Product = require('./models/Product');
const Employee = require('./models/Employee');
const Bill = require('./models/Bill');

// --- ROUTES ---

// Auth
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email, password });
    if (!user) return res.status(401).json({ message: 'Invalid credentials' });
    res.json({
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      token: 'mock-jwt-token-' + user._id // In prod, use real JWT
    });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// Customers
app.get('/api/customers', async (req, res) => {
  try {
    const { search } = req.query;
    let query = {};

    if (search) {
      query = {
        $or: [
          { name: { $regex: search, $options: 'i' } },
          { mobile: { $regex: search, $options: 'i' } }
        ]
      };
    }

    const customers = await Customer.find(query).sort({ lastVisit: -1 });
    res.json(customers);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/customers', async (req, res) => {
  try {
    const customer = new Customer(req.body);
    await customer.save();
    res.json(customer);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// Services
app.get('/api/services', async (req, res) => {
  try {
    const services = await Service.find();
    res.json(services);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/services', async (req, res) => {
  try {
    const service = new Service(req.body);
    await service.save();
    res.json(service);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.put('/api/services/:id', async (req, res) => {
  try {
    const service = await Service.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(service);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/api/services/:id', async (req, res) => {
  try {
    await Service.findByIdAndDelete(req.params.id);
    res.json({ message: 'Service deleted' });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// Products
app.get('/api/products', async (req, res) => {
  try {
    const products = await Product.find();
    res.json(products);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/products', async (req, res) => {
  try {
    const product = new Product(req.body);
    await product.save();
    res.json(product);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.put('/api/products/:id', async (req, res) => {
  try {
    const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(product);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/api/products/:id', async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ message: 'Product deleted' });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// Employees
app.get('/api/employees', async (req, res) => {
  try {
    const employees = await Employee.find({ active: true });
    res.json(employees);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/employees', async (req, res) => {
  try {
    const employee = new Employee(req.body);
    await employee.save();
    res.json(employee);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.put('/api/employees/:id', async (req, res) => {
  try {
    const employee = await Employee.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(employee);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/api/employees/:id', async (req, res) => {
  try {
    await Employee.findByIdAndDelete(req.params.id);
    res.json({ message: 'Employee deleted' });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// Bills
app.get('/api/bills', async (req, res) => {
  try {
    const { status, date } = req.query;
    let query = {};
    if (status) query.status = status;
    if (date) {
      const start = new Date(date);
      start.setHours(0, 0, 0, 0);
      const end = new Date(date);
      end.setHours(23, 59, 59, 999);
      query.createdAt = { $gte: start, $lte: end };
    }
    const bills = await Bill.find(query).sort({ createdAt: -1 });
    res.json(bills);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/bills', async (req, res) => {
  try {
    console.log('Received bill data:', JSON.stringify(req.body, null, 2));

    // Calculate total if missing or 0
    if (!req.body.totalAmount || req.body.totalAmount === 0) {
      const items = req.body.items || [];
      const subtotal = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
      req.body.subtotal = subtotal;
      req.body.totalAmount = subtotal - (req.body.discount || 0) + (req.body.tax || 0);
      console.log('Calculated total:', req.body.totalAmount);
    }

    const bill = new Bill(req.body);
    if (bill.status === 'completed') {
      bill.completedAt = new Date();

      // Update customer stats
      await Customer.findByIdAndUpdate(bill.customerId, {
        $inc: { totalVisits: 1, totalSpent: bill.totalAmount },
        $set: { lastVisit: new Date() }
      });

      // Update product stock
      for (const item of bill.items) {
        if (item.type === 'product') {
          await Product.findByIdAndUpdate(item.id, { $inc: { stock: -item.quantity } });
        }
      }
    }
    await bill.save();
    res.json(bill);
  } catch (e) {
    console.error('Error creating bill:', e);
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/bills/:id/complete', async (req, res) => {
  try {
    const bill = await Bill.findById(req.params.id);
    if (!bill) return res.status(404).json({ message: 'Bill not found' });

    bill.status = 'completed';
    bill.completedAt = new Date();
    bill.paymentMethod = req.body.paymentMethod || 'Cash';
    await bill.save();

    // Update stats (same as above)
    await Customer.findByIdAndUpdate(bill.customerId, {
      $inc: { totalVisits: 1, totalSpent: bill.totalAmount },
      $set: { lastVisit: new Date() }
    });

    res.json(bill);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// Reports
app.use('/api/reports', require('./routes/reports'));

// Dashboard Stats
app.get('/api/dashboard/stats', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    let filterStart, filterEnd;

    // Determine date range
    if (startDate && endDate) {
      filterStart = new Date(startDate);
      filterEnd = new Date(endDate);
      filterEnd.setHours(23, 59, 59, 999); // End of the day
    } else {
      // Default to today
      filterStart = new Date();
      filterStart.setHours(0, 0, 0, 0);
      filterEnd = new Date();
      filterEnd.setHours(23, 59, 59, 999);
    }

    const startOfMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1);

    // 1. Filtered Bills (for the selected range)
    const filteredBills = await Bill.find({
      createdAt: { $gte: filterStart, $lte: filterEnd },
      status: 'completed'
    });

    // 2. Month's Bills (Always for current month context)
    const monthBills = await Bill.find({
      createdAt: { $gte: startOfMonth },
      status: 'completed'
    });

    // 3. Calculations
    const todayEarnings = filteredBills.reduce((sum, bill) => sum + bill.totalAmount, 0);
    const monthEarnings = monthBills.reduce((sum, bill) => sum + bill.totalAmount, 0);
    const totalCustomers = await Customer.countDocuments();

    // 4. Services & Employees Analysis (Filtered)
    let servicesCount = 0;
    const employeeStats = {};
    const serviceStats = {};
    let servicesRevenue = 0;
    let productsRevenue = 0;
    let productsSold = 0; // NEW: Track products sold

    filteredBills.forEach(bill => {
      bill.items.forEach(item => {
        if (item.type === 'service') {
          servicesCount++;
          servicesRevenue += item.price * item.quantity;

          // Service Stats
          if (!serviceStats[item.name]) serviceStats[item.name] = { count: 0, revenue: 0 };
          serviceStats[item.name].count += item.quantity;
          serviceStats[item.name].revenue += item.price * item.quantity;

          // Employee Stats
          if (item.employeeName) {
            if (!employeeStats[item.employeeName]) employeeStats[item.employeeName] = 0;
            employeeStats[item.employeeName]++;
          }
        } else {
          // Product Stats
          productsRevenue += item.price * item.quantity;
          productsSold += item.quantity; // Increment products sold
        }
      });
    });

    // Top Stylist (Filtered)
    let topStylist = 'N/A';
    let maxServices = 0;
    for (const [name, count] of Object.entries(employeeStats)) {
      if (count > maxServices) {
        maxServices = count;
        topStylist = name;
      }
    }

    // Top Services List
    const topServices = Object.entries(serviceStats)
      .map(([name, stats]) => ({ name, count: stats.count, revenue: stats.revenue }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);

    // 5. Top Customers (All Time)
    const topCustomers = await Customer.find()
      .sort({ totalSpent: -1 })
      .limit(5)
      .select('name mobile totalVisits totalSpent');

    // 6. Top Employees (Filtered)
    const topEmployees = Object.entries(employeeStats)
      .map(([name, count]) => ({ name, servicesCompleted: count }))
      .sort((a, b) => b.servicesCompleted - a.servicesCompleted)
      .slice(0, 5);

    // 7. Inventory Summary
    const products = await Product.find();
    const totalProducts = products.length;
    const lowStockCount = products.filter(p => p.stock < 10).length;
    const stockValue = products.reduce((sum, p) => sum + (p.price * p.stock), 0);

    res.json({
      todayEarnings, // This is now "Filtered Earnings"
      monthEarnings,
      totalCustomers,
      servicesCompleted: servicesCount,
      topStylist,
      topServices,
      revenueBreakdown: {
        servicesRevenue,
        productsRevenue
      },
      topCustomers: topCustomers.map(c => ({
        customerId: c._id,
        name: c.name,
        mobile: c.mobile,
        totalVisits: c.totalVisits,
        totalSpent: c.totalSpent
      })),
      topEmployees: topEmployees.map(e => ({
        employeeId: e.name,
        name: e.name,
        servicesCompleted: e.servicesCompleted
      })),
      inventorySummary: {
        totalProducts,
        lowStockCount,
        stockValue,
        productRevenue: productsRevenue,
        productsSold: productsSold,
        lowStockItems: products
          .filter(p => p.stock < 10)
          .map(p => `${p.name} (${p.stock})`)
      },
      filterStartDate: filterStart.toISOString(),
      filterEndDate: filterEnd.toISOString()
    });

  } catch (e) {
    console.error('Dashboard Stats Error:', e);
    res.status(500).json({ error: e.message });
  }
});

// Start Server
const PORT = process.env.PORT || 3000;

// Only listen if run directly (not imported)
if (require.main === module) {
  app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
}

module.exports = app;
