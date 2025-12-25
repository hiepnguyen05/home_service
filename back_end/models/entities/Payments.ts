import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Bookings } from "./Bookings";

@Index("booking_id", ["bookingId"], {})
@Entity("payments", { schema: "home_service" })
export class Payments {
  @PrimaryGeneratedColumn({ type: "bigint", name: "id", unsigned: true })
  id: string;

  @Column("bigint", { name: "booking_id", unsigned: true })
  bookingId: string;

  @Column("enum", {
    name: "method",
    enum: ["cash", "momo", "stripe", "wallet"],
  })
  method: "cash" | "momo" | "stripe" | "wallet";

  @Column("decimal", { name: "amount", precision: 15, scale: 2 })
  amount: string;

  @Column("varchar", { name: "transaction_ref", nullable: true, length: 100 })
  transactionRef: string | null;

  @Column("enum", {
    name: "status",
    nullable: true,
    enum: ["pending", "paid", "failed", "refunded"],
    default: () => "'pending'",
  })
  status: "pending" | "paid" | "failed" | "refunded" | null;

  @Column("datetime", { name: "paid_at", nullable: true })
  paidAt: Date | null;

  @ManyToOne(() => Bookings, (bookings) => bookings.payments, {
    onDelete: "NO ACTION",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "booking_id", referencedColumnName: "id" }])
  booking: Bookings;
}
