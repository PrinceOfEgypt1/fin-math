import React from 'react';

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
  helperText?: string;
}

/**
 * Input acessível com label, error e helper text.
 * Segue WCAG 2.1 AA.
 */
export function Input({
  label,
  error,
  helperText,
  id,
  className = '',
  required,
  ...props
}: InputProps) {
  // Gerar ID único se não fornecido
  const inputId = id || `input-${label.toLowerCase().replace(/\s+/g, '-')}`;
  const errorId = `${inputId}-error`;
  const helperId = `${inputId}-helper`;

  return (
    <div className="mb-4">
      <label
        htmlFor={inputId}
        className="block text-sm font-medium text-gray-700 mb-1"
      >
        {label}
        {required && (
          <span className="text-red-500 ml-1" aria-label="obrigatório">
            *
          </span>
        )}
      </label>

      <input
        id={inputId}
        className={`
          w-full px-3 py-2 border rounded-md
          focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent
          disabled:bg-gray-100 disabled:cursor-not-allowed
          ${error ? 'border-red-500' : 'border-gray-300'}
          ${className}
        `}
        aria-required={required}
        aria-invalid={!!error}
        aria-describedby={
          error ? errorId : helperText ? helperId : undefined
        }
        {...props}
      />

      {helperText && !error && (
        <p id={helperId} className="mt-1 text-sm text-gray-500">
          {helperText}
        </p>
      )}

      {error && (
        <p id={errorId} className="mt-1 text-sm text-red-600" role="alert">
          {error}
        </p>
      )}
    </div>
  );
}
