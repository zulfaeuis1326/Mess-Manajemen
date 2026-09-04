"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const router = useRouter();
  const supabase = createClient();

  async function handleLogin(e) {
    e.preventDefault();
    setError("");

    const { data, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (authError) {
      setError("Email atau kata sandi salah.");
      return;
    }

    const { data: profil } = await supabase
      .from("profil")
      .select("role")
      .eq("id", data.user.id)
      .single();

    if (profil?.role === "super_admin") router.push("/dashboard/super-admin");
    else if (profil?.role === "admin_mess") router.push("/dashboard/admin-mess");
    else router.push("/dashboard/karyawan");
  }

  return (
    <main className="min-h-screen flex items-center justify-center px-6 bg-paper">
      <form onSubmit={handleLogin} className="w-full max-w-sm bg-panel rounded-xl p-6 border border-hair">
        <h1 className="font-serif text-2xl mb-1">Masuk ke Mess Ku</h1>
        <p className="text-sm text-inkMuted mb-6">Gunakan akun yang diberikan admin.</p>

        <label className="text-xs text-inkMuted">Email</label>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full mt-1 mb-4 px-3 py-2 rounded-lg border border-hair text-sm"
          required
        />

        <label className="text-xs text-inkMuted">Kata sandi</label>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="w-full mt-1 mb-4 px-3 py-2 rounded-lg border border-hair text-sm"
          required
        />

        {error && <p className="text-xs text-red-600 mb-3">{error}</p>}

        <button type="submit" className="w-full py-2.5 rounded-lg bg-blueprint text-white text-sm font-medium">
          Masuk
        </button>
      </form>
    </main>
  );
}
