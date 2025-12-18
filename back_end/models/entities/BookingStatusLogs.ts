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
@Entity("booking_status_logs", { schema: "home_service" })
export class BookingStatusLogs {
  @PrimaryGeneratedColumn({ type: "bigint", name: "id", unsigned: true })
  id: string;

  @Column("bigint", { name: "booking_id", unsigned: true })
  bookingId: string;

  @Column("varchar", { name: "status_from", nullable: true, length: 50 })
  statusFrom: string | null;

  @Column("varchar", { name: "status_to", length: 50 })
  statusTo: string;

  @Column("bigint", { name: "changed_by", nullable: true, unsigned: true })
  changedBy: string | null;

  @Column("varchar", { name: "note", nullable: true, length: 255 })
  note: string | null;

  @Column("timestamp", {
    name: "created_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  createdAt: Date | null;

  @ManyToOne(() => Bookings, (bookings) => bookings.bookingStatusLogs, {
    onDelete: "CASCADE",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "booking_id", referencedColumnName: "id" }])
  booking: Bookings;
}
