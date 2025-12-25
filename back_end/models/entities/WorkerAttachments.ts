import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Users } from "./Users";

@Index("worker_id", ["workerId"], {})
@Entity("worker_attachments", { schema: "home_service" })
export class WorkerAttachments {
  @PrimaryGeneratedColumn({ type: "bigint", name: "id", unsigned: true })
  id: string;

  @Column("bigint", { name: "worker_id", unsigned: true })
  workerId: string;

  @Column("enum", {
    name: "type",
    enum: ["identity_front", "identity_back", "certificate", "other"],
  })
  type: "identity_front" | "identity_back" | "certificate" | "other";

  @Column("varchar", { name: "url", length: 255 })
  url: string;

  @Column("timestamp", { name: "verified_at", nullable: true })
  verifiedAt: Date | null;

  @ManyToOne(() => Users, (users) => users.workerAttachments, {
    onDelete: "CASCADE",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "worker_id", referencedColumnName: "id" }])
  worker: Users;
}
