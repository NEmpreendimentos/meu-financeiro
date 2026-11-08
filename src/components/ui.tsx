"use client";

import { X, Plus, Search, ArrowUpRight, ArrowDownRight, Minus } from "lucide-react";
import { useEffect } from "react";

export function PageHeading({ eyebrow, title, description, action }: { eyebrow?: string; title: React.ReactNode; description?: string; action?: React.ReactNode }) {
  return <div className="mb-7 flex flex-col justify-between gap-4 sm:flex-row sm:items-end"><div>{eyebrow&&<div className="mb-2 text-[10px] font-extrabold uppercase tracking-[.17em] text-[var(--accent)]">{eyebrow}</div>}<h1 className="text-[26px] font-extrabold tracking-[-.055em] sm:text-[32px]">{title}</h1>{description&&<p className="mt-1.5 max-w-2xl text-sm leading-6 text-[var(--muted)]">{description}</p>}</div>{action&&<div className="shrink-0">{action}</div>}</div>;
}

export function StatCard({ label, value, note, icon:Icon, tone="neutral", trend }: { label:string; value:string; note?:string; icon:React.ElementType; tone?:"neutral"|"green"|"red"|"amber"; trend?:string }) {
 const color = tone==="green"?"text-[var(--positive)]":tone==="red"?"text-[var(--negative)]":tone==="amber"?"text-[var(--warning)]":"text-[var(--muted)]";
 return <div className="card p-4 sm:p-5"><div className="flex items-start justify-between"><span className="text-[11px] font-bold text-[var(--muted)] sm:text-xs">{label}</span><span className={`grid h-8 w-8 place-items-center rounded-lg bg-[var(--surface-2)] ${color}`}><Icon size={16}/></span></div><div className="mt-4 text-[21px] font-extrabold tracking-[-.05em] font-mono sm:text-2xl">{value}</div><div className="mt-1 flex items-center gap-1 text-[10px] text-[var(--muted)] sm:text-[11px]">{trend&&<span className={tone==="red"?"negative":"positive"}>{trend}</span>}{note}</div></div>;
}

export function EmptyState({ title, description, action }: { title:string; description:string; action?:React.ReactNode }) {
 return <div className="flex min-h-[200px] flex-col items-center justify-center px-5 py-10 text-center"><div className="mb-4 grid h-12 w-12 place-items-center rounded-2xl bg-[var(--accent-2)] text-[var(--accent)]"><Search size={20}/></div><h3 className="text-sm font-bold">{title}</h3><p className="mt-1 max-w-sm text-xs leading-5 text-[var(--muted)]">{description}</p>{action&&<div className="mt-4">{action}</div>}</div>;
}

export function Modal({ title, description, children, onClose }: { title:string; description?:string; children:React.ReactNode; onClose:()=>void }) {
 useEffect(()=>{const key=(e:KeyboardEvent)=>{if(e.key==="Escape")onClose()};window.addEventListener("keydown",key);return()=>window.removeEventListener("keydown",key)},[onClose]);
 return <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/45 p-0 backdrop-blur-[2px] sm:items-center sm:p-5" onMouseDown={onClose}><section role="dialog" aria-modal="true" className="max-h-[92vh] w-full max-w-[520px] overflow-y-auto rounded-t-2xl border border-[var(--line)] bg-[var(--surface)] p-5 shadow-2xl sm:rounded-2xl sm:p-6" onMouseDown={e=>e.stopPropagation()}><div className="mb-5 flex items-start justify-between"><div><h2 className="text-lg font-extrabold tracking-tight">{title}</h2>{description&&<p className="mt-1 text-xs text-[var(--muted)]">{description}</p>}</div><button className="rounded-lg p-2 text-[var(--muted)] hover:bg-[var(--surface-2)]" onClick={onClose} aria-label="Fechar"><X size={18}/></button></div>{children}</section></div>;
}

export function FormField({label,children,required}:{label:string;children:React.ReactNode;required?:boolean}){return <label className="block"><span className="label">{label}{required&&<span className="text-[var(--negative)]"> *</span>}</span>{children}</label>}
export function Message({children,tone="error"}:{children:React.ReactNode;tone?:"error"|"success"}){return <div role="status" className={`rounded-lg px-3 py-2.5 text-xs font-semibold ${tone==="error"?"bg-[#fff0ef] text-[#a93831] dark:bg-[#462724] dark:text-[#ffaba4]":"bg-[var(--accent-2)] text-[var(--accent)]"}`}>{children}</div>}
export function PrimaryButton({children,...props}:{children:React.ReactNode;type?:"button"|"submit";disabled?:boolean;onClick?:()=>void;className?:string}){return <button className={`btn-primary ${props.className??""}`} {...props}>{children}</button>}
export function AddButton({children="Adicionar",...props}:{children?:React.ReactNode;onClick:()=>void}){return <button className="btn-primary" {...props}><Plus size={16}/>{children}</button>}
export function Sign({positive}:{positive:boolean}){return positive?<ArrowUpRight size={15} className="positive"/>:<ArrowDownRight size={15} className="negative"/>}
