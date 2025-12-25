const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('wallet_transactions', {
    id: {
      autoIncrement: true,
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      primaryKey: true
    },
    wallet_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      references: {
        model: 'wallets',
        key: 'id'
      }
    },
    amount: {
      type: DataTypes.DECIMAL(15,2),
      allowNull: false
    },
    type: {
      type: DataTypes.ENUM('deposit','withdrawal','payment_fee','income','refund'),
      allowNull: false
    },
    booking_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: true
    },
    description: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM('pending','success','failed'),
      allowNull: true,
      defaultValue: "success"
    }
  }, {
    sequelize,
    tableName: 'wallet_transactions',
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
        name: "wallet_id",
        using: "BTREE",
        fields: [
          { name: "wallet_id" },
        ]
      },
    ]
  });
};
