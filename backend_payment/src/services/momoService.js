const axios = require('axios');
const crypto = require('crypto');
const momoConfig = require('../config/momo');

class MomoService {
    /**
     * Tạo chữ ký HMAC SHA256
     */
    createSignature(rawSignature) {
        return crypto
            .createHmac('sha256', momoConfig.secretKey)
            .update(rawSignature)
            .digest('hex');
    }

    /**
     * Tạo yêu cầu thanh toán MoMo
     * @param {string} orderId - Mã đơn hàng duy nhất
     * @param {number} amount - Số tiền
     * @param {string} orderInfo - Thông tin đơn hàng
     * @param {string} extraData - Dữ liệu thêm (tùy chọn)
     */
    async createPayment(orderId, amount, orderInfo, extraData = '') {
        const requestId = momoConfig.partnerCode + new Date().getTime();
        const requestType = "captureWallet";

        // Format: accessKey=$accessKey&amount=$amount&extraData=$extraData&ipnUrl=$ipnUrl&orderId=$orderId&orderInfo=$orderInfo&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=$requestType
        const rawSignature = `accessKey=${momoConfig.accessKey}&amount=${amount}&extraData=${extraData}&ipnUrl=${momoConfig.ipnUrl}&orderId=${orderId}&orderInfo=${orderInfo}&partnerCode=${momoConfig.partnerCode}&redirectUrl=${momoConfig.redirectUrl}&requestId=${requestId}&requestType=${requestType}`;

        const signature = this.createSignature(rawSignature);

        const requestBody = {
            partnerCode: momoConfig.partnerCode,
            accessKey: momoConfig.accessKey,
            requestId: requestId,
            amount: amount.toString(),
            orderId: orderId,
            orderInfo: orderInfo,
            redirectUrl: momoConfig.redirectUrl,
            ipnUrl: momoConfig.ipnUrl,
            extraData: extraData,
            requestType: requestType,
            signature: signature,
            lang: 'vi'
        };

        try {
            console.log("Sending request to MoMo:", requestBody);
            const response = await axios.post(momoConfig.endpoint, requestBody);
            return response.data;
        } catch (error) {
            console.error("MoMo Create Payment Error:", error.response ? error.response.data : error.message);
            throw error;
        }
    }

    /**
     * Xác thực chữ ký từ IPN callback
     */
    verifyIpnSignature(data) {
        const {
            partnerCode,
            accessKey,
            requestId,
            amount,
            orderId,
            orderInfo,
            orderType,
            transId,
            resultCode,
            message,
            payType,
            responseTime,
            extraData,
            signature
        } = data;

        // accessKey=$accessKey&amount=$amount&extraData=$extraData&message=$message&orderId=$orderId&orderInfo=$orderInfo&orderType=$orderType&partnerCode=$partnerCode&payType=$payType&requestId=$requestId&responseTime=$responseTime&resultCode=$resultCode&transId=$transId
        const rawSignature = `accessKey=${momoConfig.accessKey}&amount=${amount}&extraData=${extraData}&message=${message}&orderId=${orderId}&orderInfo=${orderInfo}&orderType=${orderType}&partnerCode=${partnerCode}&payType=${payType}&requestId=${requestId}&responseTime=${responseTime}&resultCode=${resultCode}&transId=${transId}`;

        const generatedSignature = this.createSignature(rawSignature);

        return generatedSignature === signature;
    }
}

module.exports = new MomoService();
