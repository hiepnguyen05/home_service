import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from "typeorm";
import { Services } from "./Services";

@Entity("categories", { schema: "home_service" })
export class Categories {
  @PrimaryGeneratedColumn({ type: "int", name: "id", unsigned: true })
  id: number;

  @Column("varchar", { name: "name", length: 100 })
  name: string;

  @Column("varchar", { name: "icon_url", nullable: true, length: 255 })
  iconUrl: string | null;

  @Column("tinyint", {
    name: "is_active",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  isActive: boolean | null;

  @Column("int", { name: "sort_order", nullable: true, default: () => "'0'" })
  sortOrder: number | null;

  @OneToMany(() => Services, (services) => services.category)
  services: Services[];
}
