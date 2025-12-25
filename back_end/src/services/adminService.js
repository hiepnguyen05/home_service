const adminRepository = require('../repositories/adminRepository');
const bcrypt = require('bcryptjs');

class AdminService {
    // Lấy danh sách người dùng
    async getAllUsers(options) {
        try {
            return await adminRepository.getAllUsers(options);
        } catch (error) {
            throw new Error(`Khong the lay danh sach nguoi dung: ${error.message}`);
        }
    }

    // Lấy thông tin chi tiết người dùng
    async getUserById(userId) {
        try {
            const user = await adminRepository.getUserById(userId);

            if (!user) {
                throw new Error('Khong tim thay nguoi dung');
            }

            return user;
        } catch (error) {
            throw new Error(`Khong the lay thong tin nguoi dung: ${error.message}`);
        }
    }

    // Cập nhật thông tin người dùng
    async updateUser(userId, updateData) {
        try {
            // Kiểm tra người dùng có tồn tại không
            const user = await adminRepository.getUserById(userId);
            if (!user) {
                throw new Error('Khong tim thay nguoi dung');
            }

            // Nếu có cập nhật password, hash nó
            if (updateData.password) {
                updateData.password_hash = await bcrypt.hash(updateData.password, 10);
                delete updateData.password;
            }

            const updatedRows = await adminRepository.updateUser(userId, updateData);

            if (updatedRows === 0) {
                throw new Error('Khong co thay doi nao duoc thuc hien');
            }

            // Lấy thông tin người dùng đã cập nhật
            return await adminRepository.getUserById(userId);
        } catch (error) {
            throw new Error(`Khong the cap nhat nguoi dung: ${error.message}`);
        }
    }

    // Cập nhật trạng thái người dùng
    async updateUserStatus(userId, status) {
        try {
            const validStatuses = ['active', 'inactive', 'banned', 'pending_verification'];

            if (!validStatuses.includes(status)) {
                throw new Error('Trang thai khong hop le');
            }

            const user = await adminRepository.getUserById(userId);
            if (!user) {
                throw new Error('Khong tim thay nguoi dung');
            }

            const updatedRows = await adminRepository.updateUserStatus(userId, status);

            if (updatedRows === 0) {
                throw new Error('Khong the cap nhat trang thai');
            }

            return await adminRepository.getUserById(userId);
        } catch (error) {
            throw new Error(`Khong the cap nhat trang thai: ${error.message}`);
        }
    }

    // Cập nhật role người dùng
    async updateUserRole(userId, role) {
        try {
            const validRoles = ['customer', 'worker', 'admin'];

            if (!validRoles.includes(role)) {
                throw new Error('Role khong hop le');
            }

            const user = await adminRepository.getUserById(userId);
            if (!user) {
                throw new Error('Khong tim thay nguoi dung');
            }

            const updatedRows = await adminRepository.updateUserRole(userId, role);

            if (updatedRows === 0) {
                throw new Error('Khong the cap nhat role');
            }

            return await adminRepository.getUserById(userId);
        } catch (error) {
            throw new Error(`Khong the cap nhat role: ${error.message}`);
        }
    }

    // Xóa mềm người dùng
    async deleteUser(userId) {
        try {
            const user = await adminRepository.getUserById(userId);
            if (!user) {
                throw new Error('Khong tim thay nguoi dung');
            }

            // Không cho phép xóa admin cuối cùng
            if (user.role === 'admin') {
                const stats = await adminRepository.getUserStats();
                if (stats.byRole.admin <= 1) {
                    throw new Error('Khong the xoa admin cuoi cung trong he thong');
                }
            }

            await adminRepository.softDeleteUser(userId);
            return { message: 'Xoa nguoi dung thanh cong' };
        } catch (error) {
            throw new Error(`Khong the xoa nguoi dung: ${error.message}`);
        }
    }

    // Khôi phục người dùng
    async restoreUser(userId) {
        try {
            await adminRepository.restoreUser(userId);
            return await adminRepository.getUserById(userId);
        } catch (error) {
            throw new Error(`Khong the khoi phuc nguoi dung: ${error.message}`);
        }
    }

    // Xóa cứng người dùng
    async permanentDeleteUser(userId) {
        try {
            const user = await adminRepository.getUserById(userId);
            if (!user) {
                throw new Error('Khong tim thay nguoi dung');
            }

            // Không cho phép xóa admin cuối cùng
            if (user.role === 'admin') {
                const stats = await adminRepository.getUserStats();
                if (stats.byRole.admin <= 1) {
                    throw new Error('Khong the xoa vinh vien admin cuoi cung');
                }
            }

            await adminRepository.hardDeleteUser(userId);
            return { message: 'Xoa vinh vien nguoi dung thanh cong' };
        } catch (error) {
            throw new Error(`Khong the xoa vinh vien nguoi dung: ${error.message}`);
        }
    }

    // Lấy thống kê người dùng
    async getUserStats() {
        try {
            return await adminRepository.getUserStats();
        } catch (error) {
            throw new Error(`Khong the lay thong ke: ${error.message}`);
        }
    }

    // Tạo tài khoản admin mới
    async createAdmin(adminData) {
        try {
            // Hash password
            const password_hash = await bcrypt.hash(adminData.password, 10);

            const newAdmin = await adminRepository.createAdmin({
                full_name: adminData.fullName,
                phone: adminData.phone,
                email: adminData.email,
                password_hash
            });

            // Loại bỏ password_hash khỏi response
            const { password_hash: _, ...adminResponse } = newAdmin.toJSON();
            return adminResponse;
        } catch (error) {
            throw new Error(`Khong the tao admin: ${error.message}`);
        }
    }

    // Lấy danh sách người dùng đã xóa
    async getDeletedUsers(options) {
        try {
            return await adminRepository.getDeletedUsers(options);
        } catch (error) {
            throw new Error(`Khong the lay danh sach nguoi dung da xoa: ${error.message}`);
        }
    }

    // Tìm kiếm nâng cao
    async advancedSearch(searchCriteria) {
        try {
            return await adminRepository.advancedSearch(searchCriteria);
        } catch (error) {
            throw new Error(`Khong the tim kiem: ${error.message}`);
        }
    }

    // Ban người dùng
    async banUser(userId, reason = '') {
        try {
            const user = await adminRepository.getUserById(userId);
            if (!user) {
                throw new Error('Khong tim thay nguoi dung');
            }

            if (user.role === 'admin') {
                throw new Error('Khong the ban tai khoan admin');
            }

            await adminRepository.updateUserStatus(userId, 'banned');

            // TODO: Có thể lưu lý do ban vào bảng riêng nếu cần

            return await adminRepository.getUserById(userId);
        } catch (error) {
            throw new Error(`Khong the ban nguoi dung: ${error.message}`);
        }
    }

    // Unban người dùng
    async unbanUser(userId) {
        try {
            const user = await adminRepository.getUserById(userId);
            if (!user) {
                throw new Error('Khong tim thay nguoi dung');
            }

            if (user.status !== 'banned') {
                throw new Error('Nguoi dung khong bi ban');
            }

            await adminRepository.updateUserStatus(userId, 'active');
            return await adminRepository.getUserById(userId);
        } catch (error) {
            throw new Error(`Khong the unban nguoi dung: ${error.message}`);
        }
    }
}

module.exports = new AdminService();