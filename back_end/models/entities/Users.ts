import {
  Column,
  Entity,
  Index,
  OneToMany,
  OneToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Bookings } from "./Bookings";
import { Notifications } from "./Notifications";
import { Reviews } from "./Reviews";
import { UserAddresses } from "./UserAddresses";
import { Wallets } from "./Wallets";
import { WorkerAttachments } from "./WorkerAttachments";
import { WorkerProfiles } from "./WorkerProfiles";
import { WorkerServices } from "./WorkerServices";

@Index("phone", ["phone"], { unique: true })
@Index("code", ["code"], { unique: true })
@Index("email", ["email"], { unique: true })
@Index("idx_phone", ["phone"], {})
@Index("idx_role", ["role"], {})
@Entity("users", { schema: "home_service" })
export class Users {
  @PrimaryGeneratedColumn({ type: "bigint", name: "id", unsigned: true })
  id: string;

  @Column("varchar", { name: "code", nullable: true, unique: true, length: 20 })
  code: string | null;

  @Column("varchar", { name: "full_name", length: 100 })
  fullName: string;

  @Column("varchar", { name: "phone", unique: true, length: 15 })
  phone: string;

  @Column("varchar", {
    name: "email",
    nullable: true,
    unique: true,
    length: 100,
  })
  email: string | null;

  @Column("varchar", { name: "password_hash", length: 255 })
  passwordHash: string;

  @Column("varchar", { name: "avatar_url", nullable: true, length: 255 })
  avatarUrl: string | null;

  @Column("enum", {
    name: "role",
    enum: ["customer", "worker", "admin"],
    default: () => "'customer'",
  })
  role: "customer" | "worker" | "admin";

  @Column("enum", {
    name: "status",
    nullable: true,
    enum: ["active", "inactive", "banned", "pending_verification"],
    default: () => "'active'",
  })
  status: "active" | "inactive" | "banned" | "pending_verification" | null;

  @Column("text", { name: "fcm_token", nullable: true })
  fcmToken: string | null;

  @Column("timestamp", {
    name: "created_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  createdAt: Date | null;

  @Column("timestamp", {
    name: "updated_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  updatedAt: Date | null;

  @Column("timestamp", { name: "deleted_at", nullable: true })
  deletedAt: Date | null;

  @OneToMany(() => Bookings, (bookings) => bookings.customer)
  bookings: Bookings[];

  @OneToMany(() => Bookings, (bookings) => bookings.worker)
  bookings2: Bookings[];

  @OneToMany(() => Notifications, (notifications) => notifications.user)
  notifications: Notifications[];

  @OneToMany(() => Reviews, (reviews) => reviews.worker)
  reviews: Reviews[];

  @OneToMany(() => UserAddresses, (userAddresses) => userAddresses.user)
  userAddresses: UserAddresses[];

  @OneToOne(() => Wallets, (wallets) => wallets.user)
  wallets: Wallets;

  @OneToMany(
    () => WorkerAttachments,
    (workerAttachments) => workerAttachments.worker
  )
  workerAttachments: WorkerAttachments[];

  @OneToOne(() => WorkerProfiles, (workerProfiles) => workerProfiles.user)
  workerProfiles: WorkerProfiles;

  @OneToMany(() => WorkerServices, (workerServices) => workerServices.worker)
  workerServices: WorkerServices[];
}
