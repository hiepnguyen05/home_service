import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Bookings } from "./Bookings";
import { Categories } from "./Categories";
import { WorkerServices } from "./WorkerServices";

@Index("category_id", ["categoryId"], {})
@Entity("services", { schema: "home_service" })
export class Services {
  @PrimaryGeneratedColumn({ type: "bigint", name: "id", unsigned: true })
  id: string;

  @Column("int", { name: "category_id", unsigned: true })
  categoryId: number;

  @Column("varchar", { name: "name", length: 150 })
  name: string;

  @Column("text", { name: "description", nullable: true })
  description: string | null;

  @Column("enum", {
    name: "price_type",
    nullable: true,
    enum: ["fixed", "hourly", "quote"],
    default: () => "'fixed'",
  })
  priceType: "fixed" | "hourly" | "quote" | null;

  @Column("decimal", { name: "default_price", precision: 15, scale: 2 })
  defaultPrice: string;

  @Column("int", {
    name: "duration_minutes",
    nullable: true,
    default: () => "'60'",
  })
  durationMinutes: number | null;

  @Column("decimal", {
    name: "commission_rate",
    nullable: true,
    precision: 5,
    scale: 2,
    default: () => "'10.00'",
  })
  commissionRate: string | null;

  @Column("tinyint", {
    name: "is_active",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  isActive: boolean | null;

  @OneToMany(() => Bookings, (bookings) => bookings.service)
  bookings: Bookings[];

  @ManyToOne(() => Categories, (categories) => categories.services, {
    onDelete: "NO ACTION",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "category_id", referencedColumnName: "id" }])
  category: Categories;

  @OneToMany(() => WorkerServices, (workerServices) => workerServices.service)
  workerServices: WorkerServices[];
}
