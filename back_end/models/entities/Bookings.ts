import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  OneToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { BookingStatusLogs } from "./BookingStatusLogs";
import { Users } from "./Users";
import { Services } from "./Services";
import { Payments } from "./Payments";
import { Reviews } from "./Reviews";

@Index("code", ["code"], { unique: true })
@Index("customer_id", ["customerId"], {})
@Index("worker_id", ["workerId"], {})
@Index("service_id", ["serviceId"], {})
@Index("idx_date_status", ["scheduledAt", "status"], {})
@Entity("bookings", { schema: "home_service" })
export class Bookings {
  @PrimaryGeneratedColumn({ type: "bigint", name: "id", unsigned: true })
  id: string;

  @Column("varchar", { name: "code", unique: true, length: 20 })
  code: string;

  @Column("bigint", { name: "customer_id", unsigned: true })
  customerId: string;

  @Column("bigint", { name: "worker_id", nullable: true, unsigned: true })
  workerId: string | null;

  @Column("bigint", { name: "service_id", unsigned: true })
  serviceId: string;

  @Column("bigint", { name: "address_id", unsigned: true })
  addressId: string;

  @Column("decimal", { name: "base_price", precision: 15, scale: 2 })
  basePrice: string;

  @Column("decimal", { name: "platform_fee", precision: 15, scale: 2 })
  platformFee: string;

  @Column("decimal", { name: "total_amount", precision: 15, scale: 2 })
  totalAmount: string;

  @Column("datetime", { name: "scheduled_at" })
  scheduledAt: Date;

  @Column("datetime", { name: "arrived_at", nullable: true })
  arrivedAt: Date | null;

  @Column("datetime", { name: "started_at", nullable: true })
  startedAt: Date | null;

  @Column("datetime", { name: "completed_at", nullable: true })
  completedAt: Date | null;

  @Column("enum", {
    name: "status",
    nullable: true,
    enum: [
      "pending",
      "confirmed",
      "arriving",
      "in_progress",
      "completed",
      "cancelled",
      "failed",
    ],
    default: () => "'pending'",
  })
  status:
    | "pending"
    | "confirmed"
    | "arriving"
    | "in_progress"
    | "completed"
    | "cancelled"
    | "failed"
    | null;

  @Column("text", { name: "customer_note", nullable: true })
  customerNote: string | null;

  @Column("text", { name: "cancel_reason", nullable: true })
  cancelReason: string | null;

  @Column("bigint", { name: "canceled_by", nullable: true, unsigned: true })
  canceledBy: string | null;

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

  @OneToMany(
    () => BookingStatusLogs,
    (bookingStatusLogs) => bookingStatusLogs.booking
  )
  bookingStatusLogs: BookingStatusLogs[];

  @ManyToOne(() => Users, (users) => users.bookings, {
    onDelete: "NO ACTION",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "customer_id", referencedColumnName: "id" }])
  customer: Users;

  @ManyToOne(() => Users, (users) => users.bookings2, {
    onDelete: "NO ACTION",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "worker_id", referencedColumnName: "id" }])
  worker: Users;

  @ManyToOne(() => Services, (services) => services.bookings, {
    onDelete: "NO ACTION",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "service_id", referencedColumnName: "id" }])
  service: Services;

  @OneToMany(() => Payments, (payments) => payments.booking)
  payments: Payments[];

  @OneToOne(() => Reviews, (reviews) => reviews.booking)
  reviews: Reviews;
}
