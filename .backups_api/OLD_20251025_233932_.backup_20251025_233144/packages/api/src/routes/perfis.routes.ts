import { Router } from "express";
import {
  listarPerfisEndpoint,
  buscarPerfilEndpoint,
} from "../controllers/perfis.controller";

const router = Router();

router.get("/", listarPerfisEndpoint);
router.get("/:id", buscarPerfilEndpoint);

export default router;
