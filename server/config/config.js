import { config } from "dotenv";
config();

const MONGO_DB = process.env.MONGO_DB;
const JWT_SECRET = process.env.JWT_SECRET;

export { MONGO_DB, JWT_SECRET };
