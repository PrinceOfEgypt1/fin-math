import { Router } from "express";
import { calculateIRREndpoint } from "../controllers/irr.controller";

const router = Router();

/**
 * POST /api/irr
 * Calcula TIR (Taxa Interna de Retorno) usando método de Brent
 */
router.post("/", calculateIRREndpoint);

export default router;
