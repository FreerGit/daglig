"use client";

import { Button } from "@mantine/core";
import { signIn } from "next-auth/react";

const OAuthButton = ({ provider }) => {
  var name = provider.charAt(0).toUpperCase() + provider.slice(1);
  return <Button onClick={() => signIn(provider)}>Login with {name}</Button>;
};

export default OAuthButton;
