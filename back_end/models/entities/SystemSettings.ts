import { Column, Entity } from "typeorm";

@Entity("system_settings", { schema: "home_service" })
export class SystemSettings {
  @Column("varchar", { primary: true, name: "key", length: 50 })
  key: string;

  @Column("text", { name: "value" })
  value: string;

  @Column("varchar", { name: "description", nullable: true, length: 255 })
  description: string | null;
}
