import { getServerSession } from "next-auth";
import { redirect } from "next/navigation";

import { LineChart } from "@mantine/charts";
import { Button } from "@mantine/core";
import { TaskManager } from "../components/TaskManager/TaskManager";
import { ChartTooltip } from "../components/ChartTooltip";

export default async function LoginPage() {
  const session = await getServerSession();
  console.log(session);

  if (!session) {
    redirect("/auth/signin");
    return null;
  }

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

const cards = [
  {
    points: 5,
    description: "Lorem ipsum dolor sit amet.",
  },
  {
    points: 2,
    description: "Consectetur adipiscing elit.",
  },
  {
    points: 8,
    description: "Sed do eiusmod tempor incididunt.",
  },
  {
    points: 3,
    description: "Ut enim ad minim veniam.",
  },
  {
    points: 7,
    description: "Quis nostrud exercitation ullamco.",
  },
  {
    points: 1,
    description: "Laboris nisi ut aliquip ex ea commodo.",
  },
  {
    points: 6,
    description: "Duis aute irure dolor in reprehenderit.",
  },
  {
    points: 4,
    description: "Excepteur sint occaecat cupidatat non proident.",
  },
  {
    points: 10,
    description: "Sunt in culpa qui officia deserunt.",
  },
  {
    points: 9,
    description: "Mollit anim id est laborum.",
  },
];

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
