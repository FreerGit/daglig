import { getServerSession } from "next-auth";
import { redirect } from "next/navigation";

import { LineChart } from "@mantine/charts";
import { Button, resolveClassNames } from "@mantine/core";
import { TaskManager } from "../components/TaskManager/TaskManager";
import { ChartTooltip } from "../components/ChartTooltip";
import { cookies } from "next/headers";

export default async function LoginPage() {
  const session = await getServerSession();
  if (!session) {
    redirect("/auth/signin");
    return null;
  }

  const sessionCookies = await cookies();

  const getCards = async () => {
    const response = await fetch(
      `${process.env.NEXT_URL}/api/proxy/get-tasks`,
      {
        headers: {
          Cookie: sessionCookies.toString(),
        },
        credentials: "include",
      }
    );
    if (response.ok) {
      const cards = await response.json();
      return cards;
    }
    return [];
  };

  let cards = await getCards();

  return (
    <div className="flex flex-col items-center mt-4 h-screen w-screen">
      <h1 className="font-semibold text-[54px] mb-4">Your Snowball</h1>
      <div className="flex mr-8 w-4/5 xl:w-1/2 md:w-2/3 sm:w-4/5 min-h-[25%]">
        <LineChart
          className="w-full h-full"
          data={data}
          dataKey="date"
          yAxisProps={{ domain: [0, 50] }}
          series={[{ name: "Points", color: "red" }]}
          tooltipProps={{
            content: ChartTooltip,
          }}
        />
      </div>
      <div className="mt-12 w-full">
        <TaskManager initialCards={cards} />
      </div>
    </div>
  );
}

const data = [
  {
    date: "Mar 22",
    Points: 0,
  },
  {
    date: "Mar 23",
    Points: 3,
  },
  {
    date: "Mar 24",
    Points: 5,
  },
  {
    date: "Mar 25",
    Points: 8,
  },
  {
    date: "Mar 26",
    Points: 11,
  },
  {
    date: "Mar 27",
    Points: 9,
  },
  {
    date: "Mar 28",
    Points: 12,
  },
  {
    date: "Mar 29",
    Points: 15,
  },
];
