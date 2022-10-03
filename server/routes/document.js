import express from "express";
import {
  createDoc,
  docTitle,
  getDocs,
  getSingelDoc,
} from "../controllers/document_controllers.js";
const router = express.Router();
import authMiddleware from "../middleware/auth_middleare.js";

router.post("/create", authMiddleware, createDoc);
router.get("/me", authMiddleware, getDocs);
router.post("/title", authMiddleware, docTitle);
router.get("/:id", authMiddleware, getSingelDoc);

export default router;
