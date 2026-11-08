import { LayoutDashboard, ArrowLeftRight, CreditCard, HandCoins, TrendingUp, ChartNoAxesCombined, Settings } from "lucide-react";

export const navigation = [
  { label: "Visão geral", href: "/", icon: LayoutDashboard },
  { label: "Lançamentos", href: "/lancamentos", icon: ArrowLeftRight },
  { label: "Cartões", href: "/cartoes", icon: CreditCard },
  { label: "Dívidas", href: "/dividas", icon: HandCoins },
  { label: "Investimentos", href: "/investimentos", icon: TrendingUp },
  { label: "Relatórios", href: "/relatorios", icon: ChartNoAxesCombined },
];
export const settingsItem = { label: "Configurações", href: "/configuracoes", icon: Settings };
