import { Column, Entity, Index, JoinColumn, ManyToOne } from "typeorm";
import { Users } from "./Users";
import { Services } from "./Services";

@Index("service_id", ["serviceId"], {})
@Entity("worker_services", { schema: "home_service" })
export class WorkerServices {
  @Column("bigint", { primary: true, name: "worker_id", unsigned: true })
  workerId: string;

  @Column("bigint", { primary: true, name: "service_id", unsigned: true })
  serviceId: string;

  @Column("tinyint", {
    name: "is_active",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  isActive: boolean | null;

  @ManyToOne(() => Users, (users) => users.workerServices, {
    onDelete: "CASCADE",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "worker_id", referencedColumnName: "id" }])
  worker: Users;

  @ManyToOne(() => Services, (services) => services.workerServices, {
    onDelete: "CASCADE",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "service_id", referencedColumnName: "id" }])
  service: Services;
}
