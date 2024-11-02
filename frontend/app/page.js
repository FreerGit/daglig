import Image from "next/image";
import { Button } from "@mantine/core";
import { redirect } from "next/navigation";
import RedirectButton from "./components/RedirectButton";
import "./styles/globals.css";

// .intro {
//   text-align: center;
// }

// .intro h1 {
//   font-size: 54px;
//   line-height: 62px;
//   margin-bottom: 16px;
// }

// .intro p {
//   font-size: 22px;
//   margin-bottom: 48px;
// }
export default function LandingPage() {
  return (
    <div>
      <main>
        <div className="text-center mt-8">
          <h1 className="font-semibold text-[54px] leading-[62px] mb-4">
            Accelarete.
          </h1>
          <p className="text-[22px] mb-12">
            {" "}
            Watch your growth by completing your dailies
          </p>
          {/* <Image priority src={IntroGraph} alt="" /> */}
          <RedirectButton />
        </div>
      </main>
    </div>
  );
}
