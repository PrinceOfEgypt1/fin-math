import React from "react";

export interface InputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  hint?: string;
  error?: string;
  showLabel?: boolean;
}

/**
 * Componente Input acessível (WCAG 2.1 AA)
 *
 * Características de acessibilidade:
 * - Label associado via htmlFor/id
 * - aria-required para campos obrigatórios
 * - aria-invalid e aria-describedby para erros
 * - Indicador de foco visível
 * - Contraste adequado
 */
export const Input: React.FC<InputProps> = ({
  label,
  hint,
  error,
  showLabel = true,
  id,
  required = false,
  className = "",
  ...props
}) => {
  // Gera ID único se não fornecido
  const inputId = id || `input-${label.toLowerCase().replace(/\s+/g, "-")}`;
  const hintId = hint ? `${inputId}-hint` : undefined;
  const errorId = error ? `${inputId}-error` : undefined;

  const baseStyles =
    "block w-full px-4 py-2.5 text-base text-gray-900 bg-white border rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-offset-1";

  const stateStyles = error
    ? "border-red-500 focus:ring-red-500 focus:border-red-500"
    : "border-gray-300 focus:ring-blue-500 focus:border-blue-500";

  return (
    <div className="w-full">
      <label
        htmlFor={inputId}
        className={`block mb-2 text-sm font-medium text-gray-900 ${
          !showLabel ? "sr-only" : ""
        }`}
      >
        {label}
        {required && (
          <span className="text-red-600 ml-1" aria-label="obrigatório">
            *
          </span>
        )}
      </label>

      <input
        id={inputId}
        required={required}
        aria-required={required}
        aria-invalid={error ? true : undefined}
        aria-describedby={
          [hintId, errorId].filter(Boolean).join(" ") || undefined
        }
        className={`${baseStyles} ${stateStyles} ${className}`}
        {...props}
      />

      {hint && !error && (
        <p id={hintId} className="mt-1.5 text-sm text-gray-600">
          {hint}
        </p>
      )}

      {error && (
        <p id={errorId} className="mt-1.5 text-sm text-red-600" role="alert">
          {error}
        </p>
      )}
    </div>
  );
};
