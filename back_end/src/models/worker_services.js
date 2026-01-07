const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('worker_services', {
    worker_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    service_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'services',
        key: 'id'
      }
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      allowNull: true,
      defaultValue: 1
    }
  }, {
    sequelize,
    tableName: 'worker_services',
    timestamps: true,
    indexes: [
      {
        name: "PRIMARY",
        unique: true,
        using: "BTREE",
        fields: [
          { name: "worker_id" },
          { name: "service_id" },
        ]
      },
      {
        name: "service_id",
        using: "BTREE",
        fields: [
          { name: "service_id" },
        ]
      },
    ]
  });
};
