const express = require('express');
const router = express.Router();
const Bill = require('../models/Bill');
const Employee = require('../models/Employee');
const Service = require('../models/Service');

// Helper to get start and end of day
const getDayRange = (date) => {
    const start = new Date(date);
    start.setHours(0, 0, 0, 0);
    const end = new Date(date);
    end.setHours(23, 59, 59, 999);
    return { start, end };
};

// Helper to get start and end of month
const getMonthRange = (date) => {
    const start = new Date(date.getFullYear(), date.getMonth(), 1);
    const end = new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59, 999);
    return { start, end };
};

// GET /api/reports/daily-sales
router.get('/daily-sales', async (req, res) => {
    try {
        const { date } = req.query;
        const queryDate = date ? new Date(date) : new Date();
        const { start, end } = getDayRange(queryDate);

        const bills = await Bill.find({
            createdAt: { $gte: start, $lte: end },
            status: 'completed' // Only count completed bills
        });

        const totalSales = bills.reduce((sum, bill) => sum + bill.totalAmount, 0);
        const totalBills = bills.length;

        // Group by hour for the chart
        const hourlySales = Array(24).fill(0);
        bills.forEach(bill => {
            const hour = new Date(bill.createdAt).getHours();
            hourlySales[hour] += bill.totalAmount;
        });

        res.json({
            date: queryDate.toISOString().split('T')[0],
            totalSales,
            totalBills,
            hourlySales
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// GET /api/reports/monthly-revenue
router.get('/monthly-revenue', async (req, res) => {
    try {
        const { year } = req.query;
        const queryYear = year ? parseInt(year) : new Date().getFullYear();

        const start = new Date(queryYear, 0, 1);
        const end = new Date(queryYear, 11, 31, 23, 59, 59, 999);

        const bills = await Bill.find({
            createdAt: { $gte: start, $lte: end },
            status: 'completed'
        });

        const monthlyRevenue = Array(12).fill(0);
        bills.forEach(bill => {
            const month = new Date(bill.createdAt).getMonth();
            monthlyRevenue[month] += bill.totalAmount;
        });

        res.json({
            year: queryYear,
            totalRevenue: monthlyRevenue.reduce((a, b) => a + b, 0),
            monthlyRevenue
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// GET /api/reports/employee-performance
router.get('/employee-performance', async (req, res) => {
    try {
        const { startDate, endDate } = req.query;

        let dateFilter = {};
        if (startDate && endDate) {
            dateFilter = {
                createdAt: {
                    $gte: new Date(startDate),
                    $lte: new Date(endDate)
                }
            };
        }

        const bills = await Bill.find({
            ...dateFilter,
            status: 'completed'
        }).populate('items.employee');

        const employeeStats = {};

        bills.forEach(bill => {
            bill.items.forEach(item => {
                if (item.employee) { // Check if employee is assigned
                    const empId = item.employee._id.toString();
                    if (!employeeStats[empId]) {
                        employeeStats[empId] = {
                            id: empId,
                            name: item.employee.name,
                            servicesCount: 0,
                            revenue: 0
                        };
                    }
                    employeeStats[empId].servicesCount += 1;
                    employeeStats[empId].revenue += item.price * item.quantity;
                }
            });
        });

        const performanceData = Object.values(employeeStats).sort((a, b) => b.revenue - a.revenue);

        res.json(performanceData);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// GET /api/reports/customer-analytics
router.get('/customer-analytics', async (req, res) => {
    try {
        const { months } = req.query;
        const numMonths = months ? parseInt(months) : 6;

        const today = new Date();
        const analytics = [];

        for (let i = 0; i < numMonths; i++) {
            const date = new Date(today.getFullYear(), today.getMonth() - i, 1);
            const monthStart = new Date(date.getFullYear(), date.getMonth(), 1);
            const monthEnd = new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59, 999);

            // New Customers
            const newCustomers = await require('../models/Customer').countDocuments({
                createdAt: { $gte: monthStart, $lte: monthEnd } // Assuming Customer has createdAt
            });

            // Active Customers (visited this month)
            const activeCustomers = await Bill.distinct('customerId', {
                createdAt: { $gte: monthStart, $lte: monthEnd },
                status: 'completed'
            });

            analytics.unshift({
                month: monthStart.toLocaleString('default', { month: 'short' }),
                newCustomers,
                activeCustomers: activeCustomers.length
            });
        }

        res.json(analytics);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
