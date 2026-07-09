import { ShieldCheck, Zap, Users } from 'lucide-react';
import Link from 'next/link';

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen grid lg:grid-cols-2" style={{ backgroundColor: 'var(--background)' }}>
      {/* Left Column: Branding / Graphic (Hidden on mobile) */}
      <div 
        className="hidden lg:flex flex-col justify-between p-12 relative overflow-hidden"
        style={{ backgroundColor: 'var(--primary)', color: 'var(--primary-foreground)' }}
      >
        {/* Abstract Background pattern */}
        <div className="absolute inset-0 opacity-10 pointer-events-none">
          <svg className="h-full w-full" viewBox="0 0 100 100" preserveAspectRatio="none">
            <polygon fill="currentColor" points="0,100 100,0 100,100" />
          </svg>
        </div>

        <div className="relative z-10">
          <Link href="/" className="text-4xl font-bold tracking-tight inline-block hover:opacity-90 transition-opacity">
            GoLiv
          </Link>
          <p className="mt-4 text-xl/relaxed font-medium max-w-md opacity-90">
            سوقك المحلي للبيع والشراء والتوظيف في الجزائر. معاملات آمنة ومجتمع موثوق.
          </p>
        </div>

        <div className="relative z-10 space-y-8 max-w-md">
          <div className="flex gap-4 items-start">
            <div className="bg-white/20 p-3 rounded-2xl backdrop-blur-md">
              <ShieldCheck size={28} />
            </div>
            <div>
              <h3 className="font-semibold text-lg">مستخدمون موثوقون</h3>
              <p className="opacity-80 text-sm mt-1">معاملات آمنة مع بائعين وعملاء تم التحقق منهم.</p>
            </div>
          </div>

          <div className="flex gap-4 items-start">
            <div className="bg-white/20 p-3 rounded-2xl backdrop-blur-md">
              <Zap size={28} />
            </div>
            <div>
              <h3 className="font-semibold text-lg">سريع وسهل</h3>
              <p className="opacity-80 text-sm mt-1">تواصل فوراً مع المشترين ومقدمي الخدمات في مدينتك.</p>
            </div>
          </div>

          <div className="flex gap-4 items-start">
            <div className="bg-white/20 p-3 rounded-2xl backdrop-blur-md">
              <Users size={28} />
            </div>
            <div>
              <h3 className="font-semibold text-lg">المجتمع المحلي</h3>
              <p className="opacity-80 text-sm mt-1">ندعم المشاريع المحلية والأفراد لبناء اقتصاد أقوى.</p>
            </div>
          </div>
        </div>
      </div>

      {/* Right Column: Form */}
      <div className="flex items-center justify-center p-6 sm:p-12" style={{ backgroundColor: 'var(--background)' }}>
        <div className="w-full max-w-[420px]">
          {/* Mobile Logo */}
          <div className="lg:hidden text-center mb-10">
            <Link href="/" className="text-4xl font-bold" style={{ color: 'var(--primary)' }}>GoLiv</Link>
            <p className="subtitle mt-2">اشترِ وبع وأستأجر الخدمات محلياً</p>
          </div>
          
          <div className="card-elevated p-8 rounded-3xl border border-border shadow-2xl">
            {children}
          </div>
        </div>
      </div>
    </div>
  );
}
