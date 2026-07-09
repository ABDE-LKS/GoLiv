import { t, Locale } from '@/lib/i18n';

type PageProps = {
  params: Promise<{ locale: Locale }>;
};

export default async function PrivacyPage({ params }: PageProps) {
  const { locale } = await params;
  const translate = (key: string) => t(locale, key);

  return (
    <div style={{ backgroundColor: 'var(--background)', color: 'var(--foreground)' }} className="min-h-screen">
      {/* Navigation */}
      <nav className="sticky top-0 z-40 border-b backdrop-blur-sm" style={{ borderColor: 'var(--border)', backgroundColor: 'color-mix(in srgb, var(--card) 80%, transparent)' }}>
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <a href={`/${locale}`} className="text-2xl font-bold text-primary">GoLiv</a>
        </div>
      </nav>

      {/* Content */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-16 space-y-8">
        <section>
          <h1 className="text-4xl font-bold mb-4">Privacy Policy</h1>
          <p style={{ color: 'var(--muted-foreground)' }}>Last updated: January 2025</p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">1. Information We Collect</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            We collect information you provide directly to us, such as when you create an account, post a listing, or contact us. This includes your name, email, phone number, and profile information.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">2. How We Use Your Information</h2>
          <ul className="space-y-2" style={{ color: 'var(--muted-foreground)' }}>
            <li>• To provide and maintain our services</li>
            <li>• To send you technical notices and support messages</li>
            <li>• To respond to your comments and questions</li>
            <li>• To improve our services</li>
          </ul>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">3. Data Security</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            We take reasonable measures to protect your personal information from unauthorized access, disclosure, or alteration. However, no method of transmission over the internet is completely secure.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">4. Third-Party Links</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            Our platform may contain links to third-party websites. We are not responsible for their privacy practices. Please review their privacy policies before providing any information.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">5. Your Rights</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            You have the right to access, correct, or delete your personal information. Contact us for any requests regarding your data.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">6. Contact Us</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            If you have questions about this Privacy Policy, please contact us at privacy@goliv.dz
          </p>
        </section>
      </main>
    </div>
  );
}
