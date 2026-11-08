import { redirect } from "next/navigation";

export const dynamic="force-dynamic";
export default function AuthLayout({children}:{children:React.ReactNode}){
 if(!process.env.NEXT_PUBLIC_SUPABASE_URL||!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY)redirect("/configurar");
 return <main className="flex min-h-screen items-center justify-center px-4 py-12"><div className="w-full max-w-[440px]">{children}</div></main>;
}
