import { getToken } from "next-auth/jwt";
import { NextResponse } from "next/server";

const secret = process.env.NEXTAUTH_SECRET;

export async function handler(request, { params, query }) {
  const { path } = await params;
  const url = new URL(request.url);
  const queryString = url.search;

  const serverUrl = `${process.env.SERVER_URL}/${path}${queryString}`;
  const method = request.method;

  console.log(`${method} serverUrl:`, serverUrl);

  const token = await getToken({ req: request, secret });
  if (!token) {
    return NextResponse.json(
      { error: "Session token missing or invalid" },
      { status: 401 }
    );
  }

  try {
    const headers = {
      "Content-Type": "application/json",
      "X-User-ID": token.id,
    };

    let body;
    if (method === "POST") {
      body = await request.json();
    }

    const response = await fetch(serverUrl, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    const contentType = response.headers.get("content-type");

    if (response.status === 200 && contentType?.includes("application/json")) {
      const data = await response.json();
      return NextResponse.json(data, { status: response.status });
    }

    return new NextResponse(null, { status: response.status });
  } catch (error) {
    console.error(`Error forwarding ${method} request:`, error);
    return NextResponse.json(
      { error: "Error proxying request" },
      { status: 500 }
    );
  }
}

export const GET = handler;
export const POST = handler;
export const DELETE = handler;
