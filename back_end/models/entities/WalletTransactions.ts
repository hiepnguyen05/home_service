import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Wallets } from "./Wallets";

@Index("wallet_id", ["walletId"], {})
@Entity("wallet_transactions", { schema: "home_service" })
export class WalletTransactions {
  @PrimaryGeneratedColumn({ type: "bigint", name: "id", unsigned: true })
  id: string;

  @Column("bigint", { name: "wallet_id", unsigned: true })
  walletId: string;

  @Column("decimal", { name: "amount", precision: 15, scale: 2 })
  amount: string;

  @Column("enum", {
    name: "type",
    enum: ["deposit", "withdrawal", "payment_fee", "income", "refund"],
  })
  type: "deposit" | "withdrawal" | "payment_fee" | "income" | "refund";

  @Column("bigint", { name: "booking_id", nullable: true, unsigned: true })
  bookingId: string | null;

  @Column("varchar", { name: "description", nullable: true, length: 255 })
  description: string | null;

  @Column("enum", {
    name: "status",
    nullable: true,
    enum: ["pending", "success", "failed"],
    default: () => "'success'",
  })
  status: "pending" | "success" | "failed" | null;

  @Column("timestamp", {
    name: "created_at",
    nullable: true,
    default: () => "CURRENT_TIMESTAMP",
  })
  createdAt: Date | null;

  @ManyToOne(() => Wallets, (wallets) => wallets.walletTransactions, {
    onDelete: "NO ACTION",
    onUpdate: "NO ACTION",
  })
  @JoinColumn([{ name: "wallet_id", referencedColumnName: "id" }])
  wallet: Wallets;
}
