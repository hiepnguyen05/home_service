const express = require('express');
const router = express.Router();
const momoService = require('../services/momoService');
const paymentService = require('../services/paymentService');

// POST /api/payment/create
// Nhận: { bookingId, amount, orderInfo }
// Trả về: { payUrl, orderId }
router.post('/create', async (req, res) => {
    console.log("========== CREATE PAYMENT ==========");
    console.log("Request body:", JSON.stringify(req.body, null, 2));
    try {
        const { bookingId, amount, orderInfo } = req.body;

        const orderId = `${bookingId}_${new Date().getTime()}`;
        console.log(`[CREATE] Generated orderId: ${orderId}`);

        // 1. Lưu payment record vào Firestore (TRƯỚC khi gọi MoMo)
        console.log(`[CREATE] Creating payment record in Firestore...`);
        await paymentService.createPaymentRecord(bookingId, orderId, amount);
        console.log(`[CREATE] Payment record created successfully`);

        // 2. Gọi MoMo API
        console.log(`[CREATE] Calling MoMo API...`);
        const result = await momoService.createPayment(orderId, amount, orderInfo);
        console.log(`[CREATE] MoMo Response:`, JSON.stringify(result, null, 2));

        if (result && result.payUrl) {
            res.json({
                success: true,
                payUrl: result.payUrl,
                deepLink: result.deeplink,
                qrCodeUrl: result.qrCodeUrl,
                orderId: orderId,
                message: result.message
            });
        } else {
            res.status(400).json({
                success: false,
                message: 'Failed to create payment url with MoMo',
                detail: result
            });
        }
    } catch (error) {
        console.error("[CREATE] Error:", error);
        res.status(500).json({
            success: false,
            message: 'Internal Server Error',
            error: error.message
        });
    }
});

// POST /api/payment/ipn
// Callback từ MoMo (Server-to-Server)
router.post('/ipn', async (req, res) => {
    console.log("========== IPN CALLBACK RECEIVED ==========");
    console.log("[IPN] Full body:", JSON.stringify(req.body, null, 2));
    try {
        const data = req.body;

        console.log(`[IPN] orderId: ${data.orderId}`);
        console.log(`[IPN] resultCode: ${data.resultCode}`);
        console.log(`[IPN] transId: ${data.transId}`);
        console.log(`[IPN] message: ${data.message}`);

        // 1. Verify chữ ký
        console.log(`[IPN] Verifying signature...`);
        const isValid = momoService.verifyIpnSignature(data);
        console.log(`[IPN] Signature valid: ${isValid}`);

        if (!isValid) {
            console.error("[IPN] INVALID SIGNATURE!");
            return res.status(200).json({ message: 'Invalid signature' });
        }

        // 2. Xác định trạng thái
        let status = 'failed';
        if (data.resultCode == 0) {
            status = 'success';
        } else if (data.resultCode == 9000) {
            status = 'pending';
        }
        console.log(`[IPN] Determined status: ${status}`);

        // 3. Cập nhật Database
        console.log(`[IPN] Updating Firestore...`);
        await paymentService.updatePaymentStatus(
            data.orderId,
            status,
            data.transId,
            data.resultCode,
            data.message
        );
        console.log(`[IPN] Firestore updated successfully!`);

        // 4. Phản hồi cho MoMo
        console.log(`[IPN] Sending 204 response to MoMo`);
        res.status(204).send();

    } catch (error) {
        console.error("[IPN] Error:", error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
});

// GET /api/payment/status/:orderId
// App gọi để check trạng thái thủ công (nếu không dùng realtime listener)
router.get('/status/:orderId', async (req, res) => {
    const { orderId } = req.params;
    console.log(`========== STATUS CHECK: ${orderId} ==========`);
    try {
        console.log(`[STATUS] Fetching payment from Firestore...`);
        const payment = await paymentService.getPaymentByOrderId(orderId);

        if (payment) {
            console.log(`[STATUS] Found payment:`, JSON.stringify(payment, null, 2));
            res.json({
                success: true,
                data: payment
            });
        } else {
            console.log(`[STATUS] Payment NOT FOUND for orderId: ${orderId}`);
            res.status(404).json({
                success: false,
                message: 'Payment not found'
            });
        }
    } catch (error) {
        console.error(`[STATUS] Error:`, error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});
// POST /api/payment/confirm
// App gọi để xác nhận thanh toán thủ công (backup khi IPN không về)
router.post('/confirm', async (req, res) => {
    console.log("========== MANUAL CONFIRM ==========");
    console.log("[CONFIRM] Body:", JSON.stringify(req.body, null, 2));

    try {
        const { orderId, resultCode } = req.body;

        if (!orderId) {
            return res.status(400).json({ success: false, message: 'orderId is required' });
        }

        // Nếu resultCode = 0 (từ redirect URL) -> cập nhật thành success
        if (resultCode == 0 || resultCode == '0') {
            console.log(`[CONFIRM] Updating orderId ${orderId} to SUCCESS`);
            await paymentService.updatePaymentStatus(
                orderId,
                'success',
                null, // transId không có từ redirect
                0,
                'Confirmed via app redirect'
            );
            console.log(`[CONFIRM] ✅ Updated successfully!`);
            res.json({ success: true, message: 'Payment confirmed' });
        } else {
            console.log(`[CONFIRM] resultCode is ${resultCode}, not updating`);
            res.json({ success: false, message: 'Payment not successful' });
        }
    } catch (error) {
        console.error("[CONFIRM] Error:", error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
