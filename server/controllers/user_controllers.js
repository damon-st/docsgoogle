import UserSchema from "../models/user_model.js";
import jwt from "jsonwebtoken";
import { JWT_SECRET } from "../config/config.js";
const signup = async (req, res) => {
  try {
    const { name, email, profilePic } = req.body;
    let user = await UserSchema.findOne({ email });
    if (!user) {
      user = new UserSchema({
        name,
        email,
        profilePic,
      });
      user = await user.save();
    }

    const token = jwt.sign({ id: user._id }, JWT_SECRET);

    return res.status(200).json({
      status: "success",
      user,
      token,
    });
  } catch (e) {
    console.log(e);
    return res.status(500).send({
      error: e.toString(),
      status: "error",
      msg: "Error server",
    });
  }
};
const getAuth = async (req, res) => {
  try {
    let user = await UserSchema.findById(req.user);
    return res.status(200).send({
      user,
      token: req.token,
      status: "success",
    });
  } catch (e) {
    return res.status(500).send({
      status: "error",
      error: e.toString(),
      msg: "Error server",
    });
  }
};
export { signup, getAuth };
