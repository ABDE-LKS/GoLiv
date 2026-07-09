'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useAuthStore } from '@/stores/authStore';
import { authService } from '@/lib/services/authService';
import { isValidPhoneNumber } from '@/lib/utils/helpers';
import { AlertCircle, Loader2, UserPlus, ArrowRight } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const registerSchema = z.object({
  firstName: z.string().min(2, 'First name must be at least 2 characters'),
  lastName: z.string().min(2, 'Last name must be at least 2 characters'),
  email: z.string().email('Invalid email address').optional().or(z.literal('')),
  phone: z.string().refine(isValidPhoneNumber, 'Invalid phone number'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
});

type RegisterFormData = z.infer<typeof registerSchema>;

export default function RegisterPage() {
  const router = useRouter();
  const { setAuth, setError, error } = useAuthStore();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
  });

  const onSubmit = async (data: RegisterFormData) => {
    setIsSubmitting(true);
    try {
      const response = await authService.register({
        email: data.email || undefined,
        password: data.password,
        firstName: data.firstName,
        lastName: data.lastName,
        phone: data.phone,
      });
      setAuth(response);
      router.push('/dashboard');
    } catch (err: any) {
      const message = err.response?.data?.message || 'Registration failed. Please try again.';
      setError(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <>
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-foreground mb-3">Create Account</h1>
        <p className="text-muted-foreground text-sm">
          Join the largest local marketplace in Algeria today.
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

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4 cursor-default">
        {/* First & Last Name */}
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-1.5">
            <label className="block text-sm font-semibold text-foreground">First Name</label>
            <input
              type="text"
              placeholder="John"
              disabled={isSubmitting}
              {...register('firstName')}
              className="w-full px-4 py-3 bg-secondary/50 border border-border rounded-xl text-foreground placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all disabled:opacity-50"
            />
            {errors.firstName && (
              <p className="text-xs text-destructive font-medium flex items-center gap-1 mt-1">
                <span className="w-1 h-1 rounded-full bg-destructive" />
                {errors.firstName.message}
              </p>
            )}
          </div>
          <div className="space-y-1.5">
            <label className="block text-sm font-semibold text-foreground">Last Name</label>
            <input
              type="text"
              placeholder="Doe"
              disabled={isSubmitting}
              {...register('lastName')}
              className="w-full px-4 py-3 bg-secondary/50 border border-border rounded-xl text-foreground placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all disabled:opacity-50"
            />
            {errors.lastName && (
              <p className="text-xs text-destructive font-medium flex items-center gap-1 mt-1">
                <span className="w-1 h-1 rounded-full bg-destructive" />
                {errors.lastName.message}
              </p>
            )}
          </div>
        </div>

        {/* Phone */}
        <div className="space-y-1.5">
          <label className="block text-sm font-semibold text-foreground">Phone Number</label>
          <div className="relative group">
            <input
              type="tel"
              placeholder="0555555555"
              disabled={isSubmitting}
              {...register('phone')}
              className="w-full pl-4 pr-10 py-3 bg-secondary/50 border border-border rounded-xl text-foreground placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all disabled:opacity-50"
            />
            <div className="absolute right-4 top-1/2 -translate-y-1/2 text-muted-foreground font-medium text-sm select-none pointer-events-none">
              DZ
            </div>
          </div>
          {errors.phone && (
            <p className="text-xs text-destructive font-medium flex items-center gap-1 mt-1">
              <span className="w-1 h-1 rounded-full bg-destructive" />
              {errors.phone.message}
            </p>
          )}
        </div>

        {/* Email (Optional) */}
        <div className="space-y-1.5">
          <div className="flex items-center justify-between">
            <label className="block text-sm font-semibold text-foreground">Email</label>
            <span className="text-xs text-muted-foreground font-medium">Optional</span>
          </div>
          <input
            type="email"
            placeholder="you@example.com"
            disabled={isSubmitting}
            {...register('email')}
            className="w-full px-4 py-3 bg-secondary/50 border border-border rounded-xl text-foreground placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all disabled:opacity-50"
          />
          {errors.email && (
            <p className="text-xs text-destructive font-medium flex items-center gap-1 mt-1">
              <span className="w-1 h-1 rounded-full bg-destructive" />
              {errors.email.message}
            </p>
          )}
        </div>

        {/* Passwords */}
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-1.5">
            <label className="block text-sm font-semibold text-foreground">Password</label>
            <input
              type="password"
              placeholder="••••••••"
              disabled={isSubmitting}
              {...register('password')}
              className="w-full px-4 py-3 bg-secondary/50 border border-border rounded-xl text-foreground placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all disabled:opacity-50 tracking-widest"
            />
            {errors.password && (
              <p className="text-xs text-destructive font-medium flex items-center gap-1 mt-1">
                <span className="w-1 h-1 rounded-full bg-destructive" />
                {errors.password.message}
              </p>
            )}
          </div>
          <div className="space-y-1.5">
            <label className="block text-sm font-semibold text-foreground">Confirm</label>
            <input
              type="password"
              placeholder="••••••••"
              disabled={isSubmitting}
              {...register('confirmPassword')}
              className="w-full px-4 py-3 bg-secondary/50 border border-border rounded-xl text-foreground placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all disabled:opacity-50 tracking-widest"
            />
            {errors.confirmPassword && (
              <p className="text-xs text-destructive font-medium flex items-center gap-1 mt-1">
                <span className="w-1 h-1 rounded-full bg-destructive" />
                {errors.confirmPassword.message}
              </p>
            )}
          </div>
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
                  <span>Creating Account...</span>
                </>
              ) : (
                <>
                  <UserPlus size={18} className="transition-transform group-hover:-translate-x-1" />
                  <span>Sign Up</span>
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
          Already have an account?{' '}
          <Link href="/auth/login" className="text-primary hover:underline underline-offset-4 decoration-2">
            Sign in
          </Link>
        </p>
      </div>
    </>
  );
}
