import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Users } from "./Users";

@Index("user_id", ["userId"], {})
@Entity("user_addresses", { schema: "home_service" })
export class UserAddresses {
  @PrimaryGeneratedColumn({ type: "bigint", name: "id", unsigned: true })
  id: string;

  @Column("bigint", { name: "user_id", unsigned: true })
  userId: string;

  @Column("varchar", {
    name: "name",
    nullable: true,
    length: 50,
    default: () => "'Nhà riêng'",
  })
  name: string | null;

  @Column("varchar", { name: "address", length: 255 })
  address: string;

  @Column("decimal", { name: "latitude", precision: 10, scale: 8 })
  latitude: string;

  @Column("decimal", { name: "longitude", precision: 11, scale: 8 })
  longitude: string;

  @Column("tinyint", {
    name: "is_default",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isDefault: boolean | null;

  @Column("timestamp", {
    name: "created_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  createdAt: Date | null;

  @ManyToOne(() => Users, (users) => users.userAddresses, {
    onDelete: "CASCADE",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "user_id", referencedColumnName: "id" }])
  user: Users;
}
