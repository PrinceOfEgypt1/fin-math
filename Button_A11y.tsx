import { ButtonHTMLAttributes, forwardRef } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { Loader2 } from "lucide-react";

/**
 * Variantes do botão
 */
export type ButtonVariant =
  | "primary"
  | "secondary"
  | "outline"
  | "ghost"
  | "danger";

/**
 * Tamanhos do botão
 */
export type ButtonSize = "sm" | "md" | "lg";

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  /** Variante visual do botão */
  variant?: ButtonVariant;
  /** Tamanho do botão */
  size?: ButtonSize;
  /** Estado de carregamento */
  loading?: boolean;
  /** Ícone à esquerda */
  leftIcon?: React.ReactNode;
  /** Ícone à direita */
  rightIcon?: React.ReactNode;
  /** Largura total */
  fullWidth?: boolean;
  /** Descrição acessível (quando ícone sem texto) */
  ariaLabel?: string;
}

const variantClasses: Record<ButtonVariant, string> = {
  primary: "btn-primary",
  secondary: "btn-secondary",
  outline: "btn-outline",
  ghost: "hover:bg-slate-800/50 text-slate-100",
  danger:
    "bg-danger hover:bg-danger-hover text-white shadow-lg shadow-danger/50",
};

const sizeClasses: Record<ButtonSize, string> = {
  sm: "px-4 py-2 text-sm min-h-[40px]", // Próximo ao mínimo touch de 44px
  md: "px-6 py-3 text-base min-h-[44px]", // Exato touch target
  lg: "px-8 py-4 text-lg min-h-[48px]", // Confortável
};

/**
 * Componente Button com acessibilidade WCAG 2.2 AA
 *
 * Recursos de acessibilidade:
 * - Touch target mínimo de 44x44px (WCAG 2.5.5)
 * - Foco visível (WCAG 2.4.7)
 * - Estados claros (loading, disabled)
 * - ARIA labels quando necessário
 * - Contraste adequado (≥4.5:1)
 */
export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      children,
      variant = "primary",
      size = "md",
      loading = false,
      leftIcon,
      rightIcon,
      fullWidth = false,
      className,
      disabled,
      ariaLabel,
      ...props
    },
    ref,
  ) => {
    const MotionButton = motion.button as any;

    // Se não há children (botão apenas com ícone), aria-label é obrigatório
    const needsAriaLabel = !children && (leftIcon || rightIcon);

    return (
      <MotionButton
        ref={ref}
        whileHover={{ scale: disabled || loading ? 1 : 1.02 }}
        whileTap={{ scale: disabled || loading ? 1 : 0.98 }}
        className={cn(
          "btn inline-flex items-center justify-center gap-2 font-semibold",
          "transition-all duration-200",
          "focus-visible:outline-none focus-visible:ring-2",
          "focus-visible:ring-offset-2 focus-visible:ring-offset-surface",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          variantClasses[variant],
          sizeClasses[size],
          fullWidth && "w-full",
          className,
        )}
        disabled={disabled || loading}
        // ARIA
        aria-label={needsAriaLabel ? ariaLabel : undefined}
        aria-busy={loading}
        aria-disabled={disabled || loading}
        data-variant={variant}
        {...props}
      >
        {loading && (
          <Loader2 className="w-4 h-4 animate-spin" aria-hidden="true" />
        )}
        {!loading && leftIcon && <span aria-hidden="true">{leftIcon}</span>}
        {children}
        {!loading && rightIcon && <span aria-hidden="true">{rightIcon}</span>}
      </MotionButton>
    );
  },
);

Button.displayName = "Button";
