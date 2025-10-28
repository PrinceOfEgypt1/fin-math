// packages/api/src/controllers/xlsx-export.controller.ts
import { Request, Response } from "express";
import { exportToXLSX } from "../services/xlsx-export.service";

export async function exportScheduleXLSX(req: Request, res: Response) {
  try {
    const { schedule, pv, i, n } = req.body;

    const buffer = await exportToXLSX(schedule, pv, i, n);

    res.setHeader(
      "Content-Type",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    );
    res.setHeader(
      "Content-Disposition",
      "attachment; filename=cronograma.xlsx",
    );
    return res.send(buffer);
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    return res.status(500).json({ success: false, error: message });
  }
}
