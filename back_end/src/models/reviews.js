const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('reviews', {
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
      },
      unique: "reviews_ibfk_1"
    },
    customer_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false
    },
    worker_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    rating: {
      type: DataTypes.TINYINT.UNSIGNED,
      allowNull: false,
      comment: "1 to 5"
    },
    comment: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    images_json: {
      type: DataTypes.JSON,
      allowNull: true
    },
    is_hidden: {
      type: DataTypes.BOOLEAN,
      allowNull: true,
      defaultValue: 0
    }
  }, {
    sequelize,
    tableName: 'reviews',
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
        unique: true,
        using: "BTREE",
        fields: [
          { name: "booking_id" },
        ]
      },
      {
        name: "worker_id",
        using: "BTREE",
        fields: [
          { name: "worker_id" },
        ]
      },
    ]
  });
};
