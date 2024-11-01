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
    async jwt({ token, account, profile }) {
      let serverUrl = `${process.env.SERVER_URL}/api/proxy/signup`;
      if (account) {
        const response = await fetch(serverUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: {
            provider_user_id: profile.id,
            email: profile.email,
            name: profile.name,
            image: profile.image,
            provider: account.provider,
            access_token: account.access_token,
          },
        });

        const data = await response.json();
        token.access_token = data.access_token;
        token.provider = account.provider;
        token.provider_user_id = profile.id;
      }
      return token;
    },
    async session({ session, token }) {
      session.access_token = token.access_token;
      session.provider_user_id = token.provider_user_id;
      session.expires_at = token.expires_at;
      session.provider = token.provider;
      return session;
    },
  },
  secret: process.env.NEXTAUTH_SECRET,
};

export { authOptions };
