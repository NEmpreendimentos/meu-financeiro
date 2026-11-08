import { brl } from "@/lib/finance/format";

export function Amount({ value, sign = false, className = "" }: { value: number; sign?: boolean; className?: string }) {
  const prefix = sign && value > 0 ? "+" : "";
  return <span className={className} aria-label={brl(value)}>{prefix}{brl(value)}</span>;
}
