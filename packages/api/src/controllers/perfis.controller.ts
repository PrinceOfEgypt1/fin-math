import { Request, Response } from "express";
import { listarPerfis, buscarPerfil } from "../services/perfis.service";

export async function listarPerfisEndpoint(req: Request, res: Response) {
  try {
    const perfis = await listarPerfis();
    res.json({
      success: true,
      version: "2025-01",
      data: perfis.map((p) => ({
        id: p.id,
        instituicao: p.instituicao,
        vigencia: p.vigencia,
      })),
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
}

export async function buscarPerfilEndpoint(req: Request, res: Response) {
  try {
    const perfil = await buscarPerfil(req.params.id);
    if (!perfil) {
      return res
        .status(404)
        .json({ success: false, error: "Perfil não encontrado" });
    }
    res.json({ success: true, data: perfil });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
}
