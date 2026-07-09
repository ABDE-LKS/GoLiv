import Link from 'next/link';
import { ShoppingCart, Briefcase, Wrench, ArrowRight, Shield, Zap, Users } from 'lucide-react';
import LocaleSwitch from '@/components/LocaleSwitch';
import { t, Locale } from '@/lib/i18n';

type PageProps = {
  params: Promise<{ locale: Locale }>
};

export default async function Home({ params }: PageProps) {
  const { locale } = await params;
  const translate = (key: string) => t(locale, key);

  return (
    <div style={{ backgroundColor: 'var(--background)', color: 'var(--foreground)' }} className="min-h-screen">
      {/* Navigation */}
      <nav className="sticky top-0 z-40 border-b backdrop-blur-sm" style={{ borderColor: 'var(--border)', backgroundColor: 'color-mix(in srgb, var(--card) 80%, transparent)' }}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <Link href="/" className="text-2xl font-bold" style={{ color: 'var(--primary)' }}>
            GoLiv
          </Link>
          <div className="flex gap-3 items-center">
            <Link
              href="/auth/login"
              className="btn-ghost text-sm"
            >
              { translate('nav.signIn')}
            </Link>
            <Link
              href="/auth/register"
              className="btn-primary text-sm"
            >
              { translate('nav.getStarted')}
            </Link>
            <LocaleSwitch />
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-20 sm:py-28">
        <div className="text-center space-y-8">
          <div className="space-y-4">
            <h1 className="display-medium" style={{ color: 'var(--foreground)' }}>
              { translate('home.title')}
            </h1>
            <p className="text-xl max-w-2xl mx-auto text-balance leading-relaxed" style={{ color: 'var(--muted-foreground)' }}>
              { translate('home.description')}
            </p>
          </div>

          <div className="flex flex-col sm:flex-row gap-3 justify-center">
            <Link
              href="/marketplace"
              className="btn-primary inline-flex items-center justify-center gap-2"
            >
              { translate('home.browseListings')}
              <ArrowRight size={20} />
            </Link>
            <Link
              href="/auth/register"
              className="btn-secondary inline-flex items-center justify-center"
            >
              { translate('home.startSelling')}
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="border-y py-16 sm:py-20" style={{ borderColor: 'var(--border)', backgroundColor: 'color-mix(in srgb, var(--secondary) 50%, transparent)' }}>
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid md:grid-cols-3 gap-8 sm:gap-6">
            {/* Marketplace */}
            <div className="space-y-3">
              <div className="inline-flex items-center justify-center w-12 h-12 rounded-lg" style={{ backgroundColor: 'color-mix(in srgb, var(--primary) 10%, transparent)' }}>
                <ShoppingCart style={{ color: 'var(--primary)' }} size={24} />
              </div>
              <h3 className="heading-3" style={{ color: 'var(--foreground)' }}>{ translate('home.marketplace')}</h3>
              <p className="caption text-balance" style={{ color: 'var(--muted-foreground)' }}>
                { translate('home.marketplaceDesc')}
              </p>
            </div>

            {/* Services */}
            <div className="space-y-3">
              <div className="inline-flex items-center justify-center w-12 h-12 rounded-lg" style={{ backgroundColor: 'color-mix(in srgb, var(--accent) 10%, transparent)' }}>
                <Wrench style={{ color: 'var(--accent)' }} size={24} />
              </div>
              <h3 className="heading-3" style={{ color: 'var(--foreground)' }}>{ translate('home.services')}</h3>
              <p className="caption text-balance" style={{ color: 'var(--muted-foreground)' }}>
                { translate('home.servicesDesc')}
              </p>
            </div>

            {/* Jobs */}
            <div className="space-y-3">
              <div className="inline-flex items-center justify-center w-12 h-12 rounded-lg" style={{ backgroundColor: 'color-mix(in srgb, var(--success) 10%, transparent)' }}>
                <Briefcase style={{ color: 'var(--success)' }} size={24} />
              </div>
              <h3 className="heading-3" style={{ color: 'var(--foreground)' }}>{ translate('home.jobs')}</h3>
              <p className="caption text-balance" style={{ color: 'var(--muted-foreground)' }}>
                { translate('home.jobsDesc')}
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Trust & Security */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-16 sm:py-20">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          <div className="space-y-6">
            <h2 className="heading-1" style={{ color: 'var(--foreground)' }}>{ translate('home.whyChoose')}</h2>
            
            <div className="space-y-4">
              {[
                { icon: Shield, title: translate('home.verified'), desc: translate('home.verifiedDesc') },
                { icon: Zap, title: translate('home.fast'), desc: translate('home.fastDesc') },
                { icon: Users, title: translate('home.community'), desc: translate('home.communityDesc') }
              ].map((item, i) => (
                <div key={i} className="flex gap-3">
                  <div className="flex-shrink-0">
                    <item.icon style={{ color: 'var(--primary)' }} size={24} />
                  </div>
                  <div>
                    <p className="font-semibold" style={{ color: 'var(--foreground)' }}>{item.title}</p>
                    <p className="text-sm" style={{ color: 'var(--muted-foreground)' }}>{item.desc}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="card-elevated p-8">
            <div className="space-y-4">
              <h3 className="heading-2" style={{ color: 'var(--foreground)' }}>{ translate('home.getStartedToday')}</h3>
              <p className="subtitle">{ translate('home.joinThousands')}</p>
              <div className="space-y-3 pt-4">
                <Link
                  href="/auth/register"
                  className="btn-primary w-full block text-center"
                >
                  { translate('auth.register')}
                </Link>
                <Link
                  href="/auth/login"
                  className="btn-secondary w-full block text-center"
                >
                  { translate('auth.alreadyHaveAccount')}
                </Link>
              </div>
              <p className="text-xs text-center" style={{ color: 'var(--muted-foreground)' }}>{ translate('home.noCreditCard')}</p>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="border-y py-16 sm:py-20" style={{ borderColor: 'var(--border)', backgroundColor: 'color-mix(in srgb, var(--secondary) 50%, transparent)' }}>
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid sm:grid-cols-3 gap-8 text-center">
            <div>
              <div className="text-3xl sm:text-4xl font-bold mb-2" style={{ color: 'var(--primary)' }}>50K+</div>
              <p className="subtitle">{ translate('home.activeUsers')}</p>
            </div>
            <div>
              <div className="text-3xl sm:text-4xl font-bold mb-2" style={{ color: 'var(--primary)' }}>100K+</div>
              <p className="subtitle">{ translate('home.listings')}</p>
            </div>
            <div>
              <div className="text-3xl sm:text-4xl font-bold mb-2" style={{ color: 'var(--primary)' }}>95%</div>
              <p className="subtitle">{ translate('home.satisfactionRate')}</p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t" style={{ borderColor: 'var(--border)', backgroundColor: 'var(--card)' }}>
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-12 sm:py-16">
          <div className="grid sm:grid-cols-4 gap-8 mb-8">
            <div>
              <p className="font-semibold mb-4" style={{ color: 'var(--foreground)' }}>GoLiv</p>
              <p className="text-sm" style={{ color: 'var(--muted-foreground)' }}>Your local marketplace for buying, selling, and hiring services.</p>
            </div>
            <div>
              <p className="font-semibold mb-3 text-sm" style={{ color: 'var(--foreground)' }}>{ translate('home.explore')}</p>
              <ul className="space-y-2 text-sm">
                <li><Link href="/marketplace" className="link-secondary">{ translate('home.marketplace')}</Link></li>
                <li><Link href="/services" className="link-secondary">{ translate('home.services')}</Link></li>
                <li><Link href="/jobs" className="link-secondary">{ translate('home.jobs')}</Link></li>
              </ul>
            </div>
            <div>
              <p className="font-semibold mb-3 text-sm" style={{ color: 'var(--foreground)' }}>{ translate('home.company')}</p>
              <ul className="space-y-2 text-sm">
                <li><a href="#" className="link-secondary">{ translate('home.about')}</a></li>
                <li><a href="#" className="link-secondary">{ translate('home.blog')}</a></li>
                <li><a href="#" className="link-secondary">{ translate('home.contact')}</a></li>
              </ul>
            </div>
            <div>
              <p className="font-semibold mb-3 text-sm" style={{ color: 'var(--foreground)' }}>{ translate('home.legal')}</p>
              <ul className="space-y-2 text-sm">
                <li><a href="#" className="link-secondary">{ translate('home.privacy')}</a></li>
                <li><a href="#" className="link-secondary">{ translate('home.terms')}</a></li>
                <li><a href="#" className="link-secondary">{ translate('home.safety')}</a></li>
              </ul>
            </div>
          </div>
          <div className="border-t pt-8 text-center text-sm" style={{ borderColor: 'var(--border)', color: 'var(--muted-foreground)' }}>
            <p>{ translate('home.copyright')}</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
