import type { NextConfig } from "next";

// Release builds (scripts/release/build.sh) set PATCHBAY_RELEASE=1: they build a self-contained
// server into .next-release/standalone, so the downloadable app needs only Node, not node_modules.
// Normal builds (npm run build, the patchbay launcher) are unchanged and use .next.
const release = process.env.PATCHBAY_RELEASE === "1";

const nextConfig: NextConfig = {
  ...(release
    ? { output: "standalone" as const, distDir: ".next-release", outputFileTracingRoot: process.cwd(), images: { unoptimized: true } }
    : {}),
  // PDF / Word text extraction libraries run on the server as plain Node packages.
  serverExternalPackages: ["unpdf", "mammoth"],
  experimental: {
    // proxy.ts buffers request bodies; allow large attachments (images, big files).
    proxyClientMaxBodySize: "200mb",
  },
};

export default nextConfig;
