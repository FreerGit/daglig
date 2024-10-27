import localFont from "next/font/local";
import "./styles/globals.css";
import "@mantine/core/styles.css";
import { theme } from "../theme";
import { ColorSchemeScript, MantineProvider } from "@mantine/core";
import Providers from "./providers";
import { getServerSession } from "next-auth";

const geistSans = localFont({
  src: "./fonts/GeistVF.woff",
  variable: "--font-geist-sans",
  weight: "100 900",
});

export default async function RootLayout({ children }) {
  const session = await getServerSession();
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <ColorSchemeScript />
        <meta
          name="viewport"
          content="minimum-scale=1, initial-scale=1, width=device-width, user-scalable=no"
        />
      </head>

      <body className={`${geistSans.variable}`}>
        <MantineProvider theme={theme}>
          <Providers session={session}>{children}</Providers>
        </MantineProvider>
      </body>
    </html>
  );
}
