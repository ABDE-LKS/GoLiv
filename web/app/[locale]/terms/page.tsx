import { t, Locale } from '@/lib/i18n';

type PageProps = {
  params: Promise<{ locale: Locale }>;
};

export default async function TermsPage({ params }: PageProps) {
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
          <h1 className="text-4xl font-bold mb-4">Terms of Service</h1>
          <p style={{ color: 'var(--muted-foreground)' }}>Last updated: January 2025</p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">1. User Agreement</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            By accessing and using GoLiv, you accept and agree to be bound by the terms and provision of this agreement.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">2. Use License</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            Permission is granted to temporarily download one copy of the materials (information or software) on GoLiv for personal, non-commercial transitory viewing only.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">3. Disclaimer</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            The materials on GoLiv are provided on an 'as is' basis. GoLiv makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">4. Limitations</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            In no event shall GoLiv or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on GoLiv.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">5. Accuracy of Materials</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            The materials appearing on GoLiv could include technical, typographical, or photographic errors. GoLiv does not warrant that any of the materials on our website are accurate, complete, or current.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">6. Modifications</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            GoLiv may revise these terms of service for our website at any time without notice. By using this website, you are agreeing to be bound by the then current version of these terms of service.
          </p>
        </section>

        <section className="space-y-4">
          <h2 className="text-2xl font-bold">7. Governing Law</h2>
          <p style={{ color: 'var(--muted-foreground)' }}>
            These terms and conditions are governed by and construed in accordance with the laws of Algeria, and you irrevocably submit to the exclusive jurisdiction of the courts in that location.
          </p>
        </section>
      </main>
    </div>
  );
}
