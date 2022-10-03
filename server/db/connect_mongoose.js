import mongoose from "mongoose";

const DB = process.env.MONGO_DB;
mongoose
  .connect(DB)
  .then((e) => {
    console.log("CONNECT BASE SUCCESS");
  })
  .catch((r) => {
    console.log("CONNECT ERRORR DB " + r);
  });
