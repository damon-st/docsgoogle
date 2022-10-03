import express from "express";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const router = express.Router();
const __filename = fileURLToPath(import.meta.url);
const PATH_ROUTES = path.dirname(__filename);

const removeExtension = (fileName) => {
  return fileName.split(".").shift();
};

fs.readdirSync(PATH_ROUTES).filter(async (file) => {
  const name = removeExtension(file);
  if (name !== "index") {
    router.use(`/${name}`, (await import(`./${file}`)).default);
  }
});

export default router;
