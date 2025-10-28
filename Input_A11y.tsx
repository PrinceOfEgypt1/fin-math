import { InputHTMLAttributes, forwardRef, useId } from "react";
import { cn } from "@/lib/utils";
import { AlertCircle } from "lucide-react";

export interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  /** Label do input */
  label?: string;
  /** Mensagem de erro */
  error?: string;
  /** Mensagem de ajuda */
  helperText?: string;
  /** Ícone à esquerda */
  leftIcon?: React.ReactNode;
  /** Ícone à direita */
  rightIcon?: React.ReactNode;
  /** Se o campo é obrigatório */
  isRequired?: boolean;
}

/**
 * Componente Input com acessibilidade WCAG 2.2 AA
 *
 * Recursos de acessibilidade:
 * - Label associado via htmlFor/id
 * - Mensagens de erro com aria-describedby
 * - Indicador visual de erro
 * - Indicador de campo obrigatório
 * - Contraste adequado
 */
export const Input = forwardRef<HTMLInputElement, InputProps>(
  (
    {
      label,
      error,
      helperText,
      leftIcon,
      rightIcon,
      className,
      id,
      isRequired = false,
      ...props
    },
    ref,
  ) => {
    // Gerar IDs únicos para acessibilidade
    const generatedId = useId();
    const inputId = id || generatedId;
    const errorId = `${inputId}-error`;
    const helperId = `${inputId}-helper`;

    // Se há erro, substituir rightIcon por ícone de erro
    const displayRightIcon = error ? (
      <AlertCircle className="w-4 h-4 text-danger" aria-hidden="true" />
    ) : (
      rightIcon
    );

    return (
      <div className="w-full">
        {label && (
          <label
            htmlFor={inputId}
            className="block text-sm font-medium text-slate-300 mb-2"
          >
            {label}
            {isRequired && (
              <span className="text-danger ml-1" aria-label="obrigatório">
                *
              </span>
            )}
          </label>
        )}

        <div className="relative">
          {leftIcon && (
            <div
              className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
              aria-hidden="true"
            >
              {leftIcon}
            </div>
          )}

          <input
            ref={ref}
            id={inputId}
            className={cn(
              "input-field",
              leftIcon && "pl-10",
              (rightIcon || error) && "pr-10",
              error && "border-danger focus:border-danger focus:ring-danger/50",
              className,
            )}
            // ARIA
            aria-invalid={error ? "true" : "false"}
            aria-describedby={
              error ? errorId : helperText ? helperId : undefined
            }
            aria-required={isRequired}
            {...props}
          />

          {displayRightIcon && (
            <div
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400"
              aria-hidden="true"
            >
              {displayRightIcon}
            </div>
          )}
        </div>

        {error && (
          <p
            id={errorId}
            className="mt-2 text-sm text-danger animate-slide-down"
            role="alert"
          >
            {error}
          </p>
        )}

        {helperText && !error && (
          <p id={helperId} className="mt-2 text-sm text-slate-400">
            {helperText}
          </p>
        )}
      </div>
    );
  },
);

Input.displayName = "Input";
