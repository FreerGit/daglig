import OAuthButton from "@/app/components/OAuthButton";
import { getServerSession } from "next-auth";
import { redirect } from "next/navigation";

export default async function LoginPage() {
  const session = await getServerSession();

  if (session) {
    redirect("/home");
  }

  return (
    <div>
      <h1>Login Page</h1>
      <OAuthButton provider="github" />
      <OAuthButton provider="google" />
    </div>
  );
}
