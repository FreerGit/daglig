import { getServerSession } from "next-auth";
import { redirect } from "next/navigation";

import { LineChart } from "@mantine/charts";
import { Button } from "@mantine/core";
import { TaskManager } from "../components/TaskManager";

export default async function LoginPage() {
  const session = await getServerSession();
  console.log(session);

  if (!session) {
    redirect("/auth/signin");
    return null;
  }

  return (
    <div className="flex flex-col items-center mt-8 h-screen w-screen">
      <h1 className="font-semibold text-[54px] mb-4">Your Snowball</h1>
      <div className="flex max-h-56 mr-6 xl:w-1/2 md:w-3/5 sm:w-full h-1/2">
        <LineChart
          className="w-full h-full"
          data={data}
          dataKey="date"
          yAxisProps={{ domain: [0, 50] }}
          series={[{ name: "Points", color: "red" }]}
        />
      </div>

      <TaskManager initialCards={cards} />
    </div>
  );
}

const cards = [
  {
    id: 321321,
    points: 5,
    description: "Lorem ipsum dolor sit amet.",
  },
  {
    id: 321322,
    points: 2,
    description: "Consectetur adipiscing elit.",
  },
  {
    id: 321323,
    points: 8,
    description: "Sed do eiusmod tempor incididunt.",
  },
  {
    id: 321324,
    points: 3,
    description: "Ut enim ad minim veniam.",
  },
  {
    id: 321325,
    points: 7,
    description: "Quis nostrud exercitation ullamco.",
  },
  {
    id: 321326,
    points: 1,
    description: "Laboris nisi ut aliquip ex ea commodo.",
  },
  {
    id: 321327,
    points: 6,
    description: "Duis aute irure dolor in reprehenderit.",
  },
  {
    id: 321328,
    points: 4,
    description: "Excepteur sint occaecat cupidatat non proident.",
  },
  {
    id: 321329,
    points: 10,
    description: "Sunt in culpa qui officia deserunt.",
  },
  {
    id: 321330,
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
