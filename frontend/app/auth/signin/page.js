"use client";

import { signIn, useSession } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { redirect } from "next/navigation";

export default function LoginPage() {
  const { data: session, status } = useSession();
  const router = useRouter();

  // Redirect to "/abc" if session is active and not loading
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
    </div>
  );
}
