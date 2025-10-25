import fs from "fs/promises";
import path from "path";

export interface PerfilCET {
  id: string;
  instituicao: string;
  vigencia: { ini: string; fim: string | null };
  daycount: "30360" | "ACT365";
  arredondamento: "HALF_UP" | "HALF_DOWN";
  iof: any;
  tarifas: any;
  seguros: any;
  prorata: boolean;
  observacoes: string;
}

const PROFILES_DIR = path.join(__dirname, "../../../engine/profiles");

export async function listarPerfis(): Promise<PerfilCET[]> {
  const files = await fs.readdir(PROFILES_DIR);
  const jsonFiles = files.filter((f) => f.endsWith(".json"));

  const perfis = await Promise.all(
    jsonFiles.map(async (file) => {
      const content = await fs.readFile(path.join(PROFILES_DIR, file), "utf-8");
      return JSON.parse(content);
    }),
  );

  return perfis;
}

export async function buscarPerfil(id: string): Promise<PerfilCET | null> {
  try {
    const content = await fs.readFile(
      path.join(PROFILES_DIR, `${id}.json`),
      "utf-8",
    );
    return JSON.parse(content);
  } catch {
    return null;
  }
}
