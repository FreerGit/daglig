import Providers from "./providers";
import { getServerSession } from "next-auth";
import { GeistSans } from "geist/font/sans";
import { createTheme, ColorSchemeScript, MantineProvider } from "@mantine/core";
import "@mantine/core/styles.css";
import "./styles/globals.css";

const theme = createTheme({
  /** Put your mantine theme override here */
  fontFamily: "inherit",
  lineHeights: "inherit",
});

export default async function RootLayout({ children }) {
  const session = await getServerSession();
  return (
    <html
      lang="en"
      className={`${GeistSans.className} antialiased dark:bg-gray-950`}
      suppressHydrationWarning
    >
      <head>
        <meta
          name="viewport"
          content="minimum-scale=1, initial-scale=1, width=device-width, user-scalable=no"
        />
        <ColorSchemeScript />
      </head>

      <body>
        <MantineProvider theme={theme}>
          <Providers session={session}>{children}</Providers>
        </MantineProvider>
      </body>
    </html>
  );
}
