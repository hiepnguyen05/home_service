const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('services', {
    id: {
      autoIncrement: true,
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      primaryKey: true
    },
    category_id: {
      type: DataTypes.INTEGER.UNSIGNED,
      allowNull: false,
      references: {
        model: 'categories',
        key: 'id'
      }
    },
    name: {
      type: DataTypes.STRING(150),
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    price_type: {
      type: DataTypes.ENUM('fixed','hourly','quote'),
      allowNull: true,
      defaultValue: "fixed"
    },
    default_price: {
      type: DataTypes.DECIMAL(15,2),
      allowNull: false
    },
    duration_minutes: {
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: 60
    },
    commission_rate: {
      type: DataTypes.DECIMAL(5,2),
      allowNull: true,
      defaultValue: 10.00
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      allowNull: true,
      defaultValue: 1
    }
  }, {
    sequelize,
    tableName: 'services',
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
        name: "category_id",
        using: "BTREE",
        fields: [
          { name: "category_id" },
        ]
      },
    ]
  });
};
