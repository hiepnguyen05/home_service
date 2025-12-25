import { Column, Entity, Index, JoinColumn, OneToOne } from "typeorm";
import { Users } from "./Users";

@Index("citizen_id", ["citizenId"], { unique: true })
@Entity("worker_profiles", { schema: "home_service" })
export class WorkerProfiles {
  @Column("bigint", { primary: true, name: "user_id", unsigned: true })
  userId: string;

  @Column("varchar", {
    name: "citizen_id",
    nullable: true,
    unique: true,
    length: 20,
  })
  citizenId: string | null;

  @Column("text", { name: "bio", nullable: true })
  bio: string | null;

  @Column("tinyint", {
    name: "experience_years",
    nullable: true,
    unsigned: true,
    default: () => "'0'",
  })
  experienceYears: number | null;

  @Column("int", { name: "radius_km", nullable: true, default: () => "'10'" })
  radiusKm: number | null;

  @Column("tinyint", {
    name: "is_verified",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isVerified: boolean | null;

  @Column("tinyint", {
    name: "is_online",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isOnline: boolean | null;

  @Column("decimal", {
    name: "current_lat",
    nullable: true,
    precision: 10,
    scale: 8,
  })
  currentLat: string | null;

  @Column("decimal", {
    name: "current_long",
    nullable: true,
    precision: 11,
    scale: 8,
  })
  currentLong: string | null;

  @Column("decimal", {
    name: "rating_avg",
    nullable: true,
    precision: 3,
    scale: 2,
    default: () => "'5.00'",
  })
  ratingAvg: string | null;

  @Column("int", { name: "total_jobs", nullable: true, default: () => "'0'" })
  totalJobs: number | null;

  @Column("int", {
    name: "total_reviews",
    nullable: true,
    default: () => "'0'",
  })
  totalReviews: number | null;

  @OneToOne(() => Users, (users) => users.workerProfiles, {
    onDelete: "CASCADE",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "user_id", referencedColumnName: "id" }])
  user: Users;
}
