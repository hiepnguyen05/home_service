const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('booking_status_logs', {
    id: {
      autoIncrement: true,
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      primaryKey: true
    },
    booking_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      references: {
        model: 'bookings',
        key: 'id'
      }
    },
    status_from: {
      type: DataTypes.STRING(50),
      allowNull: true
    },
    status_to: {
      type: DataTypes.STRING(50),
      allowNull: false
    },
    changed_by: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: true
    },
    note: {
      type: DataTypes.STRING(255),
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'booking_status_logs',
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
        name: "booking_id",
        using: "BTREE",
        fields: [
          { name: "booking_id" },
        ]
      },
    ]
  });
};
