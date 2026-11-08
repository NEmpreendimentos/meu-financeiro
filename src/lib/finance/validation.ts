import { z } from "zod";

const amount = z.coerce.number().positive("Informe um valor maior que zero.");
export const transactionSchema = z.object({
  description: z.string().trim().min(1).max(120), amount,
  kind: z.enum(["income", "expense"]), category_id: z.string().uuid().optional().or(z.literal("")),
  account_id: z.string().uuid().optional().or(z.literal("")), transaction_date: z.string().date(),
  status: z.enum(["pending", "paid", "received"]), notes: z.string().max(500).optional(),
});
export const accountSchema = z.object({ name:z.string().trim().min(1).max(80), kind:z.enum(["checking","savings","cash","wallet","investment","other"]), institution:z.string().max(100).optional(), opening_balance:z.coerce.number(), color:z.string().regex(/^#[0-9a-fA-F]{6}$/) });
export const cardSchema = z.object({ name:z.string().trim().min(1).max(80), institution:z.string().max(100).optional(), credit_limit:amount, closing_day:z.coerce.number().int().min(1).max(31), due_day:z.coerce.number().int().min(1).max(31), color:z.string().regex(/^#[0-9a-fA-F]{6}$/) });
export const debtSchema = z.object({ name:z.string().trim().min(1).max(100), creditor:z.string().max(100).optional(), initial_amount:amount, installment_count:z.coerce.number().int().positive().optional(), installment_amount:z.coerce.number().positive().optional(), next_due_date:z.string().optional(), interest_rate:z.coerce.number().min(0).optional(), notes:z.string().max(500).optional() });
export const investmentSchema = z.object({ name:z.string().trim().min(1).max(100), institution:z.string().max(100).optional(), invested_amount:z.coerce.number().min(0), invested_at:z.string().date(), manual_return_rate:z.coerce.number().optional(), current_value:z.coerce.number().min(0), accumulated_earnings:z.coerce.number(), notes:z.string().max(500).optional() });
