import express from "express";
import { getAuth, signup } from "../controllers/user_controllers.js";
import authMiddelware from "../middleware/auth_middleare.js";
const router = express.Router();

router.post("/signup", signup);

router.get("/", authMiddelware, getAuth);

export default router;
