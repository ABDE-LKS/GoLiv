import { Analytics } from '@vercel/analytics/next'
import type { Metadata, Viewport } from 'next'
import { Noto_Sans_Arabic, Inter } from 'next/font/google'
import './globals.css'

const notoSansArabic = Noto_Sans_Arabic({ subsets: ['arabic'], variable: '--font-noto-arabic' })
const inter = Inter({ subsets: ['latin'], variable: '--font-inter' })

export const metadata: Metadata = {
  title: 'GoLiv - Buy, Sell & Hire Locally',
  description: 'GoLiv - The local marketplace for buying, selling, and hiring services in Algeria',
  generator: 'v0.app',
  keywords: ['marketplace', 'buy', 'sell', 'hire', 'services', 'Algeria'],
  openGraph: {
    title: 'GoLiv - Buy, Sell & Hire Locally',
    description: 'The local marketplace for buying, selling, and hiring services',
    type: 'website',
  },
  icons: {
    icon: [
      {
        url: '/icon.svg',
        type: 'image/svg+xml',
      },
    ],
    apple: '/apple-icon.png',
  },
}

export const viewport: Viewport = {
  colorScheme: 'light dark',
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#FF5722' },
    { media: '(prefers-color-scheme: dark)', color: '#FF7043' },
  ],
  userScalable: true,
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
}

export default async function RootLayout({
  children,
  params,
}: Readonly<{
  children: React.ReactNode
  params?: Promise<{ locale?: string }>
}>) {
  const resolvedParams = params ? await params : undefined;
  const locale = resolvedParams?.locale || 'ar';
  const direction = locale === 'ar' ? 'rtl' : 'ltr';

  return (
    <html lang={locale} dir={direction} className={`${inter.variable} ${notoSansArabic.variable}`} style={{ backgroundColor: 'var(--background)' }}>
      <head>
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
      </head>
      <body className="antialiased font-sans" style={{ backgroundColor: 'var(--background)', color: 'var(--foreground)', fontFamily: "var(--font-noto-arabic), var(--font-inter), sans-serif" }}>
        {children}
        {process.env.NODE_ENV === 'production' && <Analytics />}
      </body>
    </html>
  )
}
