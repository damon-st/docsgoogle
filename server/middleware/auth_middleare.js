import jwt from "jsonwebtoken";
import { JWT_SECRET } from "../config/config.js";
const authMiddelware = async (req, res, next) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) {
      return res.status(401).json({
        status: "error",
        msg: "No auth token, access denied.",
      });
    }
    const verified = jwt.verify(token, JWT_SECRET);
    if (!verified) {
      return res.status(401).json({
        status: "error",
        msg: "Token verification failed, authorization denied",
      });
    }
    req.user = verified.id;
    req.token = token;
    next();
  } catch (e) {
    return res.status(500).send({
      status: "error",
      error: e.toString(),
    });
  }
};

export default authMiddelware;
