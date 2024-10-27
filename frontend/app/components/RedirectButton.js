"use client";

import { useRouter } from "next/navigation";
import { Button } from "@mantine/core";

const RedirectButton = () => {
  const router = useRouter();

  const handleRedirect = () => {
    router.push("/login");
  };

  return (
    <Button variant="filled" color="red" onClick={handleRedirect}>
      Get Started
    </Button>
  );
};

export default RedirectButton;
