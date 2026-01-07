const Sequelize = require('sequelize');
module.exports = function (sequelize, DataTypes) {
    return sequelize.define('worker_applications', {
        id: {
            autoIncrement: true,
            type: DataTypes.BIGINT.UNSIGNED,
            allowNull: false,
            primaryKey: true
        },
        user_id: {
            type: DataTypes.BIGINT.UNSIGNED,
            allowNull: false,
            references: {
                model: 'users',
                key: 'id'
            }
        },
        citizen_id: {
            type: DataTypes.STRING(20),
            allowNull: false
        },
        bio: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        experience_years: {
            type: DataTypes.TINYINT.UNSIGNED,
            allowNull: true,
            defaultValue: 0
        },
        radius_km: {
            type: DataTypes.INTEGER,
            allowNull: true,
            defaultValue: 10
        },
        identity_front_url: {
            type: DataTypes.STRING(255),
            allowNull: false
        },
        identity_back_url: {
            type: DataTypes.STRING(255),
            allowNull: false
        },
        certificate_urls: {
            type: DataTypes.JSON,
            allowNull: true
        },
        service_ids: {
            type: DataTypes.JSON,
            allowNull: false
        },
        status: {
            type: DataTypes.ENUM('pending', 'approved', 'rejected'),
            allowNull: false,
            defaultValue: 'pending'
        },
        admin_note: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        reviewed_by: {
            type: DataTypes.BIGINT.UNSIGNED,
            allowNull: true,
            references: {
                model: 'users',
                key: 'id'
            }
        },
        reviewed_at: {
            type: DataTypes.DATE,
            allowNull: true
        }
    }, {
        sequelize,
        tableName: 'worker_applications',
        timestamps: true,
        indexes: [
            {
                name: "PRIMARY",
                unique: true,
                using: "BTREE",
                fields: [
                    { name: "id" },
                ]
            },
            {
                name: "user_id",
                using: "BTREE",
                fields: [
                    { name: "user_id" },
                ]
            },
            {
                name: "status",
                using: "BTREE",
                fields: [
                    { name: "status" },
                ]
            },
        ]
    });
};