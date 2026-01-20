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
@Entity("notifications", { schema: "home_service" })
export class Notifications {
  @PrimaryGeneratedColumn({ type: "bigint", name: "id", unsigned: true })
  id: string;

  @Column("bigint", { name: "user_id", unsigned: true })
  userId: string;

  @Column("varchar", { name: "title", length: 255 })
  title: string;

  @Column("text", { name: "message" })
  message: string;

  @Column("varchar", { name: "type", nullable: true, length: 50 })
  type: string | null;

  @Column("json", { name: "data_json", nullable: true })
  dataJson: object | null;

  @Column("tinyint", {
    name: "is_read",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isRead: boolean | null;

  @Column("timestamp", {
    name: "created_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  createdAt: Date | null;

  @ManyToOne(() => Users, (users) => users.notifications, {
    onDelete: "CASCADE",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "user_id", referencedColumnName: "id" }])
  user: Users;
}
