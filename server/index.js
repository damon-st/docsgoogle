import express from "express";
import "./config/config.js";
import "./db/connect_mongoose.js";
import cors from "cors";
import router from "./routes/index.js";
import http from "http";
import socke from "socket.io";
import DocumentSchema from "./models/document_model.js";
const PORT = process.env.PORT || 5000;
const app = express();
var server = http.createServer(app);
var io = socke(server);
io.on("connection", (socket) => {
  console.log("Connected " + socket.id);
  socket.on("join", (documentId) => {
    socket.join(documentId);
    console.log("Join " + socket.id);
  });
  socket.on("typing", (data) => {
    socket.broadcast.to(data.room).emit("changes", data);
  });
  socket.on("save", (data) => {
    saveData(data);
  });
});

const saveData = async (data) => {
  try {
    let document = await DocumentSchema.findById(data.room);
    document.content = data.delta;
    document = await document.save();
  } catch (e) {
    console.log(e);
  }
};

app.use(cors());
app.use(express.json());
app.use("/api", router);
server.listen(PORT, "0.0.0.0", () => {
  console.log("LISTEN ON PORT " + PORT);
});
