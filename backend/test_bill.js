async function testBillCreation() {
    try {
        // 1. Create a customer
        const customerRes = await fetch('http://localhost:3000/api/customers', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                name: 'Test Customer',
                mobile: '9999999999',
                gender: 'Female'
            })
        });
        const customer = await customerRes.json();
        const customerId = customer._id;
        console.log('Customer created:', customerId);

        // 2. Create a bill with 0 total
        const billData = {
            customerId: customerId,
            customerName: 'Test Customer',
            customerMobile: '9999999999',
            items: [
                {
                    type: 'service',
                    id: 'service123',
                    name: 'Test Service',
                    price: 500,
                    quantity: 1
                }
            ],
            subtotal: 0,
            totalAmount: 0,
            status: 'completed',
            paymentMethod: 'Cash'
        };

        console.log('Sending bill data with 0 total...');
        const billRes = await fetch('http://localhost:3000/api/bills', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(billData)
        });

        const bill = await billRes.json();

        console.log('Bill Response Status:', billRes.status);
        console.log('Bill Response Data:', JSON.stringify(bill, null, 2));

        if (bill.totalAmount === 500) {
            console.log('✅ SUCCESS: Backend calculated totalAmount correctly!');
        } else {
            console.log('❌ FAILURE: Backend returned totalAmount:', bill.totalAmount);
        }

    } catch (error) {
        console.error('Error:', error);
    }
}

testBillCreation();
