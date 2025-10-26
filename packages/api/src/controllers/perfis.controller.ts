// packages/api/src/controllers/perfis.controller.ts
import { Request, Response } from "express";
import { listarPerfis, buscarPerfil } from "../services/perfis.service";

export async function listarPerfisEndpoint(_req: Request, res: Response) {
  try {
    const perfis = await listarPerfis();
    return res.json({
      success: true,
      version: "2025-01",
      data: perfis.map((p) => ({
        id: p.id,
        instituicao: p.instituicao,
        vigencia: p.vigencia,
      })),
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    return res.status(500).json({ success: false, error: message });
  }
}

export async function buscarPerfilEndpoint(req: Request, res: Response) {
  try {
    const { id } = (req.params ?? {}) as { id?: string };
    if (!id) {
      return res
        .status(400)
        .json({ success: false, error: "Parâmetro id ausente" });
    }

    const perfil = await buscarPerfil(id);
    if (!perfil) {
      return res
        .status(404)
        .json({ success: false, error: "Perfil não encontrado" });
    }
    return res.json({ success: true, data: perfil });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    return res.status(500).json({ success: false, error: message });
  }
}
