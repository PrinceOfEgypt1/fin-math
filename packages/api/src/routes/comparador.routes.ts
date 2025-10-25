import { Router } from "express";
import { compararCenariosEndpoint } from "../controllers/comparador.controller";

const router = Router();

router.post("/comparar", compararCenariosEndpoint);

export default router;
