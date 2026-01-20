var DataTypes = require("sequelize").DataTypes;
var _booking_status_logs = require("./booking_status_logs");
var _bookings = require("./bookings");
var _categories = require("./categories");
var _notifications = require("./notifications");
var _payments = require("./payments");
var _reviews = require("./reviews");
var _services = require("./services");
var _system_settings = require("./system_settings");
var _user_addresses = require("./user_addresses");
var _users = require("./users");
var _wallet_transactions = require("./wallet_transactions");
var _wallets = require("./wallets");
var _worker_applications = require("./worker_applications");
var _worker_attachments = require("./worker_attachments");
var _worker_profiles = require("./worker_profiles");
var _worker_services = require("./worker_services");

function initModels(sequelize) {
  var booking_status_logs = _booking_status_logs(sequelize, DataTypes);
  var bookings = _bookings(sequelize, DataTypes);
  var categories = _categories(sequelize, DataTypes);
  var notifications = _notifications(sequelize, DataTypes);
  var payments = _payments(sequelize, DataTypes);
  var reviews = _reviews(sequelize, DataTypes);
  var services = _services(sequelize, DataTypes);
  var system_settings = _system_settings(sequelize, DataTypes);
  var user_addresses = _user_addresses(sequelize, DataTypes);
  var users = _users(sequelize, DataTypes);
  var wallet_transactions = _wallet_transactions(sequelize, DataTypes);
  var wallets = _wallets(sequelize, DataTypes);
  var worker_applications = _worker_applications(sequelize, DataTypes);
  var worker_attachments = _worker_attachments(sequelize, DataTypes);
  var worker_profiles = _worker_profiles(sequelize, DataTypes);
  var worker_services = _worker_services(sequelize, DataTypes);

  services.belongsToMany(users, { as: 'worker_id_users', through: worker_services, foreignKey: "service_id", otherKey: "worker_id" });
  users.belongsToMany(services, { as: 'service_id_services', through: worker_services, foreignKey: "worker_id", otherKey: "service_id" });
  booking_status_logs.belongsTo(bookings, { as: "booking", foreignKey: "booking_id" });
  bookings.hasMany(booking_status_logs, { as: "booking_status_logs", foreignKey: "booking_id" });
  payments.belongsTo(bookings, { as: "booking", foreignKey: "booking_id" });
  bookings.hasMany(payments, { as: "payments", foreignKey: "booking_id" });
  reviews.belongsTo(bookings, { as: "booking", foreignKey: "booking_id" });
  bookings.hasOne(reviews, { as: "review", foreignKey: "booking_id" });
  services.belongsTo(categories, { as: "category", foreignKey: "category_id" });
  categories.hasMany(services, { as: "services", foreignKey: "category_id" });
  bookings.belongsTo(services, { as: "service", foreignKey: "service_id" });
  services.hasMany(bookings, { as: "bookings", foreignKey: "service_id" });
  worker_services.belongsTo(services, { as: "service", foreignKey: "service_id" });
  services.hasMany(worker_services, { as: "worker_services", foreignKey: "service_id" });
  bookings.belongsTo(users, { as: "customer", foreignKey: "customer_id" });
  users.hasMany(bookings, { as: "bookings", foreignKey: "customer_id" });
  bookings.belongsTo(users, { as: "worker", foreignKey: "worker_id" });
  users.hasMany(bookings, { as: "worker_bookings", foreignKey: "worker_id" });
  notifications.belongsTo(users, { as: "user", foreignKey: "user_id" });
  users.hasMany(notifications, { as: "notifications", foreignKey: "user_id" });
  reviews.belongsTo(users, { as: "worker", foreignKey: "worker_id" });
  users.hasMany(reviews, { as: "reviews", foreignKey: "worker_id" });
  user_addresses.belongsTo(users, { as: "user", foreignKey: "user_id" });
  users.hasMany(user_addresses, { as: "user_addresses", foreignKey: "user_id" });
  wallets.belongsTo(users, { as: "user", foreignKey: "user_id" });
  users.hasOne(wallets, { as: "wallet", foreignKey: "user_id" });
  worker_attachments.belongsTo(users, { as: "worker", foreignKey: "worker_id" });
  users.hasMany(worker_attachments, { as: "worker_attachments", foreignKey: "worker_id" });
  worker_profiles.belongsTo(users, { as: "user", foreignKey: "user_id" });
  users.hasOne(worker_profiles, { as: "worker_profile", foreignKey: "user_id" });
  worker_services.belongsTo(users, { as: "worker", foreignKey: "worker_id" });
  users.hasMany(worker_services, { as: "worker_services", foreignKey: "worker_id" });
  wallet_transactions.belongsTo(wallets, { as: "wallet", foreignKey: "wallet_id" });
  wallets.hasMany(wallet_transactions, { as: "wallet_transactions", foreignKey: "wallet_id" });

  // Worker applications relationships
  worker_applications.belongsTo(users, { as: "user", foreignKey: "user_id" });
  users.hasMany(worker_applications, { as: "worker_applications", foreignKey: "user_id" });
  worker_applications.belongsTo(users, { as: "reviewer", foreignKey: "reviewed_by" });
  users.hasMany(worker_applications, { as: "reviewed_applications", foreignKey: "reviewed_by" });

  return {
    booking_status_logs,
    bookings,
    categories,
    notifications,
    payments,
    reviews,
    services,
    system_settings,
    user_addresses,
    users,
    wallet_transactions,
    wallets,
    worker_applications,
    worker_attachments,
    worker_profiles,
    worker_services,
  };
}
module.exports = initModels;
module.exports.initModels = initModels;
module.exports.default = initModels;
