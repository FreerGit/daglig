import styles from "./styles/landingPage.module.css";
import IntroGraph from "../public/400x200.svg";
import Image from "next/image";
import { Button } from "@mantine/core";

export default function LandingPage() {
  return (
    <div>
      <main>
        <div className={styles.intro}>
          <h1>Accelarete.</h1>
          <p> Watch your growth by completing your dailies</p>
          {/* <Image priority src={IntroGraph} alt="" /> */}
          <Button variant="filled" color="red">
            Get Started
          </Button>
        </div>
      </main>
    </div>
  );
}
