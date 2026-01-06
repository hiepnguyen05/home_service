const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('worker_profiles', {
    user_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    citizen_id: {
      type: DataTypes.STRING(20),
      allowNull: true,
      unique: "citizen_id"
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
    is_verified: {
      type: DataTypes.BOOLEAN,
      allowNull: true,
      defaultValue: 0
    },
    is_online: {
      type: DataTypes.BOOLEAN,
      allowNull: true,
      defaultValue: 0
    },
    current_lat: {
      type: DataTypes.DECIMAL(10,8),
      allowNull: true
    },
    current_long: {
      type: DataTypes.DECIMAL(11,8),
      allowNull: true
    },
    rating_avg: {
      type: DataTypes.DECIMAL(3,2),
      allowNull: true,
      defaultValue: 5.00
    },
    total_jobs: {
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: 0
    },
    total_reviews: {
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: 0
    }
  }, {
    sequelize,
    tableName: 'worker_profiles',
    timestamps: true,
    indexes: [
      {
        name: "PRIMARY",
        unique: true,
        using: "BTREE",
        fields: [
          { name: "user_id" },
        ]
      },
      {
        name: "citizen_id",
        unique: true,
        using: "BTREE",
        fields: [
          { name: "citizen_id" },
        ]
      },
    ]
  });
};
