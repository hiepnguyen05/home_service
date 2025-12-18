import {
  Column,
  Entity,
  Index,
  JoinColumn,
  OneToMany,
  OneToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { WalletTransactions } from "./WalletTransactions";
import { Users } from "./Users";

@Index("user_id", ["userId"], { unique: true })
@Entity("wallets", { schema: "home_service" })
export class Wallets {
  @PrimaryGeneratedColumn({ type: "bigint", name: "id", unsigned: true })
  id: string;

  @Column("bigint", { name: "user_id", unique: true, unsigned: true })
  userId: string;

  @Column("decimal", {
    name: "balance",
    nullable: true,
    precision: 15,
    scale: 2,
    default: () => "'0.00'",
  })
  balance: string | null;

  @Column("decimal", {
    name: "hold_balance",
    nullable: true,
    precision: 15,
    scale: 2,
    default: () => "'0.00'",
  })
  holdBalance: string | null;

  @Column("char", {
    name: "currency",
    nullable: true,
    length: 3,
    default: () => "'VND'",
  })
  currency: string | null;

  @Column("timestamp", {
    name: "updated_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  updatedAt: Date | null;

  @OneToMany(
    () => WalletTransactions,
    (walletTransactions) => walletTransactions.wallet
  )
  walletTransactions: WalletTransactions[];

  @OneToOne(() => Users, (users) => users.wallets, {
    onDelete: "NO ACTION",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "user_id", referencedColumnName: "id" }])
  user: Users;
}
