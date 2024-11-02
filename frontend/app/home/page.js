import { getServerSession } from "next-auth";
import { redirect } from "next/navigation";

import { LineChart } from "@mantine/charts";

export default async function LoginPage() {
  const session = await getServerSession();
  console.log(session);

  if (!session) {
    redirect("/auth/signin");
    return null;
  }

  return (
    <div className="flex flex-col items-center mt-8 h-screen">
      <h1 className="font-semibold text-[54px] mb-4">Your Snowball</h1>
      <div className="flex w-3/4 h-1/2">
        <LineChart
          className="w-full h-full"
          data={data}
          dataKey="date"
          yAxisProps={{ domain: [0, 50] }}
          series={[{ name: "Points", color: "red" }]}
        />
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
