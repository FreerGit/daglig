import { getServerSession } from "next-auth";
import GithubProvider from "next-auth/providers/github";
import GoogleProvider from "next-auth/providers/google";

const authOptions = {
  providers: [
    GithubProvider({
      clientId: process.env.GITHUB_CLIENT_ID,
      clientSecret: process.env.GITHUB_CLIENT_SECRET,
    }),
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    }),
  ],
  pages: {
    signIn: "/auth/signin",
    // error: "auth/error",
  },
  callbacks: {
    async signIn({ user, account }) {
      console.log("signIn callback");
      const oauth = {
        provider_account_id: account.providerAccountId,
        email: user.email,
        name: user.name,
        image: user.image,
        provider: account.provider,
        access_token: account.access_token,
        expires_at: account.expires_at,
      };

      const response = await fetch(
        `${process.env.SERVER_URL}/api/proxy/signup`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(oauth),
        }
      );

      if (response.ok) {
        const data = await response.json();
        console.log(data);
        user.id = data.id;
        return true;
      }

      return false;
    },
    async jwt({ token, user, account }) {
      console.log("jwt callback");
      if (user) {
        token.id = user.id;
      }
      if (account) {
        token.accessToken = account.access_token;
        token.provider = account.provider;
      }
      return token;
    },
    async session({ session, token }) {
      console.log("session callback");
      session.id = token.id;
      session.accessToken = token.accessToken;
      session.provider = token.provider;
      return session;
    },
  },
  secret: process.env.NEXTAUTH_SECRET,
};

export { authOptions };
