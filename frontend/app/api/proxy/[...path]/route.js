import { getToken } from "next-auth/jwt";
import { NextResponse } from "next/server";

const secret = process.env.NEXTAUTH_SECRET;

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

export async function POST(request) {
  const url = new URL(request.url);
  const path = url.pathname;
  const serverUrl = `${process.env.SERVER_URL}${path}`;

  const token = await getToken({ req: request, secret });
  const body = await request.json();
  if (!token) {
    return NextResponse.json(
      { error: "Session token missing or invalid" },
      { status: 401 }
    );
  }

  try {
    const response = await fetch(serverUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-User-Email": token.email,
      },
      body: JSON.stringify(body),
    });

    // const data = await response.json();
    console.log(response.status);
    return new NextResponse(null, { status: response.status });
  } catch (error) {
    console.error("Error forwarding POST request:", error);
    return NextResponse.json(
      { error: "Error proxying request" },
      { status: 500 }
    );
  }
}
