import React from "react";

/**
 * ExplainPanel - Componente de explicação e documentação
 * Usado nas telas para exibir fórmulas, variáveis e explicações
 */

interface ExplainPanelProps {
  /** Título do painel */
  title?: string;

  /** Lista de fórmulas matemáticas */
  formulae?: string[];

  /** Variáveis utilizadas no cálculo */
  variables?: Record<string, any>;

  /** Metadados do cálculo */
  meta?: {
    motorVersion?: string;
    calculationId?: string;
    [key: string]: any;
  };

  /** Notas adicionais */
  notes?: string[];

  /** Conteúdo filho */
  children?: React.ReactNode;
}

export const ExplainPanel: React.FC<ExplainPanelProps> = ({
  title,
  formulae = [],
  variables = {},
  meta = {},
  notes = [],
  children,
}) => {
  return (
    <div className="rounded-lg border border-blue-200 bg-blue-50 p-4 shadow-sm">
      {/* Título */}
      {title && (
        <h3 className="mb-3 text-lg font-semibold text-blue-900">{title}</h3>
      )}

      {/* Fórmulas */}
      {formulae.length > 0 && (
        <div className="mb-3">
          <h4 className="mb-2 text-sm font-medium text-blue-800">Fórmulas:</h4>
          <ul className="list-disc space-y-1 pl-5">
            {formulae.map((formula, idx) => (
              <li key={idx} className="font-mono text-xs text-blue-700">
                {formula}
              </li>
            ))}
          </ul>
        </div>
      )}

      {/* Variáveis */}
      {Object.keys(variables).length > 0 && (
        <div className="mb-3">
          <h4 className="mb-2 text-sm font-medium text-blue-800">Variáveis:</h4>
          <dl className="grid grid-cols-2 gap-2 text-xs">
            {Object.entries(variables).map(([key, value]) => (
              <div key={key} className="flex justify-between">
                <dt className="font-medium text-blue-700">{key}:</dt>
                <dd className="font-mono text-blue-600">
                  {typeof value === "object"
                    ? JSON.stringify(value)
                    : String(value)}
                </dd>
              </div>
            ))}
          </dl>
        </div>
      )}

      {/* Metadata */}
      {Object.keys(meta).length > 0 && (
        <div className="mb-3">
          <h4 className="mb-2 text-sm font-medium text-blue-800">Metadata:</h4>
          <dl className="space-y-1 text-xs">
            {Object.entries(meta).map(([key, value]) => (
              <div key={key} className="flex gap-2">
                <dt className="font-medium text-blue-700">{key}:</dt>
                <dd className="font-mono text-blue-600">{String(value)}</dd>
              </div>
            ))}
          </dl>
        </div>
      )}

      {/* Notas */}
      {notes.length > 0 && (
        <div className="mb-3">
          <h4 className="mb-2 text-sm font-medium text-blue-800">Notas:</h4>
          <ul className="list-disc space-y-1 pl-5">
            {notes.map((note, idx) => (
              <li key={idx} className="text-xs text-blue-700">
                {note}
              </li>
            ))}
          </ul>
        </div>
      )}

      {/* Children */}
      {children && <div className="text-sm text-blue-700">{children}</div>}
    </div>
  );
};

export default ExplainPanel;
