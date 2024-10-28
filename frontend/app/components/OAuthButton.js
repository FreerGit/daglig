"use client";

import { signIn } from "next-auth/react";

const OAuthButton = ({ provider }) => {
  var name = provider.charAt(0).toUpperCase() + provider.slice(1);
  return <button onClick={() => signIn(provider)}>Login with {name}</button>;
};

export default OAuthButton;
