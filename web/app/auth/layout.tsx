'use client';

import { motion } from 'framer-motion';
import { ShieldCheck, Zap, Users } from 'lucide-react';
import Link from 'next/link';

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen grid lg:grid-cols-2 bg-background">
      {/* Left Column: Branding / Graphic (Hidden on mobile) */}
      <div className="hidden lg:flex flex-col justify-between bg-primary p-12 text-primary-foreground relative overflow-hidden">
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
          <p className="mt-4 text-xl/relaxed font-medium max-w-md">
            The local marketplace for buying, selling, and hiring services in Algeria.
          </p>
        </div>

        <div className="relative z-10 space-y-8 max-w-md">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="flex gap-4 items-start"
          >
            <div className="bg-white/20 p-3 rounded-2xl backdrop-blur-md">
              <ShieldCheck size={28} />
            </div>
            <div>
              <h3 className="font-semibold text-lg">Trusted & Secure</h3>
              <p className="text-primary-foreground/80 text-sm mt-1">Every user and advertisement is verified to maintain a safe environment.</p>
            </div>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="flex gap-4 items-start"
          >
            <div className="bg-white/20 p-3 rounded-2xl backdrop-blur-md">
              <Zap size={28} />
            </div>
            <div>
              <h3 className="font-semibold text-lg">Fast Transactions</h3>
              <p className="text-primary-foreground/80 text-sm mt-1">Connect instantly with local buyers and service providers in your city.</p>
            </div>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="flex gap-4 items-start"
          >
            <div className="bg-white/20 p-3 rounded-2xl backdrop-blur-md">
              <Users size={28} />
            </div>
            <div>
              <h3 className="font-semibold text-lg">Community First</h3>
              <p className="text-primary-foreground/80 text-sm mt-1">We bring neighbors together to build a stronger local economy.</p>
            </div>
          </motion.div>
        </div>
      </div>

      {/* Right Column: Form */}
      <div className="flex items-center justify-center p-6 sm:p-12">
        <div className="w-full max-w-[420px]">
          {/* Mobile Logo */}
          <div className="lg:hidden text-center mb-10">
            <Link href="/" className="text-4xl font-bold text-primary">GoLiv</Link>
            <p className="text-muted-foreground mt-2">Buy, Sell & Hire Locally</p>
          </div>
          
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            className="bg-card p-8 rounded-3xl border border-border/50 shadow-2xl shadow-primary/5"
          >
            {children}
          </motion.div>
        </div>
      </div>
    </div>
  );
}
