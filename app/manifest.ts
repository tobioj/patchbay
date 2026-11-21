import type { MetadataRoute } from "next";

// Lets Chrome / Edge / Safari install this as a standalone app with its own Dock icon.
export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Patchbay",
    short_name: "Patchbay",
    start_url: "/",
    display: "standalone",
    background_color: "#faf9f6",
    theme_color: "#faf9f6",
    icons: [{ src: "/icon.png", sizes: "512x512", type: "image/png" }],
  };
}
