import { t, Locale } from '@/lib/i18n';

type PageProps = {
  params: Promise<{ locale: Locale }>;
};

export default async function AboutPage({ params }: PageProps) {
  const { locale } = await params;
  const translate = (key: string) => t(locale, key);

  return (
    <div style={{ backgroundColor: 'var(--background)', color: 'var(--foreground)' }} className="min-h-screen">
      {/* Navigation */}
      <nav className="sticky top-0 z-40 border-b backdrop-blur-sm" style={{ borderColor: 'var(--border)', backgroundColor: 'color-mix(in srgb, var(--card) 80%, transparent)' }}>
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <a href={`/${locale}`} className="text-2xl font-bold text-primary">GoLiv</a>
          <div className="flex gap-3 items-center">
            <a href={`/${locale}/auth/login`} className="text-sm hover:text-primary transition-colors">
              {translate('nav.signIn')}
            </a>
            <a
              href={`/${locale}/auth/register`}
              style={{ backgroundColor: 'var(--primary)', color: 'var(--primary-foreground)' }}
              className="px-4 py-2 rounded-lg hover:opacity-90 transition-opacity text-sm"
            >
              {translate('nav.getStarted')}
            </a>
          </div>
        </div>
      </nav>

      {/* Content */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-12">
        <section className="space-y-4">
          <h1 className="text-4xl font-bold">{translate('home.about') || 'About GoLiv'}</h1>
          <p className="text-lg" style={{ color: 'var(--muted-foreground)' }}>
            GoLiv is Algeria's leading local marketplace connecting buyers, sellers, and service providers in your community.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">Our Mission</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            We aim to empower Algerian communities by creating a trusted platform where locals can easily buy, sell, and hire services without geographical barriers.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">Why Choose GoLiv?</h2>
          <ul className="space-y-3">
            {[
              { title: 'Local Community', desc: 'Support local businesses and your neighbors' },
              { title: 'Verified Users', desc: 'Safe transactions with verified buyers and sellers' },
              { title: 'Easy to Use', desc: 'Simple interface for posting and finding items' },
              { title: 'Fair Pricing', desc: 'No hidden fees or commissions' }
            ].map((item, i) => (
              <li key={i} className="flex gap-4">
                <div className="w-2 h-2 rounded-full mt-2" style={{ backgroundColor: 'var(--primary)' }}></div>
                <div>
                  <h3 className="font-semibold">{item.title}</h3>
                  <p style={{ color: 'var(--muted-foreground)' }}>{item.desc}</p>
                </div>
              </li>
            ))}
          </ul>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">Our Values</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            Transparency, trust, and community are at the heart of everything we do. We're committed to creating a safe, fair, and inclusive marketplace for all Algerians.
          </p>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t mt-16" style={{ borderColor: 'var(--border)', backgroundColor: 'var(--card)' }}>
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8 text-center text-sm" style={{ color: 'var(--muted-foreground)' }}>
          <p>{translate('home.copyright') || '© 2025 GoLiv. All rights reserved.'}</p>
        </div>
      </footer>
    </div>
  );
}
