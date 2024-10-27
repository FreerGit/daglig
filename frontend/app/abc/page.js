import { getServerSession } from "next-auth";
import { redirect } from "next/navigation";

export default async function LoginPage() {
  const session = await getServerSession();
  console.log("Session", session);

  if (!session) {
    redirect("/auth/signin");
    return null;
  }

  return (
    <div>
      <h1>Hello!</h1>
    </div>
  );
}
