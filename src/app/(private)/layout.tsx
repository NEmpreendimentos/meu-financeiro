import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { AppShell } from "@/components/AppShell";

export const dynamic="force-dynamic";
export default async function PrivateLayout({children}:{children:React.ReactNode}){
 if(!process.env.NEXT_PUBLIC_SUPABASE_URL||!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY)redirect("/configurar");
 const supabase=await createClient();const {data:{user}}=await supabase.auth.getUser();if(!user)redirect("/login");
 return <AppShell email={user.email??"Minha conta"}>{children}</AppShell>;
}
