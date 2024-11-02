import styles from "./styles/landingPage.module.css";
import Image from "next/image";
import { Button } from "@mantine/core";
import { redirect } from "next/navigation";
import RedirectButton from "./components/RedirectButton";

export default function LandingPage() {
  return (
    <div>
      <main>
        <div className={styles.intro}>
          <h1>Accelarete.</h1>
          <p> Watch your growth by completing your dailies</p>
          {/* <Image priority src={IntroGraph} alt="" /> */}
          <RedirectButton />
        </div>
      </main>
    </div>
  );
}
