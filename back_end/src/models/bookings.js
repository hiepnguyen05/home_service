const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('bookings', {
    id: {
      autoIncrement: true,
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      primaryKey: true
    },
    code: {
      type: DataTypes.STRING(20),
      allowNull: false,
      unique: "code"
    },
    customer_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    worker_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: true,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    service_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      references: {
        model: 'services',
        key: 'id'
      }
    },
    address_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false
    },
    base_price: {
      type: DataTypes.DECIMAL(15,2),
      allowNull: false
    },
    platform_fee: {
      type: DataTypes.DECIMAL(15,2),
      allowNull: false
    },
    total_amount: {
      type: DataTypes.DECIMAL(15,2),
      allowNull: false
    },
    scheduled_at: {
      type: DataTypes.DATE,
      allowNull: false
    },
    arrived_at: {
      type: DataTypes.DATE,
      allowNull: true
    },
    started_at: {
      type: DataTypes.DATE,
      allowNull: true
    },
    completed_at: {
      type: DataTypes.DATE,
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM('pending','confirmed','arriving','in_progress','completed','cancelled','failed'),
      allowNull: true,
      defaultValue: "pending"
    },
    customer_note: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    cancel_reason: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    canceled_by: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'bookings',
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
        name: "code",
        unique: true,
        using: "BTREE",
        fields: [
          { name: "code" },
        ]
      },
      {
        name: "customer_id",
        using: "BTREE",
        fields: [
          { name: "customer_id" },
        ]
      },
      {
        name: "worker_id",
        using: "BTREE",
        fields: [
          { name: "worker_id" },
        ]
      },
      {
        name: "service_id",
        using: "BTREE",
        fields: [
          { name: "service_id" },
        ]
      },
      {
        name: "idx_date_status",
        using: "BTREE",
        fields: [
          { name: "scheduled_at" },
          { name: "status" },
        ]
      },
    ]
  });
};
