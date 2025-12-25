import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Bookings } from "./Bookings";
import { Users } from "./Users";

@Index("booking_id", ["bookingId"], { unique: true })
@Index("worker_id", ["workerId"], {})
@Entity("reviews", { schema: "home_service" })
export class Reviews {
  @PrimaryGeneratedColumn({ type: "bigint", name: "id", unsigned: true })
  id: string;

  @Column("bigint", { name: "booking_id", unique: true, unsigned: true })
  bookingId: string;

  @Column("bigint", { name: "customer_id", unsigned: true })
  customerId: string;

  @Column("bigint", { name: "worker_id", unsigned: true })
  workerId: string;

  @Column("tinyint", { name: "rating", comment: "1 to 5", unsigned: true })
  rating: number;

  @Column("text", { name: "comment", nullable: true })
  comment: string | null;

  @Column("json", { name: "images_json", nullable: true })
  imagesJson: object | null;

  @Column("tinyint", {
    name: "is_hidden",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isHidden: boolean | null;

  @Column("timestamp", {
    name: "created_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  createdAt: Date | null;

  @OneToOne(() => Bookings, (bookings) => bookings.reviews, {
    onDelete: "NO ACTION",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "booking_id", referencedColumnName: "id" }])
  booking: Bookings;

  @ManyToOne(() => Users, (users) => users.reviews, {
    onDelete: "NO ACTION",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "worker_id", referencedColumnName: "id" }])
  worker: Users;
}
