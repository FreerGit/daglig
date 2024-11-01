import { NextResponse } from "next/server";

export async function GET(request, { params }) {
  const { path } = await params;
  const serverUrl = `${process.env.SERVER_URL}/${path.join("/")}`;
  console.log(serverUrl);
  try {
    const response = await fetch(serverUrl, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    });
    if (response.status == 200) {
      const data = await response.json();
      console.log(response);
      return NextResponse.json(data, { status: response.status });
    } else {
      console.log(response.status);
      return new NextResponse(null, { status: response.status });
    }
  } catch (error) {
    console.error("Error forwarding GET request:", error);
    return NextResponse.json(
      { error: "Error proxying request" },
      { status: 500 }
    );
  }
}

export async function POST(request, { params }) {
  const body = await request.json();
  const { path } = params;
  const serverUrl = `${process.env.SERVER_URL}/${path.join("/")}`;

  try {
    const response = await fetch(serverUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

    const data = await response.json();
    return NextResponse.json(data, { status: response.status });
  } catch (error) {
    console.error("Error forwarding POST request:", error);
    return NextResponse.json(
      { error: "Error proxying request" },
      { status: 500 }
    );
  }
}
