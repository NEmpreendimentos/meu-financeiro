export type EntryType = "income" | "expense";
export type TxStatus = "pending" | "paid" | "received";
export type Transaction = {
  id: string;
  description: string;
  amount: number;
  kind: EntryType;
  category_id: string | null;
  account_id: string | null;
  transaction_date: string;
  status: TxStatus;
  notes: string | null;
  card_purchase_id?: string | null;
  category?: { name: string; color: string | null } | null;
};
export type Account = { id: string; name: string; kind: string; opening_balance: number; balance?: number; color: string | null };
export type FinanceCategory = { id: string; name: string; kind: EntryType | "both"; color: string | null };

export const CATEGORY_COLORS = ["#0B7A59", "#D48A37", "#5B73C5", "#D86C63", "#7A5E9B", "#56959A", "#A3A33D", "#7C8794"];
