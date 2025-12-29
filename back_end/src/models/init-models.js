var DataTypes = require("sequelize").DataTypes;
var _BookingStatusLogs = require("./booking_status_logs");
var _Bookings = require("./bookings");
var _Categories = require("./categories");
var _Notifications = require("./notifications");
var _Payments = require("./payments");
var _Reviews = require("./reviews");
var _Services = require("./services");
var _SystemSettings = require("./system_settings");
var _UserAddresses = require("./user_addresses");
var _Users = require("./users");
var _WalletTransactions = require("./wallet_transactions");
var _Wallets = require("./wallets");
var _WorkerApplications = require("./worker_applications");
var _WorkerAttachments = require("./worker_attachments");
var _WorkerProfiles = require("./worker_profiles");
var _WorkerServices = require("./worker_services");

function initModels(sequelize) {
  var BookingStatusLogs = _BookingStatusLogs(sequelize, DataTypes);
  var Bookings = _Bookings(sequelize, DataTypes);
  var Categories = _Categories(sequelize, DataTypes);
  var Notifications = _Notifications(sequelize, DataTypes);
  var Payments = _Payments(sequelize, DataTypes);
  var Reviews = _Reviews(sequelize, DataTypes);
  var Services = _Services(sequelize, DataTypes);
  var SystemSettings = _SystemSettings(sequelize, DataTypes);
  var UserAddresses = _UserAddresses(sequelize, DataTypes);
  var Users = _Users(sequelize, DataTypes);
  var WalletTransactions = _WalletTransactions(sequelize, DataTypes);
  var Wallets = _Wallets(sequelize, DataTypes);
  var WorkerApplications = _WorkerApplications(sequelize, DataTypes);
  var WorkerAttachments = _WorkerAttachments(sequelize, DataTypes);
  var WorkerProfiles = _WorkerProfiles(sequelize, DataTypes);
  var WorkerServices = _WorkerServices(sequelize, DataTypes);

  Services.belongsToMany(Users, { as: 'worker_id_users', through: WorkerServices, foreignKey: "service_id", otherKey: "worker_id" });
  Users.belongsToMany(Services, { as: 'service_id_services', through: WorkerServices, foreignKey: "worker_id", otherKey: "service_id" });
  BookingStatusLogs.belongsTo(Bookings, { as: "booking", foreignKey: "booking_id"});
  Bookings.hasMany(BookingStatusLogs, { as: "booking_status_logs", foreignKey: "booking_id"});
  Payments.belongsTo(Bookings, { as: "booking", foreignKey: "booking_id"});
  Bookings.hasMany(Payments, { as: "payments", foreignKey: "booking_id"});
  Reviews.belongsTo(Bookings, { as: "booking", foreignKey: "booking_id"});
  Bookings.hasOne(Reviews, { as: "review", foreignKey: "booking_id"});
  Services.belongsTo(Categories, { as: "category", foreignKey: "category_id"});
  Categories.hasMany(Services, { as: "services", foreignKey: "category_id"});
  Bookings.belongsTo(Services, { as: "service", foreignKey: "service_id"});
  Services.hasMany(Bookings, { as: "bookings", foreignKey: "service_id"});
  WorkerServices.belongsTo(Services, { as: "service", foreignKey: "service_id"});
  Services.hasMany(WorkerServices, { as: "worker_services", foreignKey: "service_id"});
  Bookings.belongsTo(Users, { as: "customer", foreignKey: "customer_id"});
  Users.hasMany(Bookings, { as: "bookings", foreignKey: "customer_id"});
  Bookings.belongsTo(Users, { as: "worker", foreignKey: "worker_id"});
  Users.hasMany(Bookings, { as: "worker_bookings", foreignKey: "worker_id"});
  Notifications.belongsTo(Users, { as: "user", foreignKey: "user_id"});
  Users.hasMany(Notifications, { as: "notifications", foreignKey: "user_id"});
  Reviews.belongsTo(Users, { as: "worker", foreignKey: "worker_id"});
  Users.hasMany(Reviews, { as: "reviews", foreignKey: "worker_id"});
  UserAddresses.belongsTo(Users, { as: "user", foreignKey: "user_id"});
  Users.hasMany(UserAddresses, { as: "user_addresses", foreignKey: "user_id"});
  Wallets.belongsTo(Users, { as: "user", foreignKey: "user_id"});
  Users.hasOne(Wallets, { as: "wallet", foreignKey: "user_id"});
  WorkerApplications.belongsTo(Users, { as: "user", foreignKey: "user_id"});
  Users.hasMany(WorkerApplications, { as: "worker_applications", foreignKey: "user_id"});
  WorkerApplications.belongsTo(Users, { as: "reviewed_by_user", foreignKey: "reviewed_by"});
  Users.hasMany(WorkerApplications, { as: "reviewed_by_worker_applications", foreignKey: "reviewed_by"});
  WorkerAttachments.belongsTo(Users, { as: "worker", foreignKey: "worker_id"});
  Users.hasMany(WorkerAttachments, { as: "worker_attachments", foreignKey: "worker_id"});
  WorkerProfiles.belongsTo(Users, { as: "user", foreignKey: "user_id"});
  Users.hasOne(WorkerProfiles, { as: "worker_profile", foreignKey: "user_id"});
  WorkerServices.belongsTo(Users, { as: "worker", foreignKey: "worker_id"});
  Users.hasMany(WorkerServices, { as: "worker_services", foreignKey: "worker_id"});
  WalletTransactions.belongsTo(Wallets, { as: "wallet", foreignKey: "wallet_id"});
  Wallets.hasMany(WalletTransactions, { as: "wallet_transactions", foreignKey: "wallet_id"});

  return {
    BookingStatusLogs,
    Bookings,
    Categories,
    Notifications,
    Payments,
    Reviews,
    Services,
    SystemSettings,
    UserAddresses,
    Users,
    WalletTransactions,
    Wallets,
    WorkerApplications,
    WorkerAttachments,
    WorkerProfiles,
    WorkerServices,
  };
}
module.exports = initModels;
module.exports.initModels = initModels;
module.exports.default = initModels;
