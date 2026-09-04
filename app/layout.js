import "./globals.css";

export const metadata = {
  title: "Mess Ku",
  description: "Platform manajemen mess karyawan",
};

export default function RootLayout({ children }) {
  return (
    <html lang="id">
      <body>{children}</body>
    </html>
  );
}
