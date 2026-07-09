'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useAuthStore } from '@/stores/authStore';
import { authService } from '@/lib/services/authService';
import { AlertCircle, Loader2, LogIn, ArrowRight } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const loginSchema = z.object({
  phone: z.string().min(8, 'Invalid phone number'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export default function LoginPage() {
  const router = useRouter();
  const { setAuth, setError, error } = useAuthStore();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    setIsSubmitting(true);
    try {
      const response = await authService.login(data.phone, data.password);
      setAuth(response);
      router.push('/dashboard');
    } catch (err: any) {
      const message = err.response?.data?.message || 'Login failed. Please verify your credentials.';
      setError(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-foreground mb-3">Welcome Back</h1>
        <p className="text-muted-foreground text-sm">
          Please sign in to access your dashboard and continue where you left off.
        </p>
      </div>

      <AnimatePresence>
        {error && (
          <motion.div
            initial={{ opacity: 0, height: 0, y: -10 }}
            animate={{ opacity: 1, height: 'auto', y: 0 }}
            exit={{ opacity: 0, height: 0 }}
            className="mb-6 p-4 bg-destructive/10 border border-destructive/20 rounded-2xl flex gap-3 overflow-hidden"
          >
            <AlertCircle className="text-destructive flex-shrink-0 mt-0.5" size={18} />
            <p className="text-sm font-medium text-destructive">{error}</p>
          </motion.div>
        )}
      </AnimatePresence>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5 cursor-default">
        {/* Phone Input */}
        <div className="space-y-1.5">
          <label className="block text-sm font-semibold text-foreground">Phone Number</label>
          <div className="relative group">
            <input
              type="tel"
              disabled={isSubmitting}
              placeholder="0555555555"
              {...register('phone')}
              className="w-full pl-4 pr-10 py-3 bg-secondary/50 border border-border rounded-xl text-foreground placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all disabled:opacity-50"
            />
            {/* Algerian Flag Prefix Visual (Optional, adds premium feel) */}
            <div className="absolute right-4 top-1/2 -translate-y-1/2 text-muted-foreground font-medium text-sm select-none pointer-events-none">
              DZ
            </div>
          </div>
          {errors.phone && (
            <p className="text-sm text-destructive font-medium flex items-center gap-1 mt-1.5">
              <span className="w-1 h-1 rounded-full bg-destructive" />
              {errors.phone.message}
            </p>
          )}
        </div>

        {/* Password Input */}
        <div className="space-y-1.5 pt-1">
          <div className="flex items-center justify-between">
            <label className="block text-sm font-semibold text-foreground">Password</label>
            <Link 
              href="/auth/forgot-password" 
              className="text-xs font-semibold text-primary hover:text-primary/80 transition-colors"
            >
              Forgot password?
            </Link>
          </div>
          <input
            type="password"
            disabled={isSubmitting}
            placeholder="••••••••"
            {...register('password')}
            className="w-full px-4 py-3 bg-secondary/50 border border-border rounded-xl text-foreground placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all disabled:opacity-50 tracking-widest"
          />
          {errors.password && (
            <p className="text-sm text-destructive font-medium flex items-center gap-1 mt-1.5">
              <span className="w-1 h-1 rounded-full bg-destructive" />
              {errors.password.message}
            </p>
          )}
        </div>

        {/* Submit Button */}
        <div className="pt-4">
          <button
            type="submit"
            disabled={isSubmitting}
            className="group w-full relative h-12 bg-primary text-primary-foreground font-semibold rounded-xl overflow-hidden transition-all hover:shadow-[0_0_20px_rgba(255,87,34,0.3)] disabled:opacity-70 disabled:cursor-not-allowed disabled:hover:shadow-none"
          >
            {/* Button inner layout */}
            <div className="absolute inset-0 flex items-center justify-center gap-2">
              {isSubmitting ? (
                <>
                  <Loader2 size={18} className="animate-spin" />
                  <span>Authenticating...</span>
                </>
              ) : (
                <>
                  <LogIn size={18} className="transition-transform group-hover:-translate-x-1" />
                  <span>Sign In</span>
                  <ArrowRight size={18} className="opacity-0 -ml-4 transition-all group-hover:opacity-100 group-hover:ml-0" />
                </>
              )}
            </div>
            
            {/* Shimmer effect */}
            {!isSubmitting && (
              <div className="absolute inset-0 -translate-x-full bg-gradient-to-r from-transparent via-white/20 to-transparent group-hover:animate-shimmer" />
            )}
          </button>
        </div>
      </form>

      {/* Footer */}
      <div className="mt-8 text-center">
        <p className="text-sm text-muted-foreground font-medium">
          New to GoLiv?{' '}
          <Link href="/auth/register" className="text-primary hover:underline underline-offset-4 decoration-2">
            Create an account
          </Link>
        </p>
      </div>
    </>
  );
}
