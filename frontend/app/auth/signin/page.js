"use client";

import { signIn, useSession } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

export default function LoginPage() {
  const { data: session, status } = useSession();
  const router = useRouter();

  useEffect(() => {
    console.log("signin: ", status);
    if (status === "authenticated") {
      router.push("/abc");
    }
  }, [status, router]);

  return (
    <div>
      <h1>Login Page</h1>
      <button onClick={() => signIn("github")}>Login with GitHub</button>
      <button onClick={() => signIn("google")}>Login with Google</button>
    </div>
  );
}
