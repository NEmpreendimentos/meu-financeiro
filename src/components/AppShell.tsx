"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { ArrowUpRight, Bell, ChevronDown, CircleHelp, LogOut, Menu, Moon, Sun, X } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { navigation, settingsItem } from "@/lib/navigation";

function Brand() {
  return <Link href="/" className="flex items-center gap-3 px-1 py-2" aria-label="Meu Financeiro, início">
    <span className="grid h-10 w-10 place-items-center rounded-xl bg-[#087f5b] text-sm font-black tracking-[-.08em] text-white"><span>m<span className="opacity-60">f</span></span></span>
    <span className="text-[15px] font-extrabold tracking-[-.04em]">meu<span className="font-medium text-[var(--muted)]">financeiro</span></span>
  </Link>;
}

export function AppShell({ children, email }: { children: React.ReactNode; email: string }) {
  const pathname = usePathname();
  const router = useRouter();
  const [dark, setDark] = useState(false);
  const [open, setOpen] = useState(false);
  useEffect(() => {
    const saved = localStorage.getItem("mf-theme");
    const isDark = saved ? saved === "dark" : window.matchMedia("(prefers-color-scheme: dark)").matches;
    setDark(isDark); document.documentElement.classList.toggle("dark", isDark);
  }, []);
  function toggleTheme() {
    const value = !dark; setDark(value); document.documentElement.classList.toggle("dark", value); localStorage.setItem("mf-theme", value ? "dark" : "light");
  }
  async function logout() {
    await createClient().auth.signOut(); router.replace("/login"); router.refresh();
  }
  const linkClass = (href: string) => `group flex items-center gap-3 rounded-xl px-3 py-[10px] text-[13px] font-semibold transition-colors ${pathname === href ? "bg-[var(--accent-2)] text-[var(--accent)]" : "text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--ink)]"}`;
  const links = <>
    <div className="px-3 pb-2 pt-7 text-[10px] font-extrabold uppercase tracking-[.16em] text-[var(--muted)]">Meu dinheiro</div>
    {navigation.map(({ label, href, icon: Icon }) => <Link key={href} href={href} onClick={() => setOpen(false)} className={linkClass(href)}><Icon size={17} strokeWidth={pathname===href?2.4:1.9}/>{label}{href==="/cartoes"&&<span className="ml-auto rounded-full bg-[var(--surface)] px-2 py-0.5 text-[10px] text-[var(--muted)]">0</span>}</Link>)}
    <div className="mt-8 px-3 pb-2 text-[10px] font-extrabold uppercase tracking-[.16em] text-[var(--muted)]">Preferências</div>
    <Link href={settingsItem.href} onClick={() => setOpen(false)} className={linkClass(settingsItem.href)}><settingsItem.icon size={17}/>{settingsItem.label}</Link>
  </>;
  return <div className="min-h-screen bg-[var(--canvas)]">
    <aside className="fixed inset-y-0 left-0 z-30 hidden w-[246px] flex-col border-r border-[var(--line)] bg-[var(--surface)] px-5 py-5 lg:flex">
      <Brand/><div className="mt-6 rounded-xl bg-[var(--surface-2)] p-3"><div className="flex items-center justify-between"><span className="text-[10px] font-bold uppercase tracking-[.12em] text-[var(--muted)]">Visão do mês</span><span className="h-2 w-2 rounded-full bg-[var(--accent)]"/></div><div className="mt-1 text-xs font-semibold capitalize">{new Intl.DateTimeFormat("pt-BR",{month:"long",year:"numeric"}).format(new Date())}</div></div>
      <nav className="flex-1">{links}</nav>
      <div className="border-t border-[var(--line)] pt-4"><button className="flex w-full items-center gap-3 rounded-xl px-2 py-2 text-left hover:bg-[var(--surface-2)]"><span className="grid h-9 w-9 place-items-center rounded-full bg-[#e6f4ed] text-xs font-bold text-[#087f5b]">{email.slice(0,1).toUpperCase()}</span><span className="min-w-0 flex-1"><span className="block truncate text-xs font-bold">{email.split("@")[0]}</span><span className="block truncate text-[10px] text-[var(--muted)]">Conta pessoal</span></span><ChevronDown size={15} className="text-[var(--muted)]"/></button></div>
    </aside>
    {open && <div className="fixed inset-0 z-50 bg-black/40 lg:hidden" onClick={() => setOpen(false)}><aside className="h-full w-[280px] bg-[var(--surface)] p-5" onClick={e=>e.stopPropagation()}><div className="flex items-center justify-between"><Brand/><button aria-label="Fechar menu" className="rounded-lg p-2" onClick={()=>setOpen(false)}><X size={18}/></button></div><nav>{links}</nav></aside></div>}
    <main className="min-h-screen lg:pl-[246px]">
      <header className="sticky top-0 z-20 flex h-[68px] items-center justify-between border-b border-[var(--line)] bg-[color-mix(in_srgb,var(--canvas)_88%,transparent)] px-4 backdrop-blur-xl sm:px-7 lg:px-10">
        <div className="flex items-center gap-3"><button className="rounded-lg p-2 text-[var(--muted)] hover:bg-[var(--surface)] lg:hidden" onClick={()=>setOpen(true)} aria-label="Abrir menu"><Menu size={20}/></button><div className="text-xs text-[var(--muted)]"><span className="hidden sm:inline">Seu dinheiro, com clareza</span><span className="sm:hidden">Meu Financeiro</span></div></div>
        <div className="flex items-center gap-1"><button aria-label={dark?"Usar tema claro":"Usar tema escuro"} title="Alternar tema" onClick={toggleTheme} className="rounded-lg p-2.5 text-[var(--muted)] hover:bg-[var(--surface)]">{dark?<Sun size={17}/>:<Moon size={17}/>}</button><button title="Ajuda" aria-label="Ajuda" className="hidden rounded-lg p-2.5 text-[var(--muted)] hover:bg-[var(--surface)] sm:block"><CircleHelp size={17}/></button><button onClick={logout} title="Sair" aria-label="Sair" className="rounded-lg p-2.5 text-[var(--muted)] hover:bg-[var(--surface)]"><LogOut size={17}/></button><div className="ml-2 hidden h-8 w-px bg-[var(--line)] sm:block"/><div className="ml-2 grid h-8 w-8 place-items-center rounded-full bg-[var(--accent)] text-xs font-bold text-white lg:hidden">{email.slice(0,1).toUpperCase()}</div></div>
      </header>
      <div className="mx-auto max-w-[1440px] px-4 pb-28 pt-7 sm:px-7 sm:pt-9 lg:px-10 lg:pb-12">{children}</div>
    </main>
    <nav className="fixed inset-x-0 bottom-0 z-30 grid grid-cols-5 border-t border-[var(--line)] bg-[var(--surface)]/95 px-2 py-2 pb-[max(env(safe-area-inset-bottom),8px)] backdrop-blur-xl lg:hidden">
      {[...navigation.slice(0,4),navigation[5]].map(({label,href,icon:Icon})=><Link key={href} href={href} className={`flex flex-col items-center gap-1 rounded-lg py-1.5 text-[9px] font-semibold ${pathname===href?"text-[var(--accent)]":"text-[var(--muted)]"}`}><Icon size={18}/>{label.split(" ")[0]}</Link>)}
    </nav>
  </div>;
}
