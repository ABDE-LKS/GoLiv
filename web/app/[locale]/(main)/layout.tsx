'use client';

import { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import Navbar from '@/components/layout/Navbar';
import Sidebar from '@/components/layout/Sidebar';
import { Loader2 } from 'lucide-react';

export default function MainLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const params = useParams();
  const locale = (params?.locale as string) || 'ar';
  const router = useRouter();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  // null = not yet checked | true = authenticated | false = not authenticated
  // Start as null so server and client render the SAME thing (no hydration mismatch)
  const [authState, setAuthState] = useState<boolean | null>(null);

  useEffect(() => {
    // This only runs on the client, after hydration — safe to access localStorage
    try {
      const raw = localStorage.getItem('goliv-auth');
      if (raw) {
        const parsed = JSON.parse(raw);
        const user = parsed?.state?.user;
        const token = parsed?.state?.accessToken;
        if (user && token) {
          setAuthState(true);
          return;
        }
      }
    } catch (_) {
      // corrupted storage
    }
    // No valid auth found → redirect
    setAuthState(false);
    router.replace(`/${locale}/auth/login`);
  }, [locale, router]);

  // Show loading spinner while auth is being checked (and during redirect)
  if (authState !== true) {
    return (
      <div
        className="min-h-screen flex items-center justify-center"
        style={{ backgroundColor: 'var(--background)' }}
      >
        <div className="flex flex-col items-center gap-4">
          <div className="text-3xl font-bold" style={{ color: 'var(--primary)' }}>
            GoLiv
          </div>
          <Loader2
            className="animate-spin"
            style={{ color: 'var(--primary)' }}
            size={32}
          />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen" style={{ backgroundColor: 'var(--background)' }}>
      <Navbar onMenuToggle={() => setIsMobileMenuOpen(!isMobileMenuOpen)} />
      <div className="flex">
        <Sidebar isOpen={isMobileMenuOpen} onClose={() => setIsMobileMenuOpen(false)} />
        <main className="flex-1 lg:ms-64">
          {children}
        </main>
      </div>
    </div>
  );
}
