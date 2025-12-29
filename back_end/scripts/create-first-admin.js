const bcrypt = require('bcryptjs');
const { sequelize } = require('../src/config/database');
const initModels = require('../src/models/init-models');

const models = initModels(sequelize);

async function createFirstAdmin() {
    try {
        console.log('🔄 Đang tạo tài khoản admin đầu tiên...');

        // Kiểm tra xem đã có admin nào chưa
        const existingAdmin = await models.users.findOne({
            where: { role: 'admin' }
        });

        if (existingAdmin) {
            console.log('ℹ️  Đã có tài khoản admin trong hệ thống');
            console.log(`📧 Email: ${existingAdmin.email}`);
            console.log(`📱 Phone: ${existingAdmin.phone}`);
            return;
        }

        // Tạo admin mới
        const adminData = {
            full_name: 'Super Admin',
            phone: '0999999999',
            email: 'admin@homeservice.com',
            password_hash: await bcrypt.hash('admin123456', 10),
            role: 'admin',
            status: 'active'
        };

        const newAdmin = await models.users.create(adminData);

        console.log('✅ Tạo tài khoản admin thành công!');
        console.log('📧 Email:', adminData.email);
        console.log('🔑 Password:', 'admin123456');
        console.log('📱 Phone:', adminData.phone);
        console.log('🆔 Admin ID:', newAdmin.id);
        console.log('');
        console.log('⚠️  LƯU Ý: Hãy đổi mật khẩu sau khi đăng nhập lần đầu!');

    } catch (error) {
        console.error('❌ Lỗi tạo admin:', error.message);
    } finally {
        await sequelize.close();
    }
}

// Chạy script
if (require.main === module) {
    createFirstAdmin();
}

module.exports = { createFirstAdmin };