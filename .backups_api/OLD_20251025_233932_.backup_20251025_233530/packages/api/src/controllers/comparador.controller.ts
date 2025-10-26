import { Request, Response } from "express";
import { compararCenarios } from "../services/comparador.service";
import { z } from "zod";

const ComparadorSchema = z.object({
  cenarios: z
    .array(
      z.object({
        id: z.string(),
        nome: z.string(),
        pv: z.number().positive(),
        i: z.number().positive(),
        n: z.number().int().positive(),
      }),
    )
    .min(2)
    .max(5),
});

export async function compararCenariosEndpoint(req: Request, res: Response) {
  try {
    const validated = ComparadorSchema.parse(req.body);
    const resultado = await compararCenarios(validated.cenarios);

    res.json({
      success: true,
      data: resultado,
    });
  } catch (error: unknown) {
    res.status(400).json({ success: false, error: error.message });
  }
}
