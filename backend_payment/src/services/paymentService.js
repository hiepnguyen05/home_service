const { db } = require('../config/firebase');

class PaymentService {
    constructor() {
        this.collection = db.collection('payments');
    }

    /**
     * Tạo bản ghi thanh toán mới
     */
    async createPaymentRecord(bookingId, orderId, amount, paymentMethod = 'momo') {
        try {
            await this.collection.doc(orderId).set({
                bookingId: bookingId,
                orderId: orderId,
                amount: amount,
                status: 'pending',
                paymentMethod: paymentMethod,
                createdAt: new Date(),
                updatedAt: new Date()
            });
            console.log(`Created payment record for Order ID: ${orderId}`);
        } catch (error) {
            console.error("Error creating payment record:", error);
            throw error;
        }
    }

    /**
     * Cập nhật trạng thái thanh toán và thông tin giao dịch
     */
    async updatePaymentStatus(orderId, status, transId, resultCode, message) {
        try {
            await this.collection.doc(orderId).update({
                status: status,
                transId: transId,
                resultCode: resultCode,
                message: message,
                updatedAt: new Date()
            });
            console.log(`Updated payment status for Order ID: ${orderId} to ${status}`);
        } catch (error) {
            console.error(`Error updating payment status for ${orderId}:`, error);
            throw error;
        }
    }

    /**
     * Lấy thông tin thanh toán
     */
    async getPaymentByOrderId(orderId) {
        try {
            const doc = await this.collection.doc(orderId).get();
            if (!doc.exists) return null;
            return doc.data();
        } catch (error) {
            console.error("Error getting payment:", error);
            throw error;
        }
    }
}

module.exports = new PaymentService();
