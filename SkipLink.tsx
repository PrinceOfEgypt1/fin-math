/**
 * SkipLink - Componente de acessibilidade para pular navegação
 * WCAG 2.1 - 2.4.1 Bypass Blocks (Level A)
 */

interface SkipLinkProps {
  /** ID do elemento de conteúdo principal */
  contentId?: string;
  /** Texto do link */
  text?: string;
}

export const SkipLink = ({
  contentId = "main-content",
  text = "Pular para o conteúdo principal",
}: SkipLinkProps) => {
  return (
    <a
      href={`#${contentId}`}
      className="skip-to-content"
      // ARIA
      aria-label={text}
    >
      {text}
    </a>
  );
};
