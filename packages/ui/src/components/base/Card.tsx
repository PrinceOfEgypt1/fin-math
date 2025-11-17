import React from "react";

export interface CardProps {
  children: React.ReactNode;
  title?: string;
  className?: string;
  role?: string;
  ariaLabel?: string;
}

/**
 * Componente Card acessível
 *
 * Características de acessibilidade:
 * - Estrutura semântica com heading se título fornecido
 * - Landmarks opcionais via role
 * - Contraste adequado
 */
export const Card: React.FC<CardProps> = ({
  children,
  title,
  className = "",
  role,
  ariaLabel,
}) => {
  return (
    <div
      role={role}
      aria-label={ariaLabel}
      className={`bg-white rounded-lg shadow-md border border-gray-200 p-6 ${className}`}
    >
      {title && (
        <h2 className="text-xl font-semibold text-gray-900 mb-4">{title}</h2>
      )}
      {children}
    </div>
  );
};
